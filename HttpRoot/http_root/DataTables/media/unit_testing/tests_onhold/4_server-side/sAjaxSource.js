/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/4_server-side/sAjaxSource.js,v $
   $Date: 2013/01/16 19:10:56 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: empty_table
oTest.fnStart( "sAjaxSource" );

/* Sanitfy check really - all the other tests blast this */

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable( {
		"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php"
	} );
	var oSettings = oTable.fnSettings();
	
	oTest.fnWaitTest( 
		"Server side is off by default",
		null,
		function () { 
			return oSettings.sAjaxSource == "../../../examples/server_side/scripts/server_processing.php";
		}
	);
	
	oTest.fnComplete();
} );