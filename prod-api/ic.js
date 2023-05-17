const tls = require("tls");
const http = require("https");

const useGradeSchedule = false;

function retrieveLoginCookies(username, password, callback) {
  var d =
    "POST /campus/verify.jsp HTTP/1.1\r\nCookie: portalLang=en\r\nUser-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/74.0.3729.169 Chrome/74.0.3729.169 Safari/537.36\r\nReferer: https://campus.d211.org/campus/portal/township.jsp\r\nHost: campus.d211.org\r\nContent-Type: application/x-www-form-urlencoded\r\ncache-control: no-cache\r\nPostman-Token: e9d9e932-2f6e-4ace-948f-8382f461d9ab\r\nAccept: */*\r\naccept-encoding: gzip, deflate\r\ncontent-length: 133\r\nConnection: keep-alive\r\n\r\nusername=" +
    username +
    "&password=" +
    password +
    "&appName=township&portalURL=portal%252fstudents%252ftownship.jsp&lang=en&portalLoginPage=students";

  var socket = tls.connect(443, "campus.d211.org", function() {
    socket.write(d);
  });
  socket.on("data", function(data) {
    var response = data.toString();
    var lines = response.split("\r\n");
    var cookies = {};
    for (i = 0; i < lines.length; i++) {
      if (lines[i].includes("Set-Cookie")) {
        var cookieHeader = lines[i];
        var cookieBody = cookieHeader.split("Set-Cookie: ")[1];
        var cookie = cookieBody.split("; ")[0];
        cookie = cookie.split("=");
        var cookieName = cookie[0];
        var cookieValue = cookie[1];
        cookies[cookieName] = cookieValue;
      }
    }
    callback(cookies);
    socket.destroy();
  });
}
function getSchedule(jsessionid, did, xsrf, campus, callback) {
  var options = {
    method: "GET",
    hostname: "campus.d211.org",
    path:
      "/campus/resources/portal/roster?_expand=%7BsectionPlacements-%7Bterm%7D%7D",
    headers: {
      Cookie:
        "JSESSIONID=" +
        jsessionid +
        "; _did-751785010=" +
        did +
        "; XSRF-TOKEN=" +
        xsrf +
        "; tool=; selection=; portalApp=student; portalLang=en; appName=township; campussessioncookie=" +
        campus +
        ";",
      Host: "campus.d211.org",
      "User-Agent":
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/74.0.3729.169 Chrome/74.0.3729.169 Safari/537.36",
      Referer: "https://campus.d211.org/campus/apps/portal/student/schedule",
      "Cache-Control": "no-cache",
      "Postman-Token": "497ad2ae-c325-4653-872b-dffd92bf82a0"
    }
  };

  var req = http.request(options, function(res) {
    var chunks = [];

    res.on("data", function(chunk) {
      chunks.push(chunk);
    });

    res.on("end", function() {
      var body = Buffer.concat(chunks);
      callback(body.toString());
    });
  });

  req.end();
}

function getScheduleFromGrades(jsessionid, did, xsrf, campus, callback) {
  var options = {
    method: "GET",
    hostname: "campus.d211.org",
    path: "/campus/resources/portal/grades",
    headers: {
      Cookie:
        "JSESSIONID=" +
        jsessionid +
        "; _did-751785010=" +
        did +
        "; XSRF-TOKEN=" +
        xsrf +
        "; tool=; selection=; portalApp=student; portalLang=en; appName=township; campussessioncookie=" +
        campus +
        ";",
      Host: "campus.d211.org",
      "User-Agent":
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/74.0.3729.169 Chrome/74.0.3729.169 Safari/537.36",
      Referer: "https://campus.d211.org/campus/apps/portal/student/schedule",
      "Cache-Control": "no-cache",
      "Postman-Token": "497ad2ae-c325-4653-872b-dffd92bf82a0",
      Accept: "application/json, text/plain, */*",
      Expires: "0"
    }
  };

  var req = http.request(options, function(res) {
    var chunks = [];

    res.on("data", function(chunk) {
      chunks.push(chunk);
    });

    res.on("end", function() {
      var body = Buffer.concat(chunks);
      callback(body.toString());
    });
  });

  req.end();
}

function parseSchedule(json) {
  var schedule = {};
  for (i = 0; i < json.length; i++) {
    for (s = 0; s < json[i].sectionPlacements.length; s++) {
      var semester = json[i].sectionPlacements[s].termName;
      var period = json[i].sectionPlacements[s].periodName;
      var className = json[i].courseName;
      var roomName = json[i].sectionPlacements[s].roomName;
      var teacher = formatName(json[i].sectionPlacements[s].teacherDisplay);
      if (!schedule.hasOwnProperty(semester)) {
        schedule[semester] = [];
      }
      schedule[semester].push({
        period: period,
        className: className,
        roomName: roomName,
        teacher: teacher
      });
    }
  }
  return schedule;
}

function formatName(name) {
if(name == undefined){
	return name;
}
  if (name.includes("Hastings")) {
    return "Travis Hastings";
  }
  if (name.includes("Mitchell")) {
    return "Denise Mitchell";
  }
  if (name.includes(",")) {
    var parts = name.split(", ");
    var firstParts = parts[1].split(" ");
    for (n = firstParts.length - 1; n >= 0; n--) {
      if (firstParts[n].length <= 1) {
        firstParts.splice(n, 1);
      }
    }
    if (firstParts.length > 0) {
      return firstParts.join("") + " " + parts[0];
    } else {
      return parts[0];
    }
  } else {
    var parts = name.split(" ");
    if (parts[parts.length - 1].length == 1) {
      parts.splice(parts.length - 1, 1);
    }
    if (parts.length == 2) {
      return parts[1] + " " + parts[0];
    }
    var firstName = parts[parts.length - 1];
    parts.splice(parts.length - 1, 1);
    return firstName + " " + parts.join("");
  }
}

function parseSchedule2(json) {
  var schedule = {};
  var terms = json[0].terms;
  terms.forEach(term => {
    var termName = term.termName;
    term.courses.forEach(course => {
      console.log(course.teacherDisplay);
      var c = {
        period: "AC",
        className: course.courseName,
        roomName: course.roomName,
        teacher: formatName(course.teacherDisplay)
      };
      if (!schedule.hasOwnProperty(termName)) {
        schedule[termName] = [];
      }
      schedule[termName].push(c);
    });
  });
  console.log(schedule);
  return schedule;
}
//000722603
function fetchScheduleData(username, password, callback = function() {}) {
  console.log(username);
  retrieveLoginCookies(username, password, function(cookies) {
    let sessionID = cookies["JSESSIONID"];
    let did = cookies["_did-751785010"];
    let xsrf = cookies["XSRF-TOKEN"];
    let campus = cookies["campussessioncookie"];
    if (
      sessionID == undefined ||
      did == undefined ||
      xsrf == undefined ||
      campus == undefined
    ) {
      callback(null);
      return;
    }
    if (useGradeSchedule) {
      getScheduleFromGrades(sessionID, did, xsrf, campus, function(json) {
        if (json != null) {
          callback(parseSchedule2(JSON.parse(json)));
        } else {
          callback(null);
        }
      });
    } else {
      getSchedule(sessionID, did, xsrf, campus, function(json) {
        if (json != null) {
          callback(parseSchedule(JSON.parse(json)));
        } else {
          callback(null);
        }
      });
    }
  });
}

module.exports = {
  fetchSchedule: fetchScheduleData
};
