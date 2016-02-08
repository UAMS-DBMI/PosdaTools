/*!
 *

 <div> layout:
 [chartr]
 [RoiInfo
   [RoiSelection]
   [DosePVolSel
     [DoseSel]
     [PerVolSel] ]
   [AVolSel
     [AbsVolSel] ]
   [RoiDoseInfo
     [RoiMin]
     [RoiMax]
     [DoseFileMin]
     [DoseFileMax] ] 
 ]
 */
  var DvhData;
  var DvhPlot;
  var points = [];
  var series_opts = [];
  var DvhDataSaved = [];
  
  $.jqplot.config.enablePlugins = true;

  function GetPercentVol(roi_index,dose) {
    var p = DvhData.d[roi_index].d.data;
    var x1,x2,y1,y2;
    for (var i=0;i<p.length;i++) {
      if (p[i][0] == dose) { return p[i][1]; }
      if (p[i][0] > dose) { break; }
    }
    if (i == 0) {
      x1 = 0.0; y1 = 100.0; x2 = p[0][0]; y2 = p[0][1];
    } else if (i >= p.length) {
      return p[p.length-1][1];
    } else {
      x1 = p[i-1][0], y1 = p[i-1][1];
      x2 = p[i][0], y2 = p[i][1];
    }
    var diff = Math.abs(x2-x1);
    if (diff == 0) { return y1; }
    return (Math.abs((x2-dose)/diff)*y1 +
            Math.abs((x1-dose)/diff)*y2);
  }

  function GetDose(roi_index,p_vol) {
    var p = DvhData.d[roi_index].d.data;
    var x1,x2,y1,y2;
    for (var i=0;i<p.length;i++) {
      if (p[i][1] == p_vol) { return p[i][0]; }
      if (p[i][1] < p_vol) { break; }
    }
    if (i == 0) {
      x1 = 0.0; y1 = 100.0; x2 = p[0][0]; y2 = p[0][1];
    } else if (i >= p.length) {
      return p[p.length-1][0];
    } else {
      x1 = p[i-1][0], y1 = p[i-1][1];
      x2 = p[i][0], y2 = p[i][1];
    }
    var diff = Math.abs(y2-y1);
    if (diff == 0) { return x1; }
    return (Math.abs((y2-p_vol)/diff)*x1 +
            Math.abs((y1-p_vol)/diff)*x2);
  }

  function ClearAndHideFooter() {
    $("#RoiInfo").hide();
    $("#RoiSelection").html("");
    $("#DoseSel").val("");
    $("#PerVolSel").val("");
    $("#AbsVolSel").val("");
    $("#RoiMin").text("");
    $("#RoiMax").text("");
    $("#RoiMaxAbsVol").text("");
    $("#DoseFileMin").text("");
    $("#DoseFileMax").text("");
  }

  function DvhDataDoneChk() {
    var done = true;
    if ('undefined' === typeof(DvhData.d)) { return; }
    for (var i=0;i<DvhData.d.length;i++) {
      if (DvhData.d[i].d == null) {
        done = false;
      }
    }
    // console.log("DvhDataDoneChk: All DVHs retreived, #: "+DvhData.d.length);
    if (! done) { return; }
    ClearAndHideFooter();
    if (DvhData.d.length == 0) {
      // console.log("DvhDataDoneChk: no DVHs...");
      $("#chart").hide();
      if (typeof(DvhPlot) !== 'undefined') { 
        // console.log("DvhDataDoneChk: destroy DvhPlot...");
        DvhPlot.destroy();
      }
      return;
    }
    var min_dose = DvhData.d[0].d.min_dose;
    var max_dose = 0;
    if (DvhData.d.length == 1  &&  DvhData.d[0].d.Status == 'OK') {
      // console.log("DvhData.d.length == 1");
      $("#RoiInfo").show();
      $("#RoiSelection").show();
      $("#DosePVolSel").show();
      // console.log("DvhDataDoneChk: DvhData.d["+i+"].d.max_volume: "+DvhData.d[0].d.max_volume);
      if ('undefined' !== typeof(DvhData.d[0].d.max_volume)  &&
          DvhData.d[0].d.max_volume > 0) {
        $("#AVolSel").show();
        $("#RoiMaxAbsVol").show();
        $("#RoiMaxAbsVol").text(
          ",  Total Vol: "+DvhData.d[0].d.max_volume.toFixed(2)+" cc");
      }
      $("#RoiDoseInfo").show();
      if (null != DvhData.d[0].d.min_dose  &&
          'undefined' !== typeof(DvhData.d[0].d.min_dose)) {
        $("#RoiMin").text(DvhData.d[0].d.min_dose.toFixed(2));
      } else {
        $("#RoiMin").text("");
      }
      if (null != DvhData.d[0].d.max_dose  &&
          'undefined' !== typeof(DvhData.d[0].d.max_dose)) {
        $("#RoiMax").text(DvhData.d[0].d.max_dose.toFixed(2));
      } else {
        $("#RoiMax").text("");
      }
      if (null != DvhData.d[0].d.dose_file_min_dose  &&
          'undefined' !== typeof(DvhData.d[0].d.dose_file_min_dose)) {
        $("#DoseFileMin").text(DvhData.d[0].d.dose_file_min_dose.toFixed(2));
      } else {
        $("#DoseFileMin").text("");
      }
      if (null != DvhData.d[0].d.dose_file_max_dose  &&
          'undefined' !== typeof(DvhData.d[0].d.dose_file_max_dose)) {
        $("#DoseFileMax").text(DvhData.d[0].d.dose_file_max_dose.toFixed(2));
      } else {
        $("#DoseFileMax").text("");
      }
    } else if (DvhData.d.length > 1) {
      // console.log("DvhData.d.length > 1: "+DvhData.d.length);
      $('<option value="-1">Select ROI</option>').
          appendTo("#RoiSelection");
      $("#RoiInfo").show();
      $("#RoiSelection").show();
    }
    points = [];
    for (var i=0;i<DvhData.d.length;i++) {
      if (DvhData.d[i].d.Status != 'OK') { continue; }
      $("<option value="+i+">"+DvhData.d[i].desc+"</option>").appendTo("#RoiSelection");
      // console.log("DvhDataDoneChk: Adding points for i: "+i+", #: "+DvhData.d[i].d.data.length);
      points.push(DvhData.d[i].d.data);
      if (null != DvhData.d[0].d.min_dose  &&
          'undefined' !== typeof(DvhData.d[0].d.min_dose)  &&
          DvhData.d[i].d.min_dose < min_dose)
        { min_dose = DvhData.d[i].d.min_dose; }
      if (null != DvhData.d[0].d.max_dose  &&
          'undefined' !== typeof(DvhData.d[0].d.max_dose)  &&
          DvhData.d[i].d.max_dose > max_dose)
        { max_dose = DvhData.d[i].d.max_dose; }
    }
    var max_dose_tick = Math.round(max_dose + (max_dose * 0.01));
    var dose_tick_inc = Math.round(max_dose_tick/10);
    var last_tick = 0;
    var dose_ticks = [];
    if (dose_tick_inc > 0  &&  max_dose_tick > 0) {
      for (var i=0;i<=max_dose_tick;i=i+dose_tick_inc) {
        dose_ticks.push(i);
        last_tick = i;
      }
      dose_ticks.push(last_tick+dose_tick_inc);
    }
    series_opts = [];
    for (var i=0;i<DvhData.d.length;i++) {
      if (DvhData.d[i].d.Status != 'OK') { continue; }
      // console.log("DvhDataDoneChk: Adding series color for i: "+i+", "+DvhData.d[i].disp_color);
      series_opts.push({label:DvhData.d[i].desc,color:'#'+DvhData.d[i].disp_color});
    }
    var plot_title = "DVH";
    if (DvhData.d.length == 1  &&  DvhData.d[0].d.Status == 'OK') 
      { plot_title = 'DVH of '+DvhData.d[0].desc; }
    if (typeof(DvhPlot) !== 'undefined') { 
      // console.log("DvhDataDoneChk: destroy DvhPlot...");
      DvhPlot.destroy();
    }
    // console.log("DvhDataDoneChk: Creating DvhPlot, # point arrays: "+points.length);
    DvhPlot = $.jqplot('chart', points , {  

      show:true,
      title:plot_title,
      seriesDefaults:{lineWidth:1,showMarker:false},
      series: series_opts,
      legend:{show:true,location:'nw'},
      axes:{
        xaxis:{
          label:'Dose in Gy',
          labelRenderer: $.jqplot.CanvasAxisLabelRenderer,
          tickOptions:{ formatString:'%.2f Gy' },
          rendererOptions:{ forceTickAt0:true },
          ticks: dose_ticks,
          min:0,
        },
        yaxis:{
          label:'% Volume',
          labelRenderer: $.jqplot.CanvasAxisLabelRenderer,
          tickOptions:{ formatString:'\%d %%' },
          labelOptions:{ angle:-90},
          rendererOptions:{ forceTickAt0:true, forceTickAt100:true },
          min:0,max:100
        }
      },
      cursor: {
        show: true,
        tooltipLocation: 'se'
      },
      canvasOverlay: {
        show: true,
        objects: [
          { verticalLine: {
            name: 'dose',
            show: false,
            x: 0,
            lineWidth: 1,
            xaxis: 'xaxis',
            yminOffset: '0px',
            ymaxOffset: '0px',
            color: 'rgb(100, 0, 0)',
            shadow: false
          }}
        ]
      }
    });
    // DvhPlot.show();
    // console.dir(DvhPlot);
    $("#chart").show();
    DvhPlot.draw();
    // console.log("DvhDataDoneChk: Showing chart...");
  }

  function DvhDataReturned(obj) {
    // alert("DvhDataReturned: "+obj);
    if ('undefined' === typeof(DvhData.d)) { return; }
    for (var i=0;i<DvhData.d.length;i++) {
      // console.log('DvhDataReturned: handing index: '+i+', digest: '+DvhData.d[i].digest+', dvh index: '+DvhData.d[i].dvh_index);
      DvhData.d[i].d = null;
      for (var j=0;j<DvhDataSaved.length;j++) {
        if (DvhData.d[i].dvh_index == DvhDataSaved[j].dvh_index  &&
            DvhData.d[i].digest == DvhDataSaved[j].dose_file_digest) {
          DvhData.d[i].d = DvhDataSaved[j];
          // console.log('Reuseing data for index: '+DvhData.d[i].dvh_index);
          break;
        }
      }
      if (null == DvhData.d[i].d) {
          // console.log('Getting data for index: '+DvhData.d[i].dvh_index);
        DvhData.d[i].ajaxObj =
          new ajaxObject(
            "GetDvhEntryData?obj_path="+ObjPath+
              "&digest="+DvhData.d[i].digest+"&index="+DvhData.d[i].dvh_index,
            function(responseText) {
              var dvh_entry = jQuery.parseJSON(responseText);
              dvh_entry.max_volume = Number(dvh_entry.max_volume);
              if (dvh_entry.Status != 'OK') {
                alert("Error on ROI index: "+
                      dvh_entry.dvh_index+", Error: "+dvh_entry.Error);
              } else {
                DvhDataSaved.push(dvh_entry);
              }
              var index = -1;
              for (var i=0;i<DvhData.d.length;i++) {
                if (DvhData.d[i].dvh_index == dvh_entry.dvh_index &&
                    DvhData.d[i].digest == dvh_entry.dose_file_digest) {
                  index = i;
                  DvhData.d[index].d = dvh_entry;
                  delete DvhData.d[index].ajaxObj;
                }
              }
              if (index == -1) {
                alert("GetDvhEntryData: unexpected response received: "+
                      "DVH index:"+dvh_entry.dvh_index);
                return;
              }
              // alert("GetDvhEntryData::response received: "+index);
              delete dvh_entry;
              DvhDataDoneChk();
            }
          );
        DvhData.d[i].ajaxObj.update("");
      }
    }
    DvhDataDoneChk();
  }
  
  function Update() {
    ClearAndHideFooter();
    // if ('undefined' != typeof(DvhData) && 'undefined' != typeof(DvhData.d))
    //     { DvhData.d.length = 0; }
    DvhData = 
         new PosdaAjaxObj("dvh_info",ObjPath, DvhDataReturned);
  }

  function Init() {
    $("#RoiSelection").change( function(event) {
      var i = $("#RoiSelection").val();
      $("#DoseSel").val("");
      $("#PerVolSel").val("");
      $("#AbsVolSel").val("");
      if (i == -1) {
        $("#DosePVolSel").hide();
        $("#AVolSel").hide();
        return;
      }
      $("#DosePVolSel").show();
      if (DvhData.d[i].d.max_volume > 0) {
        $("#AVolSel").show();
        $("#RoiMaxAbsVol").show();
        $("#RoiMaxAbsVol").text(
          ",  Total Vol: "+DvhData.d[i].d.max_volume.toFixed(2)+" cc");
      } else {
        $("#AVolSel").hide();
        $("RoiMaxAbsVol").hide();
      }
      $("#RoiDoseInfo").show();
      if (null != DvhData.d[i].d.min_dose  &&
          'undefined' !== typeof(DvhData.d[i].d.min_dose)) {
        $("#RoiMin").text(DvhData.d[i].d.min_dose.toFixed(2));
      } else {
        $("#RoiMin").text("");
      }
      if (null != DvhData.d[i].d.max_dose  &&
          'undefined' !== typeof(DvhData.d[i].d.max_dose)) {
        $("#RoiMax").text(DvhData.d[i].d.max_dose.toFixed(2));
      } else {
        $("#RoiMax").text("");
      }
      if (null != DvhData.d[i].d.dose_file_min_dose  &&
          'undefined' !== typeof(DvhData.d[i].d.dose_file_min_dose)) {
        $("#DoseFileMin").text(DvhData.d[i].d.dose_file_min_dose.toFixed(2));
      } else {
        $("#DoseFileMin").text("");
      }
      if (null != DvhData.d[i].d.dose_file_max_dose  &&
          'undefined' !== typeof(DvhData.d[i].d.dose_file_max_dose)) {
        $("#DoseFileMax").text(DvhData.d[i].d.dose_file_max_dose.toFixed(2));
      } else {
        $("#DoseFileMax").text("");
      }
      $("#chart").show();
    });
    $("#DoseSel").change( function(event) {
         // alert('The DoseSel text has changed');
         var i = $("#RoiSelection").val();
         if (i == -1) {
           alert('Please select an ROI.');
           return;
         }
         var d = $("#DoseSel").val();
         // var num_check = new RegExp("^\\s*\\d+(\\.\\d*)+\\s*$");
         // var num_check = new RegExp("^\\d*$");
         // if (!num_check.test(d)) {
           // alert('Dose entered is not a number.');
           // $("#RoiSelection").val("");
           //return;
         // }
         // alert('Dose entered is: '+d);
         var co = DvhPlot.plugins.canvasOverlay;
         var line = co.get('dose');
         line.options.x = d;
         line.options.show = true;
         co.draw(DvhPlot);
         var p_vol = GetPercentVol(i,d);
         // alert('% vol is '+p_vol+' for dose of: '+d);
         $("#PerVolSel").val(p_vol.toFixed(2));
         if (DvhData.d[i].d.max_volume > 0) {
           var a_vol = p_vol*DvhData.d[i].d.max_volume*0.01;
           $("#AbsVolSel").val(a_vol.toFixed(2));
         }
         $("#chart").show();

    });
    $("#PerVolSel").change( function(event) {
         // alert('The PerVolSel text has changed');
         var i = $("#RoiSelection").val();
         if (i == -1) {
           alert('Please select an ROI.');
           return;
         }
         var p_vol = $("#PerVolSel").val();
         if (DvhData.d[i].d.max_volume > 0) {
           var a_vol = p_vol*DvhData.d[i].d.max_volume*0.01;
           $("#AbsVolSel").val(a_vol.toFixed(2));
         }
         var d = GetDose(i,p_vol);
         // alert('Dose is '+d+' for % vol of: '+p_vol);
         $("#DoseSel").val(d.toFixed(2));
         var co = DvhPlot.plugins.canvasOverlay;
         var line = co.get('dose');
         line.options.x = d;
         line.options.show = true;
         co.draw(DvhPlot);
         $("#chart").show();
    });
    $("#AbsVolSel").change( function(event) {
         // alert('The AbsVolSel text has changed');
         var i = $("#RoiSelection").val();
         if (i == -1) {
           alert('Please select an ROI.');
           return;
         }
         if (DvhData.d[i].d.max_volume <= 0) {
           $("#AbsVolSel").val("");
           $("#AVolSel").hide();
           return;
         }
         var a_vol = $("#AbsVolSel").val();
         var p_val = (a_vol/DvhData.d[i].d.max_volume)*100.0;
         $("#PerVolSel").val(p_val.toFixed(2));
         var d = GetDose(i,p_vol);
         // alert('Dose is '+d+' for % vol of: '+p_vol);
         $("#DoseSel").val(d.toFixed(2));
         var co = DvhPlot.plugins.canvasOverlay;
         var line = co.get('dose');
         line.options.x = d;
         line.options.show = true;
         co.draw(DvhPlot);
         $("#chart").show();
    });
    Update();
  }

  $(document).ready(function(){ Init(); }) 

