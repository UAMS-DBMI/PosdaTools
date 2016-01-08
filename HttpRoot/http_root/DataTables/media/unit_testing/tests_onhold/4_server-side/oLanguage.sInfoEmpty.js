/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/4_server-side/oLanguage.sInfoEmpty.js,v $
   $Date: 2013/01/16 19:10:56 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: empty_table
oTest.fnStart( "oLanguage.sInfoEmpty" );

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable( {
		"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php"
	} );
	var oSettings = oTable.fnSettings();
	
	oTest.fnWaitTest( 
		"Info empty language is 'Showing 0 to 0 of 0 entries' by default",
		function () { oTable.fnFilter("nothinghere"); },
		function () { return oSettings.oLanguage.sInfoEmpty == "Showing 0 to 0 of 0 entries"; }
	);
	
	oTest.fnWaitTest( 
		"Info empty language default is in the DOM",
		null,
		function () {
			var bReturn = document.getElementById('example_info').innerHTML.replace( 
				' '+oSettings.oLanguage.sInfoFiltered.replace( '_MAX_', '57' ), "" ) ==
					"Showing 0 to 0 of 0 entries";
			return bReturn;
		}
	);
	
	
	oTest.fnWaitTest( 
		"Info empty language can be defined",
		function () {
			oSession.fnRestore();
			oTable = $('#example').dataTable( {
				"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php",
				"oLanguage": {
					"sInfoEmpty": "unit test"
				}
			} );
			oSettings = oTable.fnSettings();
			oTable.fnFilter("nothinghere");
		},
		function () { return oSettings.oLanguage.sInfoEmpty == "unit test"; }
	);
	
	oTest.fnWaitTest( 
		"Info empty language default is in the DOM",
		null,
		function () {
			var bReturn = document.getElementById('example_info').innerHTML.replace( 
				' '+oSettings.oLanguage.sInfoFiltered.replace( '_MAX_', '57' ), "" ) ==
					"unit test";
			return bReturn;
		}
	);
	
	
	oTest.fnWaitTest( 
		"Macro's replaced",
		function () {
			oSession.fnRestore();
			oTable = $('#example').dataTable( {
				"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php",
				"oLanguage": {
					"sInfoEmpty": "unit _START_ _END_ _TOTAL_ test"
				}
			} );
			oTable.fnFilter("nothinghere");
		},
		function () {
			var bReturn = document.getElementById('example_info').innerHTML.replace( 
				' '+oSettings.oLanguage.sInfoFiltered.replace( '_MAX_', '57' ), "" ) ==
					"unit 1 0 0 test";
			return bReturn;
		}
	);
	
	
	oTest.fnComplete();
} );