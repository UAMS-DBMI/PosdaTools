/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/2840-restore-table-width.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "2840 - Restore table width on fnDestroy" );

$(document).ready( function () {
	document.cookie = "";
	$('#example').dataTable( {
		"sScrollX": "100%",
		"sScrollXInner": "110%"
	} );
	$('#example').dataTable().fnDestroy();
	
	oTest.fnTest( 
		"Width after destroy",
		null,
		function () { return $('#example').width() == "800"; }
	);
	
	oTest.fnComplete();
} );