/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/bInfo.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "bInfo" );

$(document).ready( function () {
	/* Check the default */
	$('#example').dataTable();
	
	oTest.fnTest( 
		"Info div exists by default",
		null,
		function () { return document.getElementById('example_info') != null; }
	);
	
	/* Check can disable */
	oTest.fnTest( 
		"Info can be disabled",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"bInfo": false
			} );
		},
		function () { return document.getElementById('example_info') == null; }
	);
	
	/* Enable makes no difference */
	oTest.fnTest( 
		"Info enabled override",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"bInfo": true
			} );
		},
		function () { return document.getElementById('example_info') != null; }
	);
	
	
	oTest.fnComplete();
} );