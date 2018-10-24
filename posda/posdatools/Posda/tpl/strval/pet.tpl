#
StringValues="PETUnits" {
	CNTS = counts,
	NONE = unitless,
	CM2 = centimeter**2,
	PCNT = percent,
	CPS = counts/second,
	BQML = Becquerels/milliliter,
	MGMINML = milligram/minute/milliliter,
	UMOLMINML = micromole/minute/milliliter,
	MLMING = milliliter/minute/gram,
	MLG = milliliter/gram,
	1CM = 1/centimeter,
	UMOLML = micromole/milliliter,
	PROPCNTS = proportional to counts,
	PROPCPS = proportional to counts/sec,
	MLMINML = milliliter/minute/milliliter,
	MLML = milliliter/milliliter,
	GML = grams/milliliter,
	STDDEV = standard deviations
}

StringValues="CountsSource"	{
	EMISSION,
	TRANSMISSION
}

StringValues="PETSeriesType1" {
	STATIC,
	DYNAMIC,
	GATED,
	WHOLE BODY
}

StringValues="PETSeriesType2" {
	IMAGE,
	REPROJECTION
}

StringValues="ReprojectionMethod" {
	SUM,
	MAX PIXEL
}

StringValues="CorrectedImage" {
	DECY = decay corrected,
	ATTN = attenuation corrected,
	SCAT = scatter corrected,
	DTIM = dead time corrected,
	MOTN = gantry motion corrected (e.g. wobble or clamshell),
	PMOT = patient motion corrected,
	CLN  = count loss normalization (correction for count loss in gated Time Slots),
	RAN  = randoms corrected,
	RADL = non-uniform radial sampling corrected,
	DCAL = sensitivity calibrated using dose calibrator,
	NORM = detector normalization
}

StringValues="RandomsCorrectionMethod" {
	NONE = no randoms correction,
	DLYD = delayed event subtraction,
	SING = singles estimation
}

StringValues="RandomsCorrectionMethodEnhanced" {
	DLYD = delayed event subtraction,
	SING = singles estimation,
	PDDL = processed delays
}

StringValues="DecayCorrection" {
	NONE = no decay correction,
	START= acquisition start time,
	ADMIN = radiopharmaceutical administration time
}

StringValues="AcquisitionStartCondition" {
	DENS = density (counts/sec),
	RDD = relative density difference (change in counts/sec),
	MANU = manual,
	TIME = time,
	AUTO = automatic, when ready,
	TRIG = physiological trigger
}

StringValues="PETAcquisitionTerminationCondition" {
	CNTS = counts,
	DENS = density (counts/sec),
	RDD = relative density difference (change in counts/sec),
	MANU = manual,
	OVFL = data overflow,
	TIME = time,
	TRIG = physiological trigger
}

StringValues="PETFieldOfViewShape" {
	CYLINDRICAL RING
	HEXAGONAL
	MULTIPLE PLANAR
}

StringValues="TypeOfDetectorMotion" {
	NONE = stationary gantry,
	STEP AND SHOOT = Interrupted motion, acquire only while stationary,
	CONTINUOUS = Gantry motion and acquisition are simultaneous and continuous,
	WOBBLE = wobble motion,
	CLAMSHELL = clamshell motion
}

StringValues="PETCollimatorType" {
	NONE = no collimator,
	RING = transverse septa
}

StringValues="SecondaryCountsType" {
	DLYD=delayed events,
	SCAT=scattered events in secondary window,
	SING=singles,
	DTIM=events lost due to deadtime
}

StringValues="FramingType" {
	FORW = forward,
	BACK = backward,
	PCNT  = forward/backward by percentage
}

StringValues="PETImageTypeValue2"	{
	PRIMARY
}

StringValues="PETTypeOfData"	{
	SYSRATE = system count rate,
	SLICERATE = slice count rate,
	BLDSMPL = blood samples,
	CPM = cardiac polar map
}

StringValues="PETAxisUnits"	{
	SEC = seconds,
	CNTS = counts,
	MM = millimeters,
	NONE = unitless,
	CM = centimeters
	CM2 = cm**2,
	DEG = degrees,
	MILS = milliseconds,
	PCNT = percent,
	CPS = counts/second,
	BQML = Becquerels/milliliter,
	MGMINML = milligram/minute/milliliter,
	UMOLMINML = micromole/minute/milliliter,
	MLMING = milliliter/minute/gram,
	MLG = milliliter/gram,
	1CM = 1/centimeter,
	UMOLML = micromole/milliliter,
	PROPCNTS = proportional to counts,
	PROPCPS = proportional to counts/sec,
	MLMINML = milliliter/minute/milliliter,
	MLML = milliliter/milliliter,
	GML = grams/milliliter,
	STDDEV = standard deviations
}

StringValues="CountsIncluded"	{
	TRUES,
	SCATTER,
	RANDOMS,
	SINGLES
}

StringValues="SliceProgressionDirection"	{
	APEX_TO_BASE,
	BASE_TO_APEX
}

StringValues="PETModality" {
	PT
}

StringValues="EnhancedPETTypeOfDetectorMotion" {
	STATIONARY,
	STEP AND SHOOT,
	CONTINUOUS,
	WOBBLE,
	CLAMSHELL 
}

StringValues="DetectorGeometry" {
	CYLINDRICAL_RING,
	CYL_RING_PARTIAL,
	MULTIPLE_PLANAR,
	MUL_PLAN_PARTIAL
}

StringValues="PETSliceProgressionDirection" {
	APEX_TO_BASE,
	BASE_TO_APEX,
	ANT_TO_INF,
	INF_TO_ANT,
	SEPTUM_TO_WALL,
	WALL_TO_SEPTUM
}

StringValues="EnhancedPETAcquisitionStartCondition" {
	DENS,
	RDD,
	MANU,
	AUTO,
	CARD_TRIG,
	RESP_TRIG
}

StringValues="EnhancedPETAcquisitionTerminationCondition" {
	CNTS,
	DENS,
	RDD,
	MANU,
	OVFL,
	TIME,
	CARD_TRIG,
	RESP_TRIG
}

StringValues="AttenuationCorrectionSource" {
	CT,
	MR,
	POSITRON SOURCE,
	SINGLE PHOTON,
	CALCULATED
}

StringValues="AttenuationCorrectionTemporalRelationship" {
	CONCURRENT, 
	SEPARATE,
	SIMULTANEOUS
}

StringValues="PETReconstructionType" {
	2D,
	3D,
	3D_REBINNED
}

StringValues="PETReconstructionAlgorithm" {
	FILTER_BACK_PROJ,
	REPROJECTION,
	RAMLA,
	MLEM
}


