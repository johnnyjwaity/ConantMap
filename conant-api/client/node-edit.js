var socket = io();
var app;

socket.on("node-data", function(data) {
  var ctx = document.getElementById("map").getContext("2d");
  var img = new Image();
  // img.onload = drawImage;
  img.src = "floor1.png";
  ctx.drawImage(img, 0, 0, 1000, 800);
  var nodes = data;
  for (i = 0; i < nodes.length; i++) {
    if(nodes[i].floor == 2){
      continue;
    }
    ctx.rect(nodes[i].x * 45 + 50, nodes[i].y * 45 - 400, 3, 3);
    ctx.lineWidth = 0.5;
    ctx.fill();
  }
});
 
function initialize() {
  socket.emit("node-req", "");
}
