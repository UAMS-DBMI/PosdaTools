import React, { useContext } from 'react';

import { Context } from './Context.js';
import MaskerPanel from './MaskerPanel.jsx';
import ReviewPanel from './ReviewPanel.jsx';
import NavigationPanel from './NavigationPanel.jsx';

function MiddlelBottomPanel({ onExpand,
    onClear,
    onAccept,
    onNext,
    onPrevious,
    onMarkAccepted,
    onMarkRejected,
    onMarkSkip,
    onMarkNonMaskable,
    onMarkGood,
    onMarkBad,
    onMarkBlank,
    onMarkScout,
    onMarkOther}) {

    const {
        layout,
    } = useContext(Context);

    if (layout === "Masker" || layout === "MaskerVR" || layout === "MaskerReview") {
        return (
            <div id="middleBottomPanel" className="w-full h-12 flex justify-center gap-2">
                <MaskerPanel
                    onExpand={onExpand}
                    onClear={onClear}
                    onAccept={onAccept}
                    onMarkAccepted={onMarkAccepted}
                    onMarkRejected={onMarkRejected}
                    onMarkSkip={onMarkSkip}
                    onMarkNonMaskable={onMarkNonMaskable}
                />
                {layout === "MaskerVR" && (
                    <NavigationPanel
                        onNext={onNext}
                        onPrevious={onPrevious}
                    />
                )}
            </div>
        );
    }

    else if (layout === "NiftiReview" || layout === "DicomReview") {
        return (
            <div id="middleBottomPanel" className="w-full h-12 flex justify-center gap-2">
                <ReviewPanel
                    onMarkGood={onMarkGood}
                    onMarkBad={onMarkBad}
                    onMarkBlank={onMarkBlank}
                    onMarkScout={onMarkScout}
                    onMarkOther={onMarkOther}
                />
                {/*<NavigationPanel*/}
                {/*    onNext={onNext}*/}
                {/*    onPrevious={onPrevious}*/}
                {/*/>*/}
            </div>
        );
    }
}
export default MiddlelBottomPanel;
