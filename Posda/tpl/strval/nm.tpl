#$Source: /home/bbennett/pass/archive/Posda/tpl/strval/nm.tpl,v $
#$Date: 2009/03/25 14:07:38 $
#$Revision: 1.1 $
#
StringValues="NuclearMedicineSeriesTypeRetired" {
	STATIC,
	DYNAMIC,
	GATED,
	WHOLE BODY,
	STEP_SHOOT TOMO,
	CONTINUOUS TOMO,
	GATED TOMO
}

StringValues="WholeBodyTechnique" {
	1PS = One Pass,
	2PS = Two Pass,
	PCN = Patient Contour Following Employed 
	DIV = Diverging Collimator Used,
	MSP = Multiple Static Images Collected Into a Whole Body Image
}

StringValues="NMFieldOfViewShape" {
	RECTANGLE,
	ROUND,
	HEXAGONAL
}

StringValues="CollimatorType" {
	PARA = Parallel,
	PINH = PinHole,
	FANB = Fan Beam,
	CONE = Cone Beam,
	SLNT = Slant Hole,
	ASTG = Astigmatic
}

StringValues="AcquisitionTerminationCondition" {
	CNTS = Counts,
	DENS = Density,
	MANU = Manual,
	OVFL = Data Overflow,
	TIME = Time,
	TRIG = Physiological Trigger
}

StringValues="NMCorrectedImageRetired" {
	UNIF = Flood Corrected,
	COR  = Center of Rotation Corrected,
	NCO  = Non-circular Orbit Corrected,
	DECY = Decay Corrected,
	ATTN = Attenuation Corrected,
	SCAT = Scatter Corrected,
	DTIM = Dead Time Corrected
}


StringValues="NMPhotometricInterpretation" {
	MONOCHROME2,
	PALETTE COLOR
}

StringValues="NMImageTypeValue2"	{
	PRIMARY
}

StringValues="NMImageTypeValue3"	{
	STATIC,
	DYNAMIC,
	GATED,
	WHOLE BODY,
	TOMO,
	GATED TOMO,
	RECON TOMO,
	RECON GATED TOMO
}

StringValues="NMImageTypeValue4"	{
	EMISSION,
	TRANSMISSION
}

StringValues="NMAcquisitionTerminationCondition" {
	CNTS = preset count limit was reached,
	DENS = preset count density was reached,
	MANU = acquisition was terminated manually,
	OVFL = acquisition was terminated automatically by pixel data overflow condition,
	TIME = preset time limit was reached,
	TRIG = preset number Of physiological triggers was reached,
}

StringValues="NMCorrectedImage"	{
	UNIF = flood corrected,
	COR = center Of rotation corrected,
	NCO = non-circular orbit corrected,
	DECY = decay corrected,
	ATTN = attenuation corrected,
	SCAT = scatter corrected,
	DTIM = dead time corrected,
	NRGY = energy corrected,
	LIN = linearity corrected,
	MOTN = motion corrected,
	CLN = count loss normalization
}

StringValues="NMWholeBodyTechnique"	{
	1PS = one pass,
	2PS = two pass, 
	PCN = patient contour following employed,
	MSP = multiple static frames collected into a whole body frame
}

StringValues="EKG"	{
	EKG
}

StringValues="NMCollimatorType"	{
	PARA = Parallel,
	PINH = Pinhole,
	FANB = Fan-beam,
	CONE = Cone-beam,
	SLNT = Slant hole,
	ASTG = Astigmatic,
	DIVG = Diverging,
	NONE = No collimator,
	UNKN = Unknown
}

StringValues="NMTypeOfDetectorMotion"	{
	STEP AND SHOOT = Interrupted motion - acquire only while stationary,
	CONTINUOUS = Gantry motion and acquisition are simultaneous and continuous,
	ACQ DURING STEP = Interrupted motion - acquisition is continuous
}

StringValues="PositionerMotion" {
	STATIC,
	DYNAMIC
}

StringValues="TableMotion" {
	STATIC,
	DYNAMIC
}

StringValues="NMPhaseDescription" {
	FLOW,
	WASHOUT,
	UPTAKE,
	EMPTYING,
	EXCRETION
}

StringValues="NMSliceProgressionDirection" {
	APEX_TO_BASE,
	BASE_TO_APEX
}


