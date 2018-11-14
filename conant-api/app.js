var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var fs = require('fs');

app.use(express.static(__dirname + '/client'));

app.get('/bug-report', function(req, res) {
  res.sendFile(__dirname + '/index.html');

});

io.on('connection', function(socket){
  console.log('user connected');

  socket.on('bug report', function(data){
    var date = new Date()
    var timeString = date.toLocaleTimeString();
    timeString = timeString.split(':').join('-');
    var fileName = date.toDateString() + " " + timeString + ".txt"
    fileName = "Hello.txt"
    var writeStream = fs.createWriteStream(__dirname + "/reports/" + fileName);
    writeStream.write(data.name + "\n\n" + data.email + "\n\n" + data.report)
    writeStream.close();
  });

  socket.on('disconnect', function(){
    console.log('user disconnected');
  })
})

http.listen(3000, function(){
  console.log('listening on 3000');
});
