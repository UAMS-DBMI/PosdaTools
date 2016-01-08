/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/unit_testing/tests_onhold/1_dom/6776-scrolling-table-grows.js,v $
   $Date: 2013/01/16 19:10:55 $
   $Revision: 1.1 $
 */

// DATA_TEMPLATE: 6776
oTest.fnStart( "Actions on a scrolling table keep width" );


$(document).ready( function () {
	var oTable = $('#example').dataTable( {
        "bFilter": true,
        "bSort": true,
        "sScrollY": "100px",
        "bPaginate": false
	} );
	
	var iWidth = $('div.dataTables_wrapper').width();

	oTest.fnTest( 
		"First sort has no effect on width",
		function () { $('th:eq(1)').click(); },
		function () { return $('div.dataTables_wrapper').width() == iWidth; }
	);

	oTest.fnTest( 
		"Second sort has no effect on width",
		function () { $('th:eq(1)').click(); },
		function () { return $('div.dataTables_wrapper').width() == iWidth; }
	);

	oTest.fnTest( 
		"Third sort has no effect on width",
		function () { $('th:eq(2)').click(); },
		function () { return $('div.dataTables_wrapper').width() == iWidth; }
	);

	oTest.fnTest( 
		"Filter has no effect on width",
		function () { oTable.fnFilter('i'); },
		function () { return $('div.dataTables_wrapper').width() == iWidth; }
	);

	oTest.fnTest( 
		"Filter 2 has no effect on width",
		function () { oTable.fnFilter('in'); },
		function () { return $('div.dataTables_wrapper').width() == iWidth; }
	);

	oTest.fnTest( 
		"No result filter has header and body at same width",
		function () { oTable.fnFilter('xxx'); },
		function () { return $('#example').width() == $('div.dataTables_scrollHeadInner').width(); }
	);

	oTest.fnTest( 
		"Filter with no results has no effect on width",
		function () { oTable.fnFilter('xxx'); },
		function () { return $('div.dataTables_wrapper').width() == iWidth; }
	);

	oTest.fnTest( 
		"Filter with no results has table equal to wrapper width",
		function () { oTable.fnFilter('xxx'); },
		function () { return $('div.dataTables_wrapper').width() == $('#example').width(); }
	);
	
	oTest.fnComplete();
} );