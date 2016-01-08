/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/2530.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: dymanic_table
oTest.fnStart( "2530 - Check width's when dealing with empty strings" );


$(document).ready( function () {
	$('#example').dataTable( {
		"aaData": [
			['','Internet Explorer 4.0','Win 95+','4','X'],
			['','Internet Explorer 5.0','Win 95+','5','C']
		],
		"aoColumns": [
			{ "sTitle": "", "sWidth": "40px" },
			{ "sTitle": "Browser" },
			{ "sTitle": "Platform" },
			{ "sTitle": "Version", "sClass": "center" },
			{ "sTitle": "Grade", "sClass": "center" }
		]
	} );
	
	/* Basic checks */
	oTest.fnTest( 
		"Check calculated widths",
		null,
		function () { return $('#example tbody tr td:eq(0)').width() < 100; }
	);
	
	
	oTest.fnComplete();
} );