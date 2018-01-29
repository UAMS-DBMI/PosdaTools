  var ImageToDraw = new Image;
  var ImageUrl;
  var ImageLabels;
  var ImageUrlPending = false;
  var ImageLabelsPending = false;
  var BaseSessionUrl;
  var LineWidth = 1;
  var ToolType = "None";
//  var ContoursToDraw = [];
  var ContourResp;
  var ContoursToDraw = [
  ];
  var ContoursPending;

  function trackTransforms(ctx){
    var svg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
    var xform = svg.createSVGMatrix();
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
      return restore.call(ctx);
    };

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
      var m2 = svg.createSVGMatrix();
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
    var pt  = svg.createSVGPoint();
    ctx.transformedPoint = function(x,y){
      pt.x=x; pt.y=y;
      return pt.matrixTransform(xform.inverse());
    }
  }
  function RenderImage (canvas, ctx) {
      // Clear the entire canvas
      var p1 = ctx.transformedPoint(0,0);
      var p2 = ctx.transformedPoint(canvas.width,canvas.height);
      ctx.clearRect(p1.x,p1.y,p2.x-p1.x,p2.y-p1.y);

      // Alternatively:
      // ctx.save();
      // ctx.setTransform(1,0,0,1,0,0);
      // ctx.clearRect(0,0,canvas.width,canvas.height);
      // ctx.restore();

      ctx.drawImage(ImageToDraw,0,0);
//      if(ToolType == "PanZoom"){
//      } else {
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
 //     }
      ctx.save();
  };
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
    var zoom = function(clicks){
      var pt = ctx.transformedPoint(lastX,lastY);
      ctx.translate(pt.x,pt.y);
      var factor = Math.pow(scaleFactor,clicks);
      LineWidth /= factor;
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
    var td = document.getElementById('ControlButton2');
    td.innerHTML = 
      '<input type="button" onClick="DisableTracking();" value="p/z off"/>';
  };
  function RemovePanZoomTrackers(canvas, ctx){
    canvas.removeEventListener('mousedown',PanZoomMouseDown, false);
    canvas.removeEventListener('mousemove',PanZoomMouseMove, false);
    canvas.removeEventListener('mousemove',PanZoomMouseMove, false);
    canvas.removeEventListener('DOMMouseScroll',PanZoomScroll,false);
    canvas.removeEventListener('mousewheel',PanZoomScroll,false);
    var td = document.getElementById('ControlButton2');
    td.innerHTML = 
      '<input type="button" onClick="EnableTracking();" value="p/z on"/>';
  }
  
  // Adds ctx.getTransform() - returns an SVGMatrix
  // Adds ctx.transformedPoint(x,y) - returns an SVGPoint
  function trackTransforms(ctx){
    var svg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
    var xform = svg.createSVGMatrix();
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
      var m2 = svg.createSVGMatrix();
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
    var pt  = svg.createSVGPoint();
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
    $('#LeftPositionText').html(ImageLabels.d.left_text);
    $('#RightPositionText').html(ImageLabels.d.right_text);
    $('#TopPositionText').html(ImageLabels.d.top_text);
    $('#BottomPositionText').html(ImageLabels.d.bottom_text);
  }
  var canvas;
  var ctx;
  ImageToDraw.onload = function(){
    RenderImage(canvas, ctx);
  };
  function ImageUrlReturned(obj) {
    ImageUrlPending = false;
    var td = document.getElementById('ControlButton10');
    td.innerHTML="&nbsp;";
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
    var td = document.getElementById('ControlButton9');
    td.innerHTML="&nbsp;";
    if(ContourResp == null){
      console.error("ContourResp is null");
      return;
    }
    if(ContourResp.d == null){
      console.error("ContourResp.d is null");
      return;
    }
    ContoursToDraw = ContourResp.d;
    RenderImage(canvas, ctx);
  }
  function Update(){
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
      var td = document.getElementById('ControlButton10');
      td.innerHTML="<small>pending</small>";
      ImageUrl =
        new PosdaAjaxObj("ImageUrl", ObjPath, ImageUrlReturned);
    }
    if(ContoursPending){
      console.error("Update when Contours Pending");
    } else {
      ContoursPending = true;
      //ContoursToDraw = [];
      //RenderImage(canvas, ctx);
      var td = document.getElementById('ControlButton9');
      td.innerHTML="<small>pending</small>";
      ContourResp = 
        new PosdaAjaxMethod("GetContoursToRender", ObjPath, ContoursReturned);
    }
    if(ToolType == "None"){
      var td = document.getElementById('ControlButton2');
      td.innerHTML = 
        '<input type="button" onClick="EnableTracking();" value="p/z on"/>';
//      $('#ControlButton2').innerHTML = 
//        '<input type="button" onClick="EnableTracking();" value="p/z on"/>';
    } else {
      var td = document.getElementById('ControlButton2');
      td.innerHTML = 
        '<input type="button" onClick="DisableTracking();" value="p/z off"/>';
//      $('#ControlButton2').innerHTML = 
//        '<input type="button" onClick="DisableTracking();" value="p/z off"/>';
    }
  }
  function EnableTracking(){
    InstallPanZoomTrackers(canvas, ctx);
    ToolType = "PanZoom";
  }
  function DisableTracking(){
    RemovePanZoomTrackers(canvas, ctx);
    ToolType = "None";
    RenderImage(canvas, ctx);
  }
  function Init() {
    canvas = document.getElementById('MyCanvas');
    LineWidth = 1;
//    console.error("Init");
    ctx = canvas.getContext('2d');
    trackTransforms(ctx);
//    EnableTracking();
    ImageToDraw.src = '/ITCLogoWeb.jpg';
    Update();
    var Loc = new String(document.location);
    var ques = Loc.indexOf('?');
    var base_one = Loc.substring(0, ques);
    var last_slash = base_one.lastIndexOf("/");
    BaseSessionUrl = base_one.substring(0, last_slash+1);
  }

  $(document).ready(function(){ Init(); }) 
