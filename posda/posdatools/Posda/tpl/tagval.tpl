#
# should check these with data dictionary ?
# should match with ImageType value 3 allowed combinations ?

TagValues="NMFrameIncrementPointerValues" {
	0x0054,0x0010 = Energy Window Vector,
	0x0054,0x0020 = Detector Vector,
	0x0054,0x0030 = Phase Vector,
	0x0054,0x0050 = Rotation Vector,
	0x0054,0x0060 = RR Interval Vector,
	0x0054,0x0070 = Time Slot Vector,
	0x0054,0x0080 = Slice Vector,
	0x0054,0x0090 = Angular View Vector,
	0x0054,0x0100 = Time Slice Vector
}

TagValues="XRayFrameIncrementPointerValues" {
	0x0018,0x1063 = Frame Time,
	0x0018,0x1065 = Frame Time Vector
}

TagValues="FrameIncrementPointerIsEnergyWindowVector" {
	0x0054,0x0010 = Energy Window Vector
}

TagValues="FrameIncrementPointerIsDetectorVector" {
	0x0054,0x0020 = Detector Vector
}

TagValues="FrameIncrementPointerIsPhaseVector" {
	0x0054,0x0030 = Phase Vector
}

TagValues="FrameIncrementPointerIsRotationVector" {
	0x0054,0x0050 = Rotation Vector
}

TagValues="FrameIncrementPointerIsRRIntervalVector" {
	0x0054,0x0060 = RR Interval Vector
}

TagValues="FrameIncrementPointerIsTimeSlotVector" {
	0x0054,0x0070 = Time Slot Vector
}

TagValues="FrameIncrementPointerIsSliceVector" {
	0x0054,0x0080 = Slice Vector
}

TagValues="FrameIncrementPointerIsAngularViewVector" {
	0x0054,0x0090 = Angular View Vector
}

TagValues="FrameIncrementPointerIsTimeSliceVector" {
	0x0054,0x0100 = Time Slice Vector
}

TagValues="XAFrameDimensionPointerValues" {
	0x0018,0x1063 = Frame Time, 
	0x0018,0x1065 = Frame Time Vector,
	0x0018,0x1520 = Positioner Primary Angle Increment,
	0x0018,0x1521 = Positioner Secondary Angle Increment,
	0x0018,0x1135 = Table Vertical Increment,
	0x0018,0x1137 = Table Longitudinal Increment,
	0x0018,0x1136 = Table Lateral Increment,
	0x0018,0x2002 = Frame Label Vector
}

