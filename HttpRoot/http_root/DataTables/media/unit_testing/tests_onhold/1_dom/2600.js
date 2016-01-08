/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/2600.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "2600 - Display rewind when changing length" );

$(document).ready( function () {
	$('#example').dataTable();
	
	oTest.fnTest( 
		"Info correct on init",
		null,
		function () { return $('#example_info').html() == "Showing 1 to 10 of 57 entries"; }
	);
	
	oTest.fnTest( 
		"Page 2",
		function () { $('#example_next').click(); },
		function () { return $('#example_info').html() == "Showing 11 to 20 of 57 entries"; }
	);
	
	oTest.fnTest( 
		"Page 3",
		function () { $('#example_next').click(); },
		function () { return $('#example_info').html() == "Showing 21 to 30 of 57 entries"; }
	);
	
	oTest.fnTest( 
		"Page 4",
		function () { $('#example_next').click(); },
		function () { return $('#example_info').html() == "Showing 31 to 40 of 57 entries"; }
	);
	
	oTest.fnTest( 
		"Page 5",
		function () { $('#example_next').click(); },
		function () { return $('#example_info').html() == "Showing 41 to 50 of 57 entries"; }
	);
	
	oTest.fnTest( 
		"Rewind",
		function () { $('#example_length select').val('100'); $('#example_length select').change(); },
		function () { return $('#example_info').html() == "Showing 1 to 57 of 57 entries"; }
	);
	
	oTest.fnComplete();
} );