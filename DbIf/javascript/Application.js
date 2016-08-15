function MenuResponseReturned(text, status, xml){
  document.getElementById('menu').innerHTML = text;
}

function ContentResponseReturned(text, status, xml){
  document.getElementById('content').innerHTML = text;
  $(".dropzone").dropzone({url:"/file-upload"});
}

function LoginResponseReturned(text, status, xml){
  document.getElementById('login').innerHTML = text;
}

function UpdateMenu(){
  PosdaGetRemoteMethod("MenuResponse", "" , MenuResponseReturned);
}

function UpdateContent(){
  PosdaGetRemoteMethod("ContentResponse", "" , ContentResponseReturned);
}

function UpdateLogin(){
  PosdaGetRemoteMethod("LoginResponse", "" , LoginResponseReturned);
}

function ModeChanged(text, status, xml){
  if(status != 200) {
    alert("Mode change failed");
  } else {
    console.log("mode changed");
    Update();
  }
}

function ChangeMode(op, mode){
  PosdaGetRemoteMethod(op, 'value='+mode , ModeChanged);
}

function Update(){ 
  UpdateMenu();
  UpdateContent();
  UpdateLogin();
  if(Dropzone.autoDiscover){
    Dropzone.discover();
  }
}

var spinner_opts = {
  lines: 13 // The number of lines to draw
, length: 28 // The length of each line
, width: 14 // The line thickness
, radius: 42 // The radius of the inner circle
, scale: 0.25 // Scales overall size of the spinner
, corners: 1 // Corner roundness (0..1)
, color: '#000' // #rgb or #rrggbb or array of colors
, opacity: 0.25 // Opacity of the lines
, rotate: 0 // The rotation offset
, direction: 1 // 1: clockwise, -1: counterclockwise
, speed: 1 // Rounds per second
, trail: 60 // Afterglow percentage
, fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
, zIndex: 2e9 // The z-index (defaults to 2000000000)
, className: 'spinner' // The CSS class to assign to the spinner
, top: '50%' // Top position relative to parent
, left: '50%' // Left position relative to parent
, shadow: false // Whether to render a shadow
, hwaccel: false // Whether to use hardware acceleration
, position: 'absolute' // Element positioning
};
