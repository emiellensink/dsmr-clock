var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
    const response = { 
        datagrams: {
            current: req.app.locals.datagram,
            previous: req.app.locals.previousDatagram
        }
    };
    
    res.json(response);
});

module.exports = router;
