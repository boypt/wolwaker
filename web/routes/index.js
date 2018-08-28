const debug = require('debug')('web:server:index.js');
const _ = require('lodash');
var express = require('express');
var router = express.Router();
var crypto = require('crypto');
const EventEmitter = require('events');
class notifyEvent extends EventEmitter {}

const gOnlineDict = {}

// ui stub data
/*
gOnlineDict["12345678901234"] = { 
  hostname: 'stub-TESTDATA',
  remote:'127.0.0.1', 
  pairs:[['9C:8E:99:E4:00:00','STUB_PCName'], ['9C:8E:99:E4:00:00','STUB_NasName']], 
  emiter: new EventEmitter()
};
*/

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { _:_, gOnlineDict: gOnlineDict });
});

router.get('/callwake', function(req, res, next) {
  if(_.size(gOnlineDict) > 0) {

    var key = req.query.key;
    var index = parseInt(req.query.index);
    if (_.has(gOnlineDict, key)) {
      var waker = _.get(gOnlineDict, key);
      waker.emiter.emit('wake', index)
      res.send(`Wake ${waker.pairs[index][0]}`)
    } else {
      res.send("Invalid key")
    }
  } else {
    res.send("size 0")
  }
});

router.get('/regpull', function(req, res, next) {

  var regs = req.query.r;
  var hostname = req.query.hostname.match(/[a-z0-9-_]+/i)[0];
  var _now = Date.now();

  // 123456ABCDEF[NAME] ABCDEF567890[NAME]
  var pairs = regs.split('|').map(p => p.split(','));

  var md5 = crypto.createHash('md5');
  var remoteid = md5.update(`${req.ip}:${hostname}:${req.connection.remotePort}:${_now}`)
    .digest('hex');

  var noevn = new notifyEvent();

  // one time event
  noevn.once('wake', (index) => {
    res.send(index.toString());
  });

  gOnlineDict[remoteid] = {
    "time": _now,
    "remote": req.ip,
    "hostname": hostname,
    "pairs": pairs,
    "emiter":noevn
  };

  res.on('close', () =>{
    delete gOnlineDict[remoteid];
    debug(`conn closed: ${req.ip}`);
  })

  res.on('finish', () =>{
    delete gOnlineDict[remoteid];
    debug(`conn finished: ${req.ip}`);
  })

});

module.exports = router;
