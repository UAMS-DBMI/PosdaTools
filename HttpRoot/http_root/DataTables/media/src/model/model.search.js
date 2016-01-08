/* $Source: /home/bbennett/pass/archive/HttpRoot/http_root/DataTables/media/src/model/model.search.js,v $
   $Date: 2013/01/16 19:10:57 $
   $Revision: 1.1 $
 */




/**
 * Template object for the way in which DataTables holds information about
 * search information for the global filter and individual column filters.
 *  @namespace
 */
DataTable.models.oSearch = {
	/**
	 * Flag to indicate if the filtering should be case insensitive or not
	 *  @type boolean
	 *  @default true
	 */
	"bCaseInsensitive": true,

	/**
	 * Applied search term
	 *  @type string
	 *  @default <i>Empty string</i>
	 */
	"sSearch": "",

	/**
	 * Flag to indicate if the search term should be interpreted as a
	 * regular expression (true) or not (false) and therefore and special
	 * regex characters escaped.
	 *  @type boolean
	 *  @default false
	 */
	"bRegex": false,

	/**
	 * Flag to indicate if DataTables is to use its smart filtering or not.
	 *  @type boolean
	 *  @default true
	 */
	"bSmart": true
};

