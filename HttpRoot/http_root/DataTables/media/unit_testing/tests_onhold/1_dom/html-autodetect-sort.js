/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/html-autodetect-sort.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: html_table
oTest.fnStart( "HTML auto detect" );

$(document).ready( function () {
	var oTable = $('#example').dataTable();
	
	oTest.fnTest( 
		"Initial sort",
		null,
		function () {
			var ret =
				$('#example tbody tr:eq(0) td:eq(0)').html() == '1' &&
				$('#example tbody tr:eq(1) td:eq(0)').html() == '2' &&
				$('#example tbody tr:eq(2) td:eq(0)').html() == '3';
			return ret;
		}
	);
	
	oTest.fnTest( 
		"HTML sort",
		function () { $('#example thead th:eq(1)').click() },
		function () {
			var ret =
				$('#example tbody tr:eq(0) td:eq(0)').html() == '2' &&
				$('#example tbody tr:eq(1) td:eq(0)').html() == '1' &&
				$('#example tbody tr:eq(2) td:eq(0)').html() == '4';
			return ret;
		}
	);
	
	oTest.fnTest( 
		"HTML reverse sort",
		function () { $('#example thead th:eq(1)').click() },
		function () {
			var ret =
				$('#example tbody tr:eq(0) td:eq(0)').html() == '3' &&
				$('#example tbody tr:eq(1) td:eq(0)').html() == '4' &&
				$('#example tbody tr:eq(2) td:eq(0)').html() == '1';
			return ret;
		}
	);
	
	oTest.fnTest( 
		"Numeric sort",
		function () { $('#example thead th:eq(0)').click() },
		function () {
			var ret =
				$('#example tbody tr:eq(0) td:eq(0)').html() == '1' &&
				$('#example tbody tr:eq(1) td:eq(0)').html() == '2' &&
				$('#example tbody tr:eq(2) td:eq(0)').html() == '3';
			return ret;
		}
	);
	
	
	oTest.fnComplete();
} );