/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/2530-2.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "User given with is left when no scrolling" );

$(document).ready( function () {
	$('#example')[0].style.width = "80%";
	$('#example').dataTable();
	
	oTest.fnTest( 
		"Check user width is left",
		null,
		function () { return $('#example').width() == 640; }
	);
	
	oTest.fnComplete();
} );