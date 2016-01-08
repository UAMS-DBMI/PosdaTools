/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/3_ajax/fnServerData.js,v $
   $Date: 2013/01/16 19:10:56 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: empty_table
oTest.fnStart( "fnServerData for Ajax sourced data" );

$(document).ready( function () {
	var mPass;
	
	oTest.fnTest( 
		"Argument length",
		function () {
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"fnServerData": function () {
					mPass = arguments.length;
				}
			} );
		},
		function () { return mPass == 4; }
	);
	
	oTest.fnTest( 
		"Url",
		function () {
			$('#example').dataTable( {
				"bDestroy": true,
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"fnServerData": function (sUrl, aoData, fnCallback, oSettings) {
					mPass = sUrl == "../../../examples/ajax/sources/arrays.txt";
				}
			} );
		},
		function () { return mPass; }
	);
	
	oTest.fnTest( 
		"Data array",
		function () {
			$('#example').dataTable( {
				"bDestroy": true,
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"fnServerData": function (sUrl, aoData, fnCallback, oSettings) {
					mPass = aoData.length==0;
				}
			} );
		},
		function () { return mPass; }
	);
	
	oTest.fnTest( 
		"Callback function",
		function () {
			$('#example').dataTable( {
				"bDestroy": true,
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"fnServerData": function (sUrl, aoData, fnCallback, oSettings) {
					mPass = typeof fnCallback == 'function';
				}
			} );
		},
		function () { return mPass; }
	);
	
	
	oTest.fnComplete();
} );