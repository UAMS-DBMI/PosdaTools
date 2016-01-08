/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/bFilter.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "bFilter" );

$(document).ready( function () {
	/* Check the default */
	$('#example').dataTable();
	
	oTest.fnTest( 
		"Filtering div exists by default",
		null,
		function () { return document.getElementById('example_filter') != null; }
	);
	
	/* Check can disable */
	oTest.fnTest( 
		"Fltering can be disabled",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"bFilter": false
			} );
		},
		function () { return document.getElementById('example_filter') == null; }
	);
	
	/* Enable makes no difference */
	oTest.fnTest( 
		"Filtering enabled override",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"bFilter": true
			} );
		},
		function () { return document.getElementById('example_filter') != null; }
	);
	
	
	oTest.fnComplete();
} );