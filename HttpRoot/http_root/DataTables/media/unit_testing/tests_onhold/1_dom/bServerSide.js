/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/bServerSide.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "bServerSide" );

/* Not interested in server-side processing here other than to check that it is off */

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable();
	var oSettings = oTable.fnSettings();
	
	oTest.fnTest( 
		"Server side is off by default",
		null,
		function () { return oSettings.oFeatures.bServerSide == false; }
	);
	
	oTest.fnComplete();
} );