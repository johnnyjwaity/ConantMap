const ic = require("./ic.js");
const express = require("express");
const https = require("https");
const bodyParser = require("body-parser");
const fs = require("fs");

const versions = JSON.parse(fs.readFileSync("data/manifest.json"));
var data = {};
Object.keys(versions).forEach(element => {
  var fileName = "data/" + element + "." + versions[element].type;
  data[element] = JSON.parse(fs.readFileSync(fileName));
});

let app = express();
const port = 3001;

app.use(bodyParser.json());

app.get("/", (req, res) => {
  res.status(200).json({});
});

app.post("/schedule", (req, res) => {
  let username = req.body.username;
  let password = req.body.password;
  if (
    username == undefined ||
    username == null ||
    password == undefined ||
    password == null
  ) {
    res.status(400).json({
      success: false
    });
    return;
  }
  ic.fetchSchedule(username, password, schedule => {
    if (
      schedule == null ||
      schedule == undefined ||
      Object.keys(schedule) == 0
    ) {
      res.status(400).json({
        success: false
      });
    } else {
      res.status(200).json({
        success: true,
        schedule: schedule
      });
    }
  });
});
app.get("/data", (req, res) => {
  var clientVersion = req.query.version;
  var requestedData = req.query.data;
  var serverVersion = versions[requestedData].version;
  res.setHeader("Version", serverVersion);
  res.setHeader("Update", serverVersion > clientVersion ? 1 : 0);
  res
    .status(200)
    .json(serverVersion > clientVersion ? data[requestedData] : {});
});
app.listen(port, function() {
  console.log("Listenting on " + port);
});
// https
//   .createServer(
//     {
//       key: fs.readFileSync(
//         "/etc/letsencrypt/live/map.johnnywaity.com/privkey.pem"
//       ),
//       cert: fs.readFileSync(
//         "/etc/letsencrypt/live/map.johnnywaity.com/fullchain.pem"
//       )
//     },
//     app
//   )
//   .listen(port, function() {
//     console.log(`Conant Map API Listening on port ${port}`);
//   });
