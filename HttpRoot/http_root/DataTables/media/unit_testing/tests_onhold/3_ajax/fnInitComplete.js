/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/3_ajax/fnInitComplete.js,v $
   $Date: 2013/01/16 19:10:56 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: empty_table
oTest.fnStart( "fnInitComplete" );

/* Fairly boring function compared to the others! */

$(document).ready( function () {
	/* Check the default */
	var oTable = $('#example').dataTable( {
		"sAjaxSource": "../../../examples/ajax/sources/arrays.txt"
	} );
	var oSettings = oTable.fnSettings();
	var mPass;
	
	oTest.fnWaitTest( 
		"Default should be null",
		null,
		function () { return oSettings.fnInitComplete == null; }
	);
	
	
	oTest.fnWaitTest( 
		"Two arguments passed (for Ajax!)",
		function () {
			oSession.fnRestore();
			
			mPass = -1;
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"fnInitComplete": function ( ) {
					mPass = arguments.length;
				}
			} );
		},
		function () { return mPass == 2; }
	);
	
	
	oTest.fnWaitTest( 
		"That one argument is the settings object",
		function () {
			oSession.fnRestore();
			
			oTable = $('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"fnInitComplete": function ( oSettings ) {
					mPass = oSettings;
				}
			} );
		},
		function () { return oTable.fnSettings() == mPass; }
	);
	
	
	oTest.fnWaitTest( 
		"fnInitComplete called once on first draw",
		function () {
			oSession.fnRestore();
			
			mPass = 0;
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"fnInitComplete": function ( ) {
					mPass++;
				}
			} );
		},
		function () { return mPass == 1; }
	);
	
	oTest.fnWaitTest( 
		"fnInitComplete never called there after",
		function () {
			$('#example_next').click();
			$('#example_next').click();
			$('#example_next').click();
		},
		function () { return mPass == 1; }
	);
	
	
	oTest.fnWaitTest( 
		"10 rows in the table on complete",
		function () {
			oSession.fnRestore();
			
			mPass = 0;
			$('#example').dataTable( {
				"sAjaxSource": "../../../examples/ajax/sources/arrays.txt",
				"fnInitComplete": function ( ) {
					mPass = $('#example tbody tr').length;
				}
			} );
		},
		function () { return mPass == 10; }
	);
	
	
	
	oTest.fnComplete();
} );