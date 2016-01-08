/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/4_server-side/fnRowCallback.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: empty_table
oTest.fnStart( "fnRowCallback" );

/* Note - fnRowCallback MUST return the first arguments (modified or not) */

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable( {
		"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php"
	} );
	var oSettings = oTable.fnSettings();
	var mPass;
	
	oTest.fnWaitTest( 
		"Default should be null",
		null,
		function () { return oSettings.fnRowCallback == null; }
	);
	
	
	oTest.fnWaitTest( 
		"Four arguments passed",
		function () {
			oSession.fnRestore();
			
			mPass = -1;
			$('#example').dataTable( {
				"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php",
				"fnRowCallback": function ( nTr ) {
					mPass = arguments.length;
					return nTr;
				}
			} );
		},
		function () { return mPass == 4; }
	);
	
	
	oTest.fnWaitTest( 
		"fnRowCallback called once for each drawn row",
		function () {
			oSession.fnRestore();
			
			mPass = 0;
			$('#example').dataTable( {
				"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php",
				"fnRowCallback": function ( nTr, asData, iDrawIndex, iDataIndex ) {
					mPass++;
					return nTr;
				}
			} );
		},
		function () { return mPass == 10; }
	);
	
	oTest.fnWaitTest( 
		"fnRowCallback allows us to alter row information",
		function () {
			oSession.fnRestore();
			$('#example').dataTable( {
				"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php",
				"fnRowCallback": function ( nTr, asData, iDrawIndex, iDataIndex ) {
					$(nTr).addClass('unit_test');
					return nTr;
				}
			} );
		},
		function () { return $('#example tbody tr:eq(1)').hasClass('unit_test'); }
	);
	
	oTest.fnWaitTest( 
		"Data array has length matching columns",
		function () {
			oSession.fnRestore();
			
			mPass = true;
			$('#example').dataTable( {
				"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php",
				"fnRowCallback": function ( nTr, asData, iDrawIndex, iDataIndex ) {
					if ( asData.length != 5 )
						mPass = false;
					return nTr;
				}
			} );
		},
		function () { return mPass; }
	);
	
	oTest.fnWaitTest( 
		"Data array has length matching columns",
		function () {
			oSession.fnRestore();
			
			mPass = true;
			var iCount = 0;
			$('#example').dataTable( {
				"bServerSide": true,
		"sAjaxSource": "../../../examples/server_side/scripts/server_processing.php",
				"fnRowCallback": function ( nTr, asData, iDrawIndex, iDataIndex ) {
					if ( iCount != iDrawIndex )
						mPass = false;
					iCount++;
					return nTr;
				}
			} );
		},
		function () { return mPass; }
	);
	
	
	
	oTest.fnComplete();
} );