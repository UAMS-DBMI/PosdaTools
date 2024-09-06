import React, { useContext } from 'react';
import { Context } from './Context.js';

function ReviewPanel({
    onMarkGood, onMarkBad, onMarkBlank, onMarkScout, onMarkOther
}) {
    const {
        layout,
    } = useContext(Context);

    // The review buttons
    return (
        <div id="reviewPanel" className="h-12 flex justify-center gap-2">
            <button
                id="markGood"
                onClick={onMarkGood}
                className="text-white bg-green-700 hover:bg-green-800">Good</button>
            <button
                id="markBad"
                onClick={onMarkBad}
                className="text-white bg-red-700 hover:bg-red-800">Bad</button>
            <button
                id="markBlank"
                onClick={onMarkBlank}
                className="text-white bg-yellow-700 hover:bg-yellow-800">Blank</button>
            <button
                id="markScout"
                onClick={onMarkScout}
                className="text-white bg-yellow-700 hover:bg-yellow-800">Scout</button>
            <button
                id="markOther"
                onClick={onMarkOther}
                className="text-white bg-yellow-700 hover:bg-yellow-800">Other</button>
        </div>
    )
}

export default ReviewPanel;
