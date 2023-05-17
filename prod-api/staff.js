const http = require("https");
const fs = require("fs");

function getSchedule(teacher, auth, callback) {
  var e = teacher.email.replace("@", "%40");

  var options = {
    method: "GET",
    hostname: "awsapieast1-prod3.schoolwires.com",
    path: "/REST/api/v4/FlexData/GetFlexDataFiltered/13124?EmployeeEmail=" + e,
    headers: {
      Accept: "application/json",
      "User-Agent":
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/74.0.3729.169 Chrome/74.0.3729.169 Safari/537.36",
      Referer: "https://adc.d211.org/Page/323",
      Origin: "https://adc.d211.org",
      Authorization: "Bearer " + auth
    }
  };

  var req = http.request(options, function (res) {
    var chunks = [];

    res.on("data", function (chunk) {
      chunks.push(chunk);
    });

    res.on("end", function () {
      var body = Buffer.concat(chunks);
      var info = JSON.parse(body.toString());
      var classes = [];
      for (i = 0; i < info.length; i++) {
        var c = {
          name: info[i].cd_CourseName.replace("/H", ""),
          period: info[i].cd_Period,
          location: info[i].cd_Room
        };
        classes.push(c);
      }
      classes.sort(function (a, b) {
        return a.period - b.period;
      });
      teacher.classes = classes;
      callback(teacher);
    });
  });

  req.end();
}

function getTeachers(auth, callback) {
  var options = {
    method: "GET",
    hostname: "awsapieast1-prod3.schoolwires.com",
    path: "/REST/api/v4/FlexData/GetFlexDataFiltered/10644",
    headers: {
      Accept: "application/json",
      "User-Agent":
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/74.0.3729.169 Chrome/74.0.3729.169 Safari/537.36",
      Referer: "https://adc.d211.org/Page/323",
      Origin: "https://adc.d211.org",
      Authorization: "Bearer " + auth
    }
  };

  var req = http.request(options, function (res) {
    var chunks = [];

    res.on("data", function (chunk) {
      chunks.push(chunk);
    });

    res.on("end", function () {
      var body = Buffer.concat(chunks);
      console.log(body.toString())
      var info = JSON.parse(body.toString());
      var teachers = [];
      for (i = 0; i < info.length; i++) {
        let teacher = {
          name:
            info[i].cd_EmployeeFirstName + " " + info[i].cd_EmployeeLastName,
          email: info[i].cd_EmployeeEmail,
          phone: info[i].cd_EmployeePhone,
          department: info[i].cd_EmployeeDepartment
        };
        teachers.push(teacher);
      }
      callback(teachers);
    });
  });

  req.end();
}
const authToken =
  "eyJhbGciOiJBMjU2S1ciLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIn0.DbsQGbgLg32ZUfZoQa-OIVxmgK_wKWR9-XkRCnGDXULHe-lBcTOk3mqzQDc16IJ-nQSqTQZnBI4Fk00RMougXFfYI4bpG6pw.KP_Yb5hAGNXjrfO4S8mRXQ.wG3RLIRN1uHzZMqYsKfU040VsYMfzfsj1lCDNJrGZAbRLHfGsNFb9zbhPrlgDB9zEUSlcWkcWUs5154imX_acYKGRkIfL0lCJAAX5kgFkkOITAGVLC129LEaLN9kMUD-ImN9K0PCONodJ0n_qu4nFif5h0a0OtEBFba1JZgtuK8XfmAcMceOiPEdlRVsheJUOet305Q4O-PpRHVNdTJp0-XNdnMNxKgwDpkwKeTtA0cWfyNdGDFRgXguc_m_duN9WilXwK-Vm7L928mK-0-hdg.ycMsks3Z3BRrAYFAXN8W2lqwju2OKocu5GSWjs2afnI";
function getStaffSchedules() {
  getTeachers(authToken, function (teachers) {
    var allTeachers = [];
    var reqAmount = teachers.length;
    for (i = 0; i < teachers.length; i++) {
      getSchedule(teachers[i], authToken, function (t) {
        allTeachers.push(t);
        reqAmount -= 1;
        if (reqAmount == 0) {
          allTeachers.sort(function (a, b) {
            var x = a.name.toLowerCase();
            var y = b.name.toLowerCase();
            if (x < y) {
              return -1;
            }
            if (x > y) {
              return 1;
            }
            return 0;
          });
          var classID = 0;
          for (k = 0; k < allTeachers.length; k++) {
            for (c = 0; c < allTeachers[k].classes.length; c++) {
              allTeachers[k].classes[c].id = "" + classID;
              classID += 1;
            }
          }
          var jsonString = JSON.stringify(allTeachers);
          fs.writeFile("staff.json", jsonString, err => {
            if (err) throw err;
            console.log("Done");
          });
        }
      });
    }
  });
}
getStaffSchedules();
