/*
 * $Source: /home/bbennett/pass/archive/TciaCuration/javascript/CheckSeries.js,v $
 * $Date: 2015/06/05 19:41:33 $
 * $Revision: 1.2 $
 */
var ContentResponse;
function ContentResponseReturned(text, status, xml){
  var menu;
  document.getElementById('content').innerHTML = text;
}
var LoginResponse;
function LoginResponseReturned(text, status, xml){
  var menu;
  document.getElementById('login').innerHTML = text;
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
    Update();
  }
}
function ChangeMode(op, mode){
  PosdaGetRemoteMethod(op, 'mode='+mode , ModeChanged);
}
function Update(){ 
  UpdateContent();
  UpdateLogin();
}
