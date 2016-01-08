/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/src/ext/ext.sorting.js,v $
   $Date: 2013/01/16 19:10:57 $
   $Revision: 1.1 $
 */


$.extend( DataTable.ext.oSort, {
	/*
	 * text sorting
	 */
	"string-pre": function ( a )
	{
		if ( typeof a != 'string' ) {
			a = (a !== null && a.toString) ? a.toString() : '';
		}
		return a.toLowerCase();
	},

	"string-asc": function ( x, y )
	{
		return ((x < y) ? -1 : ((x > y) ? 1 : 0));
	},
	
	"string-desc": function ( x, y )
	{
		return ((x < y) ? 1 : ((x > y) ? -1 : 0));
	},
	
	
	/*
	 * html sorting (ignore html tags)
	 */
	"html-pre": function ( a )
	{
		return a.replace( /<.*?>/g, "" ).toLowerCase();
	},
	
	"html-asc": function ( x, y )
	{
		return ((x < y) ? -1 : ((x > y) ? 1 : 0));
	},
	
	"html-desc": function ( x, y )
	{
		return ((x < y) ? 1 : ((x > y) ? -1 : 0));
	},
	
	
	/*
	 * date sorting
	 */
	"date-pre": function ( a )
	{
		var x = Date.parse( a );
		
		if ( isNaN(x) || x==="" )
		{
			x = Date.parse( "01/01/1970 00:00:00" );
		}
		return x;
	},

	"date-asc": function ( x, y )
	{
		return x - y;
	},
	
	"date-desc": function ( x, y )
	{
		return y - x;
	},
	
	
	/*
	 * numerical sorting
	 */
	"numeric-pre": function ( a )
	{
		return (a=="-" || a==="") ? 0 : a*1;
	},

	"numeric-asc": function ( x, y )
	{
		return x - y;
	},
	
	"numeric-desc": function ( x, y )
	{
		return y - x;
	}
} );
