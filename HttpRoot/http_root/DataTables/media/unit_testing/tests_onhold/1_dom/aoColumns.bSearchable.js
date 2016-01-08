/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/aoColumns.bSearchable.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "aoColumns.bSeachable" );

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable();
	var oSettings = oTable.fnSettings();
	
	oTest.fnTest( 
		"Columns are searchable by default",
		function () { oTable.fnFilter("Camino"); },
		function () { return $('#example tbody tr:eq(0) td:eq(1)').html().match(/Camino/); }
	);
	
	oTest.fnTest( 
		"Disabling sorting on a column removes it from the global filter",
		function () {
			oSession.fnRestore();
			oTable = $('#example').dataTable( {
				"aoColumns": [
					null,
					{ "bSearchable": false },
					null,
					null,
					null
				]
			} );
			oSettings = oTable.fnSettings();
			oTable.fnFilter("Camino");
		},
		function () { return $('#example tbody tr:eq(0) td:eq(0)').html() == "No matching records found"; }
	);
	
	oTest.fnTest( 
		"Disabled on one column has no effect on other columns",
		function () { oTable.fnFilter("Webkit"); },
		function () { return $('#example tbody tr:eq(0) td:eq(0)').html() == "Webkit"; }
	);
	
	oTest.fnTest( 
		"Disable filtering on multiple columns",
		function () {
			oSession.fnRestore();
			oTable = $('#example').dataTable( {
				"aoColumns": [
					{ "bSearchable": false },
					{ "bSearchable": false },
					null,
					null,
					null
				]
			} );
			oSettings = oTable.fnSettings();
			oTable.fnFilter("Webkit");
		},
		function () { return $('#example tbody tr:eq(0) td:eq(0)').html() == "No matching records found"; }
	);
	
	oTest.fnTest( 
		"Filter on second disabled column",
		function () { oTable.fnFilter("Camino"); },
		function () { return $('#example tbody tr:eq(0) td:eq(0)').html() == "No matching records found"; }
	);
	
	
	oTest.fnComplete();
} );