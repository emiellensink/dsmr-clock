var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var cors = require('cors');
var p1 = require('p1-reader');

var indexRouter = require('./routes/index');
var datagramRouter = require('./routes/datagram');

var app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(cors());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/datagram', datagramRouter);

const p1Reader = new p1({
    port: '/dev/ttyUSB0',
    baudRate: 115200,
    parity: "even",
    dataBits: 7,
    stopBits: 1
});

p1Reader.on('reading', data => {
    app.locals.previousDatagram = app.locals.datagram;
    app.locals.datagram = data;
});

p1Reader.on('error', err => {
    console.log('Error while reading: ' + err);
});

module.exports = app;
