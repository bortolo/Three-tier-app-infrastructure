const mysql = require('mysql');

const con = mysql.createConnection({
    host: "demodb.ck0joffnfyxn.eu-central-1.rds.amazonaws.com",
    user: process.env.TF_VAR_db_username,
    password: process.env.TF_VAR_db_password
});

con.connect(function(err) {
    if (err) throw err;

    con.query('CREATE DATABASE IF NOT EXISTS main;');
    con.query('USE main;');
    con.query('CREATE TABLE IF NOT EXISTS users(id int NOT NULL AUTO_INCREMENT, username varchar(30), email varchar(255), age int, PRIMARY KEY(id));', function(error, result, fields) {
        console.log(result);
    });
    con.end();
});
