const mysql = require('mysql');

// First you need to create a connection to the database
// Be sure to replace 'user' and 'password' with the correct values
const con = mysql.createConnection({
  host: "demodb.ck0joffnfyxn.eu-central-1.rds.amazonaws.com",
  user: process.env.TF_VAR_db_username,
  password: process.env.TF_VAR_db_password,
  database: "main"
});

const port = 3000;

var express = require('express');
var bodyParser = require('body-parser');

var app = express();

app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies
app.set('views', './views');
app.set('view engine', 'ejs');

app.get('/view', (req, res) => {
    con.connect(function(err) {
        con.query(`SELECT * FROM main.users`, function(err, result, fields) {
            if (err) res.send(err);
            if (result) res.render('viewdb', {obj: result});
        });
    });
});
app.post('/view/add', (req, res) => {
    if (req.body.username && req.body.email && req.body.age) {
        console.log('Request received');
        con.connect(function(err) {
            con.query(`INSERT INTO main.users (username, email, age) VALUES ('${req.body.username}', '${req.body.email}', '${req.body.age}')`, function(err, result, fields) {
                if (err) res.send(err);
                if (result) res.redirect('/view'); //res.send({username: req.body.username, email: req.body.email, age: req.body.age});
                if (fields) console.log(fields);
            });
        });
    } else {
        console.log('Missing a parameter');
    }
});

app.listen(port);
