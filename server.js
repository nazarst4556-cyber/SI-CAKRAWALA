const http = require("http");
const fs = require("fs");
const path = require("path");

const mime = {
  ".html": "text/html",
  ".css": "text/css",
  ".js": "text/javascript",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png"
};

const server = http.createServer((req, res) => {
  let file = req.url === "/" ? "/index.html" : req.url;
  let p = path.join(__dirname, file.split("?")[0]);
  if (!fs.existsSync(p)) {
    res.writeHead(404);
    res.end("Not Found");
    return;
  }
  let ext = path.extname(p);
  res.writeHead(200, { "Content-Type": mime[ext] || "text/plain" });
  fs.createReadStream(p).pipe(res);
});

server.listen(5050, () => {
  console.log("SERVER_RUNNING_ON_PORT_5050");
});
