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
  var ColHdrs = { };
  var DoseFiles;
  var FileDvhMatrix;
  var DvhOptions;
  var oDvhSelTbl;
  var CreateDvhFileButtonHtml = '<input style="position:absolute; right: 20px; top: 11px;" type="button" value="Create DVH File" onClick="CreateDvhFile();" />';
  
  function CreateDvhFile(){
    ns('CreateDvhFile?obj_path='+ObjPath);
  }

  function ToggleDoseShown(v,d,col){
    // console.log('ToggleDoseOn Called: dose: '+d+', col: '+col);
    if (col > 1)
      { col -= 2; }
    else
      { console.log('ToggleDose Called with invalid col: '+col); return; }

    var eles = jQuery('tr', oDvhSelTbl);
    eles.each(function(){
      var pos = oDvhSelTbl.fnGetPosition(this);
      // console.log('ToggleDose: pos: '+pos);
      if (null != pos) {
        var roi = FileDvhMatrix.d[pos];
        ele_id = '_id_R'+pos+'C'+col;
        // console.log('Setting name: '+roi.name+', roi id: '+roi._id+', ele id: '+ele_id);
        var ele = document.getElementById(ele_id);
        if (null != ele) {
          ele.checked=v;
          ns('nrSetDvhSel?obj_path='+ObjPath+'&value='+v+'&dose="'+d+'"&r_id="'+roi._id+'"');
       }
      }
      return true;
    });
  }

  function ToggleDoseAll(v,d,col){
    // console.log('ToggleDoseOn Called: dose: '+d+', col: '+col);
    if (col > 1)
      { col -= 2; }
    else
      { console.log('ToggleDose Called with invalid col: '+col); return; }
    ns('nrSetDoseSel?obj_path='+ObjPath+'&value='+v+'&dose="'+d+'"');
  }

  function ToggleDoseShownOn(d,col){
    ToggleDoseShown(true,d,col);
  }

  function ToggleDoseShownOff(d,col){
    ToggleDoseShown(false,d,col);
  }

  function ToggleDoseAllOn(d,col){
    ToggleDoseAll(true,d,col);
  }

  function ToggleDoseAllOff(d,col){
    ToggleDoseAll(false,d,col);
  }

  function ToggleRoi(v,id){
    // console.log('ToggleRoi Called, id: '+id+', value: '+v);
    var roi;
    for (var ri = 0; ri < FileDvhMatrix.d.length; ri++) {
      roi = FileDvhMatrix.d[ri];
      if (id == roi._id) { break; }
    }
    if (null == roi  ||  id != roi._id) {
      alert('ToggleRoi Called with invalid ROI, id: '+id);
      return;
    }
    // console.log('ToggleDose: setting ROI id: '+roi._id);
    var ele = document.getElementById(roi._id);
    if (null == ele) {
      console.log('ToggleDose: id: '+roi._id+' getElementByID null');
    } else {
      ele.checked = (v ? true : false);
    }
    ns('nrSetRoiSel?obj_path='+ObjPath+'&value='+v+'&r_id="'+id+'"');
    for (var d in roi.doses) {
      if ('undefined' === typeof(roi.doses[d]._id)) { continue; }
      // console.log('ToggleDose: setting id: '+roi.doses[d]._id);
      var ele = document.getElementById(roi.doses[d]._id);
      if (null == ele  ||  'undefined' === typeof(ele)) {
        console.log('ToggleDose: id: '+roi.doses[d]._id+' getElementByID null');
      } else {
        ele.checked = (v ? true : false);
      }
    }
  }

  function ToggleRoiOn(id){
    ToggleRoi(true,id);
  }

  function ToggleRoiOff(id){
    ToggleRoi(false,id);
  }

  function ToggleDvh(v,id,r_id,d,r){
    // console.log('ToggleDvh Called: Id: '+id+', Roi id: '+r_id+', Dose: '+d+' Roi: '+r+', value: '+v);
    document.getElementById(id).checked=(v ? true : false);
    ns('nrSetDvhSel?obj_path='+ObjPath+'&value='+v+'&dose="'+d+'"&r_id="'+r_id+'"');
  }

  function GenerateSelTbl(obj) {
    // alert("DvhDataReturned: "+obj);
    if ('undefined' === typeof(DoseFiles.d)) { return; }
    if ('undefined' === typeof(DoseFiles.d.length)) { return; }
    if ('undefined' === typeof(FileDvhMatrix.d)) { return; }
    if ('undefined' === typeof(FileDvhMatrix.d.length)) { return; }
    if ('undefined' === typeof(DvhOptions.d)) { return; }
    // alert('CanCreateDvhFiles: '+DvhOptions.d.CanCreateDvhFiles);
    if ('undefined' !== typeof(DvhOptions.d.CanCreateDvhFiles)  &&
        DvhOptions.d.CanCreateDvhFiles != 1) 
      { CreateDvhFileButtonHtml = ""; }
    // alert('CanCreateDvhFiles: '+CreateDvhFileButtonHtml);
    if (0 == DoseFiles.d.length  ||
        0 == FileDvhMatrix.d.length) {
      $('#DvhSelect').html('<p>No DVHs</p>'+CreateDvhFileButtonHtml);
      return;
    }
    ColHdrs.d = [ ];
    var hdr = { };
    hdr.sTitle = '      ';
    hdr.sCellType = 'th';
    hdr.sWidth = '70px';
    hdr.bSortable = false;
    hdr.bSerchable = false;
    ColHdrs.d.push(hdr);
    hdr = { };
    hdr.sTitle = 'ROI Name';
    hdr.sCellType = 'th';
    hdr.sWidth = '250px';
    hdr.bSortable = true;
    hdr.bSerchable = true;
    ColHdrs.d.push(hdr);
    var col = 1;
    for (var di = 0; di < DoseFiles.d.length; di++) {
      var dose = DoseFiles.d[di].name;
      col++;
      hdr = { };
      var title = '';
      if ('undefined' !== typeof(DoseFiles.d[di].title)) 
        { title = 'title="'+DoseFiles.d[di].title+'"'; }
      // console.log('Dose File: '+dose);
      hdr.sTitle = '<small><div id="_id_'+dose+'" '+title+' >'+dose+'<br />shown<input type="button" value="on" onclick="ToggleDoseShownOn(\''+dose+'\','+col+')"/><input type="button" value="off" onclick="ToggleDoseShownOff(\''+dose+'\','+col+')"/></div></small>';
      hdr.sCellType = 'th';
      hdr.sWidth = '120px';
      hdr.bSortable = false;
      hdr.bSerchable = false;
      ColHdrs.d.push(hdr);
    }

    $('#DvhSelect').html( '<table cellpadding="0" cellspacing="0" border="0" class="display" id="DvhSelTbl"></table>'+CreateDvhFileButtonHtml);
    oDvhSelTbl = $('#DvhSelTbl').dataTable( {
       "bJQueryUI": true,
       "iDisplayLength": 9,
       "sPaginationType": "full_numbers",
       "bLengthChange": false,
       "bSortClasses": false,
       "aaData": [ ],
       "aoColumns": ColHdrs.d
    } );
    var row_index = 0;
    // console.log('Inserting tbl elements, # rois: '+FileDvhMatrix.d.length);
    // console.log(', # DoseFiles: '+DoseFiles.d.length);
    var rows = [ ];
    for (var ri = 0; ri < FileDvhMatrix.d.length; ri++) {
      var col_index = 0;
      var roi = FileDvhMatrix.d[ri];
      if ('undefined' === typeof(roi._id))  
        { roi._id = '_id_R'+row_index; }
      roi.row_index = row_index;
      // console.log('Roi: '+roi.name+' sel: '+roi.sel);
      //console.dir(roi);
      var row = [ ];
      row.push('<div style="text-align:left"><input type="button" value="on" onclick="ToggleRoiOn(\''+roi._id+'\')"/><input type="button" value="off" onclick="ToggleRoiOff(\''+roi._id+'\')"/></div>');
      row.push('<div style="text-align:left">'+roi.name+'</div>');
      for (var di = 0; di < DoseFiles.d.length; di++) {
        var dose = DoseFiles.d[di].name;
        if (dose in roi.doses) {
          var ele = roi.doses[dose];
          ele._id = '_id_R'+ri+'C'+col_index;
          // console.log('Adding cell with id: '+ele._id+'.');
          var sel = '';
          if (ele.sel == 1) { sel = 'checked="checked"'; }
          row.push('<div style="text-align:center;background-color: #'+ele.color+'"><input id="'+ele._id+'" type="checkbox" '+sel+' onclick="ToggleDvh(this.checked,\''+ele._id+'\',\''+roi._id+'\',\''+dose+'\',\''+roi.name+'\')" /></div>');
        } else {
          row.push(' ');
          // console.log('No cell with id: _id_R'+row_index+'C'+col_index+'.');
        }
        col_index++;
      }
      // console.log('Inserting row: '+row_index);
      // console.dir(row);
      rows.push(row);
      // console.log('Inserting row: '+row_index+'  Done...');
      row_index++;
    }
    oDvhSelTbl.fnAddData(rows);
    if ('undefined' !== typeof(DvhOptions.d.Filter)  &&
        DvhOptions.d.Filter != "") { 
      oDvhSelTbl.fnFilter(DvhOptions.d.Filter);
    }
  }

  function Update() {
    // alert('Update Called.');
    DoseFiles = new PosdaAjaxObj("DoseFiles",ObjPath, GenerateSelTbl);
    FileDvhMatrix = new PosdaAjaxObj("FileDvhMatrix",ObjPath, GenerateSelTbl);
    DvhOptions = new PosdaAjaxObj("DvhOptions",ObjPath, GenerateSelTbl);
  }

  function Init() {
    Update();
  }

  $(document).ready(function(){ Init(); }) 

