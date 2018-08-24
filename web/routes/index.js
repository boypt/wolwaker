const _ = require('lodash');
var express = require('express');
var router = express.Router();
var crypto = require('crypto');
const EventEmitter = require('events');
class notifyEvent extends EventEmitter {}

const gOnlineDict = {}

//test data
gOnlineDict["12345678901234"] = { remote:['127.0.0.1',4444], pairs:[['333','PCName'], ['555','NasName']], emiter: new EventEmitter()}

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { _:_, gOnlineDict: gOnlineDict,  title: 'Express' });
});

router.get('/callwake', function(req, res, next) {
  if(_.size(gOnlineDict) > 0) {

    var key = req.query.key;
    var reqmac = req.query.mac;
    if (_.has(gOnlineDict, key)) {


      var waker = _.get(gOnlineDict, key);
      var idx = _.findIndex(waker.pairs, (p) => p[0] == reqmac )
      if(idx > -1) {
        [ mac, name ] = waker.pairs[idx];
        waker.emiter.emit('wake', mac)
        res.send(`call ${mac}`)
      } else {
        res.send("invalid mac")
      }
    } else {
      res.send("invalid key")
    }
  } else {
    res.send("size 0")
  }
});

router.get('/regpull', function(req, res, next) {

  var parser = /([0-9a-f:]{17})\[([0-9a-z-_]+)\]/i
  var regs = req.query.r;
  // 123456ABCDEF[NAME],ABCDEF567890[NAME]
  var pairs = regs.split(',').map((p) => {
    let grp = p.match(parser);
    return [grp[1], grp[2]];
  });

  var md5 = crypto.createHash('md5');
  var remoteid = md5.update(`${req.connection.remoteAddress}:${req.connection.remotePort}:${Date.now()}`)
    .digest('hex');


  const noevn = new notifyEvent();

  // one time event
  noevn.on('wake', (mac) => {
    res.send(mac);
  });

  gOnlineDict[remoteid] = {
    "remote": [req.connection.remoteAddress, req.connection.remotePort],
    "pairs": pairs,
    "emiter":noevn
  }

  res.on('close', () =>{
    delete gOnlineDict[remoteid];
    console.log(`conn closed: ${remoteid}`);
  })
  res.on('finish', () =>{
    delete gOnlineDict[remoteid];
    console.log(`conn finished: ${remoteid}`);
  })

  //res.render('index', { title: 'Express' });
});

module.exports = router;
