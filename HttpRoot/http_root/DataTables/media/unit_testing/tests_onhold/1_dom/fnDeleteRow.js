/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/fnDeleteRow.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "fnDeleteRow" );

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable();
	var oSettings = oTable.fnSettings();
	
	oTest.fnTest( 
		"Check that the default data is sane",
		null,
		function () { return oSettings.asDataSearch.join(' ').match(/4.0/g).length == 3; }
	);
	
	oTest.fnTest( 
		"Remove the first data row, and check that hte search data has been updated",
		function () { oTable.fnDeleteRow( 0 ); },
		function () { return oSettings.asDataSearch.join(' ').match(/4.0/g).length == 2; }
	);
	
	oTest.fnTest( 
		"Check that the info element has been updated",
		null,
		function () { return $('#example_info').html() == "Showing 1 to 10 of 56 entries"; }
	);
	
	
	
	oTest.fnComplete();
} );