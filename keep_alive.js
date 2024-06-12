const http = require('http');

http.createServer((req, res) => {
  res.write("ATA <3");
  res.end();
}).listen(8080);