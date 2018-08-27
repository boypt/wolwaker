const _ = require('lodash');
var express = require('express');
var router = express.Router();
var crypto = require('crypto');
const EventEmitter = require('events');
class notifyEvent extends EventEmitter {}

const gOnlineDict = {}

/*
//test data
gOnlineDict["12345678901234"] = { 
  remote:['127.0.0.1',4444], 
  pairs:[['9C:8E:99:E4:00:00','STUB_PCName'], ['9C:8E:99:E4:00:00','STUB_NasName']], 
  emiter: new EventEmitter()
};
*/

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { _:_, gOnlineDict: gOnlineDict,  title: 'Express' });
});

router.get('/callwake', function(req, res, next) {
  if(_.size(gOnlineDict) > 0) {

    var key = req.query.key;
    var index = parseInt(req.query.index);
    if (_.has(gOnlineDict, key)) {
      var waker = _.get(gOnlineDict, key);
      waker.emiter.emit('wake', index)
      res.send(`Wake ${waker.pairs[index]}`)
    } else {
      res.send("Invalid key")
    }
  } else {
    res.send("size 0")
  }
});

router.get('/regpull', function(req, res, next) {

  var parser = /([0-9a-f:]{17})\[([0-9a-z-_]+)\]/i
  var regs = req.query.r;
  var _now = Date.now();

  console.log(regs)
  // 123456ABCDEF[NAME] ABCDEF567890[NAME]
  var pairs = regs.split(' ').map((p) => {
    let grp = p.match(parser);
    return [grp[1], grp[2]];
  });

  var md5 = crypto.createHash('md5');
  var remoteid = md5.update(`${req.connection.remoteAddress}:${req.connection.remotePort}`)
    .digest('hex');

  var noevn = new notifyEvent();

  // one time event
  noevn.once('wake', (index) => {
    res.send(index.toString());
  });

  gOnlineDict[remoteid] = {
    "time": _now,
    "remote": [req.connection.remoteAddress, req.connection.remotePort],
    "pairs": pairs,
    "emiter":noevn
  };

  res.on('close', () =>{
    delete gOnlineDict[remoteid];
    console.log(`conn closed: ${remoteid}`);
  })

  res.on('finish', () =>{
    delete gOnlineDict[remoteid];
    console.log(`conn finished: ${remoteid}`);
  })

});

module.exports = router;
