/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/sAjaxSource.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "sAjaxSource" );

/* Not interested in ajax source here other than to check it's default */

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable();
	var oSettings = oTable.fnSettings();
	
	oTest.fnTest( 
		"Server side is off by default",
		null,
		function () { return oSettings.sAjaxSource == null; }
	);
	
	oTest.fnComplete();
} );