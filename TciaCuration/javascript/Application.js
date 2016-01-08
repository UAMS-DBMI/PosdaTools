/*
 * $Source: /home/bbennett/pass/archive/TciaCuration/javascript/Application.js,v $
 * $Date: 2015/02/23 22:33:16 $
 * $Revision: 1.3 $
 */
var MenuResponse;
function MenuResponseReturned(text, status, xml){
  var menu;
  document.getElementById('menu').innerHTML = text;
}
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
}
