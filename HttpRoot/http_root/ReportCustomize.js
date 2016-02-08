  var ColHdrs = { };
  var CutPoints;
  var iterations = 1;
  var oCutPointTable;
  var theUrl;
  var ret;

  function GenerateCpTbl(obj){
    iterations += 1;
    if ('undefined' === typeof(CutPoints.d)) { return; }
    if ('undefined' === typeof(CutPoints.d.length)) { return; }
    if (0 == CutPoints.d.length) {
      document.write("<p>No CutPoints defined</p>");
      return;
    }
    var thead = '<tr><th>'+
      '</th><th>Caption'+
      '</th><th>Format'+
      '</th><th>Type'+
      '</th><th>Parm</th><th>Op</th></tr>';
    
    var body = '';
    for (var ri = 0; ri < CutPoints.d.length; ri++){
      var efi = CutPoints.d[ri].orig_index;
      var caption = '<input type=text onBlur="'+
        'ChangeCutPointProtocol('+efi+',this.value);" value="'+
        CutPoints.d[ri].caption+'">';
      var ent_type = EntType(ri,efi);
      var ent_parm = EntParm(ri,efi);
      body = body+'<tr '+
        'data-position="'+ri+'" '+
        'id="cut_points_'+ri+'">'+
        '<td>'+ri+
        '</td><td>'+caption+
        '</td><td>'+CutPoints.d[ri].format+
        '</td><td>'+ent_type+
        '</td><td>'+ent_parm+'</td><td>'+
        '<input type="submit" onClick="InsertCutPoint('+ri+','+efi+');"'+
        ' value="+"><input type="submit" onClick="DeleteCutPoint('+ri+','+
        efi+');" value="-"></td>'+
        '</tr>';
    }
    $('#ReportCustomize').html(
       '<table cellpadding="0" cellspacing="0" border="0" ' +
       'class="display" id="CutPointTable">' +
       '<thead>'+thead+'</thead>' +
       '<tbody>'+body+'</tbody>' +
       '</table>' );
    oCutPointTable = $('#CutPointTable').dataTable(
       {
         "bJQueryUI": true,
         "iDisplayLength": CutPoints.d.length,
         "bLengthChange": false,
         "bDeferRender": false,
         "bSortClasses": true,
         "bInfo" : false,
         "bFilter": false
      } 
    ).rowReordering( {
        sURL: theUrl.d[0],
        sRequestType: "GET"
    } );
  }
  function DeleteCutPoint(ri, efi){
    ns('DeleteCutPoint?obj_path='+ObjPath+'&index='+ri+'&eff_ind='+efi);
  }
  function InsertCutPoint(ri, efi){
    ns('AddCutPoint?obj_path='+ObjPath+'&index='+ri+'&eff_ind='+efi);
  }
  function EntType(ri, efi){
    var ent_type = ['Total Volume', 'Dose Maximum', 'Dose Minimum',
      'Dose Average', 'Dose at Volume Percentile', 'Percent Prescription', 
      'Absolute Dose Level', 'Percent Volume at Dose', 
      'Percent Volume at Percent Prescription', 'Prescription Dose'];
    var ent = '<select onChange="+ChangeEntType('+ri+','+efi+','+
      'this.options[this.selectedIndex].value);">';
    for (var ei = 0; ei < ent_type.length; ei++){
      ent = ent + '<option value="'+ei+'"';
//      console.log('ri: '+ri+', efi: '+efi+', formula: "'+
//        CutPoints.d[ri].formula+'", sel: '+ent_type[ei]);
      if(
        CutPoints.d[ri].formula == 'TotalVolume' &&
        ent_type[ei] == 'Total Volume'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].formula == 'DoseMaximum' &&
        ent_type[ei] == 'Dose Maximum'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].formula == 'DoseMinimum' &&
        ent_type[ei] == 'Dose Minimum'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].formula == 'DoseAverage' &&
        ent_type[ei] == 'Dose Average'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].formula.type == 'DosePercentile' &&
        ent_type[ei] == 'Dose at Volume Percentile'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].type == 'dose' &&
        CutPoints.d[ri].formula.type == 'PercentPrescription' &&
        ent_type[ei] == 'Percent Prescription'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].type == 'PercentVolume' &&
        CutPoints.d[ri].formula.type == 'PercentPrescription' &&
        ent_type[ei] == 'Percent Volume at Percent Prescription'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].formula == 'PrescriptionDose' &&
        ent_type[ei] == 'Prescription Dose'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].type == 'dose' &&
        CutPoints.d[ri].formula.type == 'DoseLevel' &&
        ent_type[ei] == 'Absolute Dose Level'
      ){ ent = ent+' selected'; }
      if(
        CutPoints.d[ri].type == 'PercentVolume' &&
        CutPoints.d[ri].formula.type == 'AbsoluteDose' &&
        ent_type[ei] == 'Percent Volume at Dose'
      ){ ent = ent+' selected'; }
      ent = ent + '>'+ent_type[ei]+'</option>';
    }
    return ent+'</select>';
  }
  function ChangeEntType(ri, efi, val){
    ns('ChangeEntType?obj_path='+ObjPath+'&index='+ri+'&eff_ind='+efi+'&val='+val);
  }
  function EntParm(ri, efi){
//    console.log('ri: '+ri+' formula.type: '+CutPoints.d[ri].formula.type);
    if(
      CutPoints.d[ri].formula.type == 'DosePercentile'
    ){
      return '<input type=text onBlur="'+
        'ChangeCutPointParm('+efi+',this.value);" value="'+
        CutPoints.d[ri].formula.percent+'">';
    } else if(
      CutPoints.d[ri].type == 'dose' &&
      CutPoints.d[ri].formula.type == 'PercentPrescription'
    ){
      return '<input type=text onBlur="'+
        'ChangeCutPointParm('+efi+',this.value);" value="'+
        CutPoints.d[ri].formula.PercentPrescription+'">';
    } else if(
      CutPoints.d[ri].type == 'PercentVolume' &&
      CutPoints.d[ri].formula.type == 'PercentPrescription'
    ){
      return '<input type=text onBlur="'+
        'ChangeCutPointParm('+efi+',this.value);" value="'+
        CutPoints.d[ri].formula.percent+'">';
    } else if(
      CutPoints.d[ri].type == 'dose' &&
      CutPoints.d[ri].formula.type == 'DoseLevel'
    ){
      return '<input type=text onBlur="'+
        'ChangeCutPointParm('+efi+',this.value);" value="'+
        CutPoints.d[ri].formula.dose_level+'">';
    } else if(
      CutPoints.d[ri].type == 'PercentVolume' &&
      CutPoints.d[ri].formula.type == 'AbsoluteDose'
    ){
      return '<input type=text onBlur="'+
        'ChangeCutPointParm('+efi+',this.value);" value="'+
        CutPoints.d[ri].formula.level+'">';
    } else {
      return '--';
    }
  }
  function ChangeCutPointParm(ind, val){
    ns('ChangeParam?obj_path='+ObjPath+'&index='+ind+'&val='+val);
  }
  function PrintUrl(obj){ 
  }
  function ChangeCutPointProtocol(ind, val){ 
    ns('ChangeCaption?obj_path='+ObjPath+'&index='+ind+'&val='+val);
  }

  function Update() {
    theUrl = new PosdaAjaxObj("UpdateUrl", ObjPath, PrintUrl);
    CutPoints = new PosdaAjaxObj("CutPointDefs",ObjPath, GenerateCpTbl);
  }

  $(document).ready(function(){
    Update(); 
  });

