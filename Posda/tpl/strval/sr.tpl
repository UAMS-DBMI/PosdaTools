#$Source: /home/bbennett/pass/archive/Posda/tpl/strval/sr.tpl,v $
#$Date: 2010/04/30 18:53:53 $
#$Revision: 1.2 $
#
StringValues="SRModality" {
	SR
}

StringValues="KOModality" {
	KO
}

StringValues="PreliminaryFlag" {
	PRELIMINARY,
	FINAL
}

StringValues="CompletionFlag" {
	PARTIAL,
	COMPLETE
}

StringValues="VerificationFlag" {
	UNVERIFIED,
	VERIFIED
}

StringValues="ContinuityOfContent" {
	SEPARATE,
	CONTINUOUS
}

StringValues="SRRelationshipType" {
	CONTAINS,
	HAS PROPERTIES,
	HAS CONCEPT MOD,
	HAS OBS CONTEXT,
	HAS ACQ CONTEXT,
	INFERRED FROM,
	SELECTED FROM
}

StringValues="SRRelationshipTypeHasConceptModifier" {
	HAS CONCEPT MOD
}

StringValues="SRValueTypes" {
	TEXT,
	NUM,
	CODE,
	DATETIME,
	DATE,
	TIME,
	UIDREF,
	PNAME,
	IMAGE,
	WAVEFORM,
	COMPOSITE,
	SCOORD,
	TCOORD,
	CONTAINER
}

StringValues="BasicTextSRValueTypes" {
	TEXT,
	CODE,
	DATETIME,
	DATE,
	TIME,
	UIDREF,
	PNAME,
	COMPOSITE,
	IMAGE,
	WAVEFORM,
	CONTAINER
}

StringValues="KeyObjectSelectionDocumentValueTypes" {
	TEXT,
	CODE,
	UIDREF,
	PNAME,
	IMAGE,
	WAVEFORM,
	COMPOSITE,
	CONTAINER
}

StringValues="MammographyCADSRValueTypes" {
	TEXT,
	CODE,
	NUM,
	DATE,
	TIME,
	PNAME,
	SCOORD,
	COMPOSITE,
	IMAGE,
	CONTAINER
}

StringValues="ChestCADSRValueTypes" {
	TEXT,
	CODE,
	NUM,
	DATE,
	TIME,
	PNAME,
	SCOORD,
	TCOORD,
	COMPOSITE,
	IMAGE,
	CONTAINER,
	UIDREF,
	WAVEFORM
}

StringValues="ProcedureLogValueTypes" {
	CODE,
	CONTAINER,
	COMPOSITE,
	DATETIME,
	DATE,
	IMAGE,
	NUM,
	PNAME,
	TEXT,
	TIME,
	UIDREF,
	WAVEFORM
}

StringValues="XRayRadiationDoseSRValueTypes" {
	TEXT,
	CODE,
	NUM,
	DATETIME,
	UIDREF,
	PNAME,
	COMPOSITE,
	IMAGE,
	CONTAINER
}

StringValues="SRGraphicType" {
	POINT,
	MULTIPOINT,
	POLYLINE,
	CIRCLE,
	ELLIPSE
}

StringValues="TemporalRangeType" {
	POINT,
	MULTIPOINT,
	SEGMENT,
	MULTISEGMENT,
	BEGIN,
	END
}

StringValues="ParticipationType" {
	SOURCE,
	ENT,
	ATTEST 
}

StringValues="ObserverType" {
	PSN,
	DEV 
}

StringValues="SRTemplateMappingResource" {
	DCMR,
	99RPH 
}

