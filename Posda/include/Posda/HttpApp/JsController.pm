#!/usr/bin/perl -w
#
use strict;
package Posda::HttpApp::JsController;
use Method::Signatures::Simple;
use Time::HiRes qw( time );
use Dispatch::NamedObject;
use Dispatch::LineReader;
use Posda::HttpApp::HttpObj;

use vars qw( @ISA );
@ISA = ( "Posda::HttpObj" );
my $base_header = qq{<?dyn="html_header"?><!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
  <meta http-equiv="Content-Type" content="text/html; charset=utf8" />
  <head>
    <!-- HttpApp::JsController line 20 -->
    <link rel="stylesheet" href="/css/bootstrap.min.css">
    <link rel="stylesheet" href="/css/nv.d3.css">

    <script src="/js/jquery-1.12.0.js"></script>
    <script src="/js/bootstrap.min.js"></script>
    <script src="/js/d3.v3.min.js"></script>
    <script src="/js/nv.d3.min.js"></script>
    <script src="/js/spin.min.js"></script>
    <script src="/js/jquery.spin.js"></script>

    <?dyn="CssStyle"?>
    <title><?dyn="title"?></title>
};

my $js_controller_hdr = <<EOF;
function rt(n,u,w,h,x) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes," +
    "status=0,left=100,top=100,location=yes";
  remote=window.open(u,n,args);
  if (remote != null) {
    remote.opener = self;
    remote.location.href = u;
//    remote.location.reload(true);
    remote.focus();
  }
  if (x == 1) { return remote; }
}

var ObjPath = "<?dyn="echo" field="path"?>";
var IsExpert = <?dyn="QueueIsExpert"?>;
var CanDebug = <?dyn="QueueCanDebug"?>;
function AjaxObj(url, cb){
  var that=this;
  this.updating = false;
  this.abort = function(){
    if(that.updating) {
      that.updating = false;
      that.AJAX.abort();
      that.AJAX=null;
    }
  }
  this.post = function(data){
    if(that.updating) { alert('reload before update finished'); return }
    that.AJAX = null;
    if (window.XMLHttpRequest) {
      that.AJAX=new XMLHttpRequest();
    } else {
      that.AJAX=new ActiveXObject("Microsoft.XMLHTTP");
    }
    if (that.AJAX==null) {
      alert('unable to create XMLHttpRequest');
      return false;
    } else {
      that.AJAX.onreadystatechange = function() {
        if (that.AJAX.readyState==4) {
          that.updating=false;
          that.callback(that.AJAX.responseText,
            that.AJAX.status,that.AJAX.responseXML);
          that.AJAX=null;
        }
      }
      that.updating = new Date();
      var uri=saveUrl+'&ts='+that.updating.getTime();
      //alert('ajaxObject::update POST called, url: '+uri);
      that.AJAX.open("POST", uri, true);
      that.AJAX.setRequestHeader(
        "Content-type", "text/plain");
        // "Content-type", "application/x-www-form-urlencoded");
      that.AJAX.send(data);
    }
  }
  this.get = function(){
    if(that.updating) { alert('reload before update finished'); return }
    that.AJAX = null;
    if (window.XMLHttpRequest) {
      that.AJAX=new XMLHttpRequest();
    } else {
      that.AJAX=new ActiveXObject("Microsoft.XMLHTTP");
    }
    if (that.AJAX==null) {
      alert('unable to create XMLHttpRequest');
      return false;
    } else {
      that.AJAX.onreadystatechange = function() {
        if (that.AJAX.readyState==4) {
          that.updating=false;
          that.callback(that.AJAX.responseText,
            that.AJAX.status,that.AJAX.responseXML);
          that.AJAX=null;
        }
      }
      that.updating = new Date();
      var uri=saveUrl+'&ts='+that.updating.getTime();
      that.AJAX.open("GET", uri, true);
      that.AJAX.setRequestHeader(
        "Content-type", "text/plain");
        // "Content-type", "application/x-www-form-urlencoded");
      that.AJAX.send(null);
    }
  }
  var saveUrl = url;
  this.callback = cb || function () { };
}
function AJAXPostForm(formId){
  var elem = document.getElementById(formId).elements;
  var params = "";
  url = document.getElementById(formId).action;
  for(var i = 0; i < elem.length; i++){
      if (elem[i].tagName == "SELECT"){
          params += elem[i].name + "=" +     
            encodeURIComponent(elem[i].options[elem[i].selectedIndex].value) 
            + "&";
      }else{
          params += elem[i].name + "=" + 
          encodeURIComponent(elem[i].value) + "&";
      }
  }
  xmlhttp=new XMLHttpRequest();
  xmlhttp.open("POST",url,false);
  xmlhttp.setRequestHeader("Content-type", 
    "application/x-www-form-urlencoded");
  xmlhttp.setRequestHeader("Content-length", params.length);
  xmlhttp.setRequestHeader("Connection", "close");
  xmlhttp.send(params);
  return xmlhttp.responseText;
}
function PosdaPostRemoteMethod(url, content, cb){
  var ajax = new AjaxObj(meth + "?obj_path=" + ObjPath, cb);
  ajax.post(content);
}
function PosdaGetRemoteMethod(meth, args, cb){
  var url = meth + "?obj_path=" + ObjPath;
  if(args != '') url = url + "&" + args;
  var ajax = new AjaxObj(url, cb);
  ajax.get();
}
function CloseThisWindow(){
  var that=this;
  PosdaGetRemoteMethod("JavascriptCloseWindow", '',
    function(responseText){
      window.close();
    }
  );
}
function NewQueueRepeatingServerCmd(method, t){
  //console.log("queue repeating server command");
  var chk_cmd = "NewCheckServer(" + '"' +method+'"' + " ,2500);";
  setTimeout(chk_cmd, t);
}
function NewCheckServer(method, t){
  PosdaGetRemoteMethod(method, '', function(text, status, xml){
    if(status == 200){
      if(text == null) {
        alert('nothing returned');
      } else if (text == '0'){
      } else {
        eval(text);
      }
    } else {
      console.log("status: %d", status);
      alert('Bad Ajax Response');
      window.location.reload();
    }
    NewQueueRepeatingServerCmd(method, t);
  });
}
function DetachAndRedirect(url){
  PosdaGetRemoteMethod('Detach', '', function(text, status, xml){
    if(status == 200){
      window.location = url;
    } else {
      alert('Detach failed');
    }
  });
}
window.onload = function(){
  NewQueueRepeatingServerCmd('ServerCheck', 500);
  Update();
}
EOF
sub InitApp{
  my($class, $sess, $app_name) = @_;
  my $obj = $class->new($sess, $app_name);
  return $obj;
}
sub new{
  my($class, $sess, $app_name) = @_;
  my $this = Dispatch::NamedObject::new($class, $sess, $app_name);
  my $timer = Dispatch::Select::Background->new($this->PollTimer);
  $timer->timer(10);
  $this->{timer_count} = 6; # one minute timeout
  return $this;
}
sub PollTimer{
  my($this) = @_;
  my $sub = sub {
    my($t) = @_;
    unless($this->can("get_obj")){ return }
    unless(defined $this->get_obj($this->{path})){
      #print STDERR "$this->{path} has been removed\n";
      return;
    }
    if($this->{timer_count} <= 4){
      #print STDERR "$this->{path} timer count of $this->{timer_count}\n";
      if($this->{timer_count} <= 0){
        #print STDERR "$this->{path}: timed out\n";
        $this->DeleteSelf;
        return;
      }
    }
    $this->{timer_count} -= 1;
    $t->timer(10);
  };
  return $sub;
}
sub EntryBox{
  my($this, $http, $dyn) = @_;
  my $op = "PosdaGetRemoteMethod('$dyn->{op}', '";
  my $class = "form-control";
  if (defined $dyn->{class}) {
    $class = $dyn->{class};
  }
  $http->queue("<input class='$class' type='text'" .
    ($dyn->{name} ? " name=\"$dyn->{name}\"" : "") .
    ($dyn->{default} ? " value=\"$dyn->{default}\"" : "") .
    # "onblur=\"" . $op . "event=onblur&amp;value='+this.value);\" " .
    "onchange=\"" . $op . "event=onchange&amp;value='+this.value);\" " .
    # "onclick=\"" . $op . "event=onclick&amp;value='+this.value);\" " .
    # "ondblclick=\"" . $op . "event=ondblclick&amp;value='+this.value);\" " .
    # "onfocus=\"" . $op . "event=onfocus&amp;value='+this.value);\" " .
    # "onmousedown=\"" . $op . "event=onmousedown&amp;value='+this.value);\" " .
    # "onmousemove=\"" . $op . "event=onmousemove&amp;value='+this.value);\" " .
    "onmouseout=\"" . $op . "event=onmouseout&amp;value='+this.value);\" " .
    # "onmouseover=\"" . $op . "event=onmouseover&amp;value='+this.value);\" " .
    # "onmouseup=\"" . $op . "event=onmouseup&amp;value='+this.value);\" " .
    # "onkeydown=\"" . $op . "event=onkeydown&amp;value='+this.value);\" " .
    # "onkeypress=\"" . $op . "event=onkeypress&amp;value='+this.value);\" " .
    # "onkeyup=\"" . $op . "event=onkeyup&amp;value='+this.value);\" " .
    "onselect=\"" . $op . "event=onselect&amp;value='+this.value);\" " .
    "/>");
}
sub LinkedDelegateEntryBox{
  my($this, $http, $dyn) = @_;
  my @parms;
  my @attrs;
  for my $i (keys %$dyn){
    if($i eq "op") { next }
    if($i eq "length" || $i eq "name") { 
      push @attrs, "length=\"$dyn->{length}";
      next
    }
    push @parms, "$i=$dyn->{$i}";
  }
  my $attr_s = "";
  for my $a (@attrs){
    $attr_s .= " $a";
  }
  push @parms, "Delegator=$this->{path}";
  if(exists $dyn->{op}){
    push @parms, "Delegated=$dyn->{op}";
  } else {
    push @parms, "Delegated=StoreLinkedValue";
  }
  my $v_string;
  for my $i (0 .. $#parms){
    $v_string .= "$parms[$i]&";
  }
  my $default;
  if(exists $dyn->{index}){
    $default = $this->{$dyn->{linked}}->{$dyn->{index}};
  } else {
    $default = $this->{$dyn->{linked}};
  }
  my $op = "PosdaGetRemoteMethod('Delegate', '$v_string";
  $http->queue('<input type="text"' .
    ($default ? " value=\"$default\"" : "") .
    "onblur=\"" . $op . "event=onblur&amp;value='+this.value);\" " .
    "onchange=\"" . $op . "event=onchange&amp;value='+this.value);\" " .
    "onclick=\"" . $op . "event=onclick&amp;value='+this.value);\" " .
    "ondblclick=\"" . $op . "event=ondblclick&amp;value='+this.value);\" " .
    "onfocus=\"" . $op . "event=onfocus&amp;value='+this.value);\" " .
    "onmousedown=\"" . $op . "event=onmousedown&amp;value='+this.value);\" " .
    "onmousemove=\"" . $op . "event=onmousemove&amp;value='+this.value);\" " .
    "onmouseout=\"" . $op . "event=onmouseout&amp;value='+this.value);\" " .
    "onmouseover=\"" . $op . "event=onmouseover&amp;value='+this.value);\" " .
    "onmouseup=\"" . $op . "event=onmouseup&amp;value='+this.value);\" " .
    "onkeydown=\"" . $op . "event=onkeydown&amp;value='+this.value);\" " .
    "onkeypress=\"" . $op . "event=onkeypress&amp;value='+this.value);\" " .
    "onkeyup=\"" . $op . "event=onkeyup&amp;value='+this.value);\" " .
    "onselect=\"" . $op . "event=onselect&amp;value='+this.value);\" " .
    "/>");
}
sub StoreLinkedValue{
  my($this, $http, $dyn) = @_;
  if(exists $dyn->{index}){
    $this->{$dyn->{linked}}->{$dyn->{index}} = $dyn->{value};
  } else {
    $this->{$dyn->{linked}} = $dyn->{value};
  }
}
sub SelectByValue{
  my($this, $http, $dyn) = @_;
  unless(defined $dyn->{op}) {
    $dyn->{op} = "ChangeMode";
  }

  my $class = defined $dyn->{class}? $dyn->{class}: "form-control";
  my $style = defined $dyn->{style}? $dyn->{style}: "";

  $http->queue(qq{
    <select class="$class" style="$style" 
      onChange="ChangeMode('$dyn->{op}',this.options[this.selectedIndex].value);">
  });
}
sub DrawSelectFromHash {
  # Draw a simple SelectByValue, using a hash of values
  #
  # $op: op to pass to SelectByValue
  # $options_hash: hash of options, in form {value => display_value}
  # $selected_key: the key of the currently selected item
  my($this, $http, $dyn, $op, $options_hash, $selected_key) = @_;

  if (not defined $selected_key) {
    $selected_key = '';
  }

  $dyn->{op} = $op;
  $this->SelectByValue($http, $dyn);

  for my $k (sort keys %$options_hash) {
    my $val = $options_hash->{$k};
    my $selected = "";
    if ($k eq $selected_key) {
      $selected = "selected=\"selected\"";
    }
    $http->queue("<option value=\"$k\" $selected>$val</option>");
  }

  $http->queue("</option></select>");
}
# Builds a <select>
# TODO: But why are there two? The other is SelectByValue
sub SelectDelegateByValue{
  my($this, $http, $dyn) = @_;
  my $op = "Delegate";
  my $delegator = $this->{path};
  my $delegated = $dyn->{op};
  my @parms;
  for my $i (keys %$dyn){
    if($i eq "op") { next }
    if($i eq "caption") { next }
    if($i eq "sync") { next }
    push @parms, "$i=$dyn->{$i}";
  }
  my $v_string = "&Delegator=$delegator&Delegated=$delegated";
  for my $p (@parms){
    $v_string .= "&$p";
  }

  my $class = defined $dyn->{class}? $dyn->{class}: "form-control";
  my $style = defined $dyn->{style}? $dyn->{style}: "";

  $http->queue(
    "<select class=\"$class\" style=\"$style\" onChange=\"PosdaGetRemoteMethod('$op', " . 
    "'value=' + " .
    "this.options[this.selectedIndex].value + '$v_string', " .
    "function(){" .
    (exists($dyn->{sync})? $dyn->{sync}: "") .
    "});\">"
  );
}
sub SelectMethodByValue{
  my($this, $http, $dyn) = @_;
  $http->queue("<select onChange=\"PosdaGetRemoteMethod(" .
    "'$dyn->{method}', " .
    "'value=' + this.options[this.selectedIndex].value " .
    (defined($dyn->{parm}) ? "+ '&$dyn->{parm}'" : "") .
    ", " .
    "function(){$dyn->{sync}}" .
    ");\">");
}
sub BaseHeader{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $base_header);
}
sub html_header{
  my($this, $http, $dyn) = @_;
  $http->HtmlHeader($dyn);
}
sub JsController{
  my($this, $http, $dyn) = @_;
  $dyn->{path} = $this->{path};
  $this->RefreshEngine($http, $dyn, $js_controller_hdr);
}
sub AutoRefresh{
  my($this) = @_;
  $this->QueueJsCmd("Update();");
}
sub StartJsChildProcess{
  my($this, $process_desc, $host, $child_name) = @_;
  unless(defined $child_name) {
    $child_name = "child_" . $this->{child_index};
    $this->{child_index} += 1;
  }
  my $child_path = $this->child_path($child_name);
  my $win_name = $child_path;
  $win_name =~ s/\//_/g;
  AppController::JsChildProcess->new($this->{session}, $child_path,
     $process_desc, $host);
  my $url = "Refresh?obj_path=$child_path";
  my $win_width = $process_desc->{w} + 50;
  my $win_height = $process_desc->{h} + 150;
  my $cmd = 
    "rt('$win_name', '$url', $win_width, $win_height, 0);";
  $this->QueueJsCmd($cmd);
}
sub StartJsChildWindow{
  my($this, $child_obj) = @_;
  my $child_path = $child_obj->{path};
  my $win_name = $child_path;
  $win_name =~ s/\//_/g;
  my $url = "Refresh?obj_path=$child_path";
  my $win_width = $child_obj->{width} + 50;
  my $win_height = $child_obj->{height} + 150;
  my $cmd = 
    "rt('$win_name', '$url', $win_width, $win_height, 0);";
  $this->QueueJsCmd($cmd);
}
sub ServerCheck{
  my($this, $http, $dyn) = @_;
  $this->{timer_count} = 6;
  if(
    exists($http->{header}->{content_length}) &&
    defined($http->{header}->{content_length})
  ){
    my $content_len = $http->{header}->{content_length};
    my $content;
    my $len = read($http->{socket}, $content, $content_len);
  }
   
  if (exists $this->{_JsCmds}) {
    $this->text_header($http, { content_length => length($this->{_JsCmds}) } );
    $http->queue($this->{_JsCmds});
    delete $this->{_JsCmds};
  } else {
    $this->text_header($http, { content_length => 1 } );
    $http->queue("0");
  }
}
sub QueueJsCmd{
  my($this, $cmd) = @_;
  unless (exists $this->{_JsCmds}) { $this->{_JsCmds} = ""; }
  unless ($cmd =~ /;$/) { $cmd .= ";"; }
  if($this->{_JsCmds} eq $cmd) { return }
  $this->{_JsCmds} .= $cmd;
}
sub QueueIsExpert{
  my($this, $http, $dyn) = @_;
  $http->queue($this->IsExpert() ? "true" : "false");
}
sub QueueCanDebug{
  my($this, $http, $dyn) = @_;
  $http->queue($this->CanDebug() ? "true" : "false");
}
sub MakeHostLink{
  my($this, $caption, $method, $args, $small, $class) = @_;
  my $text = "<a class=\"$class\" href=\"javascript:PosdaGetRemoteMethod(" . 
    "'$method'";
  my @a;
  my $at = "";
  if(defined $args && ref($args) eq "HASH"){
    for my $k (keys %$args){
      push(@a, "$k=$args->{$k}");
    }
    $at .= join('&', @a);
  }
  $text .= ", '$at', function() {});" . '" ' .
    ($small ? 'style="font-size:small;"' : '') .
    '>' ."$caption</a>";
  return $text;
}
sub MakeHostLinkSync{
  my($this, $caption, $method, $args, $small, $sync, $class) = @_;
  if (not defined $class) {
    $class = "";
  }
  my $text = "<a class=\"$class\" href=\"javascript:PosdaGetRemoteMethod(" . 
    "'$method'";
  my @a;
  my $at = "";
  if(defined $args && ref($args) eq "HASH"){
    for my $k (keys %$args){
      push(@a, "$k=$args->{$k}");
    }
    $at .= join('&', @a);
  }
  # TODO: Revisit what passing "small" does
  $text .= ", '$at', function() {$sync});" . '" ' .
    ($small ? 'style="font-size:small;"' : '') .
    '>' ."$caption</a>";
  return $text;
}
sub MakeJavascriptLink{
  my($this, $caption, $method, $args) = @_;
  my $text = '<span onClick="javascript:' . "$method(";
  if(defined $args && ref($args) eq "ARRAY"){
    for my $i ($#$args){
      $text .= "'$args->[$i]'";
      unless($i == $#$args){ $text .= ", " }
    }
  }
  $text .= ');">' ."$caption</span>";
  return $text;
}

method ReallySimpleButton($http, $dyn) {
  $http->queue(qq{
    <button class="btn btn-default"
            onClick="$dyn->{onClick}">
      $dyn->{caption}
    </button>
  });
}

sub SimpleButton{
  my($this, $http, $dyn) = @_;
  my $string = '<input class="btn btn-default" type="button" ' .
    'onClick="javascript:PosdaGetRemoteMethod(' .
    "'$dyn->{op}', " . 
    (exists($dyn->{parm})? "'parm=$dyn->{parm}'" : "''") .
    ', function () {' .
    (exists($dyn->{sync}) ? $dyn->{sync} : "") .
    '});" value="' .  $dyn->{caption} . '">';
  $http->queue($string);
}
sub NotSoSimpleButton{
  my($this, $http, $dyn)  = @_;
  my @parms;
  for my $i (keys %$dyn){
    if($i eq "op") { next }
    if($i eq "caption") { next }
    if($i eq "sync") { next }
    push @parms, "$i=$dyn->{$i}";
  }
  my $hstring = "";
  for my $i (0 .. $#parms){
    $hstring .= "$parms[$i]";
    unless($i == $#parms) { $hstring .= "&" }
  }
  my $class = "btn btn-default";
  if (defined $dyn->{class}) {
    $class = $dyn->{class};
  }
  my $string = qq{<input class="$class" type="button" } .
    'onClick="javascript:PosdaGetRemoteMethod(' .
    "'$dyn->{op}', '$hstring', " .
    'function () {' .
    (exists($dyn->{sync}) ? $dyn->{sync} : "") .
    '});" value="' .  $dyn->{caption} . '">';
  $http->queue($string);
}
sub DelegateButton{
  my($this, $http, $dyn)  = @_;
  my @parms;
  for my $i (keys %$dyn){
    if($i eq "op") { next }
    if($i eq "caption") { next }
    if($i eq "sync") { next }
    push @parms, "$i=$dyn->{$i}";
  }
  push(@parms, "Delegator=$this->{path}");
  push(@parms, "Delegated=$dyn->{op}");
  my $hstring = "";
  for my $i (0 .. $#parms){
    $hstring .= "$parms[$i]";
    unless($i == $#parms) { $hstring .= "&" }
  }
  my $string = '<input type="button" class="btn btn-default" ' .
    'onClick="javascript:PosdaGetRemoteMethod(' .
    "'Delegate', '$hstring', " .
    'function () {' .
    (exists($dyn->{sync}) ? $dyn->{sync} : "") .
    '});" value="' .  $dyn->{caption} . '">';
  $http->queue($string);
}
sub MakeMenu{
  my($this, $http, $dyn, $list) = @_;
  $http->queue('<div class="list-group">');
  for my $m (@$list){
    if($m->{condition}){
      if($m->{type} eq "host_link"){
        my $small;
        if(exists($m->{style}) && $m->{style} eq "small"){
          $small = 1;
        }
        my $link = 
          $this->MakeHostLink($m->{caption}, $m->{method}, $m->{args}, $small,
          "list-group-item");
        # $http->queue("<a href='' class=\"list-group-item\">$link</a>");
        $http->queue($link);
      } elsif($m->{type} eq "host_link_sync"){
        my $small;
        if(exists($m->{style}) && $m->{style} eq "small"){
          $small = 1;
        }
        # Default sync method of Update()
        my $sync_method = defined $m->{sync}? $m->{sync}: "Update();";
        my $link = 
          $this->MakeHostLinkSync($m->{caption}, $m->{method}, 
            $m->{args}, $small, $sync_method, "list-group-item");
        $http->queue($link);
      } elsif ($m->{type} eq "javascript"){
        my $link = $this->MakeJavascriptLink(
          $m->{caption}, $m->{method}, $m->{args});
        $http->queue("$link<br />");
      } elsif ($m->{type} eq "hr"){
        $http->queue("<hr />");
      } elsif ($m->{type} eq "info"){
        $http->queue("$m->{caption}<br />");
      }
    }
  }
  $http->queue('</div>');
}
sub CheckBox{
  my($this, $group, $value, $op, $checked, $parm) = @_;
  my $input = '<input type="checkbox" group="' . $group .
    '" value="' . $value . '"' .
    (defined($parm) ? "&parm" : "") .
    ($checked ? ' checked="checked"' : '') .
    ' onClick="javascript:PosdaGetRemoteMethod(' .
    "'$op', " . "'group=$group&value=$value&$parm&checked='+this.checked" .
    ', function () {});">';
  return $input;
}
sub CheckBoxSync{
  my($this, $group, $value, $op, $checked, $parm, $sync) = @_;
  my $input = '<input type="checkbox" group="' . $group .
    '" value="' . $value . '"' .
    (defined($parm) ? "&parm" : "") .
    ($checked ? ' checked="checked"' : '') .
    ' onClick="javascript:PosdaGetRemoteMethod(' .
    "'$op', " . "'group=$group&value=$value&$parm&checked='+this.checked" .
    ', function () {' . $sync . '});">';
  return $input;
}
sub CheckBoxDelegate{
  my($this, $group, $value, $checked, $parms) = @_;
  my $op = "Delegate";
  $parms->{Delegator} = $this->{path};
  $parms->{Delegated} = $parms->{op};
  my $sync = $parms->{sync};
  my $v_string = "group=$group&value=$value";
  for my $i (keys %$parms){
    unless($i eq "checked" || $i eq "sync") {
      $v_string .= "&$i=$parms->{$i}";
    }
  }
  my $input = '<input type="checkbox" group="' . $group .
    '" value="' . $value . '"' .
    ($checked ? ' checked="checked"' : '') .
    ' onClick="javascript:PosdaGetRemoteMethod(' .
    "'$op', " . "'group=$group&$v_string&checked='+this.checked" .
    ', function () {' . $sync . '});">';
  return $input;
}
sub RadioButtonDelegate{
  my($this, $group, $value, $checked, $parms, $class) = @_;
  if (not defined $class) {
    $class = '';
  }
  my $op = "Delegate";
  $parms->{Delegator} = $this->{path};
  $parms->{Delegated} = $parms->{op};
  my $sync = $parms->{sync};
  my $v_string = "group=$group&value=$value";
  for my $i (keys %$parms){
    unless($i eq "checked" || $i eq "sync") {
      $v_string .= "&$i=$parms->{$i}";
    }
  }
  my $input = qq{<input class="$class" type="radio" group="$group"} .
    ' value="' . $value . '"' .
    ($checked ? ' checked="checked"' : '') .
    ' onClick="javascript:PosdaGetRemoteMethod(' .
    "'$op', " . "'$v_string&checked='+this.checked" .
    ', function () {' . $sync . '});">';
  return $input;
}
sub RadioButtonSync{
  my($this, $group, $value, $op, $checked, $parm, $sync) = @_;
  my $parms = "";
  if(defined($parm)) {$parms = "&$parm" }
  my $input = '<input type="radio" group="' . $group .
    '" value="' . $value . '"' .
    ($checked ? ' checked="checked"' : '') .
    ' onClick="javascript:PosdaGetRemoteMethod(' .
    "'$op', " . "'group=$group&value=$value$parm&checked='+this.checked" .
    ', function () {' . $sync . '});">';
  return $input;
}
sub SendHtmlFile{
  my($this, $http, $file) = @_;
  $http->HeaderSent;
  $http->queue("HTTP/1.0 200 OK\n");
  $http->queue("Content-type: text/html\n\n");
  my $lr = Dispatch::LineReader->new_cmd(
    "cat \"$file\"",
    $this->SendHtmlLine($http),
    $this->FinishHtml($http)
  );
}
sub SendHtmlCmd{
  my($this, $http, $cmd) = @_;
  $http->HeaderSent;
  $http->queue("HTTP/1.0 200 OK\n");
  $http->queue("Content-type: text/html\n\n");
  $http->queue("<html><head></head><body>");
  my $lr = Dispatch::LineReader->new_cmd(
    $cmd,
    $this->SendHtmlLine($http),
    $this->FinishHtml($http)
  );
}
sub SendHtmlLine{
  my($this, $http) = @_;
  my $sub = sub {
    my($line) = @_;
    $http->queue($line);
  };
  return $sub;
}
sub FinishHtml{
  my($this, $http) = @_;
  my $sub = sub {
    $http->queue("</body></html>");
    $http->finish;
  };
  return $sub;
}
sub NextSeq{
  my($this) = @_;
  unless(defined $this->{sequence}) { $this->{sequence} = 0 }
  return $this->{sequence}++;
}
sub Delegate{
  my($this, $http, $dyn) = @_;
  my $delegator = $this->get_obj($dyn->{Delegator});
  unless($delegator) {
    print STDERR "Delegator $dyn->{Delegator} not found\n";
    return;
  }
  my $method = $dyn->{Delegated};
  unless($delegator->can($method)){
    print STDERR "Delegator $dyn->{Delegator} can't $method\n";
    for my $i (keys %$dyn){
      print STDERR "\tdyn{$i} = $dyn->{$i}\n";
    }
    return;
  }
  $delegator->$method($http, $dyn);
}

sub SimpleTransaction{
  my($this, $port, $lines, $response) = @_;

  my $sock;
  unless(
    $sock = IO::Socket::INET->new(
     PeerAddr => "localhost",
     PeerPort => $port,
     Proto => 'tcp',
     Timeout => 1,
     Blocking => 0,
    )
  ){
    print "-> Aborting, socket could not be opened!\n";
    return 0;
  }
  my $text = join("\n", @$lines) . "\n\n";
  Dispatch::Select::Socket->new($this->WriteTransactionParms($text, $response),
    $sock)->Add("writer");
}
sub WriteTransactionParms{
  my($this, $text, $response) = @_;
  my $offset = 0;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $length = length($text);
    if($offset == length($text)){
      $disp->Remove;
      Dispatch::Select::Socket->new($this->ReadTransactionResponse($response),
        $sock)->Add("reader");
    } else {
      my $len = syswrite($sock, $text, length($text) - $offset, $offset);
      if($len <= 0) {
        print STDERR "Wrote $len bytes ($!)\n";
        $offset = length($text);
      } else { $offset += $len }
    }
  };
  return $sub;
}
sub ReadTransactionResponse{
  my($this, $response) = @_;
  my $text = "";
  my @lines;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $len = sysread($sock, $text, 65536, length($text));
    if($len <= 0){
      if($text) { push @lines, $text }
      $disp->Remove;
      &$response(\@lines);
    } else {
      while($text =~/^([^\n]*)\n(.*)$/s){
        my $line = $1;
        $text = $2;
        push(@lines, $line);
      }
    }
  };
  return $sub;
}

method MakeMenuBar($http, $menu) {
  # Generate a jquery-based button bar from the given menu hash
  #
  # $menu should look like this:
  # class is optional
  #
  # my $menu = [
  #   {caption => 'Extractions',
  #    class => 'btn btn-primary',
  #    items => [
  #       {caption => 'Delete Incomplete', op => 'DiscardIncompleteExtractions'},
  #       {caption => 'Extract all Unextracted', op => 'ExtractAllUnextracted'},
  #     ]
  #   },
  #   {caption => 'PHI',
  #    items => [
  #       {caption => 'Scan all for PHI', op => 'ScanAllForPhi'},
  #       {caption => 'Remove all PHI scans', op => 'RemoveAllPhiScans'},
  #     ]
  #   },
  #   {caption => 'Inconsistencies',
  #    items => [
  #       {caption => 'Fix Study Inconsistencies', op => 'FixStudyInconsistencies'},
  #       {caption => 'Fix Series Inconsistencies', op => 'FixSeriesInconsistencies'},
  #       {caption => 'Fix Patient Inconsistencies', op => 'FixPatientInconsistencies'},
  #     ]
  #   }
  # ];
  #
  $http->queue('<div class="btn-group">');
  for my $top (@$menu) {
    my $class = "btn btn-default";

    if (defined $top->{class}) {
      $class = $top->{class};
    }

    $http->queue(qq{
      <div class="btn-group">
        <button type="button" 
                class="$class dropdown-toggle"
                data-toggle="dropdown"
                aria-haspopup="true"
                aria-expanded="false">
          $top->{caption} <span class="caret"></span>
        </button>
        <ul class="dropdown-menu">

    });
    for my $entry (@{$top->{items}}) {

      my $op = qq{javascript:PosdaGetRemoteMethod('$entry->{op}', '', function() {Update();});};

      $http->queue(qq{
        <li><a href="$op">
          $entry->{caption}
        </a></li>
      });
    }
    $http->queue(qq{
        </ul>
      </div>
    });
  }
  $http->queue('</div>');
}

1;
