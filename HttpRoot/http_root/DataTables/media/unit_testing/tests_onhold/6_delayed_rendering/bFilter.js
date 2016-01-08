/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/6_delayed_rendering/bFilter.js,v $
   $Date: 2013/01/16 19:10:56 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: empty_table
oTest.fnStart( "bFilter" );

$(document).ready( function () {
	/* Check the default */
	$('#example').dataTable( {
		"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
		"bDeferRender": true
	} );
	
	oTest.fnWaitTest( 
		"Filtering div exists by default",
		null,
		function () { return document.getElementById('example_filter') != null; }
	);
	
	/* Check can disable */
	oTest.fnWaitTest( 
		"Fltering can be disabled",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"bDeferRender": true,
				"bFilter": false
			} );
		},
		function () { return document.getElementById('example_filter') == null; }
	);
	
	/* Enable makes no difference */
	oTest.fnWaitTest( 
		"Filtering enabled override",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"bDeferRender": true,
				"bFilter": true
			} );
		},
		function () { return document.getElementById('example_filter') != null; }
	);
	
	
	oTest.fnComplete();
} );