/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/bJQueryUI.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dom_data
oTest.fnStart( "bJQueryUI" );

$(document).ready( function () {
	$('#example').dataTable( {
		"bJQueryUI": true
	} );
	
	oTest.fnTest( 
		"Header elements are fully wrapped by DIVs",
		null,
		function () {
			var test = true;
			$('#example thead th').each( function () {
				if ( this.childNodes > 1 ) {
					test = false;
				}
			} );
			return test;
		}
	);
	
	oTest.fnTest( 
		"One div for each header element",
		null,
		function () {
			return $('#example thead th div').length == 5;
		}
	);
	
	oTest.fnTest( 
		"One span for each header element, nested as child of div",
		null,
		function () {
			return $('#example thead th div>span').length == 5;
		}
	);
	
	oTest.fnComplete();
} );