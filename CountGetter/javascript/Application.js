var MenuResponse;
function MenuResponseReturned(text, status, xml){
  var menu;
  document.getElementById('menu').innerHTML = text;
}
var ContentResponse;
function ContentResponseReturned(text, status, xml){
  var menu;
  document.getElementById('content').innerHTML = text;
  UpdateDatePickers();
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
function UpdateDatePickers() {
  $(".datepicker").datepicker();
  console.log("updated date pickers");
}
function Update(){ 
  UpdateContent();
  UpdateMenu();
  UpdateLogin();
}
