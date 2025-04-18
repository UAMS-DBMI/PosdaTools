/**
 * Add a data array to the table, creating DOM node etc. This is the parallel to 
 * _fnGatherData, but for adding rows from a Javascript source, rather than a
 * DOM source.
 *  @param {object} oSettings dataTables settings object
 *  @param {array} aData data array to be added
 *  @returns {int} >=0 if successful (index of new aoData entry), -1 if failed
 *  @memberof DataTable#oApi
 */
function _fnAddData ( oSettings, aDataSupplied )
{
	var oCol;
	
	/* Take an independent copy of the data source so we can bash it about as we wish */
	var aDataIn = ($.isArray(aDataSupplied)) ?
		aDataSupplied.slice() :
		$.extend( true, {}, aDataSupplied );
	
	/* Create the object for storing information about this new row */
	var iRow = oSettings.aoData.length;
	var oData = $.extend( true, {}, DataTable.models.oRow );
	oData._aData = aDataIn;
	oSettings.aoData.push( oData );

	/* Create the cells */
	var nTd, sThisType;
	for ( var i=0, iLen=oSettings.aoColumns.length ; i<iLen ; i++ )
	{
		oCol = oSettings.aoColumns[i];

		/* Use rendered data for filtering/sorting */
		if ( typeof oCol.fnRender === 'function' && oCol.bUseRendered && oCol.mDataProp !== null )
		{
			_fnSetCellData( oSettings, iRow, i, _fnRender(oSettings, iRow, i) );
		}
		else
		{
			_fnSetCellData( oSettings, iRow, i, _fnGetCellData( oSettings, iRow, i ) );
		}
		
		/* See if we should auto-detect the column type */
		if ( oCol._bAutoType && oCol.sType != 'string' )
		{
			/* Attempt to auto detect the type - same as _fnGatherData() */
			var sVarType = _fnGetCellData( oSettings, iRow, i, 'type' );
			if ( sVarType !== null && sVarType !== '' )
			{
				sThisType = _fnDetectType( sVarType );
				if ( oCol.sType === null )
				{
					oCol.sType = sThisType;
				}
				else if ( oCol.sType != sThisType && oCol.sType != "html" )
				{
					/* String is always the 'fallback' option */
					oCol.sType = 'string';
				}
			}
		}
	}
	
	/* Add to the display array */
	oSettings.aiDisplayMaster.push( iRow );

	/* Create the DOM imformation */
	if ( !oSettings.oFeatures.bDeferRender )
	{
		_fnCreateTr( oSettings, iRow );
	}

	return iRow;
}


/**
 * Read in the data from the target table from the DOM
 *  @param {object} oSettings dataTables settings object
 *  @memberof DataTable#oApi
 */
function _fnGatherData( oSettings )
{
	var iLoop, i, iLen, j, jLen, jInner,
	 	nTds, nTrs, nTd, aLocalData, iThisIndex,
		iRow, iRows, iColumn, iColumns, sNodeName,
		oCol, oData;
	
	/*
	 * Process by row first
	 * Add the data object for the whole table - storing the tr node. Note - no point in getting
	 * DOM based data if we are going to go and replace it with Ajax source data.
	 */
	if ( oSettings.bDeferLoading || oSettings.sAjaxSource === null )
	{
		nTrs = oSettings.nTBody.childNodes;
		for ( i=0, iLen=nTrs.length ; i<iLen ; i++ )
		{
			if ( nTrs[i].nodeName.toUpperCase() == "TR" )
			{
				iThisIndex = oSettings.aoData.length;
				nTrs[i]._DT_RowIndex = iThisIndex;
				oSettings.aoData.push( $.extend( true, {}, DataTable.models.oRow, {
					"nTr": nTrs[i]
				} ) );
				
				oSettings.aiDisplayMaster.push( iThisIndex );
				nTds = nTrs[i].childNodes;
				jInner = 0;
				
				for ( j=0, jLen=nTds.length ; j<jLen ; j++ )
				{
					sNodeName = nTds[j].nodeName.toUpperCase();
					if ( sNodeName == "TD" || sNodeName == "TH" )
					{
						_fnSetCellData( oSettings, iThisIndex, jInner, $.trim(nTds[j].innerHTML) );
						jInner++;
					}
				}
			}
		}
	}
	
	/* Gather in the TD elements of the Table - note that this is basically the same as
	 * fnGetTdNodes, but that function takes account of hidden columns, which we haven't yet
	 * setup!
	 */
	nTrs = _fnGetTrNodes( oSettings );
	nTds = [];
	for ( i=0, iLen=nTrs.length ; i<iLen ; i++ )
	{
		for ( j=0, jLen=nTrs[i].childNodes.length ; j<jLen ; j++ )
		{
			nTd = nTrs[i].childNodes[j];
			sNodeName = nTd.nodeName.toUpperCase();
			if ( sNodeName == "TD" || sNodeName == "TH" )
			{
				nTds.push( nTd );
			}
		}
	}
	
	/* Now process by column */
	for ( iColumn=0, iColumns=oSettings.aoColumns.length ; iColumn<iColumns ; iColumn++ )
	{
		oCol = oSettings.aoColumns[iColumn];

		/* Get the title of the column - unless there is a user set one */
		if ( oCol.sTitle === null )
		{
			oCol.sTitle = oCol.nTh.innerHTML;
		}
		
		var
			bAutoType = oCol._bAutoType,
			bRender = typeof oCol.fnRender === 'function',
			bClass = oCol.sClass !== null,
			bVisible = oCol.bVisible,
			nCell, sThisType, sRendered, sValType;
		
		/* A single loop to rule them all (and be more efficient) */
		if ( bAutoType || bRender || bClass || !bVisible )
		{
			for ( iRow=0, iRows=oSettings.aoData.length ; iRow<iRows ; iRow++ )
			{
				oData = oSettings.aoData[iRow];
				nCell = nTds[ (iRow*iColumns) + iColumn ];
				
				/* Type detection */
				if ( bAutoType && oCol.sType != 'string' )
				{
					sValType = _fnGetCellData( oSettings, iRow, iColumn, 'type' );
					if ( sValType !== '' )
					{
						sThisType = _fnDetectType( sValType );
						if ( oCol.sType === null )
						{
							oCol.sType = sThisType;
						}
						else if ( oCol.sType != sThisType && 
						          oCol.sType != "html" )
						{
							/* String is always the 'fallback' option */
							oCol.sType = 'string';
						}
					}
				}

				if ( typeof oCol.mDataProp === 'function' )
				{
					nCell.innerHTML = _fnGetCellData( oSettings, iRow, iColumn, 'display' );
				}
				
				/* Rendering */
				if ( bRender )
				{
					sRendered = _fnRender( oSettings, iRow, iColumn );
					nCell.innerHTML = sRendered;
					if ( oCol.bUseRendered )
					{
						/* Use the rendered data for filtering/sorting */
						_fnSetCellData( oSettings, iRow, iColumn, sRendered );
					}
				}
				
				/* Classes */
				if ( bClass )
				{
					nCell.className += ' '+oCol.sClass;
				}
				
				/* Column visability */
				if ( !bVisible )
				{
					oData._anHidden[iColumn] = nCell;
					nCell.parentNode.removeChild( nCell );
				}
				else
				{
					oData._anHidden[iColumn] = null;
				}

				if ( oCol.fnCreatedCell )
				{
					oCol.fnCreatedCell.call( oSettings.oInstance,
						nCell, _fnGetCellData( oSettings, iRow, iColumn, 'display' ), oData._aData, iRow, iColumn
					);
				}
			}
		}
	}

	/* Row created callbacks */
	if ( oSettings.aoRowCreatedCallback.length !== 0 )
	{
		for ( i=0, iLen=oSettings.aoData.length ; i<iLen ; i++ )
		{
			oData = oSettings.aoData[i];
			_fnCallbackFire( oSettings, 'aoRowCreatedCallback', null, [oData.nTr, oData._aData, i] );
		}
	}
}


/**
 * Take a TR element and convert it to an index in aoData
 *  @param {object} oSettings dataTables settings object
 *  @param {node} n the TR element to find
 *  @returns {int} index if the node is found, null if not
 *  @memberof DataTable#oApi
 */
function _fnNodeToDataIndex( oSettings, n )
{
	return (n._DT_RowIndex!==undefined) ? n._DT_RowIndex : null;
}


/**
 * Take a TD element and convert it into a column data index (not the visible index)
 *  @param {object} oSettings dataTables settings object
 *  @param {int} iRow The row number the TD/TH can be found in
 *  @param {node} n The TD/TH element to find
 *  @returns {int} index if the node is found, -1 if not
 *  @memberof DataTable#oApi
 */
function _fnNodeToColumnIndex( oSettings, iRow, n )
{
	var anCells = _fnGetTdNodes( oSettings, iRow );

	for ( var i=0, iLen=oSettings.aoColumns.length ; i<iLen ; i++ )
	{
		if ( anCells[i] === n )
		{
			return i;
		}
	}
	return -1;
}


/**
 * Get an array of data for a given row from the internal data cache
 *  @param {object} oSettings dataTables settings object
 *  @param {int} iRow aoData row id
 *  @param {string} sSpecific data get type ('type' 'filter' 'sort')
 *  @returns {array} Data array
 *  @memberof DataTable#oApi
 */
function _fnGetRowData( oSettings, iRow, sSpecific )
{
	var out = [];
	for ( var i=0, iLen=oSettings.aoColumns.length ; i<iLen ; i++ )
	{
		out.push( _fnGetCellData( oSettings, iRow, i, sSpecific ) );
	}
	return out;
}


/**
 * Get the data for a given cell from the internal cache, taking into account data mapping
 *  @param {object} oSettings dataTables settings object
 *  @param {int} iRow aoData row id
 *  @param {int} iCol Column index
 *  @param {string} sSpecific data get type ('display', 'type' 'filter' 'sort')
 *  @returns {*} Cell data
 *  @memberof DataTable#oApi
 */
function _fnGetCellData( oSettings, iRow, iCol, sSpecific )
{
	var sData;
	var oCol = oSettings.aoColumns[iCol];
	var oData = oSettings.aoData[iRow]._aData;

	if ( (sData=oCol.fnGetData( oData, sSpecific )) === undefined )
	{
		if ( oSettings.iDrawError != oSettings.iDraw && oCol.sDefaultContent === null )
		{
			_fnLog( oSettings, 0, "Requested unknown parameter "+
				(typeof oCol.mDataProp=='function' ? '{mDataprop function}' : "'"+oCol.mDataProp+"'")+
				" from the data source for row "+iRow );
			oSettings.iDrawError = oSettings.iDraw;
		}
		return oCol.sDefaultContent;
	}

	/* When the data source is null, we can use default column data */
	if ( sData === null && oCol.sDefaultContent !== null )
	{
		sData = oCol.sDefaultContent;
	}
	else if ( typeof sData === 'function' )
	{
		/* If the data source is a function, then we run it and use the return */
		return sData();
	}

	if ( sSpecific == 'display' && sData === null )
	{
		return '';
	}
	return sData;
}


/**
 * Set the value for a specific cell, into the internal data cache
 *  @param {object} oSettings dataTables settings object
 *  @param {int} iRow aoData row id
 *  @param {int} iCol Column index
 *  @param {*} val Value to set
 *  @memberof DataTable#oApi
 */
function _fnSetCellData( oSettings, iRow, iCol, val )
{
	var oCol = oSettings.aoColumns[iCol];
	var oData = oSettings.aoData[iRow]._aData;

	oCol.fnSetData( oData, val );
}


/**
 * Return a function that can be used to get data from a source object, taking
 * into account the ability to use nested objects as a source
 *  @param {string|int|function} mSource The data source for the object
 *  @returns {function} Data get function
 *  @memberof DataTable#oApi
 */
function _fnGetObjectDataFn( mSource )
{
	if ( mSource === null )
	{
		/* Give an empty string for rendering / sorting etc */
		return function (data, type) {
			return null;
		};
	}
	else if ( typeof mSource === 'function' )
	{
		return function (data, type) {
			return mSource( data, type );
		};
	}
	else if ( typeof mSource === 'string' && mSource.indexOf('.') != -1 )
	{
		/* If there is a . in the source string then the data source is in a 
		 * nested object so we loop over the data for each level to get the next
		 * level down. On each loop we test for undefined, and if found immediatly
		 * return. This allows entire objects to be missing and sDefaultContent to
		 * be used if defined, rather than throwing an error
		 */
		var a = mSource.split('.');
		return function (data, type) {
			for ( var i=0, iLen=a.length ; i<iLen ; i++ )
			{
				data = data[ a[i] ];
				if ( data === undefined )
				{
					return undefined;
				}
			}
			return data;
		};
	}
	else
	{
		/* Array or flat object mapping */
		return function (data, type) {
			return data[mSource];	
		};
	}
}


/**
 * Return a function that can be used to set data from a source object, taking
 * into account the ability to use nested objects as a source
 *  @param {string|int|function} mSource The data source for the object
 *  @returns {function} Data set function
 *  @memberof DataTable#oApi
 */
function _fnSetObjectDataFn( mSource )
{
	if ( mSource === null )
	{
		/* Nothing to do when the data source is null */
		return function (data, val) {};
	}
	else if ( typeof mSource === 'function' )
	{
		return function (data, val) {
			mSource( data, 'set', val );
		};
	}
	else if ( typeof mSource === 'string' && mSource.indexOf('.') != -1 )
	{
		/* Like the get, we need to get data from a nested object.  */
		var a = mSource.split('.');
		return function (data, val) {
			for ( var i=0, iLen=a.length-1 ; i<iLen ; i++ )
			{
				data = data[ a[i] ];
				if ( data === undefined )
				{
					return;
				}
			}
			data[ a[a.length-1] ] = val;
		};
	}
	else
	{
		/* Array or flat object mapping */
		return function (data, val) {
			data[mSource] = val;	
		};
	}
}


/**
 * Return an array with the full table data
 *  @param {object} oSettings dataTables settings object
 *  @returns array {array} aData Master data array
 *  @memberof DataTable#oApi
 */
function _fnGetDataMaster ( oSettings )
{
	var aData = [];
	var iLen = oSettings.aoData.length;
	for ( var i=0 ; i<iLen; i++ )
	{
		aData.push( oSettings.aoData[i]._aData );
	}
	return aData;
}


/**
 * Nuke the table
 *  @param {object} oSettings dataTables settings object
 *  @memberof DataTable#oApi
 */
function _fnClearTable( oSettings )
{
	oSettings.aoData.splice( 0, oSettings.aoData.length );
	oSettings.aiDisplayMaster.splice( 0, oSettings.aiDisplayMaster.length );
	oSettings.aiDisplay.splice( 0, oSettings.aiDisplay.length );
	_fnCalculateEnd( oSettings );
}


 /**
 * Take an array of integers (index array) and remove a target integer (value - not 
 * the key!)
 *  @param {array} a Index array to target
 *  @param {int} iTarget value to find
 *  @memberof DataTable#oApi
 */
function _fnDeleteIndex( a, iTarget )
{
	var iTargetIndex = -1;
	
	for ( var i=0, iLen=a.length ; i<iLen ; i++ )
	{
		if ( a[i] == iTarget )
		{
			iTargetIndex = i;
		}
		else if ( a[i] > iTarget )
		{
			a[i]--;
		}
	}
	
	if ( iTargetIndex != -1 )
	{
		a.splice( iTargetIndex, 1 );
	}
}


 /**
 * Call the developer defined fnRender function for a given cell (row/column) with
 * the required parameters and return the result.
 *  @param {object} oSettings dataTables settings object
 *  @param {int} iRow aoData index for the row
 *  @param {int} iCol aoColumns index for the column
 *  @returns {*} Return of the developer's fnRender function
 *  @memberof DataTable#oApi
 */
function _fnRender( oSettings, iRow, iCol )
{
	var oCol = oSettings.aoColumns[iCol];

	return oCol.fnRender( {
		"iDataRow":    iRow,
		"iDataColumn": iCol,
		"oSettings":   oSettings,
		"aData":       oSettings.aoData[iRow]._aData,
		"mDataProp":   oCol.mDataProp
	}, _fnGetCellData(oSettings, iRow, iCol, 'display') );
}
