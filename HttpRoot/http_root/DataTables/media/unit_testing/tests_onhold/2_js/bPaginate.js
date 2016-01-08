/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/2_js/bPaginate.js,v $
   $Date: 2013/01/16 19:10:57 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: js_data
oTest.fnStart( "bPaginate" );

$(document).ready( function () {
	/* Check the default */
	$('#example').dataTable( {
		"aaData": gaaData
	} );
	
	oTest.fnTest( 
		"Pagiantion div exists by default",
		null,
		function () { return document.getElementById('example_paginate') != null; }
	);
	
	oTest.fnTest(
		"Information div takes paging into account",
		null,
		function () { return document.getElementById('example_info').innerHTML == 
			"Showing 1 to 10 of 57 entries"; }
	);
	
	/* Check can disable */
	oTest.fnTest( 
		"Pagiantion can be disabled",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"aaData": gaaData,
				"bPaginate": false
			} );
		},
		function () { return document.getElementById('example_paginate') == null; }
	);
	
	oTest.fnTest(
		"Information div takes paging disabled into account",
		null,
		function () { return document.getElementById('example_info').innerHTML == 
			"Showing 1 to 57 of 57 entries"; }
	);
	
	/* Enable makes no difference */
	oTest.fnTest( 
		"Pagiantion enabled override",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"aaData": gaaData,
				"bPaginate": true
			} );
		},
		function () { return document.getElementById('example_paginate') != null; }
	);
	
	
	
	oTest.fnComplete();
} );