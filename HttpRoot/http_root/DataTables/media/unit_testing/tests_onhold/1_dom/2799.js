/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/2799.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: two_tables
oTest.fnStart( "Initialise two tables" );

$(document).ready( function () {
	$('table.display').dataTable();
	
	oTest.fnTest( 
		"Check that initialisation was okay",
		null,
		function () { return true; }
	);
	
	oTest.fnComplete();
} );