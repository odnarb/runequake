var express = require('express');
var app = express();
var CryptoJS = require('crypto-js');
var bodyParser = require('body-parser');
app.use(bodyParser.json()); // for parsing application/json

var key = process.argv[2]; //get the key from command line, why not

var quake_response = {
    status: "success",
    details: "Code pulled in, compiled, copied progs.dat, changed level!"
};

console.reset = function () {
    return process.stdout.write('\033c');
}

app.post('/deploy-quake-dev', function (req, res) {
    var sent_secret = req.get('X-Hub-Signature');
    var my_generated_secret = "sha1=" + CryptoJS.HmacSHA1( JSON.stringify(req.body), key);

    if( my_generated_secret != sent_secret ) {
        res.status(403);
        return res.json({ status: "failed", reason: "Bad login" });
    }
    var exec = require('child_process').exec;
    var child = exec('/home/ubuntu/deploy-quake-dev.sh',
        function(error, stdout, stderr) {
            if (error !== null) {
                res.status(500).json({ error: 'Failed to deploy runequake code' });
            }
            return res.json(quake_response);
    });
});

app.get('/deploy-quake-prod', function (req, res) {
    var guid = req.query.guid;
    if( key != guid ) {
        res.status(403);
        return res.json({ status: "failed", reason: "Bad login" });
    }
    quake_response = {
        status: "success",
        details: "Copied progs.dat to /runequake folder!"
    };

    var exec = require('child_process').exec;
    var child = exec('/home/ubuntu/deploy-quake-prod.sh',
        function(error, stdout, stderr) {
            quake_response.compile_output = stdout;
            quake_response.compile_errors = stderr;
            if (error !== null) {
                res.status(500).json({ error: 'Failed to deploy runequake code' });
            }
            return res.json(quake_response);
    });
});

app.listen(8530, function () {
    console.log('Quake server applet listening on port 8530!');
});