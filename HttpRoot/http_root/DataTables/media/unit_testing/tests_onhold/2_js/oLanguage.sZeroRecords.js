/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/2_js/oLanguage.sZeroRecords.js,v $
   $Date: 2013/01/16 19:10:57 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: js_data
oTest.fnStart( "oLanguage.sZeroRecords" );

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable( {
		"aaData": gaaData
	} );
	var oSettings = oTable.fnSettings();
	
	oTest.fnTest( 
		"Zero records language is 'No matching records found' by default",
		null,
		function () { return oSettings.oLanguage.sZeroRecords == "No matching records found"; }
	);
	
	oTest.fnTest(
		"Text is shown when empty table (after filtering)",
		function () { oTable.fnFilter('nothinghere'); },
		function () { return $('#example tbody tr td')[0].innerHTML == "No matching records found" }
	);
	
	
	
	oTest.fnTest( 
		"Zero records language can be defined",
		function () {
			oSession.fnRestore();
			oTable = $('#example').dataTable( {
				"aaData": gaaData,
				"oLanguage": {
					"sZeroRecords": "unit test"
				}
			} );
			oSettings = oTable.fnSettings();
		},
		function () { return oSettings.oLanguage.sZeroRecords == "unit test"; }
	);
	
	oTest.fnTest(
		"Text is shown when empty table (after filtering)",
		function () { oTable.fnFilter('nothinghere2'); },
		function () { return $('#example tbody tr td')[0].innerHTML == "unit test" }
	);
	
	
	oTest.fnComplete();
} );