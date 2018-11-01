var socket = io();
var app;

function initialize(){
}
function submitReport(){
  var nameVal = document.getElementById('nameField').value;
  var emailVal = document.getElementById('emailField').value;
  var reportVal = document.getElementById('reportField').value;
  var data = {
    name: nameVal,
    email: emailVal,
    report: reportVal
  }
  socket.emit('bug report', data);
}
