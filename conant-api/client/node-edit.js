var socket = io();
var app;

socket.on("node-data", function(data) {
  var ctx = document.getElementById("map").getContext("2d");
  var img = new Image();
  img.onload = drawImage;
  img.src = "floor1.png";
  ctx.drawImage(img, 0, 0, 220, 170);
  var nodes = data;
  for (i = 0; i < nodes.length; i++) {
    ctx.rect(nodes[i].x * 5 + 100, nodes[i].y * 5 - 50, 1, 1);
    ctx.lineWidth = 0.5;
    ctx.stroke();
  }
});

function initialize() {
  socket.emit("node-req", "");
}
