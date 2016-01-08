/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/aoColumns.sName.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "aoColumns.sName" );

/* This has no effect at all in DOM methods - so we just check that it has applied the name */

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable( {
		"aoColumns": [
			null,
			null,
			null,
			{ "sName": 'unit test' },
			null
		]
	} );
	var oSettings = oTable.fnSettings();
	
	oTest.fnTest( 
		"Names are stored in the columns object",
		null,
		function () { return oSettings.aoColumns[3].sName =="unit test"; }
	);
	
	
	oTest.fnComplete();
} );