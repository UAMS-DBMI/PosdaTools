#
StringValues="WaveformOriginality" {
	ORIGINAL,
	DERIVED
}

StringValues="ChannelStatus" {
	OK,
	TEST DATA,
	DISCONNECTED,
	QUESTIONABLE,
	INVALID,
	UNCALIBRATED,
	UNZEROED
}

StringValues="WaveformSampleInterpretation" {
	SB = signed 8 bit linear,
	UB = unsigned 8 bit linear,
	MB = 8 bit mu-law,
	AB = 8 bit A-law,
	SS = signed 16 bit linear,
	US = unsigned 16 bit linear
}

StringValues="TemporalRangeTypeForWaveformAnnotation" {
	POINT,
	MULTIPOINT,
	SEGMENT,
	MULTISEGMENT,
	BEGIN,
	END
}

StringValues="SynchronizationTrigger" {
	SOURCE,
	EXTERNAL,
	PASSTHRU,
	NO TRIGGER
}

StringValues="TimeDistributionProtocol" {
	NTP  = Network Time Protocol,
	IRIG = InterRange Instrument Group,
	GPS  = Global Positioning System,
	SNTP  = Simple Network Time Protocol
}

StringValues="DisplayShadingFlag" {
	NONE,
	BASELINE,
	ABSOLUTE,
	DIFFERENCE
}

