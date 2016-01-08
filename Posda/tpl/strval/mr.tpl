#$Source: /home/bbennett/pass/archive/Posda/tpl/strval/mr.tpl,v $
#$Date: 2010/04/30 18:53:53 $
#$Revision: 1.2 $
#
StringValues="MRModality" {
	MR
}

StringValues="CardiacCyclePosition" {
	END_SYSTOLE,
	END_DIASTOLE,
	UNDETERMINED
}

StringValues="RespiratoryCyclePosition" {
	START_RESPIR,
	END_RESPIR,
	UNDETERMINED
}

StringValues="CardiacSynchronizationTechnique" {
	NONE,
	REALTIME
	PROSPECTIVE,
	RETROSPECTIVE,
	PACED
}


StringValues="CardiacSignalSource" {
	ECG,
	VCG,
	PP,
	MR
}


StringValues="CardiacBeatRejectionTechnique" {
	NONE,
	RR_INTERVAL,
	QRS_LOOP,
	PVC
}

StringValues="RespiratoryMotionCompensationTechnique" {
	NONE,
	BREATH_HOLD,
	REALTIME,
	GATING,
	TRACKING,
	PHASE_ORDERING,
	PHASE_RESCANNING,
	RETROSPECTIVE,
	CORRECTION
}

StringValues="RespiratorySignalSource" {
	NONE,
	BELT,
	NASAL_PROBE,
	CO2_SENSOR,
	NAVIGATOR,
	MR_PHASE,
	ECG
}

StringValues="BulkMotionCompensationTechnique" {
	NONE,
	REALTIME,
	GATING,
	TRACKING,
	RETROSPECTIVE,
	CORRECTION
}

StringValues="BulkMotionSignalSource" {
	JOINT,
	NAVIGATOR,
	MR_PHASE
}

StringValues="ContentQualification" {
	PRODUCT,
	RESEARCH,
	SERVICE
}

StringValues="ResonantNucleus" {
	1H,
	3HE,
	7LI,
	13C,
	19F,
	23NA,
	31P,
	129XE
}

StringValues="ApplicableSafetyStandardAgency" {
	IEC,
	FDA,
	MHW
}

StringValues="EnhancedMRImageAndFrameType3" {
	ANGIO,
	CARDIAC,
	CARDIAC_GATED,
	CARDRESP_GATED,
	DYNAMIC,
	FLUOROSCOPY,
	LOCALIZER,
	MOTION,
	PERFUSION,
	PRE_CONTRAST,
	POST_CONTRAST,
	RESP_GATED,
	REST,
	STATIC,
	STRESS,
	VOLUME,
	NON_PARALLEL,
	PARALLEL,
	WHOLE_BODY,
	ANGIO_TIME,
	CINE,
	DIFFUSION,
	FLOW_ENCODED,
	FLUID_ATTENUATED,
	FMRI,
	MAX_IP,
	MIN_IP,
	M_MODE,
	METABOLITE_MAP,
	MULTIECHO,
	PROTON_DENSITY,
	REALTIME,
	STIR,
	TAGGING,
	TEMPERATURE,
	T1,
	T2,
	T2_STAR,
	TOF,
	VELOCITY
}

StringValues="EnhancedMRSpectroscopyImageAndFrameType3" {
	SPECTROSCOPY
}

StringValues="EnhancedMRImageType4" {
	ADDITION,
	DIVISION,
	MASKED,
	MAXIMUM,
	MEAN,
	MINIMUM,
	MTT,
	MULTIPLICATION,
	RCBF,
	RCBV,
	RESAMPLED,
	STD_DEVIATION,
	SUBTRACTION,
	T_TEST,
	TTP,
	Z_SCORE,
	NONE,
	ADC,
	DIFFUSION,
	DIFFUSION_ANISO,
	DIFFUSION_ATTNTD,
	METABOLITE_MAP,
	NEI,
	R_COEFFICIENT,
	RHO,
	SCM,
	SNR_MAP,
	T1_MAP,
	T2_STAR_MAP,
	T2_MAP,
	TCS,
	TEMPERATURE,
	VELOCITY,
	MIXED
}

StringValues="EnhancedMRFrameType4" {
	ADDITION,
	DIVISION,
	MASKED,
	MAXIMUM,
	MEAN,
	MINIMUM,
	MTT,
	MULTIPLICATION,
	RCBF,
	RCBV,
	RESAMPLED,
	STD_DEVIATION,
	SUBTRACTION,
	T_TEST,
	TTP,
	Z_SCORE,
	NONE,
	ADC,
	DIFFUSION,
	DIFFUSION_ANISO,
	DIFFUSION_ATTNTD,
	METABOLITE_MAP,
	NEI,
	R_COEFFICIENT,
	RHO,
	SCM,
	SNR_MAP,
	T1_MAP,
	T2_STAR_MAP,
	T2_MAP,
	TCS,
	TEMPERATURE,
	VELOCITY
}

StringValues="EnhancedMRSpectroscopyImageType4" {
	ADDITION,
	DIVISION,
	MAXIMUM,
	MEAN,
	MINIMUM,
	MULTIPLICATION,
	STD_DEVIATION,
	SUBTRACTION,
	NONE,
	MIXED
}

StringValues="EnhancedMRSpectroscopyFrameType4" {
	ADDITION,
	DIVISION,
	MAXIMUM,
	MEAN,
	MINIMUM,
	MULTIPLICATION,
	STD_DEVIATION,
	SUBTRACTION,
	NONE
}

StringValues="CommonCTMRPixelPresentationFrameLevel" {
	COLOR,
	MONOCHROME,
	TRUE_COLOR
}

StringValues="CommonCTMRPixelPresentationImageLevel" {
	COLOR,
	MONOCHROME,
	MIXED,
	TRUE_COLOR
}

StringValues="PixelPresentationTrueColor" {
	TRUE_COLOR
}

StringValues="CommonCTMRVolumetricPropertiesFrameLevel" {
	VOLUME,
	SAMPLED,
	DISTORTED
}

StringValues="CommonCTMRVolumetricPropertiesImageLevel" {
	VOLUME,
	SAMPLED,
	DISTORTED,
	MIXED
}

StringValues="CommonCTMRVolumeBasedCalculationTechniqueFrameLevel" {
	MAX_IP,
	MIN_IP,
	VOLUME_RENDER,
	SURFACE_RENDER,
	MPR,
	CURVED_MPR,
	NONE
}

StringValues="CommonCTMRVolumeBasedCalculationTechniqueImageLevel" {
	MAX_IP,
	MIN_IP,
	VOLUME_RENDER,
	SURFACE_RENDER,
	MPR,
	CURVED_MPR,
	NONE,
	MIXED
}


StringValues="MRSpectroscopyVolumeBasedCalculationTechniqueFrameLevel" {
	MAX_IP,
	MIN_IP,
	NONE
}

StringValues="MRSpectroscopyVolumeBasedCalculationTechniqueImageLevel" {
	MAX_IP,
	MIN_IP,
	NONE,
	MIXED
}

StringValues="EnhancedMRComplexImageComponentFrameLevel" {
	MAGNITUDE,
	PHASE,
	REAL,
	IMAGINARY
}

StringValues="EnhancedMRComplexImageComponentImageLevel" {
	MAGNITUDE,
	PHASE,
	REAL,
	IMAGINARY,
	MIXED
}

StringValues="MRSpectroscopyComplexImageComponentFrameLevel" {
	MAGNITUDE,
	PHASE,
	REAL,
	IMAGINARY,
	COMPLEX
}

StringValues="MRSpectroscopyComplexImageComponentImageLevel" {
	MAGNITUDE,
	PHASE,
	REAL,
	IMAGINARY,
	COMPLEX,
	MIXED
}

StringValues="EnhancedMRAcquisitionContrastFrameLevel" {
	DIFFUSION,
	FLOW_ENCODED,
	FLUID_ATTENUATED,
	PERFUSION,
	PROTON_DENSITY,
	STIR,
	TAGGING,
	T1,
	T2,
	T2_STAR,
	TOF,
	UNKNOWN
}

StringValues="EnhancedMRAcquisitionContrastImageLevel" {
	DIFFUSION,
	FLOW_ENCODED,
	FLUID_ATTENUATED,
	PERFUSION,
	PROTON_DENSITY,
	STIR,
	TAGGING,
	T1,
	T2,
	T2_STAR,
	TOF,
	UNKNOWN,
	MIXED
}


StringValues="MRSpectroscopyAcquisitionContrastFrameLevel" {
	PROTON_DENSITY,
	T1,
	T2,
	UNKNOWN
}

StringValues="MRSpectroscopyAcquisitionContrastImageLevel" {
	PROTON_DENSITY,
	T1,
	T2,
	UNKNOWN,
	MIXED
}

StringValues="EnhancedMRAcquisitionType" {
	1D,
	2D,
	3D
}

StringValues="EchoPulseSequence" {
	SPIN,
	GRADIENT,
	BOTH
}

StringValues="SteadyStatePulseSequence" {
	FREE_PRECESSION,
	TRANSVERSE,
	TIME_REVERSED,
	LONGITUDINAL,
	NONE
}

StringValues="SpectrallySelectedSuppression" {
	FAT,
	WATER,
	FAT_AND_WATER,
	SILICON_GEL,
	NONE
}

StringValues="OversamplingPhase" {
	2D = phase direction,
	3D = out of plane direction,
	2D_3D = both,
	NONE
}

StringValues="GeometryOfKSpaceTraversal" {
	RECTILINEAR,
	RADIAL,
	SPIRAL
}

StringValues="RectilinearPhaseEncodeReordering" {
	LINEAR,
	CENTRIC,
	SEGMENTED,
	REVERSE_LINEAR,
	REVERSE_CENTRIC
}

StringValues="SegmentedKSpaceTraversal" {
	SINGLE,
	PARTIAL,
	FULL
}

StringValues="CoverageOfKSpace" {
	FULL,
	CYLINDRICAL,
	ELLIPSOIDAL,
	WEIGHTED
}

StringValues="SpecificAbsorptionRateDefinition" {
	IEC_WHOLE_BODY,
	IEC_PARTIAL_BODY,
	IEC_HEAD,
	IEC_LOCAL
}

StringValues="GradientOutputType" {
	DB_DT,
	ELECTRIC_FIELD,
	PER_NERVE_STIM
}

StringValues="OperatingModeType" {
	STATIC FIELD,
	RF,
	GRADIENT
}
StringValues="OperatingMode" {
	IEC_NORMAL,
	IEC_FIRST_LEVEL,
	IEC_SECOND_LEVEL
}

StringValues="InplanePhaseEncodingDirection" {
	COLUMN,
	ROW,
	OTHER
}

StringValues="FlowCompensation" {
	ACCELERATION,
	VELOCITY,
	OTHER,
	NONE
}

StringValues="FlowCompensationDirection" {
	PHASE,
	FREQUENCY,
	SLICE_SELECT,
	SLICE_AND_FREQ,
	SLICE_FREQ_PHASE,
	PHASE_AND_FREQ,
	SLICE_AND_PHASE,
	OTHER
}

StringValues="Spoiling" {
	RF,
	GRADIENT,
	RF_AND_GRADIENT,
	NONE
}

StringValues="SpectrallySelectedExcitation" {
	WATER,
	FAT,
	NONE
}

StringValues="SpatialPresaturation" {
	SLAB,
	NONE
}

StringValues="PartialFourierDirection" {
	PHASE,
	FREQUENCY,
	SLICE_SELECT,
	COMBINATION
}

StringValues="ParallelAcquisitionTechnique" {
	PILS,
	SENSE,
	SMASH,
	OTHER
}

StringValues="MagnetizationTransfer" {
	ON_RESONANCE,
	OFF_RESONANCE,
	NONE
}

StringValues="Tagging" {
	GRID,
	LINE,
	NONE
}

StringValues="ReceiveCoilType" {
	BODY,
	VOLUME,
	SURFACE,
	MULTICOIL
}

StringValues="TransmitCoilType" {
	BODY,
	VOLUME,
	SURFACE
}

StringValues="DiffusionDirectionality" {
	DIRECTIONAL,
	BMATRIX,
	ISOTROPIC,
	NONE
}

StringValues="DiffusionAnisotropyType" {
	FRACTIONAL,
	RELATIVE,
	VOLUME_RATIO
}

StringValues="VolumeLocalizationTechnique" {
	ILOPS,
	ISIS,
	PRIME,
	PRESS,
	SLIM,
	SLOOP,
	STEAM,
	NONE
}

StringValues="DecoupledNucleus" {
	1H,
	3HE,
	7LI,
	13C,
	19F,
	23NA,
	31P,
	129XE
}

StringValues="DecouplingMethod" {
	MLEV,
	WALTZ,
	NARROWBAND
}

StringValues="KSpaceFiltering" {
	COSINE,
	COSINE_SQUARED,
	FERMI,
	GAUSSIAN,
	HAMMING,
	HANNING,
	LORENTZIAN,
	LRNTZ_GSS_TRNSFM,
	RIESZ,
	TUKEY,
	NONE
}

StringValues="TimeDomainFiltering" {
	COSINE,
	COSINE_SQUARED,
	EXPONENTIAL,
	GAUSSIAN,
	HAMMING,
	HANNING,
	LORENTZIAN,
	LRNTZ_GSS_TRNSFM,
	NONE
}

StringValues="BaselineCorrection" {
	LINEAR_TILT,
	LOCAL_LINEAR_FIT,
	POLYNOMIAL_FIT,
	SINC_DECONVOLUTN,
	TIME_DOMAIN_FIT,
	SPLINE,
	NONE
}

StringValues="MRSpectroscopyAcquisitionType" {
	SINGLE_VOXEL,
	ROW,
	PLANE,
	VOLUME
}

StringValues="MRSpectroscopyDataRepresentation" {
	COMPLEX,
	REAL,
	IMAGINARY,
	MAGNITUDE
}

StringValues="SpectroscopySignalDomain" {
	FREQUENCY,
	TIME
}



