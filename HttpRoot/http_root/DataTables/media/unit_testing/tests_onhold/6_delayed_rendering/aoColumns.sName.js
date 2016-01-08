/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/6_delayed_rendering/aoColumns.sName.js,v $
   $Date: 2013/01/16 19:10:57 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: empty_table
oTest.fnStart( "aoColumns.sName" );

/* This has no effect at all in DOM methods - so we just check that it has applied the name */

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable( {
		"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
		"bDeferRender": true,
		"aoColumns": [
			null,
			null,
			null,
			{ "sName": 'unit test' },
			null
		]
	} );
	var oSettings = oTable.fnSettings();
	
	oTest.fnWaitTest( 
		"Names are stored in the columns object",
		null,
		function () { return oSettings.aoColumns[3].sName =="unit test"; }
	);
	
	
	oTest.fnComplete();
} );