/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/6_delayed_rendering/iDisplayLength.js,v $
   $Date: 2013/01/16 19:10:56 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: empty_table
oTest.fnStart( "iDisplayLength" );

$(document).ready( function () {
	/* Check the default */
	$('#example').dataTable( {
		"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
		"bDeferRender": true
	} );
	
	oTest.fnWaitTest( 
		"Default length is ten",
		null,
		function () { return $('#example tbody tr').length == 10; }
	);
	
	oTest.fnWaitTest( 
		"Select menu shows 10",
		null,
		function () { return $('#example_length select').val() == 10; }
	);
	
	
	oTest.fnWaitTest( 
		"Set initial length to 25",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"bDeferRender": true,
				"iDisplayLength": 25
			} );
		},
		function () { return $('#example tbody tr').length == 25; }
	);
	
	oTest.fnWaitTest( 
		"Select menu shows 25",
		null,
		function () { return $('#example_length select').val() == 25; }
	);
	
	
	oTest.fnWaitTest( 
		"Set initial length to 100",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"bDeferRender": true,
				"iDisplayLength": 100
			} );
		},
		function () { return $('#example tbody tr').length == 57; }
	);
	
	oTest.fnWaitTest( 
		"Select menu shows 25",
		null,
		function () { return $('#example_length select').val() == 100; }
	);
	
	
	oTest.fnWaitTest( 
		"Set initial length to 23 (unknown select menu length)",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"bDeferRender": true,
				"iDisplayLength": 23
			} );
		},
		function () { return $('#example tbody tr').length == 23; }
	);
	
	oTest.fnWaitTest( 
		"Select menu shows 10 (since 23 is unknow)",
		null,
		function () { return $('#example_length select').val() == 10; }
	);
	
	
	oTest.fnComplete();
} );