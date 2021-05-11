#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer;
use Posda::HttpApp::JsController;
##################################################
#Data Fetched via Ajax (AjaxPosdaGet):
#  ImageLabels
#  ImageUrl
##################################################
#Methods Invoked via Ajax:
#  GetContoursToRender
##################################################
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::JsController" );
sub new {
  my($class, $sess, $path, $parms) = @_;
  my $self = Posda::HttpApp::JsController->new($sess, $path);
  bless $self, $class;
  $self->Init($parms);
  return $self;
}
my $js_content_line = "line __LINE__ of __FILE__";
my $js_content = <<EOF;

<!-- $js_content_line -->

function HeaderResponseReturned(text, status, xml){
  document.getElementById('header').innerHTML = text;
}

function MenuResponseReturned(text, status, xml){
  var obj = document.getElementById('menu');
  if(obj != null) { obj.innerHTML = text }
  // document.getElementById('menu').innerHTML = text;
}

function ContentResponseReturned(text, status, xml){
  document.getElementById('content').innerHTML = text;

  Dropzone.discover();

  // Apply highlight.js style to any code blocks
  \$('pre code').each(function(i, block) {
    hljs.highlightBlock(block);
  });

  \$('div.spinner').spin(spinner_opts);
}

function LoginResponseReturned(text, status, xml){
  document.getElementById('login').innerHTML = text;
}

function ActivityTaskStatusReturned(text, status, xml){
  document.getElementById('activitytaskstatus').innerHTML = text;
}

function UpdateHeader(){
  PosdaGetRemoteMethod("HeaderResponse", "" , HeaderResponseReturned);
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

function UpdateActivityTaskStatus(){
  PosdaGetRemoteMethod("DrawActivityTaskStatus", "" , ActivityTaskStatusReturned);
}

function UpdateDiv(div_text, method_text){
  PosdaGetRemoteMethod(method_text, "", makeDivUpdater(div_text));
}

function makeDivUpdater(div_text){
  var that = this;
  that.div_text = div_text;
  return function(text, status, xml){
    var foo = document.getElementById(that.div_text);
    if(foo != null) {
      foo.innerHTML = text;
    } else {
      // console.log("Attempt to update unknown div: " + div_text);
    }
  }
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
  // UpdateMenu();
  //  UpdateContent();
  // UpdateLogin();
}
function UpdateOne(){ 
  // UpdateHeader();
  // UpdateMenu();
  // UpdateContent();
  // UpdateLogin();
}
function UpdateAct(){ 
  // UpdateActivityTaskStatus();
}
function ResetZoom(){
  var xform = ctx.setTransform(1,0,0,1,0,0);
  LineWidth = 1;
  RenderImage(canvas,ctx);
}
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

\$(function() {
  \$('[data-toggle="popover"]').popover();
});
EOF

sub JsContent{
  my($self, $http, $dyn) = @_;
  return $self->RefreshEngine($http, $dyn, $js_content);
}

my $dicom_image_disp_js_line = "line __LINE__ of __FILE__";
my $dicom_image_disp_js = <<EOF;
  <!-- $dicom_image_disp_js_line -->

  var ImageToDraw = new Image;
  var ImageUrl;
  var ImageLabels;
  var ImageUrlPending = false;
  var ImageLabelsPending = false;
  var ContoursPending = false;
  var BaseSessionUrl;
  var LineWidth = 1;
  var ToolType = "None";
  var TrackingEnabled = "Off";
  var SelectionEnabled = "Off";
  var CineEnabled = "No";
  var CineDir = "+";
//  var ContoursToDraw = [];
  var ContourResp;
  var ContoursToDraw = [
  ];
  var AnnotationsToDraw = [
  ];
  var RectsToDraw = [
  ];
  var RectBeingConstructed = null;
  var theSvg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
  function SendAnnotations(){
//    var data = JSON.stringify(AnnotationsToDraw)
//    var ajax = new AjaxObj('UploadJsonObject' + "?obj_path=" + ObjPath +
//      '&DataName=Annotations', function () { RenderImage(canvas,ctx); });;
//    ajax.post(data);
    var data = JSON.stringify(RectsToDraw)
    var ajax = new AjaxObj('UploadJsonObject' + "?obj_path=" + ObjPath +
      '&DataName=Annotations', function () { RenderImage(canvas,ctx); });;
    ajax.post(data);
  }
  function PopAnnotations(){
    var anot = RectsToDraw.pop();
    SendAnnotations();
//    RenderImage(canvas,ctx);
  }
  function RenderImage (canvas, ctx) {
      // Clear the entire canvas
      var p1 = ctx.transformedPoint(0,0);
      var p2 = ctx.transformedPoint(canvas.width,canvas.height);
      var td = document.getElementById('divTransform');
      var tf = ctx.getTransform();
      if(td != null){
        td.innerHTML = 'a: ' + tf.a + ' b: ' + tf.b + ' c: ' 
          + tf.c + '<br>d: ' + tf.d + ' e: ' + tf.e + ' f: ' + tf.f;
      }
      ctx.clearRect(p1.x,p1.y,p2.x-p1.x,p2.y-p1.y);

      // Alternatively:
      // ctx.save();
      // ctx.setTransform(1,0,0,1,0,0);
      // ctx.clearRect(0,0,canvas.width,canvas.height);
      // ctx.restore();

      ctx.drawImage(ImageToDraw,0,0);
      var i;
      for(i = 0; i < ContoursToDraw.length; i++){
         var contour = ContoursToDraw[i];
         ctx.beginPath();
         ctx.moveTo(contour.points[0][0], contour.points[0][1]);
         for(j = 0; j < contour.points.length - 1; j++){
           ctx.lineTo(contour.points[j+1][0],contour.points[j+1][1]);
         }
         ctx.closePath();
         ctx.lineWidth = LineWidth;
         ctx.strokeStyle = contour.color;
         ctx.stroke();
      }
      if(RectBeingConstructed != null){
         ctx.beginPath();
         ctx.rect(RectBeingConstructed.x, RectBeingConstructed.y,
           RectBeingConstructed.width, RectBeingConstructed.height);
         ctx.setLineDash([5,15]);
         ctx.lineWidth = LineWidth;
         ctx.strokeStyle = '#20ff20';
         ctx.stroke();
         ctx.setLineDash([]);
      }
      for(i = 0; i < RectsToDraw.length; i++){
         var rect = RectsToDraw[i];
         ctx.beginPath();
         ctx.rect(rect.x, rect.y, rect.width, rect.height);
         ctx.strokeStyle = "blue";
         ctx.lineWidth = LineWidth;
         ctx.stroke();
      }
      var td = document.getElementById('div_annotation_ctrl');
      if(td != null){
        if(RectsToDraw.length > 0){
          // Create a count and delete button in div_annotation_ctrl
          td.innerHTML = '<input type="Button" class="btn btn-default" ' +
            'onclick="javascript:PopAnnotations();" value="pop annotation">';
        } else {
          td.innerHTML = '';
        }
      }
      ctx.save();
  };
  function SetCineMode(cine_mode){
    var oldCine = CineEnabled;
    if(cine_mode == "Cine -"){
      CineEnabled = "On";
      CineDir = "-";
    } else if (cine_mode == "Cine +"){
      CineEnabled = "On";
      CineDir = "+";
    } else {
      CineEnabled = "Off";
    }
    if(oldCine = 'Off'){
      UpdateImage();
    }
  }
  function SetToolType(sel_type){
    if(ToolType == sel_type) { return; }
    if(ToolType == "Pan/Zoom"){
      DisableTracking();
    } else if (ToolType == "Select"){
      DisableSelection();
    }
    ToolType = sel_type;
    if(ToolType == "Pan/Zoom"){
      EnableTracking();
    } else if (ToolType == "Select"){
      EnableSelection();
    }
  }
  function InstallSelectionTrackers(canvas, ctx){
    var lastX=canvas.width/2, lastY=canvas.height/2;
    var dragStart,dragged;
    var theRect = document.createElementNS(theSvg, 'rect');
    SelectionMouseDown = function(evt){
    document.body.style.mozUserSelect = 
        document.body.style.webkitUserSelect = 
          document.body.style.userSelect = 'none';
      lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft);
      lastY = evt.offsetY || (evt.pageY - canvas.offsetTop);
      dragStart = ctx.transformedPoint(lastX,lastY);
      theRect.x = dragStart.x;
      theRect.y = dragStart.y;
      var td = document.getElementById('MousePosition');
      if(td != null){
        td.innerHTML = 'Rect(x,y): (' + dragStart.x +
          ', ' + dragStart.y + ')';
      }
      dragged = false;
    };
    canvas.addEventListener('mousedown',SelectionMouseDown, false);
    SelectionMouseMove = function(evt){
      lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft);
      lastY = evt.offsetY || (evt.pageY - canvas.offsetTop);
      dragged = true;
      if (dragStart){
        var pt = ctx.transformedPoint(lastX,lastY);
        var width = pt.x - theRect.x;
        var height = pt.y - theRect.y;
        theRect.width = width;
        theRect.height = height;
        RectBeingConstructed = theRect;
        var td = document.getElementById('MousePosition');
        if(td != null){
          td.innerHTML = 'Rect(x,y): (' + theRect.x +
            ', ' + theRect.y + ')<br>' +
            'Rect(w,h): (' + theRect.width + ', ' + theRect.height + ')';
        }
        RenderImage(canvas, ctx);
      }
    };
    canvas.addEventListener('mousemove',SelectionMouseMove, false);
    SelectionMouseUp = function(evt){
      dragStart = null;
      var cont = {};
      cont.color = '#2020ff';
      cont.points = [];
      var ul = []; var ur = []; var lr = []; var ll = [];
      ul[0] = theRect.x;
      ul[1] = theRect.y;
      ur[0] = theRect.x + theRect.width;
      ur[1] = theRect.y;
      lr[0] = theRect.x + theRect.width;
      lr[1] = theRect.y + theRect.height;
      ll[0] = theRect.x;
      ll[1] = theRect.y + theRect.height;
      cont.points[0] = ul;
      cont.points[1] = ur;
      cont.points[2] = lr;
      cont.points[3] = ll;
      AnnotationsToDraw.push(cont);
      theRect = document.createElementNS(theSvg, 'rect');
      RectsToDraw.push(RectBeingConstructed);
      RectBeingConstructed = null;
      SendAnnotations();
//      RenderImage(canvas, ctx);
    };
    canvas.addEventListener('mouseup',SelectionMouseUp, false);

  };
  function RemoveSelectionTrackers(canvas, ctx){
    canvas.removeEventListener('mousedown',SelectionMouseDown, false);
    canvas.removeEventListener('mousemove',SelectionMouseMove, false);
    canvas.removeEventListener('mouseup',SelectionMouseUp, false);
  }
  
  // Adds ctx.getTransform() - returns an SVGMatrix
  // Adds ctx.transformedPoint(x,y) - returns an SVGPoint
  function trackTransforms(ctx){
    var xform = theSvg.createSVGMatrix();
    xform.a = 1; xform.b = 0; xform.c = 0, xform.d = 1;
    xform.e = 0; xform.f = 0;
    ctx.getTransform = function(){ return xform; };
    
    var savedTransforms = [];
    var save = ctx.save;
    ctx.save = function(){
      savedTransforms.push(xform.translate(0,0));
      return save.call(ctx);
    };
    var restore = ctx.restore;
    ctx.restore = function(){
      xform = savedTransforms.pop();
      return restore.call(ctx); };

    var scale = ctx.scale;
    ctx.scale = function(sx,sy){
      xform = xform.scaleNonUniform(sx,sy);
      return scale.call(ctx,sx,sy);
    };
    var rotate = ctx.rotate;
    ctx.rotate = function(radians){
      xform = xform.rotate(radians*180/Math.PI);
      return rotate.call(ctx,radians);
    };
     var translate = ctx.translate;
     ctx.translate = function(dx,dy){
      xform = xform.translate(dx,dy);
      return translate.call(ctx,dx,dy);
    };
    var transform = ctx.transform;
    ctx.transform = function(a,b,c,d,e,f){
      var m2 = theSvg.createSVGMatrix();
      m2.a=a; m2.b=b; m2.c=c; m2.d=d; m2.e=e; m2.f=f;
      xform = xform.multiply(m2);
      return transform.call(ctx,a,b,c,d,e,f);
    };
    var setTransform = ctx.setTransform;
    ctx.setTransform = function(a,b,c,d,e,f){
      xform.a = a;
      xform.b = b;
      xform.c = c;
      xform.d = d;
      xform.e = e;
      xform.f = f;
      return setTransform.call(ctx,a,b,c,d,e,f);
    };
    var pt  = theSvg.createSVGPoint();
    ctx.transformedPoint = function(x,y){
      pt.x=x; pt.y=y;
      return pt.matrixTransform(xform.inverse());
    }
  }
  var PanZoomMouseDown, PanZoomMouseMove, PanZoomMouseUp, PanZoomScroll;
  function InstallPanZoomTrackers(canvas, ctx){
    var lastX=canvas.width/2, lastY=canvas.height/2;
    var dragStart,dragged;
    PanZoomMouseDown = function(evt){
    document.body.style.mozUserSelect = 
        document.body.style.webkitUserSelect = 
          document.body.style.userSelect = 'none';
      lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft);
      lastY = evt.offsetY || (evt.pageY - canvas.offsetTop);
      dragStart = ctx.transformedPoint(lastX,lastY);
      dragged = false;
    };
    canvas.addEventListener('mousedown',PanZoomMouseDown, false);
    PanZoomMouseMove = function(evt){
      lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft);
      lastY = evt.offsetY || (evt.pageY - canvas.offsetTop);
      dragged = true;
      if (dragStart){
        var pt = ctx.transformedPoint(lastX,lastY);
        ctx.translate(pt.x-dragStart.x,pt.y-dragStart.y);
        RenderImage(canvas, ctx);
      }
    };
    canvas.addEventListener('mousemove',PanZoomMouseMove, false);
    PanZoomMouseUp = function(evt){
      dragStart = null;
      if (!dragged) zoom(evt.shiftKey ? -1 : 1 );
    };
    canvas.addEventListener('mouseup',PanZoomMouseUp, false);

    var scaleFactor = 1.025;
    var currentScaleFactor = 1.0;
    var zoom = function(clicks){
      var pt = ctx.transformedPoint(lastX,lastY);
      ctx.translate(pt.x,pt.y);
      var factor = Math.pow(scaleFactor,clicks);
      LineWidth /= factor;
      currentScaleFactor  = factor;
      ctx.scale(factor,factor);
      ctx.translate(-pt.x,-pt.y);
      RenderImage(canvas, ctx);
    }

    PanZoomScroll = function(evt){
      var delta = evt.wheelDelta ? 
        evt.wheelDelta/40 : evt.detail ? -evt.detail : 0;
      if (delta) zoom(delta);
      return evt.preventDefault() && false;
    };
    canvas.addEventListener('DOMMouseScroll',PanZoomScroll,false);
    canvas.addEventListener('mousewheel',PanZoomScroll,false);
  };
  function RemovePanZoomTrackers(canvas, ctx){
    canvas.removeEventListener('mousedown',PanZoomMouseDown, false);
    canvas.removeEventListener('mousemove',PanZoomMouseMove, false);
    canvas.removeEventListener('mousemove',PanZoomMouseMove, false);
    canvas.removeEventListener('DOMMouseScroll',PanZoomScroll,false);
    canvas.removeEventListener('mousewheel',PanZoomScroll,false);
  }
  
  // Adds ctx.getTransform() - returns an SVGMatrix
  // Adds ctx.transformedPoint(x,y) - returns an SVGPoint
  function trackTransforms(ctx){
    var theSvg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
    var xform = theSvg.createSVGMatrix();
    xform.a = 1; xform.b = 0; xform.c = 0, xform.d = 1;
    xform.e = 0; xform.f = 0;
    ctx.getTransform = function(){ return xform; };
    
    var savedTransforms = [];
    var save = ctx.save;
    ctx.save = function(){
      savedTransforms.push(xform.translate(0,0));
      return save.call(ctx);
    };
    var restore = ctx.restore;
    ctx.restore = function(){
      xform = savedTransforms.pop();
      return restore.call(ctx); };

    var scale = ctx.scale;
    ctx.scale = function(sx,sy){
      xform = xform.scaleNonUniform(sx,sy);
      return scale.call(ctx,sx,sy);
    };
    var rotate = ctx.rotate;
    ctx.rotate = function(radians){
      xform = xform.rotate(radians*180/Math.PI);
      return rotate.call(ctx,radians);
    };
     var translate = ctx.translate;
     ctx.translate = function(dx,dy){
      xform = xform.translate(dx,dy);
      return translate.call(ctx,dx,dy);
    };
    var transform = ctx.transform;
    ctx.transform = function(a,b,c,d,e,f){
      var m2 = theSvg.createSVGMatrix();
      m2.a=a; m2.b=b; m2.c=c; m2.d=d; m2.e=e; m2.f=f;
      xform = xform.multiply(m2);
      return transform.call(ctx,a,b,c,d,e,f);
    };
    var setTransform = ctx.setTransform;
    ctx.setTransform = function(a,b,c,d,e,f){
      xform.a = a;
      xform.b = b;
      xform.c = c;
      xform.d = d;
      xform.e = e;
      xform.f = f;
      return setTransform.call(ctx,a,b,c,d,e,f);
    };
    var pt  = theSvg.createSVGPoint();
    ctx.transformedPoint = function(x,y){
      pt.x=x; pt.y=y;
      return pt.matrixTransform(xform.inverse());
    }
  }
  function ImageLabelsReturned(obj) {
    if(ImageLabels == null) {
      //console.error("ImageLabels is null");
      return;
    }
    if(ImageLabels.d == null) {
      //console.error("ImageLabels.d is null");
      return;
    }
    var td = document.getElementById('LeftPositionText');
    if(td != null){
      td.innerHTML = ImageLabels.d.left_text;
    }
    td = document.getElementById('RightPositionText');
    if(td != null){
      td.innerHTML = ImageLabels.d.right_text;
    }
    td = document.getElementById('TopPositionText');
    if(td != null){
      td.innerHTML = ImageLabels.d.top_text;
    }
    td = document.getElementById('BottomPositionText');
    if(td != null){
      td.innerHTML = ImageLabels.d.bottom_text;
    }
    td = document.getElementById('CurrentInstance');
    if(td != null){
      td.innerHTML = "Current Instance: " +
       ImageLabels.d.current_instance;
    }
    td = document.getElementById('CurrentOffset');
    if(td != null){
      td.innerHTML = "Current Offset: " +
       ImageLabels.d.current_offset;
    }
    td = document.getElementById('OffsetSelector');
    if(td != null){
      td.selectedIndex = ImageLabels.d.current_index;
    }
    ImageLabelsPending = false;
    RenderImageIfReady();
  }
  var canvas;
  var ctx;
  WaitingForUpdates = function(){
    if(ContoursPending) { return true };
    if(ImageUrlPending) { return true };
    if(ImageLabelsPending) { return true };
    return false;
  }
  EnableImageControlButtons = function(){
    var td = document.getElementById('NextButton'); 
    if(td != null){
      td.disabled = false;
    }
    var td = document.getElementById('PrevButton'); 
    if(td != null){
      td.disabled = false;
    }
    var td = document.getElementById('OffsetSelector'); 
    if(td != null){
      td.disabled = false;
    }
  }
  DisableImageControlButtons = function(){
    var td = document.getElementById('NextButton'); 
    if(td != null){
      td.disabled = true;
    }
    var td = document.getElementById('PrevButton'); 
    if(td != null){
      td.disabled = true;
    }
    var td = document.getElementById('OffsetSelector'); 
    if(td != null){
      td.disabled = true;
    }
  }
  RenderImageIfReady = function(){
    if(WaitingForUpdates()){
      return;
    }
    RenderImage(canvas, ctx);
    if(WaitingForUpdates()){
      console.log("Waiting for updates right after RenderCanvas");
    }
    EnableImageControlButtons();
    if(CineEnabled == "On"){
      if(CineDir == "+"){
        document.getElementById('NextButton').click();
      } else {
        document.getElementById('PrevButton').click();
      }
    }
  }
  ImageToDraw.onload = function(){
    ImageUrlPending = false;
    var td = document.getElementById('div_image_pending');
    if(td != null){
      td.innerHTML="&nbsp;";
    }
    RenderImageIfReady();
  };
  function ImageUrlReturned(obj) {
    if(ImageUrl == null){
      //console.error("ImageUrl is null");
      return;
    }
    if(ImageUrl.d == null){
      //console.error("ImageUrl.d is null");
      return;
    }
    if(ImageUrl.d.url_type == "absolute"){
      ImageToDraw.src = ImageUrl.d.image;
    } else {
      ImageToDraw.src = BaseSessionUrl + ImageUrl.d.image;
    }
  }
  function ContoursReturned(obj) {
    ContoursPending = false;
    var td = document.getElementById('div_contours_pending');
    if(td != null){
      td.innerHTML="&nbsp;";
    }
    if(ContourResp == null){
      console.error("ContourResp is null");
      return;
    }
    if(ContourResp.d == null){
      console.error("ContourResp.d is null");
      return;
    }
    ContoursToDraw = ContourResp.d;
    RenderImageIfReady(canvas, ctx);
  }
  function UpdateImage(){
    //  Here get image from server, get overlays from server
    //  When complete:
    if(ImageLabelsPending){
      //console.error("Update when ImageLabels Pending");
    } else {
      ImageLabelsPending = true;
      ImageLabels = 
        new PosdaAjaxObj("ImageLabels", ObjPath, ImageLabelsReturned);
    }
    if(ImageUrlPending){
      //console.error("Update when ImageUrl Pending");
    } else {
      ImageUrlPending = true;
      var td = document.getElementById('div_image_pending');
      if(td != null){
        td.innerHTML="<small>image pending</small>";
      }
      ImageUrl =
        new PosdaAjaxObj("ImageUrl", ObjPath, ImageUrlReturned);
    }
    if(ContoursPending){
      console.error("Update when Contours Pending");
    } else {
      ContoursPending = true;
      //ContoursToDraw = [];
      //RenderImage(canvas, ctx);
      var td = document.getElementById('div_contours_pending');
      if(td != null){
        td.innerHTML="<small>contours pending</small>";
      }
      ContourResp = 
        new PosdaAjaxMethod("GetContoursToRender", ObjPath, ContoursReturned);
    }
    if(WaitingForUpdates()){
      DisableImageControlButtons();
    }
  }
  function EnableCine(){
    CineEnabled = "On";
  }
  function DisableCine(){
    CineEnabled = "Off";
  }
  function ToggleCine(){
    if(CineEnabled == "On"){
      CineEnabled = "Off";
    } else {
      CineEnabled = "On";
    }
    UpdateImage();
  }
  function ToggleCineDir(){
    if(CineDir == "+"){
      CineDir = "-";
    } else {
      CineDir = "+";
    }
    UpdateImage();
  }
  function EnableTracking(){
    if(TrackingEnabled == "Off"){
      TrackingEnabled = "On";
      InstallPanZoomTrackers(canvas, ctx);
    } else {
      console.log('EnableTracking called when Tracking Enabled = ' +
        TrackingEnabled);
    }
  }
  function DisableTracking(){
    if(TrackingEnabled == "On"){
      TrackingEnabled = "Off";
      RemovePanZoomTrackers(canvas, ctx);
    } else {
      console.log('DisableTracking called when Tracking Enabled = ' +
        TrackingEnabled);
    }
  }
  function EnableSelection(){
    if(SelectionEnabled == "Off"){
      SelectionEnabled = "On";
      InstallSelectionTrackers(canvas, ctx);
    } else {
      console.log('SelectionTracking called when Selection Enabled = ' +
        SelectionEnabled);
    }
  }
  function DisableSelection(){
    if(SelectionEnabled == "On"){
      SelectionEnabled = "Off";
      RemoveSelectionTrackers(canvas, ctx);
    } else {
      console.log('DisableSelection called when Selection Enabled = ' +
        SelectionEnabled);
    }
  }
  function TogglePz(){
    console.log('TogglePz called');
    if(TrackingEnabled == "On"){
      DisableTracking();
    } else {
      EnableTracking();
    }
    UpdateImage();
  }
  function Init() {
    canvas = document.getElementById('MyCanvas');
    LineWidth = 1;
//    console.error("Init");
    ctx = canvas.getContext('2d');
    trackTransforms(ctx);
//    EnableTracking();
    ImageToDraw.src = '/ITCLogoWeb.jpg';
    UpdateImage();
    var Loc = new String(document.location);
    var ques = Loc.indexOf('?');
    var base_one = Loc.substring(0, ques);
    var last_slash = base_one.lastIndexOf("/");
    BaseSessionUrl = base_one.substring(0, last_slash+1);
    console.log('BaseSessionUrl: "' + BaseSessionUrl + '"');
  }

  \$(document).ready(function(){ Init(); }) 
EOF

sub DicomImageDispJs{
  my($self, $http, $dyn) = @_;
  return $self->RefreshEngine($http, $dyn, $dicom_image_disp_js);
}
sub AjaxObj{
  my($self, $http, $dyn) = @_;
  my $ajax_obj_line = "line __LINE__ of __FILE__";
  my $foo = <<EOF;
  <!-- $ajax_obj_line -->
// Simple ajax object.
// Public domain From Patrick Hunlock <patrick\@hunlock.com>
// http://www.hunlock.com/blogs/The_Ultimate_Ajax_Object
function ajaxObject(url, callbackFunction) {
  var that=this;
  this.updating = false;
  this.abort = function() {
    if (that.updating) {
      that.updating=false;
      that.AJAX.abort();
      that.AJAX=null;
    }
  }
  this.update = function(passData,postMethod) {
    if (postMethod==null) {
      postMethod = "POST";
    }
    if (that.updating) {
      console.error("update when updating");
      return false;
    }
    that.AJAX = null;
    if (window.XMLHttpRequest) {
      that.AJAX=new XMLHttpRequest();
    } else {
      that.AJAX=new ActiveXObject("Microsoft.XMLHTTP");
    }
    if (that.AJAX==null) {
      return false;
    } else {
      that.AJAX.onreadystatechange = function() {
        if (that.AJAX.readyState==4) {
          that.updating=false;
          that.callback(that.AJAX.responseText,that.AJAX.status,that.AJAX.responseXML);
          that.AJAX=null;
        }
      }
      that.updating = new Date();
      if (/post/i.test(postMethod)) {
        var uri=urlCall+'&ts='+that.updating.getTime();
        // alert('ajaxObject::update POST called, url: '+uri);
        that.AJAX.open("POST", uri, true);
        that.AJAX.setRequestHeader(
          "Content-type", "text/plain");
          // "Content-type", "application/x-www-form-urlencoded");
        that.AJAX.send(passData);
      } else {
      var uri=urlCall+'?'+passData+'&timestamp='+(that.updating.getTime());
        // alert('ajaxObject::update GET called, url: '+uri);
        that.AJAX.open("GET", uri, true);
        that.AJAX.send(null);
      }
      return true;
    }
  }
  var urlCall = url;
  this.callback = callbackFunction || function () { };
}
function PosdaAjaxObj(r_obj, path, cb) {
  var that=this;
  this.r_obj = r_obj;
  this.cb = cb || function () { };
  this.ajaxObj =
    new ajaxObject("AjaxPosdaGet?obj_path="+path+"&obj="+r_obj,
      function(responseText) {
        // alert("PosdaAjaxObj::response: "+responseText);
        that.d = JSON.parse(responseText);
        that.cb(that.r_obj);
      }
    );
  this.update = function(passData,cb) {
    if (cb!=null) { this.cb = cb; }
    return this.ajaxObj.update(passData);
  }
  this.ajaxObj.update("");
}
function PosdaAjaxMethod(r_meth, path, cb) {
  var that=this;
  this.r_meth = r_meth;
  this.cb = cb || function () { };
  this.ajaxObj =
    new ajaxObject(r_meth + "?obj_path="+path,
      function(responseText) {
        // alert("PosdaAjaxObj::response: "+responseText);
        that.d = JSON.parse(responseText);
        that.cb(that.r_meth);
      }
    );
  this.update = function(passData,cb) {
    if (cb!=null) { this.cb = cb; }
    return this.ajaxObj.update(passData);
  }
  this.ajaxObj.update("");
}
function CloseThisWindow(){
  var that=this;
  PosdaAjaxMethod("JavascriptCloseWindow", ObjPath,
    function(responseText){
      window.close();
    }
  );
}
EOF
  $self->RefreshEngine($http, $dyn, $foo);
}

my $js_controller_local_line = "line __LINE__ of __FILE__";
my $js_controller_local = <<EOF;
<!-- $js_controller_local_line -->
var server_timer;
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

var ObjPath = '<?dyn="echo" field="path"?>';
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
function PosdaPostRemoteMethod(meth, content, cb){
  var ajax = new AjaxObj(meth + "?obj_path=" + ObjPath, cb);
  ajax.post(content);
}
function PosdaNewPostRemoteMethod(url, content, cb){
  var ajax = new AjaxObj(url,  cb);
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
  server_timer = setTimeout(chk_cmd, t);
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
      NewQueueRepeatingServerCmd(method, t);
    } else {
      console.log("status: %d", status);
      //alert('Bad Ajax Response');
      //window.location.reload();
      document.write("<h1>Bad Ajax Response</h1>");
      document.write("<p>Your connection to the server was lost.</p>");
      document.write("<p>This could be due to a server error, or a disruption ");
      document.write("in your internet connection.</p>");
      document.write("<p>Refreshing this page may help.</p>");
    }
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
function ChangeSelection(myNewSelected){
  var substohide = document.getElementsByClassName("subdiv");
  for (var i=0,len=substohide.length|0;i<len; i=i+1|0){
    substohide[i].style.display = "none"
  }
  document.getElementById(myNewSelected).style.display= "block";
}
EOF
sub JsControllerLocal{
  my($self, $http, $dyn) = @_;
  $dyn->{path} = $self->{path};
  $self->RefreshEngine($http, $dyn, $js_controller_local);
}

############################# Widgets


sub NextButton{
  my($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
    op => "NextSlice",
    caption => "nxt",
    id => "NextButton",
    sync => "UpdateImage();"
  });
}

sub PrevButton{
  my($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
    op => "PrevSlice",
    caption => "prv",
    id => "PrevButton",
    sync => "UpdateImage();"
  });
}

sub NextSlice{
  my($self, $http, $dyn) = @_;
  $self->{CurrentUrlIndex} += 1;
  if($self->{CurrentUrlIndex} > $#{$self->{JpegImageUrls}}){
    $self->{CurrentUrlIndex} = 0;
  }
  $self->SetImageUrl;
}

sub SetImageIndex{
  my($self, $http, $dyn) = @_;
  my $index = $dyn->{value};
  if($index >= 0 && $index <= $#{$self->{JpegImageUrls}}){
    $self->{CurrentUrlIndex} = $index;
    $self->SetImageUrl;
  } else {
    my $max = $#{$self->{JpegImageUrls}};
    print STDERR "#############\n" .
      "Bad value ($index) in SetImageIndex\n" .
      "Should be in range 0 }\n" .
      "#############\n";
  }
}

sub PrevSlice{
  my($self, $http, $dyn) = @_;
  $self->{CurrentUrlIndex} -= 1;
  if($self->{CurrentUrlIndex} < 0){
    $self->{CurrentUrlIndex} = $#{$self->{JpegImageUrls}};
  }
  $self->SetImageUrl;
}

sub NullLineHandler{
  my($self) = @_;
  my $sub = sub{};
  return $sub;
}
sub NullNotifier{
  my($self, $dyn) = @_;
}

sub SetWinLev{
  my($self, $http, $dyn) = @_;
  my $v = $dyn->{value};
  if($v eq "No preset"){
    delete $self->{WindowWidth};
    delete $self->{WindowCenter}
  } else {
    my ($wc, $ww) = split(/:/, $dyn->{value});
    $self->{WindowCenter} = $wc;
    $self->{WindowWidth} = $ww;
  }
  $self->InitializeUrls;
}
my $preset_widget_ct = <<EOF;
  <select class="form-control"
    onchange="javascript:PosdaGetRemoteMethod('SetWinLev', 'value=' +
      this.options[this.selectedIndex].value,
      function () { UpdateImage(); });">;
    <option value="None" selected="">No preset</option>
    <option value="470:20">Soft Tissue</option>
    <option value="450:50">Abdomen</option>
    <option value="350:50">Mediastinum</option>
    <option value="1600:-600">Lung</option>
    <option value="2000:300">Bone</option>
    <option value="4000:400">Sinus</option>
    <option value="180:80">Larynx</option>
    <option value="120:40">Brain Posterior</option>
    <option value="80:40">Brain</option>
  </select>
EOF
sub PresetWidgetCt{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $preset_widget_ct);
}

sub ToolTypeSelector{
  my($self, $http, $dyn) = @_;
  unless(defined $self->{ToolType}){
    $self->{ToolType} = "None";
  }
  $http->queue("Tool type: ");
  $self->SelectDelegateByValue($http, {
    op => "SelectToolType",
    id => "SelectToolTypeDropdown",
    class => "form-control",
    style => "",
    sync => "InitToolType();"
  });
  for my $i ("None", "Pan/Zoom", "Select"){
   $http->queue("<option value=\"$i\"");
   if($i eq $self->{ToolType}){
     $http->queue(" selected");
   }
   $http->queue(">$i</option>");
  }
  $http->queue("</select>");
}
sub SelectToolType{
  my($self, $http, $dyn) = @_;
  $self->{ToolType} = $dyn->{value};
}
sub UploadJsonObject{
  my($self, $http, $dyn) = @_;
  my $text = $http->ParseTextPlain;
  my $data_name = $dyn->{DataName};
  my $json = JSON->new->allow_nonref;
  $self->{$data_name} = $json->decode($text);
#  print STDERR
#    "++++++++++++++++++++++++++++++++++++++++\n" .
#    "In UploadJsonObject\n";
#  for my $i (keys %{$dyn}){
#    print STDERR "dyn{$i} = $dyn->{$i}\n";
#  }
#  print STDERR "text: \"$text\"\n";
#  print STDERR
#    "++++++++++++++++++++++++++++++++++++++++\n";
}

1;
