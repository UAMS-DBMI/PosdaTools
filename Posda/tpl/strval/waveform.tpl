#$Source: /home/bbennett/pass/archive/Posda/tpl/strval/waveform.tpl,v $
#$Date: 2009/03/25 14:08:51 $
#$Revision: 1.1 $
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

