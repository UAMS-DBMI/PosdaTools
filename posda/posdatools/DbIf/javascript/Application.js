function HeaderResponseReturned(text, status, xml){
  document.getElementById('header').innerHTML = text;
}

function MenuResponseReturned(text, status, xml){
  document.getElementById('menu').innerHTML = text;
}

function ContentResponseReturned(text, status, xml){
  document.getElementById('content').innerHTML = text;

  Dropzone.discover();

  // Apply highlight.js style to any code blocks
  $('pre code').each(function(i, block) {
    hljs.highlightBlock(block);
  });

  $('div.spinner').spin(spinner_opts);
}

function LoginResponseReturned(text, status, xml){
  document.getElementById('login').innerHTML = text;
}

function ActivityTaskStatusReturned(text, status, xml){
  document.getElementById('activitytaskstatus').innerHTML = text;
}

//function UpdateHeader(){
//  PosdaGetRemoteMethod("HeaderResponse", "" , HeaderResponseReturned);
//}

function UpdateHeader(){
  UpdateDiv("header", "HeaderResponse");
}

//function UpdateMenu(){
//  PosdaGetRemoteMethod("MenuResponse", "" , MenuResponseReturned);
//}

function UpdateMenu(){
  UpdateDiv("menu", "MenuResponse");
}

//function UpdateContent(){
//  PosdaGetRemoteMethod("ContentResponse", "" , ContentResponseReturned);
//}

function UpdateContent(){
  UpdateDiv("content", "ContentResponse");
}

//function UpdateLogin(){
//  PosdaGetRemoteMethod("LoginResponse", "" , LoginResponseReturned);
//}

function UpdateLogin(){
  UpdateDiv("login", "LoginResponse");
}

//function UpdateActivityTaskStatus(){
//  PosdaGetRemoteMethod("DrawActivityTaskStatus", "" , ActivityTaskStatusReturned);
//}

function UpdateActivityTaskStatus(){
  UpdateDiv("activitytaskstatus","DrawActivityTaskStatus");
}
function UpdateDiv(div_text, method_text){
  if(in_update_divs){
    console.log("UpdateDivs collision[0]");
    return;
  }
  //console.log('{0}PosdaGetRemoteMethod(' + method_text + ', ' + div_text + ')');
  PosdaGetRemoteMethod(method_text, "", makeDivUpdater(div_text));
}
function makeDivUpdater(div_text){
  var that = this;
  that.div_text = div_text;
  return function(text, status, xml){
    var foo = document.getElementById(that.div_text);
    if(foo != null) {
      document.getElementById(that.div_text).innerHTML = text;
      if(that.div_text == "content"){
        Dropzone.discover();
      }
       //console.log("UpdatedDiv: " + div_text);
    } else {
       console.log("Attempt to update unknown div(1): " + div_text);
    }
  }
}
var in_update_divs = 0;
function UpdateDivs(div_list){
  if(in_update_divs){
    console.log("UpdateDivs collision[1]");
    return;
  }
  in_update_divs = 1;
  //console.log("Setting in_update_divs");
  UpdateDivs1(div_list);
}
function UpdateDivs1(div_list){
  if(div_list == null) {
    in_update_divs = 0;
    return;
  }
  if(div_list.length == 0) { in_update_divs = 0 ; return }
  var next = div_list.pop();
  //console.log('{1}PosdaGetRemoteMethod(' + next[1] + ', ' + next[0] + ')');
  PosdaGetRemoteMethod(next[1], "", makeDivListIterator(next[0], div_list));
}
function makeDivListIterator(div_text, div_list){
  var that = this;
  that.div_text = div_text;
  return function(text, status, xml){
    var foo = document.getElementById(that.div_text);
    if(foo != null) {
      foo.innerHTML = text;
      if(that.div_text == "content"){
        Dropzone.discover();
      }
      $('pre code').each(function(i, block) {
       hljs.highlightBlock(block);
      });
      $('div.spinner').spin(spinner_opts);
      //console.log("UpdatedDiv: " + div_text);
    } else {
      console.log("Attempt to update unknown div(2): " + div_text);
    }
      UpdateDivs1(div_list);
    }
  }

function ModeChanged(text, status, xml){
  if(status != 200) {
    alert("Mode change failed");
  } else {
    //console.log("mode changed");
    Update();
  }
}

function ChangeMode(op, mode){
  //console.log('{2}PosdaGetRemoteMethod(' + op + ', ModeChanged)');
  PosdaGetRemoteMethod(op, 'value='+mode , ModeChanged);
}

function Update(){ 
  UpdateDivs([
    ["menu", "MenuResponse"],
    ["content", "ContentResponse"],
    ["login", "LoginResponse"]
  ]);
}
function UpdateOne(){ 
  UpdateDivs([
    ["header", "HeaderResponse"],
    ["menu", "MenuResponse"],
    ["content", "ContentResponse"],
    ["login", "LoginResponse"]
  ]);
}

function UpdateAct(){ 
  UpdateActivityTaskStatus();
}

//function Update(){ 
//  UpdateMenu();
//  UpdateContent();
//  UpdateLogin();
//}
//function UpdateOne(){ 
//  UpdateHeader();
//  UpdateMenu();
//  UpdateContent();
//  UpdateLogin();
//}
//function UpdateAct(){ 
//  UpdateActivityTaskStatus();
//}
function Reload(){
  window.location.reload();
}

var spinner_opts = {
  lines: 13 // The number of lines to draw
, length: 28 // The length of each line
, width: 14 // The line thickness
, radius: 42 // The radius of the inner circle
, scale: 0.15 // Scales overall size of the spinner
, corners: 1 // Corner roundness (0..1)
, color: '#000' // #rgb or #rrggbb or array of colors
, opacity: 0.25 // Opacity of the lines
, rotate: 0 // The rotation offset
, direction: 1 // 1: clockwise, -1: counterclockwise
, speed: 1 // Rounds per second
, trail: 60 // Afterglow percentage
, fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
, zIndex: 2e9 // The z-index (defaults to 2000000000)
, className: 'spinnerobj' // The CSS class to assign to the spinner
, top: '' // Top position relative to parent
, left: '' // Left position relative to parent
, shadow: false // Whether to render a shadow
, hwaccel: false // Whether to use hardware acceleration
, position: 'relative' // Element positioning
};

$(function() {
  $('[data-toggle="popover"]').popover();
});
