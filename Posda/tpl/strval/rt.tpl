#$Source: /home/bbennett/pass/archive/Posda/tpl/strval/rt.tpl,v $
#$Date: 2010/04/30 18:53:53 $
#$Revision: 1.2 $
#
StringValues="RTModality"	{
	RTIMAGE = RT Image,
	RTDOSE = RT Dose,
	RTSTRUCT = RT Structure Set,
	RTPLAN = RT Plan,
	RTRECORD = RT Treatment Record
}

StringValues="RTImageTypeValue3"	{
	DRR = digitally reconstructed radiograph,
	PORTAL = digital portal image or portal film image,
	SIMULATOR = conventional simulator image,
	RADIOGRAPH = radiographic image,
	BLANK = image pixels set to background value,
	FLUENCE = fluence map
}

StringValues="ReportedValuesOrigin"	{
	OPERATOR = manually entered by operator,
	PLAN = planned parameter values,
	ACTUAL = electronically recorded
}

StringValues="RTImagePlane"	{
	NORMAL = image plane normal to beam axis,
	NON_NORMAL = image plane non-normal to beam axis
}

StringValues="PrimaryDosimeterUnit"	{
	MU = Monitor Unit,
	MINUTE = minute
}

StringValues="IonPrimaryDosimeterUnit"	{
	MU = Monitor Unit,
	NP = number of particles
}

StringValues="RTBeamLimitingDeviceType"	{
	X = symmetric jaw pair in IEC X direction,
	Y = symmetric jaw pair in IEC Y direction,
	ASYMX = asymmetric jaw pair in IEC X direction,
	ASYMY = asymmetric pair in IEC Y direction,
	MLCX = multileaf (multi-element) jaw pair in IEC X direction,
	MLCY = multileaf (multi-element) jaw pair in IEC Y direction
}

StringValues="ApplicatorType"	{
	ELECTRON_SQUARE = square electron applicator,
	ELECTRON_RECT = rectangular electron applicator,
	ELECTRON_CIRC = circular electron applicator,
	ELECTRON_SHORT = short electron applicator,
	ELECTRON_OPEN = open (dummy) electron applicator,
	INTRAOPERATIVE = intraoperative (custom) applicator,
	STEREOTACTIC = stereotactic applicator
}

StringValues="IonApplicatorType"	{
	ION_SQUARE = square ion applicator,
	ION_RECT = rectangluar ion applicator,
	ION_CIRC = circular ion applicator,
	ION_SHORT = short ion applicator,
	ION_OPEN = open (dummy) ion applicator,
	INTEROPERATIVE = interoperative (custom) applicator,
	STEREOTACTIC = stereotactic applicator
}

StringValues="BlockType"	{
	SHIELDING = blocking material is inside contour,
	APERTURE = blocking material is outside contour
}

StringValues="BlockDivergence"	{
	PRESENT = block edges are shaped for beam divergence,
	ABSENT = block edges are not shaped for beam divergence
}

StringValues="BlockMountingPosition"	{
	PATIENT_SIDE = the block is mounted on the side of the Block Tray which is towards the patient,
	SOURCE_SIDE = the block is mounted on the side of the Block Tray which is towards the radiation source
}

StringValues="DoseUnits"	{
	GY = Gray,
	RELATIVE = dose relative to implicit reference value
}

StringValues="TissueHeterogeneityCorrection"	{
	IMAGE,
	ROI_OVERRIDE,
	WATER 
}

StringValues="DoseType"	{
	PHYSICAL = physical dose,
	EFFECTIVE = physical dose after correction for biological effect using user-defined modeling technique,
	ERROR = difference between desired and planned dose
}

StringValues="DoseSummationType"	{
	PLAN = dose calculated for entire RT Plan,
	MULTI_PLAN = dose calculated for 2 or more RT Plans,
	FRACTION = dose calculated for a single Fraction Group within RT Plan,
	BEAM = dose calculated for one or more Beams within RT Plan,
	BRACHY = dose calculated for one or more Brachy Application Setups within RT Plan,
	CONTROL_POINT = dose calculated for one or more Control Points within a Beam
}

StringValues="DVHROIContributionType"	{
	INCLUDED
	EXCLUDED
}

StringValues="DVHType"	{
	DIFFERENTIAL = differential dose-volume histogram,
	CUMULATIVE = cumulative dose-volume histogram,
	NATURAL = natural dose-volume histogram
}

StringValues="DVHDoseUnits"	{
	GY = Gray,
	RELATIVE = dose relative to reference value specified in DVH Normalization Dose Value
}

StringValues="DVHDoseType"	{
	PHYSICAL = physical dose,
	EFFECTIVE = physical dose after correction for biological effect using user-defined modeling technique,
	ERROR = difference between desired and planned dose
}

StringValues="DVHVolumeUnits"	{
	CM3 = cubic centimeters,
	PERCENT = percent,
	PER_U = volume per u
}

StringValues="TransformationType"	{
	HOMOGENEOUS
}

StringValues="ROIGenerationAlgorithm"	{
	AUTOMATIC = calculated ROI,
	SEMIAUTOMATIC = ROI calculated with user assistance,
	MANUAL = user-entered ROI
}

StringValues="ContourGeometricType"	{
	POINT = single point,
	OPEN_PLANAR = open contour containing coplanar points,
	OPEN_NONPLANAR = open contour containing non-coplanar points,
	CLOSED_PLANAR = closed contour (polygon) containing coplanar points
}

StringValues="RTROIRelationship"	{
	SAME = ROIs represent the same entity,
	ENCLOSED = referenced ROI completely encloses referencing ROI,
	ENCLOSING = referencing ROI completely encloses referenced ROI
}

StringValues="RTROIInterpretedType"	{
	EXTERNAL = external patient contour,
	PTV = Planning Target Volume (as defined in ICRU50),
	CTV = Clinical Target Volume (as defined in ICRU50),
	GTV = Gross Tumor Volume (as defined in ICRU50),
	TREATED_VOLUME = Treated Volume (as defined in ICRU50),
	IRRAD_VOLUME = Irradiated Volume (as defined in ICRU50),
	BOLUS = patient bolus to be used for external beam therapy,
	AVOIDANCE = region in which dose is to be minimized,
	ORGAN = patient organ,
	MARKER = patient marker,
	REGISTRATION = registration ROI,
	ISOCENTER = treatment isocenter to be used for external beam therapy,
	CONTRAST_AGENT = volume into which a contrast agent has been injected,
	CAVITY = patient anatomical cavity,
	BRACHY_CHANNEL = brachytherapy channel,
	BRACHY_ACCESSORY = brachytherapy accessory device,
	BRACHY_SRC_APP = brachytherapy source applicator,
	BRACHY_CHNL_SHLD = brachytherapy channel shield,
	SUPPORT = external patient support device,
	FIXATION = external patient fixation or immobilisation device,
	DOSE_REGION = ROI to be used as a dose reference,
	CONTROL = ROI to be used in control of dose optimization and calculation
}

StringValues="ROIPhysicalProperty"	{
	REL_MASS_DENSITY = mass density relative to water,
	REL_ELEC_DENSITY = electron density relative to water,
	EFFECTIVE_Z = effective atomic number,
	EFF_Z_PER_A = ratio of effective atomic number to mass (AMU-1),
	REL_STOP_RATIO = linear stopping power ratio relative to water,
	ELEM_FRACTION = elemental composition of the material
}

StringValues="PlanIntent"	{
	CURATIVE,
	PALLIATIVE,
	PROPHYLACTIC,
	VERIFICATION,
	MACHINE_QA,
	RESEARCH,
	SERVICE 
}

StringValues="RTPlanGeometry"	{
	PATIENT = RT Structure Set exists,
	TREATMENT_DEVICE = RT Structure Set does not exist
}

StringValues="RTPlanRelationship"	{
	PRIOR = plan delivered prior to current treatment,
	ALTERNATIVE = alternative plan prepared for current treatment,
	PREDECESSOR = plan used in derivation of current plan,
	VERIFIED_PLAN = plan which is verified using the current plan
}

StringValues="RTPlanRelationshipVerifiedPlan"	{
	VERIFIED_PLAN = plan which is verified using the current plan
}

StringValues="DoseReferenceStructureType"	{
	POINT = dose reference point specified as ROI,
	VOLUME = dose reference volume specified as ROI,
	COORDINATES = point specified by Dose Reference Point Coordinates (300A,0018),
	SITE = dose reference clinical site
}

StringValues="DoseReferenceType"	{
	TARGET = treatment target (corresponding to GTV, PTV, or CTV in ICRU50),
	ORGAN_AT_RISK = Organ at Risk (as defined in ICRU50)
}

StringValues="SetupTechnique"	{
	ISOCENTRIC,
	FIXED_SSD,
	TBI,
	BREAST_BRIDGE,
	SKIN_APPOSITION
}

StringValues="SetupDeviceType"	{
	LASER_POINTER,
	DISTANCE_METER,
	TABLE_HEIGHT,
	MECHANICAL_PTR,
	ARC
}

StringValues="BeamType"	{
	STATIC = all beam parameters remain unchanged during delivery,
	DYNAMIC = one or more beam parameters changes during delivery
}

StringValues="RadiationType"	{
	PHOTON,
	ELECTRON,
	NEUTRON,
	PROTON
}

StringValues="FluenceMode"	{
	STANDARD,
	NON_STANDARD
}

StringValues="IonRadiationType"	{
	PHOTON,
	PROTON,
	ION
}

StringValues="IonScanMode"	{
	NONE,
	UNIFORM,
	MODULATED
}

StringValues="TreatmentDeliveryType"	{
	TREATMENT = normal patient treatment,
	OPEN_PORTFILM = portal image acquisition with open field,
	TRMT_PORTFILM = portal image acquisition with treatment port,
	CONTINUATION = continuation of interrupted treatment,
	SETUP = no treatment beam is applied for this RT Beam
}

StringValues="WedgeType"	{
	STANDARD = standard (static) wedge,
	DYNAMIC = moving beam limiting device (collimator) jaw simulating wedge,
	MOTORIZED = single wedge which can be removed from beam remotely
}

StringValues="IonWedgeType"	{
	STANDARD = standard (static) wedge,
	MOTORIZED = single wedge which can be removed from beam remotely,
	PARTIAL_STANDARD = wedge does not extend across the whole field and is operated manually,
	PARTIAL_MOTORIZED = wedge does not extend across the whole field and can be removed from beam remotely
}

StringValues="CompensatorDivergence"	{
	PRESENT = the compensator is shaped according to the beam geometrical divergence,
	ABSENT = the compensator is not shaped according to the beam geometrical divergence
}

StringValues="CompensatorMountingPosition"	{
	PATIENT_SIDE = the compensator is mounted on the side of the Compensator Tray which is towards the patient,
	SOURCE_SIDE = the compensator is mounted on the side of the Compensator Tray which is towards the radiation source,
	DOUBLE_SIDED = the compensator has a shaped surface on both sides of the Compensator Tray
}

StringValues="BrachyTreatmentTechnique"	{
	INTRALUMENARY,
	INTRACAVITARY,
	INTERSTITIAL,
	CONTACT,
	INTRAVASCULAR,
	PERMANENT
}

StringValues="BrachyTreatmentType"	{
	MANUAL = manually positioned,
	HDR = High dose rate,
	MDR = Medium dose rate,
	LDR = Low dose rate,
	PDR = Pulsed dose rate
}

StringValues="ApplicationSetupType"	{
	FLETCHER_SUIT,
	DELCLOS,
	BLOEDORN,
	JOSLIN_FLYNN,
	CHANDIGARH,
	MANCHESTER,
	HENSCHKE,
	NASOPHARYNGEAL,
	OESOPHAGEAL,
	ENDOBRONCHIAL,
	SYED_NEBLETT,
	ENDORECTAL,
	PERINEAL
}

StringValues="BrachyAccessoryDeviceType"	{
	SHIELD,
	DILATATION,
	MOLD,
	PLAQUE,
	FLAB
}

StringValues="SourceMovementType"	{
	STEPWISE,
	FIXED,
	OSCILLATING,
	UNIDIRECTIONAL
}

StringValues="ApprovalStatus"	{
	APPROVED = Reviewer recorded that object met an implied criterion,
	UNAPPROVED = No review of object has been recorded,
	REJECTED = Reviewer recorded that object failed to meet an implied criterion
}

StringValues="FixationDeviceType"	{
	BITEBLOCK,
	HEADFRAME,
	MASK,
	MOLD,
	CAST,
	HEADREST,
	BREAST_BOARD,
	BODY_FRAME,
	VACUUM_MOLD,
	WHOLE_BODY_POD,
	RECTAL_BALLOON
}

StringValues="ShieldingDeviceType"	{
	GUM,
	EYE,
	GONAD
}

StringValues="HighDoseTechniqueType"	{
	NORMAL,
	TBI,
	HDR
}

StringValues="TreatmentTerminationStatus"	{
	NORMAL,
	OPERATOR,
	MACHINE,
	UNKNOWN
}

StringValues="FractionGroupType"	{
	EXTERNAL_BEAM,
	BRACHY
}

StringValues="CurrentTreatmentStatus"	{
	NOT_STARTED,
	ON_TREATMENT,
	ON_BREAK,
	SUSPENDED,
	STOPPED,
	COMPLETED
}

StringValues="SourceApplicatorType"	{
	FLEXIBLE,
	RIGID
}

StringValues="TreatmentVerificationStatus"	{
	VERIFED,
	VERIFIED_OVR,
	NOT_VERIFED
}

StringValues="TreatmentDeliveryTypeNormalOrContinuation"	{
	TREATMENT,
	CONTINUATION
}

StringValues="ApplicationSetupCheck"	{
	PASSED,
	FAILED,
	UNKNOWN
}

StringValues="SourceType"	{
	POINT,
	LINE,
	CYLINDER,
	SPHERE
}

StringValues="BeamStopperPosition"	{
	EXTENDED,
	RETRACTED,
	UNKNOWN
}

StringValues="WedgePosition"	{
	IN,
	OUT
}

StringValues="NominalBeamEnergyUnit"	{
	MV = Megavolt,
	MEV = Mega electron-Volt
}

StringValues="CompensatorType"	{
	STANDARD,
	DYNAMIC
}

StringValues="MeasuredDoseType"	{
	DIODE,
	TLD,
	ION_CHAMBER,
	GEL,
	EPID,
	FILM
}

StringValues="FluenceDataSource"	{
	CALCULATED,
	MEASURED
}

StringValues="RTRespiratoryMotionCompensationTechnique" {
	NONE,
	BREATH_HOLD,
	REALTIME,
	GATING,
	TRACKING,
	PHASE_ORDERING,
	PHASE_RESCANNING,
	RETROSPECTIVE,
	CORRECTION,
	UNKNOWN
}

StringValues="RTRespiratorySignalSource" {
	NONE,
	BELT,
	NASAL_PROBE,
	CO2_SENSOR,
	NAVIGATOR,
	MR_PHASE,
	ECG,
	SPIROMETER,
	EXTERNAL_MARKER,
	INTERNAL_MARKER,
	IMAGE,
	UNKNOWN
}

StringValues="SourceStrengthUnits"	{
	AIR_KERMA_RATE,
	DOSE_RATE_WATER
}

StringValues="RTDoseSOPClass"	{
	1.2.840.10008.5.1.4.1.1.481.2
}

StringValues="RangeShifterType"	{
	ANALOG,
	BINARY
}

StringValues="LateralSpreadingDeviceType"	{
	SCATTERER,
	MAGNET
}

StringValues="RangeModulatorType"	{
	FIXED,
	WHL_FIXEDWEIGHTS,
	WHL_MODWEIGHTS
}

StringValues="PatientSupportType"	{
	TABLE,
	CHAIR
}

StringValues="RTGeneralAccessoryType"	{
	GRATICULE = Accessory tray with a radio-opaque grid,
	IMAGE_DETECTOR = Image acquisition device positioned in the beam line,
	RETICLE = Accessory tray with radio-transparent markers or grid
}

StringValues="RTPatientPosition" {
	HFP  = Head First Prone,
	HFS  = Head First Supine,
	HFDR = Head First Decubitus Right,
	HFDL = Head First Decubitus Right,
	FFP  = Feet First Prone,
	FFS  = Feet First Supine,
	FFDR = Feet First Decubitus Right,
	FFDL = Feet First Decubitus Right,
	SITTING = Sitting
}



