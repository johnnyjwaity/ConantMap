var express = require("express");
var app = express();
var http = require("http").Server(app);
var io = require("socket.io")(http);
var fs = require("fs");
var readline = require("readline");
var stream = require("stream");

var versions = {};

app.use(express.static(__dirname + "/client"));

app.get("/bug-report", function(req, res) {
  res.sendFile(__dirname + "/bug-report.html");
});

app.get("/node-edit", function(req, res) {
  res.sendFile(__dirname + "/node-edit.html");
});

app.get("/version-list", function(req, res) {
  res.send(versions);
});
app.get("/file", function(req, res) {
  res.sendFile(__dirname + "/data/" + req.query.name + ".dat");
});

io.on("connection", function(socket) {
  console.log("user connected");

  socket.on("bug report", function(data) {
    var date = new Date();
    var timeString = date.toLocaleTimeString();
    timeString = timeString.split(":").join("-");
    var fileName = date.toDateString() + " " + timeString + ".txt";
    fileName = "Hello.txt";
    var writeStream = fs.createWriteStream(__dirname + "/reports/" + fileName);
    writeStream.write(data.name + "\n\n" + data.email + "\n\n" + data.report);
    writeStream.close();
  });

  socket.on("node-req", function(data) {
    fs.readFile("nodes.json", "utf8", function(err, contents) {
      var str = contents;
      socket.emit("node-data", JSON.parse(str));
    });
  });

  socket.on("disconnect", function() {
    console.log("user disconnected");
  });
});

http.listen(3000, function() {
  console.log("listening on 3000");
});

function convertToJSON() {
  fs.readFile("nodes.dat", "utf8", function(err, contents) {
    var lines = contents.split("\n");

    var allObjects = [];
    var currentObject = {};
    var addedFirst = false;
    for (i = 0; i < lines.length; i++) {
      var header = lines[i].substr(0, 1);
      var body = lines[i].substr(1, lines.length - 2);
      body = body.replace("\r", "");
      if (header == "%") {
        if (addedFirst) {
          allObjects.push(currentObject);
        }
        addedFirst = true;
        currentObject = {};
        currentObject.name = "";
        currentObject.x = 0.0;
        currentObject.y = 0.0;
        currentObject.floor = 0;
        currentObject.connections = [];
        currentObject.rooms = [];
        currentObject.name = body;
      } else if (header == "x") {
        currentObject.x = parseFloat(body);
      } else if (header == "y") {
        currentObject.y = parseFloat(body);
      } else if (header == "f") {
        currentObject.floor = parseInt(body);
      } else if (header == "-") {
        currentObject.connections.push(body);
      } else if (header == "@") {
        currentObject.rooms.push(body);
      }
    }
    console.log(allObjects);
    fs.writeFile("nodes.json", JSON.stringify(allObjects), "utf8", function(
      err
    ) {});
  });
}
// convertToJSON();

fs.readdir(__dirname + "/data", function(err, items) {
  for (i = 0; i < items.length; i++) {
    var readFirst = false;
    require("fs")
      .readFileSync(__dirname + "/data/" + items[i], "utf-8")
      .split(/\r?\n/)
      .forEach(function(line) {
        if (!readFirst) {
          versions[items[i].split(".")[0]] = parseInt(line);
          readFirst = true;
        }
      });
  }
});
