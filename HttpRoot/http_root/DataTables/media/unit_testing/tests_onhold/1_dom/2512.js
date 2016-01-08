/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/2512.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: 2512
oTest.fnStart( "Check filtering with BR and HTML entity" );


$(document).ready( function () {
	$('#example').dataTable();
	
	/* Basic checks */
	oTest.fnTest( 
		"Check filtering",
		function () { $('#example').dataTable().fnFilter('testsearchstring'); },
		function () { return $('#example tbody tr').length == 1; }
	);
	
	
	oTest.fnComplete();
} );