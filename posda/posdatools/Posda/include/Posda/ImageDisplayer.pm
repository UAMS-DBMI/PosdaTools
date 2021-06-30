#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer;
use Posda::HttpApp::JsController;
use Posda::DB qw(Query);

use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::JsController" );
my $expander = <<EOF;
<?dyn="BaseHeader"?>
<script type="text/javascript">
<?dyn="AjaxObj"?>
<?dyn="DicomImageDispJs"?>
<?dyn="JsContent"?>
<?dyn="JsControllerLocal"?>
</script>
</head>
<body>
<?dyn="Content"?>
<?dyn="Footer"?>
EOF
sub new {
  my($class, $sess, $path, $parms) = @_;
  my $self = Posda::HttpApp::JsController->new($sess, $path);
  bless $self, $class;
  $self->{expander} = $expander;
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
  var ToolType = "No tool";
  var TrackingEnabled = "Off";
  var SelectionEnabled = "Off";
  var CineEnabled = "No";
  var CineDir = "+";
  var ContourResp;
  var ContoursToDraw = [
  ];
  var AnnotationsToDraw = [
  ];
  var RectsToDraw = [
  ];
  var RectBeingConstructed = null;
  var VisibleContours = {};
  var theSvg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
  function SendAnnotations(){
//    var data = JSON.stringify(AnnotationsToDraw)
//    var ajax = new AjaxObj('UploadJsonObject' + "?obj_path=" + ObjPath +
//      '&DataName=Annotations', function () { RenderImage(canvas,ctx); });
//    ajax.post(data);
    var data = JSON.stringify(RectsToDraw)
    var ajax = new AjaxObj('UploadJsonObject' + "?obj_path=" + ObjPath +
      '&DataName=Annotations', function () { RenderImage(canvas,ctx); });
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
        td.innerHTML = 'a: ' + tf.a + ' b: ' + tf.b + ' <br>c: ' 
          + tf.c + 'd: ' + tf.d + ' <br>e: ' + tf.e + ' f: ' + tf.f;
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
         var cont_name = ContoursToDraw[i].id;
         var is_visible = VisibleContours[cont_name];
         if(is_visible){
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
    } else if (ToolType == "Rect"){
      DisableSelection();
    }
    ToolType = sel_type;
    if(ToolType == "Pan/Zoom"){
      EnableTracking();
    } else if (ToolType == "Rect"){
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
    td = document.getElementById('CurrentIndex');
    if(td != null){
      td.innerHTML = "Current Index: " +
       ImageLabels.d.current_index;
    }
    td = document.getElementById('OffsetSelector');
    if(td != null){
      td.selectedIndex = ImageLabels.d.current_index;
    }
    td = document.getElementById('IndexSelector');
    if(td != null){
      td.selectedIndex = ImageLabels.d.current_index;
    }
    if(ImageLabels.d.VisibleContours != null){
      VisibleContours = ImageLabels.d.VisibleContours;
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
    var td = document.getElementById('IndexSelector'); 
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
    var td = document.getElementById('IndexSelector'); 
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
    ImageToDraw.src = '/LoadingScreen.png';
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

sub RoiSelector{
  my($self, $http, $dyn) = @_;
  for my $ri (
    sort { $a <=> $b }
    keys %{$self->{params}->{rois}}
  ){
    my $roi = $self->{params}->{rois}->{$ri};
    my $color = sprintf("%02x%02x%02x", $roi->{color}->[0],
      $roi->{color}->[1], $roi->{color}->[2]);
    $http->queue("<div style=\"display: flex; flex-direction: row;" .
      " align-items: flex-beginning; margin-right: 5px\" id=\"div_roi_$ri\">");
    $http->queue($self->CheckBoxDelegate("SelectRoiForDisplay", 0,
        $self->{ImageLabels}->{VisibleContours}->{"roi_num_$ri"},
        { op => "SelectRoiForDisplay",
          sync => "UpdateImage();",
          roi =>$ri
        }
      )
    );
    $http->queue("<font style=\"color: #$color\">$roi->{name}</font>");
    $http->queue("</div>");
  }
}

sub SelectRoiForDisplay{
  my($self, $http, $dyn) = @_;
  my $roi_id = "roi_num_$dyn->{roi}";
  if($dyn->{checked} eq "true"){
    $self->{ImageLabels}->{VisibleContours}->{$roi_id} = 1;
  } elsif ($dyn->{checked} eq "false"){
    $self->{ImageLabels}->{VisibleContours}->{$roi_id} = 0;
  }
}

sub ToggleRoiVisible{
  my($self, $http, $dyn) = @_;
  if($self->{RoiVisible}){
    $self->{RoiVisible} = 0;
  } else {
    $self->{RoiVisible} = 1;
  }
  $self->SetImageUrl;
}

sub ToggleRoiVisibilty{
  my($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "ToggleRoiVisible",
     caption => "Toggle Roi",
     sync => "UpdateImage();"
  });
}

sub IndexSelector{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn,
    "<select id=\"IndexSelector\" class=\"form-control\"\n" .
    "onchange=\"javascript:PosdaGetRemoteMethod('SetImageIndex', 'value=' +\n" .
    "  this.options[this.selectedIndex].value,\n".
    "  function () { UpdateImage(); });\">" .
    "<?dyn=\"IndexOptions\"?>" .
    "</select>");
}

sub IndexOptions{
  my($self, $http, $dyn) = @_;
  for my $i (0 .. $#{$self->{FileList}}){
    $http->queue("<option value=\"$i\">$i</option>");
  }
}

sub OffsetSelector{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn,
    "<select id=\"OffsetSelector\" class=\"form-control\"\n" .
    "onchange=\"javascript:PosdaGetRemoteMethod('SetImageIndex', 'value=' +\n" .
    "  this.options[this.selectedIndex].value,\n".
    "  function () { UpdateImage(); });\">" .
    "<?dyn=\"OffsetOptions\"?>" .
    "</select>");
}

sub OffsetOptions{
  my($self, $http, $dyn) = @_;
  for my $i (0 .. $#{$self->{FileList}}){
    $http->queue("<option value=\"$i\">" .
      "$self->{FileList}->[$i]->{offset}</option>");
  }
}

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
    $self->{WindowWidth} = "";
    $self->{WindowCenter} = "";
  } else {
    my ($wc, $ww) = split(/:/, $dyn->{value});
    $self->{WindowCenter} = $wc;
    $self->{WindowWidth} = $ww;
  }
  $self->InitializeUrls;
  $self->SetImageUrl;
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
  $self->RefreshEngine($http, $dyn,
    "<select class=\"form-control\" ".
    "onchange=\"javascript:SetToolType" .
    "(this.options[this.selectedIndex].value);\">" .
    "<option value=\"None\" selected=\"\">No tool</option>" .
    "<?dyn=\"ToolTypeOptions\"?>" .
    "</select>");
}
sub ToolTypeOptions{
  my($self, $http, $dyn) = @_;
  my @ToolTypes;
  if(defined $self->{ToolTypes}){
    @ToolTypes = @{$self->{ToolTypes}};
  } else {
    @ToolTypes = (["Pan/Zoom", "P/Z tool"], ["Rect", "Rect Tool"]);
  }
  for my $i (@ToolTypes){
   $http->queue("<option value=\"$i->[0]\"");
   $http->queue(">$i->[1]</option>");
  }
}

sub ImageTypeSelector{
  my($self, $http, $dyn) = @_;
  unless(
    defined $self->{ImageTypes} &&
    ref($self->{ImageTypes}) eq "ARRAY" &&
    ref($self->{ImageTypes}->[0]) eq "ARRAY"
  ){ return };
  unless(defined $self->{ImageType}){
    $self->{ImageType} = $self->{ImageTypes}->[0]->[0];
  }
  $self->SelectDelegateByValue($http, {
    op => "SelectImageType",
    id => "SelectImageTypeDropdown",
    class => "form-control",
    style => "",
    sync => "UpdateImage();"
  });
  for my $i (@{$self->{ImageTypes}}){
   $http->queue("<option value=\"$i->[0]\"");
   if($i->[0] eq $self->{ImageType}){
     $http->queue(" selected");
   }
   $http->queue(">$i->[1]</option>");
  }
  $http->queue("</select>");
}
sub SelectImageType{
  my($self, $http, $dyn) = @_;
  $self->{ImageType} = $dyn->{value};
  $self->SetImageUrl;
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

sub CanvasHeight{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{canvas_height});
}
sub CanvasWidth{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{canvas_width});
}

############################# Fetch Dicom / Send Jpeg

sub FetchDicomJpeg{
  my($self, $http, $dyn) = @_;
  my $dicom_file_id = $dyn->{file_id};
  $self->{CurrentDicomFile} = $dicom_file_id;
  unless(defined $self->{WindowWidth}){
    $self->{WindowWidth} = "";
    $self->{WindowCenter} = "";
  }
  my $window_width = $self->{WindowWidth};
  my $window_ctr = $self->{WindowCenter};
  unless(defined $window_width) { $window_width = "" }
  unless(defined $window_ctr) { $window_ctr = "" }
  my $jpeg_file = "$self->{params}->{tmp_dir}/" .
    "$dicom_file_id" ."_$window_ctr" . "_$window_width.jpeg";
  unless(-f $jpeg_file){
    my $rendered_dicom_gray = "$self->{params}->{tmp_dir}/$dicom_file_id.gray";
    my $cmd = "CacheDicomAsJpeg.pl $dicom_file_id \"$window_width\" " .
     "\"$window_ctr\" " .
     "$rendered_dicom_gray $jpeg_file;echo 'done'";
    my @render_list;
    Dispatch::LineReader->new_cmd($cmd,
      $self->HandleRenderersLines(\@render_list),
      $self->ContinueRenderingImage($http, $dyn, $jpeg_file,
        $rendered_dicom_gray, $dicom_file_id, \@render_list)
    );
    return;
  }
  $self->SendCachedJpeg($http, $dyn, $jpeg_file)
}

sub HandleRenderersLines{
  my($self, $render_list) = @_;
  my $sub = sub {
    my($line) = @_;
    push @$render_list, $line;
  };
  return $sub;
}

sub ContinueRenderingImage{
  my($self, $http, $dyn, $rendered_dicom_jpeg, $rendered_dicom_gray,
    $dicom_file_id, $render_list) = @_;
  my $sub = sub {
    $self->SendCachedJpeg($http, $dyn, $rendered_dicom_jpeg);
    unlink $rendered_dicom_gray;
  };
  return $sub;
}

sub SendCachedJpeg{
  my($self, $http, $dyn, $jpeg_path) = @_;
  my $contour_file_id = $self->{ContourFileId};
  my $content_type = "image/jpeg";
  open my $sock, "cat $jpeg_path|" or die "Can't open " .
    "$jpeg_path for reading ($!)";

  $self->SendContentFromFh($http, $sock, $content_type,
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}

############################# Fetch Jpeg / Png / Test Pattern

sub FetchJpeg{
  my ($self, $http, $dyn) = @_;
  $self->FetchImgFile($http, $dyn, "image/jpeg");
}

sub FetchPng{ 
  my ($self, $http, $dyn) = @_;
  $self->FetchImgFile($http, $dyn, "image/png");
}

sub FetchImgFile{
  my ($self, $http, $dyn, $mime_type) = @_;
  my $file;
  unless(defined($dyn->{file_id}) && $dyn->{file_id} ne ""){
    print STDERR "file_id not defined:\n";
    for my $i (keys %$dyn){ 
      print STDERR "dyn{$i} = $dyn->{$i}\n";
    }
    return;
  }

  Query('GetFilePath')->RunQuery(sub{
    my($row) = @_;
    $file = $row->[0];
  }, sub {}, $dyn->{file_id}); 
  open my $fh, "cat $file|" or die "Can't open $file for reading ($!)";
  $self->SendContentFromFh($http, $fh, $mime_type,
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}
sub FetchTestPattern{
  my($self, $http, $dyn) = @_;
  my $tp_path = "$self->{params}->{tmp_dir}/TestPattern.png";
  my $tmp_path = "$self->{params}->{tmp_dir}/TestPattern.pbm";
  unless(-f $tp_path){
    my $cmd = "MakeTestPbm.pl 512 512  >$tmp_path; ".
    "convert $tmp_path $tp_path; rm $tmp_path; echo done";
    my @render_list;
    Dispatch::LineReader->new_cmd($cmd,
      $self->HandleRenderersLines(\@render_list),
      $self->ContinueRenderingImage($http, $dyn, $tp_path,
        \@render_list)
    );
    return;
  }
  $self->SendCachedPng($http, $dyn, $tp_path);
}
sub ContinueRenderingTp{
  my($self, $http, $dyn, $rendered_test_pat, $render_list) = @_;
  my $sub = sub {
    $self->SendCachedPng($http, $dyn, $rendered_test_pat);
  };
  return $sub;
}
sub SendCachedPng{
  my($self, $http, $dyn, $png_path) = @_;
  my $content_type = "image/png";
  open my $sock, "cat $png_path|" or die "Can't open " .
    "$png_path for reading ($!)";

  $self->SendContentFromFh($http, $sock, $content_type,
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}

############################# InitializeUrls

sub InitializeUrls{
  my($self)= @_;
    ######  Here is the "definition" of FileList #########
#    push @{$self->{FileList}}, {
#      dicom_file_id => $dicom_file_id, # if dicom file
#      jpeg_file_id => $dicom_file_id,  # if jpeg file only
#      contour_files => [
#        {
#          file_id => $contour_file_id,
#          num_contours => $num_contours,
#          contour_points => $contour_points,
#          color => $color,
#          roi_id => $roi_id,
#          roi_name => $roi_name,
#        },
#        ...
#      ],
#      seg_bitmaps => [
#        {
#          seg_slice_bitmap_file_id => $seg_slice_bitmap_file_id,
#          png_file_id => $png_file_id,
#          frame_no => $frame_no,
#          total_one_bits => $total_one_bits,
#          num_bare_points => $num_bare_points,
#        },
#        ...
#      ],
#      offset => $offset,            #only if dicom and/or seg_bitmaps
#      off_normal => $off_normal,    #
#      iop => $iop,                  #
#      ipp => $ipp,                  #
#      instance_num => $instance_num #only if dicom
#    };
    #^^^^^  Here is the "definition" of FileList ^^^^^^^^^
  delete $self->{BitmapImageUrls};
  $self->{ContourFiles} = [];
  $self->{JpegImageUrls} = [];
  for my $i (0 .. $#{$self->{FileList}}){
    my $ent = $self->{FileList}->[$i];
    if(exists $ent->{jpeg_file_id}){
      my $jpeg_url = "FetchJpeg?obj_path=$self->{path}&file_id=" .
        "$ent->{dicom_file_id}";
      push(@{$self->{JpegImageUrls}}, {
        image => $jpeg_url,
        url_type => "relative",
      });
    } else {
      unless(defined $self->{WindowWidth}){ $self->{WindowWidth} = "" }
      unless(defined $self->{WindowCenter}){ $self->{WindowCenter} = "" }
      my $jpeg_url = "FetchDicomJpeg?obj_path=$self->{path}&file_id=" .
        $ent->{dicom_file_id} . "&width=$self->{WindowWidth}" .
        "&ctr=$self->{WindowCenter}";
      push(@{$self->{JpegImageUrls}}, {
        image => $jpeg_url,
        url_type => "relative",
      });
    }
    if(exists $ent->{contour_files} && ref($ent->{contour_files}) eq "ARRAY"){
      push(@{$self->{ContourFiles}}, $ent->{contour_files});
    } else {
      push @{$self->{ContourFiles}}, [];
    }
   $self->InitializeSegs($ent);
  }
};

sub InitializeSegs{
  my($self, $ent) = @_;
  ## default does nothing  -- override if you want to display segmentations
}

#sub SetImageUrl{
sub SetImageUrl{
  my($self)= @_;
  unless(defined $self->{CurrentUrlIndex}){ $self->{CurrentUrlIndex} = 0 }
  unless(defined $self->{ImageType}){
    if(
      defined $self->{ImageTypes} &&
      ref($self->{ImageTypes}) eq "ARRAY" &&
      ref($self->{ImageTypes}->[0]) eq "ARRAY"
    ){
      $self->{ImageType} = $self->{ImageTypes}->[0]->[0];
    } else {
      $self->{ImageType} = "Dicom Image";
    }
  }
  my $current_index = $self->{CurrentUrlIndex};
  if($self->{ImageType} eq "Rendered Bitmap"){
    $self->{ImageUrl} = $self->{BitmapImageUrls}->[$current_index];
  }elsif($self->{ImageType} eq "Dicom Image"){
    $self->{ImageUrl} = $self->{JpegImageUrls}->[$current_index];
  } elsif($self->{ImageType} eq "Test Pattern"){
    $self->{ImageUrl} = {
        url_type => "relative",
        image => "FetchTestPattern?obj_path=$self->{path}"
    };
  }else{
    die "WTF?  Image Type = $self->{ImageType} !!!";
  }
  $self->SetContourRendering;
  $self->{ImageLabels}->{current_instance} =
    $self->{FileList}->[$current_index]->{instance};
  $self->{ImageLabels}->{current_offset} =
    $self->{FileList}->[$current_index]->{offset};
  $self->{ImageLabels}->{current_index} = $current_index;
  $self->SetTextLabels;
  if(exists $self->{RoiVisible}){
    $self->{ImageLabels}->{VisibleContours} = {
       "this_roi" => $self->{RoiVisible}
    };
  }
}
sub SetContourRendering{
  my($self)= @_;
  my $current_index = $self->{CurrentUrlIndex};
  $self->{CurrentContourRendering} =
    $self->{ContourFiles}->[$current_index];
}
sub SetTextLabels{
  my($self)= @_;
  my $current_index = $self->{CurrentUrlIndex};
  my @iop = split(/\\/, $self->{FileList}->[$current_index]->{iop});
  my $top_text = "";
  my $bottom_text = "";
  my $right_text = "";
  my $left_text = "";
  if($iop[0] > 0){
    $left_text .= "R"; $right_text .= "L";
  } elsif($iop[0] < 0){
    $left_text .= "L"; $right_text .= "R";
  }
  if($iop[1] > 0){
    $left_text .= "A"; $right_text .= "P";
  } elsif($iop[1] < 0){
    $left_text .= "P"; $right_text .= "A";
  }
  if($iop[2] > 0){
    $left_text .= "H"; $right_text .= "F";
  } elsif($iop[2] < 0){
    $left_text .= "F"; $right_text .= "H";
  }
  if($iop[3] > 0){
    $top_text .= "R"; $bottom_text .= "L";
  } elsif($iop[3] < 0){
    $top_text .= "L"; $bottom_text .= "R";
  }
  if($iop[4] > 0){
    $top_text .= "A"; $bottom_text .= "P";
  } elsif($iop[4] < 0){
    $top_text .= "P"; $bottom_text .= "A";
  }
  if($iop[5] > 0){
    $top_text .= "H"; $bottom_text .= "F";
  } elsif($iop[5] < 0){
    $top_text .= "F"; $bottom_text .= "H";
  }
  $self->{ImageLabels}->{top_text} = "<small>$top_text</small>";
  $self->{ImageLabels}->{bottom_text} = "<small>$bottom_text</small>";
  $self->{ImageLabels}->{right_text} = "<small>$right_text</small>";
  $self->{ImageLabels}->{left_text} = "<small>$left_text</small>";
}


############################# Fetch Contours

sub GetContoursToRender{
  my($self, $http, $dyn) = @_;
  my $get_file = Query('GetFilePath');
  unless(
    exists($self->{CurrentContourRendering}) &&
    ref($self->{CurrentContourRendering}) eq "ARRAY" &&
    $#{$self->{CurrentContourRendering}} >= 0
  ){
    my $content_type = "application/json";
    $http->HeaderSent;
    $http->queue("HTTP/1.0 200 OK\n");
    $http->queue("Content-type: $content_type\n\n");
    $http->queue("[]");
    return;
  }
  my $json_contours_path =
    "$self->{params}->{tmp_dir}/contours_$self->{contour_root_file_id}";
  my @contour_render_struct;
  for my $cn (0 .. $#{$self->{CurrentContourRendering}}){
    my $c = $self->{CurrentContourRendering}->[$cn];
    $json_contours_path .= "_$c->{file_id}";
    my $file_path;
    $get_file->RunQuery(sub{
      my($row) = @_;
      $file_path = $row->[0];
    }, sub {}, $c->{file_id});
    my $roi_id;
    if(exists $c->{id}){ $roi_id = $c->{id} }
    else {$roi_id = "roi_num_" . $c->{roi_id} }
    my $contour_render_hash = {
      id => $roi_id,
      color => $c->{color},
      type => "2dContourBatch",
      file => $file_path,
      pix_sp_x => 1,
      pix_sp_y => 1,
      x_shift => $self->{x_shift},
      y_shift => $self->{y_shift},
    };
    push @contour_render_struct, $contour_render_hash;
  }
  my $tmp1 = "$json_contours_path.contours";
  $json_contours_path .= ".json";
  unless(-f $json_contours_path){
    Storable::store \@contour_render_struct, $tmp1;
    my $cmd = "cat $tmp1|Construct2DContoursFromExtractedFile.pl > " .
      "$json_contours_path;" .
      "echo 'done'";
    Dispatch::LineReader->new_cmd($cmd,
      $self->NullLineHandler(),
      $self->ContinueProcessingContours($http, $dyn, $tmp1,
        $json_contours_path)
    );
    return;
  }
  $self->SendCachedContours($http, $dyn, $json_contours_path);
}

sub ContinueProcessingContours{
  my($self, $http, $dyn, $tmp1, $json_contours_path) = @_;
  my $sub = sub {
    unlink $tmp1;
    $self->SendCachedContours($http, $dyn, $json_contours_path);
  };
  return $sub;
}
sub SendCachedContours{
  my($self, $http, $dyn, $json_contours_path) = @_;
  my $contour_file_id = $self->{ContourFileId};
  my $content_type = "text/json";
  open my $sock, "cat $json_contours_path|" or die "Can't open " .
    "$json_contours_path for reading ($!)";

#  open FILE, "<$json_contours_path" or die "Can't open $json_contours_path" .
#    " for reading ($!)";
  $self->SendContentFromFh($http, $sock, "application/json",
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}



1;
