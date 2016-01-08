/*
 * $Source: /home/bbennett/pass/archive/Posda/javascript/AppController.js,v $
 * $Date: 2014/06/10 20:36:33 $
 * $Revision: 1.4 $
 */
function MenuResponseReturned(text, status, xml){
  document.getElementById('menu').innerHTML = text;
}
function ContentResponseReturned(text, status, xml){
  document.getElementById('content').innerHTML = text;
}
function LoginResponseReturned(text, status, xml){
  document.getElementById('login').innerHTML = text;
}
function TitleAndInfoResponseReturned(text, status, xml){
  document.getElementById('title_and_info').innerHTML = text;
}
function UpdateTitleAndInfo(){
  PosdaGetRemoteMethod("TitleAndInfoResponse", "" , 
    TitleAndInfoResponseReturned);
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
function Update(){ 
  UpdateTitleAndInfo();
  UpdateMenu();
  UpdateContent();
  UpdateLogin();
}
