#
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::DataDict;
my $Dict = {
  "0" => {
    "0" => {
      "KeyWord" => "CommandGroupLength",
      "Name" => "Command Group Length",
      "VM" => "1",
      "VR" => "UL",
      "description" => "The even number of bytes from the end of the value field to the beginning of the next group.",
      "ele" => "0000",
      "group" => "0000"
    },
    "1" => {
      "KeyWord" => "CommandLengthToEnd",
      "Name" => "Command Length to End",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0001",
      "group" => "0000"
    },
    "1024" => {
      "KeyWord" => "FindLocation",
      "Name" => "Find Location",
      "RET" => "1",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "0400",
      "group" => "0000"
    },
    "1536" => {
      "KeyWord" => "MoveDestination",
      "Name" => "Move Destination",
      "VM" => "1",
      "VR" => "AE",
      "description" => "Shall be set to the DICOM AE Title of the destination DICOM AE to which the C-STORE sub-operations are being performed.",
      "ele" => "0600",
      "group" => "0000"
    },
    "16" => {
      "KeyWord" => "CommandRecognitionCode",
      "Name" => "Command Recognition Code",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0010",
      "group" => "0000"
    },
    "16384" => {
      "KeyWord" => "DialogReceiver",
      "Name" => "Dialog Receiver",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "0000"
    },
    "16400" => {
      "KeyWord" => "TerminalType",
      "Name" => "Terminal Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4010",
      "group" => "0000"
    },
    "1792" => {
      "KeyWord" => "Priority",
      "Name" => "Priority",
      "VM" => "1",
      "VR" => "US",
      "description" => "The priority shall be set to one of the following values:
        LOW = 0002H
        MEDIUM = 0000H
        HIGH = 0001H",
      "ele" => "0700",
      "group" => "0000"
    },
    "2" => {
      "KeyWord" => "AffectedSOPClassUID",
      "Name" => "Affected SOP Class UID",
      "VM" => "1",
      "VR" => "UI",
      "description" => "The affected SOP Class UID associated with the operation.",
      "ele" => "0002",
      "group" => "0000"
    },
    "2048" => {
      "KeyWord" => "CommandDataSetType",
      "Name" => "Command Data Set Type",
      "VM" => "1",
      "VR" => "US",
      "description" => "This field indicates if a Data Set is present in the Message. This field shall be set to the value of 0101H if no Data Set is present; any other value indicates a Data Set is included in the Message.",
      "ele" => "0800",
      "group" => "0000"
    },
    "20496" => {
      "KeyWord" => "MessageSetID",
      "Name" => "Message Set ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "5010",
      "group" => "0000"
    },
    "20512" => {
      "KeyWord" => "EndMessageID",
      "Name" => "End Message ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "5020",
      "group" => "0000"
    },
    "20752" => {
      "KeyWord" => "DisplayFormat",
      "Name" => "Display Format",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "5110",
      "group" => "0000"
    },
    "20768" => {
      "KeyWord" => "PagePositionID",
      "Name" => "Page Position ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "5120",
      "group" => "0000"
    },
    "20784" => {
      "KeyWord" => "TextFormatID",
      "Name" => "Text Format ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "5130",
      "group" => "0000"
    },
    "20800" => {
      "KeyWord" => "NormalReverse",
      "Name" => "Normal/Reverse",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "5140",
      "group" => "0000"
    },
    "20816" => {
      "KeyWord" => "AddGrayScale",
      "Name" => "Add Gray Scale",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "5150",
      "group" => "0000"
    },
    "20832" => {
      "KeyWord" => "Borders",
      "Name" => "Borders",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "5160",
      "group" => "0000"
    },
    "20848" => {
      "KeyWord" => "Copies",
      "Name" => "Copies",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "5170",
      "group" => "0000"
    },
    "20864" => {
      "KeyWord" => "CommandMagnificationType",
      "Name" => "Command Magnification Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "5180",
      "group" => "0000"
    },
    "20880" => {
      "KeyWord" => "Erase",
      "Name" => "Erase",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "5190",
      "group" => "0000"
    },
    "20896" => {
      "KeyWord" => "Print",
      "Name" => "Print",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "51a0",
      "group" => "0000"
    },
    "20912" => {
      "KeyWord" => "Overlays",
      "Name" => "Overlays",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "51b0",
      "group" => "0000"
    },
    "2128" => {
      "KeyWord" => "NumberOfMatches",
      "Name" => "Number of Matches",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0850",
      "group" => "0000"
    },
    "2144" => {
      "KeyWord" => "ResponseSequenceNumber",
      "Name" => "Response Sequence Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0860",
      "group" => "0000"
    },
    "2304" => {
      "KeyWord" => "Status",
      "Name" => "Status",
      "VM" => "1",
      "VR" => "US",
      "description" => "Confirmation status of the operation. See .",
      "ele" => "0900",
      "group" => "0000"
    },
    "2305" => {
      "KeyWord" => "OffendingElement",
      "Name" => "Offending Element",
      "VM" => "1-n",
      "VR" => "AT",
      "description" => "If status is Cxxx, then this field contains a list of the elements in which the error was detected.",
      "ele" => "0901",
      "group" => "0000"
    },
    "2306" => {
      "KeyWord" => "ErrorComment",
      "Name" => "Error Comment",
      "VM" => "1",
      "VR" => "LO",
      "description" => "This field contains an application-specific text description of the error detected.",
      "ele" => "0902",
      "group" => "0000"
    },
    "2307" => {
      "KeyWord" => "ErrorID",
      "Name" => "Error ID",
      "VM" => "1",
      "VR" => "US",
      "description" => "This field shall optionally contain an application-specific error code.",
      "ele" => "0903",
      "group" => "0000"
    },
    "256" => {
      "KeyWord" => "CommandField",
      "Name" => "Command Field",
      "VM" => "1",
      "VR" => "US",
      "description" => "This field distinguishes the DIMSE operation conveyed by this Message. This field shall be set to one of the following values:
        0001H C-STORE-RQ
        8001H C-STORE-RSP
        0010H C-GET-RQ
        8010H C-GET-RSP
        0020H C-FIND-RQ
        8020H C-FIND-RSP
        0021HC-MOVE-RQ
        8021H C-MOVE-RSP
        0030H C-ECHO-RQ
        8030H C-ECHO-RSP
        0100H N-EVENT-REPORT-RQ
        8100H N-EVENT-REPORT-RSP
        0110H N-GET-RQ
        8110H N-GET-RSP
        0120H N-SET-RQ
        8120H N-SET-RSP
        0130H N-ACTION-RQ
        8130H N-ACTION-RSP
        0140H N-CREATE-RQ
        8140H N-CREATE-RSP
        0150H N-DELETE-RQ
        8150H N-DELETE-RSP
        0FFFH C-CANCEL-RQ",
      "ele" => "0100",
      "group" => "0000"
    },
    "272" => {
      "KeyWord" => "MessageID",
      "Name" => "Message ID",
      "VM" => "1",
      "VR" => "US",
      "description" => "Implementation-specific value that distinguishes this Message from other Messages.",
      "ele" => "0110",
      "group" => "0000"
    },
    "288" => {
      "KeyWord" => "MessageIDBeingRespondedTo",
      "Name" => "Message ID Being Responded To",
      "VM" => "1",
      "VR" => "US",
      "description" => "Shall be set to the value of the Message ID (0000,0110) field used in associated request Message.",
      "ele" => "0120",
      "group" => "0000"
    },
    "3" => {
      "KeyWord" => "RequestedSOPClassUID",
      "Name" => "Requested SOP Class UID",
      "VM" => "1",
      "VR" => "UI",
      "description" => "The requested SOP Class UID associated with the operation.",
      "ele" => "0003",
      "group" => "0000"
    },
    "4096" => {
      "KeyWord" => "AffectedSOPInstanceUID",
      "Name" => "Affected SOP Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "description" => "Contains the UID of the SOP Instance for which this operation occurred.",
      "ele" => "1000",
      "group" => "0000"
    },
    "4097" => {
      "KeyWord" => "RequestedSOPInstanceUID",
      "Name" => "Requested SOP Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "description" => "Contains the UID of the SOP Instance for which this operation occurred.",
      "ele" => "1001",
      "group" => "0000"
    },
    "4098" => {
      "KeyWord" => "EventTypeID",
      "Name" => "Event Type ID",
      "VM" => "1",
      "VR" => "US",
      "description" => "Values for this field are application-specific.",
      "ele" => "1002",
      "group" => "0000"
    },
    "4101" => {
      "KeyWord" => "AttributeIdentifierList",
      "Name" => "Attribute Identifier List",
      "VM" => "1-n",
      "VR" => "AT",
      "description" => "This field contains an Attribute Tag for each of the n Attributes applicable.",
      "ele" => "1005",
      "group" => "0000"
    },
    "4104" => {
      "KeyWord" => "ActionTypeID",
      "Name" => "Action Type ID",
      "VM" => "1",
      "VR" => "US",
      "description" => "Values for this field are application-specific.",
      "ele" => "1008",
      "group" => "0000"
    },
    "4128" => {
      "KeyWord" => "NumberOfRemainingSuboperations",
      "Name" => "Number of Remaining Sub-operations",
      "VM" => "1",
      "VR" => "US",
      "description" => "The number of remaining C-STORE sub-operations to be invoked for the operation.",
      "ele" => "1020",
      "group" => "0000"
    },
    "4129" => {
      "KeyWord" => "NumberOfCompletedSuboperations",
      "Name" => "Number of Completed Sub-operations",
      "VM" => "1",
      "VR" => "US",
      "description" => "The number of C-STORE sub-operations associated with this operation that have completed successfully.",
      "ele" => "1021",
      "group" => "0000"
    },
    "4130" => {
      "KeyWord" => "NumberOfFailedSuboperations",
      "Name" => "Number of Failed Sub-operations",
      "VM" => "1",
      "VR" => "US",
      "description" => "The number of C-STORE sub-operations associated with this operation that have failed.",
      "ele" => "1022",
      "group" => "0000"
    },
    "4131" => {
      "KeyWord" => "NumberOfWarningSuboperations",
      "Name" => "Number of Warning Sub-operations",
      "VM" => "1",
      "VR" => "US",
      "description" => "The number of C-STORE sub-operations associated with this operation that generated warning responses.",
      "ele" => "1023",
      "group" => "0000"
    },
    "4144" => {
      "KeyWord" => "MoveOriginatorApplicationEntityTitle",
      "Name" => "Move Originator Application Entity Title",
      "VM" => "1",
      "VR" => "AE",
      "description" => "Contains the DICOM AE Title of the DICOM AE that invoked the C-MOVE operation from which this C-STORE sub-operation is being performed.",
      "ele" => "1030",
      "group" => "0000"
    },
    "4145" => {
      "KeyWord" => "MoveOriginatorMessageID",
      "Name" => "Move Originator Message ID",
      "VM" => "1",
      "VR" => "US",
      "description" => "Contains the Message ID (0000,0110) of the C-MOVE-RQ Message from which this C-STORE sub-operation is being performed.",
      "ele" => "1031",
      "group" => "0000"
    },
    "512" => {
      "KeyWord" => "Initiator",
      "Name" => "Initiator",
      "RET" => "1",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "0200",
      "group" => "0000"
    },
    "768" => {
      "KeyWord" => "Receiver",
      "Name" => "Receiver",
      "RET" => "1",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "0300",
      "group" => "0000"
    }
  },
  "100" => {
    "15" => {
      "KeyWord" => "PreDeformationMatrixRegistrationSequence",
      "Name" => "Pre Deformation Matrix Registration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000f",
      "group" => "0064"
    },
    "16" => {
      "KeyWord" => "PostDeformationMatrixRegistrationSequence",
      "Name" => "Post Deformation Matrix Registration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "0064"
    },
    "2" => {
      "KeyWord" => "DeformableRegistrationSequence",
      "Name" => "Deformable Registration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0002",
      "group" => "0064"
    },
    "3" => {
      "KeyWord" => "SourceFrameOfReferenceUID",
      "Name" => "Source Frame of Reference UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0003",
      "group" => "0064"
    },
    "5" => {
      "KeyWord" => "DeformableRegistrationGridSequence",
      "Name" => "Deformable Registration Grid Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0005",
      "group" => "0064"
    },
    "7" => {
      "KeyWord" => "GridDimensions",
      "Name" => "Grid Dimensions",
      "VM" => "3",
      "VR" => "UL",
      "ele" => "0007",
      "group" => "0064"
    },
    "8" => {
      "KeyWord" => "GridResolution",
      "Name" => "Grid Resolution",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "0008",
      "group" => "0064"
    },
    "9" => {
      "KeyWord" => "VectorGridData",
      "Name" => "Vector Grid Data",
      "VM" => "1",
      "VR" => "OF",
      "ele" => "0009",
      "group" => "0064"
    }
  },
  "102" => {
    "1" => {
      "KeyWord" => "NumberOfSurfaces",
      "Name" => "Number of Surfaces",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0001",
      "group" => "0066"
    },
    "10" => {
      "KeyWord" => "SurfaceProcessingRatio",
      "Name" => "Surface Processing Ratio",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "000a",
      "group" => "0066"
    },
    "11" => {
      "KeyWord" => "SurfaceProcessingDescription",
      "Name" => "Surface Processing Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "000b",
      "group" => "0066"
    },
    "12" => {
      "KeyWord" => "RecommendedPresentationOpacity",
      "Name" => "Recommended Presentation Opacity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "000c",
      "group" => "0066"
    },
    "13" => {
      "KeyWord" => "RecommendedPresentationType",
      "Name" => "Recommended Presentation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000d",
      "group" => "0066"
    },
    "14" => {
      "KeyWord" => "FiniteVolume",
      "Name" => "Finite Volume",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000e",
      "group" => "0066"
    },
    "16" => {
      "KeyWord" => "Manifold",
      "Name" => "Manifold",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0010",
      "group" => "0066"
    },
    "17" => {
      "KeyWord" => "SurfacePointsSequence",
      "Name" => "Surface Points Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0011",
      "group" => "0066"
    },
    "18" => {
      "KeyWord" => "SurfacePointsNormalsSequence",
      "Name" => "Surface Points Normals Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0012",
      "group" => "0066"
    },
    "19" => {
      "KeyWord" => "SurfaceMeshPrimitivesSequence",
      "Name" => "Surface Mesh Primitives Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0013",
      "group" => "0066"
    },
    "2" => {
      "KeyWord" => "SurfaceSequence",
      "Name" => "Surface Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0002",
      "group" => "0066"
    },
    "21" => {
      "KeyWord" => "NumberOfSurfacePoints",
      "Name" => "Number of Surface Points",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0015",
      "group" => "0066"
    },
    "22" => {
      "KeyWord" => "PointCoordinatesData",
      "Name" => "Point Coordinates Data",
      "VM" => "1",
      "VR" => "OF",
      "ele" => "0016",
      "group" => "0066"
    },
    "23" => {
      "KeyWord" => "PointPositionAccuracy",
      "Name" => "Point Position Accuracy",
      "VM" => "3",
      "VR" => "FL",
      "ele" => "0017",
      "group" => "0066"
    },
    "24" => {
      "KeyWord" => "MeanPointDistance",
      "Name" => "Mean Point Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0018",
      "group" => "0066"
    },
    "25" => {
      "KeyWord" => "MaximumPointDistance",
      "Name" => "Maximum Point Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0019",
      "group" => "0066"
    },
    "26" => {
      "KeyWord" => "PointsBoundingBoxCoordinates",
      "Name" => "Points Bounding Box Coordinates",
      "VM" => "6",
      "VR" => "FL",
      "ele" => "001a",
      "group" => "0066"
    },
    "27" => {
      "KeyWord" => "AxisOfRotation",
      "Name" => "Axis of Rotation",
      "VM" => "3",
      "VR" => "FL",
      "ele" => "001b",
      "group" => "0066"
    },
    "28" => {
      "KeyWord" => "CenterOfRotation",
      "Name" => "Center of Rotation",
      "VM" => "3",
      "VR" => "FL",
      "ele" => "001c",
      "group" => "0066"
    },
    "3" => {
      "KeyWord" => "SurfaceNumber",
      "Name" => "Surface Number",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0003",
      "group" => "0066"
    },
    "30" => {
      "KeyWord" => "NumberOfVectors",
      "Name" => "Number of Vectors",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "001e",
      "group" => "0066"
    },
    "31" => {
      "KeyWord" => "VectorDimensionality",
      "Name" => "Vector Dimensionality",
      "VM" => "1",
      "VR" => "US",
      "ele" => "001f",
      "group" => "0066"
    },
    "32" => {
      "KeyWord" => "VectorAccuracy",
      "Name" => "Vector Accuracy",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "0020",
      "group" => "0066"
    },
    "33" => {
      "KeyWord" => "VectorCoordinateData",
      "Name" => "Vector Coordinate Data",
      "VM" => "1",
      "VR" => "OF",
      "ele" => "0021",
      "group" => "0066"
    },
    "35" => {
      "KeyWord" => "TrianglePointIndexList",
      "Name" => "Triangle Point Index List",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "0023",
      "group" => "0066"
    },
    "36" => {
      "KeyWord" => "EdgePointIndexList",
      "Name" => "Edge Point Index List",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "0024",
      "group" => "0066"
    },
    "37" => {
      "KeyWord" => "VertexPointIndexList",
      "Name" => "Vertex Point Index List",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "0025",
      "group" => "0066"
    },
    "38" => {
      "KeyWord" => "TriangleStripSequence",
      "Name" => "Triangle Strip Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0026",
      "group" => "0066"
    },
    "39" => {
      "KeyWord" => "TriangleFanSequence",
      "Name" => "Triangle Fan Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0027",
      "group" => "0066"
    },
    "4" => {
      "KeyWord" => "SurfaceComments",
      "Name" => "Surface Comments",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0004",
      "group" => "0066"
    },
    "40" => {
      "KeyWord" => "LineSequence",
      "Name" => "Line Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0028",
      "group" => "0066"
    },
    "41" => {
      "KeyWord" => "PrimitivePointIndexList",
      "Name" => "Primitive Point Index List",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "0029",
      "group" => "0066"
    },
    "42" => {
      "KeyWord" => "SurfaceCount",
      "Name" => "Surface Count",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "002a",
      "group" => "0066"
    },
    "43" => {
      "KeyWord" => "ReferencedSurfaceSequence",
      "Name" => "Referenced Surface Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "002b",
      "group" => "0066"
    },
    "44" => {
      "KeyWord" => "ReferencedSurfaceNumber",
      "Name" => "Referenced Surface Number",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "002c",
      "group" => "0066"
    },
    "45" => {
      "KeyWord" => "SegmentSurfaceGenerationAlgorithmIdentificationSequence",
      "Name" => "Segment Surface Generation Algorithm Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "002d",
      "group" => "0066"
    },
    "46" => {
      "KeyWord" => "SegmentSurfaceSourceInstanceSequence",
      "Name" => "Segment Surface Source Instance Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "002e",
      "group" => "0066"
    },
    "47" => {
      "KeyWord" => "AlgorithmFamilyCodeSequence",
      "Name" => "Algorithm Family Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "002f",
      "group" => "0066"
    },
    "48" => {
      "KeyWord" => "AlgorithmNameCodeSequence",
      "Name" => "Algorithm Name Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0030",
      "group" => "0066"
    },
    "49" => {
      "KeyWord" => "AlgorithmVersion",
      "Name" => "Algorithm Version",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0031",
      "group" => "0066"
    },
    "50" => {
      "KeyWord" => "AlgorithmParameters",
      "Name" => "Algorithm Parameters",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0032",
      "group" => "0066"
    },
    "52" => {
      "KeyWord" => "FacetSequence",
      "Name" => "Facet Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0034",
      "group" => "0066"
    },
    "53" => {
      "KeyWord" => "SurfaceProcessingAlgorithmIdentificationSequence",
      "Name" => "Surface Processing Algorithm Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0035",
      "group" => "0066"
    },
    "54" => {
      "KeyWord" => "AlgorithmName",
      "Name" => "Algorithm Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0036",
      "group" => "0066"
    },
    "55" => {
      "KeyWord" => "RecommendedPointRadius",
      "Name" => "Recommended Point Radius",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0037",
      "group" => "0066"
    },
    "56" => {
      "KeyWord" => "RecommendedLineThickness",
      "Name" => "Recommended Line Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0038",
      "group" => "0066"
    },
    "9" => {
      "KeyWord" => "SurfaceProcessing",
      "Name" => "Surface Processing",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0009",
      "group" => "0066"
    }
  },
  "1024" => {
    "1025" => {
      "KeyWord" => "DigitalSignaturePurposeCodeSequence",
      "Name" => "Digital Signature Purpose Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0401",
      "group" => "0400"
    },
    "1026" => {
      "KeyWord" => "ReferencedDigitalSignatureSequence",
      "Name" => "Referenced Digital Signature Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0402",
      "group" => "0400"
    },
    "1027" => {
      "KeyWord" => "ReferencedSOPInstanceMACSequence",
      "Name" => "Referenced SOP Instance MAC Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0403",
      "group" => "0400"
    },
    "1028" => {
      "KeyWord" => "MAC",
      "Name" => "MAC",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0404",
      "group" => "0400"
    },
    "1280" => {
      "KeyWord" => "EncryptedAttributesSequence",
      "Name" => "Encrypted Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0500",
      "group" => "0400"
    },
    "1296" => {
      "KeyWord" => "EncryptedContentTransferSyntaxUID",
      "Name" => "Encrypted Content Transfer Syntax UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0510",
      "group" => "0400"
    },
    "1312" => {
      "KeyWord" => "EncryptedContent",
      "Name" => "Encrypted Content",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0520",
      "group" => "0400"
    },
    "1360" => {
      "KeyWord" => "ModifiedAttributesSequence",
      "Name" => "Modified Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0550",
      "group" => "0400"
    },
    "1377" => {
      "KeyWord" => "OriginalAttributesSequence",
      "Name" => "Original Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0561",
      "group" => "0400"
    },
    "1378" => {
      "KeyWord" => "AttributeModificationDateTime",
      "Name" => "Attribute Modification DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "0562",
      "group" => "0400"
    },
    "1379" => {
      "KeyWord" => "ModifyingSystem",
      "Name" => "Modifying System",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0563",
      "group" => "0400"
    },
    "1380" => {
      "KeyWord" => "SourceOfPreviousValues",
      "Name" => "Source of Previous Values",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0564",
      "group" => "0400"
    },
    "1381" => {
      "KeyWord" => "ReasonForTheAttributeModification",
      "Name" => "Reason for the Attribute Modification",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0565",
      "group" => "0400"
    },
    "16" => {
      "KeyWord" => "MACCalculationTransferSyntaxUID",
      "Name" => "MAC Calculation Transfer Syntax UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0010",
      "group" => "0400"
    },
    "21" => {
      "KeyWord" => "MACAlgorithm",
      "Name" => "MAC Algorithm",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0015",
      "group" => "0400"
    },
    "256" => {
      "KeyWord" => "DigitalSignatureUID",
      "Name" => "Digital Signature UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0100",
      "group" => "0400"
    },
    "261" => {
      "KeyWord" => "DigitalSignatureDateTime",
      "Name" => "Digital Signature DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "0105",
      "group" => "0400"
    },
    "272" => {
      "KeyWord" => "CertificateType",
      "Name" => "Certificate Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0110",
      "group" => "0400"
    },
    "277" => {
      "KeyWord" => "CertificateOfSigner",
      "Name" => "Certificate of Signer",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0115",
      "group" => "0400"
    },
    "288" => {
      "KeyWord" => "Signature",
      "Name" => "Signature",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0120",
      "group" => "0400"
    },
    "32" => {
      "KeyWord" => "DataElementsSigned",
      "Name" => "Data Elements Signed",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "0020",
      "group" => "0400"
    },
    "5" => {
      "KeyWord" => "MACIDNumber",
      "Name" => "MAC ID Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0005",
      "group" => "0400"
    },
    "773" => {
      "KeyWord" => "CertifiedTimestampType",
      "Name" => "Certified Timestamp Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0305",
      "group" => "0400"
    },
    "784" => {
      "KeyWord" => "CertifiedTimestamp",
      "Name" => "Certified Timestamp",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0310",
      "group" => "0400"
    }
  },
  "104" => {
    "25104" => {
      "KeyWord" => "ImplantSize",
      "Name" => "Implant Size",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "6210",
      "group" => "0068"
    },
    "25121" => {
      "KeyWord" => "ImplantTemplateVersion",
      "Name" => "Implant Template Version",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "6221",
      "group" => "0068"
    },
    "25122" => {
      "KeyWord" => "ReplacedImplantTemplateSequence",
      "Name" => "Replaced Implant Template Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6222",
      "group" => "0068"
    },
    "25123" => {
      "KeyWord" => "ImplantType",
      "Name" => "Implant Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "6223",
      "group" => "0068"
    },
    "25124" => {
      "KeyWord" => "DerivationImplantTemplateSequence",
      "Name" => "Derivation Implant Template Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6224",
      "group" => "0068"
    },
    "25125" => {
      "KeyWord" => "OriginalImplantTemplateSequence",
      "Name" => "Original Implant Template Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6225",
      "group" => "0068"
    },
    "25126" => {
      "KeyWord" => "EffectiveDateTime",
      "Name" => "Effective DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "6226",
      "group" => "0068"
    },
    "25136" => {
      "KeyWord" => "ImplantTargetAnatomySequence",
      "Name" => "Implant Target Anatomy Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6230",
      "group" => "0068"
    },
    "25184" => {
      "KeyWord" => "InformationFromManufacturerSequence",
      "Name" => "Information From Manufacturer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6260",
      "group" => "0068"
    },
    "25189" => {
      "KeyWord" => "NotificationFromManufacturerSequence",
      "Name" => "Notification From Manufacturer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6265",
      "group" => "0068"
    },
    "25200" => {
      "KeyWord" => "InformationIssueDateTime",
      "Name" => "Information Issue DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "6270",
      "group" => "0068"
    },
    "25216" => {
      "KeyWord" => "InformationSummary",
      "Name" => "Information Summary",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "6280",
      "group" => "0068"
    },
    "25248" => {
      "KeyWord" => "ImplantRegulatoryDisapprovalCodeSequence",
      "Name" => "Implant Regulatory Disapproval Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "62a0",
      "group" => "0068"
    },
    "25253" => {
      "KeyWord" => "OverallTemplateSpatialTolerance",
      "Name" => "Overall Template Spatial Tolerance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "62a5",
      "group" => "0068"
    },
    "25280" => {
      "KeyWord" => "HPGLDocumentSequence",
      "Name" => "HPGL Document Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "62c0",
      "group" => "0068"
    },
    "25296" => {
      "KeyWord" => "HPGLDocumentID",
      "Name" => "HPGL Document ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "62d0",
      "group" => "0068"
    },
    "25301" => {
      "KeyWord" => "HPGLDocumentLabel",
      "Name" => "HPGL Document Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "62d5",
      "group" => "0068"
    },
    "25312" => {
      "KeyWord" => "ViewOrientationCodeSequence",
      "Name" => "View Orientation Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "62e0",
      "group" => "0068"
    },
    "25328" => {
      "KeyWord" => "ViewOrientationModifier",
      "Name" => "View Orientation Modifier",
      "VM" => "9",
      "VR" => "FD",
      "ele" => "62f0",
      "group" => "0068"
    },
    "25330" => {
      "KeyWord" => "HPGLDocumentScaling",
      "Name" => "HPGL Document Scaling",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "62f2",
      "group" => "0068"
    },
    "25344" => {
      "KeyWord" => "HPGLDocument",
      "Name" => "HPGL Document",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "6300",
      "group" => "0068"
    },
    "25360" => {
      "KeyWord" => "HPGLContourPenNumber",
      "Name" => "HPGL Contour Pen Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6310",
      "group" => "0068"
    },
    "25376" => {
      "KeyWord" => "HPGLPenSequence",
      "Name" => "HPGL Pen Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6320",
      "group" => "0068"
    },
    "25392" => {
      "KeyWord" => "HPGLPenNumber",
      "Name" => "HPGL Pen Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6330",
      "group" => "0068"
    },
    "25408" => {
      "KeyWord" => "HPGLPenLabel",
      "Name" => "HPGL Pen Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "6340",
      "group" => "0068"
    },
    "25413" => {
      "KeyWord" => "HPGLPenDescription",
      "Name" => "HPGL Pen Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "6345",
      "group" => "0068"
    },
    "25414" => {
      "KeyWord" => "RecommendedRotationPoint",
      "Name" => "Recommended Rotation Point",
      "VM" => "2",
      "VR" => "FD",
      "ele" => "6346",
      "group" => "0068"
    },
    "25415" => {
      "KeyWord" => "BoundingRectangle",
      "Name" => "Bounding Rectangle",
      "VM" => "4",
      "VR" => "FD",
      "ele" => "6347",
      "group" => "0068"
    },
    "25424" => {
      "KeyWord" => "ImplantTemplate3DModelSurfaceNumber",
      "Name" => "Implant Template 3D Model Surface Number",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "6350",
      "group" => "0068"
    },
    "25440" => {
      "KeyWord" => "SurfaceModelDescriptionSequence",
      "Name" => "Surface Model Description Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6360",
      "group" => "0068"
    },
    "25472" => {
      "KeyWord" => "SurfaceModelLabel",
      "Name" => "Surface Model Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "6380",
      "group" => "0068"
    },
    "25488" => {
      "KeyWord" => "SurfaceModelScalingFactor",
      "Name" => "Surface Model Scaling Factor",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "6390",
      "group" => "0068"
    },
    "25504" => {
      "KeyWord" => "MaterialsCodeSequence",
      "Name" => "Materials Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "63a0",
      "group" => "0068"
    },
    "25508" => {
      "KeyWord" => "CoatingMaterialsCodeSequence",
      "Name" => "Coating Materials Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "63a4",
      "group" => "0068"
    },
    "25512" => {
      "KeyWord" => "ImplantTypeCodeSequence",
      "Name" => "Implant Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "63a8",
      "group" => "0068"
    },
    "25516" => {
      "KeyWord" => "FixationMethodCodeSequence",
      "Name" => "Fixation Method Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "63ac",
      "group" => "0068"
    },
    "25520" => {
      "KeyWord" => "MatingFeatureSetsSequence",
      "Name" => "Mating Feature Sets Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "63b0",
      "group" => "0068"
    },
    "25536" => {
      "KeyWord" => "MatingFeatureSetID",
      "Name" => "Mating Feature Set ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "63c0",
      "group" => "0068"
    },
    "25552" => {
      "KeyWord" => "MatingFeatureSetLabel",
      "Name" => "Mating Feature Set Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "63d0",
      "group" => "0068"
    },
    "25568" => {
      "KeyWord" => "MatingFeatureSequence",
      "Name" => "Mating Feature Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "63e0",
      "group" => "0068"
    },
    "25584" => {
      "KeyWord" => "MatingFeatureID",
      "Name" => "Mating Feature ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "63f0",
      "group" => "0068"
    },
    "25600" => {
      "KeyWord" => "MatingFeatureDegreeOfFreedomSequence",
      "Name" => "Mating Feature Degree of Freedom Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6400",
      "group" => "0068"
    },
    "25616" => {
      "KeyWord" => "DegreeOfFreedomID",
      "Name" => "Degree of Freedom ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6410",
      "group" => "0068"
    },
    "25632" => {
      "KeyWord" => "DegreeOfFreedomType",
      "Name" => "Degree of Freedom Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "6420",
      "group" => "0068"
    },
    "25648" => {
      "KeyWord" => "TwoDMatingFeatureCoordinatesSequence",
      "Name" => "2D Mating Feature Coordinates Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6430",
      "group" => "0068"
    },
    "25664" => {
      "KeyWord" => "ReferencedHPGLDocumentID",
      "Name" => "Referenced HPGL Document ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6440",
      "group" => "0068"
    },
    "25680" => {
      "KeyWord" => "TwoDMatingPoint",
      "Name" => "2D Mating Point",
      "VM" => "2",
      "VR" => "FD",
      "ele" => "6450",
      "group" => "0068"
    },
    "25696" => {
      "KeyWord" => "TwoDMatingAxes",
      "Name" => "2D Mating Axes",
      "VM" => "4",
      "VR" => "FD",
      "ele" => "6460",
      "group" => "0068"
    },
    "25712" => {
      "KeyWord" => "TwoDDegreeOfFreedomSequence",
      "Name" => "2D Degree of Freedom Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6470",
      "group" => "0068"
    },
    "25744" => {
      "KeyWord" => "ThreeDDegreeOfFreedomAxis",
      "Name" => "3D Degree of Freedom Axis",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "6490",
      "group" => "0068"
    },
    "25760" => {
      "KeyWord" => "RangeOfFreedom",
      "Name" => "Range of Freedom",
      "VM" => "2",
      "VR" => "FD",
      "ele" => "64a0",
      "group" => "0068"
    },
    "25792" => {
      "KeyWord" => "ThreeDMatingPoint",
      "Name" => "3D Mating Point",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "64c0",
      "group" => "0068"
    },
    "25808" => {
      "KeyWord" => "ThreeDMatingAxes",
      "Name" => "3D Mating Axes",
      "VM" => "9",
      "VR" => "FD",
      "ele" => "64d0",
      "group" => "0068"
    },
    "25840" => {
      "KeyWord" => "TwoDDegreeOfFreedomAxis",
      "Name" => "2D Degree of Freedom Axis",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "64f0",
      "group" => "0068"
    },
    "25856" => {
      "KeyWord" => "PlanningLandmarkPointSequence",
      "Name" => "Planning Landmark Point Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6500",
      "group" => "0068"
    },
    "25872" => {
      "KeyWord" => "PlanningLandmarkLineSequence",
      "Name" => "Planning Landmark Line Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6510",
      "group" => "0068"
    },
    "25888" => {
      "KeyWord" => "PlanningLandmarkPlaneSequence",
      "Name" => "Planning Landmark Plane Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6520",
      "group" => "0068"
    },
    "25904" => {
      "KeyWord" => "PlanningLandmarkID",
      "Name" => "Planning Landmark ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6530",
      "group" => "0068"
    },
    "25920" => {
      "KeyWord" => "PlanningLandmarkDescription",
      "Name" => "Planning Landmark Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "6540",
      "group" => "0068"
    },
    "25925" => {
      "KeyWord" => "PlanningLandmarkIdentificationCodeSequence",
      "Name" => "Planning Landmark Identification Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6545",
      "group" => "0068"
    },
    "25936" => {
      "KeyWord" => "TwoDPointCoordinatesSequence",
      "Name" => "2D Point Coordinates Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6550",
      "group" => "0068"
    },
    "25952" => {
      "KeyWord" => "TwoDPointCoordinates",
      "Name" => "2D Point Coordinates",
      "VM" => "2",
      "VR" => "FD",
      "ele" => "6560",
      "group" => "0068"
    },
    "26000" => {
      "KeyWord" => "ThreeDPointCoordinates",
      "Name" => "3D Point Coordinates",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "6590",
      "group" => "0068"
    },
    "26016" => {
      "KeyWord" => "TwoDLineCoordinatesSequence",
      "Name" => "2D Line Coordinates Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "65a0",
      "group" => "0068"
    },
    "26032" => {
      "KeyWord" => "TwoDLineCoordinates",
      "Name" => "2D Line Coordinates",
      "VM" => "4",
      "VR" => "FD",
      "ele" => "65b0",
      "group" => "0068"
    },
    "26064" => {
      "KeyWord" => "ThreeDLineCoordinates",
      "Name" => "3D Line Coordinates",
      "VM" => "6",
      "VR" => "FD",
      "ele" => "65d0",
      "group" => "0068"
    },
    "26080" => {
      "KeyWord" => "TwoDPlaneCoordinatesSequence",
      "Name" => "2D Plane Coordinates Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "65e0",
      "group" => "0068"
    },
    "26096" => {
      "KeyWord" => "TwoDPlaneIntersection",
      "Name" => "2D Plane Intersection",
      "VM" => "4",
      "VR" => "FD",
      "ele" => "65f0",
      "group" => "0068"
    },
    "26128" => {
      "KeyWord" => "ThreeDPlaneOrigin",
      "Name" => "3D Plane Origin",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "6610",
      "group" => "0068"
    },
    "26144" => {
      "KeyWord" => "ThreeDPlaneNormal",
      "Name" => "3D Plane Normal",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "6620",
      "group" => "0068"
    }
  },
  "112" => {
    "1" => {
      "KeyWord" => "GraphicAnnotationSequence",
      "Name" => "Graphic Annotation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0001",
      "group" => "0070"
    },
    "102" => {
      "KeyWord" => "GraphicLayerRecommendedDisplayGrayscaleValue",
      "Name" => "Graphic Layer Recommended Display Grayscale Value",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0066",
      "group" => "0070"
    },
    "1025" => {
      "KeyWord" => "GraphicLayerRecommendedDisplayCIELabValue",
      "Name" => "Graphic Layer Recommended Display CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0401",
      "group" => "0070"
    },
    "1026" => {
      "KeyWord" => "BlendingSequence",
      "Name" => "Blending Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0402",
      "group" => "0070"
    },
    "1027" => {
      "KeyWord" => "RelativeOpacity",
      "Name" => "Relative Opacity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0403",
      "group" => "0070"
    },
    "1028" => {
      "KeyWord" => "ReferencedSpatialRegistrationSequence",
      "Name" => "Referenced Spatial Registration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0404",
      "group" => "0070"
    },
    "1029" => {
      "KeyWord" => "BlendingPosition",
      "Name" => "Blending Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0405",
      "group" => "0070"
    },
    "103" => {
      "KeyWord" => "GraphicLayerRecommendedDisplayRGBValue",
      "Name" => "Graphic Layer Recommended Display RGB Value",
      "RET" => "1",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0067",
      "group" => "0070"
    },
    "104" => {
      "KeyWord" => "GraphicLayerDescription",
      "Name" => "Graphic Layer Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0068",
      "group" => "0070"
    },
    "128" => {
      "KeyWord" => "ContentLabel",
      "Name" => "Content Label",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0080",
      "group" => "0070"
    },
    "129" => {
      "KeyWord" => "ContentDescription",
      "Name" => "Content Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0081",
      "group" => "0070"
    },
    "130" => {
      "KeyWord" => "PresentationCreationDate",
      "Name" => "Presentation Creation Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0082",
      "group" => "0070"
    },
    "131" => {
      "KeyWord" => "PresentationCreationTime",
      "Name" => "Presentation Creation Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0083",
      "group" => "0070"
    },
    "132" => {
      "KeyWord" => "ContentCreatorName",
      "Name" => "Content Creator's Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "0084",
      "group" => "0070"
    },
    "134" => {
      "KeyWord" => "ContentCreatorIdentificationCodeSequence",
      "Name" => "Content Creator's Identification Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0086",
      "group" => "0070"
    },
    "135" => {
      "KeyWord" => "AlternateContentDescriptionSequence",
      "Name" => "Alternate Content Description Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0087",
      "group" => "0070"
    },
    "16" => {
      "KeyWord" => "BoundingBoxTopLeftHandCorner",
      "Name" => "Bounding Box Top Left Hand Corner",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "0010",
      "group" => "0070"
    },
    "17" => {
      "KeyWord" => "BoundingBoxBottomRightHandCorner",
      "Name" => "Bounding Box Bottom Right Hand Corner",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "0011",
      "group" => "0070"
    },
    "18" => {
      "KeyWord" => "BoundingBoxTextHorizontalJustification",
      "Name" => "Bounding Box Text Horizontal Justification",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0012",
      "group" => "0070"
    },
    "2" => {
      "KeyWord" => "GraphicLayer",
      "Name" => "Graphic Layer",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0002",
      "group" => "0070"
    },
    "20" => {
      "KeyWord" => "AnchorPoint",
      "Name" => "Anchor Point",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "0014",
      "group" => "0070"
    },
    "21" => {
      "KeyWord" => "AnchorPointVisibility",
      "Name" => "Anchor Point Visibility",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0015",
      "group" => "0070"
    },
    "256" => {
      "KeyWord" => "PresentationSizeMode",
      "Name" => "Presentation Size Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0100",
      "group" => "0070"
    },
    "257" => {
      "KeyWord" => "PresentationPixelSpacing",
      "Name" => "Presentation Pixel Spacing",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "0101",
      "group" => "0070"
    },
    "258" => {
      "KeyWord" => "PresentationPixelAspectRatio",
      "Name" => "Presentation Pixel Aspect Ratio",
      "VM" => "2",
      "VR" => "IS",
      "ele" => "0102",
      "group" => "0070"
    },
    "259" => {
      "KeyWord" => "PresentationPixelMagnificationRatio",
      "Name" => "Presentation Pixel Magnification Ratio",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0103",
      "group" => "0070"
    },
    "3" => {
      "KeyWord" => "BoundingBoxAnnotationUnits",
      "Name" => "Bounding Box Annotation Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0003",
      "group" => "0070"
    },
    "32" => {
      "KeyWord" => "GraphicDimensions",
      "Name" => "Graphic Dimensions",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0020",
      "group" => "0070"
    },
    "33" => {
      "KeyWord" => "NumberOfGraphicPoints",
      "Name" => "Number of Graphic Points",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0021",
      "group" => "0070"
    },
    "34" => {
      "KeyWord" => "GraphicData",
      "Name" => "Graphic Data",
      "VM" => "2-n",
      "VR" => "FL",
      "ele" => "0022",
      "group" => "0070"
    },
    "35" => {
      "KeyWord" => "GraphicType",
      "Name" => "Graphic Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0023",
      "group" => "0070"
    },
    "36" => {
      "KeyWord" => "GraphicFilled",
      "Name" => "Graphic Filled",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0024",
      "group" => "0070"
    },
    "4" => {
      "KeyWord" => "AnchorPointAnnotationUnits",
      "Name" => "Anchor Point Annotation Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0004",
      "group" => "0070"
    },
    "5" => {
      "KeyWord" => "GraphicAnnotationUnits",
      "Name" => "Graphic Annotation Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0005",
      "group" => "0070"
    },
    "519" => {
      "KeyWord" => "GraphicGroupLabel",
      "Name" => "Graphic Group Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0207",
      "group" => "0070"
    },
    "520" => {
      "KeyWord" => "GraphicGroupDescription",
      "Name" => "Graphic Group Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0208",
      "group" => "0070"
    },
    "521" => {
      "KeyWord" => "CompoundGraphicSequence",
      "Name" => "Compound Graphic Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0209",
      "group" => "0070"
    },
    "550" => {
      "KeyWord" => "CompoundGraphicInstanceID",
      "Name" => "Compound Graphic Instance ID",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0226",
      "group" => "0070"
    },
    "551" => {
      "KeyWord" => "FontName",
      "Name" => "Font Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0227",
      "group" => "0070"
    },
    "552" => {
      "KeyWord" => "FontNameType",
      "Name" => "Font Name Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0228",
      "group" => "0070"
    },
    "553" => {
      "KeyWord" => "CSSFontName",
      "Name" => "CSS Font Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0229",
      "group" => "0070"
    },
    "560" => {
      "KeyWord" => "RotationAngle",
      "Name" => "Rotation Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0230",
      "group" => "0070"
    },
    "561" => {
      "KeyWord" => "TextStyleSequence",
      "Name" => "Text Style Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0231",
      "group" => "0070"
    },
    "562" => {
      "KeyWord" => "LineStyleSequence",
      "Name" => "Line Style Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0232",
      "group" => "0070"
    },
    "563" => {
      "KeyWord" => "FillStyleSequence",
      "Name" => "Fill Style Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0233",
      "group" => "0070"
    },
    "564" => {
      "KeyWord" => "GraphicGroupSequence",
      "Name" => "Graphic Group Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0234",
      "group" => "0070"
    },
    "577" => {
      "KeyWord" => "TextColorCIELabValue",
      "Name" => "Text Color CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0241",
      "group" => "0070"
    },
    "578" => {
      "KeyWord" => "HorizontalAlignment",
      "Name" => "Horizontal Alignment",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0242",
      "group" => "0070"
    },
    "579" => {
      "KeyWord" => "VerticalAlignment",
      "Name" => "Vertical Alignment",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0243",
      "group" => "0070"
    },
    "580" => {
      "KeyWord" => "ShadowStyle",
      "Name" => "Shadow Style",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0244",
      "group" => "0070"
    },
    "581" => {
      "KeyWord" => "ShadowOffsetX",
      "Name" => "Shadow Offset X",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0245",
      "group" => "0070"
    },
    "582" => {
      "KeyWord" => "ShadowOffsetY",
      "Name" => "Shadow Offset Y",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0246",
      "group" => "0070"
    },
    "583" => {
      "KeyWord" => "ShadowColorCIELabValue",
      "Name" => "Shadow Color CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0247",
      "group" => "0070"
    },
    "584" => {
      "KeyWord" => "Underlined",
      "Name" => "Underlined",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0248",
      "group" => "0070"
    },
    "585" => {
      "KeyWord" => "Bold",
      "Name" => "Bold",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0249",
      "group" => "0070"
    },
    "592" => {
      "KeyWord" => "Italic",
      "Name" => "Italic",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0250",
      "group" => "0070"
    },
    "593" => {
      "KeyWord" => "PatternOnColorCIELabValue",
      "Name" => "Pattern On Color CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0251",
      "group" => "0070"
    },
    "594" => {
      "KeyWord" => "PatternOffColorCIELabValue",
      "Name" => "Pattern Off Color CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0252",
      "group" => "0070"
    },
    "595" => {
      "KeyWord" => "LineThickness",
      "Name" => "Line Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0253",
      "group" => "0070"
    },
    "596" => {
      "KeyWord" => "LineDashingStyle",
      "Name" => "Line Dashing Style",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0254",
      "group" => "0070"
    },
    "597" => {
      "KeyWord" => "LinePattern",
      "Name" => "Line Pattern",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0255",
      "group" => "0070"
    },
    "598" => {
      "KeyWord" => "FillPattern",
      "Name" => "Fill Pattern",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0256",
      "group" => "0070"
    },
    "599" => {
      "KeyWord" => "FillMode",
      "Name" => "Fill Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0257",
      "group" => "0070"
    },
    "6" => {
      "KeyWord" => "UnformattedTextValue",
      "Name" => "Unformatted Text Value",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0006",
      "group" => "0070"
    },
    "600" => {
      "KeyWord" => "ShadowOpacity",
      "Name" => "Shadow Opacity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0258",
      "group" => "0070"
    },
    "609" => {
      "KeyWord" => "GapLength",
      "Name" => "Gap Length",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0261",
      "group" => "0070"
    },
    "610" => {
      "KeyWord" => "DiameterOfVisibility",
      "Name" => "Diameter of Visibility",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0262",
      "group" => "0070"
    },
    "627" => {
      "KeyWord" => "RotationPoint",
      "Name" => "Rotation Point",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "0273",
      "group" => "0070"
    },
    "628" => {
      "KeyWord" => "TickAlignment",
      "Name" => "Tick Alignment",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0274",
      "group" => "0070"
    },
    "632" => {
      "KeyWord" => "ShowTickLabel",
      "Name" => "Show Tick Label",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0278",
      "group" => "0070"
    },
    "633" => {
      "KeyWord" => "TickLabelAlignment",
      "Name" => "Tick Label Alignment",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0279",
      "group" => "0070"
    },
    "64" => {
      "KeyWord" => "ImageRotationRetired",
      "Name" => "Image Rotation (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0040",
      "group" => "0070"
    },
    "642" => {
      "KeyWord" => "CompoundGraphicUnits",
      "Name" => "Compound Graphic Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0282",
      "group" => "0070"
    },
    "644" => {
      "KeyWord" => "PatternOnOpacity",
      "Name" => "Pattern On Opacity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0284",
      "group" => "0070"
    },
    "645" => {
      "KeyWord" => "PatternOffOpacity",
      "Name" => "Pattern Off Opacity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0285",
      "group" => "0070"
    },
    "647" => {
      "KeyWord" => "MajorTicksSequence",
      "Name" => "Major Ticks Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0287",
      "group" => "0070"
    },
    "648" => {
      "KeyWord" => "TickPosition",
      "Name" => "Tick Position",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0288",
      "group" => "0070"
    },
    "649" => {
      "KeyWord" => "TickLabel",
      "Name" => "Tick Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0289",
      "group" => "0070"
    },
    "65" => {
      "KeyWord" => "ImageHorizontalFlip",
      "Name" => "Image Horizontal Flip",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0041",
      "group" => "0070"
    },
    "66" => {
      "KeyWord" => "ImageRotation",
      "Name" => "Image Rotation",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0042",
      "group" => "0070"
    },
    "660" => {
      "KeyWord" => "CompoundGraphicType",
      "Name" => "Compound Graphic Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0294",
      "group" => "0070"
    },
    "661" => {
      "KeyWord" => "GraphicGroupID",
      "Name" => "Graphic Group ID",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0295",
      "group" => "0070"
    },
    "774" => {
      "KeyWord" => "ShapeType",
      "Name" => "Shape Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0306",
      "group" => "0070"
    },
    "776" => {
      "KeyWord" => "RegistrationSequence",
      "Name" => "Registration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0308",
      "group" => "0070"
    },
    "777" => {
      "KeyWord" => "MatrixRegistrationSequence",
      "Name" => "Matrix Registration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0309",
      "group" => "0070"
    },
    "778" => {
      "KeyWord" => "MatrixSequence",
      "Name" => "Matrix Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "030a",
      "group" => "0070"
    },
    "780" => {
      "KeyWord" => "FrameOfReferenceTransformationMatrixType",
      "Name" => "Frame of Reference Transformation Matrix Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "030c",
      "group" => "0070"
    },
    "781" => {
      "KeyWord" => "RegistrationTypeCodeSequence",
      "Name" => "Registration Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "030d",
      "group" => "0070"
    },
    "783" => {
      "KeyWord" => "FiducialDescription",
      "Name" => "Fiducial Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "030f",
      "group" => "0070"
    },
    "784" => {
      "KeyWord" => "FiducialIdentifier",
      "Name" => "Fiducial Identifier",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0310",
      "group" => "0070"
    },
    "785" => {
      "KeyWord" => "FiducialIdentifierCodeSequence",
      "Name" => "Fiducial Identifier Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0311",
      "group" => "0070"
    },
    "786" => {
      "KeyWord" => "ContourUncertaintyRadius",
      "Name" => "Contour Uncertainty Radius",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0312",
      "group" => "0070"
    },
    "788" => {
      "KeyWord" => "UsedFiducialsSequence",
      "Name" => "Used Fiducials Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0314",
      "group" => "0070"
    },
    "792" => {
      "KeyWord" => "GraphicCoordinatesDataSequence",
      "Name" => "Graphic Coordinates Data Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0318",
      "group" => "0070"
    },
    "794" => {
      "KeyWord" => "FiducialUID",
      "Name" => "Fiducial UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "031a",
      "group" => "0070"
    },
    "796" => {
      "KeyWord" => "FiducialSetSequence",
      "Name" => "Fiducial Set Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "031c",
      "group" => "0070"
    },
    "798" => {
      "KeyWord" => "FiducialSequence",
      "Name" => "Fiducial Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "031e",
      "group" => "0070"
    },
    "8" => {
      "KeyWord" => "TextObjectSequence",
      "Name" => "Text Object Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0008",
      "group" => "0070"
    },
    "80" => {
      "KeyWord" => "DisplayedAreaTopLeftHandCornerTrial",
      "Name" => "Displayed Area Top Left Hand Corner (Trial)",
      "RET" => "1",
      "VM" => "2",
      "VR" => "US",
      "ele" => "0050",
      "group" => "0070"
    },
    "81" => {
      "KeyWord" => "DisplayedAreaBottomRightHandCornerTrial",
      "Name" => "Displayed Area Bottom Right Hand Corner (Trial)",
      "RET" => "1",
      "VM" => "2",
      "VR" => "US",
      "ele" => "0051",
      "group" => "0070"
    },
    "82" => {
      "KeyWord" => "DisplayedAreaTopLeftHandCorner",
      "Name" => "Displayed Area Top Left Hand Corner",
      "VM" => "2",
      "VR" => "SL",
      "ele" => "0052",
      "group" => "0070"
    },
    "83" => {
      "KeyWord" => "DisplayedAreaBottomRightHandCorner",
      "Name" => "Displayed Area Bottom Right Hand Corner",
      "VM" => "2",
      "VR" => "SL",
      "ele" => "0053",
      "group" => "0070"
    },
    "9" => {
      "KeyWord" => "GraphicObjectSequence",
      "Name" => "Graphic Object Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0009",
      "group" => "0070"
    },
    "90" => {
      "KeyWord" => "DisplayedAreaSelectionSequence",
      "Name" => "Displayed Area Selection Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "005a",
      "group" => "0070"
    },
    "96" => {
      "KeyWord" => "GraphicLayerSequence",
      "Name" => "Graphic Layer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0060",
      "group" => "0070"
    },
    "98" => {
      "KeyWord" => "GraphicLayerOrder",
      "Name" => "Graphic Layer Order",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0062",
      "group" => "0070"
    }
  },
  "114" => {
    "10" => {
      "KeyWord" => "HangingProtocolCreationDateTime",
      "Name" => "Hanging Protocol Creation DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "000a",
      "group" => "0072"
    },
    "100" => {
      "KeyWord" => "SelectorISValue",
      "Name" => "Selector IS Value",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "0064",
      "group" => "0072"
    },
    "102" => {
      "KeyWord" => "SelectorLOValue",
      "Name" => "Selector LO Value",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0066",
      "group" => "0072"
    },
    "1024" => {
      "KeyWord" => "FilterOperationsSequence",
      "Name" => "Filter Operations Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0400",
      "group" => "0072"
    },
    "1026" => {
      "KeyWord" => "FilterByCategory",
      "Name" => "Filter-by Category",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0402",
      "group" => "0072"
    },
    "1028" => {
      "KeyWord" => "FilterByAttributePresence",
      "Name" => "Filter-by Attribute Presence",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0404",
      "group" => "0072"
    },
    "1030" => {
      "KeyWord" => "FilterByOperator",
      "Name" => "Filter-by Operator",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0406",
      "group" => "0072"
    },
    "104" => {
      "KeyWord" => "SelectorLTValue",
      "Name" => "Selector LT Value",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0068",
      "group" => "0072"
    },
    "1056" => {
      "KeyWord" => "StructuredDisplayBackgroundCIELabValue",
      "Name" => "Structured Display Background CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0420",
      "group" => "0072"
    },
    "1057" => {
      "KeyWord" => "EmptyImageBoxCIELabValue",
      "Name" => "Empty Image Box CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0421",
      "group" => "0072"
    },
    "1058" => {
      "KeyWord" => "StructuredDisplayImageBoxSequence",
      "Name" => "Structured Display Image Box Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0422",
      "group" => "0072"
    },
    "106" => {
      "KeyWord" => "SelectorPNValue",
      "Name" => "Selector PN Value",
      "VM" => "1-n",
      "VR" => "PN",
      "ele" => "006a",
      "group" => "0072"
    },
    "1060" => {
      "KeyWord" => "StructuredDisplayTextBoxSequence",
      "Name" => "Structured Display Text Box Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0424",
      "group" => "0072"
    },
    "1063" => {
      "KeyWord" => "ReferencedFirstFrameSequence",
      "Name" => "Referenced First Frame Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0427",
      "group" => "0072"
    },
    "1072" => {
      "KeyWord" => "ImageBoxSynchronizationSequence",
      "Name" => "Image Box Synchronization Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0430",
      "group" => "0072"
    },
    "1074" => {
      "KeyWord" => "SynchronizedImageBoxList",
      "Name" => "Synchronized Image Box List",
      "VM" => "2-n",
      "VR" => "US",
      "ele" => "0432",
      "group" => "0072"
    },
    "1076" => {
      "KeyWord" => "TypeOfSynchronization",
      "Name" => "Type of Synchronization",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0434",
      "group" => "0072"
    },
    "108" => {
      "KeyWord" => "SelectorSHValue",
      "Name" => "Selector SH Value",
      "VM" => "1-n",
      "VR" => "SH",
      "ele" => "006c",
      "group" => "0072"
    },
    "110" => {
      "KeyWord" => "SelectorSTValue",
      "Name" => "Selector ST Value",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "006e",
      "group" => "0072"
    },
    "112" => {
      "KeyWord" => "SelectorUTValue",
      "Name" => "Selector UT Value",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "0070",
      "group" => "0072"
    },
    "114" => {
      "KeyWord" => "SelectorDSValue",
      "Name" => "Selector DS Value",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "0072",
      "group" => "0072"
    },
    "116" => {
      "KeyWord" => "SelectorFDValue",
      "Name" => "Selector FD Value",
      "VM" => "1-n",
      "VR" => "FD",
      "ele" => "0074",
      "group" => "0072"
    },
    "118" => {
      "KeyWord" => "SelectorFLValue",
      "Name" => "Selector FL Value",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "0076",
      "group" => "0072"
    },
    "12" => {
      "KeyWord" => "HangingProtocolDefinitionSequence",
      "Name" => "Hanging Protocol Definition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000c",
      "group" => "0072"
    },
    "120" => {
      "KeyWord" => "SelectorULValue",
      "Name" => "Selector UL Value",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "0078",
      "group" => "0072"
    },
    "122" => {
      "KeyWord" => "SelectorUSValue",
      "Name" => "Selector US Value",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "007a",
      "group" => "0072"
    },
    "124" => {
      "KeyWord" => "SelectorSLValue",
      "Name" => "Selector SL Value",
      "VM" => "1-n",
      "VR" => "SL",
      "ele" => "007c",
      "group" => "0072"
    },
    "126" => {
      "KeyWord" => "SelectorSSValue",
      "Name" => "Selector SS Value",
      "VM" => "1-n",
      "VR" => "SS",
      "ele" => "007e",
      "group" => "0072"
    },
    "128" => {
      "KeyWord" => "SelectorCodeSequenceValue",
      "Name" => "Selector Code Sequence Value",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0080",
      "group" => "0072"
    },
    "1280" => {
      "KeyWord" => "BlendingOperationType",
      "Name" => "Blending Operation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0500",
      "group" => "0072"
    },
    "1296" => {
      "KeyWord" => "ReformattingOperationType",
      "Name" => "Reformatting Operation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0510",
      "group" => "0072"
    },
    "1298" => {
      "KeyWord" => "ReformattingThickness",
      "Name" => "Reformatting Thickness",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0512",
      "group" => "0072"
    },
    "1300" => {
      "KeyWord" => "ReformattingInterval",
      "Name" => "Reformatting Interval",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0514",
      "group" => "0072"
    },
    "1302" => {
      "KeyWord" => "ReformattingOperationInitialViewDirection",
      "Name" => "Reformatting Operation Initial View Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0516",
      "group" => "0072"
    },
    "1312" => {
      "KeyWord" => "ThreeDRenderingType",
      "Name" => "3D Rendering Type",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0520",
      "group" => "0072"
    },
    "14" => {
      "KeyWord" => "HangingProtocolUserIdentificationCodeSequence",
      "Name" => "Hanging Protocol User Identification Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000e",
      "group" => "0072"
    },
    "1536" => {
      "KeyWord" => "SortingOperationsSequence",
      "Name" => "Sorting Operations Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0600",
      "group" => "0072"
    },
    "1538" => {
      "KeyWord" => "SortByCategory",
      "Name" => "Sort-by Category",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0602",
      "group" => "0072"
    },
    "1540" => {
      "KeyWord" => "SortingDirection",
      "Name" => "Sorting Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0604",
      "group" => "0072"
    },
    "16" => {
      "KeyWord" => "HangingProtocolUserGroupName",
      "Name" => "Hanging Protocol User Group Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0010",
      "group" => "0072"
    },
    "1792" => {
      "KeyWord" => "DisplaySetPatientOrientation",
      "Name" => "Display Set Patient Orientation",
      "VM" => "2",
      "VR" => "CS",
      "ele" => "0700",
      "group" => "0072"
    },
    "1794" => {
      "KeyWord" => "VOIType",
      "Name" => "VOI Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0702",
      "group" => "0072"
    },
    "1796" => {
      "KeyWord" => "PseudoColorType",
      "Name" => "Pseudo-Color Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0704",
      "group" => "0072"
    },
    "1797" => {
      "KeyWord" => "PseudoColorPaletteInstanceReferenceSequence",
      "Name" => "Pseudo-Color Palette Instance Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0705",
      "group" => "0072"
    },
    "1798" => {
      "KeyWord" => "ShowGrayscaleInverted",
      "Name" => "Show Grayscale Inverted",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0706",
      "group" => "0072"
    },
    "18" => {
      "KeyWord" => "SourceHangingProtocolSequence",
      "Name" => "Source Hanging Protocol Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0012",
      "group" => "0072"
    },
    "1808" => {
      "KeyWord" => "ShowImageTrueSizeFlag",
      "Name" => "Show Image True Size Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0710",
      "group" => "0072"
    },
    "1810" => {
      "KeyWord" => "ShowGraphicAnnotationFlag",
      "Name" => "Show Graphic Annotation Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0712",
      "group" => "0072"
    },
    "1812" => {
      "KeyWord" => "ShowPatientDemographicsFlag",
      "Name" => "Show Patient Demographics Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0714",
      "group" => "0072"
    },
    "1814" => {
      "KeyWord" => "ShowAcquisitionTechniquesFlag",
      "Name" => "Show Acquisition Techniques Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0716",
      "group" => "0072"
    },
    "1815" => {
      "KeyWord" => "DisplaySetHorizontalJustification",
      "Name" => "Display Set Horizontal Justification",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0717",
      "group" => "0072"
    },
    "1816" => {
      "KeyWord" => "DisplaySetVerticalJustification",
      "Name" => "Display Set Vertical Justification",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0718",
      "group" => "0072"
    },
    "2" => {
      "KeyWord" => "HangingProtocolName",
      "Name" => "Hanging Protocol Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0002",
      "group" => "0072"
    },
    "20" => {
      "KeyWord" => "NumberOfPriorsReferenced",
      "Name" => "Number of Priors Referenced",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0014",
      "group" => "0072"
    },
    "256" => {
      "KeyWord" => "NumberOfScreens",
      "Name" => "Number of Screens",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0100",
      "group" => "0072"
    },
    "258" => {
      "KeyWord" => "NominalScreenDefinitionSequence",
      "Name" => "Nominal Screen Definition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0102",
      "group" => "0072"
    },
    "260" => {
      "KeyWord" => "NumberOfVerticalPixels",
      "Name" => "Number of Vertical Pixels",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0104",
      "group" => "0072"
    },
    "262" => {
      "KeyWord" => "NumberOfHorizontalPixels",
      "Name" => "Number of Horizontal Pixels",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0106",
      "group" => "0072"
    },
    "264" => {
      "KeyWord" => "DisplayEnvironmentSpatialPosition",
      "Name" => "Display Environment Spatial Position",
      "VM" => "4",
      "VR" => "FD",
      "ele" => "0108",
      "group" => "0072"
    },
    "266" => {
      "KeyWord" => "ScreenMinimumGrayscaleBitDepth",
      "Name" => "Screen Minimum Grayscale Bit Depth",
      "VM" => "1",
      "VR" => "US",
      "ele" => "010a",
      "group" => "0072"
    },
    "268" => {
      "KeyWord" => "ScreenMinimumColorBitDepth",
      "Name" => "Screen Minimum Color Bit Depth",
      "VM" => "1",
      "VR" => "US",
      "ele" => "010c",
      "group" => "0072"
    },
    "270" => {
      "KeyWord" => "ApplicationMaximumRepaintTime",
      "Name" => "Application Maximum Repaint Time",
      "VM" => "1",
      "VR" => "US",
      "ele" => "010e",
      "group" => "0072"
    },
    "32" => {
      "KeyWord" => "ImageSetsSequence",
      "Name" => "Image Sets Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0020",
      "group" => "0072"
    },
    "34" => {
      "KeyWord" => "ImageSetSelectorSequence",
      "Name" => "Image Set Selector Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0022",
      "group" => "0072"
    },
    "36" => {
      "KeyWord" => "ImageSetSelectorUsageFlag",
      "Name" => "Image Set Selector Usage Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0024",
      "group" => "0072"
    },
    "38" => {
      "KeyWord" => "SelectorAttribute",
      "Name" => "Selector Attribute",
      "VM" => "1",
      "VR" => "AT",
      "ele" => "0026",
      "group" => "0072"
    },
    "4" => {
      "KeyWord" => "HangingProtocolDescription",
      "Name" => "Hanging Protocol Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0004",
      "group" => "0072"
    },
    "40" => {
      "KeyWord" => "SelectorValueNumber",
      "Name" => "Selector Value Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0028",
      "group" => "0072"
    },
    "48" => {
      "KeyWord" => "TimeBasedImageSetsSequence",
      "Name" => "Time Based Image Sets Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0030",
      "group" => "0072"
    },
    "50" => {
      "KeyWord" => "ImageSetNumber",
      "Name" => "Image Set Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0032",
      "group" => "0072"
    },
    "512" => {
      "KeyWord" => "DisplaySetsSequence",
      "Name" => "Display Sets Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0200",
      "group" => "0072"
    },
    "514" => {
      "KeyWord" => "DisplaySetNumber",
      "Name" => "Display Set Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0202",
      "group" => "0072"
    },
    "515" => {
      "KeyWord" => "DisplaySetLabel",
      "Name" => "Display Set Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0203",
      "group" => "0072"
    },
    "516" => {
      "KeyWord" => "DisplaySetPresentationGroup",
      "Name" => "Display Set Presentation Group",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0204",
      "group" => "0072"
    },
    "518" => {
      "KeyWord" => "DisplaySetPresentationGroupDescription",
      "Name" => "Display Set Presentation Group Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0206",
      "group" => "0072"
    },
    "52" => {
      "KeyWord" => "ImageSetSelectorCategory",
      "Name" => "Image Set Selector Category",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0034",
      "group" => "0072"
    },
    "520" => {
      "KeyWord" => "PartialDataDisplayHandling",
      "Name" => "Partial Data Display Handling",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0208",
      "group" => "0072"
    },
    "528" => {
      "KeyWord" => "SynchronizedScrollingSequence",
      "Name" => "Synchronized Scrolling Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0210",
      "group" => "0072"
    },
    "530" => {
      "KeyWord" => "DisplaySetScrollingGroup",
      "Name" => "Display Set Scrolling Group",
      "VM" => "2-n",
      "VR" => "US",
      "ele" => "0212",
      "group" => "0072"
    },
    "532" => {
      "KeyWord" => "NavigationIndicatorSequence",
      "Name" => "Navigation Indicator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0214",
      "group" => "0072"
    },
    "534" => {
      "KeyWord" => "NavigationDisplaySet",
      "Name" => "Navigation Display Set",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0216",
      "group" => "0072"
    },
    "536" => {
      "KeyWord" => "ReferenceDisplaySets",
      "Name" => "Reference Display Sets",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0218",
      "group" => "0072"
    },
    "56" => {
      "KeyWord" => "RelativeTime",
      "Name" => "Relative Time",
      "VM" => "2",
      "VR" => "US",
      "ele" => "0038",
      "group" => "0072"
    },
    "58" => {
      "KeyWord" => "RelativeTimeUnits",
      "Name" => "Relative Time Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "003a",
      "group" => "0072"
    },
    "6" => {
      "KeyWord" => "HangingProtocolLevel",
      "Name" => "Hanging Protocol Level",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0006",
      "group" => "0072"
    },
    "60" => {
      "KeyWord" => "AbstractPriorValue",
      "Name" => "Abstract Prior Value",
      "VM" => "2",
      "VR" => "SS",
      "ele" => "003c",
      "group" => "0072"
    },
    "62" => {
      "KeyWord" => "AbstractPriorCodeSequence",
      "Name" => "Abstract Prior Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "003e",
      "group" => "0072"
    },
    "64" => {
      "KeyWord" => "ImageSetLabel",
      "Name" => "Image Set Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0040",
      "group" => "0072"
    },
    "768" => {
      "KeyWord" => "ImageBoxesSequence",
      "Name" => "Image Boxes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0300",
      "group" => "0072"
    },
    "770" => {
      "KeyWord" => "ImageBoxNumber",
      "Name" => "Image Box Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0302",
      "group" => "0072"
    },
    "772" => {
      "KeyWord" => "ImageBoxLayoutType",
      "Name" => "Image Box Layout Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0304",
      "group" => "0072"
    },
    "774" => {
      "KeyWord" => "ImageBoxTileHorizontalDimension",
      "Name" => "Image Box Tile Horizontal Dimension",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0306",
      "group" => "0072"
    },
    "776" => {
      "KeyWord" => "ImageBoxTileVerticalDimension",
      "Name" => "Image Box Tile Vertical Dimension",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0308",
      "group" => "0072"
    },
    "784" => {
      "KeyWord" => "ImageBoxScrollDirection",
      "Name" => "Image Box Scroll Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0310",
      "group" => "0072"
    },
    "786" => {
      "KeyWord" => "ImageBoxSmallScrollType",
      "Name" => "Image Box Small Scroll Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0312",
      "group" => "0072"
    },
    "788" => {
      "KeyWord" => "ImageBoxSmallScrollAmount",
      "Name" => "Image Box Small Scroll Amount",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0314",
      "group" => "0072"
    },
    "790" => {
      "KeyWord" => "ImageBoxLargeScrollType",
      "Name" => "Image Box Large Scroll Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0316",
      "group" => "0072"
    },
    "792" => {
      "KeyWord" => "ImageBoxLargeScrollAmount",
      "Name" => "Image Box Large Scroll Amount",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0318",
      "group" => "0072"
    },
    "8" => {
      "KeyWord" => "HangingProtocolCreator",
      "Name" => "Hanging Protocol Creator",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0008",
      "group" => "0072"
    },
    "80" => {
      "KeyWord" => "SelectorAttributeVR",
      "Name" => "Selector Attribute VR",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0050",
      "group" => "0072"
    },
    "800" => {
      "KeyWord" => "ImageBoxOverlapPriority",
      "Name" => "Image Box Overlap Priority",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0320",
      "group" => "0072"
    },
    "816" => {
      "KeyWord" => "CineRelativeToRealTime",
      "Name" => "Cine Relative to Real-Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0330",
      "group" => "0072"
    },
    "82" => {
      "KeyWord" => "SelectorSequencePointer",
      "Name" => "Selector Sequence Pointer",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "0052",
      "group" => "0072"
    },
    "84" => {
      "KeyWord" => "SelectorSequencePointerPrivateCreator",
      "Name" => "Selector Sequence Pointer Private Creator",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0054",
      "group" => "0072"
    },
    "86" => {
      "KeyWord" => "SelectorAttributePrivateCreator",
      "Name" => "Selector Attribute Private Creator",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0056",
      "group" => "0072"
    },
    "96" => {
      "KeyWord" => "SelectorATValue",
      "Name" => "Selector AT Value",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "0060",
      "group" => "0072"
    },
    "98" => {
      "KeyWord" => "SelectorCSValue",
      "Name" => "Selector CS Value",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0062",
      "group" => "0072"
    }
  },
  "116" => {
    "288" => {
      "KeyWord" => "ContinuationStartMeterset",
      "Name" => "Continuation Start Meterset",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0120",
      "group" => "0074"
    },
    "289" => {
      "KeyWord" => "ContinuationEndMeterset",
      "Name" => "Continuation End Meterset",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0121",
      "group" => "0074"
    },
    "4096" => {
      "KeyWord" => "ProcedureStepState",
      "Name" => "Procedure Step State",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1000",
      "group" => "0074"
    },
    "4098" => {
      "KeyWord" => "ProcedureStepProgressInformationSequence",
      "Name" => "Procedure Step Progress Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1002",
      "group" => "0074"
    },
    "4100" => {
      "KeyWord" => "ProcedureStepProgress",
      "Name" => "Procedure Step Progress",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1004",
      "group" => "0074"
    },
    "4102" => {
      "KeyWord" => "ProcedureStepProgressDescription",
      "Name" => "Procedure Step Progress Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "1006",
      "group" => "0074"
    },
    "4104" => {
      "KeyWord" => "ProcedureStepCommunicationsURISequence",
      "Name" => "Procedure Step Communications URI Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1008",
      "group" => "0074"
    },
    "4106" => {
      "KeyWord" => "ContactURI",
      "Name" => "Contact URI",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "100a",
      "group" => "0074"
    },
    "4108" => {
      "KeyWord" => "ContactDisplayName",
      "Name" => "Contact Display Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "100c",
      "group" => "0074"
    },
    "4110" => {
      "KeyWord" => "ProcedureStepDiscontinuationReasonCodeSequence",
      "Name" => "Procedure Step Discontinuation Reason Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "100e",
      "group" => "0074"
    },
    "4128" => {
      "KeyWord" => "BeamTaskSequence",
      "Name" => "Beam Task Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1020",
      "group" => "0074"
    },
    "4130" => {
      "KeyWord" => "BeamTaskType",
      "Name" => "Beam Task Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1022",
      "group" => "0074"
    },
    "4132" => {
      "KeyWord" => "BeamOrderIndexTrial",
      "Name" => "Beam Order Index (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1024",
      "group" => "0074"
    },
    "4133" => {
      "KeyWord" => "AutosequenceFlag",
      "Name" => "Autosequence Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1025",
      "group" => "0074"
    },
    "4134" => {
      "KeyWord" => "TableTopVerticalAdjustedPosition",
      "Name" => "Table Top Vertical Adjusted Position",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "1026",
      "group" => "0074"
    },
    "4135" => {
      "KeyWord" => "TableTopLongitudinalAdjustedPosition",
      "Name" => "Table Top Longitudinal Adjusted Position",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "1027",
      "group" => "0074"
    },
    "4136" => {
      "KeyWord" => "TableTopLateralAdjustedPosition",
      "Name" => "Table Top Lateral Adjusted Position",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "1028",
      "group" => "0074"
    },
    "4138" => {
      "KeyWord" => "PatientSupportAdjustedAngle",
      "Name" => "Patient Support Adjusted Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "102a",
      "group" => "0074"
    },
    "4139" => {
      "KeyWord" => "TableTopEccentricAdjustedAngle",
      "Name" => "Table Top Eccentric Adjusted Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "102b",
      "group" => "0074"
    },
    "4140" => {
      "KeyWord" => "TableTopPitchAdjustedAngle",
      "Name" => "Table Top Pitch Adjusted Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "102c",
      "group" => "0074"
    },
    "4141" => {
      "KeyWord" => "TableTopRollAdjustedAngle",
      "Name" => "Table Top Roll Adjusted Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "102d",
      "group" => "0074"
    },
    "4144" => {
      "KeyWord" => "DeliveryVerificationImageSequence",
      "Name" => "Delivery Verification Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1030",
      "group" => "0074"
    },
    "4146" => {
      "KeyWord" => "VerificationImageTiming",
      "Name" => "Verification Image Timing",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1032",
      "group" => "0074"
    },
    "4148" => {
      "KeyWord" => "DoubleExposureFlag",
      "Name" => "Double Exposure Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1034",
      "group" => "0074"
    },
    "4150" => {
      "KeyWord" => "DoubleExposureOrdering",
      "Name" => "Double Exposure Ordering",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1036",
      "group" => "0074"
    },
    "4152" => {
      "KeyWord" => "DoubleExposureMetersetTrial",
      "Name" => "Double Exposure Meterset (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1038",
      "group" => "0074"
    },
    "4154" => {
      "KeyWord" => "DoubleExposureFieldDeltaTrial",
      "Name" => "Double Exposure Field Delta (Trial)",
      "RET" => "1",
      "VM" => "4",
      "VR" => "DS",
      "ele" => "103a",
      "group" => "0074"
    },
    "4160" => {
      "KeyWord" => "RelatedReferenceRTImageSequence",
      "Name" => "Related Reference RT Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1040",
      "group" => "0074"
    },
    "4162" => {
      "KeyWord" => "GeneralMachineVerificationSequence",
      "Name" => "General Machine Verification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1042",
      "group" => "0074"
    },
    "4164" => {
      "KeyWord" => "ConventionalMachineVerificationSequence",
      "Name" => "Conventional Machine Verification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1044",
      "group" => "0074"
    },
    "4166" => {
      "KeyWord" => "IonMachineVerificationSequence",
      "Name" => "Ion Machine Verification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1046",
      "group" => "0074"
    },
    "4168" => {
      "KeyWord" => "FailedAttributesSequence",
      "Name" => "Failed Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1048",
      "group" => "0074"
    },
    "4170" => {
      "KeyWord" => "OverriddenAttributesSequence",
      "Name" => "Overridden Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "104a",
      "group" => "0074"
    },
    "4172" => {
      "KeyWord" => "ConventionalControlPointVerificationSequence",
      "Name" => "Conventional Control Point Verification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "104c",
      "group" => "0074"
    },
    "4174" => {
      "KeyWord" => "IonControlPointVerificationSequence",
      "Name" => "Ion Control Point Verification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "104e",
      "group" => "0074"
    },
    "4176" => {
      "KeyWord" => "AttributeOccurrenceSequence",
      "Name" => "Attribute Occurrence Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1050",
      "group" => "0074"
    },
    "4178" => {
      "KeyWord" => "AttributeOccurrencePointer",
      "Name" => "Attribute Occurrence Pointer",
      "VM" => "1",
      "VR" => "AT",
      "ele" => "1052",
      "group" => "0074"
    },
    "4180" => {
      "KeyWord" => "AttributeItemSelector",
      "Name" => "Attribute Item Selector",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "1054",
      "group" => "0074"
    },
    "4182" => {
      "KeyWord" => "AttributeOccurrencePrivateCreator",
      "Name" => "Attribute Occurrence Private Creator",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1056",
      "group" => "0074"
    },
    "4183" => {
      "KeyWord" => "SelectorSequencePointerItems",
      "Name" => "Selector Sequence Pointer Items",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "1057",
      "group" => "0074"
    },
    "4608" => {
      "KeyWord" => "ScheduledProcedureStepPriority",
      "Name" => "Scheduled Procedure Step Priority",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1200",
      "group" => "0074"
    },
    "4610" => {
      "KeyWord" => "WorklistLabel",
      "Name" => "Worklist Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1202",
      "group" => "0074"
    },
    "4612" => {
      "KeyWord" => "ProcedureStepLabel",
      "Name" => "Procedure Step Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1204",
      "group" => "0074"
    },
    "4624" => {
      "KeyWord" => "ScheduledProcessingParametersSequence",
      "Name" => "Scheduled Processing Parameters Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1210",
      "group" => "0074"
    },
    "4626" => {
      "KeyWord" => "PerformedProcessingParametersSequence",
      "Name" => "Performed Processing Parameters Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1212",
      "group" => "0074"
    },
    "4630" => {
      "KeyWord" => "UnifiedProcedureStepPerformedProcedureSequence",
      "Name" => "Unified Procedure Step Performed Procedure Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1216",
      "group" => "0074"
    },
    "4640" => {
      "KeyWord" => "RelatedProcedureStepSequence",
      "Name" => "Related Procedure Step Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1220",
      "group" => "0074"
    },
    "4642" => {
      "KeyWord" => "ProcedureStepRelationshipType",
      "Name" => "Procedure Step Relationship Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1222",
      "group" => "0074"
    },
    "4644" => {
      "KeyWord" => "ReplacedProcedureStepSequence",
      "Name" => "Replaced Procedure Step Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1224",
      "group" => "0074"
    },
    "4656" => {
      "KeyWord" => "DeletionLock",
      "Name" => "Deletion Lock",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1230",
      "group" => "0074"
    },
    "4660" => {
      "KeyWord" => "ReceivingAE",
      "Name" => "Receiving AE",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "1234",
      "group" => "0074"
    },
    "4662" => {
      "KeyWord" => "RequestingAE",
      "Name" => "Requesting AE",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "1236",
      "group" => "0074"
    },
    "4664" => {
      "KeyWord" => "ReasonForCancellation",
      "Name" => "Reason for Cancellation",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "1238",
      "group" => "0074"
    },
    "4674" => {
      "KeyWord" => "SCPStatus",
      "Name" => "SCP Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1242",
      "group" => "0074"
    },
    "4676" => {
      "KeyWord" => "SubscriptionListStatus",
      "Name" => "Subscription List Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1244",
      "group" => "0074"
    },
    "4678" => {
      "KeyWord" => "UnifiedProcedureStepListStatus",
      "Name" => "Unified Procedure StepList Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1246",
      "group" => "0074"
    },
    "4900" => {
      "KeyWord" => "BeamOrderIndex",
      "Name" => "Beam Order Index",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "1324",
      "group" => "0074"
    },
    "4920" => {
      "KeyWord" => "DoubleExposureMeterset",
      "Name" => "Double Exposure Meterset",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "1338",
      "group" => "0074"
    },
    "4922" => {
      "KeyWord" => "DoubleExposureFieldDelta",
      "Name" => "Double Exposure Field Delta",
      "VM" => "4",
      "VR" => "FD",
      "ele" => "133a",
      "group" => "0074"
    }
  },
  "118" => {
    "1" => {
      "KeyWord" => "ImplantAssemblyTemplateName",
      "Name" => "Implant Assembly Template Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0001",
      "group" => "0076"
    },
    "10" => {
      "KeyWord" => "ImplantAssemblyTemplateType",
      "Name" => "Implant Assembly Template Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000a",
      "group" => "0076"
    },
    "112" => {
      "KeyWord" => "Component1ReferencedID",
      "Name" => "Component 1 Referenced ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0070",
      "group" => "0076"
    },
    "12" => {
      "KeyWord" => "OriginalImplantAssemblyTemplateSequence",
      "Name" => "Original Implant Assembly Template Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000c",
      "group" => "0076"
    },
    "128" => {
      "KeyWord" => "Component1ReferencedMatingFeatureSetID",
      "Name" => "Component 1 Referenced Mating Feature Set ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0080",
      "group" => "0076"
    },
    "14" => {
      "KeyWord" => "DerivationImplantAssemblyTemplateSequence",
      "Name" => "Derivation Implant Assembly Template Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000e",
      "group" => "0076"
    },
    "144" => {
      "KeyWord" => "Component1ReferencedMatingFeatureID",
      "Name" => "Component 1 Referenced Mating Feature ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0090",
      "group" => "0076"
    },
    "16" => {
      "KeyWord" => "ImplantAssemblyTemplateTargetAnatomySequence",
      "Name" => "Implant Assembly Template Target Anatomy Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "0076"
    },
    "160" => {
      "KeyWord" => "Component2ReferencedID",
      "Name" => "Component 2 Referenced ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "00a0",
      "group" => "0076"
    },
    "176" => {
      "KeyWord" => "Component2ReferencedMatingFeatureSetID",
      "Name" => "Component 2 Referenced Mating Feature Set ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "00b0",
      "group" => "0076"
    },
    "192" => {
      "KeyWord" => "Component2ReferencedMatingFeatureID",
      "Name" => "Component 2 Referenced Mating Feature ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "00c0",
      "group" => "0076"
    },
    "3" => {
      "KeyWord" => "ImplantAssemblyTemplateIssuer",
      "Name" => "Implant Assembly Template Issuer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0003",
      "group" => "0076"
    },
    "32" => {
      "KeyWord" => "ProcedureTypeCodeSequence",
      "Name" => "Procedure Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0020",
      "group" => "0076"
    },
    "48" => {
      "KeyWord" => "SurgicalTechnique",
      "Name" => "Surgical Technique",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0030",
      "group" => "0076"
    },
    "50" => {
      "KeyWord" => "ComponentTypesSequence",
      "Name" => "Component Types Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0032",
      "group" => "0076"
    },
    "52" => {
      "KeyWord" => "ComponentTypeCodeSequence",
      "Name" => "Component Type Code Sequence",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0034",
      "group" => "0076"
    },
    "54" => {
      "KeyWord" => "ExclusiveComponentType",
      "Name" => "Exclusive Component Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0036",
      "group" => "0076"
    },
    "56" => {
      "KeyWord" => "MandatoryComponentType",
      "Name" => "Mandatory Component Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0038",
      "group" => "0076"
    },
    "6" => {
      "KeyWord" => "ImplantAssemblyTemplateVersion",
      "Name" => "Implant Assembly Template Version",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0006",
      "group" => "0076"
    },
    "64" => {
      "KeyWord" => "ComponentSequence",
      "Name" => "Component Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0040",
      "group" => "0076"
    },
    "8" => {
      "KeyWord" => "ReplacedImplantAssemblyTemplateSequence",
      "Name" => "Replaced Implant Assembly Template Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0008",
      "group" => "0076"
    },
    "85" => {
      "KeyWord" => "ComponentID",
      "Name" => "Component ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0055",
      "group" => "0076"
    },
    "96" => {
      "KeyWord" => "ComponentAssemblySequence",
      "Name" => "Component Assembly Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0060",
      "group" => "0076"
    }
  },
  "120" => {
    "1" => {
      "KeyWord" => "ImplantTemplateGroupName",
      "Name" => "Implant Template Group Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0001",
      "group" => "0078"
    },
    "112" => {
      "KeyWord" => "ImplantTemplateGroupMemberMatching2DCoordinatesSequence",
      "Name" => "Implant Template Group Member Matching 2D Coordinates Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0070",
      "group" => "0078"
    },
    "144" => {
      "KeyWord" => "TwoDImplantTemplateGroupMemberMatchingPoint",
      "Name" => "2D Implant Template Group Member Matching Point",
      "VM" => "2",
      "VR" => "FD",
      "ele" => "0090",
      "group" => "0078"
    },
    "16" => {
      "KeyWord" => "ImplantTemplateGroupDescription",
      "Name" => "Implant Template Group Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0010",
      "group" => "0078"
    },
    "160" => {
      "KeyWord" => "TwoDImplantTemplateGroupMemberMatchingAxes",
      "Name" => "2D Implant Template Group Member Matching Axes",
      "VM" => "4",
      "VR" => "FD",
      "ele" => "00a0",
      "group" => "0078"
    },
    "176" => {
      "KeyWord" => "ImplantTemplateGroupVariationDimensionSequence",
      "Name" => "Implant Template Group Variation Dimension Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00b0",
      "group" => "0078"
    },
    "178" => {
      "KeyWord" => "ImplantTemplateGroupVariationDimensionName",
      "Name" => "Implant Template Group Variation Dimension Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "00b2",
      "group" => "0078"
    },
    "180" => {
      "KeyWord" => "ImplantTemplateGroupVariationDimensionRankSequence",
      "Name" => "Implant Template Group Variation Dimension Rank Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00b4",
      "group" => "0078"
    },
    "182" => {
      "KeyWord" => "ReferencedImplantTemplateGroupMemberID",
      "Name" => "Referenced Implant Template Group Member ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "00b6",
      "group" => "0078"
    },
    "184" => {
      "KeyWord" => "ImplantTemplateGroupVariationDimensionRank",
      "Name" => "Implant Template Group Variation Dimension Rank",
      "VM" => "1",
      "VR" => "US",
      "ele" => "00b8",
      "group" => "0078"
    },
    "32" => {
      "KeyWord" => "ImplantTemplateGroupIssuer",
      "Name" => "Implant Template Group Issuer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0020",
      "group" => "0078"
    },
    "36" => {
      "KeyWord" => "ImplantTemplateGroupVersion",
      "Name" => "Implant Template Group Version",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0024",
      "group" => "0078"
    },
    "38" => {
      "KeyWord" => "ReplacedImplantTemplateGroupSequence",
      "Name" => "Replaced Implant Template Group Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0026",
      "group" => "0078"
    },
    "40" => {
      "KeyWord" => "ImplantTemplateGroupTargetAnatomySequence",
      "Name" => "Implant Template Group Target Anatomy Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0028",
      "group" => "0078"
    },
    "42" => {
      "KeyWord" => "ImplantTemplateGroupMembersSequence",
      "Name" => "Implant Template Group Members Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "002a",
      "group" => "0078"
    },
    "46" => {
      "KeyWord" => "ImplantTemplateGroupMemberID",
      "Name" => "Implant Template Group Member ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "002e",
      "group" => "0078"
    },
    "80" => {
      "KeyWord" => "ThreeDImplantTemplateGroupMemberMatchingPoint",
      "Name" => "3D Implant Template Group Member Matching Point",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "0050",
      "group" => "0078"
    },
    "96" => {
      "KeyWord" => "ThreeDImplantTemplateGroupMemberMatchingAxes",
      "Name" => "3D Implant Template Group Member Matching Axes",
      "VM" => "9",
      "VR" => "FD",
      "ele" => "0060",
      "group" => "0078"
    }
  },
  "12290" => {
    "10" => {
      "KeyWord" => "ReportedValuesOrigin",
      "Name" => "Reported Values Origin",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000a",
      "group" => "3002"
    },
    "12" => {
      "KeyWord" => "RTImagePlane",
      "Name" => "RT Image Plane",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000c",
      "group" => "3002"
    },
    "13" => {
      "KeyWord" => "XRayImageReceptorTranslation",
      "Name" => "X-Ray Image Receptor Translation",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "000d",
      "group" => "3002"
    },
    "14" => {
      "KeyWord" => "XRayImageReceptorAngle",
      "Name" => "X-Ray Image Receptor Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "000e",
      "group" => "3002"
    },
    "16" => {
      "KeyWord" => "RTImageOrientation",
      "Name" => "RT Image Orientation",
      "VM" => "6",
      "VR" => "DS",
      "ele" => "0010",
      "group" => "3002"
    },
    "17" => {
      "KeyWord" => "ImagePlanePixelSpacing",
      "Name" => "Image Plane Pixel Spacing",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "0011",
      "group" => "3002"
    },
    "18" => {
      "KeyWord" => "RTImagePosition",
      "Name" => "RT Image Position",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "0012",
      "group" => "3002"
    },
    "2" => {
      "KeyWord" => "RTImageLabel",
      "Name" => "RT Image Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0002",
      "group" => "3002"
    },
    "3" => {
      "KeyWord" => "RTImageName",
      "Name" => "RT Image Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0003",
      "group" => "3002"
    },
    "32" => {
      "KeyWord" => "RadiationMachineName",
      "Name" => "Radiation Machine Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0020",
      "group" => "3002"
    },
    "34" => {
      "KeyWord" => "RadiationMachineSAD",
      "Name" => "Radiation Machine SAD",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0022",
      "group" => "3002"
    },
    "36" => {
      "KeyWord" => "RadiationMachineSSD",
      "Name" => "Radiation Machine SSD",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0024",
      "group" => "3002"
    },
    "38" => {
      "KeyWord" => "RTImageSID",
      "Name" => "RT Image SID",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0026",
      "group" => "3002"
    },
    "4" => {
      "KeyWord" => "RTImageDescription",
      "Name" => "RT Image Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0004",
      "group" => "3002"
    },
    "40" => {
      "KeyWord" => "SourceToReferenceObjectDistance",
      "Name" => "Source to Reference Object Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0028",
      "group" => "3002"
    },
    "41" => {
      "KeyWord" => "FractionNumber",
      "Name" => "Fraction Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0029",
      "group" => "3002"
    },
    "48" => {
      "KeyWord" => "ExposureSequence",
      "Name" => "Exposure Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0030",
      "group" => "3002"
    },
    "50" => {
      "KeyWord" => "MetersetExposure",
      "Name" => "Meterset Exposure",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0032",
      "group" => "3002"
    },
    "52" => {
      "KeyWord" => "DiaphragmPosition",
      "Name" => "Diaphragm Position",
      "VM" => "4",
      "VR" => "DS",
      "ele" => "0034",
      "group" => "3002"
    },
    "64" => {
      "KeyWord" => "FluenceMapSequence",
      "Name" => "Fluence Map Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0040",
      "group" => "3002"
    },
    "65" => {
      "KeyWord" => "FluenceDataSource",
      "Name" => "Fluence Data Source",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0041",
      "group" => "3002"
    },
    "66" => {
      "KeyWord" => "FluenceDataScale",
      "Name" => "Fluence Data Scale",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0042",
      "group" => "3002"
    },
    "80" => {
      "KeyWord" => "PrimaryFluenceModeSequence",
      "Name" => "Primary Fluence Mode Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "3002"
    },
    "81" => {
      "KeyWord" => "FluenceMode",
      "Name" => "Fluence Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0051",
      "group" => "3002"
    },
    "82" => {
      "KeyWord" => "FluenceModeID",
      "Name" => "Fluence Mode ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0052",
      "group" => "3002"
    }
  },
  "12292" => {
    "1" => {
      "KeyWord" => "DVHType",
      "Name" => "DVH Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0001",
      "group" => "3004"
    },
    "10" => {
      "KeyWord" => "DoseSummationType",
      "Name" => "Dose Summation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000a",
      "group" => "3004"
    },
    "112" => {
      "KeyWord" => "DVHMinimumDose",
      "Name" => "DVH Minimum Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0070",
      "group" => "3004"
    },
    "114" => {
      "KeyWord" => "DVHMaximumDose",
      "Name" => "DVH Maximum Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0072",
      "group" => "3004"
    },
    "116" => {
      "KeyWord" => "DVHMeanDose",
      "Name" => "DVH Mean Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0074",
      "group" => "3004"
    },
    "12" => {
      "KeyWord" => "GridFrameOffsetVector",
      "Name" => "Grid Frame Offset Vector",
      "VM" => "2-n",
      "VR" => "DS",
      "ele" => "000c",
      "group" => "3004"
    },
    "14" => {
      "KeyWord" => "DoseGridScaling",
      "Name" => "Dose Grid Scaling",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "000e",
      "group" => "3004"
    },
    "16" => {
      "KeyWord" => "RTDoseROISequence",
      "Name" => "RT Dose ROI Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "3004"
    },
    "18" => {
      "KeyWord" => "DoseValue",
      "Name" => "Dose Value",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0012",
      "group" => "3004"
    },
    "2" => {
      "KeyWord" => "DoseUnits",
      "Name" => "Dose Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0002",
      "group" => "3004"
    },
    "20" => {
      "KeyWord" => "TissueHeterogeneityCorrection",
      "Name" => "Tissue Heterogeneity Correction",
      "VM" => "1-3",
      "VR" => "CS",
      "ele" => "0014",
      "group" => "3004"
    },
    "4" => {
      "KeyWord" => "DoseType",
      "Name" => "Dose Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0004",
      "group" => "3004"
    },
    "5" => {
      "KeyWord" => "SpatialTransformOfDose",
      "Name" => "Spatial Transform of Dose",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0005",
      "group" => "3004"
    },
    "6" => {
      "KeyWord" => "DoseComment",
      "Name" => "Dose Comment",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0006",
      "group" => "3004"
    },
    "64" => {
      "KeyWord" => "DVHNormalizationPoint",
      "Name" => "DVH Normalization Point",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "0040",
      "group" => "3004"
    },
    "66" => {
      "KeyWord" => "DVHNormalizationDoseValue",
      "Name" => "DVH Normalization Dose Value",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0042",
      "group" => "3004"
    },
    "8" => {
      "KeyWord" => "NormalizationPoint",
      "Name" => "Normalization Point",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "0008",
      "group" => "3004"
    },
    "80" => {
      "KeyWord" => "DVHSequence",
      "Name" => "DVH Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "3004"
    },
    "82" => {
      "KeyWord" => "DVHDoseScaling",
      "Name" => "DVH Dose Scaling",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0052",
      "group" => "3004"
    },
    "84" => {
      "KeyWord" => "DVHVolumeUnits",
      "Name" => "DVH Volume Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0054",
      "group" => "3004"
    },
    "86" => {
      "KeyWord" => "DVHNumberOfBins",
      "Name" => "DVH Number of Bins",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0056",
      "group" => "3004"
    },
    "88" => {
      "KeyWord" => "DVHData",
      "Name" => "DVH Data",
      "VM" => "2-2n",
      "VR" => "DS",
      "ele" => "0058",
      "group" => "3004"
    },
    "96" => {
      "KeyWord" => "DVHReferencedROISequence",
      "Name" => "DVH Referenced ROI Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0060",
      "group" => "3004"
    },
    "98" => {
      "KeyWord" => "DVHROIContributionType",
      "Name" => "DVH ROI Contribution Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0062",
      "group" => "3004"
    }
  },
  "12294" => {
    "128" => {
      "KeyWord" => "RTROIObservationsSequence",
      "Name" => "RT ROI Observations Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0080",
      "group" => "3006"
    },
    "130" => {
      "KeyWord" => "ObservationNumber",
      "Name" => "Observation Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0082",
      "group" => "3006"
    },
    "132" => {
      "KeyWord" => "ReferencedROINumber",
      "Name" => "Referenced ROI Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0084",
      "group" => "3006"
    },
    "133" => {
      "KeyWord" => "ROIObservationLabel",
      "Name" => "ROI Observation Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0085",
      "group" => "3006"
    },
    "134" => {
      "KeyWord" => "RTROIIdentificationCodeSequence",
      "Name" => "RT ROI Identification Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0086",
      "group" => "3006"
    },
    "136" => {
      "KeyWord" => "ROIObservationDescription",
      "Name" => "ROI Observation Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0088",
      "group" => "3006"
    },
    "16" => {
      "KeyWord" => "ReferencedFrameOfReferenceSequence",
      "Name" => "Referenced Frame of Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "3006"
    },
    "160" => {
      "KeyWord" => "RelatedRTROIObservationsSequence",
      "Name" => "Related RT ROI Observations Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00a0",
      "group" => "3006"
    },
    "164" => {
      "KeyWord" => "RTROIInterpretedType",
      "Name" => "RT ROI Interpreted Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00a4",
      "group" => "3006"
    },
    "166" => {
      "KeyWord" => "ROIInterpreter",
      "Name" => "ROI Interpreter",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "00a6",
      "group" => "3006"
    },
    "176" => {
      "KeyWord" => "ROIPhysicalPropertiesSequence",
      "Name" => "ROI Physical Properties Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00b0",
      "group" => "3006"
    },
    "178" => {
      "KeyWord" => "ROIPhysicalProperty",
      "Name" => "ROI Physical Property",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00b2",
      "group" => "3006"
    },
    "18" => {
      "KeyWord" => "RTReferencedStudySequence",
      "Name" => "RT Referenced Study Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0012",
      "group" => "3006"
    },
    "180" => {
      "KeyWord" => "ROIPhysicalPropertyValue",
      "Name" => "ROI Physical Property Value",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00b4",
      "group" => "3006"
    },
    "182" => {
      "KeyWord" => "ROIElementalCompositionSequence",
      "Name" => "ROI Elemental Composition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00b6",
      "group" => "3006"
    },
    "183" => {
      "KeyWord" => "ROIElementalCompositionAtomicNumber",
      "Name" => "ROI Elemental Composition Atomic Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "00b7",
      "group" => "3006"
    },
    "184" => {
      "KeyWord" => "ROIElementalCompositionAtomicMassFraction",
      "Name" => "ROI Elemental Composition Atomic Mass Fraction",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "00b8",
      "group" => "3006"
    },
    "192" => {
      "KeyWord" => "FrameOfReferenceRelationshipSequence",
      "Name" => "Frame of Reference Relationship Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00c0",
      "group" => "3006"
    },
    "194" => {
      "KeyWord" => "RelatedFrameOfReferenceUID",
      "Name" => "Related Frame of Reference UID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "00c2",
      "group" => "3006"
    },
    "196" => {
      "KeyWord" => "FrameOfReferenceTransformationType",
      "Name" => "Frame of Reference Transformation Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00c4",
      "group" => "3006"
    },
    "198" => {
      "KeyWord" => "FrameOfReferenceTransformationMatrix",
      "Name" => "Frame of Reference Transformation Matrix",
      "VM" => "16",
      "VR" => "DS",
      "ele" => "00c6",
      "group" => "3006"
    },
    "2" => {
      "KeyWord" => "StructureSetLabel",
      "Name" => "Structure Set Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0002",
      "group" => "3006"
    },
    "20" => {
      "KeyWord" => "RTReferencedSeriesSequence",
      "Name" => "RT Referenced Series Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0014",
      "group" => "3006"
    },
    "200" => {
      "KeyWord" => "FrameOfReferenceTransformationComment",
      "Name" => "Frame of Reference Transformation Comment",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "00c8",
      "group" => "3006"
    },
    "22" => {
      "KeyWord" => "ContourImageSequence",
      "Name" => "Contour Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0016",
      "group" => "3006"
    },
    "24" => {
      "KeyWord" => "PredecessorStructureSetSequence",
      "Name" => "Predecessor Structure Set Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0018",
      "group" => "3006"
    },
    "32" => {
      "KeyWord" => "StructureSetROISequence",
      "Name" => "Structure Set ROI Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0020",
      "group" => "3006"
    },
    "34" => {
      "KeyWord" => "ROINumber",
      "Name" => "ROI Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0022",
      "group" => "3006"
    },
    "36" => {
      "KeyWord" => "ReferencedFrameOfReferenceUID",
      "Name" => "Referenced Frame of Reference UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0024",
      "group" => "3006"
    },
    "38" => {
      "KeyWord" => "ROIName",
      "Name" => "ROI Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0026",
      "group" => "3006"
    },
    "4" => {
      "KeyWord" => "StructureSetName",
      "Name" => "Structure Set Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0004",
      "group" => "3006"
    },
    "40" => {
      "KeyWord" => "ROIDescription",
      "Name" => "ROI Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0028",
      "group" => "3006"
    },
    "42" => {
      "KeyWord" => "ROIDisplayColor",
      "Name" => "ROI Display Color",
      "VM" => "3",
      "VR" => "IS",
      "ele" => "002a",
      "group" => "3006"
    },
    "44" => {
      "KeyWord" => "ROIVolume",
      "Name" => "ROI Volume",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "002c",
      "group" => "3006"
    },
    "48" => {
      "KeyWord" => "RTRelatedROISequence",
      "Name" => "RT Related ROI Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0030",
      "group" => "3006"
    },
    "51" => {
      "KeyWord" => "RTROIRelationship",
      "Name" => "RT ROI Relationship",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0033",
      "group" => "3006"
    },
    "54" => {
      "KeyWord" => "ROIGenerationAlgorithm",
      "Name" => "ROI Generation Algorithm",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0036",
      "group" => "3006"
    },
    "56" => {
      "KeyWord" => "ROIGenerationDescription",
      "Name" => "ROI Generation Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0038",
      "group" => "3006"
    },
    "57" => {
      "KeyWord" => "ROIContourSequence",
      "Name" => "ROI Contour Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0039",
      "group" => "3006"
    },
    "6" => {
      "KeyWord" => "StructureSetDescription",
      "Name" => "Structure Set Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0006",
      "group" => "3006"
    },
    "64" => {
      "KeyWord" => "ContourSequence",
      "Name" => "Contour Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0040",
      "group" => "3006"
    },
    "66" => {
      "KeyWord" => "ContourGeometricType",
      "Name" => "Contour Geometric Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0042",
      "group" => "3006"
    },
    "68" => {
      "KeyWord" => "ContourSlabThickness",
      "Name" => "Contour Slab Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0044",
      "group" => "3006"
    },
    "69" => {
      "KeyWord" => "ContourOffsetVector",
      "Name" => "Contour Offset Vector",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "0045",
      "group" => "3006"
    },
    "70" => {
      "KeyWord" => "NumberOfContourPoints",
      "Name" => "Number of Contour Points",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0046",
      "group" => "3006"
    },
    "72" => {
      "KeyWord" => "ContourNumber",
      "Name" => "Contour Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0048",
      "group" => "3006"
    },
    "73" => {
      "KeyWord" => "AttachedContours",
      "Name" => "Attached Contours",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "0049",
      "group" => "3006"
    },
    "8" => {
      "KeyWord" => "StructureSetDate",
      "Name" => "Structure Set Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0008",
      "group" => "3006"
    },
    "80" => {
      "KeyWord" => "ContourData",
      "Name" => "Contour Data",
      "VM" => "3-3n",
      "VR" => "DS",
      "ele" => "0050",
      "group" => "3006"
    },
    "9" => {
      "KeyWord" => "StructureSetTime",
      "Name" => "Structure Set Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0009",
      "group" => "3006"
    }
  },
  "12296" => {
    "100" => {
      "KeyWord" => "MeasuredDoseReferenceNumber",
      "Name" => "Measured Dose Reference Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0064",
      "group" => "3008"
    },
    "101" => {
      "KeyWord" => "ParameterPointer",
      "Name" => "Parameter Pointer",
      "VM" => "1",
      "VR" => "AT",
      "ele" => "0065",
      "group" => "3008"
    },
    "102" => {
      "KeyWord" => "OverrideReason",
      "Name" => "Override Reason",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0066",
      "group" => "3008"
    },
    "104" => {
      "KeyWord" => "CorrectedParameterSequence",
      "Name" => "Corrected Parameter Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0068",
      "group" => "3008"
    },
    "106" => {
      "KeyWord" => "CorrectionValue",
      "Name" => "Correction Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "006a",
      "group" => "3008"
    },
    "112" => {
      "KeyWord" => "CalculatedDoseReferenceSequence",
      "Name" => "Calculated Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0070",
      "group" => "3008"
    },
    "114" => {
      "KeyWord" => "CalculatedDoseReferenceNumber",
      "Name" => "Calculated Dose Reference Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0072",
      "group" => "3008"
    },
    "116" => {
      "KeyWord" => "CalculatedDoseReferenceDescription",
      "Name" => "Calculated Dose Reference Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0074",
      "group" => "3008"
    },
    "118" => {
      "KeyWord" => "CalculatedDoseReferenceDoseValue",
      "Name" => "Calculated Dose Reference Dose Value",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0076",
      "group" => "3008"
    },
    "120" => {
      "KeyWord" => "StartMeterset",
      "Name" => "Start Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0078",
      "group" => "3008"
    },
    "122" => {
      "KeyWord" => "EndMeterset",
      "Name" => "End Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "007a",
      "group" => "3008"
    },
    "128" => {
      "KeyWord" => "ReferencedMeasuredDoseReferenceSequence",
      "Name" => "Referenced Measured Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0080",
      "group" => "3008"
    },
    "130" => {
      "KeyWord" => "ReferencedMeasuredDoseReferenceNumber",
      "Name" => "Referenced Measured Dose Reference Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0082",
      "group" => "3008"
    },
    "144" => {
      "KeyWord" => "ReferencedCalculatedDoseReferenceSequence",
      "Name" => "Referenced Calculated Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0090",
      "group" => "3008"
    },
    "146" => {
      "KeyWord" => "ReferencedCalculatedDoseReferenceNumber",
      "Name" => "Referenced Calculated Dose Reference Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0092",
      "group" => "3008"
    },
    "16" => {
      "KeyWord" => "MeasuredDoseReferenceSequence",
      "Name" => "Measured Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "3008"
    },
    "160" => {
      "KeyWord" => "BeamLimitingDeviceLeafPairsSequence",
      "Name" => "Beam Limiting Device Leaf Pairs Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00a0",
      "group" => "3008"
    },
    "176" => {
      "KeyWord" => "RecordedWedgeSequence",
      "Name" => "Recorded Wedge Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00b0",
      "group" => "3008"
    },
    "18" => {
      "KeyWord" => "MeasuredDoseDescription",
      "Name" => "Measured Dose Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0012",
      "group" => "3008"
    },
    "192" => {
      "KeyWord" => "RecordedCompensatorSequence",
      "Name" => "Recorded Compensator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00c0",
      "group" => "3008"
    },
    "20" => {
      "KeyWord" => "MeasuredDoseType",
      "Name" => "Measured Dose Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0014",
      "group" => "3008"
    },
    "208" => {
      "KeyWord" => "RecordedBlockSequence",
      "Name" => "Recorded Block Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00d0",
      "group" => "3008"
    },
    "22" => {
      "KeyWord" => "MeasuredDoseValue",
      "Name" => "Measured Dose Value",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0016",
      "group" => "3008"
    },
    "224" => {
      "KeyWord" => "TreatmentSummaryMeasuredDoseReferenceSequence",
      "Name" => "Treatment Summary Measured Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00e0",
      "group" => "3008"
    },
    "240" => {
      "KeyWord" => "RecordedSnoutSequence",
      "Name" => "Recorded Snout Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00f0",
      "group" => "3008"
    },
    "242" => {
      "KeyWord" => "RecordedRangeShifterSequence",
      "Name" => "Recorded Range Shifter Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00f2",
      "group" => "3008"
    },
    "244" => {
      "KeyWord" => "RecordedLateralSpreadingDeviceSequence",
      "Name" => "Recorded Lateral Spreading Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00f4",
      "group" => "3008"
    },
    "246" => {
      "KeyWord" => "RecordedRangeModulatorSequence",
      "Name" => "Recorded Range Modulator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00f6",
      "group" => "3008"
    },
    "256" => {
      "KeyWord" => "RecordedSourceSequence",
      "Name" => "Recorded Source Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0100",
      "group" => "3008"
    },
    "261" => {
      "KeyWord" => "SourceSerialNumber",
      "Name" => "Source Serial Number",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0105",
      "group" => "3008"
    },
    "272" => {
      "KeyWord" => "TreatmentSessionApplicationSetupSequence",
      "Name" => "Treatment Session Application Setup Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0110",
      "group" => "3008"
    },
    "278" => {
      "KeyWord" => "ApplicationSetupCheck",
      "Name" => "Application Setup Check",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0116",
      "group" => "3008"
    },
    "288" => {
      "KeyWord" => "RecordedBrachyAccessoryDeviceSequence",
      "Name" => "Recorded Brachy Accessory Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0120",
      "group" => "3008"
    },
    "290" => {
      "KeyWord" => "ReferencedBrachyAccessoryDeviceNumber",
      "Name" => "Referenced Brachy Accessory Device Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0122",
      "group" => "3008"
    },
    "304" => {
      "KeyWord" => "RecordedChannelSequence",
      "Name" => "Recorded Channel Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0130",
      "group" => "3008"
    },
    "306" => {
      "KeyWord" => "SpecifiedChannelTotalTime",
      "Name" => "Specified Channel Total Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0132",
      "group" => "3008"
    },
    "308" => {
      "KeyWord" => "DeliveredChannelTotalTime",
      "Name" => "Delivered Channel Total Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0134",
      "group" => "3008"
    },
    "310" => {
      "KeyWord" => "SpecifiedNumberOfPulses",
      "Name" => "Specified Number of Pulses",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0136",
      "group" => "3008"
    },
    "312" => {
      "KeyWord" => "DeliveredNumberOfPulses",
      "Name" => "Delivered Number of Pulses",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0138",
      "group" => "3008"
    },
    "314" => {
      "KeyWord" => "SpecifiedPulseRepetitionInterval",
      "Name" => "Specified Pulse Repetition Interval",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "013a",
      "group" => "3008"
    },
    "316" => {
      "KeyWord" => "DeliveredPulseRepetitionInterval",
      "Name" => "Delivered Pulse Repetition Interval",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "013c",
      "group" => "3008"
    },
    "32" => {
      "KeyWord" => "TreatmentSessionBeamSequence",
      "Name" => "Treatment Session Beam Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0020",
      "group" => "3008"
    },
    "320" => {
      "KeyWord" => "RecordedSourceApplicatorSequence",
      "Name" => "Recorded Source Applicator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0140",
      "group" => "3008"
    },
    "322" => {
      "KeyWord" => "ReferencedSourceApplicatorNumber",
      "Name" => "Referenced Source Applicator Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0142",
      "group" => "3008"
    },
    "33" => {
      "KeyWord" => "TreatmentSessionIonBeamSequence",
      "Name" => "Treatment Session Ion Beam Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0021",
      "group" => "3008"
    },
    "336" => {
      "KeyWord" => "RecordedChannelShieldSequence",
      "Name" => "Recorded Channel Shield Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0150",
      "group" => "3008"
    },
    "338" => {
      "KeyWord" => "ReferencedChannelShieldNumber",
      "Name" => "Referenced Channel Shield Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0152",
      "group" => "3008"
    },
    "34" => {
      "KeyWord" => "CurrentFractionNumber",
      "Name" => "Current Fraction Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0022",
      "group" => "3008"
    },
    "352" => {
      "KeyWord" => "BrachyControlPointDeliveredSequence",
      "Name" => "Brachy Control Point Delivered Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0160",
      "group" => "3008"
    },
    "354" => {
      "KeyWord" => "SafePositionExitDate",
      "Name" => "Safe Position Exit Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0162",
      "group" => "3008"
    },
    "356" => {
      "KeyWord" => "SafePositionExitTime",
      "Name" => "Safe Position Exit Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0164",
      "group" => "3008"
    },
    "358" => {
      "KeyWord" => "SafePositionReturnDate",
      "Name" => "Safe Position Return Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0166",
      "group" => "3008"
    },
    "36" => {
      "KeyWord" => "TreatmentControlPointDate",
      "Name" => "Treatment Control Point Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0024",
      "group" => "3008"
    },
    "360" => {
      "KeyWord" => "SafePositionReturnTime",
      "Name" => "Safe Position Return Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0168",
      "group" => "3008"
    },
    "37" => {
      "KeyWord" => "TreatmentControlPointTime",
      "Name" => "Treatment Control Point Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0025",
      "group" => "3008"
    },
    "42" => {
      "KeyWord" => "TreatmentTerminationStatus",
      "Name" => "Treatment Termination Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "002a",
      "group" => "3008"
    },
    "43" => {
      "KeyWord" => "TreatmentTerminationCode",
      "Name" => "Treatment Termination Code",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "002b",
      "group" => "3008"
    },
    "44" => {
      "KeyWord" => "TreatmentVerificationStatus",
      "Name" => "Treatment Verification Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "002c",
      "group" => "3008"
    },
    "48" => {
      "KeyWord" => "ReferencedTreatmentRecordSequence",
      "Name" => "Referenced Treatment Record Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0030",
      "group" => "3008"
    },
    "50" => {
      "KeyWord" => "SpecifiedPrimaryMeterset",
      "Name" => "Specified Primary Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0032",
      "group" => "3008"
    },
    "51" => {
      "KeyWord" => "SpecifiedSecondaryMeterset",
      "Name" => "Specified Secondary Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0033",
      "group" => "3008"
    },
    "512" => {
      "KeyWord" => "CurrentTreatmentStatus",
      "Name" => "Current Treatment Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0200",
      "group" => "3008"
    },
    "514" => {
      "KeyWord" => "TreatmentStatusComment",
      "Name" => "Treatment Status Comment",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0202",
      "group" => "3008"
    },
    "54" => {
      "KeyWord" => "DeliveredPrimaryMeterset",
      "Name" => "Delivered Primary Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0036",
      "group" => "3008"
    },
    "544" => {
      "KeyWord" => "FractionGroupSummarySequence",
      "Name" => "Fraction Group Summary Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0220",
      "group" => "3008"
    },
    "547" => {
      "KeyWord" => "ReferencedFractionNumber",
      "Name" => "Referenced Fraction Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0223",
      "group" => "3008"
    },
    "548" => {
      "KeyWord" => "FractionGroupType",
      "Name" => "Fraction Group Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0224",
      "group" => "3008"
    },
    "55" => {
      "KeyWord" => "DeliveredSecondaryMeterset",
      "Name" => "Delivered Secondary Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0037",
      "group" => "3008"
    },
    "560" => {
      "KeyWord" => "BeamStopperPosition",
      "Name" => "Beam Stopper Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0230",
      "group" => "3008"
    },
    "576" => {
      "KeyWord" => "FractionStatusSummarySequence",
      "Name" => "Fraction Status Summary Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0240",
      "group" => "3008"
    },
    "58" => {
      "KeyWord" => "SpecifiedTreatmentTime",
      "Name" => "Specified Treatment Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "003a",
      "group" => "3008"
    },
    "59" => {
      "KeyWord" => "DeliveredTreatmentTime",
      "Name" => "Delivered Treatment Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "003b",
      "group" => "3008"
    },
    "592" => {
      "KeyWord" => "TreatmentDate",
      "Name" => "Treatment Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0250",
      "group" => "3008"
    },
    "593" => {
      "KeyWord" => "TreatmentTime",
      "Name" => "Treatment Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0251",
      "group" => "3008"
    },
    "64" => {
      "KeyWord" => "ControlPointDeliverySequence",
      "Name" => "Control Point Delivery Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0040",
      "group" => "3008"
    },
    "65" => {
      "KeyWord" => "IonControlPointDeliverySequence",
      "Name" => "Ion Control Point Delivery Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0041",
      "group" => "3008"
    },
    "66" => {
      "KeyWord" => "SpecifiedMeterset",
      "Name" => "Specified Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0042",
      "group" => "3008"
    },
    "68" => {
      "KeyWord" => "DeliveredMeterset",
      "Name" => "Delivered Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0044",
      "group" => "3008"
    },
    "69" => {
      "KeyWord" => "MetersetRateSet",
      "Name" => "Meterset Rate Set",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0045",
      "group" => "3008"
    },
    "70" => {
      "KeyWord" => "MetersetRateDelivered",
      "Name" => "Meterset Rate Delivered",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0046",
      "group" => "3008"
    },
    "71" => {
      "KeyWord" => "ScanSpotMetersetsDelivered",
      "Name" => "Scan Spot Metersets Delivered",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "0047",
      "group" => "3008"
    },
    "72" => {
      "KeyWord" => "DoseRateDelivered",
      "Name" => "Dose Rate Delivered",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0048",
      "group" => "3008"
    },
    "80" => {
      "KeyWord" => "TreatmentSummaryCalculatedDoseReferenceSequence",
      "Name" => "Treatment Summary Calculated Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "3008"
    },
    "82" => {
      "KeyWord" => "CumulativeDoseToDoseReference",
      "Name" => "Cumulative Dose to Dose Reference",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0052",
      "group" => "3008"
    },
    "84" => {
      "KeyWord" => "FirstTreatmentDate",
      "Name" => "First Treatment Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0054",
      "group" => "3008"
    },
    "86" => {
      "KeyWord" => "MostRecentTreatmentDate",
      "Name" => "Most Recent Treatment Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0056",
      "group" => "3008"
    },
    "90" => {
      "KeyWord" => "NumberOfFractionsDelivered",
      "Name" => "Number of Fractions Delivered",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "005a",
      "group" => "3008"
    },
    "96" => {
      "KeyWord" => "OverrideSequence",
      "Name" => "Override Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0060",
      "group" => "3008"
    },
    "97" => {
      "KeyWord" => "ParameterSequencePointer",
      "Name" => "Parameter Sequence Pointer",
      "VM" => "1",
      "VR" => "AT",
      "ele" => "0061",
      "group" => "3008"
    },
    "98" => {
      "KeyWord" => "OverrideParameterPointer",
      "Name" => "Override Parameter Pointer",
      "VM" => "1",
      "VR" => "AT",
      "ele" => "0062",
      "group" => "3008"
    },
    "99" => {
      "KeyWord" => "ParameterItemIndex",
      "Name" => "Parameter Item Index",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0063",
      "group" => "3008"
    }
  },
  "12298" => {
    "10" => {
      "KeyWord" => "PlanIntent",
      "Name" => "Plan Intent",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000a",
      "group" => "300a"
    },
    "1025" => {
      "KeyWord" => "ReferencedSetupImageSequence",
      "Name" => "Referenced Setup Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0401",
      "group" => "300a"
    },
    "1026" => {
      "KeyWord" => "SetupImageComment",
      "Name" => "Setup Image Comment",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0402",
      "group" => "300a"
    },
    "1040" => {
      "KeyWord" => "MotionSynchronizationSequence",
      "Name" => "Motion Synchronization Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0410",
      "group" => "300a"
    },
    "1042" => {
      "KeyWord" => "ControlPointOrientation",
      "Name" => "Control Point Orientation",
      "VM" => "3",
      "VR" => "FL",
      "ele" => "0412",
      "group" => "300a"
    },
    "1056" => {
      "KeyWord" => "GeneralAccessorySequence",
      "Name" => "General Accessory Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0420",
      "group" => "300a"
    },
    "1057" => {
      "KeyWord" => "GeneralAccessoryID",
      "Name" => "General Accessory ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0421",
      "group" => "300a"
    },
    "1058" => {
      "KeyWord" => "GeneralAccessoryDescription",
      "Name" => "General Accessory Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0422",
      "group" => "300a"
    },
    "1059" => {
      "KeyWord" => "GeneralAccessoryType",
      "Name" => "General Accessory Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0423",
      "group" => "300a"
    },
    "1060" => {
      "KeyWord" => "GeneralAccessoryNumber",
      "Name" => "General Accessory Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0424",
      "group" => "300a"
    },
    "1061" => {
      "KeyWord" => "SourceToGeneralAccessoryDistance",
      "Name" => "Source to General Accessory Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0425",
      "group" => "300a"
    },
    "1073" => {
      "KeyWord" => "ApplicatorGeometrySequence",
      "Name" => "Applicator Geometry Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0431",
      "group" => "300a"
    },
    "1074" => {
      "KeyWord" => "ApplicatorApertureShape",
      "Name" => "Applicator Aperture Shape",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0432",
      "group" => "300a"
    },
    "1075" => {
      "KeyWord" => "ApplicatorOpening",
      "Name" => "Applicator Opening",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0433",
      "group" => "300a"
    },
    "1076" => {
      "KeyWord" => "ApplicatorOpeningX",
      "Name" => "Applicator Opening X",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0434",
      "group" => "300a"
    },
    "1077" => {
      "KeyWord" => "ApplicatorOpeningY",
      "Name" => "Applicator Opening Y",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0435",
      "group" => "300a"
    },
    "1078" => {
      "KeyWord" => "SourceToApplicatorMountingPositionDistance",
      "Name" => "Source to Applicator Mounting Position Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0436",
      "group" => "300a"
    },
    "11" => {
      "KeyWord" => "TreatmentSites",
      "Name" => "Treatment Sites",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "000b",
      "group" => "300a"
    },
    "112" => {
      "KeyWord" => "FractionGroupSequence",
      "Name" => "Fraction Group Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0070",
      "group" => "300a"
    },
    "113" => {
      "KeyWord" => "FractionGroupNumber",
      "Name" => "Fraction Group Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0071",
      "group" => "300a"
    },
    "114" => {
      "KeyWord" => "FractionGroupDescription",
      "Name" => "Fraction Group Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0072",
      "group" => "300a"
    },
    "12" => {
      "KeyWord" => "RTPlanGeometry",
      "Name" => "RT Plan Geometry",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000c",
      "group" => "300a"
    },
    "120" => {
      "KeyWord" => "NumberOfFractionsPlanned",
      "Name" => "Number of Fractions Planned",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0078",
      "group" => "300a"
    },
    "121" => {
      "KeyWord" => "NumberOfFractionPatternDigitsPerDay",
      "Name" => "Number of Fraction Pattern Digits Per Day",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0079",
      "group" => "300a"
    },
    "122" => {
      "KeyWord" => "RepeatFractionCycleLength",
      "Name" => "Repeat Fraction Cycle Length",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "007a",
      "group" => "300a"
    },
    "123" => {
      "KeyWord" => "FractionPattern",
      "Name" => "Fraction Pattern",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "007b",
      "group" => "300a"
    },
    "128" => {
      "KeyWord" => "NumberOfBeams",
      "Name" => "Number of Beams",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0080",
      "group" => "300a"
    },
    "130" => {
      "KeyWord" => "BeamDoseSpecificationPoint",
      "Name" => "Beam Dose Specification Point",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "0082",
      "group" => "300a"
    },
    "132" => {
      "KeyWord" => "BeamDose",
      "Name" => "Beam Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0084",
      "group" => "300a"
    },
    "134" => {
      "KeyWord" => "BeamMeterset",
      "Name" => "Beam Meterset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0086",
      "group" => "300a"
    },
    "136" => {
      "KeyWord" => "BeamDosePointDepth",
      "Name" => "Beam Dose Point Depth",
      "RET" => "1",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0088",
      "group" => "300a"
    },
    "137" => {
      "KeyWord" => "BeamDosePointEquivalentDepth",
      "Name" => "Beam Dose Point Equivalent Depth",
      "RET" => "1",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0089",
      "group" => "300a"
    },
    "138" => {
      "KeyWord" => "BeamDosePointSSD",
      "Name" => "Beam Dose Point SSD",
      "RET" => "1",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "008a",
      "group" => "300a"
    },
    "139" => {
      "KeyWord" => "BeamDoseMeaning",
      "Name" => "Beam Dose Meaning",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "008b",
      "group" => "300a"
    },
    "14" => {
      "KeyWord" => "PrescriptionDescription",
      "Name" => "Prescription Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "000e",
      "group" => "300a"
    },
    "140" => {
      "KeyWord" => "BeamDoseVerificationControlPointSequence",
      "Name" => "Beam Dose Verification Control Point Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "008c",
      "group" => "300a"
    },
    "141" => {
      "KeyWord" => "AverageBeamDosePointDepth",
      "Name" => "Average Beam Dose Point Depth",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "008d",
      "group" => "300a"
    },
    "142" => {
      "KeyWord" => "AverageBeamDosePointEquivalentDepth",
      "Name" => "Average Beam Dose Point Equivalent Depth",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "008e",
      "group" => "300a"
    },
    "143" => {
      "KeyWord" => "AverageBeamDosePointSSD",
      "Name" => "Average Beam Dose Point SSD",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "008f",
      "group" => "300a"
    },
    "16" => {
      "KeyWord" => "DoseReferenceSequence",
      "Name" => "Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "300a"
    },
    "160" => {
      "KeyWord" => "NumberOfBrachyApplicationSetups",
      "Name" => "Number of Brachy Application Setups",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00a0",
      "group" => "300a"
    },
    "162" => {
      "KeyWord" => "BrachyApplicationSetupDoseSpecificationPoint",
      "Name" => "Brachy Application Setup Dose Specification Point",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "00a2",
      "group" => "300a"
    },
    "164" => {
      "KeyWord" => "BrachyApplicationSetupDose",
      "Name" => "Brachy Application Setup Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00a4",
      "group" => "300a"
    },
    "176" => {
      "KeyWord" => "BeamSequence",
      "Name" => "Beam Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00b0",
      "group" => "300a"
    },
    "178" => {
      "KeyWord" => "TreatmentMachineName",
      "Name" => "Treatment Machine Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "00b2",
      "group" => "300a"
    },
    "179" => {
      "KeyWord" => "PrimaryDosimeterUnit",
      "Name" => "Primary Dosimeter Unit",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00b3",
      "group" => "300a"
    },
    "18" => {
      "KeyWord" => "DoseReferenceNumber",
      "Name" => "Dose Reference Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0012",
      "group" => "300a"
    },
    "180" => {
      "KeyWord" => "SourceAxisDistance",
      "Name" => "Source-Axis Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00b4",
      "group" => "300a"
    },
    "182" => {
      "KeyWord" => "BeamLimitingDeviceSequence",
      "Name" => "Beam Limiting Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00b6",
      "group" => "300a"
    },
    "184" => {
      "KeyWord" => "RTBeamLimitingDeviceType",
      "Name" => "RT Beam Limiting Device Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00b8",
      "group" => "300a"
    },
    "186" => {
      "KeyWord" => "SourceToBeamLimitingDeviceDistance",
      "Name" => "Source to Beam Limiting Device Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00ba",
      "group" => "300a"
    },
    "187" => {
      "KeyWord" => "IsocenterToBeamLimitingDeviceDistance",
      "Name" => "Isocenter to Beam Limiting Device Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "00bb",
      "group" => "300a"
    },
    "188" => {
      "KeyWord" => "NumberOfLeafJawPairs",
      "Name" => "Number of Leaf/Jaw Pairs",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00bc",
      "group" => "300a"
    },
    "19" => {
      "KeyWord" => "DoseReferenceUID",
      "Name" => "Dose Reference UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0013",
      "group" => "300a"
    },
    "190" => {
      "KeyWord" => "LeafPositionBoundaries",
      "Name" => "Leaf Position Boundaries",
      "VM" => "3-n",
      "VR" => "DS",
      "ele" => "00be",
      "group" => "300a"
    },
    "192" => {
      "KeyWord" => "BeamNumber",
      "Name" => "Beam Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00c0",
      "group" => "300a"
    },
    "194" => {
      "KeyWord" => "BeamName",
      "Name" => "Beam Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "00c2",
      "group" => "300a"
    },
    "195" => {
      "KeyWord" => "BeamDescription",
      "Name" => "Beam Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "00c3",
      "group" => "300a"
    },
    "196" => {
      "KeyWord" => "BeamType",
      "Name" => "Beam Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00c4",
      "group" => "300a"
    },
    "198" => {
      "KeyWord" => "RadiationType",
      "Name" => "Radiation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00c6",
      "group" => "300a"
    },
    "199" => {
      "KeyWord" => "HighDoseTechniqueType",
      "Name" => "High-Dose Technique Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00c7",
      "group" => "300a"
    },
    "2" => {
      "KeyWord" => "RTPlanLabel",
      "Name" => "RT Plan Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0002",
      "group" => "300a"
    },
    "20" => {
      "KeyWord" => "DoseReferenceStructureType",
      "Name" => "Dose Reference Structure Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0014",
      "group" => "300a"
    },
    "200" => {
      "KeyWord" => "ReferenceImageNumber",
      "Name" => "Reference Image Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00c8",
      "group" => "300a"
    },
    "202" => {
      "KeyWord" => "PlannedVerificationImageSequence",
      "Name" => "Planned Verification Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00ca",
      "group" => "300a"
    },
    "204" => {
      "KeyWord" => "ImagingDeviceSpecificAcquisitionParameters",
      "Name" => "Imaging Device-Specific Acquisition Parameters",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "00cc",
      "group" => "300a"
    },
    "206" => {
      "KeyWord" => "TreatmentDeliveryType",
      "Name" => "Treatment Delivery Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00ce",
      "group" => "300a"
    },
    "208" => {
      "KeyWord" => "NumberOfWedges",
      "Name" => "Number of Wedges",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00d0",
      "group" => "300a"
    },
    "209" => {
      "KeyWord" => "WedgeSequence",
      "Name" => "Wedge Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00d1",
      "group" => "300a"
    },
    "21" => {
      "KeyWord" => "NominalBeamEnergyUnit",
      "Name" => "Nominal Beam Energy Unit",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0015",
      "group" => "300a"
    },
    "210" => {
      "KeyWord" => "WedgeNumber",
      "Name" => "Wedge Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00d2",
      "group" => "300a"
    },
    "211" => {
      "KeyWord" => "WedgeType",
      "Name" => "Wedge Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00d3",
      "group" => "300a"
    },
    "212" => {
      "KeyWord" => "WedgeID",
      "Name" => "Wedge ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "00d4",
      "group" => "300a"
    },
    "213" => {
      "KeyWord" => "WedgeAngle",
      "Name" => "Wedge Angle",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00d5",
      "group" => "300a"
    },
    "214" => {
      "KeyWord" => "WedgeFactor",
      "Name" => "Wedge Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00d6",
      "group" => "300a"
    },
    "215" => {
      "KeyWord" => "TotalWedgeTrayWaterEquivalentThickness",
      "Name" => "Total Wedge Tray Water-Equivalent Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "00d7",
      "group" => "300a"
    },
    "216" => {
      "KeyWord" => "WedgeOrientation",
      "Name" => "Wedge Orientation",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00d8",
      "group" => "300a"
    },
    "217" => {
      "KeyWord" => "IsocenterToWedgeTrayDistance",
      "Name" => "Isocenter to Wedge Tray Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "00d9",
      "group" => "300a"
    },
    "218" => {
      "KeyWord" => "SourceToWedgeTrayDistance",
      "Name" => "Source to Wedge Tray Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00da",
      "group" => "300a"
    },
    "219" => {
      "KeyWord" => "WedgeThinEdgePosition",
      "Name" => "Wedge Thin Edge Position",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "00db",
      "group" => "300a"
    },
    "22" => {
      "KeyWord" => "DoseReferenceDescription",
      "Name" => "Dose Reference Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0016",
      "group" => "300a"
    },
    "220" => {
      "KeyWord" => "BolusID",
      "Name" => "Bolus ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "00dc",
      "group" => "300a"
    },
    "221" => {
      "KeyWord" => "BolusDescription",
      "Name" => "Bolus Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "00dd",
      "group" => "300a"
    },
    "224" => {
      "KeyWord" => "NumberOfCompensators",
      "Name" => "Number of Compensators",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00e0",
      "group" => "300a"
    },
    "225" => {
      "KeyWord" => "MaterialID",
      "Name" => "Material ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "00e1",
      "group" => "300a"
    },
    "226" => {
      "KeyWord" => "TotalCompensatorTrayFactor",
      "Name" => "Total Compensator Tray Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00e2",
      "group" => "300a"
    },
    "227" => {
      "KeyWord" => "CompensatorSequence",
      "Name" => "Compensator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00e3",
      "group" => "300a"
    },
    "228" => {
      "KeyWord" => "CompensatorNumber",
      "Name" => "Compensator Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00e4",
      "group" => "300a"
    },
    "229" => {
      "KeyWord" => "CompensatorID",
      "Name" => "Compensator ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "00e5",
      "group" => "300a"
    },
    "230" => {
      "KeyWord" => "SourceToCompensatorTrayDistance",
      "Name" => "Source to Compensator Tray Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00e6",
      "group" => "300a"
    },
    "231" => {
      "KeyWord" => "CompensatorRows",
      "Name" => "Compensator Rows",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00e7",
      "group" => "300a"
    },
    "232" => {
      "KeyWord" => "CompensatorColumns",
      "Name" => "Compensator Columns",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00e8",
      "group" => "300a"
    },
    "233" => {
      "KeyWord" => "CompensatorPixelSpacing",
      "Name" => "Compensator Pixel Spacing",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "00e9",
      "group" => "300a"
    },
    "234" => {
      "KeyWord" => "CompensatorPosition",
      "Name" => "Compensator Position",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "00ea",
      "group" => "300a"
    },
    "235" => {
      "KeyWord" => "CompensatorTransmissionData",
      "Name" => "Compensator Transmission Data",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "00eb",
      "group" => "300a"
    },
    "236" => {
      "KeyWord" => "CompensatorThicknessData",
      "Name" => "Compensator Thickness Data",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "00ec",
      "group" => "300a"
    },
    "237" => {
      "KeyWord" => "NumberOfBoli",
      "Name" => "Number of Boli",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00ed",
      "group" => "300a"
    },
    "238" => {
      "KeyWord" => "CompensatorType",
      "Name" => "Compensator Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00ee",
      "group" => "300a"
    },
    "239" => {
      "KeyWord" => "CompensatorTrayID",
      "Name" => "Compensator Tray ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "00ef",
      "group" => "300a"
    },
    "24" => {
      "KeyWord" => "DoseReferencePointCoordinates",
      "Name" => "Dose Reference Point Coordinates",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "0018",
      "group" => "300a"
    },
    "240" => {
      "KeyWord" => "NumberOfBlocks",
      "Name" => "Number of Blocks",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00f0",
      "group" => "300a"
    },
    "242" => {
      "KeyWord" => "TotalBlockTrayFactor",
      "Name" => "Total Block Tray Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00f2",
      "group" => "300a"
    },
    "243" => {
      "KeyWord" => "TotalBlockTrayWaterEquivalentThickness",
      "Name" => "Total Block Tray Water-Equivalent Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "00f3",
      "group" => "300a"
    },
    "244" => {
      "KeyWord" => "BlockSequence",
      "Name" => "Block Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00f4",
      "group" => "300a"
    },
    "245" => {
      "KeyWord" => "BlockTrayID",
      "Name" => "Block Tray ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "00f5",
      "group" => "300a"
    },
    "246" => {
      "KeyWord" => "SourceToBlockTrayDistance",
      "Name" => "Source to Block Tray Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "00f6",
      "group" => "300a"
    },
    "247" => {
      "KeyWord" => "IsocenterToBlockTrayDistance",
      "Name" => "Isocenter to Block Tray Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "00f7",
      "group" => "300a"
    },
    "248" => {
      "KeyWord" => "BlockType",
      "Name" => "Block Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00f8",
      "group" => "300a"
    },
    "249" => {
      "KeyWord" => "AccessoryCode",
      "Name" => "Accessory Code",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "00f9",
      "group" => "300a"
    },
    "250" => {
      "KeyWord" => "BlockDivergence",
      "Name" => "Block Divergence",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00fa",
      "group" => "300a"
    },
    "251" => {
      "KeyWord" => "BlockMountingPosition",
      "Name" => "Block Mounting Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00fb",
      "group" => "300a"
    },
    "252" => {
      "KeyWord" => "BlockNumber",
      "Name" => "Block Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00fc",
      "group" => "300a"
    },
    "254" => {
      "KeyWord" => "BlockName",
      "Name" => "Block Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "00fe",
      "group" => "300a"
    },
    "256" => {
      "KeyWord" => "BlockThickness",
      "Name" => "Block Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0100",
      "group" => "300a"
    },
    "258" => {
      "KeyWord" => "BlockTransmission",
      "Name" => "Block Transmission",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0102",
      "group" => "300a"
    },
    "26" => {
      "KeyWord" => "NominalPriorDose",
      "Name" => "Nominal Prior Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "001a",
      "group" => "300a"
    },
    "260" => {
      "KeyWord" => "BlockNumberOfPoints",
      "Name" => "Block Number of Points",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0104",
      "group" => "300a"
    },
    "262" => {
      "KeyWord" => "BlockData",
      "Name" => "Block Data",
      "VM" => "2-2n",
      "VR" => "DS",
      "ele" => "0106",
      "group" => "300a"
    },
    "263" => {
      "KeyWord" => "ApplicatorSequence",
      "Name" => "Applicator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0107",
      "group" => "300a"
    },
    "264" => {
      "KeyWord" => "ApplicatorID",
      "Name" => "Applicator ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0108",
      "group" => "300a"
    },
    "265" => {
      "KeyWord" => "ApplicatorType",
      "Name" => "Applicator Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0109",
      "group" => "300a"
    },
    "266" => {
      "KeyWord" => "ApplicatorDescription",
      "Name" => "Applicator Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "010a",
      "group" => "300a"
    },
    "268" => {
      "KeyWord" => "CumulativeDoseReferenceCoefficient",
      "Name" => "Cumulative Dose Reference Coefficient",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "010c",
      "group" => "300a"
    },
    "270" => {
      "KeyWord" => "FinalCumulativeMetersetWeight",
      "Name" => "Final Cumulative Meterset Weight",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "010e",
      "group" => "300a"
    },
    "272" => {
      "KeyWord" => "NumberOfControlPoints",
      "Name" => "Number of Control Points",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0110",
      "group" => "300a"
    },
    "273" => {
      "KeyWord" => "ControlPointSequence",
      "Name" => "Control Point Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0111",
      "group" => "300a"
    },
    "274" => {
      "KeyWord" => "ControlPointIndex",
      "Name" => "Control Point Index",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0112",
      "group" => "300a"
    },
    "276" => {
      "KeyWord" => "NominalBeamEnergy",
      "Name" => "Nominal Beam Energy",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0114",
      "group" => "300a"
    },
    "277" => {
      "KeyWord" => "DoseRateSet",
      "Name" => "Dose Rate Set",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0115",
      "group" => "300a"
    },
    "278" => {
      "KeyWord" => "WedgePositionSequence",
      "Name" => "Wedge Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0116",
      "group" => "300a"
    },
    "280" => {
      "KeyWord" => "WedgePosition",
      "Name" => "Wedge Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0118",
      "group" => "300a"
    },
    "282" => {
      "KeyWord" => "BeamLimitingDevicePositionSequence",
      "Name" => "Beam Limiting Device Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "011a",
      "group" => "300a"
    },
    "284" => {
      "KeyWord" => "LeafJawPositions",
      "Name" => "Leaf/Jaw Positions",
      "VM" => "2-2n",
      "VR" => "DS",
      "ele" => "011c",
      "group" => "300a"
    },
    "286" => {
      "KeyWord" => "GantryAngle",
      "Name" => "Gantry Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "011e",
      "group" => "300a"
    },
    "287" => {
      "KeyWord" => "GantryRotationDirection",
      "Name" => "Gantry Rotation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "011f",
      "group" => "300a"
    },
    "288" => {
      "KeyWord" => "BeamLimitingDeviceAngle",
      "Name" => "Beam Limiting Device Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0120",
      "group" => "300a"
    },
    "289" => {
      "KeyWord" => "BeamLimitingDeviceRotationDirection",
      "Name" => "Beam Limiting Device Rotation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0121",
      "group" => "300a"
    },
    "290" => {
      "KeyWord" => "PatientSupportAngle",
      "Name" => "Patient Support Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0122",
      "group" => "300a"
    },
    "291" => {
      "KeyWord" => "PatientSupportRotationDirection",
      "Name" => "Patient Support Rotation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0123",
      "group" => "300a"
    },
    "292" => {
      "KeyWord" => "TableTopEccentricAxisDistance",
      "Name" => "Table Top Eccentric Axis Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0124",
      "group" => "300a"
    },
    "293" => {
      "KeyWord" => "TableTopEccentricAngle",
      "Name" => "Table Top Eccentric Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0125",
      "group" => "300a"
    },
    "294" => {
      "KeyWord" => "TableTopEccentricRotationDirection",
      "Name" => "Table Top Eccentric Rotation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0126",
      "group" => "300a"
    },
    "296" => {
      "KeyWord" => "TableTopVerticalPosition",
      "Name" => "Table Top Vertical Position",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0128",
      "group" => "300a"
    },
    "297" => {
      "KeyWord" => "TableTopLongitudinalPosition",
      "Name" => "Table Top Longitudinal Position",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0129",
      "group" => "300a"
    },
    "298" => {
      "KeyWord" => "TableTopLateralPosition",
      "Name" => "Table Top Lateral Position",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "012a",
      "group" => "300a"
    },
    "3" => {
      "KeyWord" => "RTPlanName",
      "Name" => "RT Plan Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0003",
      "group" => "300a"
    },
    "300" => {
      "KeyWord" => "IsocenterPosition",
      "Name" => "Isocenter Position",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "012c",
      "group" => "300a"
    },
    "302" => {
      "KeyWord" => "SurfaceEntryPoint",
      "Name" => "Surface Entry Point",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "012e",
      "group" => "300a"
    },
    "304" => {
      "KeyWord" => "SourceToSurfaceDistance",
      "Name" => "Source to Surface Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0130",
      "group" => "300a"
    },
    "308" => {
      "KeyWord" => "CumulativeMetersetWeight",
      "Name" => "Cumulative Meterset Weight",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0134",
      "group" => "300a"
    },
    "32" => {
      "KeyWord" => "DoseReferenceType",
      "Name" => "Dose Reference Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "300a"
    },
    "320" => {
      "KeyWord" => "TableTopPitchAngle",
      "Name" => "Table Top Pitch Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0140",
      "group" => "300a"
    },
    "322" => {
      "KeyWord" => "TableTopPitchRotationDirection",
      "Name" => "Table Top Pitch Rotation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0142",
      "group" => "300a"
    },
    "324" => {
      "KeyWord" => "TableTopRollAngle",
      "Name" => "Table Top Roll Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0144",
      "group" => "300a"
    },
    "326" => {
      "KeyWord" => "TableTopRollRotationDirection",
      "Name" => "Table Top Roll Rotation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0146",
      "group" => "300a"
    },
    "328" => {
      "KeyWord" => "HeadFixationAngle",
      "Name" => "Head Fixation Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0148",
      "group" => "300a"
    },
    "33" => {
      "KeyWord" => "ConstraintWeight",
      "Name" => "Constraint Weight",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0021",
      "group" => "300a"
    },
    "330" => {
      "KeyWord" => "GantryPitchAngle",
      "Name" => "Gantry Pitch Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "014a",
      "group" => "300a"
    },
    "332" => {
      "KeyWord" => "GantryPitchRotationDirection",
      "Name" => "Gantry Pitch Rotation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "014c",
      "group" => "300a"
    },
    "334" => {
      "KeyWord" => "GantryPitchAngleTolerance",
      "Name" => "Gantry Pitch Angle Tolerance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "014e",
      "group" => "300a"
    },
    "34" => {
      "KeyWord" => "DeliveryWarningDose",
      "Name" => "Delivery Warning Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0022",
      "group" => "300a"
    },
    "35" => {
      "KeyWord" => "DeliveryMaximumDose",
      "Name" => "Delivery Maximum Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0023",
      "group" => "300a"
    },
    "37" => {
      "KeyWord" => "TargetMinimumDose",
      "Name" => "Target Minimum Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0025",
      "group" => "300a"
    },
    "38" => {
      "KeyWord" => "TargetPrescriptionDose",
      "Name" => "Target Prescription Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0026",
      "group" => "300a"
    },
    "384" => {
      "KeyWord" => "PatientSetupSequence",
      "Name" => "Patient Setup Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0180",
      "group" => "300a"
    },
    "386" => {
      "KeyWord" => "PatientSetupNumber",
      "Name" => "Patient Setup Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0182",
      "group" => "300a"
    },
    "387" => {
      "KeyWord" => "PatientSetupLabel",
      "Name" => "Patient Setup Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0183",
      "group" => "300a"
    },
    "388" => {
      "KeyWord" => "PatientAdditionalPosition",
      "Name" => "Patient Additional Position",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0184",
      "group" => "300a"
    },
    "39" => {
      "KeyWord" => "TargetMaximumDose",
      "Name" => "Target Maximum Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0027",
      "group" => "300a"
    },
    "4" => {
      "KeyWord" => "RTPlanDescription",
      "Name" => "RT Plan Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0004",
      "group" => "300a"
    },
    "40" => {
      "KeyWord" => "TargetUnderdoseVolumeFraction",
      "Name" => "Target Underdose Volume Fraction",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0028",
      "group" => "300a"
    },
    "400" => {
      "KeyWord" => "FixationDeviceSequence",
      "Name" => "Fixation Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0190",
      "group" => "300a"
    },
    "402" => {
      "KeyWord" => "FixationDeviceType",
      "Name" => "Fixation Device Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0192",
      "group" => "300a"
    },
    "404" => {
      "KeyWord" => "FixationDeviceLabel",
      "Name" => "Fixation Device Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0194",
      "group" => "300a"
    },
    "406" => {
      "KeyWord" => "FixationDeviceDescription",
      "Name" => "Fixation Device Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0196",
      "group" => "300a"
    },
    "408" => {
      "KeyWord" => "FixationDevicePosition",
      "Name" => "Fixation Device Position",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0198",
      "group" => "300a"
    },
    "409" => {
      "KeyWord" => "FixationDevicePitchAngle",
      "Name" => "Fixation Device Pitch Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0199",
      "group" => "300a"
    },
    "410" => {
      "KeyWord" => "FixationDeviceRollAngle",
      "Name" => "Fixation Device Roll Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "019a",
      "group" => "300a"
    },
    "416" => {
      "KeyWord" => "ShieldingDeviceSequence",
      "Name" => "Shielding Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "01a0",
      "group" => "300a"
    },
    "418" => {
      "KeyWord" => "ShieldingDeviceType",
      "Name" => "Shielding Device Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "01a2",
      "group" => "300a"
    },
    "42" => {
      "KeyWord" => "OrganAtRiskFullVolumeDose",
      "Name" => "Organ at Risk Full-volume Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "002a",
      "group" => "300a"
    },
    "420" => {
      "KeyWord" => "ShieldingDeviceLabel",
      "Name" => "Shielding Device Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "01a4",
      "group" => "300a"
    },
    "422" => {
      "KeyWord" => "ShieldingDeviceDescription",
      "Name" => "Shielding Device Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "01a6",
      "group" => "300a"
    },
    "424" => {
      "KeyWord" => "ShieldingDevicePosition",
      "Name" => "Shielding Device Position",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "01a8",
      "group" => "300a"
    },
    "43" => {
      "KeyWord" => "OrganAtRiskLimitDose",
      "Name" => "Organ at Risk Limit Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "002b",
      "group" => "300a"
    },
    "432" => {
      "KeyWord" => "SetupTechnique",
      "Name" => "Setup Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "01b0",
      "group" => "300a"
    },
    "434" => {
      "KeyWord" => "SetupTechniqueDescription",
      "Name" => "Setup Technique Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "01b2",
      "group" => "300a"
    },
    "436" => {
      "KeyWord" => "SetupDeviceSequence",
      "Name" => "Setup Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "01b4",
      "group" => "300a"
    },
    "438" => {
      "KeyWord" => "SetupDeviceType",
      "Name" => "Setup Device Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "01b6",
      "group" => "300a"
    },
    "44" => {
      "KeyWord" => "OrganAtRiskMaximumDose",
      "Name" => "Organ at Risk Maximum Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "002c",
      "group" => "300a"
    },
    "440" => {
      "KeyWord" => "SetupDeviceLabel",
      "Name" => "Setup Device Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "01b8",
      "group" => "300a"
    },
    "442" => {
      "KeyWord" => "SetupDeviceDescription",
      "Name" => "Setup Device Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "01ba",
      "group" => "300a"
    },
    "444" => {
      "KeyWord" => "SetupDeviceParameter",
      "Name" => "Setup Device Parameter",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "01bc",
      "group" => "300a"
    },
    "45" => {
      "KeyWord" => "OrganAtRiskOverdoseVolumeFraction",
      "Name" => "Organ at Risk Overdose Volume Fraction",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "002d",
      "group" => "300a"
    },
    "464" => {
      "KeyWord" => "SetupReferenceDescription",
      "Name" => "Setup Reference Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "01d0",
      "group" => "300a"
    },
    "466" => {
      "KeyWord" => "TableTopVerticalSetupDisplacement",
      "Name" => "Table Top Vertical Setup Displacement",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "01d2",
      "group" => "300a"
    },
    "468" => {
      "KeyWord" => "TableTopLongitudinalSetupDisplacement",
      "Name" => "Table Top Longitudinal Setup Displacement",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "01d4",
      "group" => "300a"
    },
    "470" => {
      "KeyWord" => "TableTopLateralSetupDisplacement",
      "Name" => "Table Top Lateral Setup Displacement",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "01d6",
      "group" => "300a"
    },
    "512" => {
      "KeyWord" => "BrachyTreatmentTechnique",
      "Name" => "Brachy Treatment Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0200",
      "group" => "300a"
    },
    "514" => {
      "KeyWord" => "BrachyTreatmentType",
      "Name" => "Brachy Treatment Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0202",
      "group" => "300a"
    },
    "518" => {
      "KeyWord" => "TreatmentMachineSequence",
      "Name" => "Treatment Machine Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0206",
      "group" => "300a"
    },
    "528" => {
      "KeyWord" => "SourceSequence",
      "Name" => "Source Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0210",
      "group" => "300a"
    },
    "530" => {
      "KeyWord" => "SourceNumber",
      "Name" => "Source Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0212",
      "group" => "300a"
    },
    "532" => {
      "KeyWord" => "SourceType",
      "Name" => "Source Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0214",
      "group" => "300a"
    },
    "534" => {
      "KeyWord" => "SourceManufacturer",
      "Name" => "Source Manufacturer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0216",
      "group" => "300a"
    },
    "536" => {
      "KeyWord" => "ActiveSourceDiameter",
      "Name" => "Active Source Diameter",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0218",
      "group" => "300a"
    },
    "538" => {
      "KeyWord" => "ActiveSourceLength",
      "Name" => "Active Source Length",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "021a",
      "group" => "300a"
    },
    "539" => {
      "KeyWord" => "SourceModelID",
      "Name" => "Source Model ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "021b",
      "group" => "300a"
    },
    "540" => {
      "KeyWord" => "SourceDescription",
      "Name" => "Source Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "021c",
      "group" => "300a"
    },
    "546" => {
      "KeyWord" => "SourceEncapsulationNominalThickness",
      "Name" => "Source Encapsulation Nominal Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0222",
      "group" => "300a"
    },
    "548" => {
      "KeyWord" => "SourceEncapsulationNominalTransmission",
      "Name" => "Source Encapsulation Nominal Transmission",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0224",
      "group" => "300a"
    },
    "550" => {
      "KeyWord" => "SourceIsotopeName",
      "Name" => "Source Isotope Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0226",
      "group" => "300a"
    },
    "552" => {
      "KeyWord" => "SourceIsotopeHalfLife",
      "Name" => "Source Isotope Half Life",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0228",
      "group" => "300a"
    },
    "553" => {
      "KeyWord" => "SourceStrengthUnits",
      "Name" => "Source Strength Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0229",
      "group" => "300a"
    },
    "554" => {
      "KeyWord" => "ReferenceAirKermaRate",
      "Name" => "Reference Air Kerma Rate",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "022a",
      "group" => "300a"
    },
    "555" => {
      "KeyWord" => "SourceStrength",
      "Name" => "Source Strength",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "022b",
      "group" => "300a"
    },
    "556" => {
      "KeyWord" => "SourceStrengthReferenceDate",
      "Name" => "Source Strength Reference Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "022c",
      "group" => "300a"
    },
    "558" => {
      "KeyWord" => "SourceStrengthReferenceTime",
      "Name" => "Source Strength Reference Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "022e",
      "group" => "300a"
    },
    "560" => {
      "KeyWord" => "ApplicationSetupSequence",
      "Name" => "Application Setup Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0230",
      "group" => "300a"
    },
    "562" => {
      "KeyWord" => "ApplicationSetupType",
      "Name" => "Application Setup Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0232",
      "group" => "300a"
    },
    "564" => {
      "KeyWord" => "ApplicationSetupNumber",
      "Name" => "Application Setup Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0234",
      "group" => "300a"
    },
    "566" => {
      "KeyWord" => "ApplicationSetupName",
      "Name" => "Application Setup Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0236",
      "group" => "300a"
    },
    "568" => {
      "KeyWord" => "ApplicationSetupManufacturer",
      "Name" => "Application Setup Manufacturer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0238",
      "group" => "300a"
    },
    "576" => {
      "KeyWord" => "TemplateNumber",
      "Name" => "Template Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0240",
      "group" => "300a"
    },
    "578" => {
      "KeyWord" => "TemplateType",
      "Name" => "Template Type",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0242",
      "group" => "300a"
    },
    "580" => {
      "KeyWord" => "TemplateName",
      "Name" => "Template Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0244",
      "group" => "300a"
    },
    "592" => {
      "KeyWord" => "TotalReferenceAirKerma",
      "Name" => "Total Reference Air Kerma",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0250",
      "group" => "300a"
    },
    "6" => {
      "KeyWord" => "RTPlanDate",
      "Name" => "RT Plan Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0006",
      "group" => "300a"
    },
    "608" => {
      "KeyWord" => "BrachyAccessoryDeviceSequence",
      "Name" => "Brachy Accessory Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0260",
      "group" => "300a"
    },
    "610" => {
      "KeyWord" => "BrachyAccessoryDeviceNumber",
      "Name" => "Brachy Accessory Device Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0262",
      "group" => "300a"
    },
    "611" => {
      "KeyWord" => "BrachyAccessoryDeviceID",
      "Name" => "Brachy Accessory Device ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0263",
      "group" => "300a"
    },
    "612" => {
      "KeyWord" => "BrachyAccessoryDeviceType",
      "Name" => "Brachy Accessory Device Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0264",
      "group" => "300a"
    },
    "614" => {
      "KeyWord" => "BrachyAccessoryDeviceName",
      "Name" => "Brachy Accessory Device Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0266",
      "group" => "300a"
    },
    "618" => {
      "KeyWord" => "BrachyAccessoryDeviceNominalThickness",
      "Name" => "Brachy Accessory Device Nominal Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "026a",
      "group" => "300a"
    },
    "620" => {
      "KeyWord" => "BrachyAccessoryDeviceNominalTransmission",
      "Name" => "Brachy Accessory Device Nominal Transmission",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "026c",
      "group" => "300a"
    },
    "64" => {
      "KeyWord" => "ToleranceTableSequence",
      "Name" => "Tolerance Table Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0040",
      "group" => "300a"
    },
    "640" => {
      "KeyWord" => "ChannelSequence",
      "Name" => "Channel Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0280",
      "group" => "300a"
    },
    "642" => {
      "KeyWord" => "ChannelNumber",
      "Name" => "Channel Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0282",
      "group" => "300a"
    },
    "644" => {
      "KeyWord" => "ChannelLength",
      "Name" => "Channel Length",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0284",
      "group" => "300a"
    },
    "646" => {
      "KeyWord" => "ChannelTotalTime",
      "Name" => "Channel Total Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0286",
      "group" => "300a"
    },
    "648" => {
      "KeyWord" => "SourceMovementType",
      "Name" => "Source Movement Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0288",
      "group" => "300a"
    },
    "650" => {
      "KeyWord" => "NumberOfPulses",
      "Name" => "Number of Pulses",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "028a",
      "group" => "300a"
    },
    "652" => {
      "KeyWord" => "PulseRepetitionInterval",
      "Name" => "Pulse Repetition Interval",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "028c",
      "group" => "300a"
    },
    "656" => {
      "KeyWord" => "SourceApplicatorNumber",
      "Name" => "Source Applicator Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0290",
      "group" => "300a"
    },
    "657" => {
      "KeyWord" => "SourceApplicatorID",
      "Name" => "Source Applicator ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0291",
      "group" => "300a"
    },
    "658" => {
      "KeyWord" => "SourceApplicatorType",
      "Name" => "Source Applicator Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0292",
      "group" => "300a"
    },
    "66" => {
      "KeyWord" => "ToleranceTableNumber",
      "Name" => "Tolerance Table Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0042",
      "group" => "300a"
    },
    "660" => {
      "KeyWord" => "SourceApplicatorName",
      "Name" => "Source Applicator Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0294",
      "group" => "300a"
    },
    "662" => {
      "KeyWord" => "SourceApplicatorLength",
      "Name" => "Source Applicator Length",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0296",
      "group" => "300a"
    },
    "664" => {
      "KeyWord" => "SourceApplicatorManufacturer",
      "Name" => "Source Applicator Manufacturer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0298",
      "group" => "300a"
    },
    "668" => {
      "KeyWord" => "SourceApplicatorWallNominalThickness",
      "Name" => "Source Applicator Wall Nominal Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "029c",
      "group" => "300a"
    },
    "67" => {
      "KeyWord" => "ToleranceTableLabel",
      "Name" => "Tolerance Table Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0043",
      "group" => "300a"
    },
    "670" => {
      "KeyWord" => "SourceApplicatorWallNominalTransmission",
      "Name" => "Source Applicator Wall Nominal Transmission",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "029e",
      "group" => "300a"
    },
    "672" => {
      "KeyWord" => "SourceApplicatorStepSize",
      "Name" => "Source Applicator Step Size",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "02a0",
      "group" => "300a"
    },
    "674" => {
      "KeyWord" => "TransferTubeNumber",
      "Name" => "Transfer Tube Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "02a2",
      "group" => "300a"
    },
    "676" => {
      "KeyWord" => "TransferTubeLength",
      "Name" => "Transfer Tube Length",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "02a4",
      "group" => "300a"
    },
    "68" => {
      "KeyWord" => "GantryAngleTolerance",
      "Name" => "Gantry Angle Tolerance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0044",
      "group" => "300a"
    },
    "688" => {
      "KeyWord" => "ChannelShieldSequence",
      "Name" => "Channel Shield Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "02b0",
      "group" => "300a"
    },
    "690" => {
      "KeyWord" => "ChannelShieldNumber",
      "Name" => "Channel Shield Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "02b2",
      "group" => "300a"
    },
    "691" => {
      "KeyWord" => "ChannelShieldID",
      "Name" => "Channel Shield ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "02b3",
      "group" => "300a"
    },
    "692" => {
      "KeyWord" => "ChannelShieldName",
      "Name" => "Channel Shield Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "02b4",
      "group" => "300a"
    },
    "696" => {
      "KeyWord" => "ChannelShieldNominalThickness",
      "Name" => "Channel Shield Nominal Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "02b8",
      "group" => "300a"
    },
    "698" => {
      "KeyWord" => "ChannelShieldNominalTransmission",
      "Name" => "Channel Shield Nominal Transmission",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "02ba",
      "group" => "300a"
    },
    "7" => {
      "KeyWord" => "RTPlanTime",
      "Name" => "RT Plan Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0007",
      "group" => "300a"
    },
    "70" => {
      "KeyWord" => "BeamLimitingDeviceAngleTolerance",
      "Name" => "Beam Limiting Device Angle Tolerance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0046",
      "group" => "300a"
    },
    "712" => {
      "KeyWord" => "FinalCumulativeTimeWeight",
      "Name" => "Final Cumulative Time Weight",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "02c8",
      "group" => "300a"
    },
    "72" => {
      "KeyWord" => "BeamLimitingDeviceToleranceSequence",
      "Name" => "Beam Limiting Device Tolerance Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0048",
      "group" => "300a"
    },
    "720" => {
      "KeyWord" => "BrachyControlPointSequence",
      "Name" => "Brachy Control Point Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "02d0",
      "group" => "300a"
    },
    "722" => {
      "KeyWord" => "ControlPointRelativePosition",
      "Name" => "Control Point Relative Position",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "02d2",
      "group" => "300a"
    },
    "724" => {
      "KeyWord" => "ControlPoint3DPosition",
      "Name" => "Control Point 3D Position",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "02d4",
      "group" => "300a"
    },
    "726" => {
      "KeyWord" => "CumulativeTimeWeight",
      "Name" => "Cumulative Time Weight",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "02d6",
      "group" => "300a"
    },
    "736" => {
      "KeyWord" => "CompensatorDivergence",
      "Name" => "Compensator Divergence",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "02e0",
      "group" => "300a"
    },
    "737" => {
      "KeyWord" => "CompensatorMountingPosition",
      "Name" => "Compensator Mounting Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "02e1",
      "group" => "300a"
    },
    "738" => {
      "KeyWord" => "SourceToCompensatorDistance",
      "Name" => "Source to Compensator Distance",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "02e2",
      "group" => "300a"
    },
    "739" => {
      "KeyWord" => "TotalCompensatorTrayWaterEquivalentThickness",
      "Name" => "Total Compensator Tray Water-Equivalent Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "02e3",
      "group" => "300a"
    },
    "74" => {
      "KeyWord" => "BeamLimitingDevicePositionTolerance",
      "Name" => "Beam Limiting Device Position Tolerance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "004a",
      "group" => "300a"
    },
    "740" => {
      "KeyWord" => "IsocenterToCompensatorTrayDistance",
      "Name" => "Isocenter to Compensator Tray Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "02e4",
      "group" => "300a"
    },
    "741" => {
      "KeyWord" => "CompensatorColumnOffset",
      "Name" => "Compensator Column Offset",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "02e5",
      "group" => "300a"
    },
    "742" => {
      "KeyWord" => "IsocenterToCompensatorDistances",
      "Name" => "Isocenter to Compensator Distances",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "02e6",
      "group" => "300a"
    },
    "743" => {
      "KeyWord" => "CompensatorRelativeStoppingPowerRatio",
      "Name" => "Compensator Relative Stopping Power Ratio",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "02e7",
      "group" => "300a"
    },
    "744" => {
      "KeyWord" => "CompensatorMillingToolDiameter",
      "Name" => "Compensator Milling Tool Diameter",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "02e8",
      "group" => "300a"
    },
    "746" => {
      "KeyWord" => "IonRangeCompensatorSequence",
      "Name" => "Ion Range Compensator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "02ea",
      "group" => "300a"
    },
    "747" => {
      "KeyWord" => "CompensatorDescription",
      "Name" => "Compensator Description",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "02eb",
      "group" => "300a"
    },
    "75" => {
      "KeyWord" => "SnoutPositionTolerance",
      "Name" => "Snout Position Tolerance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "004b",
      "group" => "300a"
    },
    "76" => {
      "KeyWord" => "PatientSupportAngleTolerance",
      "Name" => "Patient Support Angle Tolerance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "004c",
      "group" => "300a"
    },
    "770" => {
      "KeyWord" => "RadiationMassNumber",
      "Name" => "Radiation Mass Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0302",
      "group" => "300a"
    },
    "772" => {
      "KeyWord" => "RadiationAtomicNumber",
      "Name" => "Radiation Atomic Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0304",
      "group" => "300a"
    },
    "774" => {
      "KeyWord" => "RadiationChargeState",
      "Name" => "Radiation Charge State",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "0306",
      "group" => "300a"
    },
    "776" => {
      "KeyWord" => "ScanMode",
      "Name" => "Scan Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0308",
      "group" => "300a"
    },
    "778" => {
      "KeyWord" => "VirtualSourceAxisDistances",
      "Name" => "Virtual Source-Axis Distances",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "030a",
      "group" => "300a"
    },
    "78" => {
      "KeyWord" => "TableTopEccentricAngleTolerance",
      "Name" => "Table Top Eccentric Angle Tolerance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "004e",
      "group" => "300a"
    },
    "780" => {
      "KeyWord" => "SnoutSequence",
      "Name" => "Snout Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "030c",
      "group" => "300a"
    },
    "781" => {
      "KeyWord" => "SnoutPosition",
      "Name" => "Snout Position",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "030d",
      "group" => "300a"
    },
    "783" => {
      "KeyWord" => "SnoutID",
      "Name" => "Snout ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "030f",
      "group" => "300a"
    },
    "786" => {
      "KeyWord" => "NumberOfRangeShifters",
      "Name" => "Number of Range Shifters",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0312",
      "group" => "300a"
    },
    "788" => {
      "KeyWord" => "RangeShifterSequence",
      "Name" => "Range Shifter Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0314",
      "group" => "300a"
    },
    "79" => {
      "KeyWord" => "TableTopPitchAngleTolerance",
      "Name" => "Table Top Pitch Angle Tolerance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "004f",
      "group" => "300a"
    },
    "790" => {
      "KeyWord" => "RangeShifterNumber",
      "Name" => "Range Shifter Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0316",
      "group" => "300a"
    },
    "792" => {
      "KeyWord" => "RangeShifterID",
      "Name" => "Range Shifter ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0318",
      "group" => "300a"
    },
    "80" => {
      "KeyWord" => "TableTopRollAngleTolerance",
      "Name" => "Table Top Roll Angle Tolerance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0050",
      "group" => "300a"
    },
    "800" => {
      "KeyWord" => "RangeShifterType",
      "Name" => "Range Shifter Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0320",
      "group" => "300a"
    },
    "802" => {
      "KeyWord" => "RangeShifterDescription",
      "Name" => "Range Shifter Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0322",
      "group" => "300a"
    },
    "81" => {
      "KeyWord" => "TableTopVerticalPositionTolerance",
      "Name" => "Table Top Vertical Position Tolerance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0051",
      "group" => "300a"
    },
    "816" => {
      "KeyWord" => "NumberOfLateralSpreadingDevices",
      "Name" => "Number of Lateral Spreading Devices",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0330",
      "group" => "300a"
    },
    "818" => {
      "KeyWord" => "LateralSpreadingDeviceSequence",
      "Name" => "Lateral Spreading Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0332",
      "group" => "300a"
    },
    "82" => {
      "KeyWord" => "TableTopLongitudinalPositionTolerance",
      "Name" => "Table Top Longitudinal Position Tolerance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0052",
      "group" => "300a"
    },
    "820" => {
      "KeyWord" => "LateralSpreadingDeviceNumber",
      "Name" => "Lateral Spreading Device Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0334",
      "group" => "300a"
    },
    "822" => {
      "KeyWord" => "LateralSpreadingDeviceID",
      "Name" => "Lateral Spreading Device ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0336",
      "group" => "300a"
    },
    "824" => {
      "KeyWord" => "LateralSpreadingDeviceType",
      "Name" => "Lateral Spreading Device Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0338",
      "group" => "300a"
    },
    "826" => {
      "KeyWord" => "LateralSpreadingDeviceDescription",
      "Name" => "Lateral Spreading Device Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "033a",
      "group" => "300a"
    },
    "828" => {
      "KeyWord" => "LateralSpreadingDeviceWaterEquivalentThickness",
      "Name" => "Lateral Spreading Device Water Equivalent Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "033c",
      "group" => "300a"
    },
    "83" => {
      "KeyWord" => "TableTopLateralPositionTolerance",
      "Name" => "Table Top Lateral Position Tolerance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0053",
      "group" => "300a"
    },
    "832" => {
      "KeyWord" => "NumberOfRangeModulators",
      "Name" => "Number of Range Modulators",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0340",
      "group" => "300a"
    },
    "834" => {
      "KeyWord" => "RangeModulatorSequence",
      "Name" => "Range Modulator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0342",
      "group" => "300a"
    },
    "836" => {
      "KeyWord" => "RangeModulatorNumber",
      "Name" => "Range Modulator Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0344",
      "group" => "300a"
    },
    "838" => {
      "KeyWord" => "RangeModulatorID",
      "Name" => "Range Modulator ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0346",
      "group" => "300a"
    },
    "840" => {
      "KeyWord" => "RangeModulatorType",
      "Name" => "Range Modulator Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0348",
      "group" => "300a"
    },
    "842" => {
      "KeyWord" => "RangeModulatorDescription",
      "Name" => "Range Modulator Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "034a",
      "group" => "300a"
    },
    "844" => {
      "KeyWord" => "BeamCurrentModulationID",
      "Name" => "Beam Current Modulation ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "034c",
      "group" => "300a"
    },
    "848" => {
      "KeyWord" => "PatientSupportType",
      "Name" => "Patient Support Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0350",
      "group" => "300a"
    },
    "85" => {
      "KeyWord" => "RTPlanRelationship",
      "Name" => "RT Plan Relationship",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0055",
      "group" => "300a"
    },
    "850" => {
      "KeyWord" => "PatientSupportID",
      "Name" => "Patient Support ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0352",
      "group" => "300a"
    },
    "852" => {
      "KeyWord" => "PatientSupportAccessoryCode",
      "Name" => "Patient Support Accessory Code",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0354",
      "group" => "300a"
    },
    "854" => {
      "KeyWord" => "FixationLightAzimuthalAngle",
      "Name" => "Fixation Light Azimuthal Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0356",
      "group" => "300a"
    },
    "856" => {
      "KeyWord" => "FixationLightPolarAngle",
      "Name" => "Fixation Light Polar Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0358",
      "group" => "300a"
    },
    "858" => {
      "KeyWord" => "MetersetRate",
      "Name" => "Meterset Rate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "035a",
      "group" => "300a"
    },
    "864" => {
      "KeyWord" => "RangeShifterSettingsSequence",
      "Name" => "Range Shifter Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0360",
      "group" => "300a"
    },
    "866" => {
      "KeyWord" => "RangeShifterSetting",
      "Name" => "Range Shifter Setting",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0362",
      "group" => "300a"
    },
    "868" => {
      "KeyWord" => "IsocenterToRangeShifterDistance",
      "Name" => "Isocenter to Range Shifter Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0364",
      "group" => "300a"
    },
    "870" => {
      "KeyWord" => "RangeShifterWaterEquivalentThickness",
      "Name" => "Range Shifter Water Equivalent Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0366",
      "group" => "300a"
    },
    "880" => {
      "KeyWord" => "LateralSpreadingDeviceSettingsSequence",
      "Name" => "Lateral Spreading Device Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0370",
      "group" => "300a"
    },
    "882" => {
      "KeyWord" => "LateralSpreadingDeviceSetting",
      "Name" => "Lateral Spreading Device Setting",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0372",
      "group" => "300a"
    },
    "884" => {
      "KeyWord" => "IsocenterToLateralSpreadingDeviceDistance",
      "Name" => "Isocenter to Lateral Spreading Device Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0374",
      "group" => "300a"
    },
    "896" => {
      "KeyWord" => "RangeModulatorSettingsSequence",
      "Name" => "Range Modulator Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0380",
      "group" => "300a"
    },
    "898" => {
      "KeyWord" => "RangeModulatorGatingStartValue",
      "Name" => "Range Modulator Gating Start Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0382",
      "group" => "300a"
    },
    "9" => {
      "KeyWord" => "TreatmentProtocols",
      "Name" => "Treatment Protocols",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0009",
      "group" => "300a"
    },
    "900" => {
      "KeyWord" => "RangeModulatorGatingStopValue",
      "Name" => "Range Modulator Gating Stop Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0384",
      "group" => "300a"
    },
    "902" => {
      "KeyWord" => "RangeModulatorGatingStartWaterEquivalentThickness",
      "Name" => "Range Modulator Gating Start Water Equivalent Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0386",
      "group" => "300a"
    },
    "904" => {
      "KeyWord" => "RangeModulatorGatingStopWaterEquivalentThickness",
      "Name" => "Range Modulator Gating Stop Water Equivalent Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0388",
      "group" => "300a"
    },
    "906" => {
      "KeyWord" => "IsocenterToRangeModulatorDistance",
      "Name" => "Isocenter to Range Modulator Distance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "038a",
      "group" => "300a"
    },
    "912" => {
      "KeyWord" => "ScanSpotTuneID",
      "Name" => "Scan Spot Tune ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0390",
      "group" => "300a"
    },
    "914" => {
      "KeyWord" => "NumberOfScanSpotPositions",
      "Name" => "Number of Scan Spot Positions",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0392",
      "group" => "300a"
    },
    "916" => {
      "KeyWord" => "ScanSpotPositionMap",
      "Name" => "Scan Spot Position Map",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "0394",
      "group" => "300a"
    },
    "918" => {
      "KeyWord" => "ScanSpotMetersetWeights",
      "Name" => "Scan Spot Meterset Weights",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "0396",
      "group" => "300a"
    },
    "920" => {
      "KeyWord" => "ScanningSpotSize",
      "Name" => "Scanning Spot Size",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "0398",
      "group" => "300a"
    },
    "922" => {
      "KeyWord" => "NumberOfPaintings",
      "Name" => "Number of Paintings",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "039a",
      "group" => "300a"
    },
    "928" => {
      "KeyWord" => "IonToleranceTableSequence",
      "Name" => "Ion Tolerance Table Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "03a0",
      "group" => "300a"
    },
    "930" => {
      "KeyWord" => "IonBeamSequence",
      "Name" => "Ion Beam Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "03a2",
      "group" => "300a"
    },
    "932" => {
      "KeyWord" => "IonBeamLimitingDeviceSequence",
      "Name" => "Ion Beam Limiting Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "03a4",
      "group" => "300a"
    },
    "934" => {
      "KeyWord" => "IonBlockSequence",
      "Name" => "Ion Block Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "03a6",
      "group" => "300a"
    },
    "936" => {
      "KeyWord" => "IonControlPointSequence",
      "Name" => "Ion Control Point Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "03a8",
      "group" => "300a"
    },
    "938" => {
      "KeyWord" => "IonWedgeSequence",
      "Name" => "Ion Wedge Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "03aa",
      "group" => "300a"
    },
    "940" => {
      "KeyWord" => "IonWedgePositionSequence",
      "Name" => "Ion Wedge Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "03ac",
      "group" => "300a"
    }
  },
  "12300" => {
    "10" => {
      "KeyWord" => "ReferencedBrachyApplicationSetupSequence",
      "Name" => "Referenced Brachy Application Setup Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000a",
      "group" => "300c"
    },
    "106" => {
      "KeyWord" => "ReferencedPatientSetupNumber",
      "Name" => "Referenced Patient Setup Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "006a",
      "group" => "300c"
    },
    "12" => {
      "KeyWord" => "ReferencedBrachyApplicationSetupNumber",
      "Name" => "Referenced Brachy Application Setup Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "000c",
      "group" => "300c"
    },
    "128" => {
      "KeyWord" => "ReferencedDoseSequence",
      "Name" => "Referenced Dose Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0080",
      "group" => "300c"
    },
    "14" => {
      "KeyWord" => "ReferencedSourceNumber",
      "Name" => "Referenced Source Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "000e",
      "group" => "300c"
    },
    "160" => {
      "KeyWord" => "ReferencedToleranceTableNumber",
      "Name" => "Referenced Tolerance Table Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00a0",
      "group" => "300c"
    },
    "176" => {
      "KeyWord" => "ReferencedBolusSequence",
      "Name" => "Referenced Bolus Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00b0",
      "group" => "300c"
    },
    "192" => {
      "KeyWord" => "ReferencedWedgeNumber",
      "Name" => "Referenced Wedge Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00c0",
      "group" => "300c"
    },
    "2" => {
      "KeyWord" => "ReferencedRTPlanSequence",
      "Name" => "Referenced RT Plan Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0002",
      "group" => "300c"
    },
    "208" => {
      "KeyWord" => "ReferencedCompensatorNumber",
      "Name" => "Referenced Compensator Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00d0",
      "group" => "300c"
    },
    "224" => {
      "KeyWord" => "ReferencedBlockNumber",
      "Name" => "Referenced Block Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00e0",
      "group" => "300c"
    },
    "240" => {
      "KeyWord" => "ReferencedControlPointIndex",
      "Name" => "Referenced Control Point Index",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00f0",
      "group" => "300c"
    },
    "242" => {
      "KeyWord" => "ReferencedControlPointSequence",
      "Name" => "Referenced Control Point Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00f2",
      "group" => "300c"
    },
    "244" => {
      "KeyWord" => "ReferencedStartControlPointIndex",
      "Name" => "Referenced Start Control Point Index",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00f4",
      "group" => "300c"
    },
    "246" => {
      "KeyWord" => "ReferencedStopControlPointIndex",
      "Name" => "Referenced Stop Control Point Index",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00f6",
      "group" => "300c"
    },
    "256" => {
      "KeyWord" => "ReferencedRangeShifterNumber",
      "Name" => "Referenced Range Shifter Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0100",
      "group" => "300c"
    },
    "258" => {
      "KeyWord" => "ReferencedLateralSpreadingDeviceNumber",
      "Name" => "Referenced Lateral Spreading Device Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0102",
      "group" => "300c"
    },
    "260" => {
      "KeyWord" => "ReferencedRangeModulatorNumber",
      "Name" => "Referenced Range Modulator Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0104",
      "group" => "300c"
    },
    "32" => {
      "KeyWord" => "ReferencedFractionGroupSequence",
      "Name" => "Referenced Fraction Group Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0020",
      "group" => "300c"
    },
    "34" => {
      "KeyWord" => "ReferencedFractionGroupNumber",
      "Name" => "Referenced Fraction Group Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0022",
      "group" => "300c"
    },
    "4" => {
      "KeyWord" => "ReferencedBeamSequence",
      "Name" => "Referenced Beam Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0004",
      "group" => "300c"
    },
    "6" => {
      "KeyWord" => "ReferencedBeamNumber",
      "Name" => "Referenced Beam Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0006",
      "group" => "300c"
    },
    "64" => {
      "KeyWord" => "ReferencedVerificationImageSequence",
      "Name" => "Referenced Verification Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0040",
      "group" => "300c"
    },
    "66" => {
      "KeyWord" => "ReferencedReferenceImageSequence",
      "Name" => "Referenced Reference Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0042",
      "group" => "300c"
    },
    "7" => {
      "KeyWord" => "ReferencedReferenceImageNumber",
      "Name" => "Referenced Reference Image Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0007",
      "group" => "300c"
    },
    "8" => {
      "KeyWord" => "StartCumulativeMetersetWeight",
      "Name" => "Start Cumulative Meterset Weight",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0008",
      "group" => "300c"
    },
    "80" => {
      "KeyWord" => "ReferencedDoseReferenceSequence",
      "Name" => "Referenced Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "300c"
    },
    "81" => {
      "KeyWord" => "ReferencedDoseReferenceNumber",
      "Name" => "Referenced Dose Reference Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0051",
      "group" => "300c"
    },
    "85" => {
      "KeyWord" => "BrachyReferencedDoseReferenceSequence",
      "Name" => "Brachy Referenced Dose Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0055",
      "group" => "300c"
    },
    "9" => {
      "KeyWord" => "EndCumulativeMetersetWeight",
      "Name" => "End Cumulative Meterset Weight",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0009",
      "group" => "300c"
    },
    "96" => {
      "KeyWord" => "ReferencedStructureSetSequence",
      "Name" => "Referenced Structure Set Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0060",
      "group" => "300c"
    }
  },
  "12302" => {
    "2" => {
      "KeyWord" => "ApprovalStatus",
      "Name" => "Approval Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0002",
      "group" => "300e"
    },
    "4" => {
      "KeyWord" => "ReviewDate",
      "Name" => "Review Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0004",
      "group" => "300e"
    },
    "5" => {
      "KeyWord" => "ReviewTime",
      "Name" => "Review Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0005",
      "group" => "300e"
    },
    "8" => {
      "KeyWord" => "ReviewerName",
      "Name" => "Reviewer Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "0008",
      "group" => "300e"
    }
  },
  "128" => {
    "1" => {
      "KeyWord" => "SurfaceScanAcquisitionTypeCodeSequence",
      "Name" => "Surface Scan Acquisition Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0001",
      "group" => "0080"
    },
    "16" => {
      "KeyWord" => "UValueData",
      "Name" => "U Value Data",
      "VM" => "1-n",
      "VR" => "OF",
      "ele" => "0010",
      "group" => "0080"
    },
    "17" => {
      "KeyWord" => "VValueData",
      "Name" => "V Value Data",
      "VM" => "1-n",
      "VR" => "OF",
      "ele" => "0011",
      "group" => "0080"
    },
    "18" => {
      "KeyWord" => "ReferencedTextureSequence",
      "Name" => "Referenced Texture Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0012",
      "group" => "0080"
    },
    "19" => {
      "KeyWord" => "ReferencedSurfaceDataSequence",
      "Name" => "Referenced Surface Data Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0013",
      "group" => "0080"
    },
    "2" => {
      "KeyWord" => "SurfaceScanModeCodeSequence",
      "Name" => "Surface Scan Mode Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0002",
      "group" => "0080"
    },
    "3" => {
      "KeyWord" => "RegistrationMethodCodeSequence",
      "Name" => "Registration Method Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0003",
      "group" => "0080"
    },
    "4" => {
      "KeyWord" => "ShotDurationTime",
      "Name" => "Shot Duration Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0004",
      "group" => "0080"
    },
    "5" => {
      "KeyWord" => "ShotOffsetTime",
      "Name" => "Shot Offset Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0005",
      "group" => "0080"
    },
    "6" => {
      "KeyWord" => "SurfacePointPresentationValueData",
      "Name" => "Surface Point Presentation Value Data",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0006",
      "group" => "0080"
    },
    "7" => {
      "KeyWord" => "SurfacePointColorCIELabValueData",
      "Name" => "Surface Point Color CIELab Value Data",
      "VM" => "3-3n",
      "VR" => "US",
      "ele" => "0007",
      "group" => "0080"
    },
    "8" => {
      "KeyWord" => "UVMappingSequence",
      "Name" => "UV Mapping Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0008",
      "group" => "0080"
    },
    "9" => {
      "KeyWord" => "TextureLabel",
      "Name" => "Texture Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0009",
      "group" => "0080"
    }
  },
  "136" => {
    "2308" => {
      "KeyWord" => "TopicTitle",
      "Name" => "Topic Title",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0904",
      "group" => "0088"
    },
    "2310" => {
      "KeyWord" => "TopicSubject",
      "Name" => "Topic Subject",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0906",
      "group" => "0088"
    },
    "2320" => {
      "KeyWord" => "TopicAuthor",
      "Name" => "Topic Author",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0910",
      "group" => "0088"
    },
    "2322" => {
      "KeyWord" => "TopicKeywords",
      "Name" => "Topic Keywords",
      "RET" => "1",
      "VM" => "1-32",
      "VR" => "LO",
      "ele" => "0912",
      "group" => "0088"
    },
    "304" => {
      "KeyWord" => "StorageMediaFileSetID",
      "Name" => "Storage Media File-set ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0130",
      "group" => "0088"
    },
    "320" => {
      "KeyWord" => "StorageMediaFileSetUID",
      "Name" => "Storage Media File-set UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0140",
      "group" => "0088"
    },
    "512" => {
      "KeyWord" => "IconImageSequence",
      "Name" => "Icon Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0200",
      "group" => "0088"
    }
  },
  "16" => {
    "16" => {
      "KeyWord" => "PatientName",
      "Name" => "Patient's Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "0010",
      "group" => "0010"
    },
    "16384" => {
      "KeyWord" => "PatientComments",
      "Name" => "Patient Comments",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "0010"
    },
    "257" => {
      "KeyWord" => "PatientPrimaryLanguageCodeSequence",
      "Name" => "Patient's Primary Language Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0101",
      "group" => "0010"
    },
    "258" => {
      "KeyWord" => "PatientPrimaryLanguageModifierCodeSequence",
      "Name" => "Patient's Primary Language Modifier Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0102",
      "group" => "0010"
    },
    "32" => {
      "KeyWord" => "PatientID",
      "Name" => "Patient ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0020",
      "group" => "0010"
    },
    "33" => {
      "KeyWord" => "IssuerOfPatientID",
      "Name" => "Issuer of Patient ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0021",
      "group" => "0010"
    },
    "34" => {
      "KeyWord" => "TypeOfPatientID",
      "Name" => "Type of Patient ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0022",
      "group" => "0010"
    },
    "36" => {
      "KeyWord" => "IssuerOfPatientIDQualifiersSequence",
      "Name" => "Issuer of Patient ID Qualifiers Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0024",
      "group" => "0010"
    },
    "37937" => {
      "KeyWord" => "ExaminedBodyThickness",
      "Name" => "Examined Body Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9431",
      "group" => "0010"
    },
    "4096" => {
      "KeyWord" => "OtherPatientIDs",
      "Name" => "Other Patient IDs",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1000",
      "group" => "0010"
    },
    "4097" => {
      "KeyWord" => "OtherPatientNames",
      "Name" => "Other Patient Names",
      "VM" => "1-n",
      "VR" => "PN",
      "ele" => "1001",
      "group" => "0010"
    },
    "4098" => {
      "KeyWord" => "OtherPatientIDsSequence",
      "Name" => "Other Patient IDs Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1002",
      "group" => "0010"
    },
    "4101" => {
      "KeyWord" => "PatientBirthName",
      "Name" => "Patient's Birth Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "1005",
      "group" => "0010"
    },
    "4112" => {
      "KeyWord" => "PatientAge",
      "Name" => "Patient's Age",
      "VM" => "1",
      "VR" => "AS",
      "ele" => "1010",
      "group" => "0010"
    },
    "4128" => {
      "KeyWord" => "PatientSize",
      "Name" => "Patient's Size",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1020",
      "group" => "0010"
    },
    "4129" => {
      "KeyWord" => "PatientSizeCodeSequence",
      "Name" => "Patient's Size Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1021",
      "group" => "0010"
    },
    "4144" => {
      "KeyWord" => "PatientWeight",
      "Name" => "Patient's Weight",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1030",
      "group" => "0010"
    },
    "4160" => {
      "KeyWord" => "PatientAddress",
      "Name" => "Patient's Address",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1040",
      "group" => "0010"
    },
    "4176" => {
      "KeyWord" => "InsurancePlanIdentification",
      "Name" => "Insurance Plan Identification",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1050",
      "group" => "0010"
    },
    "4192" => {
      "KeyWord" => "PatientMotherBirthName",
      "Name" => "Patient's Mother's Birth Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "1060",
      "group" => "0010"
    },
    "4224" => {
      "KeyWord" => "MilitaryRank",
      "Name" => "Military Rank",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1080",
      "group" => "0010"
    },
    "4225" => {
      "KeyWord" => "BranchOfService",
      "Name" => "Branch of Service",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1081",
      "group" => "0010"
    },
    "4240" => {
      "KeyWord" => "MedicalRecordLocator",
      "Name" => "Medical Record Locator",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1090",
      "group" => "0010"
    },
    "48" => {
      "KeyWord" => "PatientBirthDate",
      "Name" => "Patient's Birth Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0030",
      "group" => "0010"
    },
    "50" => {
      "KeyWord" => "PatientBirthTime",
      "Name" => "Patient's Birth Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0032",
      "group" => "0010"
    },
    "512" => {
      "KeyWord" => "QualityControlSubject",
      "Name" => "Quality Control Subject",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0200",
      "group" => "0010"
    },
    "513" => {
      "KeyWord" => "QualityControlSubjectTypeCodeSequence",
      "Name" => "Quality Control Subject Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0201",
      "group" => "0010"
    },
    "530" => {
      "KeyWord" => "StrainDescription",
      "Name" => "Strain Description",
      "VM" => "1",
      "VR" => "UC",
      "ele" => "0212",
      "group" => "0010"
    },
    "531" => {
      "KeyWord" => "StrainNomenclature",
      "Name" => "Strain Nomenclature",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0213",
      "group" => "0010"
    },
    "537" => {
      "KeyWord" => "StrainCodeSequence",
      "Name" => "Strain Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0219",
      "group" => "0010"
    },
    "546" => {
      "KeyWord" => "GeneticModificationsDescription",
      "Name" => "Genetic Modifications Description",
      "VM" => "1",
      "VR" => "UC",
      "ele" => "0222",
      "group" => "0010"
    },
    "64" => {
      "KeyWord" => "PatientSex",
      "Name" => "Patient's Sex",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0040",
      "group" => "0010"
    },
    "80" => {
      "KeyWord" => "PatientInsurancePlanCodeSequence",
      "Name" => "Patient's Insurance Plan Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "0010"
    },
    "8192" => {
      "KeyWord" => "MedicalAlerts",
      "Name" => "Medical Alerts",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "2000",
      "group" => "0010"
    },
    "8464" => {
      "KeyWord" => "Allergies",
      "Name" => "Allergies",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "2110",
      "group" => "0010"
    },
    "8528" => {
      "KeyWord" => "CountryOfResidence",
      "Name" => "Country of Residence",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2150",
      "group" => "0010"
    },
    "8530" => {
      "KeyWord" => "RegionOfResidence",
      "Name" => "Region of Residence",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2152",
      "group" => "0010"
    },
    "8532" => {
      "KeyWord" => "PatientTelephoneNumbers",
      "Name" => "Patient's Telephone Numbers",
      "VM" => "1-n",
      "VR" => "SH",
      "ele" => "2154",
      "group" => "0010"
    },
    "8544" => {
      "KeyWord" => "EthnicGroup",
      "Name" => "Ethnic Group",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2160",
      "group" => "0010"
    },
    "8576" => {
      "KeyWord" => "Occupation",
      "Name" => "Occupation",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2180",
      "group" => "0010"
    },
    "8608" => {
      "KeyWord" => "SmokingStatus",
      "Name" => "Smoking Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "21a0",
      "group" => "0010"
    },
    "8624" => {
      "KeyWord" => "AdditionalPatientHistory",
      "Name" => "Additional Patient History",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "21b0",
      "group" => "0010"
    },
    "8640" => {
      "KeyWord" => "PregnancyStatus",
      "Name" => "Pregnancy Status",
      "VM" => "1",
      "VR" => "US",
      "ele" => "21c0",
      "group" => "0010"
    },
    "8656" => {
      "KeyWord" => "LastMenstrualDate",
      "Name" => "Last Menstrual Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "21d0",
      "group" => "0010"
    },
    "8688" => {
      "KeyWord" => "PatientReligiousPreference",
      "Name" => "Patient's Religious Preference",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "21f0",
      "group" => "0010"
    },
    "8705" => {
      "KeyWord" => "PatientSpeciesDescription",
      "Name" => "Patient Species Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2201",
      "group" => "0010"
    },
    "8706" => {
      "KeyWord" => "PatientSpeciesCodeSequence",
      "Name" => "Patient Species Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2202",
      "group" => "0010"
    },
    "8707" => {
      "KeyWord" => "PatientSexNeutered",
      "Name" => "Patient's Sex Neutered",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2203",
      "group" => "0010"
    },
    "8720" => {
      "KeyWord" => "AnatomicalOrientationType",
      "Name" => "Anatomical Orientation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2210",
      "group" => "0010"
    },
    "8850" => {
      "KeyWord" => "PatientBreedDescription",
      "Name" => "Patient Breed Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2292",
      "group" => "0010"
    },
    "8851" => {
      "KeyWord" => "PatientBreedCodeSequence",
      "Name" => "Patient Breed Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2293",
      "group" => "0010"
    },
    "8852" => {
      "KeyWord" => "BreedRegistrationSequence",
      "Name" => "Breed Registration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2294",
      "group" => "0010"
    },
    "8853" => {
      "KeyWord" => "BreedRegistrationNumber",
      "Name" => "Breed Registration Number",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2295",
      "group" => "0010"
    },
    "8854" => {
      "KeyWord" => "BreedRegistryCodeSequence",
      "Name" => "Breed Registry Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2296",
      "group" => "0010"
    },
    "8855" => {
      "KeyWord" => "ResponsiblePerson",
      "Name" => "Responsible Person",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "2297",
      "group" => "0010"
    },
    "8856" => {
      "KeyWord" => "ResponsiblePersonRole",
      "Name" => "Responsible Person Role",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2298",
      "group" => "0010"
    },
    "8857" => {
      "KeyWord" => "ResponsibleOrganization",
      "Name" => "Responsible Organization",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2299",
      "group" => "0010"
    }
  },
  "16384" => {
    "16" => {
      "KeyWord" => "Arbitrary",
      "Name" => "Arbitrary",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0010",
      "group" => "4000"
    },
    "16384" => {
      "KeyWord" => "TextComments",
      "Name" => "Text Comments",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "4000"
    }
  },
  "16392" => {
    "16384" => {
      "KeyWord" => "ResultsComments",
      "Name" => "Results Comments",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "4000",
      "group" => "4008"
    },
    "255" => {
      "KeyWord" => "ReportProductionStatusTrial",
      "Name" => "Report Production Status (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00ff",
      "group" => "4008"
    },
    "256" => {
      "KeyWord" => "InterpretationRecordedDate",
      "Name" => "Interpretation Recorded Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0100",
      "group" => "4008"
    },
    "257" => {
      "KeyWord" => "InterpretationRecordedTime",
      "Name" => "Interpretation Recorded Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0101",
      "group" => "4008"
    },
    "258" => {
      "KeyWord" => "InterpretationRecorder",
      "Name" => "Interpretation Recorder",
      "RET" => "1",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "0102",
      "group" => "4008"
    },
    "259" => {
      "KeyWord" => "ReferenceToRecordedSound",
      "Name" => "Reference to Recorded Sound",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0103",
      "group" => "4008"
    },
    "264" => {
      "KeyWord" => "InterpretationTranscriptionDate",
      "Name" => "Interpretation Transcription Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0108",
      "group" => "4008"
    },
    "265" => {
      "KeyWord" => "InterpretationTranscriptionTime",
      "Name" => "Interpretation Transcription Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0109",
      "group" => "4008"
    },
    "266" => {
      "KeyWord" => "InterpretationTranscriber",
      "Name" => "Interpretation Transcriber",
      "RET" => "1",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "010a",
      "group" => "4008"
    },
    "267" => {
      "KeyWord" => "InterpretationText",
      "Name" => "Interpretation Text",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "010b",
      "group" => "4008"
    },
    "268" => {
      "KeyWord" => "InterpretationAuthor",
      "Name" => "Interpretation Author",
      "RET" => "1",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "010c",
      "group" => "4008"
    },
    "273" => {
      "KeyWord" => "InterpretationApproverSequence",
      "Name" => "Interpretation Approver Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0111",
      "group" => "4008"
    },
    "274" => {
      "KeyWord" => "InterpretationApprovalDate",
      "Name" => "Interpretation Approval Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0112",
      "group" => "4008"
    },
    "275" => {
      "KeyWord" => "InterpretationApprovalTime",
      "Name" => "Interpretation Approval Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0113",
      "group" => "4008"
    },
    "276" => {
      "KeyWord" => "PhysicianApprovingInterpretation",
      "Name" => "Physician Approving Interpretation",
      "RET" => "1",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "0114",
      "group" => "4008"
    },
    "277" => {
      "KeyWord" => "InterpretationDiagnosisDescription",
      "Name" => "Interpretation Diagnosis Description",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0115",
      "group" => "4008"
    },
    "279" => {
      "KeyWord" => "InterpretationDiagnosisCodeSequence",
      "Name" => "Interpretation Diagnosis Code Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0117",
      "group" => "4008"
    },
    "280" => {
      "KeyWord" => "ResultsDistributionListSequence",
      "Name" => "Results Distribution List Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0118",
      "group" => "4008"
    },
    "281" => {
      "KeyWord" => "DistributionName",
      "Name" => "Distribution Name",
      "RET" => "1",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "0119",
      "group" => "4008"
    },
    "282" => {
      "KeyWord" => "DistributionAddress",
      "Name" => "Distribution Address",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "011a",
      "group" => "4008"
    },
    "512" => {
      "KeyWord" => "InterpretationID",
      "Name" => "Interpretation ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0200",
      "group" => "4008"
    },
    "514" => {
      "KeyWord" => "InterpretationIDIssuer",
      "Name" => "Interpretation ID Issuer",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0202",
      "group" => "4008"
    },
    "528" => {
      "KeyWord" => "InterpretationTypeID",
      "Name" => "Interpretation Type ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0210",
      "group" => "4008"
    },
    "530" => {
      "KeyWord" => "InterpretationStatusID",
      "Name" => "Interpretation Status ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0212",
      "group" => "4008"
    },
    "64" => {
      "KeyWord" => "ResultsID",
      "Name" => "Results ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0040",
      "group" => "4008"
    },
    "66" => {
      "KeyWord" => "ResultsIDIssuer",
      "Name" => "Results ID Issuer",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0042",
      "group" => "4008"
    },
    "768" => {
      "KeyWord" => "Impressions",
      "Name" => "Impressions",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0300",
      "group" => "4008"
    },
    "80" => {
      "KeyWord" => "ReferencedInterpretationSequence",
      "Name" => "Referenced Interpretation Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "4008"
    }
  },
  "16400" => {
    "1" => {
      "KeyWord" => "LowEnergyDetectors",
      "Name" => "Low Energy Detectors",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "0001",
      "group" => "4010"
    },
    "2" => {
      "KeyWord" => "HighEnergyDetectors",
      "Name" => "High Energy Detectors",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "0002",
      "group" => "4010"
    },
    "4" => {
      "KeyWord" => "DetectorGeometrySequence",
      "Name" => "Detector Geometry Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "0004",
      "group" => "4010"
    },
    "4097" => {
      "KeyWord" => "ThreatROIVoxelSequence",
      "Name" => "Threat ROI Voxel Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1001",
      "group" => "4010"
    },
    "4100" => {
      "KeyWord" => "ThreatROIBase",
      "Name" => "Threat ROI Base",
      "VM" => "3",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1004",
      "group" => "4010"
    },
    "4101" => {
      "KeyWord" => "ThreatROIExtents",
      "Name" => "Threat ROI Extents",
      "VM" => "3",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1005",
      "group" => "4010"
    },
    "4102" => {
      "KeyWord" => "ThreatROIBitmap",
      "Name" => "Threat ROI Bitmap",
      "VM" => "1",
      "VR" => "OB",
      "comment" => "DICOS",
      "ele" => "1006",
      "group" => "4010"
    },
    "4103" => {
      "KeyWord" => "RouteSegmentID",
      "Name" => "Route Segment ID",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "1007",
      "group" => "4010"
    },
    "4104" => {
      "KeyWord" => "GantryType",
      "Name" => "Gantry Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1008",
      "group" => "4010"
    },
    "4105" => {
      "KeyWord" => "OOIOwnerType",
      "Name" => "OOI Owner Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1009",
      "group" => "4010"
    },
    "4106" => {
      "KeyWord" => "RouteSegmentSequence",
      "Name" => "Route Segment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "100a",
      "group" => "4010"
    },
    "4112" => {
      "KeyWord" => "PotentialThreatObjectID",
      "Name" => "Potential Threat Object ID",
      "VM" => "1",
      "VR" => "US",
      "comment" => "DICOS",
      "ele" => "1010",
      "group" => "4010"
    },
    "4113" => {
      "KeyWord" => "ThreatSequence",
      "Name" => "Threat Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1011",
      "group" => "4010"
    },
    "4114" => {
      "KeyWord" => "ThreatCategory",
      "Name" => "Threat Category",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1012",
      "group" => "4010"
    },
    "4115" => {
      "KeyWord" => "ThreatCategoryDescription",
      "Name" => "Threat Category Description",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICOS",
      "ele" => "1013",
      "group" => "4010"
    },
    "4116" => {
      "KeyWord" => "ATDAbilityAssessment",
      "Name" => "ATD Ability Assessment",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1014",
      "group" => "4010"
    },
    "4117" => {
      "KeyWord" => "ATDAssessmentFlag",
      "Name" => "ATD Assessment Flag",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1015",
      "group" => "4010"
    },
    "4118" => {
      "KeyWord" => "ATDAssessmentProbability",
      "Name" => "ATD Assessment Probability",
      "VM" => "1",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1016",
      "group" => "4010"
    },
    "4119" => {
      "KeyWord" => "Mass",
      "Name" => "Mass",
      "VM" => "1",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1017",
      "group" => "4010"
    },
    "4120" => {
      "KeyWord" => "Density",
      "Name" => "Density",
      "VM" => "1",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1018",
      "group" => "4010"
    },
    "4121" => {
      "KeyWord" => "ZEffective",
      "Name" => "Z Effective",
      "VM" => "1",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1019",
      "group" => "4010"
    },
    "4122" => {
      "KeyWord" => "BoardingPassID",
      "Name" => "Boarding Pass ID",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "101a",
      "group" => "4010"
    },
    "4123" => {
      "KeyWord" => "CenterOfMass",
      "Name" => "Center of Mass",
      "VM" => "3",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "101b",
      "group" => "4010"
    },
    "4124" => {
      "KeyWord" => "CenterOfPTO",
      "Name" => "Center of PTO",
      "VM" => "3",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "101c",
      "group" => "4010"
    },
    "4125" => {
      "KeyWord" => "BoundingPolygon",
      "Name" => "Bounding Polygon",
      "VM" => "6-n",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "101d",
      "group" => "4010"
    },
    "4126" => {
      "KeyWord" => "RouteSegmentStartLocationID",
      "Name" => "Route Segment Start Location ID",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "101e",
      "group" => "4010"
    },
    "4127" => {
      "KeyWord" => "RouteSegmentEndLocationID",
      "Name" => "Route Segment End Location ID",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "101f",
      "group" => "4010"
    },
    "4128" => {
      "KeyWord" => "RouteSegmentLocationIDType",
      "Name" => "Route Segment Location ID Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1020",
      "group" => "4010"
    },
    "4129" => {
      "KeyWord" => "AbortReason",
      "Name" => "Abort Reason",
      "VM" => "1-n",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1021",
      "group" => "4010"
    },
    "4131" => {
      "KeyWord" => "VolumeOfPTO",
      "Name" => "Volume of PTO",
      "VM" => "1",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1023",
      "group" => "4010"
    },
    "4132" => {
      "KeyWord" => "AbortFlag",
      "Name" => "Abort Flag",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1024",
      "group" => "4010"
    },
    "4133" => {
      "KeyWord" => "RouteSegmentStartTime",
      "Name" => "Route Segment Start Time",
      "VM" => "1",
      "VR" => "DT",
      "comment" => "DICOS",
      "ele" => "1025",
      "group" => "4010"
    },
    "4134" => {
      "KeyWord" => "RouteSegmentEndTime",
      "Name" => "Route Segment End Time",
      "VM" => "1",
      "VR" => "DT",
      "comment" => "DICOS",
      "ele" => "1026",
      "group" => "4010"
    },
    "4135" => {
      "KeyWord" => "TDRType",
      "Name" => "TDR Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1027",
      "group" => "4010"
    },
    "4136" => {
      "KeyWord" => "InternationalRouteSegment",
      "Name" => "International Route Segment",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1028",
      "group" => "4010"
    },
    "4137" => {
      "KeyWord" => "ThreatDetectionAlgorithmandVersion",
      "Name" => "Threat Detection Algorithm and Version",
      "VM" => "1-n",
      "VR" => "LO",
      "comment" => "DICOS",
      "ele" => "1029",
      "group" => "4010"
    },
    "4138" => {
      "KeyWord" => "AssignedLocation",
      "Name" => "Assigned Location",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "102a",
      "group" => "4010"
    },
    "4139" => {
      "KeyWord" => "AlarmDecisionTime",
      "Name" => "Alarm Decision Time",
      "VM" => "1",
      "VR" => "DT",
      "comment" => "DICOS",
      "ele" => "102b",
      "group" => "4010"
    },
    "4145" => {
      "KeyWord" => "AlarmDecision",
      "Name" => "Alarm Decision",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1031",
      "group" => "4010"
    },
    "4147" => {
      "KeyWord" => "NumberOfTotalObjects",
      "Name" => "Number of Total Objects",
      "VM" => "1",
      "VR" => "US",
      "comment" => "DICOS",
      "ele" => "1033",
      "group" => "4010"
    },
    "4148" => {
      "KeyWord" => "NumberOfAlarmObjects",
      "Name" => "Number of Alarm Objects",
      "VM" => "1",
      "VR" => "US",
      "comment" => "DICOS",
      "ele" => "1034",
      "group" => "4010"
    },
    "4151" => {
      "KeyWord" => "PTORepresentationSequence",
      "Name" => "PTO Representation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1037",
      "group" => "4010"
    },
    "4152" => {
      "KeyWord" => "ATDAssessmentSequence",
      "Name" => "ATD Assessment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1038",
      "group" => "4010"
    },
    "4153" => {
      "KeyWord" => "TIPType",
      "Name" => "TIP Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1039",
      "group" => "4010"
    },
    "4154" => {
      "KeyWord" => "DICOSVersion",
      "Name" => "DICOS Version",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "103a",
      "group" => "4010"
    },
    "4161" => {
      "KeyWord" => "OOIOwnerCreationTime",
      "Name" => "OOI Owner Creation Time",
      "VM" => "1",
      "VR" => "DT",
      "comment" => "DICOS",
      "ele" => "1041",
      "group" => "4010"
    },
    "4162" => {
      "KeyWord" => "OOIType",
      "Name" => "OOI Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1042",
      "group" => "4010"
    },
    "4163" => {
      "KeyWord" => "OOISize",
      "Name" => "OOI Size",
      "VM" => "3",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1043",
      "group" => "4010"
    },
    "4164" => {
      "KeyWord" => "AcquisitionStatus",
      "Name" => "Acquisition Status",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1044",
      "group" => "4010"
    },
    "4165" => {
      "KeyWord" => "BasisMaterialsCodeSequence",
      "Name" => "Basis Materials Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1045",
      "group" => "4010"
    },
    "4166" => {
      "KeyWord" => "PhantomType",
      "Name" => "Phantom Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1046",
      "group" => "4010"
    },
    "4167" => {
      "KeyWord" => "OOIOwnerSequence",
      "Name" => "OOI Owner Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1047",
      "group" => "4010"
    },
    "4168" => {
      "KeyWord" => "ScanType",
      "Name" => "Scan Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1048",
      "group" => "4010"
    },
    "4177" => {
      "KeyWord" => "ItineraryID",
      "Name" => "Itinerary ID",
      "VM" => "1",
      "VR" => "LO",
      "comment" => "DICOS",
      "ele" => "1051",
      "group" => "4010"
    },
    "4178" => {
      "KeyWord" => "ItineraryIDType",
      "Name" => "Itinerary ID Type",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "1052",
      "group" => "4010"
    },
    "4179" => {
      "KeyWord" => "ItineraryIDAssigningAuthority",
      "Name" => "Itinerary ID Assigning Authority",
      "VM" => "1",
      "VR" => "LO",
      "comment" => "DICOS",
      "ele" => "1053",
      "group" => "4010"
    },
    "4180" => {
      "KeyWord" => "RouteID",
      "Name" => "Route ID",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "1054",
      "group" => "4010"
    },
    "4181" => {
      "KeyWord" => "RouteIDAssigningAuthority",
      "Name" => "Route ID Assigning Authority",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "1055",
      "group" => "4010"
    },
    "4182" => {
      "KeyWord" => "InboundArrivalType",
      "Name" => "Inbound Arrival Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1056",
      "group" => "4010"
    },
    "4184" => {
      "KeyWord" => "CarrierID",
      "Name" => "Carrier ID",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICOS",
      "ele" => "1058",
      "group" => "4010"
    },
    "4185" => {
      "KeyWord" => "CarrierIDAssigningAuthority",
      "Name" => "Carrier ID Assigning Authority",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1059",
      "group" => "4010"
    },
    "4192" => {
      "KeyWord" => "SourceOrientation",
      "Name" => "Source Orientation",
      "VM" => "3",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1060",
      "group" => "4010"
    },
    "4193" => {
      "KeyWord" => "SourcePosition",
      "Name" => "Source Position",
      "VM" => "3",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1061",
      "group" => "4010"
    },
    "4194" => {
      "KeyWord" => "BeltHeight",
      "Name" => "Belt Height",
      "VM" => "1",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1062",
      "group" => "4010"
    },
    "4196" => {
      "KeyWord" => "AlgorithmRoutingCodeSequence",
      "Name" => "Algorithm Routing Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1064",
      "group" => "4010"
    },
    "4199" => {
      "KeyWord" => "TransportClassification",
      "Name" => "Transport Classification",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1067",
      "group" => "4010"
    },
    "4200" => {
      "KeyWord" => "OOITypeDescriptor",
      "Name" => "OOI Type Descriptor",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICOS",
      "ele" => "1068",
      "group" => "4010"
    },
    "4201" => {
      "KeyWord" => "TotalProcessingTime",
      "Name" => "Total Processing Time",
      "VM" => "1",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "1069",
      "group" => "4010"
    },
    "4204" => {
      "KeyWord" => "DetectorCalibrationData",
      "Name" => "Detector Calibration Data",
      "VM" => "1",
      "VR" => "OB",
      "comment" => "DICOS",
      "ele" => "106c",
      "group" => "4010"
    },
    "4205" => {
      "KeyWord" => "AdditionalScreeningPerformed",
      "Name" => "Additional Screening Performed",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "106d",
      "group" => "4010"
    },
    "4206" => {
      "KeyWord" => "AdditionalInspectionSelectionCriteria",
      "Name" => "Additional Inspection Selection Criteria",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "106e",
      "group" => "4010"
    },
    "4207" => {
      "KeyWord" => "AdditionalInspectionMethodSequence",
      "Name" => "Additional Inspection Method Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "106f",
      "group" => "4010"
    },
    "4208" => {
      "KeyWord" => "AITDeviceType",
      "Name" => "AIT Device Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "1070",
      "group" => "4010"
    },
    "4209" => {
      "KeyWord" => "QRMeasurementsSequence",
      "Name" => "QR Measurements Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1071",
      "group" => "4010"
    },
    "4210" => {
      "KeyWord" => "TargetMaterialSequence",
      "Name" => "Target Material Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1072",
      "group" => "4010"
    },
    "4211" => {
      "KeyWord" => "SNRThreshold",
      "Name" => "SNR Threshold",
      "VM" => "1",
      "VR" => "FD",
      "comment" => "DICOS",
      "ele" => "1073",
      "group" => "4010"
    },
    "4213" => {
      "KeyWord" => "ImageScaleRepresentation",
      "Name" => "Image Scale Representation",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICOS",
      "ele" => "1075",
      "group" => "4010"
    },
    "4214" => {
      "KeyWord" => "ReferencedPTOSequence",
      "Name" => "Referenced PTO Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1076",
      "group" => "4010"
    },
    "4215" => {
      "KeyWord" => "ReferencedTDRInstanceSequence",
      "Name" => "Referenced TDR Instance Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1077",
      "group" => "4010"
    },
    "4216" => {
      "KeyWord" => "PTOLocationDescription",
      "Name" => "PTO Location Description",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICOS",
      "ele" => "1078",
      "group" => "4010"
    },
    "4217" => {
      "KeyWord" => "AnomalyLocatorIndicatorSequence",
      "Name" => "Anomaly Locator Indicator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "1079",
      "group" => "4010"
    },
    "4218" => {
      "KeyWord" => "AnomalyLocatorIndicator",
      "Name" => "Anomaly Locator Indicator",
      "VM" => "3",
      "VR" => "FL",
      "comment" => "DICOS",
      "ele" => "107a",
      "group" => "4010"
    },
    "4219" => {
      "KeyWord" => "PTORegionSequence",
      "Name" => "PTO Region Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "107b",
      "group" => "4010"
    },
    "4220" => {
      "KeyWord" => "InspectionSelectionCriteria",
      "Name" => "Inspection Selection Criteria",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICOS",
      "ele" => "107c",
      "group" => "4010"
    },
    "4221" => {
      "KeyWord" => "SecondaryInspectionMethodSequence",
      "Name" => "Secondary Inspection Method Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICOS",
      "ele" => "107d",
      "group" => "4010"
    },
    "4222" => {
      "KeyWord" => "PRCSToRCSOrientation",
      "Name" => "PRCS to RCS Orientation",
      "VM" => "6",
      "VR" => "DS",
      "comment" => "DICOS",
      "ele" => "107e",
      "group" => "4010"
    }
  },
  "18" => {
    "100" => {
      "KeyWord" => "DeidentificationMethodCodeSequence",
      "Name" => "De-identification Method Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0064",
      "group" => "0012"
    },
    "113" => {
      "KeyWord" => "ClinicalTrialSeriesID",
      "Name" => "Clinical Trial Series ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0071",
      "group" => "0012"
    },
    "114" => {
      "KeyWord" => "ClinicalTrialSeriesDescription",
      "Name" => "Clinical Trial Series Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0072",
      "group" => "0012"
    },
    "129" => {
      "KeyWord" => "ClinicalTrialProtocolEthicsCommitteeName",
      "Name" => "Clinical Trial Protocol Ethics Committee Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0081",
      "group" => "0012"
    },
    "130" => {
      "KeyWord" => "ClinicalTrialProtocolEthicsCommitteeApprovalNumber",
      "Name" => "Clinical Trial Protocol Ethics Committee Approval Number",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0082",
      "group" => "0012"
    },
    "131" => {
      "KeyWord" => "ConsentForClinicalTrialUseSequence",
      "Name" => "Consent for Clinical Trial Use Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0083",
      "group" => "0012"
    },
    "132" => {
      "KeyWord" => "DistributionType",
      "Name" => "Distribution Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0084",
      "group" => "0012"
    },
    "133" => {
      "KeyWord" => "ConsentForDistributionFlag",
      "Name" => "Consent for Distribution Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0085",
      "group" => "0012"
    },
    "16" => {
      "KeyWord" => "ClinicalTrialSponsorName",
      "Name" => "Clinical Trial Sponsor Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0010",
      "group" => "0012"
    },
    "32" => {
      "KeyWord" => "ClinicalTrialProtocolID",
      "Name" => "Clinical Trial Protocol ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0020",
      "group" => "0012"
    },
    "33" => {
      "KeyWord" => "ClinicalTrialProtocolName",
      "Name" => "Clinical Trial Protocol Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0021",
      "group" => "0012"
    },
    "48" => {
      "KeyWord" => "ClinicalTrialSiteID",
      "Name" => "Clinical Trial Site ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0030",
      "group" => "0012"
    },
    "49" => {
      "KeyWord" => "ClinicalTrialSiteName",
      "Name" => "Clinical Trial Site Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0031",
      "group" => "0012"
    },
    "64" => {
      "KeyWord" => "ClinicalTrialSubjectID",
      "Name" => "Clinical Trial Subject ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0040",
      "group" => "0012"
    },
    "66" => {
      "KeyWord" => "ClinicalTrialSubjectReadingID",
      "Name" => "Clinical Trial Subject Reading ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0042",
      "group" => "0012"
    },
    "80" => {
      "KeyWord" => "ClinicalTrialTimePointID",
      "Name" => "Clinical Trial Time Point ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0050",
      "group" => "0012"
    },
    "81" => {
      "KeyWord" => "ClinicalTrialTimePointDescription",
      "Name" => "Clinical Trial Time Point Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0051",
      "group" => "0012"
    },
    "82" => {
      "KeyWord" => "LongitudinalTemporalOffsetFromEvent",
      "Name" => "Longitudinal Temporal Offset From Event",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0052",
      "group" => "0012"
    },
    "83" => {
      "KeyWord" => "Longitudinal Temporal Event Type",
      "Name" => "Longitudinal Temporal Event Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0053",
      "group" => "0012"
    },
    "96" => {
      "KeyWord" => "ClinicalTrialCoordinatingCenterName",
      "Name" => "Clinical Trial Coordinating Center Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0060",
      "group" => "0012"
    },
    "98" => {
      "KeyWord" => "PatientIdentityRemoved",
      "Name" => "Patient Identity Removed",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0062",
      "group" => "0012"
    },
    "99" => {
      "KeyWord" => "DeidentificationMethod",
      "Name" => "De-identification Method",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0063",
      "group" => "0012"
    }
  },
  "2" => {
    "0" => {
      "KeyWord" => "FileMetaInformationGroupLength",
      "Name" => "File Meta Information Group Length",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0000",
      "group" => "0002"
    },
    "1" => {
      "KeyWord" => "FileMetaInformationVersion",
      "Name" => "File Meta Information Version",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0001",
      "group" => "0002"
    },
    "16" => {
      "KeyWord" => "TransferSyntaxUID",
      "Name" => "Transfer Syntax UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0010",
      "group" => "0002"
    },
    "18" => {
      "KeyWord" => "ImplementationClassUID",
      "Name" => "Implementation Class UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0012",
      "group" => "0002"
    },
    "19" => {
      "KeyWord" => "ImplementationVersionName",
      "Name" => "Implementation Version Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0013",
      "group" => "0002"
    },
    "2" => {
      "KeyWord" => "MediaStorageSOPClassUID",
      "Name" => "Media Storage SOP Class UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0002",
      "group" => "0002"
    },
    "22" => {
      "KeyWord" => "SourceApplicationEntityTitle",
      "Name" => "Source Application Entity Title",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "0016",
      "group" => "0002"
    },
    "256" => {
      "KeyWord" => "PrivateInformationCreatorUID",
      "Name" => "Private Information Creator UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0100",
      "group" => "0002"
    },
    "258" => {
      "KeyWord" => "PrivateInformation",
      "Name" => "Private Information",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0102",
      "group" => "0002"
    },
    "3" => {
      "KeyWord" => "MediaStorageSOPInstanceUID",
      "Name" => "Media Storage SOP Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0003",
      "group" => "0002"
    }
  },
  "20" => {
    "12305" => {
      "KeyWord" => "InternalDetectorFrameTime",
      "Name" => "Internal Detector Frame Time",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3011",
      "group" => "0014"
    },
    "12306" => {
      "KeyWord" => "NumberOfFramesIntegrated",
      "Name" => "Number of Frames Integrated",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3012",
      "group" => "0014"
    },
    "12320" => {
      "KeyWord" => "DetectorTemperatureSequence",
      "Name" => "Detector Temperature Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "3020",
      "group" => "0014"
    },
    "12322" => {
      "KeyWord" => "SensorName",
      "Name" => "Sensor Name",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "3022",
      "group" => "0014"
    },
    "12324" => {
      "KeyWord" => "HorizontalOffsetOfSensor",
      "Name" => "Horizontal Offset of Sensor",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3024",
      "group" => "0014"
    },
    "12326" => {
      "KeyWord" => "VerticalOffsetOfSensor",
      "Name" => "Vertical Offset of Sensor",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3026",
      "group" => "0014"
    },
    "12328" => {
      "KeyWord" => "SensorTemperature",
      "Name" => "Sensor Temperature",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3028",
      "group" => "0014"
    },
    "12352" => {
      "KeyWord" => "DarkCurrentSequence",
      "Name" => "Dark Current Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "3040",
      "group" => "0014"
    },
    "12368" => {
      "KeyWord" => "DarkCurrentCounts",
      "Name" => "Dark Current Counts",
      "VM" => "1",
      "VR" => "OT",
      "comment" => "DICONDE",
      "ele" => "3050",
      "group" => "0014"
    },
    "12384" => {
      "KeyWord" => "GainCorrectionReferenceSequence",
      "Name" => "Gain Correction Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "3060",
      "group" => "0014"
    },
    "12400" => {
      "KeyWord" => "AirCounts",
      "Name" => "Air Counts",
      "VM" => "1",
      "VR" => "OT",
      "comment" => "DICONDE",
      "ele" => "3070",
      "group" => "0014"
    },
    "12401" => {
      "KeyWord" => "KVUsedInGainCalibration",
      "Name" => "KV Used in Gain Calibration",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3071",
      "group" => "0014"
    },
    "12402" => {
      "KeyWord" => "MAUsedInGainCalibration",
      "Name" => "MA Used in Gain Calibration",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3072",
      "group" => "0014"
    },
    "12403" => {
      "KeyWord" => "NumberOfFramesUsedForIntegration",
      "Name" => "Number of Frames Used for Integration",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3073",
      "group" => "0014"
    },
    "12404" => {
      "KeyWord" => "FilterMaterialUsedInGainCalibration",
      "Name" => "Filter Material Used in Gain Calibration",
      "VM" => "1",
      "VR" => "LO",
      "comment" => "DICONDE",
      "ele" => "3074",
      "group" => "0014"
    },
    "12405" => {
      "KeyWord" => "FilterThicknessUsedInGainCalibration",
      "Name" => "Filter Thickness Used in Gain Calibration",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "3075",
      "group" => "0014"
    },
    "12406" => {
      "KeyWord" => "DateOfGainCalibration",
      "Name" => "Date of Gain Calibration",
      "VM" => "1",
      "VR" => "DA",
      "comment" => "DICONDE",
      "ele" => "3076",
      "group" => "0014"
    },
    "12407" => {
      "KeyWord" => "TimeOfGainCalibration",
      "Name" => "Time of Gain Calibration",
      "VM" => "1",
      "VR" => "TM",
      "comment" => "DICONDE",
      "ele" => "3077",
      "group" => "0014"
    },
    "12416" => {
      "KeyWord" => "BadPixelImage",
      "Name" => "Bad Pixel Image",
      "VM" => "1",
      "VR" => "OB",
      "comment" => "DICONDE",
      "ele" => "3080",
      "group" => "0014"
    },
    "12441" => {
      "KeyWord" => "CalibrationNotes",
      "Name" => "Calibration Notes",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICONDE",
      "ele" => "3099",
      "group" => "0014"
    },
    "16386" => {
      "KeyWord" => "PulserEquipmentSequence",
      "Name" => "Pulser Equipment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4002",
      "group" => "0014"
    },
    "16388" => {
      "KeyWord" => "PulserType",
      "Name" => "Pulser Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "4004",
      "group" => "0014"
    },
    "16390" => {
      "KeyWord" => "PulserNotes",
      "Name" => "Pulser Notes",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICONDE",
      "ele" => "4006",
      "group" => "0014"
    },
    "16392" => {
      "KeyWord" => "ReceiverEquipmentSequence",
      "Name" => "Receiver Equipment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4008",
      "group" => "0014"
    },
    "16394" => {
      "KeyWord" => "AmplifierType",
      "Name" => "Amplifier Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "400a",
      "group" => "0014"
    },
    "16396" => {
      "KeyWord" => "ReceiverNotes",
      "Name" => "Receiver Notes",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICONDE",
      "ele" => "400c",
      "group" => "0014"
    },
    "16398" => {
      "KeyWord" => "PreAmplifierEquipmentSequence",
      "Name" => "Pre-Amplifier Equipment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "400e",
      "group" => "0014"
    },
    "16399" => {
      "KeyWord" => "PreAmplifierNotes",
      "Name" => "Pre-Amplifier Notes",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICONDE",
      "ele" => "400f",
      "group" => "0014"
    },
    "16400" => {
      "KeyWord" => "TransmitTransducerSequence",
      "Name" => "Transmit Transducer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4010",
      "group" => "0014"
    },
    "16401" => {
      "KeyWord" => "ReceiveTransducerSequence",
      "Name" => "Receive Transducer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4011",
      "group" => "0014"
    },
    "16402" => {
      "KeyWord" => "NumberOfElements",
      "Name" => "Number of Elements",
      "VM" => "1",
      "VR" => "US",
      "comment" => "DICONDE",
      "ele" => "4012",
      "group" => "0014"
    },
    "16403" => {
      "KeyWord" => "ElementShape",
      "Name" => "Element Shape",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "4013",
      "group" => "0014"
    },
    "16404" => {
      "KeyWord" => "ElementDimensionA",
      "Name" => "Element Dimension A",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4014",
      "group" => "0014"
    },
    "16405" => {
      "KeyWord" => "ElementDimensionB",
      "Name" => "Element Dimension B",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4015",
      "group" => "0014"
    },
    "16406" => {
      "KeyWord" => "ElementPitchA",
      "Name" => "Element Pitch A",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4016",
      "group" => "0014"
    },
    "16407" => {
      "KeyWord" => "MeasuredBeamDimensionA",
      "Name" => "Measured Beam Dimension A",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4017",
      "group" => "0014"
    },
    "16408" => {
      "KeyWord" => "MeasuredBeamDimensionB",
      "Name" => "Measured Beam Dimension B",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4018",
      "group" => "0014"
    },
    "16409" => {
      "KeyWord" => "LocationOfMeasuredBeamDiameter",
      "Name" => "Location of Measured Beam Diameter",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4019",
      "group" => "0014"
    },
    "16410" => {
      "KeyWord" => "NominalFrequency",
      "Name" => "Nominal Frequency",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "401a",
      "group" => "0014"
    },
    "16411" => {
      "KeyWord" => "MeasuredCenterFrequency",
      "Name" => "Measured Center Frequency",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "401b",
      "group" => "0014"
    },
    "16412" => {
      "KeyWord" => "MeasuredBandwidth",
      "Name" => "Measured Bandwidth",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "401c",
      "group" => "0014"
    },
    "16413" => {
      "KeyWord" => "ElementPitchB",
      "Name" => "Element Pitch B",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "401d",
      "group" => "0014"
    },
    "16416" => {
      "KeyWord" => "PulserSettingsSequence",
      "Name" => "Pulser Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4020",
      "group" => "0014"
    },
    "16418" => {
      "KeyWord" => "PulseWidth",
      "Name" => "Pulse Width",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4022",
      "group" => "0014"
    },
    "16420" => {
      "KeyWord" => "ExcitationFrequency",
      "Name" => "Excitation Frequency",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4024",
      "group" => "0014"
    },
    "16422" => {
      "KeyWord" => "ModulationType",
      "Name" => "Modulation Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "4026",
      "group" => "0014"
    },
    "16424" => {
      "KeyWord" => "Damping",
      "Name" => "Damping",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4028",
      "group" => "0014"
    },
    "16432" => {
      "KeyWord" => "ReceiverSettingsSequence",
      "Name" => "Receiver Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4030",
      "group" => "0014"
    },
    "16433" => {
      "KeyWord" => "AcquiredSoundpathLength",
      "Name" => "Acquired Soundpath Length",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4031",
      "group" => "0014"
    },
    "16434" => {
      "KeyWord" => "AcquisitionCompressionType",
      "Name" => "Acquisition Compression Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "4032",
      "group" => "0014"
    },
    "16435" => {
      "KeyWord" => "AcquisitionSampleSize",
      "Name" => "Acquisition Sample Size",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "4033",
      "group" => "0014"
    },
    "16436" => {
      "KeyWord" => "RectifierSmoothing",
      "Name" => "Rectifier Smoothing",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4034",
      "group" => "0014"
    },
    "16437" => {
      "KeyWord" => "DACSequence",
      "Name" => "DAC Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4035",
      "group" => "0014"
    },
    "16438" => {
      "KeyWord" => "DACType",
      "Name" => "DAC Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "4036",
      "group" => "0014"
    },
    "16440" => {
      "KeyWord" => "DACGainPoints",
      "Name" => "DAC Gain Points",
      "VM" => "1-n",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4038",
      "group" => "0014"
    },
    "16442" => {
      "KeyWord" => "DACTimePoints",
      "Name" => "DAC Time Points",
      "VM" => "1-n",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "403a",
      "group" => "0014"
    },
    "16444" => {
      "KeyWord" => "DACAmplitude",
      "Name" => "DAC Amplitude",
      "VM" => "1-n",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "403c",
      "group" => "0014"
    },
    "16448" => {
      "KeyWord" => "PreAmplifierSettingsSequence",
      "Name" => "Pre-Amplifier Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4040",
      "group" => "0014"
    },
    "16464" => {
      "KeyWord" => "TransmitTransducerSettingsSequence",
      "Name" => "Transmit Transducer Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4050",
      "group" => "0014"
    },
    "16465" => {
      "KeyWord" => "ReceiveTransducerSettingsSequence",
      "Name" => "Receive Transducer Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4051",
      "group" => "0014"
    },
    "16466" => {
      "KeyWord" => "IncidentAngle",
      "Name" => "Incident Angle",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4052",
      "group" => "0014"
    },
    "16468" => {
      "KeyWord" => "CouplingTechnique",
      "Name" => "Coupling Technique",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "4054",
      "group" => "0014"
    },
    "16470" => {
      "KeyWord" => "CouplingMedium",
      "Name" => "Coupling Medium",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "4056",
      "group" => "0014"
    },
    "16471" => {
      "KeyWord" => "CouplingVelocity",
      "Name" => "Coupling Velocity",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4057",
      "group" => "0014"
    },
    "16472" => {
      "KeyWord" => "ProbeCenterLocationX",
      "Name" => "Probe Center Location X",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4058",
      "group" => "0014"
    },
    "16473" => {
      "KeyWord" => "ProbeCenterLocationZ",
      "Name" => "Probe Center Location Z",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4059",
      "group" => "0014"
    },
    "16474" => {
      "KeyWord" => "SoundPathLength",
      "Name" => "Sound Path Length",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "405a",
      "group" => "0014"
    },
    "16476" => {
      "KeyWord" => "DelayLawIdentifier",
      "Name" => "Delay Law Identifier",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "405c",
      "group" => "0014"
    },
    "16480" => {
      "KeyWord" => "GateSettingsSequence",
      "Name" => "Gate Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4060",
      "group" => "0014"
    },
    "16482" => {
      "KeyWord" => "GateThreshold",
      "Name" => "Gate Threshold",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4062",
      "group" => "0014"
    },
    "16484" => {
      "KeyWord" => "VelocityOfSound",
      "Name" => "Velocity of Sound",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4064",
      "group" => "0014"
    },
    "16496" => {
      "KeyWord" => "CalibrationSettingsSequence",
      "Name" => "Calibration Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4070",
      "group" => "0014"
    },
    "16498" => {
      "KeyWord" => "CalibrationProcedure",
      "Name" => "Calibration Procedure",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "4072",
      "group" => "0014"
    },
    "16500" => {
      "KeyWord" => "ProcedureVersion",
      "Name" => "Procedure Version",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICONDE",
      "ele" => "4074",
      "group" => "0014"
    },
    "16502" => {
      "KeyWord" => "ProcedureCreationDate",
      "Name" => "Procedure Creation Date",
      "VM" => "1",
      "VR" => "DA",
      "comment" => "DICONDE",
      "ele" => "4076",
      "group" => "0014"
    },
    "16504" => {
      "KeyWord" => "ProcedureExpirationDate",
      "Name" => "Procedure Expiration Date",
      "VM" => "1",
      "VR" => "DA",
      "comment" => "DICONDE",
      "ele" => "4078",
      "group" => "0014"
    },
    "16506" => {
      "KeyWord" => "ProcedureLastModifiedDate",
      "Name" => "Procedure Last Modified Date",
      "VM" => "1",
      "VR" => "DA",
      "comment" => "DICONDE",
      "ele" => "407a",
      "group" => "0014"
    },
    "16508" => {
      "KeyWord" => "CalibrationTime",
      "Name" => "Calibration Time",
      "VM" => "1-n",
      "VR" => "TM",
      "comment" => "DICONDE",
      "ele" => "407c",
      "group" => "0014"
    },
    "16510" => {
      "KeyWord" => "CalibrationDate",
      "Name" => "Calibration Date",
      "VM" => "1-n",
      "VR" => "DA",
      "comment" => "DICONDE",
      "ele" => "407e",
      "group" => "0014"
    },
    "16512" => {
      "KeyWord" => "ProbeDriveEquipmentSequence",
      "Name" => "Probe Drive Equipment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4080",
      "group" => "0014"
    },
    "16513" => {
      "KeyWord" => "DriveType",
      "Name" => "Drive Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "4081",
      "group" => "0014"
    },
    "16514" => {
      "KeyWord" => "ProbeDriveNotes",
      "Name" => "Probe Drive Notes",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICONDE",
      "ele" => "4082",
      "group" => "0014"
    },
    "16515" => {
      "KeyWord" => "DriveProbeSequence",
      "Name" => "Drive Probe Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4083",
      "group" => "0014"
    },
    "16516" => {
      "KeyWord" => "ProbeInductance",
      "Name" => "Probe Inductance",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4084",
      "group" => "0014"
    },
    "16517" => {
      "KeyWord" => "ProbeResistance",
      "Name" => "Probe Resistance",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4085",
      "group" => "0014"
    },
    "16518" => {
      "KeyWord" => "ReceiveProbeSequence",
      "Name" => "Receive Probe Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4086",
      "group" => "0014"
    },
    "16519" => {
      "KeyWord" => "ProbeDriveSettingsSequence",
      "Name" => "Probe Drive Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4087",
      "group" => "0014"
    },
    "16520" => {
      "KeyWord" => "BridgeResistors",
      "Name" => "Bridge Resistors",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4088",
      "group" => "0014"
    },
    "16521" => {
      "KeyWord" => "ProbeOrientationAngle",
      "Name" => "Probe Orientation Angle",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4089",
      "group" => "0014"
    },
    "16523" => {
      "KeyWord" => "UserSelectedGainY",
      "Name" => "User Selected Gain Y",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "408b",
      "group" => "0014"
    },
    "16524" => {
      "KeyWord" => "UserSelectedPhase",
      "Name" => "User Selected Phase",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "408c",
      "group" => "0014"
    },
    "16525" => {
      "KeyWord" => "UserSelectedOffsetX",
      "Name" => "User Selected Offset X",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "408d",
      "group" => "0014"
    },
    "16526" => {
      "KeyWord" => "UserSelectedOffsetY",
      "Name" => "User Selected Offset Y",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "408e",
      "group" => "0014"
    },
    "16529" => {
      "KeyWord" => "ChannelSettingsSequence",
      "Name" => "Channel Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "4091",
      "group" => "0014"
    },
    "16530" => {
      "KeyWord" => "ChannelThreshold",
      "Name" => "Channel Threshold",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "4092",
      "group" => "0014"
    },
    "16538" => {
      "KeyWord" => "ScannerSettingsSequence",
      "Name" => "Scanner Settings Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "409a",
      "group" => "0014"
    },
    "16539" => {
      "KeyWord" => "ScanProcedure",
      "Name" => "Scan Procedure",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "409b",
      "group" => "0014"
    },
    "16540" => {
      "KeyWord" => "TranslationRateX",
      "Name" => "Translation Rate X",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "409c",
      "group" => "0014"
    },
    "16541" => {
      "KeyWord" => "TranslationRateY",
      "Name" => "Translation Rate Y",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "409d",
      "group" => "0014"
    },
    "16543" => {
      "KeyWord" => "ChannelOverlap",
      "Name" => "Channel Overlap",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "409f",
      "group" => "0014"
    },
    "16544" => {
      "KeyWord" => "ImageQualityIndicatorType",
      "Name" => "Image Quality Indicator Type",
      "VM" => "1",
      "VR" => "LO",
      "comment" => "DICONDE",
      "ele" => "40a0",
      "group" => "0014"
    },
    "16545" => {
      "KeyWord" => "ImageQualityIndicatorMaterial",
      "Name" => "Image Quality Indicator Material",
      "VM" => "1",
      "VR" => "LO",
      "comment" => "DICONDE",
      "ele" => "40a1",
      "group" => "0014"
    },
    "16546" => {
      "KeyWord" => "ImageQualityIndicatorSize",
      "Name" => "Image Quality Indicator Size",
      "VM" => "1",
      "VR" => "LO",
      "comment" => "DICONDE",
      "ele" => "40a2",
      "group" => "0014"
    },
    "20482" => {
      "KeyWord" => "LINACEnergy",
      "Name" => "LINAC Energy",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "5002",
      "group" => "0014"
    },
    "20484" => {
      "KeyWord" => "LINACOutput",
      "Name" => "LINAC Output",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "5004",
      "group" => "0014"
    },
    "35" => {
      "KeyWord" => "CADFileFormat",
      "Name" => "CAD File Format",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "ST",
      "ele" => "0023",
      "group" => "0014"
    },
    "36" => {
      "KeyWord" => "ComponentReferenceSystem",
      "Name" => "Component Reference System",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "ST",
      "ele" => "0024",
      "group" => "0014"
    },
    "37" => {
      "KeyWord" => "ComponentManufacturingProcedure",
      "Name" => "Component Manufacturing Procedure",
      "VM" => "1-n",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "0025",
      "group" => "0014"
    },
    "40" => {
      "KeyWord" => "ComponentManufacturer",
      "Name" => "Component Manufacturer",
      "VM" => "1-n",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "0028",
      "group" => "0014"
    },
    "4112" => {
      "KeyWord" => "ActualEnvironmentalConditions",
      "Name" => "Actual Environmental Conditions",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "1010",
      "group" => "0014"
    },
    "4128" => {
      "KeyWord" => "ExpiryDate",
      "Name" => "Expiry Date",
      "VM" => "1",
      "VR" => "DA",
      "comment" => "DICONDE",
      "ele" => "1020",
      "group" => "0014"
    },
    "4160" => {
      "KeyWord" => "EnvironmentalConditions",
      "Name" => "Environmental Conditions",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "1040",
      "group" => "0014"
    },
    "48" => {
      "KeyWord" => "MaterialThickness",
      "Name" => "Material Thickness",
      "VM" => "1-n",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "0030",
      "group" => "0014"
    },
    "50" => {
      "KeyWord" => "MaterialPipeDiameter",
      "Name" => "Material Pipe Diameter",
      "VM" => "1-n",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "0032",
      "group" => "0014"
    },
    "52" => {
      "KeyWord" => "MaterialIsolationDiameter",
      "Name" => "Material Isolation Diameter",
      "VM" => "1-n",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "0034",
      "group" => "0014"
    },
    "66" => {
      "KeyWord" => "MaterialGrade",
      "Name" => "Material Grade",
      "VM" => "1-n",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "0042",
      "group" => "0014"
    },
    "68" => {
      "KeyWord" => "MaterialPropertiesDescription",
      "Name" => "Material Properties Description",
      "VM" => "1-n",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "0044",
      "group" => "0014"
    },
    "69" => {
      "KeyWord" => "MaterialPropertiesFileFormatRetired",
      "Name" => "Material Properties File Format (Retired)",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "ST",
      "ele" => "0045",
      "group" => "0014"
    },
    "70" => {
      "KeyWord" => "MaterialNotes",
      "Name" => "Material Notes",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICONDE",
      "ele" => "0046",
      "group" => "0014"
    },
    "80" => {
      "KeyWord" => "ComponentShape",
      "Name" => "Component Shape",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "0050",
      "group" => "0014"
    },
    "8194" => {
      "KeyWord" => "EvaluatorSequence",
      "Name" => "Evaluator Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "2002",
      "group" => "0014"
    },
    "8196" => {
      "KeyWord" => "EvaluatorNumber",
      "Name" => "Evaluator Number",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "2004",
      "group" => "0014"
    },
    "8198" => {
      "KeyWord" => "EvaluatorName",
      "Name" => "Evaluator Name",
      "VM" => "1",
      "VR" => "PN",
      "comment" => "DICONDE",
      "ele" => "2006",
      "group" => "0014"
    },
    "82" => {
      "KeyWord" => "CurvatureType",
      "Name" => "Curvature Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "0052",
      "group" => "0014"
    },
    "8200" => {
      "KeyWord" => "EvaluationAttempt",
      "Name" => "Evaluation Attempt",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "2008",
      "group" => "0014"
    },
    "8210" => {
      "KeyWord" => "IndicationSequence",
      "Name" => "Indication Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "2012",
      "group" => "0014"
    },
    "8212" => {
      "KeyWord" => "IndicationNumber",
      "Name" => "Indication Number",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "2014",
      "group" => "0014"
    },
    "8214" => {
      "KeyWord" => "IndicationLabel",
      "Name" => "Indication Label",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICONDE",
      "ele" => "2016",
      "group" => "0014"
    },
    "8216" => {
      "KeyWord" => "IndicationDescription",
      "Name" => "Indication Description",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "2018",
      "group" => "0014"
    },
    "8218" => {
      "KeyWord" => "IndicationType",
      "Name" => "Indication Type",
      "VM" => "1-n",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "201a",
      "group" => "0014"
    },
    "8220" => {
      "KeyWord" => "IndicationDisposition",
      "Name" => "Indication Disposition",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "201c",
      "group" => "0014"
    },
    "8222" => {
      "KeyWord" => "IndicationROISequence",
      "Name" => "Indication ROI Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "201e",
      "group" => "0014"
    },
    "8240" => {
      "KeyWord" => "IndicationPhysicalPropertySequence",
      "Name" => "Indication Physical Property Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "2030",
      "group" => "0014"
    },
    "8242" => {
      "KeyWord" => "PropertyLabel",
      "Name" => "Property Label",
      "VM" => "1",
      "VR" => "SH",
      "comment" => "DICONDE",
      "ele" => "2032",
      "group" => "0014"
    },
    "84" => {
      "KeyWord" => "OuterDiameter",
      "Name" => "Outer Diameter",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "0054",
      "group" => "0014"
    },
    "86" => {
      "KeyWord" => "InnerDiameter",
      "Name" => "Inner Diameter",
      "VM" => "1",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "0056",
      "group" => "0014"
    },
    "8706" => {
      "KeyWord" => "CoordinateSystemNumberOfAxes",
      "Name" => "Coordinate System Number of Axes",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "2202",
      "group" => "0014"
    },
    "8708" => {
      "KeyWord" => "CoordinateSystemAxesSequence",
      "Name" => "Coordinate System Axes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "2204",
      "group" => "0014"
    },
    "8710" => {
      "KeyWord" => "CoordinateSystemAxisDescription",
      "Name" => "Coordinate System Axis Description",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "2206",
      "group" => "0014"
    },
    "8712" => {
      "KeyWord" => "CoordinateSystemDataSetMapping",
      "Name" => "Coordinate System Data Set Mapping",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "2208",
      "group" => "0014"
    },
    "8714" => {
      "KeyWord" => "CoordinateSystemAxisNumber",
      "Name" => "Coordinate System Axis Number",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "220a",
      "group" => "0014"
    },
    "8716" => {
      "KeyWord" => "CoordinateSystemAxisType",
      "Name" => "Coordinate System Axis Type",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "220c",
      "group" => "0014"
    },
    "8718" => {
      "KeyWord" => "CoordinateSystemAxisUnits",
      "Name" => "Coordinate System Axis Units",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "220e",
      "group" => "0014"
    },
    "8720" => {
      "KeyWord" => "CoordinateSystemAxisValues",
      "Name" => "Coordinate System Axis Values",
      "VM" => "1",
      "VR" => "OB",
      "comment" => "DICONDE",
      "ele" => "2210",
      "group" => "0014"
    },
    "8736" => {
      "KeyWord" => "CoordinateSystemTransformSequence",
      "Name" => "Coordinate System Transform Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "DICONDE",
      "ele" => "2220",
      "group" => "0014"
    },
    "8738" => {
      "KeyWord" => "TransformDescription",
      "Name" => "Transform Description",
      "VM" => "1",
      "VR" => "ST",
      "comment" => "DICONDE",
      "ele" => "2222",
      "group" => "0014"
    },
    "8740" => {
      "KeyWord" => "TransformNumberOfAxes",
      "Name" => "Transform Number of Axes",
      "VM" => "1",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "2224",
      "group" => "0014"
    },
    "8742" => {
      "KeyWord" => "TransformOrderOfAxes",
      "Name" => "Transform Order of Axes",
      "VM" => "1-n",
      "VR" => "IS",
      "comment" => "DICONDE",
      "ele" => "2226",
      "group" => "0014"
    },
    "8744" => {
      "KeyWord" => "TransformedAxisUnits",
      "Name" => "Transformed Axis Units",
      "VM" => "1",
      "VR" => "CS",
      "comment" => "DICONDE",
      "ele" => "2228",
      "group" => "0014"
    },
    "8746" => {
      "KeyWord" => "CoordinateSystemTransformRotationAndScaleMatrix",
      "Name" => "Coordinate System Transform Rotation and Scale Matrix",
      "VM" => "1-n",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "222a",
      "group" => "0014"
    },
    "8748" => {
      "KeyWord" => "CoordinateSystemTransformTranslationMatrix",
      "Name" => "Coordinate System Transform Translation Matrix",
      "VM" => "1-n",
      "VR" => "DS",
      "comment" => "DICONDE",
      "ele" => "222c",
      "group" => "0014"
    }
  },
  "20478" => {
    "1" => {
      "KeyWord" => "MACParametersSequence",
      "Name" => "MAC Parameters Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0001",
      "group" => "4ffe"
    }
  },
  "20992" => {
    "37417" => {
      "KeyWord" => "SharedFunctionalGroupsSequence",
      "Name" => "Shared Functional Groups Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9229",
      "group" => "5200"
    },
    "37424" => {
      "KeyWord" => "PerFrameFunctionalGroupsSequence",
      "Name" => "Per-frame Functional Groups Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9230",
      "group" => "5200"
    }
  },
  "21504" => {
    "256" => {
      "KeyWord" => "WaveformSequence",
      "Name" => "Waveform Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0100",
      "group" => "5400"
    },
    "272" => {
      "KeyWord" => "ChannelMinimumValue",
      "Name" => "Channel Minimum Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0110",
      "group" => "5400"
    },
    "274" => {
      "KeyWord" => "ChannelMaximumValue",
      "Name" => "Channel Maximum Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0112",
      "group" => "5400"
    },
    "4100" => {
      "KeyWord" => "WaveformBitsAllocated",
      "Name" => "Waveform Bits Allocated",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1004",
      "group" => "5400"
    },
    "4102" => {
      "KeyWord" => "WaveformSampleInterpretation",
      "Name" => "Waveform Sample Interpretation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1006",
      "group" => "5400"
    },
    "4106" => {
      "KeyWord" => "WaveformPaddingValue",
      "Name" => "Waveform Padding Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "100a",
      "group" => "5400"
    },
    "4112" => {
      "KeyWord" => "WaveformData",
      "Name" => "Waveform Data",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "1010",
      "group" => "5400"
    }
  },
  "22016" => {
    "16" => {
      "KeyWord" => "FirstOrderPhaseCorrectionAngle",
      "Name" => "First Order Phase Correction Angle",
      "VM" => "1",
      "VR" => "OF",
      "ele" => "0010",
      "group" => "5600"
    },
    "32" => {
      "KeyWord" => "SpectroscopyData",
      "Name" => "Spectroscopy Data",
      "VM" => "1",
      "VR" => "OF",
      "ele" => "0020",
      "group" => "5600"
    }
  },
  "24" => {
    "112" => {
      "KeyWord" => "CountsAccumulated",
      "Name" => "Counts Accumulated",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0070",
      "group" => "0018"
    },
    "113" => {
      "KeyWord" => "AcquisitionTerminationCondition",
      "Name" => "Acquisition Termination Condition",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0071",
      "group" => "0018"
    },
    "114" => {
      "KeyWord" => "EffectiveDuration",
      "Name" => "Effective Duration",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0072",
      "group" => "0018"
    },
    "115" => {
      "KeyWord" => "AcquisitionStartCondition",
      "Name" => "Acquisition Start Condition",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0073",
      "group" => "0018"
    },
    "116" => {
      "KeyWord" => "AcquisitionStartConditionData",
      "Name" => "Acquisition Start Condition Data",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0074",
      "group" => "0018"
    },
    "117" => {
      "KeyWord" => "AcquisitionTerminationConditionData",
      "Name" => "Acquisition Termination Condition Data",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0075",
      "group" => "0018"
    },
    "12544" => {
      "KeyWord" => "IVUSAcquisition",
      "Name" => "IVUS Acquisition",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "3100",
      "group" => "0018"
    },
    "12545" => {
      "KeyWord" => "IVUSPullbackRate",
      "Name" => "IVUS Pullback Rate",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "3101",
      "group" => "0018"
    },
    "12546" => {
      "KeyWord" => "IVUSGatedRate",
      "Name" => "IVUS Gated Rate",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "3102",
      "group" => "0018"
    },
    "12547" => {
      "KeyWord" => "IVUSPullbackStartFrameNumber",
      "Name" => "IVUS Pullback Start Frame Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "3103",
      "group" => "0018"
    },
    "12548" => {
      "KeyWord" => "IVUSPullbackStopFrameNumber",
      "Name" => "IVUS Pullback Stop Frame Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "3104",
      "group" => "0018"
    },
    "12549" => {
      "KeyWord" => "LesionNumber",
      "Name" => "Lesion Number",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "3105",
      "group" => "0018"
    },
    "128" => {
      "KeyWord" => "RepetitionTime",
      "Name" => "Repetition Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0080",
      "group" => "0018"
    },
    "129" => {
      "KeyWord" => "EchoTime",
      "Name" => "Echo Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0081",
      "group" => "0018"
    },
    "130" => {
      "KeyWord" => "InversionTime",
      "Name" => "Inversion Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0082",
      "group" => "0018"
    },
    "131" => {
      "KeyWord" => "NumberOfAverages",
      "Name" => "Number of Averages",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0083",
      "group" => "0018"
    },
    "132" => {
      "KeyWord" => "ImagingFrequency",
      "Name" => "Imaging Frequency",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0084",
      "group" => "0018"
    },
    "133" => {
      "KeyWord" => "ImagedNucleus",
      "Name" => "Imaged Nucleus",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0085",
      "group" => "0018"
    },
    "134" => {
      "KeyWord" => "EchoNumbers",
      "Name" => "Echo Number(s)",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "0086",
      "group" => "0018"
    },
    "135" => {
      "KeyWord" => "MagneticFieldStrength",
      "Name" => "Magnetic Field Strength",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0087",
      "group" => "0018"
    },
    "136" => {
      "KeyWord" => "SpacingBetweenSlices",
      "Name" => "Spacing Between Slices",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0088",
      "group" => "0018"
    },
    "137" => {
      "KeyWord" => "NumberOfPhaseEncodingSteps",
      "Name" => "Number of Phase Encoding Steps",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0089",
      "group" => "0018"
    },
    "144" => {
      "KeyWord" => "DataCollectionDiameter",
      "Name" => "Data Collection Diameter",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0090",
      "group" => "0018"
    },
    "145" => {
      "KeyWord" => "EchoTrainLength",
      "Name" => "Echo Train Length",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0091",
      "group" => "0018"
    },
    "147" => {
      "KeyWord" => "PercentSampling",
      "Name" => "Percent Sampling",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0093",
      "group" => "0018"
    },
    "148" => {
      "KeyWord" => "PercentPhaseFieldOfView",
      "Name" => "Percent Phase Field of View",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0094",
      "group" => "0018"
    },
    "149" => {
      "KeyWord" => "PixelBandwidth",
      "Name" => "Pixel Bandwidth",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0095",
      "group" => "0018"
    },
    "16" => {
      "KeyWord" => "ContrastBolusAgent",
      "Name" => "Contrast/Bolus Agent",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0010",
      "group" => "0018"
    },
    "16384" => {
      "KeyWord" => "AcquisitionComments",
      "Name" => "Acquisition Comments",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "0018"
    },
    "18" => {
      "KeyWord" => "ContrastBolusAgentSequence",
      "Name" => "Contrast/Bolus Agent Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0012",
      "group" => "0018"
    },
    "20" => {
      "KeyWord" => "ContrastBolusAdministrationRouteSequence",
      "Name" => "Contrast/Bolus Administration Route Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0014",
      "group" => "0018"
    },
    "20480" => {
      "KeyWord" => "OutputPower",
      "Name" => "Output Power",
      "VM" => "1-n",
      "VR" => "SH",
      "ele" => "5000",
      "group" => "0018"
    },
    "20496" => {
      "KeyWord" => "TransducerData",
      "Name" => "Transducer Data",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "5010",
      "group" => "0018"
    },
    "20498" => {
      "KeyWord" => "FocusDepth",
      "Name" => "Focus Depth",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5012",
      "group" => "0018"
    },
    "20512" => {
      "KeyWord" => "ProcessingFunction",
      "Name" => "Processing Function",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "5020",
      "group" => "0018"
    },
    "20513" => {
      "KeyWord" => "PostprocessingFunction",
      "Name" => "Postprocessing Function",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "5021",
      "group" => "0018"
    },
    "20514" => {
      "KeyWord" => "MechanicalIndex",
      "Name" => "Mechanical Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5022",
      "group" => "0018"
    },
    "20516" => {
      "KeyWord" => "BoneThermalIndex",
      "Name" => "Bone Thermal Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5024",
      "group" => "0018"
    },
    "20518" => {
      "KeyWord" => "CranialThermalIndex",
      "Name" => "Cranial Thermal Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5026",
      "group" => "0018"
    },
    "20519" => {
      "KeyWord" => "SoftTissueThermalIndex",
      "Name" => "Soft Tissue Thermal Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5027",
      "group" => "0018"
    },
    "20520" => {
      "KeyWord" => "SoftTissueFocusThermalIndex",
      "Name" => "Soft Tissue-focus Thermal Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5028",
      "group" => "0018"
    },
    "20521" => {
      "KeyWord" => "SoftTissueSurfaceThermalIndex",
      "Name" => "Soft Tissue-surface Thermal Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5029",
      "group" => "0018"
    },
    "20528" => {
      "KeyWord" => "DynamicRange",
      "Name" => "Dynamic Range",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5030",
      "group" => "0018"
    },
    "20544" => {
      "KeyWord" => "TotalGain",
      "Name" => "Total Gain",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "5040",
      "group" => "0018"
    },
    "20560" => {
      "KeyWord" => "DepthOfScanField",
      "Name" => "Depth of Scan Field",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "5050",
      "group" => "0018"
    },
    "20736" => {
      "KeyWord" => "PatientPosition",
      "Name" => "Patient Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "5100",
      "group" => "0018"
    },
    "20737" => {
      "KeyWord" => "ViewPosition",
      "Name" => "View Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "5101",
      "group" => "0018"
    },
    "20740" => {
      "KeyWord" => "ProjectionEponymousNameCodeSequence",
      "Name" => "Projection Eponymous Name Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "5104",
      "group" => "0018"
    },
    "21" => {
      "KeyWord" => "BodyPartExamined",
      "Name" => "Body Part Examined",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0015",
      "group" => "0018"
    },
    "21008" => {
      "KeyWord" => "ImageTransformationMatrix",
      "Name" => "Image Transformation Matrix",
      "RET" => "1",
      "VM" => "6",
      "VR" => "DS",
      "ele" => "5210",
      "group" => "0018"
    },
    "21010" => {
      "KeyWord" => "ImageTranslationVector",
      "Name" => "Image Translation Vector",
      "RET" => "1",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "5212",
      "group" => "0018"
    },
    "24576" => {
      "KeyWord" => "Sensitivity",
      "Name" => "Sensitivity",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "6000",
      "group" => "0018"
    },
    "24593" => {
      "KeyWord" => "SequenceOfUltrasoundRegions",
      "Name" => "Sequence of Ultrasound Regions",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6011",
      "group" => "0018"
    },
    "24594" => {
      "KeyWord" => "RegionSpatialFormat",
      "Name" => "Region Spatial Format",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6012",
      "group" => "0018"
    },
    "24596" => {
      "KeyWord" => "RegionDataType",
      "Name" => "Region Data Type",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6014",
      "group" => "0018"
    },
    "24598" => {
      "KeyWord" => "RegionFlags",
      "Name" => "Region Flags",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6016",
      "group" => "0018"
    },
    "24600" => {
      "KeyWord" => "RegionLocationMinX0",
      "Name" => "Region Location Min X0",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6018",
      "group" => "0018"
    },
    "24602" => {
      "KeyWord" => "RegionLocationMinY0",
      "Name" => "Region Location Min Y0",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "601a",
      "group" => "0018"
    },
    "24604" => {
      "KeyWord" => "RegionLocationMaxX1",
      "Name" => "Region Location Max X1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "601c",
      "group" => "0018"
    },
    "24606" => {
      "KeyWord" => "RegionLocationMaxY1",
      "Name" => "Region Location Max Y1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "601e",
      "group" => "0018"
    },
    "24608" => {
      "KeyWord" => "ReferencePixelX0",
      "Name" => "Reference Pixel X0",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "6020",
      "group" => "0018"
    },
    "24610" => {
      "KeyWord" => "ReferencePixelY0",
      "Name" => "Reference Pixel Y0",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "6022",
      "group" => "0018"
    },
    "24612" => {
      "KeyWord" => "PhysicalUnitsXDirection",
      "Name" => "Physical Units X Direction",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6024",
      "group" => "0018"
    },
    "24614" => {
      "KeyWord" => "PhysicalUnitsYDirection",
      "Name" => "Physical Units Y Direction",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6026",
      "group" => "0018"
    },
    "24616" => {
      "KeyWord" => "ReferencePixelPhysicalValueX",
      "Name" => "Reference Pixel Physical Value X",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "6028",
      "group" => "0018"
    },
    "24618" => {
      "KeyWord" => "ReferencePixelPhysicalValueY",
      "Name" => "Reference Pixel Physical Value Y",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "602a",
      "group" => "0018"
    },
    "24620" => {
      "KeyWord" => "PhysicalDeltaX",
      "Name" => "Physical Delta X",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "602c",
      "group" => "0018"
    },
    "24622" => {
      "KeyWord" => "PhysicalDeltaY",
      "Name" => "Physical Delta Y",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "602e",
      "group" => "0018"
    },
    "24624" => {
      "KeyWord" => "TransducerFrequency",
      "Name" => "Transducer Frequency",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6030",
      "group" => "0018"
    },
    "24625" => {
      "KeyWord" => "TransducerType",
      "Name" => "Transducer Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "6031",
      "group" => "0018"
    },
    "24626" => {
      "KeyWord" => "PulseRepetitionFrequency",
      "Name" => "Pulse Repetition Frequency",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6032",
      "group" => "0018"
    },
    "24628" => {
      "KeyWord" => "DopplerCorrectionAngle",
      "Name" => "Doppler Correction Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "6034",
      "group" => "0018"
    },
    "24630" => {
      "KeyWord" => "SteeringAngle",
      "Name" => "Steering Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "6036",
      "group" => "0018"
    },
    "24632" => {
      "KeyWord" => "DopplerSampleVolumeXPositionRetired",
      "Name" => "Doppler Sample Volume X Position (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6038",
      "group" => "0018"
    },
    "24633" => {
      "KeyWord" => "DopplerSampleVolumeXPosition",
      "Name" => "Doppler Sample Volume X Position",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "6039",
      "group" => "0018"
    },
    "24634" => {
      "KeyWord" => "DopplerSampleVolumeYPositionRetired",
      "Name" => "Doppler Sample Volume Y Position (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "603a",
      "group" => "0018"
    },
    "24635" => {
      "KeyWord" => "DopplerSampleVolumeYPosition",
      "Name" => "Doppler Sample Volume Y Position",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "603b",
      "group" => "0018"
    },
    "24636" => {
      "KeyWord" => "TMLinePositionX0Retired",
      "Name" => "TM-Line Position X0 (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "603c",
      "group" => "0018"
    },
    "24637" => {
      "KeyWord" => "TMLinePositionX0",
      "Name" => "TM-Line Position X0",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "603d",
      "group" => "0018"
    },
    "24638" => {
      "KeyWord" => "TMLinePositionY0Retired",
      "Name" => "TM-Line Position Y0 (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "603e",
      "group" => "0018"
    },
    "24639" => {
      "KeyWord" => "TMLinePositionY0",
      "Name" => "TM-Line Position Y0",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "603f",
      "group" => "0018"
    },
    "24640" => {
      "KeyWord" => "TMLinePositionX1Retired",
      "Name" => "TM-Line Position X1 (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6040",
      "group" => "0018"
    },
    "24641" => {
      "KeyWord" => "TMLinePositionX1",
      "Name" => "TM-Line Position X1",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "6041",
      "group" => "0018"
    },
    "24642" => {
      "KeyWord" => "TMLinePositionY1Retired",
      "Name" => "TM-Line Position Y1 (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6042",
      "group" => "0018"
    },
    "24643" => {
      "KeyWord" => "TMLinePositionY1",
      "Name" => "TM-Line Position Y1",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "6043",
      "group" => "0018"
    },
    "24644" => {
      "KeyWord" => "PixelComponentOrganization",
      "Name" => "Pixel Component Organization",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6044",
      "group" => "0018"
    },
    "24646" => {
      "KeyWord" => "PixelComponentMask",
      "Name" => "Pixel Component Mask",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6046",
      "group" => "0018"
    },
    "24648" => {
      "KeyWord" => "PixelComponentRangeStart",
      "Name" => "Pixel Component Range Start",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6048",
      "group" => "0018"
    },
    "24650" => {
      "KeyWord" => "PixelComponentRangeStop",
      "Name" => "Pixel Component Range Stop",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "604a",
      "group" => "0018"
    },
    "24652" => {
      "KeyWord" => "PixelComponentPhysicalUnits",
      "Name" => "Pixel Component Physical Units",
      "VM" => "1",
      "VR" => "US",
      "ele" => "604c",
      "group" => "0018"
    },
    "24654" => {
      "KeyWord" => "PixelComponentDataType",
      "Name" => "Pixel Component Data Type",
      "VM" => "1",
      "VR" => "US",
      "ele" => "604e",
      "group" => "0018"
    },
    "24656" => {
      "KeyWord" => "NumberOfTableBreakPoints",
      "Name" => "Number of Table Break Points",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6050",
      "group" => "0018"
    },
    "24658" => {
      "KeyWord" => "TableOfXBreakPoints",
      "Name" => "Table of X Break Points",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "6052",
      "group" => "0018"
    },
    "24660" => {
      "KeyWord" => "TableOfYBreakPoints",
      "Name" => "Table of Y Break Points",
      "VM" => "1-n",
      "VR" => "FD",
      "ele" => "6054",
      "group" => "0018"
    },
    "24662" => {
      "KeyWord" => "NumberOfTableEntries",
      "Name" => "Number of Table Entries",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "6056",
      "group" => "0018"
    },
    "24664" => {
      "KeyWord" => "TableOfPixelValues",
      "Name" => "Table of Pixel Values",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "6058",
      "group" => "0018"
    },
    "24666" => {
      "KeyWord" => "TableOfParameterValues",
      "Name" => "Table of Parameter Values",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "605a",
      "group" => "0018"
    },
    "24672" => {
      "KeyWord" => "RWaveTimeVector",
      "Name" => "R Wave Time Vector",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "6060",
      "group" => "0018"
    },
    "28672" => {
      "KeyWord" => "DetectorConditionsNominalFlag",
      "Name" => "Detector Conditions Nominal Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "7000",
      "group" => "0018"
    },
    "28673" => {
      "KeyWord" => "DetectorTemperature",
      "Name" => "Detector Temperature",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7001",
      "group" => "0018"
    },
    "28676" => {
      "KeyWord" => "DetectorType",
      "Name" => "Detector Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "7004",
      "group" => "0018"
    },
    "28677" => {
      "KeyWord" => "DetectorConfiguration",
      "Name" => "Detector Configuration",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "7005",
      "group" => "0018"
    },
    "28678" => {
      "KeyWord" => "DetectorDescription",
      "Name" => "Detector Description",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "7006",
      "group" => "0018"
    },
    "28680" => {
      "KeyWord" => "DetectorMode",
      "Name" => "Detector Mode",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "7008",
      "group" => "0018"
    },
    "28682" => {
      "KeyWord" => "DetectorID",
      "Name" => "Detector ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "700a",
      "group" => "0018"
    },
    "28684" => {
      "KeyWord" => "DateOfLastDetectorCalibration",
      "Name" => "Date of Last Detector Calibration",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "700c",
      "group" => "0018"
    },
    "28686" => {
      "KeyWord" => "TimeOfLastDetectorCalibration",
      "Name" => "Time of Last Detector Calibration",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "700e",
      "group" => "0018"
    },
    "28688" => {
      "KeyWord" => "ExposuresOnDetectorSinceLastCalibration",
      "Name" => "Exposures on Detector Since Last Calibration",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "7010",
      "group" => "0018"
    },
    "28689" => {
      "KeyWord" => "ExposuresOnDetectorSinceManufactured",
      "Name" => "Exposures on Detector Since Manufactured",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "7011",
      "group" => "0018"
    },
    "28690" => {
      "KeyWord" => "DetectorTimeSinceLastExposure",
      "Name" => "Detector Time Since Last Exposure",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7012",
      "group" => "0018"
    },
    "28692" => {
      "KeyWord" => "DetectorActiveTime",
      "Name" => "Detector Active Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7014",
      "group" => "0018"
    },
    "28694" => {
      "KeyWord" => "DetectorActivationOffsetFromExposure",
      "Name" => "Detector Activation Offset From Exposure",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7016",
      "group" => "0018"
    },
    "28698" => {
      "KeyWord" => "DetectorBinning",
      "Name" => "Detector Binning",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "701a",
      "group" => "0018"
    },
    "28704" => {
      "KeyWord" => "DetectorElementPhysicalSize",
      "Name" => "Detector Element Physical Size",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "7020",
      "group" => "0018"
    },
    "28706" => {
      "KeyWord" => "DetectorElementSpacing",
      "Name" => "Detector Element Spacing",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "7022",
      "group" => "0018"
    },
    "28708" => {
      "KeyWord" => "DetectorActiveShape",
      "Name" => "Detector Active Shape",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "7024",
      "group" => "0018"
    },
    "28710" => {
      "KeyWord" => "DetectorActiveDimensions",
      "Name" => "Detector Active Dimension(s)",
      "VM" => "1-2",
      "VR" => "DS",
      "ele" => "7026",
      "group" => "0018"
    },
    "28712" => {
      "KeyWord" => "DetectorActiveOrigin",
      "Name" => "Detector Active Origin",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "7028",
      "group" => "0018"
    },
    "28714" => {
      "KeyWord" => "DetectorManufacturerName",
      "Name" => "Detector Manufacturer Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "702a",
      "group" => "0018"
    },
    "28715" => {
      "KeyWord" => "DetectorManufacturerModelName",
      "Name" => "Detector Manufacturer's Model Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "702b",
      "group" => "0018"
    },
    "28720" => {
      "KeyWord" => "FieldOfViewOrigin",
      "Name" => "Field of View Origin",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "7030",
      "group" => "0018"
    },
    "28722" => {
      "KeyWord" => "FieldOfViewRotation",
      "Name" => "Field of View Rotation",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7032",
      "group" => "0018"
    },
    "28724" => {
      "KeyWord" => "FieldOfViewHorizontalFlip",
      "Name" => "Field of View Horizontal Flip",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "7034",
      "group" => "0018"
    },
    "28726" => {
      "KeyWord" => "PixelDataAreaOriginRelativeToFOV",
      "Name" => "Pixel Data Area Origin Relative To FOV",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "7036",
      "group" => "0018"
    },
    "28728" => {
      "KeyWord" => "PixelDataAreaRotationAngleRelativeToFOV",
      "Name" => "Pixel Data Area Rotation Angle Relative To FOV",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "7038",
      "group" => "0018"
    },
    "28736" => {
      "KeyWord" => "GridAbsorbingMaterial",
      "Name" => "Grid Absorbing Material",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "7040",
      "group" => "0018"
    },
    "28737" => {
      "KeyWord" => "GridSpacingMaterial",
      "Name" => "Grid Spacing Material",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "7041",
      "group" => "0018"
    },
    "28738" => {
      "KeyWord" => "GridThickness",
      "Name" => "Grid Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7042",
      "group" => "0018"
    },
    "28740" => {
      "KeyWord" => "GridPitch",
      "Name" => "Grid Pitch",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7044",
      "group" => "0018"
    },
    "28742" => {
      "KeyWord" => "GridAspectRatio",
      "Name" => "Grid Aspect Ratio",
      "VM" => "2",
      "VR" => "IS",
      "ele" => "7046",
      "group" => "0018"
    },
    "28744" => {
      "KeyWord" => "GridPeriod",
      "Name" => "Grid Period",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7048",
      "group" => "0018"
    },
    "28748" => {
      "KeyWord" => "GridFocalDistance",
      "Name" => "Grid Focal Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "704c",
      "group" => "0018"
    },
    "28752" => {
      "KeyWord" => "FilterMaterial",
      "Name" => "Filter Material",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "7050",
      "group" => "0018"
    },
    "28754" => {
      "KeyWord" => "FilterThicknessMinimum",
      "Name" => "Filter Thickness Minimum",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "7052",
      "group" => "0018"
    },
    "28756" => {
      "KeyWord" => "FilterThicknessMaximum",
      "Name" => "Filter Thickness Maximum",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "7054",
      "group" => "0018"
    },
    "28758" => {
      "KeyWord" => "FilterBeamPathLengthMinimum",
      "Name" => "Filter Beam Path Length Minimum",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "7056",
      "group" => "0018"
    },
    "28760" => {
      "KeyWord" => "FilterBeamPathLengthMaximum",
      "Name" => "Filter Beam Path Length Maximum",
      "VM" => "1-n",
      "VR" => "FL",
      "ele" => "7058",
      "group" => "0018"
    },
    "28768" => {
      "KeyWord" => "ExposureControlMode",
      "Name" => "Exposure Control Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "7060",
      "group" => "0018"
    },
    "28770" => {
      "KeyWord" => "ExposureControlModeDescription",
      "Name" => "Exposure Control Mode Description",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "7062",
      "group" => "0018"
    },
    "28772" => {
      "KeyWord" => "ExposureStatus",
      "Name" => "Exposure Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "7064",
      "group" => "0018"
    },
    "28773" => {
      "KeyWord" => "PhototimerSetting",
      "Name" => "Phototimer Setting",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "7065",
      "group" => "0018"
    },
    "32" => {
      "KeyWord" => "ScanningSequence",
      "Name" => "Scanning Sequence",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "0018"
    },
    "33" => {
      "KeyWord" => "SequenceVariant",
      "Name" => "Sequence Variant",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0021",
      "group" => "0018"
    },
    "33104" => {
      "KeyWord" => "ExposureTimeInuS",
      "Name" => "Exposure Time in µS",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "8150",
      "group" => "0018"
    },
    "33105" => {
      "KeyWord" => "XRayTubeCurrentInuA",
      "Name" => "X-Ray Tube Current in µA",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "8151",
      "group" => "0018"
    },
    "34" => {
      "KeyWord" => "ScanOptions",
      "Name" => "Scan Options",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0022",
      "group" => "0018"
    },
    "35" => {
      "KeyWord" => "MRAcquisitionType",
      "Name" => "MR Acquisition Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0023",
      "group" => "0018"
    },
    "36" => {
      "KeyWord" => "SequenceName",
      "Name" => "Sequence Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0024",
      "group" => "0018"
    },
    "36868" => {
      "KeyWord" => "ContentQualification",
      "Name" => "Content Qualification",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9004",
      "group" => "0018"
    },
    "36869" => {
      "KeyWord" => "PulseSequenceName",
      "Name" => "Pulse Sequence Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "9005",
      "group" => "0018"
    },
    "36870" => {
      "KeyWord" => "MRImagingModifierSequence",
      "Name" => "MR Imaging Modifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9006",
      "group" => "0018"
    },
    "36872" => {
      "KeyWord" => "EchoPulseSequence",
      "Name" => "Echo Pulse Sequence",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9008",
      "group" => "0018"
    },
    "36873" => {
      "KeyWord" => "InversionRecovery",
      "Name" => "Inversion Recovery",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9009",
      "group" => "0018"
    },
    "36880" => {
      "KeyWord" => "FlowCompensation",
      "Name" => "Flow Compensation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9010",
      "group" => "0018"
    },
    "36881" => {
      "KeyWord" => "MultipleSpinEcho",
      "Name" => "Multiple Spin Echo",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9011",
      "group" => "0018"
    },
    "36882" => {
      "KeyWord" => "MultiPlanarExcitation",
      "Name" => "Multi-planar Excitation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9012",
      "group" => "0018"
    },
    "36884" => {
      "KeyWord" => "PhaseContrast",
      "Name" => "Phase Contrast",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9014",
      "group" => "0018"
    },
    "36885" => {
      "KeyWord" => "TimeOfFlightContrast",
      "Name" => "Time of Flight Contrast",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9015",
      "group" => "0018"
    },
    "36886" => {
      "KeyWord" => "Spoiling",
      "Name" => "Spoiling",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9016",
      "group" => "0018"
    },
    "36887" => {
      "KeyWord" => "SteadyStatePulseSequence",
      "Name" => "Steady State Pulse Sequence",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9017",
      "group" => "0018"
    },
    "36888" => {
      "KeyWord" => "EchoPlanarPulseSequence",
      "Name" => "Echo Planar Pulse Sequence",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9018",
      "group" => "0018"
    },
    "36889" => {
      "KeyWord" => "TagAngleFirstAxis",
      "Name" => "Tag Angle First Axis",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9019",
      "group" => "0018"
    },
    "36896" => {
      "KeyWord" => "MagnetizationTransfer",
      "Name" => "Magnetization Transfer",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9020",
      "group" => "0018"
    },
    "36897" => {
      "KeyWord" => "T2Preparation",
      "Name" => "T2 Preparation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9021",
      "group" => "0018"
    },
    "36898" => {
      "KeyWord" => "BloodSignalNulling",
      "Name" => "Blood Signal Nulling",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9022",
      "group" => "0018"
    },
    "36900" => {
      "KeyWord" => "SaturationRecovery",
      "Name" => "Saturation Recovery",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9024",
      "group" => "0018"
    },
    "36901" => {
      "KeyWord" => "SpectrallySelectedSuppression",
      "Name" => "Spectrally Selected Suppression",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9025",
      "group" => "0018"
    },
    "36902" => {
      "KeyWord" => "SpectrallySelectedExcitation",
      "Name" => "Spectrally Selected Excitation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9026",
      "group" => "0018"
    },
    "36903" => {
      "KeyWord" => "SpatialPresaturation",
      "Name" => "Spatial Pre-saturation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9027",
      "group" => "0018"
    },
    "36904" => {
      "KeyWord" => "Tagging",
      "Name" => "Tagging",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9028",
      "group" => "0018"
    },
    "36905" => {
      "KeyWord" => "OversamplingPhase",
      "Name" => "Oversampling Phase",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9029",
      "group" => "0018"
    },
    "36912" => {
      "KeyWord" => "TagSpacingFirstDimension",
      "Name" => "Tag Spacing First Dimension",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9030",
      "group" => "0018"
    },
    "36914" => {
      "KeyWord" => "GeometryOfKSpaceTraversal",
      "Name" => "Geometry of k-Space Traversal",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9032",
      "group" => "0018"
    },
    "36915" => {
      "KeyWord" => "SegmentedKSpaceTraversal",
      "Name" => "Segmented k-Space Traversal",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9033",
      "group" => "0018"
    },
    "36916" => {
      "KeyWord" => "RectilinearPhaseEncodeReordering",
      "Name" => "Rectilinear Phase Encode Reordering",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9034",
      "group" => "0018"
    },
    "36917" => {
      "KeyWord" => "TagThickness",
      "Name" => "Tag Thickness",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9035",
      "group" => "0018"
    },
    "36918" => {
      "KeyWord" => "PartialFourierDirection",
      "Name" => "Partial Fourier Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9036",
      "group" => "0018"
    },
    "36919" => {
      "KeyWord" => "CardiacSynchronizationTechnique",
      "Name" => "Cardiac Synchronization Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9037",
      "group" => "0018"
    },
    "36929" => {
      "KeyWord" => "ReceiveCoilManufacturerName",
      "Name" => "Receive Coil Manufacturer Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9041",
      "group" => "0018"
    },
    "36930" => {
      "KeyWord" => "MRReceiveCoilSequence",
      "Name" => "MR Receive Coil Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9042",
      "group" => "0018"
    },
    "36931" => {
      "KeyWord" => "ReceiveCoilType",
      "Name" => "Receive Coil Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9043",
      "group" => "0018"
    },
    "36932" => {
      "KeyWord" => "QuadratureReceiveCoil",
      "Name" => "Quadrature Receive Coil",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9044",
      "group" => "0018"
    },
    "36933" => {
      "KeyWord" => "MultiCoilDefinitionSequence",
      "Name" => "Multi-Coil Definition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9045",
      "group" => "0018"
    },
    "36934" => {
      "KeyWord" => "MultiCoilConfiguration",
      "Name" => "Multi-Coil Configuration",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9046",
      "group" => "0018"
    },
    "36935" => {
      "KeyWord" => "MultiCoilElementName",
      "Name" => "Multi-Coil Element Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "9047",
      "group" => "0018"
    },
    "36936" => {
      "KeyWord" => "MultiCoilElementUsed",
      "Name" => "Multi-Coil Element Used",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9048",
      "group" => "0018"
    },
    "36937" => {
      "KeyWord" => "MRTransmitCoilSequence",
      "Name" => "MR Transmit Coil Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9049",
      "group" => "0018"
    },
    "36944" => {
      "KeyWord" => "TransmitCoilManufacturerName",
      "Name" => "Transmit Coil Manufacturer Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9050",
      "group" => "0018"
    },
    "36945" => {
      "KeyWord" => "TransmitCoilType",
      "Name" => "Transmit Coil Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9051",
      "group" => "0018"
    },
    "36946" => {
      "KeyWord" => "SpectralWidth",
      "Name" => "Spectral Width",
      "VM" => "1-2",
      "VR" => "FD",
      "ele" => "9052",
      "group" => "0018"
    },
    "36947" => {
      "KeyWord" => "ChemicalShiftReference",
      "Name" => "Chemical Shift Reference",
      "VM" => "1-2",
      "VR" => "FD",
      "ele" => "9053",
      "group" => "0018"
    },
    "36948" => {
      "KeyWord" => "VolumeLocalizationTechnique",
      "Name" => "Volume Localization Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9054",
      "group" => "0018"
    },
    "36952" => {
      "KeyWord" => "MRAcquisitionFrequencyEncodingSteps",
      "Name" => "MR Acquisition Frequency Encoding Steps",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9058",
      "group" => "0018"
    },
    "36953" => {
      "KeyWord" => "Decoupling",
      "Name" => "De-coupling",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9059",
      "group" => "0018"
    },
    "36960" => {
      "KeyWord" => "DecoupledNucleus",
      "Name" => "De-coupled Nucleus",
      "VM" => "1-2",
      "VR" => "CS",
      "ele" => "9060",
      "group" => "0018"
    },
    "36961" => {
      "KeyWord" => "DecouplingFrequency",
      "Name" => "De-coupling Frequency",
      "VM" => "1-2",
      "VR" => "FD",
      "ele" => "9061",
      "group" => "0018"
    },
    "36962" => {
      "KeyWord" => "DecouplingMethod",
      "Name" => "De-coupling Method",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9062",
      "group" => "0018"
    },
    "36963" => {
      "KeyWord" => "DecouplingChemicalShiftReference",
      "Name" => "De-coupling Chemical Shift Reference",
      "VM" => "1-2",
      "VR" => "FD",
      "ele" => "9063",
      "group" => "0018"
    },
    "36964" => {
      "KeyWord" => "KSpaceFiltering",
      "Name" => "k-space Filtering",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9064",
      "group" => "0018"
    },
    "36965" => {
      "KeyWord" => "TimeDomainFiltering",
      "Name" => "Time Domain Filtering",
      "VM" => "1-2",
      "VR" => "CS",
      "ele" => "9065",
      "group" => "0018"
    },
    "36966" => {
      "KeyWord" => "NumberOfZeroFills",
      "Name" => "Number of Zero Fills",
      "VM" => "1-2",
      "VR" => "US",
      "ele" => "9066",
      "group" => "0018"
    },
    "36967" => {
      "KeyWord" => "BaselineCorrection",
      "Name" => "Baseline Correction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9067",
      "group" => "0018"
    },
    "36969" => {
      "KeyWord" => "ParallelReductionFactorInPlane",
      "Name" => "Parallel Reduction Factor In-plane",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9069",
      "group" => "0018"
    },
    "36976" => {
      "KeyWord" => "CardiacRRIntervalSpecified",
      "Name" => "Cardiac R-R Interval Specified",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9070",
      "group" => "0018"
    },
    "36979" => {
      "KeyWord" => "AcquisitionDuration",
      "Name" => "Acquisition Duration",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9073",
      "group" => "0018"
    },
    "36980" => {
      "KeyWord" => "FrameAcquisitionDateTime",
      "Name" => "Frame Acquisition DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "9074",
      "group" => "0018"
    },
    "36981" => {
      "KeyWord" => "DiffusionDirectionality",
      "Name" => "Diffusion Directionality",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9075",
      "group" => "0018"
    },
    "36982" => {
      "KeyWord" => "DiffusionGradientDirectionSequence",
      "Name" => "Diffusion Gradient Direction Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9076",
      "group" => "0018"
    },
    "36983" => {
      "KeyWord" => "ParallelAcquisition",
      "Name" => "Parallel Acquisition",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9077",
      "group" => "0018"
    },
    "36984" => {
      "KeyWord" => "ParallelAcquisitionTechnique",
      "Name" => "Parallel Acquisition Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9078",
      "group" => "0018"
    },
    "36985" => {
      "KeyWord" => "InversionTimes",
      "Name" => "Inversion Times",
      "VM" => "1-n",
      "VR" => "FD",
      "ele" => "9079",
      "group" => "0018"
    },
    "36992" => {
      "KeyWord" => "MetaboliteMapDescription",
      "Name" => "Metabolite Map Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "9080",
      "group" => "0018"
    },
    "36993" => {
      "KeyWord" => "PartialFourier",
      "Name" => "Partial Fourier",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9081",
      "group" => "0018"
    },
    "36994" => {
      "KeyWord" => "EffectiveEchoTime",
      "Name" => "Effective Echo Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9082",
      "group" => "0018"
    },
    "36995" => {
      "KeyWord" => "MetaboliteMapCodeSequence",
      "Name" => "Metabolite Map Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9083",
      "group" => "0018"
    },
    "36996" => {
      "KeyWord" => "ChemicalShiftSequence",
      "Name" => "Chemical Shift Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9084",
      "group" => "0018"
    },
    "36997" => {
      "KeyWord" => "CardiacSignalSource",
      "Name" => "Cardiac Signal Source",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9085",
      "group" => "0018"
    },
    "36999" => {
      "KeyWord" => "DiffusionBValue",
      "Name" => "Diffusion b-value",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9087",
      "group" => "0018"
    },
    "37" => {
      "KeyWord" => "AngioFlag",
      "Name" => "Angio Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0025",
      "group" => "0018"
    },
    "37001" => {
      "KeyWord" => "DiffusionGradientOrientation",
      "Name" => "Diffusion Gradient Orientation",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9089",
      "group" => "0018"
    },
    "37008" => {
      "KeyWord" => "VelocityEncodingDirection",
      "Name" => "Velocity Encoding Direction",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9090",
      "group" => "0018"
    },
    "37009" => {
      "KeyWord" => "VelocityEncodingMinimumValue",
      "Name" => "Velocity Encoding Minimum Value",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9091",
      "group" => "0018"
    },
    "37010" => {
      "KeyWord" => "VelocityEncodingAcquisitionSequence",
      "Name" => "Velocity Encoding Acquisition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9092",
      "group" => "0018"
    },
    "37011" => {
      "KeyWord" => "NumberOfKSpaceTrajectories",
      "Name" => "Number of k-Space Trajectories",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9093",
      "group" => "0018"
    },
    "37012" => {
      "KeyWord" => "CoverageOfKSpace",
      "Name" => "Coverage of k-Space",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9094",
      "group" => "0018"
    },
    "37013" => {
      "KeyWord" => "SpectroscopyAcquisitionPhaseRows",
      "Name" => "Spectroscopy Acquisition Phase Rows",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9095",
      "group" => "0018"
    },
    "37014" => {
      "KeyWord" => "ParallelReductionFactorInPlaneRetired",
      "Name" => "Parallel Reduction Factor In-plane (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9096",
      "group" => "0018"
    },
    "37016" => {
      "KeyWord" => "TransmitterFrequency",
      "Name" => "Transmitter Frequency",
      "VM" => "1-2",
      "VR" => "FD",
      "ele" => "9098",
      "group" => "0018"
    },
    "37120" => {
      "KeyWord" => "ResonantNucleus",
      "Name" => "Resonant Nucleus",
      "VM" => "1-2",
      "VR" => "CS",
      "ele" => "9100",
      "group" => "0018"
    },
    "37121" => {
      "KeyWord" => "FrequencyCorrection",
      "Name" => "Frequency Correction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9101",
      "group" => "0018"
    },
    "37123" => {
      "KeyWord" => "MRSpectroscopyFOVGeometrySequence",
      "Name" => "MR Spectroscopy FOV/Geometry Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9103",
      "group" => "0018"
    },
    "37124" => {
      "KeyWord" => "SlabThickness",
      "Name" => "Slab Thickness",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9104",
      "group" => "0018"
    },
    "37125" => {
      "KeyWord" => "SlabOrientation",
      "Name" => "Slab Orientation",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9105",
      "group" => "0018"
    },
    "37126" => {
      "KeyWord" => "MidSlabPosition",
      "Name" => "Mid Slab Position",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9106",
      "group" => "0018"
    },
    "37127" => {
      "KeyWord" => "MRSpatialSaturationSequence",
      "Name" => "MR Spatial Saturation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9107",
      "group" => "0018"
    },
    "37138" => {
      "KeyWord" => "MRTimingAndRelatedParametersSequence",
      "Name" => "MR Timing and Related Parameters Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9112",
      "group" => "0018"
    },
    "37140" => {
      "KeyWord" => "MREchoSequence",
      "Name" => "MR Echo Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9114",
      "group" => "0018"
    },
    "37141" => {
      "KeyWord" => "MRModifierSequence",
      "Name" => "MR Modifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9115",
      "group" => "0018"
    },
    "37143" => {
      "KeyWord" => "MRDiffusionSequence",
      "Name" => "MR Diffusion Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9117",
      "group" => "0018"
    },
    "37144" => {
      "KeyWord" => "CardiacSynchronizationSequence",
      "Name" => "Cardiac Synchronization Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9118",
      "group" => "0018"
    },
    "37145" => {
      "KeyWord" => "MRAveragesSequence",
      "Name" => "MR Averages Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9119",
      "group" => "0018"
    },
    "37157" => {
      "KeyWord" => "MRFOVGeometrySequence",
      "Name" => "MR FOV/Geometry Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9125",
      "group" => "0018"
    },
    "37158" => {
      "KeyWord" => "VolumeLocalizationSequence",
      "Name" => "Volume Localization Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9126",
      "group" => "0018"
    },
    "37159" => {
      "KeyWord" => "SpectroscopyAcquisitionDataColumns",
      "Name" => "Spectroscopy Acquisition Data Columns",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9127",
      "group" => "0018"
    },
    "37191" => {
      "KeyWord" => "DiffusionAnisotropyType",
      "Name" => "Diffusion Anisotropy Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9147",
      "group" => "0018"
    },
    "37201" => {
      "KeyWord" => "FrameReferenceDateTime",
      "Name" => "Frame Reference DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "9151",
      "group" => "0018"
    },
    "37202" => {
      "KeyWord" => "MRMetaboliteMapSequence",
      "Name" => "MR Metabolite Map Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9152",
      "group" => "0018"
    },
    "37205" => {
      "KeyWord" => "ParallelReductionFactorOutOfPlane",
      "Name" => "Parallel Reduction Factor out-of-plane",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9155",
      "group" => "0018"
    },
    "37209" => {
      "KeyWord" => "SpectroscopyAcquisitionOutOfPlanePhaseSteps",
      "Name" => "Spectroscopy Acquisition Out-of-plane Phase Steps",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9159",
      "group" => "0018"
    },
    "37222" => {
      "KeyWord" => "BulkMotionStatus",
      "Name" => "Bulk Motion Status",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9166",
      "group" => "0018"
    },
    "37224" => {
      "KeyWord" => "ParallelReductionFactorSecondInPlane",
      "Name" => "Parallel Reduction Factor Second In-plane",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9168",
      "group" => "0018"
    },
    "37225" => {
      "KeyWord" => "CardiacBeatRejectionTechnique",
      "Name" => "Cardiac Beat Rejection Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9169",
      "group" => "0018"
    },
    "37232" => {
      "KeyWord" => "RespiratoryMotionCompensationTechnique",
      "Name" => "Respiratory Motion Compensation Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9170",
      "group" => "0018"
    },
    "37233" => {
      "KeyWord" => "RespiratorySignalSource",
      "Name" => "Respiratory Signal Source",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9171",
      "group" => "0018"
    },
    "37234" => {
      "KeyWord" => "BulkMotionCompensationTechnique",
      "Name" => "Bulk Motion Compensation Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9172",
      "group" => "0018"
    },
    "37235" => {
      "KeyWord" => "BulkMotionSignalSource",
      "Name" => "Bulk Motion Signal Source",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9173",
      "group" => "0018"
    },
    "37236" => {
      "KeyWord" => "ApplicableSafetyStandardAgency",
      "Name" => "Applicable Safety Standard Agency",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9174",
      "group" => "0018"
    },
    "37237" => {
      "KeyWord" => "ApplicableSafetyStandardDescription",
      "Name" => "Applicable Safety Standard Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9175",
      "group" => "0018"
    },
    "37238" => {
      "KeyWord" => "OperatingModeSequence",
      "Name" => "Operating Mode Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9176",
      "group" => "0018"
    },
    "37239" => {
      "KeyWord" => "OperatingModeType",
      "Name" => "Operating Mode Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9177",
      "group" => "0018"
    },
    "37240" => {
      "KeyWord" => "OperatingMode",
      "Name" => "Operating Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9178",
      "group" => "0018"
    },
    "37241" => {
      "KeyWord" => "SpecificAbsorptionRateDefinition",
      "Name" => "Specific Absorption Rate Definition",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9179",
      "group" => "0018"
    },
    "37248" => {
      "KeyWord" => "GradientOutputType",
      "Name" => "Gradient Output Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9180",
      "group" => "0018"
    },
    "37249" => {
      "KeyWord" => "SpecificAbsorptionRateValue",
      "Name" => "Specific Absorption Rate Value",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9181",
      "group" => "0018"
    },
    "37250" => {
      "KeyWord" => "GradientOutput",
      "Name" => "Gradient Output",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9182",
      "group" => "0018"
    },
    "37251" => {
      "KeyWord" => "FlowCompensationDirection",
      "Name" => "Flow Compensation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9183",
      "group" => "0018"
    },
    "37252" => {
      "KeyWord" => "TaggingDelay",
      "Name" => "Tagging Delay",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9184",
      "group" => "0018"
    },
    "37253" => {
      "KeyWord" => "RespiratoryMotionCompensationTechniqueDescription",
      "Name" => "Respiratory Motion Compensation Technique Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "9185",
      "group" => "0018"
    },
    "37254" => {
      "KeyWord" => "RespiratorySignalSourceID",
      "Name" => "Respiratory Signal Source ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "9186",
      "group" => "0018"
    },
    "37269" => {
      "KeyWord" => "ChemicalShiftMinimumIntegrationLimitInHz",
      "Name" => "Chemical Shift Minimum Integration Limit in Hz",
      "RET" => "1",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9195",
      "group" => "0018"
    },
    "37270" => {
      "KeyWord" => "ChemicalShiftMaximumIntegrationLimitInHz",
      "Name" => "Chemical Shift Maximum Integration Limit in Hz",
      "RET" => "1",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9196",
      "group" => "0018"
    },
    "37271" => {
      "KeyWord" => "MRVelocityEncodingSequence",
      "Name" => "MR Velocity Encoding Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9197",
      "group" => "0018"
    },
    "37272" => {
      "KeyWord" => "FirstOrderPhaseCorrection",
      "Name" => "First Order Phase Correction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9198",
      "group" => "0018"
    },
    "37273" => {
      "KeyWord" => "WaterReferencedPhaseCorrection",
      "Name" => "Water Referenced Phase Correction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9199",
      "group" => "0018"
    },
    "37376" => {
      "KeyWord" => "MRSpectroscopyAcquisitionType",
      "Name" => "MR Spectroscopy Acquisition Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9200",
      "group" => "0018"
    },
    "37396" => {
      "KeyWord" => "RespiratoryCyclePosition",
      "Name" => "Respiratory Cycle Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9214",
      "group" => "0018"
    },
    "37399" => {
      "KeyWord" => "VelocityEncodingMaximumValue",
      "Name" => "Velocity Encoding Maximum Value",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9217",
      "group" => "0018"
    },
    "37400" => {
      "KeyWord" => "TagSpacingSecondDimension",
      "Name" => "Tag Spacing Second Dimension",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9218",
      "group" => "0018"
    },
    "37401" => {
      "KeyWord" => "TagAngleSecondAxis",
      "Name" => "Tag Angle Second Axis",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "9219",
      "group" => "0018"
    },
    "37408" => {
      "KeyWord" => "FrameAcquisitionDuration",
      "Name" => "Frame Acquisition Duration",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9220",
      "group" => "0018"
    },
    "37414" => {
      "KeyWord" => "MRImageFrameTypeSequence",
      "Name" => "MR Image Frame Type Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9226",
      "group" => "0018"
    },
    "37415" => {
      "KeyWord" => "MRSpectroscopyFrameTypeSequence",
      "Name" => "MR Spectroscopy Frame Type Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9227",
      "group" => "0018"
    },
    "37425" => {
      "KeyWord" => "MRAcquisitionPhaseEncodingStepsInPlane",
      "Name" => "MR Acquisition Phase Encoding Steps in-plane",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9231",
      "group" => "0018"
    },
    "37426" => {
      "KeyWord" => "MRAcquisitionPhaseEncodingStepsOutOfPlane",
      "Name" => "MR Acquisition Phase Encoding Steps out-of-plane",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9232",
      "group" => "0018"
    },
    "37428" => {
      "KeyWord" => "SpectroscopyAcquisitionPhaseColumns",
      "Name" => "Spectroscopy Acquisition Phase Columns",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9234",
      "group" => "0018"
    },
    "37430" => {
      "KeyWord" => "CardiacCyclePosition",
      "Name" => "Cardiac Cycle Position",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9236",
      "group" => "0018"
    },
    "37433" => {
      "KeyWord" => "SpecificAbsorptionRateSequence",
      "Name" => "Specific Absorption Rate Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9239",
      "group" => "0018"
    },
    "37440" => {
      "KeyWord" => "RFEchoTrainLength",
      "Name" => "RF Echo Train Length",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9240",
      "group" => "0018"
    },
    "37441" => {
      "KeyWord" => "GradientEchoTrainLength",
      "Name" => "Gradient Echo Train Length",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9241",
      "group" => "0018"
    },
    "37456" => {
      "KeyWord" => "ArterialSpinLabelingContrast",
      "Name" => "Arterial Spin Labeling Contrast",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9250",
      "group" => "0018"
    },
    "37457" => {
      "KeyWord" => "MRArterialSpinLabelingSequence",
      "Name" => "MR Arterial Spin Labeling Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9251",
      "group" => "0018"
    },
    "37458" => {
      "KeyWord" => "ASLTechniqueDescription",
      "Name" => "ASL Technique Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9252",
      "group" => "0018"
    },
    "37459" => {
      "KeyWord" => "ASLSlabNumber",
      "Name" => "ASL Slab Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9253",
      "group" => "0018"
    },
    "37460" => {
      "KeyWord" => "ASLSlabThickness",
      "Name" => "ASL Slab Thickness",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9254",
      "group" => "0018"
    },
    "37461" => {
      "KeyWord" => "ASLSlabOrientation",
      "Name" => "ASL Slab Orientation",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9255",
      "group" => "0018"
    },
    "37462" => {
      "KeyWord" => "ASLMidSlabPosition",
      "Name" => "ASL Mid Slab Position",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9256",
      "group" => "0018"
    },
    "37463" => {
      "KeyWord" => "ASLContext",
      "Name" => "ASL Context",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9257",
      "group" => "0018"
    },
    "37464" => {
      "KeyWord" => "ASLPulseTrainDuration",
      "Name" => "ASL Pulse Train Duration",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9258",
      "group" => "0018"
    },
    "37465" => {
      "KeyWord" => "ASLCrusherFlag",
      "Name" => "ASL Crusher Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9259",
      "group" => "0018"
    },
    "37466" => {
      "KeyWord" => "ASLCrusherFlowLimit",
      "Name" => "ASL Crusher Flow Limit",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "925a",
      "group" => "0018"
    },
    "37467" => {
      "KeyWord" => "ASLCrusherDescription",
      "Name" => "ASL Crusher Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "925b",
      "group" => "0018"
    },
    "37468" => {
      "KeyWord" => "ASLBolusCutoffFlag",
      "Name" => "ASL Bolus Cut-off Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "925c",
      "group" => "0018"
    },
    "37469" => {
      "KeyWord" => "ASLBolusCutoffTimingSequence",
      "Name" => "ASL Bolus Cut-off Timing Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "925d",
      "group" => "0018"
    },
    "37470" => {
      "KeyWord" => "ASLBolusCutoffTechnique",
      "Name" => "ASL Bolus Cut-off Technique",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "925e",
      "group" => "0018"
    },
    "37471" => {
      "KeyWord" => "ASLBolusCutoffDelayTime",
      "Name" => "ASL Bolus Cut-off Delay Time",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "925f",
      "group" => "0018"
    },
    "37472" => {
      "KeyWord" => "ASLSlabSequence",
      "Name" => "ASL Slab Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9260",
      "group" => "0018"
    },
    "37525" => {
      "KeyWord" => "ChemicalShiftMinimumIntegrationLimitInppm",
      "Name" => "Chemical Shift Minimum Integration Limit in ppm",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9295",
      "group" => "0018"
    },
    "37526" => {
      "KeyWord" => "ChemicalShiftMaximumIntegrationLimitInppm",
      "Name" => "Chemical Shift Maximum Integration Limit in ppm",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9296",
      "group" => "0018"
    },
    "37633" => {
      "KeyWord" => "CTAcquisitionTypeSequence",
      "Name" => "CT Acquisition Type Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9301",
      "group" => "0018"
    },
    "37634" => {
      "KeyWord" => "AcquisitionType",
      "Name" => "Acquisition Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9302",
      "group" => "0018"
    },
    "37635" => {
      "KeyWord" => "TubeAngle",
      "Name" => "Tube Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9303",
      "group" => "0018"
    },
    "37636" => {
      "KeyWord" => "CTAcquisitionDetailsSequence",
      "Name" => "CT Acquisition Details Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9304",
      "group" => "0018"
    },
    "37637" => {
      "KeyWord" => "RevolutionTime",
      "Name" => "Revolution Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9305",
      "group" => "0018"
    },
    "37638" => {
      "KeyWord" => "SingleCollimationWidth",
      "Name" => "Single Collimation Width",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9306",
      "group" => "0018"
    },
    "37639" => {
      "KeyWord" => "TotalCollimationWidth",
      "Name" => "Total Collimation Width",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9307",
      "group" => "0018"
    },
    "37640" => {
      "KeyWord" => "CTTableDynamicsSequence",
      "Name" => "CT Table Dynamics Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9308",
      "group" => "0018"
    },
    "37641" => {
      "KeyWord" => "TableSpeed",
      "Name" => "Table Speed",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9309",
      "group" => "0018"
    },
    "37648" => {
      "KeyWord" => "TableFeedPerRotation",
      "Name" => "Table Feed per Rotation",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9310",
      "group" => "0018"
    },
    "37649" => {
      "KeyWord" => "SpiralPitchFactor",
      "Name" => "Spiral Pitch Factor",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9311",
      "group" => "0018"
    },
    "37650" => {
      "KeyWord" => "CTGeometrySequence",
      "Name" => "CT Geometry Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9312",
      "group" => "0018"
    },
    "37651" => {
      "KeyWord" => "DataCollectionCenterPatient",
      "Name" => "Data Collection Center (Patient)",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9313",
      "group" => "0018"
    },
    "37652" => {
      "KeyWord" => "CTReconstructionSequence",
      "Name" => "CT Reconstruction Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9314",
      "group" => "0018"
    },
    "37653" => {
      "KeyWord" => "ReconstructionAlgorithm",
      "Name" => "Reconstruction Algorithm",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9315",
      "group" => "0018"
    },
    "37654" => {
      "KeyWord" => "ConvolutionKernelGroup",
      "Name" => "Convolution Kernel Group",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9316",
      "group" => "0018"
    },
    "37655" => {
      "KeyWord" => "ReconstructionFieldOfView",
      "Name" => "Reconstruction Field of View",
      "VM" => "2",
      "VR" => "FD",
      "ele" => "9317",
      "group" => "0018"
    },
    "37656" => {
      "KeyWord" => "ReconstructionTargetCenterPatient",
      "Name" => "Reconstruction Target Center (Patient)",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9318",
      "group" => "0018"
    },
    "37657" => {
      "KeyWord" => "ReconstructionAngle",
      "Name" => "Reconstruction Angle",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9319",
      "group" => "0018"
    },
    "37664" => {
      "KeyWord" => "ImageFilter",
      "Name" => "Image Filter",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "9320",
      "group" => "0018"
    },
    "37665" => {
      "KeyWord" => "CTExposureSequence",
      "Name" => "CT Exposure Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9321",
      "group" => "0018"
    },
    "37666" => {
      "KeyWord" => "ReconstructionPixelSpacing",
      "Name" => "Reconstruction Pixel Spacing",
      "VM" => "2",
      "VR" => "FD",
      "ele" => "9322",
      "group" => "0018"
    },
    "37667" => {
      "KeyWord" => "ExposureModulationType",
      "Name" => "Exposure Modulation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9323",
      "group" => "0018"
    },
    "37668" => {
      "KeyWord" => "EstimatedDoseSaving",
      "Name" => "Estimated Dose Saving",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9324",
      "group" => "0018"
    },
    "37669" => {
      "KeyWord" => "CTXRayDetailsSequence",
      "Name" => "CT X-Ray Details Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9325",
      "group" => "0018"
    },
    "37670" => {
      "KeyWord" => "CTPositionSequence",
      "Name" => "CT Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9326",
      "group" => "0018"
    },
    "37671" => {
      "KeyWord" => "TablePosition",
      "Name" => "Table Position",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9327",
      "group" => "0018"
    },
    "37672" => {
      "KeyWord" => "ExposureTimeInms",
      "Name" => "Exposure Time in ms",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9328",
      "group" => "0018"
    },
    "37673" => {
      "KeyWord" => "CTImageFrameTypeSequence",
      "Name" => "CT Image Frame Type Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9329",
      "group" => "0018"
    },
    "37680" => {
      "KeyWord" => "XRayTubeCurrentInmA",
      "Name" => "X-Ray Tube Current in mA",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9330",
      "group" => "0018"
    },
    "37682" => {
      "KeyWord" => "ExposureInmAs",
      "Name" => "Exposure in mAs",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9332",
      "group" => "0018"
    },
    "37683" => {
      "KeyWord" => "ConstantVolumeFlag",
      "Name" => "Constant Volume Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9333",
      "group" => "0018"
    },
    "37684" => {
      "KeyWord" => "FluoroscopyFlag",
      "Name" => "Fluoroscopy Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9334",
      "group" => "0018"
    },
    "37685" => {
      "KeyWord" => "DistanceSourceToDataCollectionCenter",
      "Name" => "Distance Source to Data Collection Center",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9335",
      "group" => "0018"
    },
    "37687" => {
      "KeyWord" => "ContrastBolusAgentNumber",
      "Name" => "Contrast/Bolus Agent Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9337",
      "group" => "0018"
    },
    "37688" => {
      "KeyWord" => "ContrastBolusIngredientCodeSequence",
      "Name" => "Contrast/Bolus Ingredient Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9338",
      "group" => "0018"
    },
    "37696" => {
      "KeyWord" => "ContrastAdministrationProfileSequence",
      "Name" => "Contrast Administration Profile Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9340",
      "group" => "0018"
    },
    "37697" => {
      "KeyWord" => "ContrastBolusUsageSequence",
      "Name" => "Contrast/Bolus Usage Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9341",
      "group" => "0018"
    },
    "37698" => {
      "KeyWord" => "ContrastBolusAgentAdministered",
      "Name" => "Contrast/Bolus Agent Administered",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9342",
      "group" => "0018"
    },
    "37699" => {
      "KeyWord" => "ContrastBolusAgentDetected",
      "Name" => "Contrast/Bolus Agent Detected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9343",
      "group" => "0018"
    },
    "37700" => {
      "KeyWord" => "ContrastBolusAgentPhase",
      "Name" => "Contrast/Bolus Agent Phase",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9344",
      "group" => "0018"
    },
    "37701" => {
      "KeyWord" => "CTDIvol",
      "Name" => "CTDIvol",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9345",
      "group" => "0018"
    },
    "37702" => {
      "KeyWord" => "CTDIPhantomTypeCodeSequence",
      "Name" => "CTDI Phantom Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9346",
      "group" => "0018"
    },
    "37713" => {
      "KeyWord" => "CalciumScoringMassFactorPatient",
      "Name" => "Calcium Scoring Mass Factor Patient",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9351",
      "group" => "0018"
    },
    "37714" => {
      "KeyWord" => "CalciumScoringMassFactorDevice",
      "Name" => "Calcium Scoring Mass Factor Device",
      "VM" => "3",
      "VR" => "FL",
      "ele" => "9352",
      "group" => "0018"
    },
    "37715" => {
      "KeyWord" => "EnergyWeightingFactor",
      "Name" => "Energy Weighting Factor",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9353",
      "group" => "0018"
    },
    "37728" => {
      "KeyWord" => "CTAdditionalXRaySourceSequence",
      "Name" => "CT Additional X-Ray Source Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9360",
      "group" => "0018"
    },
    "37889" => {
      "KeyWord" => "ProjectionPixelCalibrationSequence",
      "Name" => "Projection Pixel Calibration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9401",
      "group" => "0018"
    },
    "37890" => {
      "KeyWord" => "DistanceSourceToIsocenter",
      "Name" => "Distance Source to Isocenter",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9402",
      "group" => "0018"
    },
    "37891" => {
      "KeyWord" => "DistanceObjectToTableTop",
      "Name" => "Distance Object to Table Top",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9403",
      "group" => "0018"
    },
    "37892" => {
      "KeyWord" => "ObjectPixelSpacingInCenterOfBeam",
      "Name" => "Object Pixel Spacing in Center of Beam",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "9404",
      "group" => "0018"
    },
    "37893" => {
      "KeyWord" => "PositionerPositionSequence",
      "Name" => "Positioner Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9405",
      "group" => "0018"
    },
    "37894" => {
      "KeyWord" => "TablePositionSequence",
      "Name" => "Table Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9406",
      "group" => "0018"
    },
    "37895" => {
      "KeyWord" => "CollimatorShapeSequence",
      "Name" => "Collimator Shape Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9407",
      "group" => "0018"
    },
    "37904" => {
      "KeyWord" => "PlanesInAcquisition",
      "Name" => "Planes in Acquisition",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9410",
      "group" => "0018"
    },
    "37906" => {
      "KeyWord" => "XAXRFFrameCharacteristicsSequence",
      "Name" => "XA/XRF Frame Characteristics Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9412",
      "group" => "0018"
    },
    "37911" => {
      "KeyWord" => "FrameAcquisitionSequence",
      "Name" => "Frame Acquisition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9417",
      "group" => "0018"
    },
    "37920" => {
      "KeyWord" => "XRayReceptorType",
      "Name" => "X-Ray Receptor Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9420",
      "group" => "0018"
    },
    "37923" => {
      "KeyWord" => "AcquisitionProtocolName",
      "Name" => "Acquisition Protocol Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9423",
      "group" => "0018"
    },
    "37924" => {
      "KeyWord" => "AcquisitionProtocolDescription",
      "Name" => "Acquisition Protocol Description",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "9424",
      "group" => "0018"
    },
    "37925" => {
      "KeyWord" => "ContrastBolusIngredientOpaque",
      "Name" => "Contrast/Bolus Ingredient Opaque",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9425",
      "group" => "0018"
    },
    "37926" => {
      "KeyWord" => "DistanceReceptorPlaneToDetectorHousing",
      "Name" => "Distance Receptor Plane to Detector Housing",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9426",
      "group" => "0018"
    },
    "37927" => {
      "KeyWord" => "IntensifierActiveShape",
      "Name" => "Intensifier Active Shape",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9427",
      "group" => "0018"
    },
    "37928" => {
      "KeyWord" => "IntensifierActiveDimensions",
      "Name" => "Intensifier Active Dimension(s)",
      "VM" => "1-2",
      "VR" => "FL",
      "ele" => "9428",
      "group" => "0018"
    },
    "37929" => {
      "KeyWord" => "PhysicalDetectorSize",
      "Name" => "Physical Detector Size",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "9429",
      "group" => "0018"
    },
    "37936" => {
      "KeyWord" => "PositionOfIsocenterProjection",
      "Name" => "Position of Isocenter Projection",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "9430",
      "group" => "0018"
    },
    "37938" => {
      "KeyWord" => "FieldOfViewSequence",
      "Name" => "Field of View Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9432",
      "group" => "0018"
    },
    "37939" => {
      "KeyWord" => "FieldOfViewDescription",
      "Name" => "Field of View Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9433",
      "group" => "0018"
    },
    "37940" => {
      "KeyWord" => "ExposureControlSensingRegionsSequence",
      "Name" => "Exposure Control Sensing Regions Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9434",
      "group" => "0018"
    },
    "37941" => {
      "KeyWord" => "ExposureControlSensingRegionShape",
      "Name" => "Exposure Control Sensing Region Shape",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9435",
      "group" => "0018"
    },
    "37942" => {
      "KeyWord" => "ExposureControlSensingRegionLeftVerticalEdge",
      "Name" => "Exposure Control Sensing Region Left Vertical Edge",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "9436",
      "group" => "0018"
    },
    "37943" => {
      "KeyWord" => "ExposureControlSensingRegionRightVerticalEdge",
      "Name" => "Exposure Control Sensing Region Right Vertical Edge",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "9437",
      "group" => "0018"
    },
    "37944" => {
      "KeyWord" => "ExposureControlSensingRegionUpperHorizontalEdge",
      "Name" => "Exposure Control Sensing Region Upper Horizontal Edge",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "9438",
      "group" => "0018"
    },
    "37945" => {
      "KeyWord" => "ExposureControlSensingRegionLowerHorizontalEdge",
      "Name" => "Exposure Control Sensing Region Lower Horizontal Edge",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "9439",
      "group" => "0018"
    },
    "37952" => {
      "KeyWord" => "CenterOfCircularExposureControlSensingRegion",
      "Name" => "Center of Circular Exposure Control Sensing Region",
      "VM" => "2",
      "VR" => "SS",
      "ele" => "9440",
      "group" => "0018"
    },
    "37953" => {
      "KeyWord" => "RadiusOfCircularExposureControlSensingRegion",
      "Name" => "Radius of Circular Exposure Control Sensing Region",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9441",
      "group" => "0018"
    },
    "37954" => {
      "KeyWord" => "VerticesOfThePolygonalExposureControlSensingRegion",
      "Name" => "Vertices of the Polygonal Exposure Control Sensing Region",
      "VM" => "2-n",
      "VR" => "SS",
      "ele" => "9442",
      "group" => "0018"
    },
    "37957" => {
      "KeyWord" => "",
      "Name" => "Philips Pirate Element",
      "VM" => "",
      "VR" => "FD",
      "comment" => "RET - See Note",
      "ele" => "9445",
      "group" => "0018"
    },
    "37959" => {
      "KeyWord" => "ColumnAngulationPatient",
      "Name" => "Column Angulation (Patient)",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9447",
      "group" => "0018"
    },
    "37961" => {
      "KeyWord" => "BeamAngle",
      "Name" => "Beam Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9449",
      "group" => "0018"
    },
    "37969" => {
      "KeyWord" => "FrameDetectorParametersSequence",
      "Name" => "Frame Detector Parameters Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9451",
      "group" => "0018"
    },
    "37970" => {
      "KeyWord" => "CalculatedAnatomyThickness",
      "Name" => "Calculated Anatomy Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9452",
      "group" => "0018"
    },
    "37973" => {
      "KeyWord" => "CalibrationSequence",
      "Name" => "Calibration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9455",
      "group" => "0018"
    },
    "37974" => {
      "KeyWord" => "ObjectThicknessSequence",
      "Name" => "Object Thickness Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9456",
      "group" => "0018"
    },
    "37975" => {
      "KeyWord" => "PlaneIdentification",
      "Name" => "Plane Identification",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9457",
      "group" => "0018"
    },
    "37985" => {
      "KeyWord" => "FieldOfViewDimensionsInFloat",
      "Name" => "Field of View Dimension(s) in Float",
      "VM" => "1-2",
      "VR" => "FL",
      "ele" => "9461",
      "group" => "0018"
    },
    "37986" => {
      "KeyWord" => "IsocenterReferenceSystemSequence",
      "Name" => "Isocenter Reference System Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9462",
      "group" => "0018"
    },
    "37987" => {
      "KeyWord" => "PositionerIsocenterPrimaryAngle",
      "Name" => "Positioner Isocenter Primary Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9463",
      "group" => "0018"
    },
    "37988" => {
      "KeyWord" => "PositionerIsocenterSecondaryAngle",
      "Name" => "Positioner Isocenter Secondary Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9464",
      "group" => "0018"
    },
    "37989" => {
      "KeyWord" => "PositionerIsocenterDetectorRotationAngle",
      "Name" => "Positioner Isocenter Detector Rotation Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9465",
      "group" => "0018"
    },
    "37990" => {
      "KeyWord" => "TableXPositionToIsocenter",
      "Name" => "Table X Position to Isocenter",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9466",
      "group" => "0018"
    },
    "37991" => {
      "KeyWord" => "TableYPositionToIsocenter",
      "Name" => "Table Y Position to Isocenter",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9467",
      "group" => "0018"
    },
    "37992" => {
      "KeyWord" => "TableZPositionToIsocenter",
      "Name" => "Table Z Position to Isocenter",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9468",
      "group" => "0018"
    },
    "37993" => {
      "KeyWord" => "TableHorizontalRotationAngle",
      "Name" => "Table Horizontal Rotation Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9469",
      "group" => "0018"
    },
    "38" => {
      "KeyWord" => "InterventionDrugInformationSequence",
      "Name" => "Intervention Drug Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0026",
      "group" => "0018"
    },
    "38000" => {
      "KeyWord" => "TableHeadTiltAngle",
      "Name" => "Table Head Tilt Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9470",
      "group" => "0018"
    },
    "38001" => {
      "KeyWord" => "TableCradleTiltAngle",
      "Name" => "Table Cradle Tilt Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9471",
      "group" => "0018"
    },
    "38002" => {
      "KeyWord" => "FrameDisplayShutterSequence",
      "Name" => "Frame Display Shutter Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9472",
      "group" => "0018"
    },
    "38003" => {
      "KeyWord" => "AcquiredImageAreaDoseProduct",
      "Name" => "Acquired Image Area Dose Product",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9473",
      "group" => "0018"
    },
    "38004" => {
      "KeyWord" => "CArmPositionerTabletopRelationship",
      "Name" => "C-arm Positioner Tabletop Relationship",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9474",
      "group" => "0018"
    },
    "38006" => {
      "KeyWord" => "XRayGeometrySequence",
      "Name" => "X-Ray Geometry Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9476",
      "group" => "0018"
    },
    "38007" => {
      "KeyWord" => "IrradiationEventIdentificationSequence",
      "Name" => "Irradiation Event Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9477",
      "group" => "0018"
    },
    "38148" => {
      "KeyWord" => "XRay3DFrameTypeSequence",
      "Name" => "X-Ray 3D Frame Type Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9504",
      "group" => "0018"
    },
    "38150" => {
      "KeyWord" => "ContributingSourcesSequence",
      "Name" => "Contributing Sources Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9506",
      "group" => "0018"
    },
    "38151" => {
      "KeyWord" => "XRay3DAcquisitionSequence",
      "Name" => "X-Ray 3D Acquisition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9507",
      "group" => "0018"
    },
    "38152" => {
      "KeyWord" => "PrimaryPositionerScanArc",
      "Name" => "Primary Positioner Scan Arc",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9508",
      "group" => "0018"
    },
    "38153" => {
      "KeyWord" => "SecondaryPositionerScanArc",
      "Name" => "Secondary Positioner Scan Arc",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9509",
      "group" => "0018"
    },
    "38160" => {
      "KeyWord" => "PrimaryPositionerScanStartAngle",
      "Name" => "Primary Positioner Scan Start Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9510",
      "group" => "0018"
    },
    "38161" => {
      "KeyWord" => "SecondaryPositionerScanStartAngle",
      "Name" => "Secondary Positioner Scan Start Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9511",
      "group" => "0018"
    },
    "38164" => {
      "KeyWord" => "PrimaryPositionerIncrement",
      "Name" => "Primary Positioner Increment",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9514",
      "group" => "0018"
    },
    "38165" => {
      "KeyWord" => "SecondaryPositionerIncrement",
      "Name" => "Secondary Positioner Increment",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9515",
      "group" => "0018"
    },
    "38166" => {
      "KeyWord" => "StartAcquisitionDateTime",
      "Name" => "Start Acquisition DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "9516",
      "group" => "0018"
    },
    "38167" => {
      "KeyWord" => "EndAcquisitionDateTime",
      "Name" => "End Acquisition DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "9517",
      "group" => "0018"
    },
    "38180" => {
      "KeyWord" => "ApplicationName",
      "Name" => "Application Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9524",
      "group" => "0018"
    },
    "38181" => {
      "KeyWord" => "ApplicationVersion",
      "Name" => "Application Version",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9525",
      "group" => "0018"
    },
    "38182" => {
      "KeyWord" => "ApplicationManufacturer",
      "Name" => "Application Manufacturer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9526",
      "group" => "0018"
    },
    "38183" => {
      "KeyWord" => "AlgorithmType",
      "Name" => "Algorithm Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9527",
      "group" => "0018"
    },
    "38184" => {
      "KeyWord" => "AlgorithmDescription",
      "Name" => "Algorithm Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9528",
      "group" => "0018"
    },
    "38192" => {
      "KeyWord" => "XRay3DReconstructionSequence",
      "Name" => "X-Ray 3D Reconstruction Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9530",
      "group" => "0018"
    },
    "38193" => {
      "KeyWord" => "ReconstructionDescription",
      "Name" => "Reconstruction Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9531",
      "group" => "0018"
    },
    "38200" => {
      "KeyWord" => "PerProjectionAcquisitionSequence",
      "Name" => "Per Projection Acquisition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9538",
      "group" => "0018"
    },
    "38401" => {
      "KeyWord" => "DiffusionBMatrixSequence",
      "Name" => "Diffusion b-matrix Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9601",
      "group" => "0018"
    },
    "38402" => {
      "KeyWord" => "DiffusionBValueXX",
      "Name" => "Diffusion b-value XX",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9602",
      "group" => "0018"
    },
    "38403" => {
      "KeyWord" => "DiffusionBValueXY",
      "Name" => "Diffusion b-value XY",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9603",
      "group" => "0018"
    },
    "38404" => {
      "KeyWord" => "DiffusionBValueXZ",
      "Name" => "Diffusion b-value XZ",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9604",
      "group" => "0018"
    },
    "38405" => {
      "KeyWord" => "DiffusionBValueYY",
      "Name" => "Diffusion b-value YY",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9605",
      "group" => "0018"
    },
    "38406" => {
      "KeyWord" => "DiffusionBValueYZ",
      "Name" => "Diffusion b-value YZ",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9606",
      "group" => "0018"
    },
    "38407" => {
      "KeyWord" => "DiffusionBValueZZ",
      "Name" => "Diffusion b-value ZZ",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9607",
      "group" => "0018"
    },
    "38657" => {
      "KeyWord" => "DecayCorrectionDateTime",
      "Name" => "Decay Correction DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "9701",
      "group" => "0018"
    },
    "38677" => {
      "KeyWord" => "StartDensityThreshold",
      "Name" => "Start Density Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9715",
      "group" => "0018"
    },
    "38678" => {
      "KeyWord" => "StartRelativeDensityDifferenceThreshold",
      "Name" => "Start Relative Density Difference Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9716",
      "group" => "0018"
    },
    "38679" => {
      "KeyWord" => "StartCardiacTriggerCountThreshold",
      "Name" => "Start Cardiac Trigger Count Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9717",
      "group" => "0018"
    },
    "38680" => {
      "KeyWord" => "StartRespiratoryTriggerCountThreshold",
      "Name" => "Start Respiratory Trigger Count Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9718",
      "group" => "0018"
    },
    "38681" => {
      "KeyWord" => "TerminationCountsThreshold",
      "Name" => "Termination Counts Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9719",
      "group" => "0018"
    },
    "38688" => {
      "KeyWord" => "TerminationDensityThreshold",
      "Name" => "Termination Density Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9720",
      "group" => "0018"
    },
    "38689" => {
      "KeyWord" => "TerminationRelativeDensityThreshold",
      "Name" => "Termination Relative Density Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9721",
      "group" => "0018"
    },
    "38690" => {
      "KeyWord" => "TerminationTimeThreshold",
      "Name" => "Termination Time Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9722",
      "group" => "0018"
    },
    "38691" => {
      "KeyWord" => "TerminationCardiacTriggerCountThreshold",
      "Name" => "Termination Cardiac Trigger Count Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9723",
      "group" => "0018"
    },
    "38692" => {
      "KeyWord" => "TerminationRespiratoryTriggerCountThreshold",
      "Name" => "Termination Respiratory Trigger Count Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9724",
      "group" => "0018"
    },
    "38693" => {
      "KeyWord" => "DetectorGeometry",
      "Name" => "Detector Geometry",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9725",
      "group" => "0018"
    },
    "38694" => {
      "KeyWord" => "TransverseDetectorSeparation",
      "Name" => "Transverse Detector Separation",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9726",
      "group" => "0018"
    },
    "38695" => {
      "KeyWord" => "AxialDetectorDimension",
      "Name" => "Axial Detector Dimension",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9727",
      "group" => "0018"
    },
    "38697" => {
      "KeyWord" => "RadiopharmaceuticalAgentNumber",
      "Name" => "Radiopharmaceutical Agent Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9729",
      "group" => "0018"
    },
    "38706" => {
      "KeyWord" => "PETFrameAcquisitionSequence",
      "Name" => "PET Frame Acquisition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9732",
      "group" => "0018"
    },
    "38707" => {
      "KeyWord" => "PETDetectorMotionDetailsSequence",
      "Name" => "PET Detector Motion Details Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9733",
      "group" => "0018"
    },
    "38708" => {
      "KeyWord" => "PETTableDynamicsSequence",
      "Name" => "PET Table Dynamics Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9734",
      "group" => "0018"
    },
    "38709" => {
      "KeyWord" => "PETPositionSequence",
      "Name" => "PET Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9735",
      "group" => "0018"
    },
    "38710" => {
      "KeyWord" => "PETFrameCorrectionFactorsSequence",
      "Name" => "PET Frame Correction Factors Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9736",
      "group" => "0018"
    },
    "38711" => {
      "KeyWord" => "RadiopharmaceuticalUsageSequence",
      "Name" => "Radiopharmaceutical Usage Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9737",
      "group" => "0018"
    },
    "38712" => {
      "KeyWord" => "AttenuationCorrectionSource",
      "Name" => "Attenuation Correction Source",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9738",
      "group" => "0018"
    },
    "38713" => {
      "KeyWord" => "NumberOfIterations",
      "Name" => "Number of Iterations",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9739",
      "group" => "0018"
    },
    "38720" => {
      "KeyWord" => "NumberOfSubsets",
      "Name" => "Number of Subsets",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9740",
      "group" => "0018"
    },
    "38729" => {
      "KeyWord" => "PETReconstructionSequence",
      "Name" => "PET Reconstruction Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9749",
      "group" => "0018"
    },
    "38737" => {
      "KeyWord" => "PETFrameTypeSequence",
      "Name" => "PET Frame Type Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9751",
      "group" => "0018"
    },
    "38741" => {
      "KeyWord" => "TimeOfFlightInformationUsed",
      "Name" => "Time of Flight Information Used",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9755",
      "group" => "0018"
    },
    "38742" => {
      "KeyWord" => "ReconstructionType",
      "Name" => "Reconstruction Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9756",
      "group" => "0018"
    },
    "38744" => {
      "KeyWord" => "DecayCorrected",
      "Name" => "Decay Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9758",
      "group" => "0018"
    },
    "38745" => {
      "KeyWord" => "AttenuationCorrected",
      "Name" => "Attenuation Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9759",
      "group" => "0018"
    },
    "38752" => {
      "KeyWord" => "ScatterCorrected",
      "Name" => "Scatter Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9760",
      "group" => "0018"
    },
    "38753" => {
      "KeyWord" => "DeadTimeCorrected",
      "Name" => "Dead Time Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9761",
      "group" => "0018"
    },
    "38754" => {
      "KeyWord" => "GantryMotionCorrected",
      "Name" => "Gantry Motion Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9762",
      "group" => "0018"
    },
    "38755" => {
      "KeyWord" => "PatientMotionCorrected",
      "Name" => "Patient Motion Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9763",
      "group" => "0018"
    },
    "38756" => {
      "KeyWord" => "CountLossNormalizationCorrected",
      "Name" => "Count Loss Normalization Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9764",
      "group" => "0018"
    },
    "38757" => {
      "KeyWord" => "RandomsCorrected",
      "Name" => "Randoms Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9765",
      "group" => "0018"
    },
    "38758" => {
      "KeyWord" => "NonUniformRadialSamplingCorrected",
      "Name" => "Non-uniform Radial Sampling Corrected",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9766",
      "group" => "0018"
    },
    "38759" => {
      "KeyWord" => "SensitivityCalibrated",
      "Name" => "Sensitivity Calibrated",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9767",
      "group" => "0018"
    },
    "38760" => {
      "KeyWord" => "DetectorNormalizationCorrection",
      "Name" => "Detector Normalization Correction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9768",
      "group" => "0018"
    },
    "38761" => {
      "KeyWord" => "IterativeReconstructionMethod",
      "Name" => "Iterative Reconstruction Method",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9769",
      "group" => "0018"
    },
    "38768" => {
      "KeyWord" => "AttenuationCorrectionTemporalRelationship",
      "Name" => "Attenuation Correction Temporal Relationship",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9770",
      "group" => "0018"
    },
    "38769" => {
      "KeyWord" => "PatientPhysiologicalStateSequence",
      "Name" => "Patient Physiological State Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9771",
      "group" => "0018"
    },
    "38770" => {
      "KeyWord" => "PatientPhysiologicalStateCodeSequence",
      "Name" => "Patient Physiological State Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9772",
      "group" => "0018"
    },
    "38913" => {
      "KeyWord" => "DepthsOfFocus",
      "Name" => "Depth(s) of Focus",
      "VM" => "1-n",
      "VR" => "FD",
      "ele" => "9801",
      "group" => "0018"
    },
    "38915" => {
      "KeyWord" => "ExcludedIntervalsSequence",
      "Name" => "Excluded Intervals Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9803",
      "group" => "0018"
    },
    "38916" => {
      "KeyWord" => "ExclusionStartDateTime",
      "Name" => "Exclusion Start DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "9804",
      "group" => "0018"
    },
    "38917" => {
      "KeyWord" => "ExclusionDuration",
      "Name" => "Exclusion Duration",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9805",
      "group" => "0018"
    },
    "38918" => {
      "KeyWord" => "USImageDescriptionSequence",
      "Name" => "US Image Description Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9806",
      "group" => "0018"
    },
    "38919" => {
      "KeyWord" => "ImageDataTypeSequence",
      "Name" => "Image Data Type Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9807",
      "group" => "0018"
    },
    "38920" => {
      "KeyWord" => "DataType",
      "Name" => "Data Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9808",
      "group" => "0018"
    },
    "38921" => {
      "KeyWord" => "TransducerScanPatternCodeSequence",
      "Name" => "Transducer Scan Pattern Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9809",
      "group" => "0018"
    },
    "38923" => {
      "KeyWord" => "AliasedDataType",
      "Name" => "Aliased Data Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "980b",
      "group" => "0018"
    },
    "38924" => {
      "KeyWord" => "PositionMeasuringDeviceUsed",
      "Name" => "Position Measuring Device Used",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "980c",
      "group" => "0018"
    },
    "38925" => {
      "KeyWord" => "TransducerGeometryCodeSequence",
      "Name" => "Transducer Geometry Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "980d",
      "group" => "0018"
    },
    "38926" => {
      "KeyWord" => "TransducerBeamSteeringCodeSequence",
      "Name" => "Transducer Beam Steering Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "980e",
      "group" => "0018"
    },
    "38927" => {
      "KeyWord" => "TransducerApplicationCodeSequence",
      "Name" => "Transducer Application Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "980f",
      "group" => "0018"
    },
    "38928" => {
      "KeyWord" => "ZeroVelocityPixelValue",
      "Name" => "Zero Velocity Pixel Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "9810",
      "group" => "0018"
    },
    "39" => {
      "KeyWord" => "InterventionDrugStopTime",
      "Name" => "Intervention Drug Stop Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0027",
      "group" => "0018"
    },
    "40" => {
      "KeyWord" => "InterventionDrugDose",
      "Name" => "Intervention Drug Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0028",
      "group" => "0018"
    },
    "4096" => {
      "KeyWord" => "DeviceSerialNumber",
      "Name" => "Device Serial Number",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1000",
      "group" => "0018"
    },
    "40961" => {
      "KeyWord" => "ContributingEquipmentSequence",
      "Name" => "Contributing Equipment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a001",
      "group" => "0018"
    },
    "40962" => {
      "KeyWord" => "ContributionDateTime",
      "Name" => "Contribution DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "a002",
      "group" => "0018"
    },
    "40963" => {
      "KeyWord" => "ContributionDescription",
      "Name" => "Contribution Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "a003",
      "group" => "0018"
    },
    "4098" => {
      "KeyWord" => "DeviceUID",
      "Name" => "Device UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1002",
      "group" => "0018"
    },
    "4099" => {
      "KeyWord" => "DeviceID",
      "Name" => "Device ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1003",
      "group" => "0018"
    },
    "41" => {
      "KeyWord" => "InterventionDrugCodeSequence",
      "Name" => "Intervention Drug Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0029",
      "group" => "0018"
    },
    "4100" => {
      "KeyWord" => "PlateID",
      "Name" => "Plate ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1004",
      "group" => "0018"
    },
    "4101" => {
      "KeyWord" => "GeneratorID",
      "Name" => "Generator ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1005",
      "group" => "0018"
    },
    "4102" => {
      "KeyWord" => "GridID",
      "Name" => "Grid ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1006",
      "group" => "0018"
    },
    "4103" => {
      "KeyWord" => "CassetteID",
      "Name" => "Cassette ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1007",
      "group" => "0018"
    },
    "4104" => {
      "KeyWord" => "GantryID",
      "Name" => "Gantry ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1008",
      "group" => "0018"
    },
    "4112" => {
      "KeyWord" => "SecondaryCaptureDeviceID",
      "Name" => "Secondary Capture Device ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1010",
      "group" => "0018"
    },
    "4113" => {
      "KeyWord" => "HardcopyCreationDeviceID",
      "Name" => "Hardcopy Creation Device ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1011",
      "group" => "0018"
    },
    "4114" => {
      "KeyWord" => "DateOfSecondaryCapture",
      "Name" => "Date of Secondary Capture",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "1012",
      "group" => "0018"
    },
    "4116" => {
      "KeyWord" => "TimeOfSecondaryCapture",
      "Name" => "Time of Secondary Capture",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1014",
      "group" => "0018"
    },
    "4118" => {
      "KeyWord" => "SecondaryCaptureDeviceManufacturer",
      "Name" => "Secondary Capture Device Manufacturer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1016",
      "group" => "0018"
    },
    "4119" => {
      "KeyWord" => "HardcopyDeviceManufacturer",
      "Name" => "Hardcopy Device Manufacturer",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1017",
      "group" => "0018"
    },
    "4120" => {
      "KeyWord" => "SecondaryCaptureDeviceManufacturerModelName",
      "Name" => "Secondary Capture Device Manufacturer's Model Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1018",
      "group" => "0018"
    },
    "4121" => {
      "KeyWord" => "SecondaryCaptureDeviceSoftwareVersions",
      "Name" => "Secondary Capture Device Software Versions",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1019",
      "group" => "0018"
    },
    "4122" => {
      "KeyWord" => "HardcopyDeviceSoftwareVersion",
      "Name" => "Hardcopy Device Software Version",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "101a",
      "group" => "0018"
    },
    "4123" => {
      "KeyWord" => "HardcopyDeviceManufacturerModelName",
      "Name" => "Hardcopy Device Manufacturer's Model Name",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "101b",
      "group" => "0018"
    },
    "4128" => {
      "KeyWord" => "SoftwareVersions",
      "Name" => "Software Version(s)",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1020",
      "group" => "0018"
    },
    "4130" => {
      "KeyWord" => "VideoImageFormatAcquired",
      "Name" => "Video Image Format Acquired",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1022",
      "group" => "0018"
    },
    "4131" => {
      "KeyWord" => "DigitalImageFormatAcquired",
      "Name" => "Digital Image Format Acquired",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1023",
      "group" => "0018"
    },
    "4144" => {
      "KeyWord" => "ProtocolName",
      "Name" => "Protocol Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1030",
      "group" => "0018"
    },
    "4160" => {
      "KeyWord" => "ContrastBolusRoute",
      "Name" => "Contrast/Bolus Route",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1040",
      "group" => "0018"
    },
    "4161" => {
      "KeyWord" => "ContrastBolusVolume",
      "Name" => "Contrast/Bolus Volume",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1041",
      "group" => "0018"
    },
    "4162" => {
      "KeyWord" => "ContrastBolusStartTime",
      "Name" => "Contrast/Bolus Start Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1042",
      "group" => "0018"
    },
    "4163" => {
      "KeyWord" => "ContrastBolusStopTime",
      "Name" => "Contrast/Bolus Stop Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1043",
      "group" => "0018"
    },
    "4164" => {
      "KeyWord" => "ContrastBolusTotalDose",
      "Name" => "Contrast/Bolus Total Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1044",
      "group" => "0018"
    },
    "4165" => {
      "KeyWord" => "SyringeCounts",
      "Name" => "Syringe Counts",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1045",
      "group" => "0018"
    },
    "4166" => {
      "KeyWord" => "ContrastFlowRate",
      "Name" => "Contrast Flow Rate",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1046",
      "group" => "0018"
    },
    "4167" => {
      "KeyWord" => "ContrastFlowDuration",
      "Name" => "Contrast Flow Duration",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1047",
      "group" => "0018"
    },
    "4168" => {
      "KeyWord" => "ContrastBolusIngredient",
      "Name" => "Contrast/Bolus Ingredient",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1048",
      "group" => "0018"
    },
    "4169" => {
      "KeyWord" => "ContrastBolusIngredientConcentration",
      "Name" => "Contrast/Bolus Ingredient Concentration",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1049",
      "group" => "0018"
    },
    "4176" => {
      "KeyWord" => "SpatialResolution",
      "Name" => "Spatial Resolution",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1050",
      "group" => "0018"
    },
    "4192" => {
      "KeyWord" => "TriggerTime",
      "Name" => "Trigger Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1060",
      "group" => "0018"
    },
    "4193" => {
      "KeyWord" => "TriggerSourceOrType",
      "Name" => "Trigger Source or Type",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1061",
      "group" => "0018"
    },
    "4194" => {
      "KeyWord" => "NominalInterval",
      "Name" => "Nominal Interval",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1062",
      "group" => "0018"
    },
    "4195" => {
      "KeyWord" => "FrameTime",
      "Name" => "Frame Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1063",
      "group" => "0018"
    },
    "4196" => {
      "KeyWord" => "CardiacFramingType",
      "Name" => "Cardiac Framing Type",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1064",
      "group" => "0018"
    },
    "4197" => {
      "KeyWord" => "FrameTimeVector",
      "Name" => "Frame Time Vector",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1065",
      "group" => "0018"
    },
    "4198" => {
      "KeyWord" => "FrameDelay",
      "Name" => "Frame Delay",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1066",
      "group" => "0018"
    },
    "4199" => {
      "KeyWord" => "ImageTriggerDelay",
      "Name" => "Image Trigger Delay",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1067",
      "group" => "0018"
    },
    "42" => {
      "KeyWord" => "AdditionalDrugSequence",
      "Name" => "Additional Drug Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "002a",
      "group" => "0018"
    },
    "4200" => {
      "KeyWord" => "MultiplexGroupTimeOffset",
      "Name" => "Multiplex Group Time Offset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1068",
      "group" => "0018"
    },
    "4201" => {
      "KeyWord" => "TriggerTimeOffset",
      "Name" => "Trigger Time Offset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1069",
      "group" => "0018"
    },
    "4202" => {
      "KeyWord" => "SynchronizationTrigger",
      "Name" => "Synchronization Trigger",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "106a",
      "group" => "0018"
    },
    "4204" => {
      "KeyWord" => "SynchronizationChannel",
      "Name" => "Synchronization Channel",
      "VM" => "2",
      "VR" => "US",
      "ele" => "106c",
      "group" => "0018"
    },
    "4206" => {
      "KeyWord" => "TriggerSamplePosition",
      "Name" => "Trigger Sample Position",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "106e",
      "group" => "0018"
    },
    "4208" => {
      "KeyWord" => "RadiopharmaceuticalRoute",
      "Name" => "Radiopharmaceutical Route",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1070",
      "group" => "0018"
    },
    "4209" => {
      "KeyWord" => "RadiopharmaceuticalVolume",
      "Name" => "Radiopharmaceutical Volume",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1071",
      "group" => "0018"
    },
    "4210" => {
      "KeyWord" => "RadiopharmaceuticalStartTime",
      "Name" => "Radiopharmaceutical Start Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1072",
      "group" => "0018"
    },
    "4211" => {
      "KeyWord" => "RadiopharmaceuticalStopTime",
      "Name" => "Radiopharmaceutical Stop Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1073",
      "group" => "0018"
    },
    "4212" => {
      "KeyWord" => "RadionuclideTotalDose",
      "Name" => "Radionuclide Total Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1074",
      "group" => "0018"
    },
    "4213" => {
      "KeyWord" => "RadionuclideHalfLife",
      "Name" => "Radionuclide Half Life",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1075",
      "group" => "0018"
    },
    "4214" => {
      "KeyWord" => "RadionuclidePositronFraction",
      "Name" => "Radionuclide Positron Fraction",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1076",
      "group" => "0018"
    },
    "4215" => {
      "KeyWord" => "RadiopharmaceuticalSpecificActivity",
      "Name" => "Radiopharmaceutical Specific Activity",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1077",
      "group" => "0018"
    },
    "4216" => {
      "KeyWord" => "RadiopharmaceuticalStartDateTime",
      "Name" => "Radiopharmaceutical Start DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "1078",
      "group" => "0018"
    },
    "4217" => {
      "KeyWord" => "RadiopharmaceuticalStopDateTime",
      "Name" => "Radiopharmaceutical Stop DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "1079",
      "group" => "0018"
    },
    "4224" => {
      "KeyWord" => "BeatRejectionFlag",
      "Name" => "Beat Rejection Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1080",
      "group" => "0018"
    },
    "4225" => {
      "KeyWord" => "LowRRValue",
      "Name" => "Low R-R Value",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1081",
      "group" => "0018"
    },
    "4226" => {
      "KeyWord" => "HighRRValue",
      "Name" => "High R-R Value",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1082",
      "group" => "0018"
    },
    "4227" => {
      "KeyWord" => "IntervalsAcquired",
      "Name" => "Intervals Acquired",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1083",
      "group" => "0018"
    },
    "4228" => {
      "KeyWord" => "IntervalsRejected",
      "Name" => "Intervals Rejected",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1084",
      "group" => "0018"
    },
    "4229" => {
      "KeyWord" => "PVCRejection",
      "Name" => "PVC Rejection",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1085",
      "group" => "0018"
    },
    "4230" => {
      "KeyWord" => "SkipBeats",
      "Name" => "Skip Beats",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1086",
      "group" => "0018"
    },
    "4232" => {
      "KeyWord" => "HeartRate",
      "Name" => "Heart Rate",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1088",
      "group" => "0018"
    },
    "4240" => {
      "KeyWord" => "CardiacNumberOfImages",
      "Name" => "Cardiac Number of Images",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1090",
      "group" => "0018"
    },
    "4244" => {
      "KeyWord" => "TriggerWindow",
      "Name" => "Trigger Window",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1094",
      "group" => "0018"
    },
    "4352" => {
      "KeyWord" => "ReconstructionDiameter",
      "Name" => "Reconstruction Diameter",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1100",
      "group" => "0018"
    },
    "4368" => {
      "KeyWord" => "DistanceSourceToDetector",
      "Name" => "Distance Source to Detector",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1110",
      "group" => "0018"
    },
    "4369" => {
      "KeyWord" => "DistanceSourceToPatient",
      "Name" => "Distance Source to Patient",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1111",
      "group" => "0018"
    },
    "4372" => {
      "KeyWord" => "EstimatedRadiographicMagnificationFactor",
      "Name" => "Estimated Radiographic Magnification Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1114",
      "group" => "0018"
    },
    "4384" => {
      "KeyWord" => "GantryDetectorTilt",
      "Name" => "Gantry/Detector Tilt",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1120",
      "group" => "0018"
    },
    "4385" => {
      "KeyWord" => "GantryDetectorSlew",
      "Name" => "Gantry/Detector Slew",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1121",
      "group" => "0018"
    },
    "4400" => {
      "KeyWord" => "TableHeight",
      "Name" => "Table Height",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1130",
      "group" => "0018"
    },
    "4401" => {
      "KeyWord" => "TableTraverse",
      "Name" => "Table Traverse",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1131",
      "group" => "0018"
    },
    "4404" => {
      "KeyWord" => "TableMotion",
      "Name" => "Table Motion",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1134",
      "group" => "0018"
    },
    "4405" => {
      "KeyWord" => "TableVerticalIncrement",
      "Name" => "Table Vertical Increment",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1135",
      "group" => "0018"
    },
    "4406" => {
      "KeyWord" => "TableLateralIncrement",
      "Name" => "Table Lateral Increment",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1136",
      "group" => "0018"
    },
    "4407" => {
      "KeyWord" => "TableLongitudinalIncrement",
      "Name" => "Table Longitudinal Increment",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1137",
      "group" => "0018"
    },
    "4408" => {
      "KeyWord" => "TableAngle",
      "Name" => "Table Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1138",
      "group" => "0018"
    },
    "4410" => {
      "KeyWord" => "TableType",
      "Name" => "Table Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "113a",
      "group" => "0018"
    },
    "4416" => {
      "KeyWord" => "RotationDirection",
      "Name" => "Rotation Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1140",
      "group" => "0018"
    },
    "4417" => {
      "KeyWord" => "AngularPosition",
      "Name" => "Angular Position",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1141",
      "group" => "0018"
    },
    "4418" => {
      "KeyWord" => "RadialPosition",
      "Name" => "Radial Position",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1142",
      "group" => "0018"
    },
    "4419" => {
      "KeyWord" => "ScanArc",
      "Name" => "Scan Arc",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1143",
      "group" => "0018"
    },
    "4420" => {
      "KeyWord" => "AngularStep",
      "Name" => "Angular Step",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1144",
      "group" => "0018"
    },
    "4421" => {
      "KeyWord" => "CenterOfRotationOffset",
      "Name" => "Center of Rotation Offset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1145",
      "group" => "0018"
    },
    "4422" => {
      "KeyWord" => "RotationOffset",
      "Name" => "Rotation Offset",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1146",
      "group" => "0018"
    },
    "4423" => {
      "KeyWord" => "FieldOfViewShape",
      "Name" => "Field of View Shape",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1147",
      "group" => "0018"
    },
    "4425" => {
      "KeyWord" => "FieldOfViewDimensions",
      "Name" => "Field of View Dimension(s)",
      "VM" => "1-2",
      "VR" => "IS",
      "ele" => "1149",
      "group" => "0018"
    },
    "4432" => {
      "KeyWord" => "ExposureTime",
      "Name" => "Exposure Time",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1150",
      "group" => "0018"
    },
    "4433" => {
      "KeyWord" => "XRayTubeCurrent",
      "Name" => "X-Ray Tube Current",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1151",
      "group" => "0018"
    },
    "4434" => {
      "KeyWord" => "Exposure",
      "Name" => "Exposure",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1152",
      "group" => "0018"
    },
    "4435" => {
      "KeyWord" => "ExposureInuAs",
      "Name" => "Exposure in µAs",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1153",
      "group" => "0018"
    },
    "4436" => {
      "KeyWord" => "AveragePulseWidth",
      "Name" => "Average Pulse Width",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1154",
      "group" => "0018"
    },
    "4437" => {
      "KeyWord" => "RadiationSetting",
      "Name" => "Radiation Setting",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1155",
      "group" => "0018"
    },
    "4438" => {
      "KeyWord" => "RectificationType",
      "Name" => "Rectification Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1156",
      "group" => "0018"
    },
    "4442" => {
      "KeyWord" => "RadiationMode",
      "Name" => "Radiation Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "115a",
      "group" => "0018"
    },
    "4446" => {
      "KeyWord" => "ImageAndFluoroscopyAreaDoseProduct",
      "Name" => "Image and Fluoroscopy Area Dose Product",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "115e",
      "group" => "0018"
    },
    "4448" => {
      "KeyWord" => "FilterType",
      "Name" => "Filter Type",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1160",
      "group" => "0018"
    },
    "4449" => {
      "KeyWord" => "TypeOfFilters",
      "Name" => "Type of Filters",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1161",
      "group" => "0018"
    },
    "4450" => {
      "KeyWord" => "IntensifierSize",
      "Name" => "Intensifier Size",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1162",
      "group" => "0018"
    },
    "4452" => {
      "KeyWord" => "ImagerPixelSpacing",
      "Name" => "Imager Pixel Spacing",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "1164",
      "group" => "0018"
    },
    "4454" => {
      "KeyWord" => "Grid",
      "Name" => "Grid",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "1166",
      "group" => "0018"
    },
    "4464" => {
      "KeyWord" => "GeneratorPower",
      "Name" => "Generator Power",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1170",
      "group" => "0018"
    },
    "4480" => {
      "KeyWord" => "CollimatorGridName",
      "Name" => "Collimator/grid Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1180",
      "group" => "0018"
    },
    "4481" => {
      "KeyWord" => "CollimatorType",
      "Name" => "Collimator Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1181",
      "group" => "0018"
    },
    "4482" => {
      "KeyWord" => "FocalDistance",
      "Name" => "Focal Distance",
      "VM" => "1-2",
      "VR" => "IS",
      "ele" => "1182",
      "group" => "0018"
    },
    "4483" => {
      "KeyWord" => "XFocusCenter",
      "Name" => "X Focus Center",
      "VM" => "1-2",
      "VR" => "DS",
      "ele" => "1183",
      "group" => "0018"
    },
    "4484" => {
      "KeyWord" => "YFocusCenter",
      "Name" => "Y Focus Center",
      "VM" => "1-2",
      "VR" => "DS",
      "ele" => "1184",
      "group" => "0018"
    },
    "4496" => {
      "KeyWord" => "FocalSpots",
      "Name" => "Focal Spot(s)",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1190",
      "group" => "0018"
    },
    "4497" => {
      "KeyWord" => "AnodeTargetMaterial",
      "Name" => "Anode Target Material",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1191",
      "group" => "0018"
    },
    "4512" => {
      "KeyWord" => "BodyPartThickness",
      "Name" => "Body Part Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "11a0",
      "group" => "0018"
    },
    "4514" => {
      "KeyWord" => "CompressionForce",
      "Name" => "Compression Force",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "11a2",
      "group" => "0018"
    },
    "4516" => {
      "KeyWord" => "PaddleDescription",
      "Name" => "Paddle Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "11a4",
      "group" => "0018"
    },
    "4608" => {
      "KeyWord" => "DateOfLastCalibration",
      "Name" => "Date of Last Calibration",
      "VM" => "1-n",
      "VR" => "DA",
      "ele" => "1200",
      "group" => "0018"
    },
    "4609" => {
      "KeyWord" => "TimeOfLastCalibration",
      "Name" => "Time of Last Calibration",
      "VM" => "1-n",
      "VR" => "TM",
      "ele" => "1201",
      "group" => "0018"
    },
    "4624" => {
      "KeyWord" => "ConvolutionKernel",
      "Name" => "Convolution Kernel",
      "VM" => "1-n",
      "VR" => "SH",
      "ele" => "1210",
      "group" => "0018"
    },
    "4672" => {
      "KeyWord" => "UpperLowerPixelValues",
      "Name" => "Upper/Lower Pixel Values",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "1240",
      "group" => "0018"
    },
    "4674" => {
      "KeyWord" => "ActualFrameDuration",
      "Name" => "Actual Frame Duration",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1242",
      "group" => "0018"
    },
    "4675" => {
      "KeyWord" => "CountRate",
      "Name" => "Count Rate",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1243",
      "group" => "0018"
    },
    "4676" => {
      "KeyWord" => "PreferredPlaybackSequencing",
      "Name" => "Preferred Playback Sequencing",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1244",
      "group" => "0018"
    },
    "4688" => {
      "KeyWord" => "ReceiveCoilName",
      "Name" => "Receive Coil Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1250",
      "group" => "0018"
    },
    "4689" => {
      "KeyWord" => "TransmitCoilName",
      "Name" => "Transmit Coil Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1251",
      "group" => "0018"
    },
    "4704" => {
      "KeyWord" => "PlateType",
      "Name" => "Plate Type",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1260",
      "group" => "0018"
    },
    "4705" => {
      "KeyWord" => "PhosphorType",
      "Name" => "Phosphor Type",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1261",
      "group" => "0018"
    },
    "48" => {
      "KeyWord" => "Radionuclide",
      "Name" => "Radionuclide",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0030",
      "group" => "0018"
    },
    "4864" => {
      "KeyWord" => "ScanVelocity",
      "Name" => "Scan Velocity",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1300",
      "group" => "0018"
    },
    "4865" => {
      "KeyWord" => "WholeBodyTechnique",
      "Name" => "Whole Body Technique",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "1301",
      "group" => "0018"
    },
    "4866" => {
      "KeyWord" => "ScanLength",
      "Name" => "Scan Length",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1302",
      "group" => "0018"
    },
    "4880" => {
      "KeyWord" => "AcquisitionMatrix",
      "Name" => "Acquisition Matrix",
      "VM" => "4",
      "VR" => "US",
      "ele" => "1310",
      "group" => "0018"
    },
    "4882" => {
      "KeyWord" => "InPlanePhaseEncodingDirection",
      "Name" => "In-plane Phase Encoding Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1312",
      "group" => "0018"
    },
    "4884" => {
      "KeyWord" => "FlipAngle",
      "Name" => "Flip Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1314",
      "group" => "0018"
    },
    "4885" => {
      "KeyWord" => "VariableFlipAngleFlag",
      "Name" => "Variable Flip Angle Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1315",
      "group" => "0018"
    },
    "4886" => {
      "KeyWord" => "SAR",
      "Name" => "SAR",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1316",
      "group" => "0018"
    },
    "4888" => {
      "KeyWord" => "dBdt",
      "Name" => "dB/dt",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1318",
      "group" => "0018"
    },
    "49" => {
      "KeyWord" => "Radiopharmaceutical",
      "Name" => "Radiopharmaceutical",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0031",
      "group" => "0018"
    },
    "50" => {
      "KeyWord" => "EnergyWindowCenterline",
      "Name" => "Energy Window Centerline",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0032",
      "group" => "0018"
    },
    "51" => {
      "KeyWord" => "EnergyWindowTotalWidth",
      "Name" => "Energy Window Total Width",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "0033",
      "group" => "0018"
    },
    "5120" => {
      "KeyWord" => "AcquisitionDeviceProcessingDescription",
      "Name" => "Acquisition Device Processing Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1400",
      "group" => "0018"
    },
    "5121" => {
      "KeyWord" => "AcquisitionDeviceProcessingCode",
      "Name" => "Acquisition Device Processing Code",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1401",
      "group" => "0018"
    },
    "5122" => {
      "KeyWord" => "CassetteOrientation",
      "Name" => "Cassette Orientation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1402",
      "group" => "0018"
    },
    "5123" => {
      "KeyWord" => "CassetteSize",
      "Name" => "Cassette Size",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1403",
      "group" => "0018"
    },
    "5124" => {
      "KeyWord" => "ExposuresOnPlate",
      "Name" => "Exposures on Plate",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1404",
      "group" => "0018"
    },
    "5125" => {
      "KeyWord" => "RelativeXRayExposure",
      "Name" => "Relative X-Ray Exposure",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1405",
      "group" => "0018"
    },
    "5137" => {
      "KeyWord" => "ExposureIndex",
      "Name" => "Exposure Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1411",
      "group" => "0018"
    },
    "5138" => {
      "KeyWord" => "TargetExposureIndex",
      "Name" => "Target Exposure Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1412",
      "group" => "0018"
    },
    "5139" => {
      "KeyWord" => "DeviationIndex",
      "Name" => "Deviation Index",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1413",
      "group" => "0018"
    },
    "52" => {
      "KeyWord" => "InterventionDrugName",
      "Name" => "Intervention Drug Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0034",
      "group" => "0018"
    },
    "5200" => {
      "KeyWord" => "ColumnAngulation",
      "Name" => "Column Angulation",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1450",
      "group" => "0018"
    },
    "5216" => {
      "KeyWord" => "TomoLayerHeight",
      "Name" => "Tomo Layer Height",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1460",
      "group" => "0018"
    },
    "5232" => {
      "KeyWord" => "TomoAngle",
      "Name" => "Tomo Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1470",
      "group" => "0018"
    },
    "5248" => {
      "KeyWord" => "TomoTime",
      "Name" => "Tomo Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1480",
      "group" => "0018"
    },
    "5264" => {
      "KeyWord" => "TomoType",
      "Name" => "Tomo Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1490",
      "group" => "0018"
    },
    "5265" => {
      "KeyWord" => "TomoClass",
      "Name" => "Tomo Class",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1491",
      "group" => "0018"
    },
    "5269" => {
      "KeyWord" => "NumberOfTomosynthesisSourceImages",
      "Name" => "Number of Tomosynthesis Source Images",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1495",
      "group" => "0018"
    },
    "53" => {
      "KeyWord" => "InterventionDrugStartTime",
      "Name" => "Intervention Drug Start Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0035",
      "group" => "0018"
    },
    "5376" => {
      "KeyWord" => "PositionerMotion",
      "Name" => "Positioner Motion",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1500",
      "group" => "0018"
    },
    "5384" => {
      "KeyWord" => "PositionerType",
      "Name" => "Positioner Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1508",
      "group" => "0018"
    },
    "5392" => {
      "KeyWord" => "PositionerPrimaryAngle",
      "Name" => "Positioner Primary Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1510",
      "group" => "0018"
    },
    "5393" => {
      "KeyWord" => "PositionerSecondaryAngle",
      "Name" => "Positioner Secondary Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1511",
      "group" => "0018"
    },
    "54" => {
      "KeyWord" => "InterventionSequence",
      "Name" => "Intervention Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0036",
      "group" => "0018"
    },
    "5408" => {
      "KeyWord" => "PositionerPrimaryAngleIncrement",
      "Name" => "Positioner Primary Angle Increment",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1520",
      "group" => "0018"
    },
    "5409" => {
      "KeyWord" => "PositionerSecondaryAngleIncrement",
      "Name" => "Positioner Secondary Angle Increment",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1521",
      "group" => "0018"
    },
    "5424" => {
      "KeyWord" => "DetectorPrimaryAngle",
      "Name" => "Detector Primary Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1530",
      "group" => "0018"
    },
    "5425" => {
      "KeyWord" => "DetectorSecondaryAngle",
      "Name" => "Detector Secondary Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1531",
      "group" => "0018"
    },
    "55" => {
      "KeyWord" => "TherapyType",
      "Name" => "Therapy Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0037",
      "group" => "0018"
    },
    "56" => {
      "KeyWord" => "InterventionStatus",
      "Name" => "Intervention Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0038",
      "group" => "0018"
    },
    "5632" => {
      "KeyWord" => "ShutterShape",
      "Name" => "Shutter Shape",
      "VM" => "1-3",
      "VR" => "CS",
      "ele" => "1600",
      "group" => "0018"
    },
    "5634" => {
      "KeyWord" => "ShutterLeftVerticalEdge",
      "Name" => "Shutter Left Vertical Edge",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1602",
      "group" => "0018"
    },
    "5636" => {
      "KeyWord" => "ShutterRightVerticalEdge",
      "Name" => "Shutter Right Vertical Edge",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1604",
      "group" => "0018"
    },
    "5638" => {
      "KeyWord" => "ShutterUpperHorizontalEdge",
      "Name" => "Shutter Upper Horizontal Edge",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1606",
      "group" => "0018"
    },
    "5640" => {
      "KeyWord" => "ShutterLowerHorizontalEdge",
      "Name" => "Shutter Lower Horizontal Edge",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1608",
      "group" => "0018"
    },
    "5648" => {
      "KeyWord" => "CenterOfCircularShutter",
      "Name" => "Center of Circular Shutter",
      "VM" => "2",
      "VR" => "IS",
      "ele" => "1610",
      "group" => "0018"
    },
    "5650" => {
      "KeyWord" => "RadiusOfCircularShutter",
      "Name" => "Radius of Circular Shutter",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1612",
      "group" => "0018"
    },
    "5664" => {
      "KeyWord" => "VerticesOfThePolygonalShutter",
      "Name" => "Vertices of the Polygonal Shutter",
      "VM" => "2-2n",
      "VR" => "IS",
      "ele" => "1620",
      "group" => "0018"
    },
    "5666" => {
      "KeyWord" => "ShutterPresentationValue",
      "Name" => "Shutter Presentation Value",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1622",
      "group" => "0018"
    },
    "5667" => {
      "KeyWord" => "ShutterOverlayGroup",
      "Name" => "Shutter Overlay Group",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1623",
      "group" => "0018"
    },
    "5668" => {
      "KeyWord" => "ShutterPresentationColorCIELabValue",
      "Name" => "Shutter Presentation Color CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "1624",
      "group" => "0018"
    },
    "57" => {
      "KeyWord" => "TherapyDescription",
      "Name" => "Therapy Description",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0039",
      "group" => "0018"
    },
    "58" => {
      "KeyWord" => "InterventionDescription",
      "Name" => "Intervention Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "003a",
      "group" => "0018"
    },
    "5888" => {
      "KeyWord" => "CollimatorShape",
      "Name" => "Collimator Shape",
      "VM" => "1-3",
      "VR" => "CS",
      "ele" => "1700",
      "group" => "0018"
    },
    "5890" => {
      "KeyWord" => "CollimatorLeftVerticalEdge",
      "Name" => "Collimator Left Vertical Edge",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1702",
      "group" => "0018"
    },
    "5892" => {
      "KeyWord" => "CollimatorRightVerticalEdge",
      "Name" => "Collimator Right Vertical Edge",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1704",
      "group" => "0018"
    },
    "5894" => {
      "KeyWord" => "CollimatorUpperHorizontalEdge",
      "Name" => "Collimator Upper Horizontal Edge",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1706",
      "group" => "0018"
    },
    "5896" => {
      "KeyWord" => "CollimatorLowerHorizontalEdge",
      "Name" => "Collimator Lower Horizontal Edge",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1708",
      "group" => "0018"
    },
    "5904" => {
      "KeyWord" => "CenterOfCircularCollimator",
      "Name" => "Center of Circular Collimator",
      "VM" => "2",
      "VR" => "IS",
      "ele" => "1710",
      "group" => "0018"
    },
    "5906" => {
      "KeyWord" => "RadiusOfCircularCollimator",
      "Name" => "Radius of Circular Collimator",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1712",
      "group" => "0018"
    },
    "5920" => {
      "KeyWord" => "VerticesOfThePolygonalCollimator",
      "Name" => "Vertices of the Polygonal Collimator",
      "VM" => "2-2n",
      "VR" => "IS",
      "ele" => "1720",
      "group" => "0018"
    },
    "6144" => {
      "KeyWord" => "AcquisitionTimeSynchronized",
      "Name" => "Acquisition Time Synchronized",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1800",
      "group" => "0018"
    },
    "6145" => {
      "KeyWord" => "TimeSource",
      "Name" => "Time Source",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1801",
      "group" => "0018"
    },
    "6146" => {
      "KeyWord" => "TimeDistributionProtocol",
      "Name" => "Time Distribution Protocol",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1802",
      "group" => "0018"
    },
    "6147" => {
      "KeyWord" => "NTPSourceAddress",
      "Name" => "NTP Source Address",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1803",
      "group" => "0018"
    },
    "64" => {
      "KeyWord" => "CineRate",
      "Name" => "Cine Rate",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0040",
      "group" => "0018"
    },
    "66" => {
      "KeyWord" => "InitialCineRunState",
      "Name" => "Initial Cine Run State",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0042",
      "group" => "0018"
    },
    "80" => {
      "KeyWord" => "SliceThickness",
      "Name" => "Slice Thickness",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0050",
      "group" => "0018"
    },
    "8193" => {
      "KeyWord" => "PageNumberVector",
      "Name" => "Page Number Vector",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "2001",
      "group" => "0018"
    },
    "8194" => {
      "KeyWord" => "FrameLabelVector",
      "Name" => "Frame Label Vector",
      "VM" => "1-n",
      "VR" => "SH",
      "ele" => "2002",
      "group" => "0018"
    },
    "8195" => {
      "KeyWord" => "FramePrimaryAngleVector",
      "Name" => "Frame Primary Angle Vector",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "2003",
      "group" => "0018"
    },
    "8196" => {
      "KeyWord" => "FrameSecondaryAngleVector",
      "Name" => "Frame Secondary Angle Vector",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "2004",
      "group" => "0018"
    },
    "8197" => {
      "KeyWord" => "SliceLocationVector",
      "Name" => "Slice Location Vector",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "2005",
      "group" => "0018"
    },
    "8198" => {
      "KeyWord" => "DisplayWindowLabelVector",
      "Name" => "Display Window Label Vector",
      "VM" => "1-n",
      "VR" => "SH",
      "ele" => "2006",
      "group" => "0018"
    },
    "8208" => {
      "KeyWord" => "NominalScannedPixelSpacing",
      "Name" => "Nominal Scanned Pixel Spacing",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "2010",
      "group" => "0018"
    },
    "8224" => {
      "KeyWord" => "DigitizingDeviceTransportDirection",
      "Name" => "Digitizing Device Transport Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2020",
      "group" => "0018"
    },
    "8240" => {
      "KeyWord" => "RotationOfScannedFilm",
      "Name" => "Rotation of Scanned Film",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "2030",
      "group" => "0018"
    },
    "8257" => {
      "KeyWord" => "BiopsyTargetSequence",
      "Name" => "Biopsy Target Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2041",
      "group" => "0018"
    },
    "8258" => {
      "KeyWord" => "TargetUID",
      "Name" => "Target UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "2042",
      "group" => "0018"
    },
    "8259" => {
      "KeyWord" => "LocalizingCursorPosition",
      "Name" => "Localizing Cursor Position",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "2043",
      "group" => "0018"
    },
    "8260" => {
      "KeyWord" => "CalculatedTargetPosition",
      "Name" => "Calculated Target Position",
      "VM" => "3",
      "VR" => "FL",
      "ele" => "2044",
      "group" => "0018"
    },
    "8261" => {
      "KeyWord" => "TargetLabel",
      "Name" => "Target Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2045",
      "group" => "0018"
    },
    "8262" => {
      "KeyWord" => "DisplayedZValue",
      "Name" => "Displayed Z Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "2046",
      "group" => "0018"
    },
    "96" => {
      "KeyWord" => "KVP",
      "Name" => "KVP",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0060",
      "group" => "0018"
    }
  },
  "256" => {
    "1040" => {
      "KeyWord" => "SOPInstanceStatus",
      "Name" => "SOP Instance Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0410",
      "group" => "0100"
    },
    "1056" => {
      "KeyWord" => "SOPAuthorizationDateTime",
      "Name" => "SOP Authorization DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "0420",
      "group" => "0100"
    },
    "1060" => {
      "KeyWord" => "SOPAuthorizationComment",
      "Name" => "SOP Authorization Comment",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0424",
      "group" => "0100"
    },
    "1062" => {
      "KeyWord" => "AuthorizationEquipmentCertificationNumber",
      "Name" => "Authorization Equipment Certification Number",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0426",
      "group" => "0100"
    }
  },
  "32" => {
    "112" => {
      "KeyWord" => "ImageGeometryType",
      "Name" => "Image Geometry Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0070",
      "group" => "0020"
    },
    "128" => {
      "KeyWord" => "MaskingImage",
      "Name" => "Masking Image",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0080",
      "group" => "0020"
    },
    "13" => {
      "KeyWord" => "StudyInstanceUID",
      "Name" => "Study Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "000d",
      "group" => "0020"
    },
    "13313" => {
      "KeyWord" => "ModifyingDeviceID",
      "Name" => "Modifying Device ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "3401",
      "group" => "0020"
    },
    "13314" => {
      "KeyWord" => "ModifiedImageID",
      "Name" => "Modified Image ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "3402",
      "group" => "0020"
    },
    "13315" => {
      "KeyWord" => "ModifiedImageDate",
      "Name" => "Modified Image Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "3403",
      "group" => "0020"
    },
    "13316" => {
      "KeyWord" => "ModifyingDeviceManufacturer",
      "Name" => "Modifying Device Manufacturer",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "3404",
      "group" => "0020"
    },
    "13317" => {
      "KeyWord" => "ModifiedImageTime",
      "Name" => "Modified Image Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "3405",
      "group" => "0020"
    },
    "13318" => {
      "KeyWord" => "ModifiedImageDescription",
      "Name" => "Modified Image Description",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "3406",
      "group" => "0020"
    },
    "14" => {
      "KeyWord" => "SeriesInstanceUID",
      "Name" => "Series Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "000e",
      "group" => "0020"
    },
    "16" => {
      "KeyWord" => "StudyID",
      "Name" => "Study ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0010",
      "group" => "0020"
    },
    "16384" => {
      "KeyWord" => "ImageComments",
      "Name" => "Image Comments",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "0020"
    },
    "17" => {
      "KeyWord" => "SeriesNumber",
      "Name" => "Series Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0011",
      "group" => "0020"
    },
    "170" => {
      "KeyWord" => "ReportNumber",
      "Name" => "Report Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "00aa",
      "group" => "0020"
    },
    "18" => {
      "KeyWord" => "AcquisitionNumber",
      "Name" => "Acquisition Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0012",
      "group" => "0020"
    },
    "19" => {
      "KeyWord" => "InstanceNumber",
      "Name" => "Instance Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0013",
      "group" => "0020"
    },
    "20" => {
      "KeyWord" => "IsotopeNumber",
      "Name" => "Isotope Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0014",
      "group" => "0020"
    },
    "20480" => {
      "KeyWord" => "OriginalImageIdentification",
      "Name" => "Original Image Identification",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "5000",
      "group" => "0020"
    },
    "20482" => {
      "KeyWord" => "OriginalImageIdentificationNomenclature",
      "Name" => "Original Image Identification Nomenclature",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "5002",
      "group" => "0020"
    },
    "21" => {
      "KeyWord" => "PhaseNumber",
      "Name" => "Phase Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0015",
      "group" => "0020"
    },
    "22" => {
      "KeyWord" => "IntervalNumber",
      "Name" => "Interval Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0016",
      "group" => "0020"
    },
    "23" => {
      "KeyWord" => "TimeSlotNumber",
      "Name" => "Time Slot Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0017",
      "group" => "0020"
    },
    "24" => {
      "KeyWord" => "AngleNumber",
      "Name" => "Angle Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0018",
      "group" => "0020"
    },
    "25" => {
      "KeyWord" => "ItemNumber",
      "Name" => "Item Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0019",
      "group" => "0020"
    },
    "256" => {
      "KeyWord" => "TemporalPositionIdentifier",
      "Name" => "Temporal Position Identifier",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0100",
      "group" => "0020"
    },
    "261" => {
      "KeyWord" => "NumberOfTemporalPositions",
      "Name" => "Number of Temporal Positions",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0105",
      "group" => "0020"
    },
    "272" => {
      "KeyWord" => "TemporalResolution",
      "Name" => "Temporal Resolution",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0110",
      "group" => "0020"
    },
    "32" => {
      "KeyWord" => "PatientOrientation",
      "Name" => "Patient Orientation",
      "VM" => "2",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "0020"
    },
    "34" => {
      "KeyWord" => "OverlayNumber",
      "Name" => "Overlay Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0022",
      "group" => "0020"
    },
    "36" => {
      "KeyWord" => "CurveNumber",
      "Name" => "Curve Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0024",
      "group" => "0020"
    },
    "36950" => {
      "KeyWord" => "StackID",
      "Name" => "Stack ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "9056",
      "group" => "0020"
    },
    "36951" => {
      "KeyWord" => "InStackPositionNumber",
      "Name" => "In-Stack Position Number",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9057",
      "group" => "0020"
    },
    "36977" => {
      "KeyWord" => "FrameAnatomySequence",
      "Name" => "Frame Anatomy Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9071",
      "group" => "0020"
    },
    "36978" => {
      "KeyWord" => "FrameLaterality",
      "Name" => "Frame Laterality",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9072",
      "group" => "0020"
    },
    "37137" => {
      "KeyWord" => "FrameContentSequence",
      "Name" => "Frame Content Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9111",
      "group" => "0020"
    },
    "37139" => {
      "KeyWord" => "PlanePositionSequence",
      "Name" => "Plane Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9113",
      "group" => "0020"
    },
    "37142" => {
      "KeyWord" => "PlaneOrientationSequence",
      "Name" => "Plane Orientation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9116",
      "group" => "0020"
    },
    "37160" => {
      "KeyWord" => "TemporalPositionIndex",
      "Name" => "Temporal Position Index",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9128",
      "group" => "0020"
    },
    "37203" => {
      "KeyWord" => "NominalCardiacTriggerDelayTime",
      "Name" => "Nominal Cardiac Trigger Delay Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9153",
      "group" => "0020"
    },
    "37204" => {
      "KeyWord" => "NominalCardiacTriggerTimePriorToRPeak",
      "Name" => "Nominal Cardiac Trigger Time Prior To R-Peak",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9154",
      "group" => "0020"
    },
    "37205" => {
      "KeyWord" => "ActualCardiacTriggerTimePriorToRPeak",
      "Name" => "Actual Cardiac Trigger Time Prior To R-Peak",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9155",
      "group" => "0020"
    },
    "37206" => {
      "KeyWord" => "FrameAcquisitionNumber",
      "Name" => "Frame Acquisition Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9156",
      "group" => "0020"
    },
    "37207" => {
      "KeyWord" => "DimensionIndexValues",
      "Name" => "Dimension Index Values",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "9157",
      "group" => "0020"
    },
    "37208" => {
      "KeyWord" => "FrameComments",
      "Name" => "Frame Comments",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "9158",
      "group" => "0020"
    },
    "37217" => {
      "KeyWord" => "ConcatenationUID",
      "Name" => "Concatenation UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "9161",
      "group" => "0020"
    },
    "37218" => {
      "KeyWord" => "InConcatenationNumber",
      "Name" => "In-concatenation Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9162",
      "group" => "0020"
    },
    "37219" => {
      "KeyWord" => "InConcatenationTotalNumber",
      "Name" => "In-concatenation Total Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9163",
      "group" => "0020"
    },
    "37220" => {
      "KeyWord" => "DimensionOrganizationUID",
      "Name" => "Dimension Organization UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "9164",
      "group" => "0020"
    },
    "37221" => {
      "KeyWord" => "DimensionIndexPointer",
      "Name" => "Dimension Index Pointer",
      "VM" => "1",
      "VR" => "AT",
      "ele" => "9165",
      "group" => "0020"
    },
    "37223" => {
      "KeyWord" => "FunctionalGroupPointer",
      "Name" => "Functional Group Pointer",
      "VM" => "1",
      "VR" => "AT",
      "ele" => "9167",
      "group" => "0020"
    },
    "37232" => {
      "KeyWord" => "UnassignedSharedConvertedAttributesSequence",
      "Name" => "Unassigned Shared Converted Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9170",
      "group" => "0020"
    },
    "37233" => {
      "KeyWord" => "UnassignedPerFrameConvertedAttributesSequence",
      "Name" => "Unassigned Per-Frame Converted Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9171",
      "group" => "0020"
    },
    "37234" => {
      "KeyWord" => "ConversionSourceAttributesSequence",
      "Name" => "Conversion Source Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9172",
      "group" => "0020"
    },
    "37395" => {
      "KeyWord" => "DimensionIndexPrivateCreator",
      "Name" => "Dimension Index Private Creator",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9213",
      "group" => "0020"
    },
    "37409" => {
      "KeyWord" => "DimensionOrganizationSequence",
      "Name" => "Dimension Organization Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9221",
      "group" => "0020"
    },
    "37410" => {
      "KeyWord" => "DimensionIndexSequence",
      "Name" => "Dimension Index Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9222",
      "group" => "0020"
    },
    "37416" => {
      "KeyWord" => "ConcatenationFrameOffsetNumber",
      "Name" => "Concatenation Frame Offset Number",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9228",
      "group" => "0020"
    },
    "37432" => {
      "KeyWord" => "FunctionalGroupPrivateCreator",
      "Name" => "Functional Group Private Creator",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9238",
      "group" => "0020"
    },
    "37441" => {
      "KeyWord" => "NominalPercentageOfCardiacPhase",
      "Name" => "Nominal Percentage of Cardiac Phase",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9241",
      "group" => "0020"
    },
    "37445" => {
      "KeyWord" => "NominalPercentageOfRespiratoryPhase",
      "Name" => "Nominal Percentage of Respiratory Phase",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9245",
      "group" => "0020"
    },
    "37446" => {
      "KeyWord" => "StartingRespiratoryAmplitude",
      "Name" => "Starting Respiratory Amplitude",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9246",
      "group" => "0020"
    },
    "37447" => {
      "KeyWord" => "StartingRespiratoryPhase",
      "Name" => "Starting Respiratory Phase",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9247",
      "group" => "0020"
    },
    "37448" => {
      "KeyWord" => "EndingRespiratoryAmplitude",
      "Name" => "Ending Respiratory Amplitude",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9248",
      "group" => "0020"
    },
    "37449" => {
      "KeyWord" => "EndingRespiratoryPhase",
      "Name" => "Ending Respiratory Phase",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9249",
      "group" => "0020"
    },
    "37456" => {
      "KeyWord" => "RespiratoryTriggerType",
      "Name" => "Respiratory Trigger Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9250",
      "group" => "0020"
    },
    "37457" => {
      "KeyWord" => "RRIntervalTimeNominal",
      "Name" => "R-R Interval Time Nominal",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9251",
      "group" => "0020"
    },
    "37458" => {
      "KeyWord" => "ActualCardiacTriggerDelayTime",
      "Name" => "Actual Cardiac Trigger Delay Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9252",
      "group" => "0020"
    },
    "37459" => {
      "KeyWord" => "RespiratorySynchronizationSequence",
      "Name" => "Respiratory Synchronization Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9253",
      "group" => "0020"
    },
    "37460" => {
      "KeyWord" => "RespiratoryIntervalTime",
      "Name" => "Respiratory Interval Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9254",
      "group" => "0020"
    },
    "37461" => {
      "KeyWord" => "NominalRespiratoryTriggerDelayTime",
      "Name" => "Nominal Respiratory Trigger Delay Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9255",
      "group" => "0020"
    },
    "37462" => {
      "KeyWord" => "RespiratoryTriggerDelayThreshold",
      "Name" => "Respiratory Trigger Delay Threshold",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9256",
      "group" => "0020"
    },
    "37463" => {
      "KeyWord" => "ActualRespiratoryTriggerDelayTime",
      "Name" => "Actual Respiratory Trigger Delay Time",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9257",
      "group" => "0020"
    },
    "37633" => {
      "KeyWord" => "ImagePositionVolume",
      "Name" => "Image Position (Volume)",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9301",
      "group" => "0020"
    },
    "37634" => {
      "KeyWord" => "ImageOrientationVolume",
      "Name" => "Image Orientation (Volume)",
      "VM" => "6",
      "VR" => "FD",
      "ele" => "9302",
      "group" => "0020"
    },
    "37639" => {
      "KeyWord" => "UltrasoundAcquisitionGeometry",
      "Name" => "Ultrasound Acquisition Geometry",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9307",
      "group" => "0020"
    },
    "37640" => {
      "KeyWord" => "ApexPosition",
      "Name" => "Apex Position",
      "VM" => "3",
      "VR" => "FD",
      "ele" => "9308",
      "group" => "0020"
    },
    "37641" => {
      "KeyWord" => "VolumeToTransducerMappingMatrix",
      "Name" => "Volume to Transducer Mapping Matrix",
      "VM" => "16",
      "VR" => "FD",
      "ele" => "9309",
      "group" => "0020"
    },
    "37642" => {
      "KeyWord" => "VolumeToTableMappingMatrix",
      "Name" => "Volume to Table Mapping Matrix",
      "VM" => "16",
      "VR" => "FD",
      "ele" => "930a",
      "group" => "0020"
    },
    "37644" => {
      "KeyWord" => "PatientFrameOfReferenceSource",
      "Name" => "Patient Frame of Reference Source",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "930c",
      "group" => "0020"
    },
    "37645" => {
      "KeyWord" => "TemporalPositionTimeOffset",
      "Name" => "Temporal Position Time Offset",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "930d",
      "group" => "0020"
    },
    "37646" => {
      "KeyWord" => "PlanePositionVolumeSequence",
      "Name" => "Plane Position (Volume) Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "930e",
      "group" => "0020"
    },
    "37647" => {
      "KeyWord" => "PlaneOrientationVolumeSequence",
      "Name" => "Plane Orientation (Volume) Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "930f",
      "group" => "0020"
    },
    "37648" => {
      "KeyWord" => "TemporalPositionSequence",
      "Name" => "Temporal Position Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9310",
      "group" => "0020"
    },
    "37649" => {
      "KeyWord" => "DimensionOrganizationType",
      "Name" => "Dimension Organization Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9311",
      "group" => "0020"
    },
    "37650" => {
      "KeyWord" => "VolumeFrameOfReferenceUID",
      "Name" => "Volume Frame of Reference UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "9312",
      "group" => "0020"
    },
    "37651" => {
      "KeyWord" => "TableFrameOfReferenceUID",
      "Name" => "Table Frame of Reference UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "9313",
      "group" => "0020"
    },
    "37921" => {
      "KeyWord" => "DimensionDescriptionLabel",
      "Name" => "Dimension Description Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9421",
      "group" => "0020"
    },
    "37968" => {
      "KeyWord" => "PatientOrientationInFrameSequence",
      "Name" => "Patient Orientation in Frame Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9450",
      "group" => "0020"
    },
    "37971" => {
      "KeyWord" => "FrameLabel",
      "Name" => "Frame Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "9453",
      "group" => "0020"
    },
    "38" => {
      "KeyWord" => "LUTNumber",
      "Name" => "LUT Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0026",
      "group" => "0020"
    },
    "38168" => {
      "KeyWord" => "AcquisitionIndex",
      "Name" => "Acquisition Index",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "9518",
      "group" => "0020"
    },
    "38185" => {
      "KeyWord" => "ContributingSOPInstancesReferenceSequence",
      "Name" => "Contributing SOP Instances Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9529",
      "group" => "0020"
    },
    "38198" => {
      "KeyWord" => "ReconstructionIndex",
      "Name" => "Reconstruction Index",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9536",
      "group" => "0020"
    },
    "4096" => {
      "KeyWord" => "SeriesInStudy",
      "Name" => "Series in Study",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1000",
      "group" => "0020"
    },
    "4097" => {
      "KeyWord" => "AcquisitionsInSeries",
      "Name" => "Acquisitions in Series",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1001",
      "group" => "0020"
    },
    "4098" => {
      "KeyWord" => "ImagesInAcquisition",
      "Name" => "Images in Acquisition",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1002",
      "group" => "0020"
    },
    "4099" => {
      "KeyWord" => "ImagesInSeries",
      "Name" => "Images in Series",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1003",
      "group" => "0020"
    },
    "4100" => {
      "KeyWord" => "AcquisitionsInStudy",
      "Name" => "Acquisitions in Study",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1004",
      "group" => "0020"
    },
    "4101" => {
      "KeyWord" => "ImagesInStudy",
      "Name" => "Images in Study",
      "RET" => "1",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1005",
      "group" => "0020"
    },
    "4128" => {
      "KeyWord" => "Reference",
      "Name" => "Reference",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1020",
      "group" => "0020"
    },
    "4160" => {
      "KeyWord" => "PositionReferenceIndicator",
      "Name" => "Position Reference Indicator",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1040",
      "group" => "0020"
    },
    "4161" => {
      "KeyWord" => "SliceLocation",
      "Name" => "Slice Location",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1041",
      "group" => "0020"
    },
    "4208" => {
      "KeyWord" => "OtherStudyNumbers",
      "Name" => "Other Study Numbers",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "1070",
      "group" => "0020"
    },
    "4608" => {
      "KeyWord" => "NumberOfPatientRelatedStudies",
      "Name" => "Number of Patient Related Studies",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1200",
      "group" => "0020"
    },
    "4610" => {
      "KeyWord" => "NumberOfPatientRelatedSeries",
      "Name" => "Number of Patient Related Series",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1202",
      "group" => "0020"
    },
    "4612" => {
      "KeyWord" => "NumberOfPatientRelatedInstances",
      "Name" => "Number of Patient Related Instances",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1204",
      "group" => "0020"
    },
    "4614" => {
      "KeyWord" => "NumberOfStudyRelatedSeries",
      "Name" => "Number of Study Related Series",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1206",
      "group" => "0020"
    },
    "4616" => {
      "KeyWord" => "NumberOfStudyRelatedInstances",
      "Name" => "Number of Study Related Instances",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1208",
      "group" => "0020"
    },
    "4617" => {
      "KeyWord" => "NumberOfSeriesRelatedInstances",
      "Name" => "Number of Series Related Instances",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1209",
      "group" => "0020"
    },
    "48" => {
      "KeyWord" => "ImagePosition",
      "Name" => "Image Position",
      "RET" => "1",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "0030",
      "group" => "0020"
    },
    "50" => {
      "KeyWord" => "ImagePositionPatient",
      "Name" => "Image Position (Patient)",
      "VM" => "3",
      "VR" => "DS",
      "ele" => "0032",
      "group" => "0020"
    },
    "512" => {
      "KeyWord" => "SynchronizationFrameOfReferenceUID",
      "Name" => "Synchronization Frame of Reference UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0200",
      "group" => "0020"
    },
    "53" => {
      "KeyWord" => "ImageOrientation",
      "Name" => "Image Orientation",
      "RET" => "1",
      "VM" => "6",
      "VR" => "DS",
      "ele" => "0035",
      "group" => "0020"
    },
    "55" => {
      "KeyWord" => "ImageOrientationPatient",
      "Name" => "Image Orientation (Patient)",
      "VM" => "6",
      "VR" => "DS",
      "ele" => "0037",
      "group" => "0020"
    },
    "578" => {
      "KeyWord" => "SOPInstanceUIDOfConcatenationSource",
      "Name" => "SOP Instance UID of Concatenation Source",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0242",
      "group" => "0020"
    },
    "80" => {
      "KeyWord" => "Location",
      "Name" => "Location",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0050",
      "group" => "0020"
    },
    "82" => {
      "KeyWord" => "FrameOfReferenceUID",
      "Name" => "Frame of Reference UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0052",
      "group" => "0020"
    },
    "96" => {
      "KeyWord" => "Laterality",
      "Name" => "Laterality",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0060",
      "group" => "0020"
    },
    "98" => {
      "KeyWord" => "ImageLaterality",
      "Name" => "Image Laterality",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0062",
      "group" => "0020"
    }
  },
  "32736" => {
    "16" => {
      "KeyWord" => "PixelData",
      "Name" => "Pixel Data",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0010",
      "group" => "7fe0"
    },
    "32" => {
      "KeyWord" => "CoefficientsSDVN",
      "Name" => "Coefficients SDVN",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "0020",
      "group" => "7fe0"
    },
    "48" => {
      "KeyWord" => "CoefficientsSDHN",
      "Name" => "Coefficients SDHN",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "0030",
      "group" => "7fe0"
    },
    "64" => {
      "KeyWord" => "CoefficientsSDDN",
      "Name" => "Coefficients SDDN",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "0040",
      "group" => "7fe0"
    }
  },
  "34" => {
    "1" => {
      "KeyWord" => "LightPathFilterPassThroughWavelength",
      "Name" => "Light Path Filter Pass-Through Wavelength",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0001",
      "group" => "0022"
    },
    "10" => {
      "KeyWord" => "EmmetropicMagnification",
      "Name" => "Emmetropic Magnification",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "000a",
      "group" => "0022"
    },
    "11" => {
      "KeyWord" => "IntraOcularPressure",
      "Name" => "Intra Ocular Pressure",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "000b",
      "group" => "0022"
    },
    "12" => {
      "KeyWord" => "HorizontalFieldOfView",
      "Name" => "Horizontal Field of View",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "000c",
      "group" => "0022"
    },
    "13" => {
      "KeyWord" => "PupilDilated",
      "Name" => "Pupil Dilated",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000d",
      "group" => "0022"
    },
    "14" => {
      "KeyWord" => "DegreeOfDilation",
      "Name" => "Degree of Dilation",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "000e",
      "group" => "0022"
    },
    "16" => {
      "KeyWord" => "StereoBaselineAngle",
      "Name" => "Stereo Baseline Angle",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0010",
      "group" => "0022"
    },
    "17" => {
      "KeyWord" => "StereoBaselineDisplacement",
      "Name" => "Stereo Baseline Displacement",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0011",
      "group" => "0022"
    },
    "18" => {
      "KeyWord" => "StereoHorizontalPixelOffset",
      "Name" => "Stereo Horizontal Pixel Offset",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0012",
      "group" => "0022"
    },
    "19" => {
      "KeyWord" => "StereoVerticalPixelOffset",
      "Name" => "Stereo Vertical Pixel Offset",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0013",
      "group" => "0022"
    },
    "2" => {
      "KeyWord" => "LightPathFilterPassBand",
      "Name" => "Light Path Filter Pass Band",
      "VM" => "2",
      "VR" => "US",
      "ele" => "0002",
      "group" => "0022"
    },
    "20" => {
      "KeyWord" => "StereoRotation",
      "Name" => "Stereo Rotation",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0014",
      "group" => "0022"
    },
    "21" => {
      "KeyWord" => "AcquisitionDeviceTypeCodeSequence",
      "Name" => "Acquisition Device Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0015",
      "group" => "0022"
    },
    "22" => {
      "KeyWord" => "IlluminationTypeCodeSequence",
      "Name" => "Illumination Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0016",
      "group" => "0022"
    },
    "23" => {
      "KeyWord" => "LightPathFilterTypeStackCodeSequence",
      "Name" => "Light Path Filter Type Stack Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0017",
      "group" => "0022"
    },
    "24" => {
      "KeyWord" => "ImagePathFilterTypeStackCodeSequence",
      "Name" => "Image Path Filter Type Stack Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0018",
      "group" => "0022"
    },
    "25" => {
      "KeyWord" => "LensesCodeSequence",
      "Name" => "Lenses Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0019",
      "group" => "0022"
    },
    "26" => {
      "KeyWord" => "ChannelDescriptionCodeSequence",
      "Name" => "Channel Description Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "001a",
      "group" => "0022"
    },
    "27" => {
      "KeyWord" => "RefractiveStateSequence",
      "Name" => "Refractive State Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "001b",
      "group" => "0022"
    },
    "28" => {
      "KeyWord" => "MydriaticAgentCodeSequence",
      "Name" => "Mydriatic Agent Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "001c",
      "group" => "0022"
    },
    "29" => {
      "KeyWord" => "RelativeImagePositionCodeSequence",
      "Name" => "Relative Image Position Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "001d",
      "group" => "0022"
    },
    "3" => {
      "KeyWord" => "ImagePathFilterPassThroughWavelength",
      "Name" => "Image Path Filter Pass-Through Wavelength",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0003",
      "group" => "0022"
    },
    "30" => {
      "KeyWord" => "CameraAngleOfView",
      "Name" => "Camera Angle of View",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "001e",
      "group" => "0022"
    },
    "32" => {
      "KeyWord" => "StereoPairsSequence",
      "Name" => "Stereo Pairs Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0020",
      "group" => "0022"
    },
    "33" => {
      "KeyWord" => "LeftImageSequence",
      "Name" => "Left Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0021",
      "group" => "0022"
    },
    "34" => {
      "KeyWord" => "RightImageSequence",
      "Name" => "Right Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0022",
      "group" => "0022"
    },
    "4" => {
      "KeyWord" => "ImagePathFilterPassBand",
      "Name" => "Image Path Filter Pass Band",
      "VM" => "2",
      "VR" => "US",
      "ele" => "0004",
      "group" => "0022"
    },
    "4103" => {
      "KeyWord" => "OphthalmicAxialMeasurementsRightEyeSequence",
      "Name" => "Ophthalmic Axial Measurements Right Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1007",
      "group" => "0022"
    },
    "4104" => {
      "KeyWord" => "OphthalmicAxialMeasurementsLeftEyeSequence",
      "Name" => "Ophthalmic Axial Measurements Left Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1008",
      "group" => "0022"
    },
    "4105" => {
      "KeyWord" => "OphthalmicAxialMeasurementsDeviceType",
      "Name" => "Ophthalmic Axial Measurements Device Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1009",
      "group" => "0022"
    },
    "4112" => {
      "KeyWord" => "OphthalmicAxialLengthMeasurementsType",
      "Name" => "Ophthalmic Axial Length Measurements Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1010",
      "group" => "0022"
    },
    "4114" => {
      "KeyWord" => "OphthalmicAxialLengthSequence",
      "Name" => "Ophthalmic Axial Length Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1012",
      "group" => "0022"
    },
    "4121" => {
      "KeyWord" => "OphthalmicAxialLength",
      "Name" => "Ophthalmic Axial Length",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1019",
      "group" => "0022"
    },
    "4132" => {
      "KeyWord" => "LensStatusCodeSequence",
      "Name" => "Lens Status Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1024",
      "group" => "0022"
    },
    "4133" => {
      "KeyWord" => "VitreousStatusCodeSequence",
      "Name" => "Vitreous Status Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1025",
      "group" => "0022"
    },
    "4136" => {
      "KeyWord" => "IOLFormulaCodeSequence",
      "Name" => "IOL Formula Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1028",
      "group" => "0022"
    },
    "4137" => {
      "KeyWord" => "IOLFormulaDetail",
      "Name" => "IOL Formula Detail",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1029",
      "group" => "0022"
    },
    "4147" => {
      "KeyWord" => "KeratometerIndex",
      "Name" => "Keratometer Index",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1033",
      "group" => "0022"
    },
    "4149" => {
      "KeyWord" => "SourceOfOphthalmicAxialLengthCodeSequence",
      "Name" => "Source of Ophthalmic Axial Length Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1035",
      "group" => "0022"
    },
    "4151" => {
      "KeyWord" => "TargetRefraction",
      "Name" => "Target Refraction",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1037",
      "group" => "0022"
    },
    "4153" => {
      "KeyWord" => "RefractiveProcedureOccurred",
      "Name" => "Refractive Procedure Occurred",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1039",
      "group" => "0022"
    },
    "4160" => {
      "KeyWord" => "RefractiveSurgeryTypeCodeSequence",
      "Name" => "Refractive Surgery Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1040",
      "group" => "0022"
    },
    "4164" => {
      "KeyWord" => "OphthalmicUltrasoundMethodCodeSequence",
      "Name" => "Ophthalmic Ultrasound Method Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1044",
      "group" => "0022"
    },
    "4176" => {
      "KeyWord" => "OphthalmicAxialLengthMeasurementsSequence",
      "Name" => "Ophthalmic Axial Length Measurements Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1050",
      "group" => "0022"
    },
    "4179" => {
      "KeyWord" => "IOLPower",
      "Name" => "IOL Power",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1053",
      "group" => "0022"
    },
    "4180" => {
      "KeyWord" => "PredictedRefractiveError",
      "Name" => "Predicted Refractive Error",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1054",
      "group" => "0022"
    },
    "4185" => {
      "KeyWord" => "OphthalmicAxialLengthVelocity",
      "Name" => "Ophthalmic Axial Length Velocity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1059",
      "group" => "0022"
    },
    "4197" => {
      "KeyWord" => "LensStatusDescription",
      "Name" => "Lens Status Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1065",
      "group" => "0022"
    },
    "4198" => {
      "KeyWord" => "VitreousStatusDescription",
      "Name" => "Vitreous Status Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1066",
      "group" => "0022"
    },
    "4240" => {
      "KeyWord" => "IOLPowerSequence",
      "Name" => "IOL Power Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1090",
      "group" => "0022"
    },
    "4242" => {
      "KeyWord" => "LensConstantSequence",
      "Name" => "Lens Constant Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1092",
      "group" => "0022"
    },
    "4243" => {
      "KeyWord" => "IOLManufacturer",
      "Name" => "IOL Manufacturer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1093",
      "group" => "0022"
    },
    "4244" => {
      "KeyWord" => "LensConstantDescription",
      "Name" => "Lens Constant Description",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1094",
      "group" => "0022"
    },
    "4245" => {
      "KeyWord" => "ImplantName",
      "Name" => "Implant Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1095",
      "group" => "0022"
    },
    "4246" => {
      "KeyWord" => "KeratometryMeasurementTypeCodeSequence",
      "Name" => "Keratometry Measurement Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1096",
      "group" => "0022"
    },
    "4247" => {
      "KeyWord" => "ImplantPartNumber",
      "Name" => "Implant Part Number",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1097",
      "group" => "0022"
    },
    "4352" => {
      "KeyWord" => "ReferencedOphthalmicAxialMeasurementsSequence",
      "Name" => "Referenced Ophthalmic Axial Measurements Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1100",
      "group" => "0022"
    },
    "4353" => {
      "KeyWord" => "OphthalmicAxialLengthMeasurementsSegmentNameCodeSequence",
      "Name" => "Ophthalmic Axial Length Measurements Segment Name Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1101",
      "group" => "0022"
    },
    "4355" => {
      "KeyWord" => "RefractiveErrorBeforeRefractiveSurgeryCodeSequence",
      "Name" => "Refractive Error Before Refractive Surgery Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1103",
      "group" => "0022"
    },
    "4385" => {
      "KeyWord" => "IOLPowerForExactEmmetropia",
      "Name" => "IOL Power For Exact Emmetropia",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1121",
      "group" => "0022"
    },
    "4386" => {
      "KeyWord" => "IOLPowerForExactTargetRefraction",
      "Name" => "IOL Power For Exact Target Refraction",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1122",
      "group" => "0022"
    },
    "4389" => {
      "KeyWord" => "AnteriorChamberDepthDefinitionCodeSequence",
      "Name" => "Anterior Chamber Depth Definition Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1125",
      "group" => "0022"
    },
    "4391" => {
      "KeyWord" => "LensThicknessSequence",
      "Name" => "Lens Thickness Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1127",
      "group" => "0022"
    },
    "4392" => {
      "KeyWord" => "AnteriorChamberDepthSequence",
      "Name" => "Anterior Chamber Depth Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1128",
      "group" => "0022"
    },
    "4400" => {
      "KeyWord" => "LensThickness",
      "Name" => "Lens Thickness",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1130",
      "group" => "0022"
    },
    "4401" => {
      "KeyWord" => "AnteriorChamberDepth",
      "Name" => "Anterior Chamber Depth",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1131",
      "group" => "0022"
    },
    "4402" => {
      "KeyWord" => "SourceOfLensThicknessDataCodeSequence",
      "Name" => "Source of Lens Thickness Data Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1132",
      "group" => "0022"
    },
    "4403" => {
      "KeyWord" => "SourceOfAnteriorChamberDepthDataCodeSequence",
      "Name" => "Source of Anterior Chamber Depth Data Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1133",
      "group" => "0022"
    },
    "4404" => {
      "KeyWord" => "SourceOfRefractiveMeasurementsSequence",
      "Name" => "Source of Refractive Measurements Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1134",
      "group" => "0022"
    },
    "4405" => {
      "KeyWord" => "SourceOfRefractiveMeasurementsCodeSequence",
      "Name" => "Source of Refractive Measurements Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1135",
      "group" => "0022"
    },
    "4416" => {
      "KeyWord" => "OphthalmicAxialLengthMeasurementModified",
      "Name" => "Ophthalmic Axial Length Measurement Modified",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1140",
      "group" => "0022"
    },
    "4432" => {
      "KeyWord" => "OphthalmicAxialLengthDataSourceCodeSequence",
      "Name" => "Ophthalmic Axial Length Data Source Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1150",
      "group" => "0022"
    },
    "4435" => {
      "KeyWord" => "OphthalmicAxialLengthAcquisitionMethodCodeSequence",
      "Name" => "Ophthalmic Axial Length Acquisition Method Code Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1153",
      "group" => "0022"
    },
    "4437" => {
      "KeyWord" => "SignalToNoiseRatio",
      "Name" => "Signal to Noise Ratio",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1155",
      "group" => "0022"
    },
    "4441" => {
      "KeyWord" => "OphthalmicAxialLengthDataSourceDescription",
      "Name" => "Ophthalmic Axial Length Data Source Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1159",
      "group" => "0022"
    },
    "4624" => {
      "KeyWord" => "OphthalmicAxialLengthMeasurementsTotalLengthSequence",
      "Name" => "Ophthalmic Axial Length Measurements Total Length Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1210",
      "group" => "0022"
    },
    "4625" => {
      "KeyWord" => "OphthalmicAxialLengthMeasurementsSegmentalLengthSequence",
      "Name" => "Ophthalmic Axial Length Measurements Segmental Length Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1211",
      "group" => "0022"
    },
    "4626" => {
      "KeyWord" => "OphthalmicAxialLengthMeasurementsLengthSummationSequence",
      "Name" => "Ophthalmic Axial Length Measurements Length Summation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1212",
      "group" => "0022"
    },
    "4640" => {
      "KeyWord" => "UltrasoundOphthalmicAxialLengthMeasurementsSequence",
      "Name" => "Ultrasound Ophthalmic Axial Length Measurements Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1220",
      "group" => "0022"
    },
    "4645" => {
      "KeyWord" => "OpticalOphthalmicAxialLengthMeasurementsSequence",
      "Name" => "Optical Ophthalmic Axial Length Measurements Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1225",
      "group" => "0022"
    },
    "4656" => {
      "KeyWord" => "UltrasoundSelectedOphthalmicAxialLengthSequence",
      "Name" => "Ultrasound Selected Ophthalmic Axial Length Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1230",
      "group" => "0022"
    },
    "4688" => {
      "KeyWord" => "OphthalmicAxialLengthSelectionMethodCodeSequence",
      "Name" => "Ophthalmic Axial Length Selection Method Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1250",
      "group" => "0022"
    },
    "4693" => {
      "KeyWord" => "OpticalSelectedOphthalmicAxialLengthSequence",
      "Name" => "Optical Selected Ophthalmic Axial Length Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1255",
      "group" => "0022"
    },
    "4695" => {
      "KeyWord" => "SelectedSegmentalOphthalmicAxialLengthSequence",
      "Name" => "Selected Segmental Ophthalmic Axial Length Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1257",
      "group" => "0022"
    },
    "4704" => {
      "KeyWord" => "SelectedTotalOphthalmicAxialLengthSequence",
      "Name" => "Selected Total Ophthalmic Axial Length Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1260",
      "group" => "0022"
    },
    "4706" => {
      "KeyWord" => "OphthalmicAxialLengthQualityMetricSequence",
      "Name" => "Ophthalmic Axial Length Quality Metric Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1262",
      "group" => "0022"
    },
    "4709" => {
      "KeyWord" => "OphthalmicAxialLengthQualityMetricTypeCodeSequence",
      "Name" => "Ophthalmic Axial Length Quality Metric Type Code Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1265",
      "group" => "0022"
    },
    "4723" => {
      "KeyWord" => "OphthalmicAxialLengthQualityMetricTypeDescription",
      "Name" => "Ophthalmic Axial Length Quality Metric Type Description",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1273",
      "group" => "0022"
    },
    "48" => {
      "KeyWord" => "AxialLengthOfTheEye",
      "Name" => "Axial Length of the Eye",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0030",
      "group" => "0022"
    },
    "4864" => {
      "KeyWord" => "IntraocularLensCalculationsRightEyeSequence",
      "Name" => "Intraocular Lens Calculations Right Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1300",
      "group" => "0022"
    },
    "4880" => {
      "KeyWord" => "IntraocularLensCalculationsLeftEyeSequence",
      "Name" => "Intraocular Lens Calculations Left Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1310",
      "group" => "0022"
    },
    "49" => {
      "KeyWord" => "OphthalmicFrameLocationSequence",
      "Name" => "Ophthalmic Frame Location Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0031",
      "group" => "0022"
    },
    "4912" => {
      "KeyWord" => "ReferencedOphthalmicAxialLengthMeasurementQCImageSequence",
      "Name" => "Referenced Ophthalmic Axial Length Measurement QC Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1330",
      "group" => "0022"
    },
    "5" => {
      "KeyWord" => "PatientEyeMovementCommanded",
      "Name" => "Patient Eye Movement Commanded",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0005",
      "group" => "0022"
    },
    "50" => {
      "KeyWord" => "ReferenceCoordinates",
      "Name" => "Reference Coordinates",
      "VM" => "2-2n",
      "VR" => "FL",
      "ele" => "0032",
      "group" => "0022"
    },
    "5141" => {
      "KeyWord" => "OphthalmicMappingDeviceType",
      "Name" => "Ophthalmic Mapping Device Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1415",
      "group" => "0022"
    },
    "5152" => {
      "KeyWord" => "AcquisitionMethodCodeSequence",
      "Name" => "Acquisition Method Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1420",
      "group" => "0022"
    },
    "5155" => {
      "KeyWord" => "AcquisitionMethodAlgorithmSequence",
      "Name" => "Acquisition Method Algorithm Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1423",
      "group" => "0022"
    },
    "5174" => {
      "KeyWord" => "OphthalmicThicknessMapTypeCodeSequence",
      "Name" => "Ophthalmic Thickness Map Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1436",
      "group" => "0022"
    },
    "5187" => {
      "KeyWord" => "OphthalmicThicknessMappingNormalsSequence",
      "Name" => "Ophthalmic Thickness Mapping Normals Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1443",
      "group" => "0022"
    },
    "5189" => {
      "KeyWord" => "RetinalThicknessDefinitionCodeSequence",
      "Name" => "Retinal Thickness Definition Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1445",
      "group" => "0022"
    },
    "5200" => {
      "KeyWord" => "PixelValueMappingToCodedConceptSequence",
      "Name" => "Pixel Value Mapping to Coded Concept Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1450",
      "group" => "0022"
    },
    "5202" => {
      "KeyWord" => "MappedPixelValue",
      "Name" => "Mapped Pixel Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "1452",
      "group" => "0022"
    },
    "5204" => {
      "KeyWord" => "PixelValueMappingExplanation",
      "Name" => "Pixel Value Mapping Explanation",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1454",
      "group" => "0022"
    },
    "5208" => {
      "KeyWord" => "OphthalmicThicknessMapQualityThresholdSequence",
      "Name" => "Ophthalmic Thickness Map Quality Threshold Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1458",
      "group" => "0022"
    },
    "5216" => {
      "KeyWord" => "OphthalmicThicknessMapThresholdQualityRating",
      "Name" => "Ophthalmic Thickness Map Threshold Quality Rating",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "1460",
      "group" => "0022"
    },
    "5219" => {
      "KeyWord" => "AnatomicStructureReferencePoint",
      "Name" => "Anatomic Structure Reference Point",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "1463",
      "group" => "0022"
    },
    "5221" => {
      "KeyWord" => "RegistrationToLocalizerSequence",
      "Name" => "Registration to Localizer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1465",
      "group" => "0022"
    },
    "5222" => {
      "KeyWord" => "RegisteredLocalizerUnits",
      "Name" => "Registered Localizer Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1466",
      "group" => "0022"
    },
    "5223" => {
      "KeyWord" => "RegisteredLocalizerTopLeftHandCorner",
      "Name" => "Registered Localizer Top Left Hand Corner",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "1467",
      "group" => "0022"
    },
    "5224" => {
      "KeyWord" => "RegisteredLocalizerBottomRightHandCorner",
      "Name" => "Registered Localizer Bottom Right Hand Corner",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "1468",
      "group" => "0022"
    },
    "5232" => {
      "KeyWord" => "OphthalmicThicknessMapQualityRatingSequence",
      "Name" => "Ophthalmic Thickness Map Quality Rating Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1470",
      "group" => "0022"
    },
    "5234" => {
      "KeyWord" => "RelevantOPTAttributesSequence",
      "Name" => "Relevant OPT Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1472",
      "group" => "0022"
    },
    "53" => {
      "KeyWord" => "DepthSpatialResolution",
      "Name" => "Depth Spatial Resolution",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0035",
      "group" => "0022"
    },
    "54" => {
      "KeyWord" => "MaximumDepthDistortion",
      "Name" => "Maximum Depth Distortion",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0036",
      "group" => "0022"
    },
    "55" => {
      "KeyWord" => "AlongScanSpatialResolution",
      "Name" => "Along-scan Spatial Resolution",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0037",
      "group" => "0022"
    },
    "56" => {
      "KeyWord" => "MaximumAlongScanDistortion",
      "Name" => "Maximum Along-scan Distortion",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0038",
      "group" => "0022"
    },
    "57" => {
      "KeyWord" => "OphthalmicImageOrientation",
      "Name" => "Ophthalmic Image Orientation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0039",
      "group" => "0022"
    },
    "6" => {
      "KeyWord" => "PatientEyeMovementCommandCodeSequence",
      "Name" => "Patient Eye Movement Command Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0006",
      "group" => "0022"
    },
    "65" => {
      "KeyWord" => "DepthOfTransverseImage",
      "Name" => "Depth of Transverse Image",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0041",
      "group" => "0022"
    },
    "66" => {
      "KeyWord" => "MydriaticAgentConcentrationUnitsSequence",
      "Name" => "Mydriatic Agent Concentration Units Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0042",
      "group" => "0022"
    },
    "7" => {
      "KeyWord" => "SphericalLensPower",
      "Name" => "Spherical Lens Power",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0007",
      "group" => "0022"
    },
    "72" => {
      "KeyWord" => "AcrossScanSpatialResolution",
      "Name" => "Across-scan Spatial Resolution",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0048",
      "group" => "0022"
    },
    "73" => {
      "KeyWord" => "MaximumAcrossScanDistortion",
      "Name" => "Maximum Across-scan Distortion",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0049",
      "group" => "0022"
    },
    "78" => {
      "KeyWord" => "MydriaticAgentConcentration",
      "Name" => "Mydriatic Agent Concentration",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "004e",
      "group" => "0022"
    },
    "8" => {
      "KeyWord" => "CylinderLensPower",
      "Name" => "Cylinder Lens Power",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0008",
      "group" => "0022"
    },
    "85" => {
      "KeyWord" => "IlluminationWaveLength",
      "Name" => "Illumination Wave Length",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0055",
      "group" => "0022"
    },
    "86" => {
      "KeyWord" => "IlluminationPower",
      "Name" => "Illumination Power",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0056",
      "group" => "0022"
    },
    "87" => {
      "KeyWord" => "IlluminationBandwidth",
      "Name" => "Illumination Bandwidth",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0057",
      "group" => "0022"
    },
    "88" => {
      "KeyWord" => "MydriaticAgentSequence",
      "Name" => "Mydriatic Agent Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0058",
      "group" => "0022"
    },
    "9" => {
      "KeyWord" => "CylinderAxis",
      "Name" => "Cylinder Axis",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0009",
      "group" => "0022"
    }
  },
  "36" => {
    "100" => {
      "KeyWord" => "ResultsNormalsSequence",
      "Name" => "Results Normals Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0064",
      "group" => "0024"
    },
    "101" => {
      "KeyWord" => "AgeCorrectedSensitivityDeviationAlgorithmSequence",
      "Name" => "Age Corrected Sensitivity Deviation Algorithm Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0065",
      "group" => "0024"
    },
    "102" => {
      "KeyWord" => "GlobalDeviationFromNormal",
      "Name" => "Global Deviation From Normal",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0066",
      "group" => "0024"
    },
    "103" => {
      "KeyWord" => "GeneralizedDefectSensitivityDeviationAlgorithmSequence",
      "Name" => "Generalized Defect Sensitivity Deviation Algorithm Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0067",
      "group" => "0024"
    },
    "104" => {
      "KeyWord" => "LocalizedDeviationFromNormal",
      "Name" => "Localized Deviation From Normal",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0068",
      "group" => "0024"
    },
    "105" => {
      "KeyWord" => "PatientReliabilityIndicator",
      "Name" => "Patient Reliability Indicator",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0069",
      "group" => "0024"
    },
    "112" => {
      "KeyWord" => "VisualFieldMeanSensitivity",
      "Name" => "Visual Field Mean Sensitivity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0070",
      "group" => "0024"
    },
    "113" => {
      "KeyWord" => "GlobalDeviationProbability",
      "Name" => "Global Deviation Probability",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0071",
      "group" => "0024"
    },
    "114" => {
      "KeyWord" => "LocalDeviationProbabilityNormalsFlag",
      "Name" => "Local Deviation Probability Normals Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0072",
      "group" => "0024"
    },
    "115" => {
      "KeyWord" => "LocalizedDeviationProbability",
      "Name" => "Localized Deviation Probability",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0073",
      "group" => "0024"
    },
    "116" => {
      "KeyWord" => "ShortTermFluctuationCalculated",
      "Name" => "Short Term Fluctuation Calculated",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0074",
      "group" => "0024"
    },
    "117" => {
      "KeyWord" => "ShortTermFluctuation",
      "Name" => "Short Term Fluctuation",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0075",
      "group" => "0024"
    },
    "118" => {
      "KeyWord" => "ShortTermFluctuationProbabilityCalculated",
      "Name" => "Short Term Fluctuation Probability Calculated",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0076",
      "group" => "0024"
    },
    "119" => {
      "KeyWord" => "ShortTermFluctuationProbability",
      "Name" => "Short Term Fluctuation Probability",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0077",
      "group" => "0024"
    },
    "120" => {
      "KeyWord" => "CorrectedLocalizedDeviationFromNormalCalculated",
      "Name" => "Corrected Localized Deviation From Normal Calculated",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0078",
      "group" => "0024"
    },
    "121" => {
      "KeyWord" => "CorrectedLocalizedDeviationFromNormal",
      "Name" => "Corrected Localized Deviation From Normal",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0079",
      "group" => "0024"
    },
    "128" => {
      "KeyWord" => "CorrectedLocalizedDeviationFromNormalProbabilityCalculated",
      "Name" => "Corrected Localized Deviation From Normal Probability Calculated",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0080",
      "group" => "0024"
    },
    "129" => {
      "KeyWord" => "CorrectedLocalizedDeviationFromNormalProbability",
      "Name" => "Corrected Localized Deviation From Normal Probability",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0081",
      "group" => "0024"
    },
    "131" => {
      "KeyWord" => "GlobalDeviationProbabilitySequence",
      "Name" => "Global Deviation Probability Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0083",
      "group" => "0024"
    },
    "133" => {
      "KeyWord" => "LocalizedDeviationProbabilitySequence",
      "Name" => "Localized Deviation Probability Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0085",
      "group" => "0024"
    },
    "134" => {
      "KeyWord" => "FovealSensitivityMeasured",
      "Name" => "Foveal Sensitivity Measured",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0086",
      "group" => "0024"
    },
    "135" => {
      "KeyWord" => "FovealSensitivity",
      "Name" => "Foveal Sensitivity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0087",
      "group" => "0024"
    },
    "136" => {
      "KeyWord" => "VisualFieldTestDuration",
      "Name" => "Visual Field Test Duration",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0088",
      "group" => "0024"
    },
    "137" => {
      "KeyWord" => "VisualFieldTestPointSequence",
      "Name" => "Visual Field Test Point Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0089",
      "group" => "0024"
    },
    "144" => {
      "KeyWord" => "VisualFieldTestPointXCoordinate",
      "Name" => "Visual Field Test Point X-Coordinate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0090",
      "group" => "0024"
    },
    "145" => {
      "KeyWord" => "VisualFieldTestPointYCoordinate",
      "Name" => "Visual Field Test Point Y-Coordinate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0091",
      "group" => "0024"
    },
    "146" => {
      "KeyWord" => "AgeCorrectedSensitivityDeviationValue",
      "Name" => "Age Corrected Sensitivity Deviation Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0092",
      "group" => "0024"
    },
    "147" => {
      "KeyWord" => "StimulusResults",
      "Name" => "Stimulus Results",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0093",
      "group" => "0024"
    },
    "148" => {
      "KeyWord" => "SensitivityValue",
      "Name" => "Sensitivity Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0094",
      "group" => "0024"
    },
    "149" => {
      "KeyWord" => "RetestStimulusSeen",
      "Name" => "Retest Stimulus Seen",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0095",
      "group" => "0024"
    },
    "150" => {
      "KeyWord" => "RetestSensitivityValue",
      "Name" => "Retest Sensitivity Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0096",
      "group" => "0024"
    },
    "151" => {
      "KeyWord" => "VisualFieldTestPointNormalsSequence",
      "Name" => "Visual Field Test Point Normals Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0097",
      "group" => "0024"
    },
    "152" => {
      "KeyWord" => "QuantifiedDefect",
      "Name" => "Quantified Defect",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0098",
      "group" => "0024"
    },
    "16" => {
      "KeyWord" => "VisualFieldHorizontalExtent",
      "Name" => "Visual Field Horizontal Extent",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0010",
      "group" => "0024"
    },
    "17" => {
      "KeyWord" => "VisualFieldVerticalExtent",
      "Name" => "Visual Field Vertical Extent",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0011",
      "group" => "0024"
    },
    "18" => {
      "KeyWord" => "VisualFieldShape",
      "Name" => "Visual Field Shape",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0012",
      "group" => "0024"
    },
    "22" => {
      "KeyWord" => "ScreeningTestModeCodeSequence",
      "Name" => "Screening Test Mode Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0016",
      "group" => "0024"
    },
    "24" => {
      "KeyWord" => "MaximumStimulusLuminance",
      "Name" => "Maximum Stimulus Luminance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0018",
      "group" => "0024"
    },
    "256" => {
      "KeyWord" => "AgeCorrectedSensitivityDeviationProbabilityValue",
      "Name" => "Age Corrected Sensitivity Deviation Probability Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0100",
      "group" => "0024"
    },
    "258" => {
      "KeyWord" => "GeneralizedDefectCorrectedSensitivityDeviationFlag",
      "Name" => "Generalized Defect Corrected Sensitivity Deviation Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0102",
      "group" => "0024"
    },
    "259" => {
      "KeyWord" => "GeneralizedDefectCorrectedSensitivityDeviationValue",
      "Name" => "Generalized Defect Corrected Sensitivity Deviation Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0103",
      "group" => "0024"
    },
    "260" => {
      "KeyWord" => "GeneralizedDefectCorrectedSensitivityDeviationProbabilityValue",
      "Name" => "Generalized Defect Corrected Sensitivity Deviation Probability Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0104",
      "group" => "0024"
    },
    "261" => {
      "KeyWord" => "MinimumSensitivityValue",
      "Name" => "Minimum Sensitivity Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0105",
      "group" => "0024"
    },
    "262" => {
      "KeyWord" => "BlindSpotLocalized",
      "Name" => "Blind Spot Localized",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0106",
      "group" => "0024"
    },
    "263" => {
      "KeyWord" => "BlindSpotXCoordinate",
      "Name" => "Blind Spot X-Coordinate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0107",
      "group" => "0024"
    },
    "264" => {
      "KeyWord" => "BlindSpotYCoordinate",
      "Name" => "Blind Spot Y-Coordinate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0108",
      "group" => "0024"
    },
    "272" => {
      "KeyWord" => "VisualAcuityMeasurementSequence",
      "Name" => "Visual Acuity Measurement Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0110",
      "group" => "0024"
    },
    "274" => {
      "KeyWord" => "RefractiveParametersUsedOnPatientSequence",
      "Name" => "Refractive Parameters Used on Patient Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0112",
      "group" => "0024"
    },
    "275" => {
      "KeyWord" => "MeasurementLaterality",
      "Name" => "Measurement Laterality",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0113",
      "group" => "0024"
    },
    "276" => {
      "KeyWord" => "OphthalmicPatientClinicalInformationLeftEyeSequence",
      "Name" => "Ophthalmic Patient Clinical Information Left Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0114",
      "group" => "0024"
    },
    "277" => {
      "KeyWord" => "OphthalmicPatientClinicalInformationRightEyeSequence",
      "Name" => "Ophthalmic Patient Clinical Information Right Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0115",
      "group" => "0024"
    },
    "279" => {
      "KeyWord" => "FovealPointNormativeDataFlag",
      "Name" => "Foveal Point Normative Data Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0117",
      "group" => "0024"
    },
    "280" => {
      "KeyWord" => "FovealPointProbabilityValue",
      "Name" => "Foveal Point Probability Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0118",
      "group" => "0024"
    },
    "288" => {
      "KeyWord" => "ScreeningBaselineMeasured",
      "Name" => "Screening Baseline Measured",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0120",
      "group" => "0024"
    },
    "290" => {
      "KeyWord" => "ScreeningBaselineMeasuredSequence",
      "Name" => "Screening Baseline Measured Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0122",
      "group" => "0024"
    },
    "292" => {
      "KeyWord" => "ScreeningBaselineType",
      "Name" => "Screening Baseline Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0124",
      "group" => "0024"
    },
    "294" => {
      "KeyWord" => "ScreeningBaselineValue",
      "Name" => "Screening Baseline Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0126",
      "group" => "0024"
    },
    "32" => {
      "KeyWord" => "BackgroundLuminance",
      "Name" => "Background Luminance",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0020",
      "group" => "0024"
    },
    "33" => {
      "KeyWord" => "StimulusColorCodeSequence",
      "Name" => "Stimulus Color Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0021",
      "group" => "0024"
    },
    "36" => {
      "KeyWord" => "BackgroundIlluminationColorCodeSequence",
      "Name" => "Background Illumination Color Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0024",
      "group" => "0024"
    },
    "37" => {
      "KeyWord" => "StimulusArea",
      "Name" => "Stimulus Area",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0025",
      "group" => "0024"
    },
    "40" => {
      "KeyWord" => "StimulusPresentationTime",
      "Name" => "Stimulus Presentation Time",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0028",
      "group" => "0024"
    },
    "50" => {
      "KeyWord" => "FixationSequence",
      "Name" => "Fixation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0032",
      "group" => "0024"
    },
    "51" => {
      "KeyWord" => "FixationMonitoringCodeSequence",
      "Name" => "Fixation Monitoring Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0033",
      "group" => "0024"
    },
    "514" => {
      "KeyWord" => "AlgorithmSource",
      "Name" => "Algorithm Source",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0202",
      "group" => "0024"
    },
    "52" => {
      "KeyWord" => "VisualFieldCatchTrialSequence",
      "Name" => "Visual Field Catch Trial Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0034",
      "group" => "0024"
    },
    "53" => {
      "KeyWord" => "FixationCheckedQuantity",
      "Name" => "Fixation Checked Quantity",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0035",
      "group" => "0024"
    },
    "54" => {
      "KeyWord" => "PatientNotProperlyFixatedQuantity",
      "Name" => "Patient Not Properly Fixated Quantity",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0036",
      "group" => "0024"
    },
    "55" => {
      "KeyWord" => "PresentedVisualStimuliDataFlag",
      "Name" => "Presented Visual Stimuli Data Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0037",
      "group" => "0024"
    },
    "56" => {
      "KeyWord" => "NumberOfVisualStimuli",
      "Name" => "Number of Visual Stimuli",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0038",
      "group" => "0024"
    },
    "57" => {
      "KeyWord" => "ExcessiveFixationLossesDataFlag",
      "Name" => "Excessive Fixation Losses Data Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0039",
      "group" => "0024"
    },
    "64" => {
      "KeyWord" => "ExcessiveFixationLosses",
      "Name" => "Excessive Fixation Losses",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0040",
      "group" => "0024"
    },
    "66" => {
      "KeyWord" => "StimuliRetestingQuantity",
      "Name" => "Stimuli Retesting Quantity",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0042",
      "group" => "0024"
    },
    "68" => {
      "KeyWord" => "CommentsOnPatientPerformanceOfVisualField",
      "Name" => "Comments on Patient's Performance of Visual Field",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0044",
      "group" => "0024"
    },
    "69" => {
      "KeyWord" => "FalseNegativesEstimateFlag",
      "Name" => "False Negatives Estimate Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0045",
      "group" => "0024"
    },
    "70" => {
      "KeyWord" => "FalseNegativesEstimate",
      "Name" => "False Negatives Estimate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0046",
      "group" => "0024"
    },
    "72" => {
      "KeyWord" => "NegativeCatchTrialsQuantity",
      "Name" => "Negative Catch Trials Quantity",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0048",
      "group" => "0024"
    },
    "774" => {
      "KeyWord" => "DataSetName",
      "Name" => "Data Set Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0306",
      "group" => "0024"
    },
    "775" => {
      "KeyWord" => "DataSetVersion",
      "Name" => "Data Set Version",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0307",
      "group" => "0024"
    },
    "776" => {
      "KeyWord" => "DataSetSource",
      "Name" => "Data Set Source",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0308",
      "group" => "0024"
    },
    "777" => {
      "KeyWord" => "DataSetDescription",
      "Name" => "Data Set Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0309",
      "group" => "0024"
    },
    "791" => {
      "KeyWord" => "VisualFieldTestReliabilityGlobalIndexSequence",
      "Name" => "Visual Field Test Reliability Global Index Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0317",
      "group" => "0024"
    },
    "80" => {
      "KeyWord" => "FalseNegativesQuantity",
      "Name" => "False Negatives Quantity",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0050",
      "group" => "0024"
    },
    "800" => {
      "KeyWord" => "VisualFieldGlobalResultsIndexSequence",
      "Name" => "Visual Field Global Results Index Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0320",
      "group" => "0024"
    },
    "805" => {
      "KeyWord" => "DataObservationSequence",
      "Name" => "Data Observation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0325",
      "group" => "0024"
    },
    "81" => {
      "KeyWord" => "ExcessiveFalseNegativesDataFlag",
      "Name" => "Excessive False Negatives Data Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0051",
      "group" => "0024"
    },
    "82" => {
      "KeyWord" => "ExcessiveFalseNegatives",
      "Name" => "Excessive False Negatives",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0052",
      "group" => "0024"
    },
    "824" => {
      "KeyWord" => "IndexNormalsFlag",
      "Name" => "Index Normals Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0338",
      "group" => "0024"
    },
    "83" => {
      "KeyWord" => "FalsePositivesEstimateFlag",
      "Name" => "False Positives Estimate Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0053",
      "group" => "0024"
    },
    "833" => {
      "KeyWord" => "IndexProbability",
      "Name" => "Index Probability",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0341",
      "group" => "0024"
    },
    "836" => {
      "KeyWord" => "IndexProbabilitySequence",
      "Name" => "Index Probability Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0344",
      "group" => "0024"
    },
    "84" => {
      "KeyWord" => "FalsePositivesEstimate",
      "Name" => "False Positives Estimate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0054",
      "group" => "0024"
    },
    "85" => {
      "KeyWord" => "CatchTrialsDataFlag",
      "Name" => "Catch Trials Data Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0055",
      "group" => "0024"
    },
    "86" => {
      "KeyWord" => "PositiveCatchTrialsQuantity",
      "Name" => "Positive Catch Trials Quantity",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0056",
      "group" => "0024"
    },
    "87" => {
      "KeyWord" => "TestPointNormalsDataFlag",
      "Name" => "Test Point Normals Data Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0057",
      "group" => "0024"
    },
    "88" => {
      "KeyWord" => "TestPointNormalsSequence",
      "Name" => "Test Point Normals Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0058",
      "group" => "0024"
    },
    "89" => {
      "KeyWord" => "GlobalDeviationProbabilityNormalsFlag",
      "Name" => "Global Deviation Probability Normals Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0059",
      "group" => "0024"
    },
    "96" => {
      "KeyWord" => "FalsePositivesQuantity",
      "Name" => "False Positives Quantity",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0060",
      "group" => "0024"
    },
    "97" => {
      "KeyWord" => "ExcessiveFalsePositivesDataFlag",
      "Name" => "Excessive False Positives Data Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0061",
      "group" => "0024"
    },
    "98" => {
      "KeyWord" => "ExcessiveFalsePositives",
      "Name" => "Excessive False Positives",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0062",
      "group" => "0024"
    },
    "99" => {
      "KeyWord" => "VisualFieldTestNormalsFlag",
      "Name" => "Visual Field Test Normals Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0063",
      "group" => "0024"
    }
  },
  "4" => {
    "4400" => {
      "KeyWord" => "FileSetID",
      "Name" => "File-set ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1130",
      "group" => "0004"
    },
    "4417" => {
      "KeyWord" => "FileSetDescriptorFileID",
      "Name" => "File-set Descriptor File ID",
      "VM" => "1-8",
      "VR" => "CS",
      "ele" => "1141",
      "group" => "0004"
    },
    "4418" => {
      "KeyWord" => "SpecificCharacterSetOfFileSetDescriptorFile",
      "Name" => "Specific Character Set of File-set Descriptor File",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1142",
      "group" => "0004"
    },
    "4608" => {
      "KeyWord" => "OffsetOfTheFirstDirectoryRecordOfTheRootDirectoryEntity",
      "Name" => "Offset of the First Directory Record of the Root Directory Entity",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "1200",
      "group" => "0004"
    },
    "4610" => {
      "KeyWord" => "OffsetOfTheLastDirectoryRecordOfTheRootDirectoryEntity",
      "Name" => "Offset of the Last Directory Record of the Root Directory Entity",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "1202",
      "group" => "0004"
    },
    "4626" => {
      "KeyWord" => "FileSetConsistencyFlag",
      "Name" => "File-set Consistency Flag",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1212",
      "group" => "0004"
    },
    "4640" => {
      "KeyWord" => "DirectoryRecordSequence",
      "Name" => "Directory Record Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1220",
      "group" => "0004"
    },
    "5120" => {
      "KeyWord" => "OffsetOfTheNextDirectoryRecord",
      "Name" => "Offset of the Next Directory Record",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "1400",
      "group" => "0004"
    },
    "5136" => {
      "KeyWord" => "RecordInUseFlag",
      "Name" => "Record In-use Flag",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1410",
      "group" => "0004"
    },
    "5152" => {
      "KeyWord" => "OffsetOfReferencedLowerLevelDirectoryEntity",
      "Name" => "Offset of Referenced Lower-Level Directory Entity",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "1420",
      "group" => "0004"
    },
    "5168" => {
      "KeyWord" => "DirectoryRecordType",
      "Name" => "Directory Record Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1430",
      "group" => "0004"
    },
    "5170" => {
      "KeyWord" => "PrivateRecordUID",
      "Name" => "Private Record UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1432",
      "group" => "0004"
    },
    "5376" => {
      "KeyWord" => "ReferencedFileID",
      "Name" => "Referenced File ID",
      "VM" => "1-8",
      "VR" => "CS",
      "ele" => "1500",
      "group" => "0004"
    },
    "5380" => {
      "KeyWord" => "MRDRDirectoryRecordOffset",
      "Name" => "MRDR Directory Record Offset",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "1504",
      "group" => "0004"
    },
    "5392" => {
      "KeyWord" => "ReferencedSOPClassUIDInFile",
      "Name" => "Referenced SOP Class UID in File",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1510",
      "group" => "0004"
    },
    "5393" => {
      "KeyWord" => "ReferencedSOPInstanceUIDInFile",
      "Name" => "Referenced SOP Instance UID in File",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1511",
      "group" => "0004"
    },
    "5394" => {
      "KeyWord" => "ReferencedTransferSyntaxUIDInFile",
      "Name" => "Referenced Transfer Syntax UID in File",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1512",
      "group" => "0004"
    },
    "5402" => {
      "KeyWord" => "ReferencedRelatedGeneralSOPClassUIDInFile",
      "Name" => "Referenced Related General SOP Class UID in File",
      "VM" => "1-n",
      "VR" => "UI",
      "ele" => "151a",
      "group" => "0004"
    },
    "5632" => {
      "KeyWord" => "NumberOfReferences",
      "Name" => "Number of References",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "1600",
      "group" => "0004"
    }
  },
  "40" => {
    "10" => {
      "KeyWord" => "FrameDimensionPointer",
      "Name" => "Frame Dimension Pointer",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "000a",
      "group" => "0028"
    },
    "101" => {
      "KeyWord" => "CompressionSequence",
      "Name" => "Compression Sequence",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0065",
      "group" => "0028"
    },
    "102" => {
      "KeyWord" => "CompressionStepPointers",
      "Name" => "Compression Step Pointers",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "0066",
      "group" => "0028"
    },
    "1024" => {
      "KeyWord" => "TransformLabel",
      "Name" => "Transform Label",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0400",
      "group" => "0028"
    },
    "1025" => {
      "KeyWord" => "TransformVersionNumber",
      "Name" => "Transform Version Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0401",
      "group" => "0028"
    },
    "1026" => {
      "KeyWord" => "NumberOfTransformSteps",
      "Name" => "Number of Transform Steps",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0402",
      "group" => "0028"
    },
    "1027" => {
      "KeyWord" => "SequenceOfCompressedData",
      "Name" => "Sequence of Compressed Data",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0403",
      "group" => "0028"
    },
    "1028" => {
      "KeyWord" => "DetailsOfCoefficients",
      "Name" => "Details of Coefficients",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "0404",
      "group" => "0028"
    },
    "104" => {
      "KeyWord" => "RepeatInterval",
      "Name" => "Repeat Interval",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0068",
      "group" => "0028"
    },
    "105" => {
      "KeyWord" => "BitsGrouped",
      "Name" => "Bits Grouped",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0069",
      "group" => "0028"
    },
    "112" => {
      "KeyWord" => "PerimeterTable",
      "Name" => "Perimeter Table",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0070",
      "group" => "0028"
    },
    "113" => {
      "KeyWord" => "PerimeterValue",
      "Name" => "Perimeter Value",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0071",
      "group" => "0028"
    },
    "12288" => {
      "KeyWord" => "ModalityLUTSequence",
      "Name" => "Modality LUT Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "3000",
      "group" => "0028"
    },
    "12290" => {
      "KeyWord" => "LUTDescriptor",
      "Name" => "LUT Descriptor",
      "VM" => "3",
      "VR" => "OT",
      "ele" => "3002",
      "group" => "0028"
    },
    "12291" => {
      "KeyWord" => "LUTExplanation",
      "Name" => "LUT Explanation",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "3003",
      "group" => "0028"
    },
    "12292" => {
      "KeyWord" => "ModalityLUTType",
      "Name" => "Modality LUT Type",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "3004",
      "group" => "0028"
    },
    "12294" => {
      "KeyWord" => "LUTData",
      "Name" => "LUT Data",
      "VM" => "1-n or 1",
      "VR" => "OT",
      "ele" => "3006",
      "group" => "0028"
    },
    "12304" => {
      "KeyWord" => "VOILUTSequence",
      "Name" => "VOI LUT Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "3010",
      "group" => "0028"
    },
    "12560" => {
      "KeyWord" => "SoftcopyVOILUTSequence",
      "Name" => "Softcopy VOI LUT Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "3110",
      "group" => "0028"
    },
    "128" => {
      "KeyWord" => "PredictorRows",
      "Name" => "Predictor Rows",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0080",
      "group" => "0028"
    },
    "129" => {
      "KeyWord" => "PredictorColumns",
      "Name" => "Predictor Columns",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0081",
      "group" => "0028"
    },
    "130" => {
      "KeyWord" => "PredictorConstants",
      "Name" => "Predictor Constants",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0082",
      "group" => "0028"
    },
    "144" => {
      "KeyWord" => "BlockedPixels",
      "Name" => "Blocked Pixels",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0090",
      "group" => "0028"
    },
    "145" => {
      "KeyWord" => "BlockRows",
      "Name" => "Block Rows",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0091",
      "group" => "0028"
    },
    "146" => {
      "KeyWord" => "BlockColumns",
      "Name" => "Block Columns",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0092",
      "group" => "0028"
    },
    "147" => {
      "KeyWord" => "RowOverlap",
      "Name" => "Row Overlap",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0093",
      "group" => "0028"
    },
    "148" => {
      "KeyWord" => "ColumnOverlap",
      "Name" => "Column Overlap",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0094",
      "group" => "0028"
    },
    "16" => {
      "KeyWord" => "Rows",
      "Name" => "Rows",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0010",
      "group" => "0028"
    },
    "16384" => {
      "KeyWord" => "ImagePresentationComments",
      "Name" => "Image Presentation Comments",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "0028"
    },
    "17" => {
      "KeyWord" => "Columns",
      "Name" => "Columns",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0011",
      "group" => "0028"
    },
    "1792" => {
      "KeyWord" => "DCTLabel",
      "Name" => "DCT Label",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0700",
      "group" => "0028"
    },
    "1793" => {
      "KeyWord" => "DataBlockDescription",
      "Name" => "Data Block Description",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0701",
      "group" => "0028"
    },
    "1794" => {
      "KeyWord" => "DataBlock",
      "Name" => "Data Block",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "0702",
      "group" => "0028"
    },
    "18" => {
      "KeyWord" => "Planes",
      "Name" => "Planes",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0012",
      "group" => "0028"
    },
    "1808" => {
      "KeyWord" => "NormalizationFactorFormat",
      "Name" => "Normalization Factor Format",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0710",
      "group" => "0028"
    },
    "1824" => {
      "KeyWord" => "ZonalMapNumberFormat",
      "Name" => "Zonal Map Number Format",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0720",
      "group" => "0028"
    },
    "1825" => {
      "KeyWord" => "ZonalMapLocation",
      "Name" => "Zonal Map Location",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "0721",
      "group" => "0028"
    },
    "1826" => {
      "KeyWord" => "ZonalMapFormat",
      "Name" => "Zonal Map Format",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0722",
      "group" => "0028"
    },
    "1840" => {
      "KeyWord" => "AdaptiveMapFormat",
      "Name" => "Adaptive Map Format",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0730",
      "group" => "0028"
    },
    "1856" => {
      "KeyWord" => "CodeNumberFormat",
      "Name" => "Code Number Format",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0740",
      "group" => "0028"
    },
    "2" => {
      "KeyWord" => "SamplesPerPixel",
      "Name" => "Samples per Pixel",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0002",
      "group" => "0028"
    },
    "20" => {
      "KeyWord" => "UltrasoundColorDataPresent",
      "Name" => "Ultrasound Color Data Present",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0014",
      "group" => "0028"
    },
    "20480" => {
      "KeyWord" => "BiPlaneAcquisitionSequence",
      "Name" => "Bi-Plane Acquisition Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "5000",
      "group" => "0028"
    },
    "24592" => {
      "KeyWord" => "RepresentativeFrameNumber",
      "Name" => "Representative Frame Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6010",
      "group" => "0028"
    },
    "24608" => {
      "KeyWord" => "FrameNumbersOfInterest",
      "Name" => "Frame Numbers of Interest (FOI)",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "6020",
      "group" => "0028"
    },
    "24610" => {
      "KeyWord" => "FrameOfInterestDescription",
      "Name" => "Frame of Interest Description",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "6022",
      "group" => "0028"
    },
    "24611" => {
      "KeyWord" => "FrameOfInterestType",
      "Name" => "Frame of Interest Type",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "6023",
      "group" => "0028"
    },
    "24624" => {
      "KeyWord" => "MaskPointers",
      "Name" => "Mask Pointer(s)",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "6030",
      "group" => "0028"
    },
    "24640" => {
      "KeyWord" => "RWavePointer",
      "Name" => "R Wave Pointer",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "6040",
      "group" => "0028"
    },
    "24832" => {
      "KeyWord" => "MaskSubtractionSequence",
      "Name" => "Mask Subtraction Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "6100",
      "group" => "0028"
    },
    "24833" => {
      "KeyWord" => "MaskOperation",
      "Name" => "Mask Operation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "6101",
      "group" => "0028"
    },
    "24834" => {
      "KeyWord" => "ApplicableFrameRange",
      "Name" => "Applicable Frame Range",
      "VM" => "2-2n",
      "VR" => "US",
      "ele" => "6102",
      "group" => "0028"
    },
    "24848" => {
      "KeyWord" => "MaskFrameNumbers",
      "Name" => "Mask Frame Numbers",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "6110",
      "group" => "0028"
    },
    "24850" => {
      "KeyWord" => "ContrastFrameAveraging",
      "Name" => "Contrast Frame Averaging",
      "VM" => "1",
      "VR" => "US",
      "ele" => "6112",
      "group" => "0028"
    },
    "24852" => {
      "KeyWord" => "MaskSubPixelShift",
      "Name" => "Mask Sub-pixel Shift",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "6114",
      "group" => "0028"
    },
    "24864" => {
      "KeyWord" => "TIDOffset",
      "Name" => "TID Offset",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "6120",
      "group" => "0028"
    },
    "24976" => {
      "KeyWord" => "MaskOperationExplanation",
      "Name" => "Mask Operation Explanation",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "6190",
      "group" => "0028"
    },
    "256" => {
      "KeyWord" => "BitsAllocated",
      "Name" => "Bits Allocated",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0100",
      "group" => "0028"
    },
    "2562" => {
      "KeyWord" => "PixelSpacingCalibrationType",
      "Name" => "Pixel Spacing Calibration Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0a02",
      "group" => "0028"
    },
    "2564" => {
      "KeyWord" => "PixelSpacingCalibrationDescription",
      "Name" => "Pixel Spacing Calibration Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0a04",
      "group" => "0028"
    },
    "257" => {
      "KeyWord" => "BitsStored",
      "Name" => "Bits Stored",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0101",
      "group" => "0028"
    },
    "258" => {
      "KeyWord" => "HighBit",
      "Name" => "High Bit",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0102",
      "group" => "0028"
    },
    "259" => {
      "KeyWord" => "PixelRepresentation",
      "Name" => "Pixel Representation",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0103",
      "group" => "0028"
    },
    "260" => {
      "KeyWord" => "SmallestValidPixelValue",
      "Name" => "Smallest Valid Pixel Value",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0104",
      "group" => "0028"
    },
    "261" => {
      "KeyWord" => "LargestValidPixelValue",
      "Name" => "Largest Valid Pixel Value",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0105",
      "group" => "0028"
    },
    "262" => {
      "KeyWord" => "SmallestImagePixelValue",
      "Name" => "Smallest Image Pixel Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0106",
      "group" => "0028"
    },
    "263" => {
      "KeyWord" => "LargestImagePixelValue",
      "Name" => "Largest Image Pixel Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0107",
      "group" => "0028"
    },
    "264" => {
      "KeyWord" => "SmallestPixelValueInSeries",
      "Name" => "Smallest Pixel Value in Series",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0108",
      "group" => "0028"
    },
    "265" => {
      "KeyWord" => "LargestPixelValueInSeries",
      "Name" => "Largest Pixel Value in Series",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0109",
      "group" => "0028"
    },
    "272" => {
      "KeyWord" => "SmallestImagePixelValueInPlane",
      "Name" => "Smallest Image Pixel Value in Plane",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0110",
      "group" => "0028"
    },
    "273" => {
      "KeyWord" => "LargestImagePixelValueInPlane",
      "Name" => "Largest Image Pixel Value in Plane",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0111",
      "group" => "0028"
    },
    "288" => {
      "KeyWord" => "PixelPaddingValue",
      "Name" => "Pixel Padding Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0120",
      "group" => "0028"
    },
    "289" => {
      "KeyWord" => "PixelPaddingRangeLimit",
      "Name" => "Pixel Padding Range Limit",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "0121",
      "group" => "0028"
    },
    "3" => {
      "KeyWord" => "SamplesPerPixelUsed",
      "Name" => "Samples per Pixel Used",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0003",
      "group" => "0028"
    },
    "32" => {
      "KeyWord" => "",
      "Name" => "",
      "VM" => "",
      "VR" => "",
      "comment" => "RET - See Note",
      "ele" => "0020",
      "group" => "0028"
    },
    "32736" => {
      "KeyWord" => "PixelDataProviderURL",
      "Name" => "Pixel Data Provider URL",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "7fe0",
      "group" => "0028"
    },
    "36865" => {
      "KeyWord" => "DataPointRows",
      "Name" => "Data Point Rows",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9001",
      "group" => "0028"
    },
    "36866" => {
      "KeyWord" => "DataPointColumns",
      "Name" => "Data Point Columns",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "9002",
      "group" => "0028"
    },
    "36867" => {
      "KeyWord" => "SignalDomainColumns",
      "Name" => "Signal Domain Columns",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9003",
      "group" => "0028"
    },
    "37017" => {
      "KeyWord" => "LargestMonochromePixelValue",
      "Name" => "Largest Monochrome Pixel Value",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9099",
      "group" => "0028"
    },
    "37128" => {
      "KeyWord" => "DataRepresentation",
      "Name" => "Data Representation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9108",
      "group" => "0028"
    },
    "37136" => {
      "KeyWord" => "PixelMeasuresSequence",
      "Name" => "Pixel Measures Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9110",
      "group" => "0028"
    },
    "37170" => {
      "KeyWord" => "FrameVOILUTSequence",
      "Name" => "Frame VOI LUT Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9132",
      "group" => "0028"
    },
    "37189" => {
      "KeyWord" => "PixelValueTransformationSequence",
      "Name" => "Pixel Value Transformation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9145",
      "group" => "0028"
    },
    "37429" => {
      "KeyWord" => "SignalDomainRows",
      "Name" => "Signal Domain Rows",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9235",
      "group" => "0028"
    },
    "37905" => {
      "KeyWord" => "DisplayFilterPercentage",
      "Name" => "Display Filter Percentage",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9411",
      "group" => "0028"
    },
    "37909" => {
      "KeyWord" => "FramePixelShiftSequence",
      "Name" => "Frame Pixel Shift Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9415",
      "group" => "0028"
    },
    "37910" => {
      "KeyWord" => "SubtractionItemID",
      "Name" => "Subtraction Item ID",
      "VM" => "1",
      "VR" => "US",
      "ele" => "9416",
      "group" => "0028"
    },
    "37922" => {
      "KeyWord" => "PixelIntensityRelationshipLUTSequence",
      "Name" => "Pixel Intensity Relationship LUT Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9422",
      "group" => "0028"
    },
    "37955" => {
      "KeyWord" => "FramePixelDataPropertiesSequence",
      "Name" => "Frame Pixel Data Properties Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9443",
      "group" => "0028"
    },
    "37956" => {
      "KeyWord" => "GeometricalProperties",
      "Name" => "Geometrical Properties",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9444",
      "group" => "0028"
    },
    "37957" => {
      "KeyWord" => "GeometricMaximumDistortion",
      "Name" => "Geometric Maximum Distortion",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9445",
      "group" => "0028"
    },
    "37958" => {
      "KeyWord" => "ImageProcessingApplied",
      "Name" => "Image Processing Applied",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "9446",
      "group" => "0028"
    },
    "37972" => {
      "KeyWord" => "MaskSelectionMode",
      "Name" => "Mask Selection Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9454",
      "group" => "0028"
    },
    "38004" => {
      "KeyWord" => "LUTFunction",
      "Name" => "LUT Function",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9474",
      "group" => "0028"
    },
    "38008" => {
      "KeyWord" => "MaskVisibilityPercentage",
      "Name" => "Mask Visibility Percentage",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9478",
      "group" => "0028"
    },
    "38145" => {
      "KeyWord" => "PixelShiftSequence",
      "Name" => "Pixel Shift Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9501",
      "group" => "0028"
    },
    "38146" => {
      "KeyWord" => "RegionPixelShiftSequence",
      "Name" => "Region Pixel Shift Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9502",
      "group" => "0028"
    },
    "38147" => {
      "KeyWord" => "VerticesOfTheRegion",
      "Name" => "Vertices of the Region",
      "VM" => "2-2n",
      "VR" => "SS",
      "ele" => "9503",
      "group" => "0028"
    },
    "38149" => {
      "KeyWord" => "MultiFramePresentationSequence",
      "Name" => "Multi-frame Presentation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9505",
      "group" => "0028"
    },
    "38150" => {
      "KeyWord" => "PixelShiftFrameRange",
      "Name" => "Pixel Shift Frame Range",
      "VM" => "2-2n",
      "VR" => "US",
      "ele" => "9506",
      "group" => "0028"
    },
    "38151" => {
      "KeyWord" => "LUTFrameRange",
      "Name" => "LUT Frame Range",
      "VM" => "2-2n",
      "VR" => "US",
      "ele" => "9507",
      "group" => "0028"
    },
    "38176" => {
      "KeyWord" => "ImageToEquipmentMappingMatrix",
      "Name" => "Image to Equipment Mapping Matrix",
      "VM" => "16",
      "VR" => "DS",
      "ele" => "9520",
      "group" => "0028"
    },
    "38199" => {
      "KeyWord" => "EquipmentCoordinateSystemIdentification",
      "Name" => "Equipment Coordinate System Identification",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9537",
      "group" => "0028"
    },
    "4" => {
      "KeyWord" => "PhotometricInterpretation",
      "Name" => "Photometric Interpretation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0004",
      "group" => "0028"
    },
    "4160" => {
      "KeyWord" => "PixelIntensityRelationship",
      "Name" => "Pixel Intensity Relationship",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1040",
      "group" => "0028"
    },
    "4161" => {
      "KeyWord" => "PixelIntensityRelationshipSign",
      "Name" => "Pixel Intensity Relationship Sign",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "1041",
      "group" => "0028"
    },
    "4176" => {
      "KeyWord" => "WindowCenter",
      "Name" => "Window Center",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1050",
      "group" => "0028"
    },
    "4177" => {
      "KeyWord" => "WindowWidth",
      "Name" => "Window Width",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "1051",
      "group" => "0028"
    },
    "4178" => {
      "KeyWord" => "RescaleIntercept",
      "Name" => "Rescale Intercept",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1052",
      "group" => "0028"
    },
    "4179" => {
      "KeyWord" => "RescaleSlope",
      "Name" => "Rescale Slope",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1053",
      "group" => "0028"
    },
    "4180" => {
      "KeyWord" => "RescaleType",
      "Name" => "Rescale Type",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1054",
      "group" => "0028"
    },
    "4181" => {
      "KeyWord" => "WindowCenterWidthExplanation",
      "Name" => "Window Center & Width Explanation",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1055",
      "group" => "0028"
    },
    "4182" => {
      "KeyWord" => "VOILUTFunction",
      "Name" => "VOI LUT Function",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1056",
      "group" => "0028"
    },
    "4224" => {
      "KeyWord" => "GrayScale",
      "Name" => "Gray Scale",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1080",
      "group" => "0028"
    },
    "4240" => {
      "KeyWord" => "RecommendedViewingMode",
      "Name" => "Recommended Viewing Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1090",
      "group" => "0028"
    },
    "4352" => {
      "KeyWord" => "GrayLookupTableDescriptor",
      "Name" => "Gray Lookup Table Descriptor",
      "RET" => "1",
      "VM" => "3",
      "VR" => "OT",
      "ele" => "1100",
      "group" => "0028"
    },
    "4353" => {
      "KeyWord" => "RedPaletteColorLookupTableDescriptor",
      "Name" => "Red Palette Color Lookup Table Descriptor",
      "VM" => "3",
      "VR" => "OT",
      "ele" => "1101",
      "group" => "0028"
    },
    "4354" => {
      "KeyWord" => "GreenPaletteColorLookupTableDescriptor",
      "Name" => "Green Palette Color Lookup Table Descriptor",
      "VM" => "3",
      "VR" => "OT",
      "ele" => "1102",
      "group" => "0028"
    },
    "4355" => {
      "KeyWord" => "BluePaletteColorLookupTableDescriptor",
      "Name" => "Blue Palette Color Lookup Table Descriptor",
      "VM" => "3",
      "VR" => "OT",
      "ele" => "1103",
      "group" => "0028"
    },
    "4356" => {
      "KeyWord" => "AlphaPaletteColorLookupTableDescriptor",
      "Name" => "AlphaPalette ColorLookup Table Descriptor",
      "VM" => "3",
      "VR" => "US",
      "ele" => "1104",
      "group" => "0028"
    },
    "4369" => {
      "KeyWord" => "LargeRedPaletteColorLookupTableDescriptor",
      "Name" => "Large Red Palette Color Lookup Table Descriptor",
      "RET" => "1",
      "VM" => "4",
      "VR" => "OT",
      "ele" => "1111",
      "group" => "0028"
    },
    "4370" => {
      "KeyWord" => "LargeGreenPaletteColorLookupTableDescriptor",
      "Name" => "Large Green Palette Color Lookup Table Descriptor",
      "RET" => "1",
      "VM" => "4",
      "VR" => "OT",
      "ele" => "1112",
      "group" => "0028"
    },
    "4371" => {
      "KeyWord" => "LargeBluePaletteColorLookupTableDescriptor",
      "Name" => "Large Blue Palette Color Lookup Table Descriptor",
      "RET" => "1",
      "VM" => "4",
      "VR" => "OT",
      "ele" => "1113",
      "group" => "0028"
    },
    "4505" => {
      "KeyWord" => "PaletteColorLookupTableUID",
      "Name" => "Palette Color Lookup Table UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1199",
      "group" => "0028"
    },
    "4608" => {
      "KeyWord" => "GrayLookupTableData",
      "Name" => "Gray Lookup Table Data",
      "RET" => "1",
      "VM" => "1-n or 1",
      "VR" => "OT",
      "ele" => "1200",
      "group" => "0028"
    },
    "4609" => {
      "KeyWord" => "RedPaletteColorLookupTableData",
      "Name" => "Red Palette Color Lookup Table Data",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1201",
      "group" => "0028"
    },
    "4610" => {
      "KeyWord" => "GreenPaletteColorLookupTableData",
      "Name" => "Green Palette Color Lookup Table Data",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1202",
      "group" => "0028"
    },
    "4611" => {
      "KeyWord" => "BluePaletteColorLookupTableData",
      "Name" => "Blue Palette Color Lookup Table Data",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1203",
      "group" => "0028"
    },
    "4612" => {
      "KeyWord" => "AlphaPaletteColorLookupTableData",
      "Name" => "Alpha Palette Color Lookup Table Data",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1204",
      "group" => "0028"
    },
    "4625" => {
      "KeyWord" => "LargeRedPaletteColorLookupTableData",
      "Name" => "Large Red Palette Color Lookup Table Data",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1211",
      "group" => "0028"
    },
    "4626" => {
      "KeyWord" => "LargeGreenPaletteColorLookupTableData",
      "Name" => "Large Green Palette Color Lookup Table Data",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1212",
      "group" => "0028"
    },
    "4627" => {
      "KeyWord" => "LargeBluePaletteColorLookupTableData",
      "Name" => "Large Blue Palette Color Lookup Table Data",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1213",
      "group" => "0028"
    },
    "4628" => {
      "KeyWord" => "LargePaletteColorLookupTableUID",
      "Name" => "Large Palette Color Lookup Table UID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1214",
      "group" => "0028"
    },
    "4641" => {
      "KeyWord" => "SegmentedRedPaletteColorLookupTableData",
      "Name" => "Segmented Red Palette Color Lookup Table Data",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1221",
      "group" => "0028"
    },
    "4642" => {
      "KeyWord" => "SegmentedGreenPaletteColorLookupTableData",
      "Name" => "Segmented Green Palette Color Lookup Table Data",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1222",
      "group" => "0028"
    },
    "4643" => {
      "KeyWord" => "SegmentedBluePaletteColorLookupTableData",
      "Name" => "Segmented Blue Palette Color Lookup Table Data",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1223",
      "group" => "0028"
    },
    "48" => {
      "KeyWord" => "PixelSpacing",
      "Name" => "Pixel Spacing",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "0030",
      "group" => "0028"
    },
    "4864" => {
      "KeyWord" => "BreastImplantPresent",
      "Name" => "Breast Implant Present",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1300",
      "group" => "0028"
    },
    "49" => {
      "KeyWord" => "ZoomFactor",
      "Name" => "Zoom Factor",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "0031",
      "group" => "0028"
    },
    "4944" => {
      "KeyWord" => "PartialView",
      "Name" => "Partial View",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1350",
      "group" => "0028"
    },
    "4945" => {
      "KeyWord" => "PartialViewDescription",
      "Name" => "Partial View Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "1351",
      "group" => "0028"
    },
    "4946" => {
      "KeyWord" => "PartialViewCodeSequence",
      "Name" => "Partial View Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1352",
      "group" => "0028"
    },
    "4954" => {
      "KeyWord" => "SpatialLocationsPreserved",
      "Name" => "Spatial Locations Preserved",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "135a",
      "group" => "0028"
    },
    "5" => {
      "KeyWord" => "ImageDimensions",
      "Name" => "Image Dimensions",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0005",
      "group" => "0028"
    },
    "50" => {
      "KeyWord" => "ZoomCenter",
      "Name" => "Zoom Center",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "0032",
      "group" => "0028"
    },
    "512" => {
      "KeyWord" => "ImageLocation",
      "Name" => "Image Location",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0200",
      "group" => "0028"
    },
    "5121" => {
      "KeyWord" => "DataFrameAssignmentSequence",
      "Name" => "Data Frame Assignment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1401",
      "group" => "0028"
    },
    "5122" => {
      "KeyWord" => "DataPathAssignment",
      "Name" => "Data Path Assignment",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1402",
      "group" => "0028"
    },
    "5123" => {
      "KeyWord" => "BitsMappedToColorLookupTable",
      "Name" => "Bits Mapped to Color Lookup Table",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1403",
      "group" => "0028"
    },
    "5124" => {
      "KeyWord" => "BlendingLUT1Sequence",
      "Name" => "Blending LUT 1 Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1404",
      "group" => "0028"
    },
    "5125" => {
      "KeyWord" => "BlendingLUT1TransferFunction",
      "Name" => "Blending LUT 1 Transfer Function",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1405",
      "group" => "0028"
    },
    "5126" => {
      "KeyWord" => "BlendingWeightConstant",
      "Name" => "Blending Weight Constant",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "1406",
      "group" => "0028"
    },
    "5127" => {
      "KeyWord" => "BlendingLookupTableDescriptor",
      "Name" => "Blending Lookup Table Descriptor",
      "VM" => "3",
      "VR" => "US",
      "ele" => "1407",
      "group" => "0028"
    },
    "5128" => {
      "KeyWord" => "BlendingLookupTableData",
      "Name" => "Blending Lookup Table Data",
      "VM" => "1",
      "VR" => "OW",
      "ele" => "1408",
      "group" => "0028"
    },
    "5131" => {
      "KeyWord" => "EnhancedPaletteColorLookupTableSequence",
      "Name" => "Enhanced Palette Color Lookup Table Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "140b",
      "group" => "0028"
    },
    "5132" => {
      "KeyWord" => "BlendingLUT2Sequence",
      "Name" => "Blending LUT 2 Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "140c",
      "group" => "0028"
    },
    "5133" => {
      "KeyWord" => "BlendingLUT2TransferFunction",
      "Name" => "Blending LUT 2 Transfer Function",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "140d",
      "group" => "0028"
    },
    "5134" => {
      "KeyWord" => "DataPathID",
      "Name" => "Data Path ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "140e",
      "group" => "0028"
    },
    "5135" => {
      "KeyWord" => "RGBLUTTransferFunction",
      "Name" => "RGB LUT Transfer Function",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "140f",
      "group" => "0028"
    },
    "5136" => {
      "KeyWord" => "AlphaLUTTransferFunction",
      "Name" => "Alpha LUT Transfer Function",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1410",
      "group" => "0028"
    },
    "52" => {
      "KeyWord" => "PixelAspectRatio",
      "Name" => "Pixel Aspect Ratio",
      "VM" => "2",
      "VR" => "IS",
      "ele" => "0034",
      "group" => "0028"
    },
    "6" => {
      "KeyWord" => "PlanarConfiguration",
      "Name" => "Planar Configuration",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0006",
      "group" => "0028"
    },
    "64" => {
      "KeyWord" => "ImageFormat",
      "Name" => "Image Format",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0040",
      "group" => "0028"
    },
    "768" => {
      "KeyWord" => "QualityControlImage",
      "Name" => "Quality Control Image",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0300",
      "group" => "0028"
    },
    "769" => {
      "KeyWord" => "BurnedInAnnotation",
      "Name" => "Burned In Annotation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0301",
      "group" => "0028"
    },
    "770" => {
      "KeyWord" => "RecognizableVisualFeatures",
      "Name" => "Recognizable Visual Features",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0302",
      "group" => "0028"
    },
    "771" => {
      "KeyWord" => "LongitudinalTemporalInformationModified",
      "Name" => "Longitudinal Temporal Information Modified",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0303",
      "group" => "0028"
    },
    "772" => {
      "KeyWord" => "ReferencedColorPaletteInstanceUID",
      "Name" => "Referenced Color Palette Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0304",
      "group" => "0028"
    },
    "8" => {
      "KeyWord" => "NumberOfFrames",
      "Name" => "Number of Frames",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0008",
      "group" => "0028"
    },
    "80" => {
      "KeyWord" => "ManipulatedImage",
      "Name" => "Manipulated Image",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0050",
      "group" => "0028"
    },
    "81" => {
      "KeyWord" => "CorrectedImage",
      "Name" => "Corrected Image",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0051",
      "group" => "0028"
    },
    "8192" => {
      "KeyWord" => "ICCProfile",
      "Name" => "ICC Profile",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "2000",
      "group" => "0028"
    },
    "8464" => {
      "KeyWord" => "LossyImageCompression",
      "Name" => "Lossy Image Compression",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2110",
      "group" => "0028"
    },
    "8466" => {
      "KeyWord" => "LossyImageCompressionRatio",
      "Name" => "Lossy Image Compression Ratio",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "2112",
      "group" => "0028"
    },
    "8468" => {
      "KeyWord" => "LossyImageCompressionMethod",
      "Name" => "Lossy Image Compression Method",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "2114",
      "group" => "0028"
    },
    "9" => {
      "KeyWord" => "FrameIncrementPointer",
      "Name" => "Frame Increment Pointer",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "0009",
      "group" => "0028"
    },
    "95" => {
      "KeyWord" => "CompressionRecognitionCode",
      "Name" => "Compression Recognition Code",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "005f",
      "group" => "0028"
    },
    "96" => {
      "KeyWord" => "CompressionCode",
      "Name" => "Compression Code",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0060",
      "group" => "0028"
    },
    "97" => {
      "KeyWord" => "CompressionOriginator",
      "Name" => "Compression Originator",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0061",
      "group" => "0028"
    },
    "98" => {
      "KeyWord" => "CompressionLabel",
      "Name" => "Compression Label",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0062",
      "group" => "0028"
    },
    "99" => {
      "KeyWord" => "CompressionDescription",
      "Name" => "Compression Description",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0063",
      "group" => "0028"
    }
  },
  "50" => {
    "10" => {
      "KeyWord" => "StudyStatusID",
      "Name" => "Study Status ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000a",
      "group" => "0032"
    },
    "12" => {
      "KeyWord" => "StudyPriorityID",
      "Name" => "Study Priority ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000c",
      "group" => "0032"
    },
    "16384" => {
      "KeyWord" => "StudyComments",
      "Name" => "Study Comments",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "0032"
    },
    "18" => {
      "KeyWord" => "StudyIDIssuer",
      "Name" => "Study ID Issuer",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0012",
      "group" => "0032"
    },
    "4096" => {
      "KeyWord" => "ScheduledStudyStartDate",
      "Name" => "Scheduled Study Start Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "1000",
      "group" => "0032"
    },
    "4097" => {
      "KeyWord" => "ScheduledStudyStartTime",
      "Name" => "Scheduled Study Start Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1001",
      "group" => "0032"
    },
    "4112" => {
      "KeyWord" => "ScheduledStudyStopDate",
      "Name" => "Scheduled Study Stop Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "1010",
      "group" => "0032"
    },
    "4113" => {
      "KeyWord" => "ScheduledStudyStopTime",
      "Name" => "Scheduled Study Stop Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1011",
      "group" => "0032"
    },
    "4128" => {
      "KeyWord" => "ScheduledStudyLocation",
      "Name" => "Scheduled Study Location",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1020",
      "group" => "0032"
    },
    "4129" => {
      "KeyWord" => "ScheduledStudyLocationAETitle",
      "Name" => "Scheduled Study Location AE Title",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "AE",
      "ele" => "1021",
      "group" => "0032"
    },
    "4144" => {
      "KeyWord" => "ReasonForStudy",
      "Name" => "Reason for Study",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1030",
      "group" => "0032"
    },
    "4145" => {
      "KeyWord" => "RequestingPhysicianIdentificationSequence",
      "Name" => "Requesting Physician Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1031",
      "group" => "0032"
    },
    "4146" => {
      "KeyWord" => "RequestingPhysician",
      "Name" => "Requesting Physician",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "1032",
      "group" => "0032"
    },
    "4147" => {
      "KeyWord" => "RequestingService",
      "Name" => "Requesting Service",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1033",
      "group" => "0032"
    },
    "4148" => {
      "KeyWord" => "RequestingServiceCodeSequence",
      "Name" => "Requesting Service Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1034",
      "group" => "0032"
    },
    "4160" => {
      "KeyWord" => "StudyArrivalDate",
      "Name" => "Study Arrival Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "1040",
      "group" => "0032"
    },
    "4161" => {
      "KeyWord" => "StudyArrivalTime",
      "Name" => "Study Arrival Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1041",
      "group" => "0032"
    },
    "4176" => {
      "KeyWord" => "StudyCompletionDate",
      "Name" => "Study Completion Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "1050",
      "group" => "0032"
    },
    "4177" => {
      "KeyWord" => "StudyCompletionTime",
      "Name" => "Study Completion Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "1051",
      "group" => "0032"
    },
    "4181" => {
      "KeyWord" => "StudyComponentStatusID",
      "Name" => "Study Component Status ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1055",
      "group" => "0032"
    },
    "4192" => {
      "KeyWord" => "RequestedProcedureDescription",
      "Name" => "Requested Procedure Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1060",
      "group" => "0032"
    },
    "4196" => {
      "KeyWord" => "RequestedProcedureCodeSequence",
      "Name" => "Requested Procedure Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1064",
      "group" => "0032"
    },
    "4208" => {
      "KeyWord" => "RequestedContrastAgent",
      "Name" => "Requested Contrast Agent",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1070",
      "group" => "0032"
    },
    "50" => {
      "KeyWord" => "StudyVerifiedDate",
      "Name" => "Study Verified Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0032",
      "group" => "0032"
    },
    "51" => {
      "KeyWord" => "StudyVerifiedTime",
      "Name" => "Study Verified Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0033",
      "group" => "0032"
    },
    "52" => {
      "KeyWord" => "StudyReadDate",
      "Name" => "Study Read Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0034",
      "group" => "0032"
    },
    "53" => {
      "KeyWord" => "StudyReadTime",
      "Name" => "Study Read Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0035",
      "group" => "0032"
    }
  },
  "56" => {
    "100" => {
      "KeyWord" => "IssuerOfServiceEpisodeIDSequence",
      "Name" => "Issuer of Service Episode ID Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0064",
      "group" => "0038"
    },
    "1024" => {
      "KeyWord" => "PatientInstitutionResidence",
      "Name" => "Patient's Institution Residence",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0400",
      "group" => "0038"
    },
    "1280" => {
      "KeyWord" => "PatientState",
      "Name" => "Patient State",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0500",
      "group" => "0038"
    },
    "1282" => {
      "KeyWord" => "PatientClinicalTrialParticipationSequence",
      "Name" => "Patient Clinical Trial Participation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0502",
      "group" => "0038"
    },
    "16" => {
      "KeyWord" => "AdmissionID",
      "Name" => "Admission ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0010",
      "group" => "0038"
    },
    "16384" => {
      "KeyWord" => "VisitComments",
      "Name" => "Visit Comments",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "0038"
    },
    "17" => {
      "KeyWord" => "IssuerOfAdmissionID",
      "Name" => "Issuer of Admission ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0011",
      "group" => "0038"
    },
    "20" => {
      "KeyWord" => "IssuerOfAdmissionIDSequence",
      "Name" => "Issuer of Admission ID Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0014",
      "group" => "0038"
    },
    "22" => {
      "KeyWord" => "RouteOfAdmissions",
      "Name" => "Route of Admissions",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0016",
      "group" => "0038"
    },
    "256" => {
      "KeyWord" => "PertinentDocumentsSequence",
      "Name" => "Pertinent Documents Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0100",
      "group" => "0038"
    },
    "26" => {
      "KeyWord" => "ScheduledAdmissionDate",
      "Name" => "Scheduled Admission Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "001a",
      "group" => "0038"
    },
    "27" => {
      "KeyWord" => "ScheduledAdmissionTime",
      "Name" => "Scheduled Admission Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "001b",
      "group" => "0038"
    },
    "28" => {
      "KeyWord" => "ScheduledDischargeDate",
      "Name" => "Scheduled Discharge Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "001c",
      "group" => "0038"
    },
    "29" => {
      "KeyWord" => "ScheduledDischargeTime",
      "Name" => "Scheduled Discharge Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "001d",
      "group" => "0038"
    },
    "30" => {
      "KeyWord" => "ScheduledPatientInstitutionResidence",
      "Name" => "Scheduled Patient Institution Residence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "001e",
      "group" => "0038"
    },
    "32" => {
      "KeyWord" => "AdmittingDate",
      "Name" => "Admitting Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0020",
      "group" => "0038"
    },
    "33" => {
      "KeyWord" => "AdmittingTime",
      "Name" => "Admitting Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0021",
      "group" => "0038"
    },
    "4" => {
      "KeyWord" => "ReferencedPatientAliasSequence",
      "Name" => "Referenced Patient Alias Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0004",
      "group" => "0038"
    },
    "48" => {
      "KeyWord" => "DischargeDate",
      "Name" => "Discharge Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0030",
      "group" => "0038"
    },
    "50" => {
      "KeyWord" => "DischargeTime",
      "Name" => "Discharge Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0032",
      "group" => "0038"
    },
    "64" => {
      "KeyWord" => "DischargeDiagnosisDescription",
      "Name" => "Discharge Diagnosis Description",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0040",
      "group" => "0038"
    },
    "68" => {
      "KeyWord" => "DischargeDiagnosisCodeSequence",
      "Name" => "Discharge Diagnosis Code Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0044",
      "group" => "0038"
    },
    "768" => {
      "KeyWord" => "CurrentPatientLocation",
      "Name" => "Current Patient Location",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0300",
      "group" => "0038"
    },
    "8" => {
      "KeyWord" => "VisitStatusID",
      "Name" => "Visit Status ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0008",
      "group" => "0038"
    },
    "80" => {
      "KeyWord" => "SpecialNeeds",
      "Name" => "Special Needs",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0050",
      "group" => "0038"
    },
    "96" => {
      "KeyWord" => "ServiceEpisodeID",
      "Name" => "Service Episode ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0060",
      "group" => "0038"
    },
    "97" => {
      "KeyWord" => "IssuerOfServiceEpisodeID",
      "Name" => "Issuer of Service Episode ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0061",
      "group" => "0038"
    },
    "98" => {
      "KeyWord" => "ServiceEpisodeDescription",
      "Name" => "Service Episode Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0062",
      "group" => "0038"
    }
  },
  "58" => {
    "16" => {
      "KeyWord" => "NumberOfWaveformSamples",
      "Name" => "Number of Waveform Samples",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0010",
      "group" => "003a"
    },
    "26" => {
      "KeyWord" => "SamplingFrequency",
      "Name" => "Sampling Frequency",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "001a",
      "group" => "003a"
    },
    "32" => {
      "KeyWord" => "MultiplexGroupLabel",
      "Name" => "Multiplex Group Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0020",
      "group" => "003a"
    },
    "4" => {
      "KeyWord" => "WaveformOriginality",
      "Name" => "Waveform Originality",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0004",
      "group" => "003a"
    },
    "5" => {
      "KeyWord" => "NumberOfWaveformChannels",
      "Name" => "Number of Waveform Channels",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0005",
      "group" => "003a"
    },
    "512" => {
      "KeyWord" => "ChannelDefinitionSequence",
      "Name" => "Channel Definition Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0200",
      "group" => "003a"
    },
    "514" => {
      "KeyWord" => "WaveformChannelNumber",
      "Name" => "Waveform Channel Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0202",
      "group" => "003a"
    },
    "515" => {
      "KeyWord" => "ChannelLabel",
      "Name" => "Channel Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0203",
      "group" => "003a"
    },
    "517" => {
      "KeyWord" => "ChannelStatus",
      "Name" => "Channel Status",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0205",
      "group" => "003a"
    },
    "520" => {
      "KeyWord" => "ChannelSourceSequence",
      "Name" => "Channel Source Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0208",
      "group" => "003a"
    },
    "521" => {
      "KeyWord" => "ChannelSourceModifiersSequence",
      "Name" => "Channel Source Modifiers Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0209",
      "group" => "003a"
    },
    "522" => {
      "KeyWord" => "SourceWaveformSequence",
      "Name" => "Source Waveform Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "020a",
      "group" => "003a"
    },
    "524" => {
      "KeyWord" => "ChannelDerivationDescription",
      "Name" => "Channel Derivation Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "020c",
      "group" => "003a"
    },
    "528" => {
      "KeyWord" => "ChannelSensitivity",
      "Name" => "Channel Sensitivity",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0210",
      "group" => "003a"
    },
    "529" => {
      "KeyWord" => "ChannelSensitivityUnitsSequence",
      "Name" => "Channel Sensitivity Units Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0211",
      "group" => "003a"
    },
    "530" => {
      "KeyWord" => "ChannelSensitivityCorrectionFactor",
      "Name" => "Channel Sensitivity Correction Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0212",
      "group" => "003a"
    },
    "531" => {
      "KeyWord" => "ChannelBaseline",
      "Name" => "Channel Baseline",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0213",
      "group" => "003a"
    },
    "532" => {
      "KeyWord" => "ChannelTimeSkew",
      "Name" => "Channel Time Skew",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0214",
      "group" => "003a"
    },
    "533" => {
      "KeyWord" => "ChannelSampleSkew",
      "Name" => "Channel Sample Skew",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0215",
      "group" => "003a"
    },
    "536" => {
      "KeyWord" => "ChannelOffset",
      "Name" => "Channel Offset",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0218",
      "group" => "003a"
    },
    "538" => {
      "KeyWord" => "WaveformBitsStored",
      "Name" => "Waveform Bits Stored",
      "VM" => "1",
      "VR" => "US",
      "ele" => "021a",
      "group" => "003a"
    },
    "544" => {
      "KeyWord" => "FilterLowFrequency",
      "Name" => "Filter Low Frequency",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0220",
      "group" => "003a"
    },
    "545" => {
      "KeyWord" => "FilterHighFrequency",
      "Name" => "Filter High Frequency",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0221",
      "group" => "003a"
    },
    "546" => {
      "KeyWord" => "NotchFilterFrequency",
      "Name" => "Notch Filter Frequency",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0222",
      "group" => "003a"
    },
    "547" => {
      "KeyWord" => "NotchFilterBandwidth",
      "Name" => "Notch Filter Bandwidth",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0223",
      "group" => "003a"
    },
    "560" => {
      "KeyWord" => "WaveformDataDisplayScale",
      "Name" => "Waveform Data Display Scale",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0230",
      "group" => "003a"
    },
    "561" => {
      "KeyWord" => "WaveformDisplayBackgroundCIELabValue",
      "Name" => "Waveform Display Background CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0231",
      "group" => "003a"
    },
    "576" => {
      "KeyWord" => "WaveformPresentationGroupSequence",
      "Name" => "Waveform Presentation Group Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0240",
      "group" => "003a"
    },
    "577" => {
      "KeyWord" => "PresentationGroupNumber",
      "Name" => "Presentation Group Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0241",
      "group" => "003a"
    },
    "578" => {
      "KeyWord" => "ChannelDisplaySequence",
      "Name" => "Channel Display Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0242",
      "group" => "003a"
    },
    "580" => {
      "KeyWord" => "ChannelRecommendedDisplayCIELabValue",
      "Name" => "Channel Recommended Display CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0244",
      "group" => "003a"
    },
    "581" => {
      "KeyWord" => "ChannelPosition",
      "Name" => "Channel Position",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0245",
      "group" => "003a"
    },
    "582" => {
      "KeyWord" => "DisplayShadingFlag",
      "Name" => "Display Shading Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0246",
      "group" => "003a"
    },
    "583" => {
      "KeyWord" => "FractionalChannelDisplayScale",
      "Name" => "Fractional Channel Display Scale",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0247",
      "group" => "003a"
    },
    "584" => {
      "KeyWord" => "AbsoluteChannelDisplayScale",
      "Name" => "Absolute Channel Display Scale",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0248",
      "group" => "003a"
    },
    "768" => {
      "KeyWord" => "MultiplexedAudioChannelsDescriptionCodeSequence",
      "Name" => "Multiplexed Audio Channels Description Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0300",
      "group" => "003a"
    },
    "769" => {
      "KeyWord" => "ChannelIdentificationCode",
      "Name" => "Channel Identification Code",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0301",
      "group" => "003a"
    },
    "770" => {
      "KeyWord" => "ChannelMode",
      "Name" => "Channel Mode",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0302",
      "group" => "003a"
    }
  },
  "64" => {
    "1" => {
      "KeyWord" => "ScheduledStationAETitle",
      "Name" => "Scheduled Station AE Title",
      "VM" => "1-n",
      "VR" => "AE",
      "ele" => "0001",
      "group" => "0040"
    },
    "10" => {
      "KeyWord" => "StageCodeSequence",
      "Name" => "Stage Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000a",
      "group" => "0040"
    },
    "1024" => {
      "KeyWord" => "CommentsOnTheScheduledProcedureStep",
      "Name" => "Comments on the Scheduled Procedure Step",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0400",
      "group" => "0040"
    },
    "1088" => {
      "KeyWord" => "ProtocolContextSequence",
      "Name" => "Protocol Context Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0440",
      "group" => "0040"
    },
    "1089" => {
      "KeyWord" => "ContentItemModifierSequence",
      "Name" => "Content Item Modifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0441",
      "group" => "0040"
    },
    "11" => {
      "KeyWord" => "ScheduledPerformingPhysicianIdentificationSequence",
      "Name" => "Scheduled Performing Physician Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000b",
      "group" => "0040"
    },
    "12289" => {
      "KeyWord" => "ConfidentialityConstraintOnPatientDataDescription",
      "Name" => "Confidentiality Constraint on Patient Data Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "3001",
      "group" => "0040"
    },
    "1280" => {
      "KeyWord" => "ScheduledSpecimenSequence",
      "Name" => "Scheduled Specimen Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0500",
      "group" => "0040"
    },
    "1290" => {
      "KeyWord" => "SpecimenAccessionNumber",
      "Name" => "Specimen Accession Number",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "050a",
      "group" => "0040"
    },
    "1298" => {
      "KeyWord" => "ContainerIdentifier",
      "Name" => "Container Identifier",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0512",
      "group" => "0040"
    },
    "1299" => {
      "KeyWord" => "IssuerOfTheContainerIdentifierSequence",
      "Name" => "Issuer of the Container Identifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0513",
      "group" => "0040"
    },
    "1301" => {
      "KeyWord" => "AlternateContainerIdentifierSequence",
      "Name" => "Alternate Container Identifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0515",
      "group" => "0040"
    },
    "1304" => {
      "KeyWord" => "ContainerTypeCodeSequence",
      "Name" => "Container Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0518",
      "group" => "0040"
    },
    "1306" => {
      "KeyWord" => "ContainerDescription",
      "Name" => "Container Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "051a",
      "group" => "0040"
    },
    "1312" => {
      "KeyWord" => "ContainerComponentSequence",
      "Name" => "Container Component Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0520",
      "group" => "0040"
    },
    "1360" => {
      "KeyWord" => "SpecimenSequence",
      "Name" => "Specimen Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0550",
      "group" => "0040"
    },
    "1361" => {
      "KeyWord" => "SpecimenIdentifier",
      "Name" => "Specimen Identifier",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0551",
      "group" => "0040"
    },
    "1362" => {
      "KeyWord" => "SpecimenDescriptionSequenceTrial",
      "Name" => "Specimen Description Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0552",
      "group" => "0040"
    },
    "1363" => {
      "KeyWord" => "SpecimenDescriptionTrial",
      "Name" => "Specimen Description (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0553",
      "group" => "0040"
    },
    "1364" => {
      "KeyWord" => "SpecimenUID",
      "Name" => "Specimen UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0554",
      "group" => "0040"
    },
    "1365" => {
      "KeyWord" => "AcquisitionContextSequence",
      "Name" => "Acquisition Context Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0555",
      "group" => "0040"
    },
    "1366" => {
      "KeyWord" => "AcquisitionContextDescription",
      "Name" => "Acquisition Context Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0556",
      "group" => "0040"
    },
    "1376" => {
      "KeyWord" => "SpecimenDescriptionSequence",
      "Name" => "Specimen Description Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0560",
      "group" => "0040"
    },
    "1378" => {
      "KeyWord" => "IssuerOfTheSpecimenIdentifierSequence",
      "Name" => "Issuer of the Specimen Identifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0562",
      "group" => "0040"
    },
    "1434" => {
      "KeyWord" => "SpecimenTypeCodeSequence",
      "Name" => "Specimen Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "059a",
      "group" => "0040"
    },
    "1536" => {
      "KeyWord" => "SpecimenShortDescription",
      "Name" => "Specimen Short Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0600",
      "group" => "0040"
    },
    "1538" => {
      "KeyWord" => "SpecimenDetailedDescription",
      "Name" => "Specimen Detailed Description",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "0602",
      "group" => "0040"
    },
    "1552" => {
      "KeyWord" => "SpecimenPreparationSequence",
      "Name" => "Specimen Preparation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0610",
      "group" => "0040"
    },
    "1554" => {
      "KeyWord" => "SpecimenPreparationStepContentItemSequence",
      "Name" => "Specimen Preparation Step Content Item Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0612",
      "group" => "0040"
    },
    "1568" => {
      "KeyWord" => "SpecimenLocalizationContentItemSequence",
      "Name" => "Specimen Localization Content Item Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0620",
      "group" => "0040"
    },
    "16" => {
      "KeyWord" => "ScheduledStationName",
      "Name" => "Scheduled Station Name",
      "VM" => "1-n",
      "VR" => "SH",
      "ele" => "0010",
      "group" => "0040"
    },
    "16385" => {
      "KeyWord" => "GeneralPurposeScheduledProcedureStepStatus",
      "Name" => "General Purpose Scheduled Procedure Step Status",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "4001",
      "group" => "0040"
    },
    "16386" => {
      "KeyWord" => "GeneralPurposePerformedProcedureStepStatus",
      "Name" => "General Purpose Performed Procedure Step Status",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "4002",
      "group" => "0040"
    },
    "16387" => {
      "KeyWord" => "GeneralPurposeScheduledProcedureStepPriority",
      "Name" => "General Purpose Scheduled Procedure Step Priority",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "4003",
      "group" => "0040"
    },
    "16388" => {
      "KeyWord" => "ScheduledProcessingApplicationsCodeSequence",
      "Name" => "Scheduled Processing Applications Code Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4004",
      "group" => "0040"
    },
    "16389" => {
      "KeyWord" => "ScheduledProcedureStepStartDateTime",
      "Name" => "Scheduled Procedure Step Start DateTime",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "4005",
      "group" => "0040"
    },
    "16390" => {
      "KeyWord" => "MultipleCopiesFlag",
      "Name" => "Multiple Copies Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "4006",
      "group" => "0040"
    },
    "16391" => {
      "KeyWord" => "PerformedProcessingApplicationsCodeSequence",
      "Name" => "Performed Processing Applications Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4007",
      "group" => "0040"
    },
    "16393" => {
      "KeyWord" => "HumanPerformerCodeSequence",
      "Name" => "Human Performer Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4009",
      "group" => "0040"
    },
    "16400" => {
      "KeyWord" => "ScheduledProcedureStepModificationDateTime",
      "Name" => "Scheduled Procedure Step Modification DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "4010",
      "group" => "0040"
    },
    "16401" => {
      "KeyWord" => "ExpectedCompletionDateTime",
      "Name" => "Expected Completion DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "4011",
      "group" => "0040"
    },
    "16405" => {
      "KeyWord" => "ResultingGeneralPurposePerformedProcedureStepsSequence",
      "Name" => "Resulting General Purpose Performed Procedure Steps Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4015",
      "group" => "0040"
    },
    "16406" => {
      "KeyWord" => "ReferencedGeneralPurposeScheduledProcedureStepSequence",
      "Name" => "Referenced General Purpose Scheduled Procedure Step Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4016",
      "group" => "0040"
    },
    "16408" => {
      "KeyWord" => "ScheduledWorkitemCodeSequence",
      "Name" => "Scheduled Workitem Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4018",
      "group" => "0040"
    },
    "16409" => {
      "KeyWord" => "PerformedWorkitemCodeSequence",
      "Name" => "Performed Workitem Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4019",
      "group" => "0040"
    },
    "16416" => {
      "KeyWord" => "InputAvailabilityFlag",
      "Name" => "Input Availability Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "4020",
      "group" => "0040"
    },
    "16417" => {
      "KeyWord" => "InputInformationSequence",
      "Name" => "Input Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4021",
      "group" => "0040"
    },
    "16418" => {
      "KeyWord" => "RelevantInformationSequence",
      "Name" => "Relevant Information Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4022",
      "group" => "0040"
    },
    "16419" => {
      "KeyWord" => "ReferencedGeneralPurposeScheduledProcedureStepTransactionUID",
      "Name" => "Referenced General Purpose Scheduled Procedure Step Transaction UID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "4023",
      "group" => "0040"
    },
    "16421" => {
      "KeyWord" => "ScheduledStationNameCodeSequence",
      "Name" => "Scheduled Station Name Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4025",
      "group" => "0040"
    },
    "16422" => {
      "KeyWord" => "ScheduledStationClassCodeSequence",
      "Name" => "Scheduled Station Class Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4026",
      "group" => "0040"
    },
    "16423" => {
      "KeyWord" => "ScheduledStationGeographicLocationCodeSequence",
      "Name" => "Scheduled Station Geographic Location Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4027",
      "group" => "0040"
    },
    "16424" => {
      "KeyWord" => "PerformedStationNameCodeSequence",
      "Name" => "Performed Station Name Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4028",
      "group" => "0040"
    },
    "16425" => {
      "KeyWord" => "PerformedStationClassCodeSequence",
      "Name" => "Performed Station Class Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4029",
      "group" => "0040"
    },
    "16432" => {
      "KeyWord" => "PerformedStationGeographicLocationCodeSequence",
      "Name" => "Performed Station Geographic Location Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4030",
      "group" => "0040"
    },
    "16433" => {
      "KeyWord" => "RequestedSubsequentWorkitemCodeSequence",
      "Name" => "Requested Subsequent Workitem Code Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4031",
      "group" => "0040"
    },
    "16434" => {
      "KeyWord" => "NonDICOMOutputCodeSequence",
      "Name" => "Non-DICOM Output Code Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4032",
      "group" => "0040"
    },
    "16435" => {
      "KeyWord" => "OutputInformationSequence",
      "Name" => "Output Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4033",
      "group" => "0040"
    },
    "16436" => {
      "KeyWord" => "ScheduledHumanPerformersSequence",
      "Name" => "Scheduled Human Performers Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4034",
      "group" => "0040"
    },
    "16437" => {
      "KeyWord" => "ActualHumanPerformersSequence",
      "Name" => "Actual Human Performers Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "4035",
      "group" => "0040"
    },
    "16438" => {
      "KeyWord" => "HumanPerformerOrganization",
      "Name" => "Human Performer's Organization",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "4036",
      "group" => "0040"
    },
    "16439" => {
      "KeyWord" => "HumanPerformerName",
      "Name" => "Human Performer's Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "4037",
      "group" => "0040"
    },
    "16448" => {
      "KeyWord" => "RawDataHandling",
      "Name" => "Raw Data Handling",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "4040",
      "group" => "0040"
    },
    "16449" => {
      "KeyWord" => "InputReadinessState",
      "Name" => "Input Readiness State",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "4041",
      "group" => "0040"
    },
    "16464" => {
      "KeyWord" => "PerformedProcedureStepStartDateTime",
      "Name" => "Performed Procedure Step Start DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "4050",
      "group" => "0040"
    },
    "16465" => {
      "KeyWord" => "PerformedProcedureStepEndDateTime",
      "Name" => "Performed Procedure Step End DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "4051",
      "group" => "0040"
    },
    "16466" => {
      "KeyWord" => "ProcedureStepCancellationDateTime",
      "Name" => "Procedure Step Cancellation DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "4052",
      "group" => "0040"
    },
    "17" => {
      "KeyWord" => "ScheduledProcedureStepLocation",
      "Name" => "Scheduled Procedure Step Location",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0011",
      "group" => "0040"
    },
    "1786" => {
      "KeyWord" => "SlideIdentifier",
      "Name" => "Slide Identifier",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "06fa",
      "group" => "0040"
    },
    "18" => {
      "KeyWord" => "PreMedication",
      "Name" => "Pre-Medication",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0012",
      "group" => "0040"
    },
    "1818" => {
      "KeyWord" => "ImageCenterPointCoordinatesSequence",
      "Name" => "Image Center Point Coordinates Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "071a",
      "group" => "0040"
    },
    "1834" => {
      "KeyWord" => "XOffsetInSlideCoordinateSystem",
      "Name" => "X Offset in Slide Coordinate System",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "072a",
      "group" => "0040"
    },
    "1850" => {
      "KeyWord" => "YOffsetInSlideCoordinateSystem",
      "Name" => "Y Offset in Slide Coordinate System",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "073a",
      "group" => "0040"
    },
    "1866" => {
      "KeyWord" => "ZOffsetInSlideCoordinateSystem",
      "Name" => "Z Offset in Slide Coordinate System",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "074a",
      "group" => "0040"
    },
    "2" => {
      "KeyWord" => "ScheduledProcedureStepStartDate",
      "Name" => "Scheduled Procedure Step Start Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0002",
      "group" => "0040"
    },
    "2264" => {
      "KeyWord" => "PixelSpacingSequence",
      "Name" => "Pixel Spacing Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "08d8",
      "group" => "0040"
    },
    "2266" => {
      "KeyWord" => "CoordinateSystemAxisCodeSequence",
      "Name" => "Coordinate System Axis Code Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "08da",
      "group" => "0040"
    },
    "2282" => {
      "KeyWord" => "MeasurementUnitsCodeSequence",
      "Name" => "Measurement Units Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "08ea",
      "group" => "0040"
    },
    "2552" => {
      "KeyWord" => "VitalStainCodeSequenceTrial",
      "Name" => "Vital Stain Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "09f8",
      "group" => "0040"
    },
    "256" => {
      "KeyWord" => "ScheduledProcedureStepSequence",
      "Name" => "Scheduled Procedure Step Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0100",
      "group" => "0040"
    },
    "3" => {
      "KeyWord" => "ScheduledProcedureStepStartTime",
      "Name" => "Scheduled Procedure Step Start Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0003",
      "group" => "0040"
    },
    "32" => {
      "KeyWord" => "ScheduledProcedureStepStatus",
      "Name" => "Scheduled Procedure Step Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "0040"
    },
    "33538" => {
      "KeyWord" => "EntranceDoseInmGy",
      "Name" => "Entrance Dose in mGy",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "8302",
      "group" => "0040"
    },
    "37012" => {
      "KeyWord" => "ReferencedImageRealWorldValueMappingSequence",
      "Name" => "Referenced Image Real World Value Mapping Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9094",
      "group" => "0040"
    },
    "37014" => {
      "KeyWord" => "RealWorldValueMappingSequence",
      "Name" => "Real World Value Mapping Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9096",
      "group" => "0040"
    },
    "37016" => {
      "KeyWord" => "PixelValueMappingCodeSequence",
      "Name" => "Pixel Value Mapping Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9098",
      "group" => "0040"
    },
    "37392" => {
      "KeyWord" => "LUTLabel",
      "Name" => "LUT Label",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "9210",
      "group" => "0040"
    },
    "37393" => {
      "KeyWord" => "RealWorldValueLastValueMapped",
      "Name" => "Real World Value Last Value Mapped",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "9211",
      "group" => "0040"
    },
    "37394" => {
      "KeyWord" => "RealWorldValueLUTData",
      "Name" => "Real World Value LUT Data",
      "VM" => "1-n",
      "VR" => "FD",
      "ele" => "9212",
      "group" => "0040"
    },
    "37398" => {
      "KeyWord" => "RealWorldValueFirstValueMapped",
      "Name" => "Real World Value First Value Mapped",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "9216",
      "group" => "0040"
    },
    "37412" => {
      "KeyWord" => "RealWorldValueIntercept",
      "Name" => "Real World Value Intercept",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9224",
      "group" => "0040"
    },
    "37413" => {
      "KeyWord" => "RealWorldValueSlope",
      "Name" => "Real World Value Slope",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "9225",
      "group" => "0040"
    },
    "38" => {
      "KeyWord" => "OrderPlacerIdentifierSequence",
      "Name" => "Order Placer Identifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0026",
      "group" => "0040"
    },
    "39" => {
      "KeyWord" => "OrderFillerIdentifierSequence",
      "Name" => "Order Filler Identifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0027",
      "group" => "0040"
    },
    "4" => {
      "KeyWord" => "ScheduledProcedureStepEndDate",
      "Name" => "Scheduled Procedure Step End Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0004",
      "group" => "0040"
    },
    "40967" => {
      "KeyWord" => "FindingsFlagTrial",
      "Name" => "Findings Flag (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a007",
      "group" => "0040"
    },
    "4097" => {
      "KeyWord" => "RequestedProcedureID",
      "Name" => "Requested Procedure ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1001",
      "group" => "0040"
    },
    "40976" => {
      "KeyWord" => "RelationshipType",
      "Name" => "Relationship Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a010",
      "group" => "0040"
    },
    "4098" => {
      "KeyWord" => "ReasonForTheRequestedProcedure",
      "Name" => "Reason for the Requested Procedure",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1002",
      "group" => "0040"
    },
    "4099" => {
      "KeyWord" => "RequestedProcedurePriority",
      "Name" => "Requested Procedure Priority",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1003",
      "group" => "0040"
    },
    "40992" => {
      "KeyWord" => "FindingsSequenceTrial",
      "Name" => "Findings Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a020",
      "group" => "0040"
    },
    "40993" => {
      "KeyWord" => "FindingsGroupUIDTrial",
      "Name" => "Findings Group UID (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "a021",
      "group" => "0040"
    },
    "40994" => {
      "KeyWord" => "ReferencedFindingsGroupUIDTrial",
      "Name" => "Referenced Findings Group UID (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "a022",
      "group" => "0040"
    },
    "40995" => {
      "KeyWord" => "FindingsGroupRecordingDateTrial",
      "Name" => "Findings Group Recording Date (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "a023",
      "group" => "0040"
    },
    "40996" => {
      "KeyWord" => "FindingsGroupRecordingTimeTrial",
      "Name" => "Findings Group Recording Time (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "a024",
      "group" => "0040"
    },
    "40998" => {
      "KeyWord" => "FindingsSourceCategoryCodeSequenceTrial",
      "Name" => "Findings Source Category Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a026",
      "group" => "0040"
    },
    "40999" => {
      "KeyWord" => "VerifyingOrganization",
      "Name" => "Verifying Organization",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "a027",
      "group" => "0040"
    },
    "4100" => {
      "KeyWord" => "PatientTransportArrangements",
      "Name" => "Patient Transport Arrangements",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1004",
      "group" => "0040"
    },
    "41000" => {
      "KeyWord" => "DocumentingOrganizationIdentifierCodeSequenceTrial",
      "Name" => "Documenting Organization Identifier Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a028",
      "group" => "0040"
    },
    "41008" => {
      "KeyWord" => "VerificationDateTime",
      "Name" => "Verification DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "a030",
      "group" => "0040"
    },
    "4101" => {
      "KeyWord" => "RequestedProcedureLocation",
      "Name" => "Requested Procedure Location",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1005",
      "group" => "0040"
    },
    "41010" => {
      "KeyWord" => "ObservationDateTime",
      "Name" => "Observation DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "a032",
      "group" => "0040"
    },
    "4102" => {
      "KeyWord" => "PlacerOrderNumberProcedure",
      "Name" => "Placer Order Number / Procedure",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1006",
      "group" => "0040"
    },
    "41024" => {
      "KeyWord" => "ValueType",
      "Name" => "Value Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a040",
      "group" => "0040"
    },
    "41027" => {
      "KeyWord" => "ConceptNameCodeSequence",
      "Name" => "Concept Name Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a043",
      "group" => "0040"
    },
    "4103" => {
      "KeyWord" => "FillerOrderNumberProcedure",
      "Name" => "Filler Order Number / Procedure",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1007",
      "group" => "0040"
    },
    "41031" => {
      "KeyWord" => "MeasurementPrecisionDescriptionTrial",
      "Name" => "Measurement Precision Description (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "a047",
      "group" => "0040"
    },
    "4104" => {
      "KeyWord" => "ConfidentialityCode",
      "Name" => "Confidentiality Code",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1008",
      "group" => "0040"
    },
    "41040" => {
      "KeyWord" => "ContinuityOfContent",
      "Name" => "Continuity Of Content",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a050",
      "group" => "0040"
    },
    "41047" => {
      "KeyWord" => "UrgencyOrPriorityAlertsTrial",
      "Name" => "Urgency or Priority Alerts (Trial)",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "a057",
      "group" => "0040"
    },
    "4105" => {
      "KeyWord" => "ReportingPriority",
      "Name" => "Reporting Priority",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1009",
      "group" => "0040"
    },
    "41056" => {
      "KeyWord" => "SequencingIndicatorTrial",
      "Name" => "Sequencing Indicator (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "a060",
      "group" => "0040"
    },
    "4106" => {
      "KeyWord" => "ReasonForRequestedProcedureCodeSequence",
      "Name" => "Reason for Requested Procedure Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "100a",
      "group" => "0040"
    },
    "41062" => {
      "KeyWord" => "DocumentIdentifierCodeSequenceTrial",
      "Name" => "Document Identifier Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a066",
      "group" => "0040"
    },
    "41063" => {
      "KeyWord" => "DocumentAuthorTrial",
      "Name" => "Document Author (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "a067",
      "group" => "0040"
    },
    "41064" => {
      "KeyWord" => "DocumentAuthorIdentifierCodeSequenceTrial",
      "Name" => "Document Author Identifier Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a068",
      "group" => "0040"
    },
    "41072" => {
      "KeyWord" => "IdentifierCodeSequenceTrial",
      "Name" => "Identifier Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a070",
      "group" => "0040"
    },
    "41075" => {
      "KeyWord" => "VerifyingObserverSequence",
      "Name" => "Verifying Observer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a073",
      "group" => "0040"
    },
    "41076" => {
      "KeyWord" => "ObjectBinaryIdentifierTrial",
      "Name" => "Object Binary Identifier (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "a074",
      "group" => "0040"
    },
    "41077" => {
      "KeyWord" => "VerifyingObserverName",
      "Name" => "Verifying Observer Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "a075",
      "group" => "0040"
    },
    "41078" => {
      "KeyWord" => "DocumentingObserverIdentifierCodeSequenceTrial",
      "Name" => "Documenting Observer Identifier Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a076",
      "group" => "0040"
    },
    "41080" => {
      "KeyWord" => "AuthorObserverSequence",
      "Name" => "Author Observer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a078",
      "group" => "0040"
    },
    "41082" => {
      "KeyWord" => "ParticipantSequence",
      "Name" => "Participant Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a07a",
      "group" => "0040"
    },
    "41084" => {
      "KeyWord" => "CustodialOrganizationSequence",
      "Name" => "Custodial Organization Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a07c",
      "group" => "0040"
    },
    "41088" => {
      "KeyWord" => "ParticipationType",
      "Name" => "Participation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a080",
      "group" => "0040"
    },
    "41090" => {
      "KeyWord" => "ParticipationDateTime",
      "Name" => "Participation DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "a082",
      "group" => "0040"
    },
    "41092" => {
      "KeyWord" => "ObserverType",
      "Name" => "Observer Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a084",
      "group" => "0040"
    },
    "41093" => {
      "KeyWord" => "ProcedureIdentifierCodeSequenceTrial",
      "Name" => "Procedure Identifier Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a085",
      "group" => "0040"
    },
    "41096" => {
      "KeyWord" => "VerifyingObserverIdentificationCodeSequence",
      "Name" => "Verifying Observer Identification Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a088",
      "group" => "0040"
    },
    "41097" => {
      "KeyWord" => "ObjectDirectoryBinaryIdentifierTrial",
      "Name" => "Object Directory Binary Identifier (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "a089",
      "group" => "0040"
    },
    "41104" => {
      "KeyWord" => "EquivalentCDADocumentSequence",
      "Name" => "Equivalent CDA Document Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a090",
      "group" => "0040"
    },
    "4112" => {
      "KeyWord" => "NamesOfIntendedRecipientsOfResults",
      "Name" => "Names of Intended Recipients of Results",
      "VM" => "1-n",
      "VR" => "PN",
      "ele" => "1010",
      "group" => "0040"
    },
    "4113" => {
      "KeyWord" => "IntendedRecipientsOfResultsIdentificationSequence",
      "Name" => "Intended Recipients of Results Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1011",
      "group" => "0040"
    },
    "41136" => {
      "KeyWord" => "ReferencedWaveformChannels",
      "Name" => "Referenced Waveform Channels",
      "VM" => "2-2n",
      "VR" => "US",
      "ele" => "a0b0",
      "group" => "0040"
    },
    "4114" => {
      "KeyWord" => "ReasonForPerformedProcedureCodeSequence",
      "Name" => "Reason For Performed Procedure Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1012",
      "group" => "0040"
    },
    "41232" => {
      "KeyWord" => "DateOfDocumentOrVerbalTransactionTrial",
      "Name" => "Date of Document or Verbal Transaction (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "a110",
      "group" => "0040"
    },
    "41234" => {
      "KeyWord" => "TimeOfDocumentCreationOrVerbalTransactionTrial",
      "Name" => "Time of Document Creation or Verbal Transaction (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "a112",
      "group" => "0040"
    },
    "41248" => {
      "KeyWord" => "DateTime",
      "Name" => "DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "a120",
      "group" => "0040"
    },
    "41249" => {
      "KeyWord" => "Date",
      "Name" => "Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "a121",
      "group" => "0040"
    },
    "41250" => {
      "KeyWord" => "Time",
      "Name" => "Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "a122",
      "group" => "0040"
    },
    "41251" => {
      "KeyWord" => "PersonName",
      "Name" => "Person Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "a123",
      "group" => "0040"
    },
    "41252" => {
      "KeyWord" => "UID",
      "Name" => "UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "a124",
      "group" => "0040"
    },
    "41253" => {
      "KeyWord" => "ReportStatusIDTrial",
      "Name" => "Report Status ID (Trial)",
      "RET" => "1",
      "VM" => "2",
      "VR" => "CS",
      "ele" => "a125",
      "group" => "0040"
    },
    "41264" => {
      "KeyWord" => "TemporalRangeType",
      "Name" => "Temporal Range Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a130",
      "group" => "0040"
    },
    "41266" => {
      "KeyWord" => "ReferencedSamplePositions",
      "Name" => "Referenced Sample Positions",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "a132",
      "group" => "0040"
    },
    "41270" => {
      "KeyWord" => "ReferencedFrameNumbers",
      "Name" => "Referenced Frame Numbers",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "a136",
      "group" => "0040"
    },
    "41272" => {
      "KeyWord" => "ReferencedTimeOffsets",
      "Name" => "Referenced Time Offsets",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "a138",
      "group" => "0040"
    },
    "41274" => {
      "KeyWord" => "ReferencedDateTime",
      "Name" => "Referenced DateTime",
      "VM" => "1-n",
      "VR" => "DT",
      "ele" => "a13a",
      "group" => "0040"
    },
    "41312" => {
      "KeyWord" => "TextValue",
      "Name" => "Text Value",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "a160",
      "group" => "0040"
    },
    "41313" => {
      "KeyWord" => "FloatingPointValue",
      "Name" => "Floating Point Value",
      "VM" => "1-n",
      "VR" => "FD",
      "ele" => "a161",
      "group" => "0040"
    },
    "41314" => {
      "KeyWord" => "RationalNumeratorValue",
      "Name" => "Rational Numerator Value",
      "VM" => "1-n",
      "VR" => "SL",
      "ele" => "a162",
      "group" => "0040"
    },
    "41315" => {
      "KeyWord" => "RationalDenominatorValue",
      "Name" => "Rational Denominator Value",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "a163",
      "group" => "0040"
    },
    "41319" => {
      "KeyWord" => "ObservationCategoryCodeSequenceTrial",
      "Name" => "Observation Category Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a167",
      "group" => "0040"
    },
    "41320" => {
      "KeyWord" => "ConceptCodeSequence",
      "Name" => "Concept Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a168",
      "group" => "0040"
    },
    "41322" => {
      "KeyWord" => "BibliographicCitationTrial",
      "Name" => "Bibliographic Citation (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "a16a",
      "group" => "0040"
    },
    "41328" => {
      "KeyWord" => "PurposeOfReferenceCodeSequence",
      "Name" => "Purpose of Reference Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "comment" => "See Note",
      "ele" => "a170",
      "group" => "0040"
    },
    "41329" => {
      "KeyWord" => "ObservationUID",
      "Name" => "Observation UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "a171",
      "group" => "0040"
    },
    "41330" => {
      "KeyWord" => "ReferencedObservationUIDTrial",
      "Name" => "Referenced Observation UID (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "a172",
      "group" => "0040"
    },
    "41331" => {
      "KeyWord" => "ReferencedObservationClassTrial",
      "Name" => "Referenced Observation Class (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a173",
      "group" => "0040"
    },
    "41332" => {
      "KeyWord" => "ReferencedObjectObservationClassTrial",
      "Name" => "Referenced Object Observation Class (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a174",
      "group" => "0040"
    },
    "41344" => {
      "KeyWord" => "AnnotationGroupNumber",
      "Name" => "Annotation Group Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "a180",
      "group" => "0040"
    },
    "41362" => {
      "KeyWord" => "ObservationDateTrial",
      "Name" => "Observation Date (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "a192",
      "group" => "0040"
    },
    "41363" => {
      "KeyWord" => "ObservationTimeTrial",
      "Name" => "Observation Time (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "a193",
      "group" => "0040"
    },
    "41364" => {
      "KeyWord" => "MeasurementAutomationTrial",
      "Name" => "Measurement Automation (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a194",
      "group" => "0040"
    },
    "41365" => {
      "KeyWord" => "ModifierCodeSequence",
      "Name" => "Modifier Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a195",
      "group" => "0040"
    },
    "41508" => {
      "KeyWord" => "IdentificationDescriptionTrial",
      "Name" => "Identification Description (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "a224",
      "group" => "0040"
    },
    "41616" => {
      "KeyWord" => "CoordinatesSetGeometricTypeTrial",
      "Name" => "Coordinates Set Geometric Type (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a290",
      "group" => "0040"
    },
    "41622" => {
      "KeyWord" => "AlgorithmCodeSequenceTrial",
      "Name" => "Algorithm Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a296",
      "group" => "0040"
    },
    "41623" => {
      "KeyWord" => "AlgorithmDescriptionTrial",
      "Name" => "Algorithm Description (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "a297",
      "group" => "0040"
    },
    "41626" => {
      "KeyWord" => "PixelCoordinatesSetTrial",
      "Name" => "Pixel Coordinates Set (Trial)",
      "RET" => "1",
      "VM" => "2-2n",
      "VR" => "SL",
      "ele" => "a29a",
      "group" => "0040"
    },
    "41728" => {
      "KeyWord" => "MeasuredValueSequence",
      "Name" => "Measured Value Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a300",
      "group" => "0040"
    },
    "41729" => {
      "KeyWord" => "NumericValueQualifierCodeSequence",
      "Name" => "Numeric Value Qualifier Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a301",
      "group" => "0040"
    },
    "41735" => {
      "KeyWord" => "CurrentObserverTrial",
      "Name" => "Current Observer (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "a307",
      "group" => "0040"
    },
    "41738" => {
      "KeyWord" => "NumericValue",
      "Name" => "Numeric Value",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "a30a",
      "group" => "0040"
    },
    "41747" => {
      "KeyWord" => "ReferencedAccessionSequenceTrial",
      "Name" => "Referenced Accession Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a313",
      "group" => "0040"
    },
    "41786" => {
      "KeyWord" => "ReportStatusCommentTrial",
      "Name" => "Report Status Comment (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "a33a",
      "group" => "0040"
    },
    "41792" => {
      "KeyWord" => "ProcedureContextSequenceTrial",
      "Name" => "Procedure Context Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a340",
      "group" => "0040"
    },
    "41810" => {
      "KeyWord" => "VerbalSourceTrial",
      "Name" => "Verbal Source (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "a352",
      "group" => "0040"
    },
    "41811" => {
      "KeyWord" => "AddressTrial",
      "Name" => "Address (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "a353",
      "group" => "0040"
    },
    "41812" => {
      "KeyWord" => "TelephoneNumberTrial",
      "Name" => "Telephone Number (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "a354",
      "group" => "0040"
    },
    "41816" => {
      "KeyWord" => "VerbalSourceIdentifierCodeSequenceTrial",
      "Name" => "Verbal Source Identifier Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a358",
      "group" => "0040"
    },
    "41824" => {
      "KeyWord" => "PredecessorDocumentsSequence",
      "Name" => "Predecessor Documents Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a360",
      "group" => "0040"
    },
    "41840" => {
      "KeyWord" => "ReferencedRequestSequence",
      "Name" => "Referenced Request Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a370",
      "group" => "0040"
    },
    "41842" => {
      "KeyWord" => "PerformedProcedureCodeSequence",
      "Name" => "Performed Procedure Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a372",
      "group" => "0040"
    },
    "41845" => {
      "KeyWord" => "CurrentRequestedProcedureEvidenceSequence",
      "Name" => "Current Requested Procedure Evidence Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a375",
      "group" => "0040"
    },
    "41856" => {
      "KeyWord" => "ReportDetailSequenceTrial",
      "Name" => "Report Detail Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a380",
      "group" => "0040"
    },
    "41861" => {
      "KeyWord" => "PertinentOtherEvidenceSequence",
      "Name" => "Pertinent Other Evidence Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a385",
      "group" => "0040"
    },
    "41872" => {
      "KeyWord" => "HL7StructuredDocumentReferenceSequence",
      "Name" => "HL7 Structured Document Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a390",
      "group" => "0040"
    },
    "4192" => {
      "KeyWord" => "RequestedProcedureDescriptionTrial",
      "Name" => "Requested Procedure Description (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1060",
      "group" => "0040"
    },
    "41986" => {
      "KeyWord" => "ObservationSubjectUIDTrial",
      "Name" => "Observation Subject UID (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "a402",
      "group" => "0040"
    },
    "41987" => {
      "KeyWord" => "ObservationSubjectClassTrial",
      "Name" => "Observation Subject Class (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a403",
      "group" => "0040"
    },
    "41988" => {
      "KeyWord" => "ObservationSubjectTypeCodeSequenceTrial",
      "Name" => "Observation Subject Type Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a404",
      "group" => "0040"
    },
    "42129" => {
      "KeyWord" => "CompletionFlag",
      "Name" => "Completion Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a491",
      "group" => "0040"
    },
    "42130" => {
      "KeyWord" => "CompletionFlagDescription",
      "Name" => "Completion Flag Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "a492",
      "group" => "0040"
    },
    "42131" => {
      "KeyWord" => "VerificationFlag",
      "Name" => "Verification Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a493",
      "group" => "0040"
    },
    "42132" => {
      "KeyWord" => "ArchiveRequested",
      "Name" => "Archive Requested",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a494",
      "group" => "0040"
    },
    "42134" => {
      "KeyWord" => "PreliminaryFlag",
      "Name" => "Preliminary Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a496",
      "group" => "0040"
    },
    "42244" => {
      "KeyWord" => "ContentTemplateSequence",
      "Name" => "Content Template Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a504",
      "group" => "0040"
    },
    "42277" => {
      "KeyWord" => "IdenticalDocumentsSequence",
      "Name" => "Identical Documents Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a525",
      "group" => "0040"
    },
    "42496" => {
      "KeyWord" => "ObservationSubjectContextFlagTrial",
      "Name" => "Observation Subject Context Flag (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a600",
      "group" => "0040"
    },
    "42497" => {
      "KeyWord" => "ObserverContextFlagTrial",
      "Name" => "Observer Context Flag (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a601",
      "group" => "0040"
    },
    "42499" => {
      "KeyWord" => "ProcedureContextFlagTrial",
      "Name" => "Procedure Context Flag (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "a603",
      "group" => "0040"
    },
    "42800" => {
      "KeyWord" => "ContentSequence",
      "Name" => "Content Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a730",
      "group" => "0040"
    },
    "42801" => {
      "KeyWord" => "RelationshipSequenceTrial",
      "Name" => "Relationship Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a731",
      "group" => "0040"
    },
    "42802" => {
      "KeyWord" => "RelationshipTypeCodeSequenceTrial",
      "Name" => "Relationship Type Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a732",
      "group" => "0040"
    },
    "42820" => {
      "KeyWord" => "LanguageCodeSequenceTrial",
      "Name" => "Language Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "a744",
      "group" => "0040"
    },
    "43410" => {
      "KeyWord" => "UniformResourceLocatorTrial",
      "Name" => "Uniform Resource Locator (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "a992",
      "group" => "0040"
    },
    "4353" => {
      "KeyWord" => "PersonIdentificationCodeSequence",
      "Name" => "Person Identification Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1101",
      "group" => "0040"
    },
    "4354" => {
      "KeyWord" => "PersonAddress",
      "Name" => "Person's Address",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "1102",
      "group" => "0040"
    },
    "4355" => {
      "KeyWord" => "PersonTelephoneNumbers",
      "Name" => "Person's Telephone Numbers",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1103",
      "group" => "0040"
    },
    "45088" => {
      "KeyWord" => "WaveformAnnotationSequence",
      "Name" => "Waveform Annotation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "b020",
      "group" => "0040"
    },
    "49" => {
      "KeyWord" => "LocalNamespaceEntityID",
      "Name" => "Local Namespace Entity ID",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "0031",
      "group" => "0040"
    },
    "5" => {
      "KeyWord" => "ScheduledProcedureStepEndTime",
      "Name" => "Scheduled Procedure Step End Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0005",
      "group" => "0040"
    },
    "50" => {
      "KeyWord" => "UniversalEntityID",
      "Name" => "Universal Entity ID",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "0032",
      "group" => "0040"
    },
    "51" => {
      "KeyWord" => "UniversalEntityIDType",
      "Name" => "Universal Entity ID Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0033",
      "group" => "0040"
    },
    "5120" => {
      "KeyWord" => "RequestedProcedureComments",
      "Name" => "Requested Procedure Comments",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "1400",
      "group" => "0040"
    },
    "53" => {
      "KeyWord" => "IdentifierTypeCode",
      "Name" => "Identifier Type Code",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0035",
      "group" => "0040"
    },
    "54" => {
      "KeyWord" => "AssigningFacilitySequence",
      "Name" => "Assigning Facility Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0036",
      "group" => "0040"
    },
    "544" => {
      "KeyWord" => "ReferencedNonImageCompositeSOPInstanceSequence",
      "Name" => "Referenced Non-Image Composite SOP Instance Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0220",
      "group" => "0040"
    },
    "56064" => {
      "KeyWord" => "TemplateIdentifier",
      "Name" => "Template Identifier",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "db00",
      "group" => "0040"
    },
    "56070" => {
      "KeyWord" => "TemplateVersion",
      "Name" => "Template Version",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "db06",
      "group" => "0040"
    },
    "56071" => {
      "KeyWord" => "TemplateLocalVersion",
      "Name" => "Template Local Version",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "db07",
      "group" => "0040"
    },
    "56075" => {
      "KeyWord" => "TemplateExtensionFlag",
      "Name" => "Template Extension Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "db0b",
      "group" => "0040"
    },
    "56076" => {
      "KeyWord" => "TemplateExtensionOrganizationUID",
      "Name" => "Template Extension Organization UID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "db0c",
      "group" => "0040"
    },
    "56077" => {
      "KeyWord" => "TemplateExtensionCreatorUID",
      "Name" => "Template Extension Creator UID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "db0d",
      "group" => "0040"
    },
    "56179" => {
      "KeyWord" => "ReferencedContentItemIdentifier",
      "Name" => "Referenced Content Item Identifier",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "db73",
      "group" => "0040"
    },
    "57" => {
      "KeyWord" => "AssigningJurisdictionCodeSequence",
      "Name" => "Assigning Jurisdiction Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0039",
      "group" => "0040"
    },
    "57345" => {
      "KeyWord" => "HL7InstanceIdentifier",
      "Name" => "HL7 Instance Identifier",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "e001",
      "group" => "0040"
    },
    "57348" => {
      "KeyWord" => "HL7DocumentEffectiveTime",
      "Name" => "HL7 Document Effective Time",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "e004",
      "group" => "0040"
    },
    "57350" => {
      "KeyWord" => "HL7DocumentTypeCodeSequence",
      "Name" => "HL7 Document Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "e006",
      "group" => "0040"
    },
    "57352" => {
      "KeyWord" => "DocumentClassCodeSequence",
      "Name" => "Document Class Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "e008",
      "group" => "0040"
    },
    "57360" => {
      "KeyWord" => "RetrieveURI",
      "Name" => "Retrieve URI",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "e010",
      "group" => "0040"
    },
    "57361" => {
      "KeyWord" => "RetrieveLocationUID",
      "Name" => "Retrieve Location UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "e011",
      "group" => "0040"
    },
    "57376" => {
      "KeyWord" => "TypeOfInstances",
      "Name" => "Type of Instances",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "e020",
      "group" => "0040"
    },
    "57377" => {
      "KeyWord" => "DICOMRetrievalSequence",
      "Name" => "DICOM Retrieval Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "e021",
      "group" => "0040"
    },
    "57378" => {
      "KeyWord" => "DICOMMediaRetrievalSequence",
      "Name" => "DICOM Media Retrieval Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "e022",
      "group" => "0040"
    },
    "57379" => {
      "KeyWord" => "WADORetrievalSequence",
      "Name" => "WADO Retrieval Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "e023",
      "group" => "0040"
    },
    "57380" => {
      "KeyWord" => "XDSRetrievalSequence",
      "Name" => "XDS Retrieval Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "e024",
      "group" => "0040"
    },
    "57392" => {
      "KeyWord" => "RepositoryUniqueID",
      "Name" => "Repository Unique ID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "e030",
      "group" => "0040"
    },
    "57393" => {
      "KeyWord" => "HomeCommunityID",
      "Name" => "Home Community ID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "e031",
      "group" => "0040"
    },
    "577" => {
      "KeyWord" => "PerformedStationAETitle",
      "Name" => "Performed Station AE Title",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "0241",
      "group" => "0040"
    },
    "578" => {
      "KeyWord" => "PerformedStationName",
      "Name" => "Performed Station Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0242",
      "group" => "0040"
    },
    "579" => {
      "KeyWord" => "PerformedLocation",
      "Name" => "Performed Location",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0243",
      "group" => "0040"
    },
    "58" => {
      "KeyWord" => "AssigningAgencyOrDepartmentCodeSequence",
      "Name" => "Assigning Agency or Department Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "003a",
      "group" => "0040"
    },
    "580" => {
      "KeyWord" => "PerformedProcedureStepStartDate",
      "Name" => "Performed Procedure Step Start Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0244",
      "group" => "0040"
    },
    "581" => {
      "KeyWord" => "PerformedProcedureStepStartTime",
      "Name" => "Performed Procedure Step Start Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0245",
      "group" => "0040"
    },
    "592" => {
      "KeyWord" => "PerformedProcedureStepEndDate",
      "Name" => "Performed Procedure Step End Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0250",
      "group" => "0040"
    },
    "593" => {
      "KeyWord" => "PerformedProcedureStepEndTime",
      "Name" => "Performed Procedure Step End Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0251",
      "group" => "0040"
    },
    "594" => {
      "KeyWord" => "PerformedProcedureStepStatus",
      "Name" => "Performed Procedure Step Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0252",
      "group" => "0040"
    },
    "595" => {
      "KeyWord" => "PerformedProcedureStepID",
      "Name" => "Performed Procedure Step ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0253",
      "group" => "0040"
    },
    "596" => {
      "KeyWord" => "PerformedProcedureStepDescription",
      "Name" => "Performed Procedure Step Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0254",
      "group" => "0040"
    },
    "597" => {
      "KeyWord" => "PerformedProcedureTypeDescription",
      "Name" => "Performed Procedure Type Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0255",
      "group" => "0040"
    },
    "6" => {
      "KeyWord" => "ScheduledPerformingPhysicianName",
      "Name" => "Scheduled Performing Physician's Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "0006",
      "group" => "0040"
    },
    "608" => {
      "KeyWord" => "PerformedProtocolCodeSequence",
      "Name" => "Performed Protocol Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0260",
      "group" => "0040"
    },
    "609" => {
      "KeyWord" => "PerformedProtocolType",
      "Name" => "Performed Protocol Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0261",
      "group" => "0040"
    },
    "624" => {
      "KeyWord" => "ScheduledStepAttributesSequence",
      "Name" => "Scheduled Step Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0270",
      "group" => "0040"
    },
    "629" => {
      "KeyWord" => "RequestAttributesSequence",
      "Name" => "Request Attributes Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0275",
      "group" => "0040"
    },
    "640" => {
      "KeyWord" => "CommentsOnThePerformedProcedureStep",
      "Name" => "Comments on the Performed Procedure Step",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0280",
      "group" => "0040"
    },
    "641" => {
      "KeyWord" => "PerformedProcedureStepDiscontinuationReasonCodeSequence",
      "Name" => "Performed Procedure Step Discontinuation Reason Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0281",
      "group" => "0040"
    },
    "659" => {
      "KeyWord" => "QuantitySequence",
      "Name" => "Quantity Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0293",
      "group" => "0040"
    },
    "660" => {
      "KeyWord" => "Quantity",
      "Name" => "Quantity",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0294",
      "group" => "0040"
    },
    "661" => {
      "KeyWord" => "MeasuringUnitsSequence",
      "Name" => "Measuring Units Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0295",
      "group" => "0040"
    },
    "662" => {
      "KeyWord" => "BillingItemSequence",
      "Name" => "Billing Item Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0296",
      "group" => "0040"
    },
    "7" => {
      "KeyWord" => "ScheduledProcedureStepDescription",
      "Name" => "Scheduled Procedure Step Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0007",
      "group" => "0040"
    },
    "768" => {
      "KeyWord" => "TotalTimeOfFluoroscopy",
      "Name" => "Total Time of Fluoroscopy",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0300",
      "group" => "0040"
    },
    "769" => {
      "KeyWord" => "TotalNumberOfExposures",
      "Name" => "Total Number of Exposures",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0301",
      "group" => "0040"
    },
    "770" => {
      "KeyWord" => "EntranceDose",
      "Name" => "Entrance Dose",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0302",
      "group" => "0040"
    },
    "771" => {
      "KeyWord" => "ExposedArea",
      "Name" => "Exposed Area",
      "VM" => "1-2",
      "VR" => "US",
      "ele" => "0303",
      "group" => "0040"
    },
    "774" => {
      "KeyWord" => "DistanceSourceToEntrance",
      "Name" => "Distance Source to Entrance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0306",
      "group" => "0040"
    },
    "775" => {
      "KeyWord" => "DistanceSourceToSupport",
      "Name" => "Distance Source to Support",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0307",
      "group" => "0040"
    },
    "782" => {
      "KeyWord" => "ExposureDoseSequence",
      "Name" => "Exposure Dose Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "030e",
      "group" => "0040"
    },
    "784" => {
      "KeyWord" => "CommentsOnRadiationDose",
      "Name" => "Comments on Radiation Dose",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0310",
      "group" => "0040"
    },
    "786" => {
      "KeyWord" => "XRayOutput",
      "Name" => "X-Ray Output",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0312",
      "group" => "0040"
    },
    "788" => {
      "KeyWord" => "HalfValueLayer",
      "Name" => "Half Value Layer",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0314",
      "group" => "0040"
    },
    "790" => {
      "KeyWord" => "OrganDose",
      "Name" => "Organ Dose",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0316",
      "group" => "0040"
    },
    "792" => {
      "KeyWord" => "OrganExposed",
      "Name" => "Organ Exposed",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0318",
      "group" => "0040"
    },
    "8" => {
      "KeyWord" => "ScheduledProtocolCodeSequence",
      "Name" => "Scheduled Protocol Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0008",
      "group" => "0040"
    },
    "800" => {
      "KeyWord" => "BillingProcedureStepSequence",
      "Name" => "Billing Procedure Step Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0320",
      "group" => "0040"
    },
    "801" => {
      "KeyWord" => "FilmConsumptionSequence",
      "Name" => "Film Consumption Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0321",
      "group" => "0040"
    },
    "804" => {
      "KeyWord" => "BillingSuppliesAndDevicesSequence",
      "Name" => "Billing Supplies and Devices Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0324",
      "group" => "0040"
    },
    "816" => {
      "KeyWord" => "ReferencedProcedureStepSequence",
      "Name" => "Referenced Procedure Step Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0330",
      "group" => "0040"
    },
    "8193" => {
      "KeyWord" => "ReasonForTheImagingServiceRequest",
      "Name" => "Reason for the Imaging Service Request",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2001",
      "group" => "0040"
    },
    "8196" => {
      "KeyWord" => "IssueDateOfImagingServiceRequest",
      "Name" => "Issue Date of Imaging Service Request",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "2004",
      "group" => "0040"
    },
    "8197" => {
      "KeyWord" => "IssueTimeOfImagingServiceRequest",
      "Name" => "Issue Time of Imaging Service Request",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "2005",
      "group" => "0040"
    },
    "8198" => {
      "KeyWord" => "PlacerOrderNumberImagingServiceRequestRetired",
      "Name" => "Placer Order Number / Imaging Service Request (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2006",
      "group" => "0040"
    },
    "8199" => {
      "KeyWord" => "FillerOrderNumberImagingServiceRequestRetired",
      "Name" => "Filler Order Number / Imaging Service Request (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2007",
      "group" => "0040"
    },
    "8200" => {
      "KeyWord" => "OrderEnteredBy",
      "Name" => "Order Entered By",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "2008",
      "group" => "0040"
    },
    "8201" => {
      "KeyWord" => "OrderEntererLocation",
      "Name" => "Order Enterer's Location",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2009",
      "group" => "0040"
    },
    "8208" => {
      "KeyWord" => "OrderCallbackPhoneNumber",
      "Name" => "Order Callback Phone Number",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2010",
      "group" => "0040"
    },
    "8214" => {
      "KeyWord" => "PlacerOrderNumberImagingServiceRequest",
      "Name" => "Placer Order Number / Imaging Service Request",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2016",
      "group" => "0040"
    },
    "8215" => {
      "KeyWord" => "FillerOrderNumberImagingServiceRequest",
      "Name" => "Filler Order Number / Imaging Service Request",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "2017",
      "group" => "0040"
    },
    "832" => {
      "KeyWord" => "PerformedSeriesSequence",
      "Name" => "Performed Series Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0340",
      "group" => "0040"
    },
    "9" => {
      "KeyWord" => "ScheduledProcedureStepID",
      "Name" => "Scheduled Procedure Step ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0009",
      "group" => "0040"
    },
    "9216" => {
      "KeyWord" => "ImagingServiceRequestComments",
      "Name" => "Imaging Service Request Comments",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "2400",
      "group" => "0040"
    }
  },
  "65530" => {
    "65530" => {
      "KeyWord" => "DigitalSignaturesSequence",
      "Name" => "Digital Signatures Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "fffa",
      "group" => "fffa"
    }
  },
  "65532" => {
    "65532" => {
      "KeyWord" => "DataSetTrailingPadding",
      "Name" => "Data Set Trailing Padding",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "fffc",
      "group" => "fffc"
    }
  },
  "65534" => {
    "57344" => {
      "KeyWord" => "Item",
      "Name" => "Item",
      "VM" => "1",
      "VR" => "See Note",
      "ele" => "e000",
      "group" => "fffe"
    },
    "57357" => {
      "KeyWord" => "ItemDelimitationItem",
      "Name" => "Item Delimitation Item",
      "VM" => "1",
      "VR" => "See Note",
      "ele" => "e00d",
      "group" => "fffe"
    },
    "57565" => {
      "KeyWord" => "SequenceDelimitationItem",
      "Name" => "Sequence Delimitation Item",
      "VM" => "1",
      "VR" => "See Note",
      "ele" => "e0dd",
      "group" => "fffe"
    }
  },
  "66" => {
    "16" => {
      "KeyWord" => "DocumentTitle",
      "Name" => "Document Title",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0010",
      "group" => "0042"
    },
    "17" => {
      "KeyWord" => "EncapsulatedDocument",
      "Name" => "Encapsulated Document",
      "VM" => "1",
      "VR" => "OB",
      "ele" => "0011",
      "group" => "0042"
    },
    "18" => {
      "KeyWord" => "MIMETypeOfEncapsulatedDocument",
      "Name" => "MIME Type of Encapsulated Document",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0012",
      "group" => "0042"
    },
    "19" => {
      "KeyWord" => "SourceInstanceSequence",
      "Name" => "Source Instance Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0013",
      "group" => "0042"
    },
    "20" => {
      "KeyWord" => "ListOfMIMETypes",
      "Name" => "List of MIME Types",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0014",
      "group" => "0042"
    }
  },
  "68" => {
    "1" => {
      "KeyWord" => "ProductPackageIdentifier",
      "Name" => "Product Package Identifier",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0001",
      "group" => "0044"
    },
    "10" => {
      "KeyWord" => "ProductLotIdentifier",
      "Name" => "Product Lot Identifier",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "000a",
      "group" => "0044"
    },
    "11" => {
      "KeyWord" => "ProductExpirationDateTime",
      "Name" => "Product Expiration DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "000b",
      "group" => "0044"
    },
    "16" => {
      "KeyWord" => "SubstanceAdministrationDateTime",
      "Name" => "Substance Administration DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "0010",
      "group" => "0044"
    },
    "17" => {
      "KeyWord" => "SubstanceAdministrationNotes",
      "Name" => "Substance Administration Notes",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0011",
      "group" => "0044"
    },
    "18" => {
      "KeyWord" => "SubstanceAdministrationDeviceID",
      "Name" => "Substance Administration Device ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0012",
      "group" => "0044"
    },
    "19" => {
      "KeyWord" => "ProductParameterSequence",
      "Name" => "Product Parameter Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0013",
      "group" => "0044"
    },
    "2" => {
      "KeyWord" => "SubstanceAdministrationApproval",
      "Name" => "Substance Administration Approval",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0002",
      "group" => "0044"
    },
    "25" => {
      "KeyWord" => "SubstanceAdministrationParameterSequence",
      "Name" => "Substance Administration Parameter Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0019",
      "group" => "0044"
    },
    "3" => {
      "KeyWord" => "ApprovalStatusFurtherDescription",
      "Name" => "Approval Status Further Description",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0003",
      "group" => "0044"
    },
    "4" => {
      "KeyWord" => "ApprovalStatusDateTime",
      "Name" => "Approval Status DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "0004",
      "group" => "0044"
    },
    "7" => {
      "KeyWord" => "ProductTypeCodeSequence",
      "Name" => "Product Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0007",
      "group" => "0044"
    },
    "8" => {
      "KeyWord" => "ProductName",
      "Name" => "Product Name",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "0008",
      "group" => "0044"
    },
    "9" => {
      "KeyWord" => "ProductDescription",
      "Name" => "Product Description",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0009",
      "group" => "0044"
    }
  },
  "70" => {
    "100" => {
      "KeyWord" => "OtherPupillaryDistance",
      "Name" => "Other Pupillary Distance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0064",
      "group" => "0046"
    },
    "112" => {
      "KeyWord" => "KeratometryRightEyeSequence",
      "Name" => "Keratometry Right Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0070",
      "group" => "0046"
    },
    "113" => {
      "KeyWord" => "KeratometryLeftEyeSequence",
      "Name" => "Keratometry Left Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0071",
      "group" => "0046"
    },
    "116" => {
      "KeyWord" => "SteepKeratometricAxisSequence",
      "Name" => "Steep Keratometric Axis Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0074",
      "group" => "0046"
    },
    "117" => {
      "KeyWord" => "RadiusOfCurvature",
      "Name" => "Radius of Curvature",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0075",
      "group" => "0046"
    },
    "118" => {
      "KeyWord" => "KeratometricPower",
      "Name" => "Keratometric Power",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0076",
      "group" => "0046"
    },
    "119" => {
      "KeyWord" => "KeratometricAxis",
      "Name" => "Keratometric Axis",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0077",
      "group" => "0046"
    },
    "128" => {
      "KeyWord" => "FlatKeratometricAxisSequence",
      "Name" => "Flat Keratometric Axis Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0080",
      "group" => "0046"
    },
    "146" => {
      "KeyWord" => "BackgroundColor",
      "Name" => "Background Color",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0092",
      "group" => "0046"
    },
    "148" => {
      "KeyWord" => "Optotype",
      "Name" => "Optotype",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0094",
      "group" => "0046"
    },
    "149" => {
      "KeyWord" => "OptotypePresentation",
      "Name" => "Optotype Presentation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0095",
      "group" => "0046"
    },
    "151" => {
      "KeyWord" => "SubjectiveRefractionRightEyeSequence",
      "Name" => "Subjective Refraction Right Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0097",
      "group" => "0046"
    },
    "152" => {
      "KeyWord" => "SubjectiveRefractionLeftEyeSequence",
      "Name" => "Subjective Refraction Left Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0098",
      "group" => "0046"
    },
    "18" => {
      "KeyWord" => "LensDescription",
      "Name" => "Lens Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0012",
      "group" => "0046"
    },
    "20" => {
      "KeyWord" => "RightLensSequence",
      "Name" => "Right Lens Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0014",
      "group" => "0046"
    },
    "21" => {
      "KeyWord" => "LeftLensSequence",
      "Name" => "Left Lens Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0015",
      "group" => "0046"
    },
    "22" => {
      "KeyWord" => "UnspecifiedLateralityLensSequence",
      "Name" => "Unspecified Laterality Lens Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0016",
      "group" => "0046"
    },
    "24" => {
      "KeyWord" => "CylinderSequence",
      "Name" => "Cylinder Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0018",
      "group" => "0046"
    },
    "256" => {
      "KeyWord" => "AddNearSequence",
      "Name" => "Add Near Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0100",
      "group" => "0046"
    },
    "257" => {
      "KeyWord" => "AddIntermediateSequence",
      "Name" => "Add Intermediate Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0101",
      "group" => "0046"
    },
    "258" => {
      "KeyWord" => "AddOtherSequence",
      "Name" => "Add Other Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0102",
      "group" => "0046"
    },
    "260" => {
      "KeyWord" => "AddPower",
      "Name" => "Add Power",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0104",
      "group" => "0046"
    },
    "262" => {
      "KeyWord" => "ViewingDistance",
      "Name" => "Viewing Distance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0106",
      "group" => "0046"
    },
    "289" => {
      "KeyWord" => "VisualAcuityTypeCodeSequence",
      "Name" => "Visual Acuity Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0121",
      "group" => "0046"
    },
    "290" => {
      "KeyWord" => "VisualAcuityRightEyeSequence",
      "Name" => "Visual Acuity Right Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0122",
      "group" => "0046"
    },
    "291" => {
      "KeyWord" => "VisualAcuityLeftEyeSequence",
      "Name" => "Visual Acuity Left Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0123",
      "group" => "0046"
    },
    "292" => {
      "KeyWord" => "VisualAcuityBothEyesOpenSequence",
      "Name" => "Visual Acuity Both Eyes Open Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0124",
      "group" => "0046"
    },
    "293" => {
      "KeyWord" => "ViewingDistanceType",
      "Name" => "Viewing Distance Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0125",
      "group" => "0046"
    },
    "309" => {
      "KeyWord" => "VisualAcuityModifiers",
      "Name" => "Visual Acuity Modifiers",
      "VM" => "2",
      "VR" => "SS",
      "ele" => "0135",
      "group" => "0046"
    },
    "311" => {
      "KeyWord" => "DecimalVisualAcuity",
      "Name" => "Decimal Visual Acuity",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0137",
      "group" => "0046"
    },
    "313" => {
      "KeyWord" => "OptotypeDetailedDefinition",
      "Name" => "Optotype Detailed Definition",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0139",
      "group" => "0046"
    },
    "325" => {
      "KeyWord" => "ReferencedRefractiveMeasurementsSequence",
      "Name" => "Referenced Refractive Measurements Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0145",
      "group" => "0046"
    },
    "326" => {
      "KeyWord" => "SpherePower",
      "Name" => "Sphere Power",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0146",
      "group" => "0046"
    },
    "327" => {
      "KeyWord" => "CylinderPower",
      "Name" => "Cylinder Power",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0147",
      "group" => "0046"
    },
    "40" => {
      "KeyWord" => "PrismSequence",
      "Name" => "Prism Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0028",
      "group" => "0046"
    },
    "48" => {
      "KeyWord" => "HorizontalPrismPower",
      "Name" => "Horizontal Prism Power",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0030",
      "group" => "0046"
    },
    "50" => {
      "KeyWord" => "HorizontalPrismBase",
      "Name" => "Horizontal Prism Base",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0032",
      "group" => "0046"
    },
    "513" => {
      "KeyWord" => "CornealTopographySurface",
      "Name" => "Corneal Topography Surface",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0201",
      "group" => "0046"
    },
    "514" => {
      "KeyWord" => "CornealVertexLocation",
      "Name" => "Corneal Vertex Location",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "0202",
      "group" => "0046"
    },
    "515" => {
      "KeyWord" => "PupilCentroidXCoordinate",
      "Name" => "Pupil Centroid X-Coordinate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0203",
      "group" => "0046"
    },
    "516" => {
      "KeyWord" => "PupilCentroidYCoordinate",
      "Name" => "Pupil Centroid Y-Coordinate",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0204",
      "group" => "0046"
    },
    "517" => {
      "KeyWord" => "EquivalentPupilRadius",
      "Name" => "Equivalent Pupil Radius",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0205",
      "group" => "0046"
    },
    "519" => {
      "KeyWord" => "CornealTopographyMapTypeCodeSequence",
      "Name" => "Corneal Topography Map Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0207",
      "group" => "0046"
    },
    "52" => {
      "KeyWord" => "VerticalPrismPower",
      "Name" => "Vertical Prism Power",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0034",
      "group" => "0046"
    },
    "520" => {
      "KeyWord" => "VerticesOfTheOutlineOfPupil",
      "Name" => "Vertices of the Outline of Pupil",
      "VM" => "2-2n",
      "VR" => "IS",
      "ele" => "0208",
      "group" => "0046"
    },
    "528" => {
      "KeyWord" => "CornealTopographyMappingNormalsSequence",
      "Name" => "Corneal Topography Mapping Normals Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0210",
      "group" => "0046"
    },
    "529" => {
      "KeyWord" => "MaximumCornealCurvatureSequence",
      "Name" => "Maximum Corneal Curvature Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0211",
      "group" => "0046"
    },
    "530" => {
      "KeyWord" => "MaximumCornealCurvature",
      "Name" => "Maximum Corneal Curvature",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0212",
      "group" => "0046"
    },
    "531" => {
      "KeyWord" => "MaximumCornealCurvatureLocation",
      "Name" => "Maximum Corneal Curvature Location",
      "VM" => "2",
      "VR" => "FL",
      "ele" => "0213",
      "group" => "0046"
    },
    "533" => {
      "KeyWord" => "MinimumKeratometricSequence",
      "Name" => "Minimum Keratometric Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0215",
      "group" => "0046"
    },
    "536" => {
      "KeyWord" => "SimulatedKeratometricCylinderSequence",
      "Name" => "Simulated Keratometric Cylinder Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0218",
      "group" => "0046"
    },
    "54" => {
      "KeyWord" => "VerticalPrismBase",
      "Name" => "Vertical Prism Base",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0036",
      "group" => "0046"
    },
    "544" => {
      "KeyWord" => "AverageCornealPower",
      "Name" => "Average Corneal Power",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0220",
      "group" => "0046"
    },
    "548" => {
      "KeyWord" => "CornealISValue",
      "Name" => "Corneal I-S Value",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0224",
      "group" => "0046"
    },
    "551" => {
      "KeyWord" => "AnalyzedArea",
      "Name" => "Analyzed Area",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0227",
      "group" => "0046"
    },
    "56" => {
      "KeyWord" => "LensSegmentType",
      "Name" => "Lens Segment Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0038",
      "group" => "0046"
    },
    "560" => {
      "KeyWord" => "SurfaceRegularityIndex",
      "Name" => "Surface Regularity Index",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0230",
      "group" => "0046"
    },
    "562" => {
      "KeyWord" => "SurfaceAsymmetryIndex",
      "Name" => "Surface Asymmetry Index",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0232",
      "group" => "0046"
    },
    "564" => {
      "KeyWord" => "CornealEccentricityIndex",
      "Name" => "Corneal Eccentricity Index",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0234",
      "group" => "0046"
    },
    "566" => {
      "KeyWord" => "KeratoconusPredictionIndex",
      "Name" => "Keratoconus Prediction Index",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0236",
      "group" => "0046"
    },
    "568" => {
      "KeyWord" => "DecimalPotentialVisualAcuity",
      "Name" => "Decimal Potential Visual Acuity",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0238",
      "group" => "0046"
    },
    "578" => {
      "KeyWord" => "CornealTopographyMapQualityEvaluation",
      "Name" => "Corneal Topography Map Quality Evaluation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0242",
      "group" => "0046"
    },
    "580" => {
      "KeyWord" => "SourceImageCornealProcessedDataSequence",
      "Name" => "Source Image Corneal Processed Data Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0244",
      "group" => "0046"
    },
    "583" => {
      "KeyWord" => "CornealPointLocation",
      "Name" => "Corneal Point Location",
      "VM" => "3",
      "VR" => "FL",
      "ele" => "0247",
      "group" => "0046"
    },
    "584" => {
      "KeyWord" => "CornealPointEstimated",
      "Name" => "Corneal Point Estimated",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0248",
      "group" => "0046"
    },
    "585" => {
      "KeyWord" => "AxialPower",
      "Name" => "Axial Power",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0249",
      "group" => "0046"
    },
    "592" => {
      "KeyWord" => "TangentialPower",
      "Name" => "Tangential Power",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0250",
      "group" => "0046"
    },
    "593" => {
      "KeyWord" => "RefractivePower",
      "Name" => "Refractive Power",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0251",
      "group" => "0046"
    },
    "594" => {
      "KeyWord" => "RelativeElevation",
      "Name" => "Relative Elevation",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0252",
      "group" => "0046"
    },
    "595" => {
      "KeyWord" => "CornealWavefront",
      "Name" => "Corneal Wavefront",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0253",
      "group" => "0046"
    },
    "64" => {
      "KeyWord" => "OpticalTransmittance",
      "Name" => "Optical Transmittance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0040",
      "group" => "0046"
    },
    "66" => {
      "KeyWord" => "ChannelWidth",
      "Name" => "Channel Width",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0042",
      "group" => "0046"
    },
    "68" => {
      "KeyWord" => "PupilSize",
      "Name" => "Pupil Size",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0044",
      "group" => "0046"
    },
    "70" => {
      "KeyWord" => "CornealSize",
      "Name" => "Corneal Size",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0046",
      "group" => "0046"
    },
    "80" => {
      "KeyWord" => "AutorefractionRightEyeSequence",
      "Name" => "Autorefraction Right Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "0046"
    },
    "82" => {
      "KeyWord" => "AutorefractionLeftEyeSequence",
      "Name" => "Autorefraction Left Eye Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0052",
      "group" => "0046"
    },
    "96" => {
      "KeyWord" => "DistancePupillaryDistance",
      "Name" => "Distance Pupillary Distance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0060",
      "group" => "0046"
    },
    "98" => {
      "KeyWord" => "NearPupillaryDistance",
      "Name" => "Near Pupillary Distance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0062",
      "group" => "0046"
    },
    "99" => {
      "KeyWord" => "IntermediatePupillaryDistance",
      "Name" => "Intermediate Pupillary Distance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0063",
      "group" => "0046"
    }
  },
  "72" => {
    "1" => {
      "KeyWord" => "ImagedVolumeWidth",
      "Name" => "Imaged Volume Width",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0001",
      "group" => "0048"
    },
    "16" => {
      "KeyWord" => "SpecimenLabelInImage",
      "Name" => "Specimen Label in Image",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0010",
      "group" => "0048"
    },
    "17" => {
      "KeyWord" => "FocusMethod",
      "Name" => "Focus Method",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0011",
      "group" => "0048"
    },
    "18" => {
      "KeyWord" => "ExtendedDepthOfField",
      "Name" => "Extended Depth of Field",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0012",
      "group" => "0048"
    },
    "19" => {
      "KeyWord" => "NumberOfFocalPlanes",
      "Name" => "Number of Focal Planes",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0013",
      "group" => "0048"
    },
    "2" => {
      "KeyWord" => "ImagedVolumeHeight",
      "Name" => "Imaged Volume Height",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0002",
      "group" => "0048"
    },
    "20" => {
      "KeyWord" => "DistanceBetweenFocalPlanes",
      "Name" => "Distance Between Focal Planes",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0014",
      "group" => "0048"
    },
    "21" => {
      "KeyWord" => "RecommendedAbsentPixelCIELabValue",
      "Name" => "Recommended Absent Pixel CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "0015",
      "group" => "0048"
    },
    "256" => {
      "KeyWord" => "IlluminatorTypeCodeSequence",
      "Name" => "Illuminator Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0100",
      "group" => "0048"
    },
    "258" => {
      "KeyWord" => "ImageOrientationSlide",
      "Name" => "Image Orientation (Slide)",
      "VM" => "6",
      "VR" => "DS",
      "ele" => "0102",
      "group" => "0048"
    },
    "261" => {
      "KeyWord" => "OpticalPathSequence",
      "Name" => "Optical Path Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0105",
      "group" => "0048"
    },
    "262" => {
      "KeyWord" => "OpticalPathIdentifier",
      "Name" => "Optical Path Identifier",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0106",
      "group" => "0048"
    },
    "263" => {
      "KeyWord" => "OpticalPathDescription",
      "Name" => "Optical Path Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0107",
      "group" => "0048"
    },
    "264" => {
      "KeyWord" => "IlluminationColorCodeSequence",
      "Name" => "Illumination Color Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0108",
      "group" => "0048"
    },
    "272" => {
      "KeyWord" => "SpecimenReferenceSequence",
      "Name" => "Specimen Reference Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0110",
      "group" => "0048"
    },
    "273" => {
      "KeyWord" => "CondenserLensPower",
      "Name" => "Condenser Lens Power",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0111",
      "group" => "0048"
    },
    "274" => {
      "KeyWord" => "ObjectiveLensPower",
      "Name" => "Objective Lens Power",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0112",
      "group" => "0048"
    },
    "275" => {
      "KeyWord" => "ObjectiveLensNumericalAperture",
      "Name" => "Objective Lens Numerical Aperture",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0113",
      "group" => "0048"
    },
    "288" => {
      "KeyWord" => "PaletteColorLookupTableSequence",
      "Name" => "Palette Color Lookup Table Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0120",
      "group" => "0048"
    },
    "3" => {
      "KeyWord" => "ImagedVolumeDepth",
      "Name" => "Imaged Volume Depth",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0003",
      "group" => "0048"
    },
    "512" => {
      "KeyWord" => "ReferencedImageNavigationSequence",
      "Name" => "Referenced Image Navigation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0200",
      "group" => "0048"
    },
    "513" => {
      "KeyWord" => "TopLeftHandCornerOfLocalizerArea",
      "Name" => "Top Left Hand Corner of Localizer Area",
      "VM" => "2",
      "VR" => "US",
      "ele" => "0201",
      "group" => "0048"
    },
    "514" => {
      "KeyWord" => "BottomRightHandCornerOfLocalizerArea",
      "Name" => "Bottom Right Hand Corner of Localizer Area",
      "VM" => "2",
      "VR" => "US",
      "ele" => "0202",
      "group" => "0048"
    },
    "519" => {
      "KeyWord" => "OpticalPathIdentificationSequence",
      "Name" => "Optical Path Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0207",
      "group" => "0048"
    },
    "538" => {
      "KeyWord" => "PlanePositionSlideSequence",
      "Name" => "Plane Position (Slide) Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "021a",
      "group" => "0048"
    },
    "542" => {
      "KeyWord" => "ColumnPositionInTotalImagePixelMatrix",
      "Name" => "Column Position In Total Image Pixel Matrix",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "021e",
      "group" => "0048"
    },
    "543" => {
      "KeyWord" => "RowPositionInTotalImagePixelMatrix",
      "Name" => "Row Position In Total Image Pixel Matrix",
      "VM" => "1",
      "VR" => "SL",
      "ele" => "021f",
      "group" => "0048"
    },
    "6" => {
      "KeyWord" => "TotalPixelMatrixColumns",
      "Name" => "Total Pixel Matrix Columns",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0006",
      "group" => "0048"
    },
    "7" => {
      "KeyWord" => "TotalPixelMatrixRows",
      "Name" => "Total Pixel Matrix Rows",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0007",
      "group" => "0048"
    },
    "769" => {
      "KeyWord" => "PixelOriginInterpretation",
      "Name" => "Pixel Origin Interpretation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0301",
      "group" => "0048"
    },
    "8" => {
      "KeyWord" => "TotalPixelMatrixOriginSequence",
      "Name" => "Total Pixel Matrix Origin Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0008",
      "group" => "0048"
    }
  },
  "8" => {
    "1" => {
      "KeyWord" => "LengthToEnd",
      "Name" => "Length to End",
      "RET" => "1",
      "VM" => "1",
      "VR" => "UL",
      "ele" => "0001",
      "group" => "0008"
    },
    "100" => {
      "KeyWord" => "ConversionType",
      "Name" => "Conversion Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0064",
      "group" => "0008"
    },
    "104" => {
      "KeyWord" => "PresentationIntentType",
      "Name" => "Presentation Intent Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0068",
      "group" => "0008"
    },
    "112" => {
      "KeyWord" => "Manufacturer",
      "Name" => "Manufacturer",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0070",
      "group" => "0008"
    },
    "12289" => {
      "KeyWord" => "AlternateRepresentationSequence",
      "Name" => "Alternate Representation Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "3001",
      "group" => "0008"
    },
    "12304" => {
      "KeyWord" => "IrradiationEventUID",
      "Name" => "Irradiation Event UID",
      "VM" => "1-n",
      "VR" => "UI",
      "ele" => "3010",
      "group" => "0008"
    },
    "128" => {
      "KeyWord" => "InstitutionName",
      "Name" => "Institution Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0080",
      "group" => "0008"
    },
    "129" => {
      "KeyWord" => "InstitutionAddress",
      "Name" => "Institution Address",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0081",
      "group" => "0008"
    },
    "130" => {
      "KeyWord" => "InstitutionCodeSequence",
      "Name" => "Institution Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0082",
      "group" => "0008"
    },
    "144" => {
      "KeyWord" => "ReferringPhysicianName",
      "Name" => "Referring Physician's Name",
      "VM" => "1",
      "VR" => "PN",
      "ele" => "0090",
      "group" => "0008"
    },
    "146" => {
      "KeyWord" => "ReferringPhysicianAddress",
      "Name" => "Referring Physician's Address",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0092",
      "group" => "0008"
    },
    "148" => {
      "KeyWord" => "ReferringPhysicianTelephoneNumbers",
      "Name" => "Referring Physician's Telephone Numbers",
      "VM" => "1-n",
      "VR" => "SH",
      "ele" => "0094",
      "group" => "0008"
    },
    "150" => {
      "KeyWord" => "ReferringPhysicianIdentificationSequence",
      "Name" => "Referring Physician Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0096",
      "group" => "0008"
    },
    "16" => {
      "KeyWord" => "RecognitionCode",
      "Name" => "Recognition Code",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0010",
      "group" => "0008"
    },
    "16384" => {
      "KeyWord" => "IdentifyingComments",
      "Name" => "Identifying Comments",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "4000",
      "group" => "0008"
    },
    "18" => {
      "KeyWord" => "InstanceCreationDate",
      "Name" => "Instance Creation Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0012",
      "group" => "0008"
    },
    "19" => {
      "KeyWord" => "InstanceCreationTime",
      "Name" => "Instance Creation Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0013",
      "group" => "0008"
    },
    "20" => {
      "KeyWord" => "InstanceCreatorUID",
      "Name" => "Instance Creator UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0014",
      "group" => "0008"
    },
    "21" => {
      "KeyWord" => "InstanceCoercionDateTime",
      "Name" => "Instance Coercion DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "0015",
      "group" => "0008"
    },
    "22" => {
      "KeyWord" => "SOPClassUID",
      "Name" => "SOP Class UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0016",
      "group" => "0008"
    },
    "24" => {
      "KeyWord" => "SOPInstanceUID",
      "Name" => "SOP Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0018",
      "group" => "0008"
    },
    "256" => {
      "KeyWord" => "CodeValue",
      "Name" => "Code Value",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0100",
      "group" => "0008"
    },
    "257" => {
      "KeyWord" => "ExtendedCodeValue",
      "Name" => "Extended Code Value",
      "VM" => "1",
      "VR" => "LO",
      "comment" => "DICOS",
      "ele" => "0101",
      "group" => "0008"
    },
    "258" => {
      "KeyWord" => "CodingSchemeDesignator",
      "Name" => "Coding Scheme Designator",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0102",
      "group" => "0008"
    },
    "259" => {
      "KeyWord" => "CodingSchemeVersion",
      "Name" => "Coding Scheme Version",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0103",
      "group" => "0008"
    },
    "26" => {
      "KeyWord" => "RelatedGeneralSOPClassUID",
      "Name" => "Related General SOP Class UID",
      "VM" => "1-n",
      "VR" => "UI",
      "ele" => "001a",
      "group" => "0008"
    },
    "260" => {
      "KeyWord" => "CodeMeaning",
      "Name" => "Code Meaning",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0104",
      "group" => "0008"
    },
    "261" => {
      "KeyWord" => "MappingResource",
      "Name" => "Mapping Resource",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0105",
      "group" => "0008"
    },
    "262" => {
      "KeyWord" => "ContextGroupVersion",
      "Name" => "Context Group Version",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "0106",
      "group" => "0008"
    },
    "263" => {
      "KeyWord" => "ContextGroupLocalVersion",
      "Name" => "Context Group Local Version",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "0107",
      "group" => "0008"
    },
    "264" => {
      "KeyWord" => "ExtendedCodeMeaning",
      "Name" => "Extended Code Meaning",
      "VM" => "1",
      "VR" => "LT",
      "comment" => "DICOS",
      "ele" => "0108",
      "group" => "0008"
    },
    "267" => {
      "KeyWord" => "ContextGroupExtensionFlag",
      "Name" => "Context Group Extension Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "010b",
      "group" => "0008"
    },
    "268" => {
      "KeyWord" => "CodingSchemeUID",
      "Name" => "Coding Scheme UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "010c",
      "group" => "0008"
    },
    "269" => {
      "KeyWord" => "ContextGroupExtensionCreatorUID",
      "Name" => "Context Group Extension Creator UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "010d",
      "group" => "0008"
    },
    "27" => {
      "KeyWord" => "OriginalSpecializedSOPClassUID",
      "Name" => "Original Specialized SOP Class UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "001b",
      "group" => "0008"
    },
    "271" => {
      "KeyWord" => "ContextIdentifier",
      "Name" => "Context Identifier",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "010f",
      "group" => "0008"
    },
    "272" => {
      "KeyWord" => "CodingSchemeIdentificationSequence",
      "Name" => "Coding Scheme Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0110",
      "group" => "0008"
    },
    "274" => {
      "KeyWord" => "CodingSchemeRegistry",
      "Name" => "Coding Scheme Registry",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0112",
      "group" => "0008"
    },
    "276" => {
      "KeyWord" => "CodingSchemeExternalID",
      "Name" => "Coding Scheme External ID",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0114",
      "group" => "0008"
    },
    "277" => {
      "KeyWord" => "CodingSchemeName",
      "Name" => "Coding Scheme Name",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0115",
      "group" => "0008"
    },
    "278" => {
      "KeyWord" => "CodingSchemeResponsibleOrganization",
      "Name" => "Coding Scheme Responsible Organization",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0116",
      "group" => "0008"
    },
    "279" => {
      "KeyWord" => "ContextUID",
      "Name" => "Context UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "0117",
      "group" => "0008"
    },
    "32" => {
      "KeyWord" => "StudyDate",
      "Name" => "Study Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0020",
      "group" => "0008"
    },
    "33" => {
      "KeyWord" => "SeriesDate",
      "Name" => "Series Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0021",
      "group" => "0008"
    },
    "34" => {
      "KeyWord" => "AcquisitionDate",
      "Name" => "Acquisition Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0022",
      "group" => "0008"
    },
    "35" => {
      "KeyWord" => "ContentDate",
      "Name" => "Content Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0023",
      "group" => "0008"
    },
    "36" => {
      "KeyWord" => "OverlayDate",
      "Name" => "Overlay Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0024",
      "group" => "0008"
    },
    "36871" => {
      "KeyWord" => "FrameType",
      "Name" => "Frame Type",
      "VM" => "4",
      "VR" => "CS",
      "ele" => "9007",
      "group" => "0008"
    },
    "37" => {
      "KeyWord" => "CurveDate",
      "Name" => "Curve Date",
      "RET" => "1",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0025",
      "group" => "0008"
    },
    "37010" => {
      "KeyWord" => "ReferencedImageEvidenceSequence",
      "Name" => "Referenced Image Evidence Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9092",
      "group" => "0008"
    },
    "37153" => {
      "KeyWord" => "ReferencedRawDataSequence",
      "Name" => "Referenced Raw Data Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9121",
      "group" => "0008"
    },
    "37155" => {
      "KeyWord" => "CreatorVersionUID",
      "Name" => "Creator-Version UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "9123",
      "group" => "0008"
    },
    "37156" => {
      "KeyWord" => "DerivationImageSequence",
      "Name" => "Derivation Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9124",
      "group" => "0008"
    },
    "37204" => {
      "KeyWord" => "SourceImageEvidenceSequence",
      "Name" => "Source Image Evidence Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9154",
      "group" => "0008"
    },
    "37381" => {
      "KeyWord" => "PixelPresentation",
      "Name" => "Pixel Presentation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9205",
      "group" => "0008"
    },
    "37382" => {
      "KeyWord" => "VolumetricProperties",
      "Name" => "Volumetric Properties",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9206",
      "group" => "0008"
    },
    "37383" => {
      "KeyWord" => "VolumeBasedCalculationTechnique",
      "Name" => "Volume Based Calculation Technique",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9207",
      "group" => "0008"
    },
    "37384" => {
      "KeyWord" => "ComplexImageComponent",
      "Name" => "Complex Image Component",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9208",
      "group" => "0008"
    },
    "37385" => {
      "KeyWord" => "AcquisitionContrast",
      "Name" => "Acquisition Contrast",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9209",
      "group" => "0008"
    },
    "37397" => {
      "KeyWord" => "DerivationCodeSequence",
      "Name" => "Derivation Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9215",
      "group" => "0008"
    },
    "37431" => {
      "KeyWord" => "ReferencedPresentationStateSequence",
      "Name" => "Referenced Presentation State Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9237",
      "group" => "0008"
    },
    "37904" => {
      "KeyWord" => "ReferencedOtherPlaneSequence",
      "Name" => "Referenced Other Plane Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9410",
      "group" => "0008"
    },
    "37976" => {
      "KeyWord" => "FrameDisplaySequence",
      "Name" => "Frame Display Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "9458",
      "group" => "0008"
    },
    "37977" => {
      "KeyWord" => "RecommendedDisplayFrameRateInFloat",
      "Name" => "Recommended Display Frame Rate in Float",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "9459",
      "group" => "0008"
    },
    "37984" => {
      "KeyWord" => "SkipFrameRangeFlag",
      "Name" => "Skip Frame Range Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "9460",
      "group" => "0008"
    },
    "4096" => {
      "KeyWord" => "NetworkID",
      "Name" => "Network ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "1000",
      "group" => "0008"
    },
    "4112" => {
      "KeyWord" => "StationName",
      "Name" => "Station Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "1010",
      "group" => "0008"
    },
    "4144" => {
      "KeyWord" => "StudyDescription",
      "Name" => "Study Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1030",
      "group" => "0008"
    },
    "4146" => {
      "KeyWord" => "ProcedureCodeSequence",
      "Name" => "Procedure Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1032",
      "group" => "0008"
    },
    "4158" => {
      "KeyWord" => "SeriesDescription",
      "Name" => "Series Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "103e",
      "group" => "0008"
    },
    "4159" => {
      "KeyWord" => "SeriesDescriptionCodeSequence",
      "Name" => "Series Description Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "103f",
      "group" => "0008"
    },
    "4160" => {
      "KeyWord" => "InstitutionalDepartmentName",
      "Name" => "Institutional Department Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1040",
      "group" => "0008"
    },
    "4168" => {
      "KeyWord" => "PhysiciansOfRecord",
      "Name" => "Physician(s) of Record",
      "VM" => "1-n",
      "VR" => "PN",
      "ele" => "1048",
      "group" => "0008"
    },
    "4169" => {
      "KeyWord" => "PhysiciansOfRecordIdentificationSequence",
      "Name" => "Physician(s) of Record Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1049",
      "group" => "0008"
    },
    "4176" => {
      "KeyWord" => "PerformingPhysicianName",
      "Name" => "Performing Physician's Name",
      "VM" => "1-n",
      "VR" => "PN",
      "ele" => "1050",
      "group" => "0008"
    },
    "4178" => {
      "KeyWord" => "PerformingPhysicianIdentificationSequence",
      "Name" => "Performing Physician Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1052",
      "group" => "0008"
    },
    "4192" => {
      "KeyWord" => "NameOfPhysiciansReadingStudy",
      "Name" => "Name of Physician(s) Reading Study",
      "VM" => "1-n",
      "VR" => "PN",
      "ele" => "1060",
      "group" => "0008"
    },
    "4194" => {
      "KeyWord" => "PhysiciansReadingStudyIdentificationSequence",
      "Name" => "Physician(s) Reading Study Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1062",
      "group" => "0008"
    },
    "42" => {
      "KeyWord" => "AcquisitionDateTime",
      "Name" => "Acquisition DateTime",
      "VM" => "1",
      "VR" => "DT",
      "ele" => "002a",
      "group" => "0008"
    },
    "4208" => {
      "KeyWord" => "OperatorsName",
      "Name" => "Operators' Name",
      "VM" => "1-n",
      "VR" => "PN",
      "ele" => "1070",
      "group" => "0008"
    },
    "4210" => {
      "KeyWord" => "OperatorIdentificationSequence",
      "Name" => "Operator Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1072",
      "group" => "0008"
    },
    "4224" => {
      "KeyWord" => "AdmittingDiagnosesDescription",
      "Name" => "Admitting Diagnoses Description",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "1080",
      "group" => "0008"
    },
    "4228" => {
      "KeyWord" => "AdmittingDiagnosesCodeSequence",
      "Name" => "Admitting Diagnoses Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1084",
      "group" => "0008"
    },
    "4240" => {
      "KeyWord" => "ManufacturerModelName",
      "Name" => "Manufacturer's Model Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1090",
      "group" => "0008"
    },
    "4352" => {
      "KeyWord" => "ReferencedResultsSequence",
      "Name" => "Referenced Results Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1100",
      "group" => "0008"
    },
    "4368" => {
      "KeyWord" => "ReferencedStudySequence",
      "Name" => "Referenced Study Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1110",
      "group" => "0008"
    },
    "4369" => {
      "KeyWord" => "ReferencedPerformedProcedureStepSequence",
      "Name" => "Referenced Performed Procedure Step Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1111",
      "group" => "0008"
    },
    "4373" => {
      "KeyWord" => "ReferencedSeriesSequence",
      "Name" => "Referenced Series Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1115",
      "group" => "0008"
    },
    "4384" => {
      "KeyWord" => "ReferencedPatientSequence",
      "Name" => "Referenced Patient Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1120",
      "group" => "0008"
    },
    "4389" => {
      "KeyWord" => "ReferencedVisitSequence",
      "Name" => "Referenced Visit Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1125",
      "group" => "0008"
    },
    "4400" => {
      "KeyWord" => "ReferencedOverlaySequence",
      "Name" => "Referenced Overlay Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1130",
      "group" => "0008"
    },
    "4404" => {
      "KeyWord" => "ReferencedStereometricInstanceSequence",
      "Name" => "Referenced Stereometric Instance Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1134",
      "group" => "0008"
    },
    "4410" => {
      "KeyWord" => "ReferencedWaveformSequence",
      "Name" => "Referenced Waveform Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "113a",
      "group" => "0008"
    },
    "4416" => {
      "KeyWord" => "ReferencedImageSequence",
      "Name" => "Referenced Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1140",
      "group" => "0008"
    },
    "4421" => {
      "KeyWord" => "ReferencedCurveSequence",
      "Name" => "Referenced Curve Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1145",
      "group" => "0008"
    },
    "4426" => {
      "KeyWord" => "ReferencedInstanceSequence",
      "Name" => "Referenced Instance Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "114a",
      "group" => "0008"
    },
    "4427" => {
      "KeyWord" => "ReferencedRealWorldValueMappingInstanceSequence",
      "Name" => "Referenced Real World Value Mapping Instance Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "114b",
      "group" => "0008"
    },
    "4432" => {
      "KeyWord" => "ReferencedSOPClassUID",
      "Name" => "Referenced SOP Class UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1150",
      "group" => "0008"
    },
    "4437" => {
      "KeyWord" => "ReferencedSOPInstanceUID",
      "Name" => "Referenced SOP Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1155",
      "group" => "0008"
    },
    "4442" => {
      "KeyWord" => "SOPClassesSupported",
      "Name" => "SOP Classes Supported",
      "VM" => "1-n",
      "VR" => "UI",
      "ele" => "115a",
      "group" => "0008"
    },
    "4448" => {
      "KeyWord" => "ReferencedFrameNumber",
      "Name" => "Referenced Frame Number",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "1160",
      "group" => "0008"
    },
    "4449" => {
      "KeyWord" => "SimpleFrameList",
      "Name" => "Simple Frame List",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "1161",
      "group" => "0008"
    },
    "4450" => {
      "KeyWord" => "CalculatedFrameList",
      "Name" => "Calculated Frame List",
      "VM" => "3-3n",
      "VR" => "UL",
      "ele" => "1162",
      "group" => "0008"
    },
    "4451" => {
      "KeyWord" => "TimeRange",
      "Name" => "TimeRange",
      "VM" => "2",
      "VR" => "FD",
      "ele" => "1163",
      "group" => "0008"
    },
    "4452" => {
      "KeyWord" => "FrameExtractionSequence",
      "Name" => "Frame Extraction Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1164",
      "group" => "0008"
    },
    "4455" => {
      "KeyWord" => "MultiFrameSourceSOPInstanceUID",
      "Name" => "Multi-frame Source SOP Instance UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1167",
      "group" => "0008"
    },
    "4496" => {
      "KeyWord" => "RetrieveURL",
      "Name" => "Retrieve URL",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "1190",
      "group" => "0008"
    },
    "4501" => {
      "KeyWord" => "TransactionUID",
      "Name" => "Transaction UID",
      "VM" => "1",
      "VR" => "UI",
      "ele" => "1195",
      "group" => "0008"
    },
    "4502" => {
      "KeyWord" => "WarningReason",
      "Name" => "Warning Reason",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1196",
      "group" => "0008"
    },
    "4503" => {
      "KeyWord" => "FailureReason",
      "Name" => "Failure Reason",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1197",
      "group" => "0008"
    },
    "4504" => {
      "KeyWord" => "FailedSOPSequence",
      "Name" => "Failed SOP Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1198",
      "group" => "0008"
    },
    "4505" => {
      "KeyWord" => "ReferencedSOPSequence",
      "Name" => "Referenced SOP Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1199",
      "group" => "0008"
    },
    "4608" => {
      "KeyWord" => "StudiesContainingOtherReferencedInstancesSequence",
      "Name" => "Studies Containing Other Referenced Instances Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1200",
      "group" => "0008"
    },
    "4688" => {
      "KeyWord" => "RelatedSeriesSequence",
      "Name" => "Related Series Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "1250",
      "group" => "0008"
    },
    "48" => {
      "KeyWord" => "StudyTime",
      "Name" => "Study Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0030",
      "group" => "0008"
    },
    "49" => {
      "KeyWord" => "SeriesTime",
      "Name" => "Series Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0031",
      "group" => "0008"
    },
    "5" => {
      "KeyWord" => "SpecificCharacterSet",
      "Name" => "Specific Character Set",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0005",
      "group" => "0008"
    },
    "50" => {
      "KeyWord" => "AcquisitionTime",
      "Name" => "Acquisition Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0032",
      "group" => "0008"
    },
    "51" => {
      "KeyWord" => "ContentTime",
      "Name" => "Content Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0033",
      "group" => "0008"
    },
    "513" => {
      "KeyWord" => "TimezoneOffsetFromUTC",
      "Name" => "Timezone Offset From UTC",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0201",
      "group" => "0008"
    },
    "52" => {
      "KeyWord" => "OverlayTime",
      "Name" => "Overlay Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0034",
      "group" => "0008"
    },
    "53" => {
      "KeyWord" => "CurveTime",
      "Name" => "Curve Time",
      "RET" => "1",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0035",
      "group" => "0008"
    },
    "6" => {
      "KeyWord" => "LanguageCodeSequence",
      "Name" => "Language Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0006",
      "group" => "0008"
    },
    "64" => {
      "KeyWord" => "DataSetType",
      "Name" => "Data Set Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0040",
      "group" => "0008"
    },
    "65" => {
      "KeyWord" => "DataSetSubtype",
      "Name" => "Data Set Subtype",
      "RET" => "1",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0041",
      "group" => "0008"
    },
    "66" => {
      "KeyWord" => "NuclearMedicineSeriesType",
      "Name" => "Nuclear Medicine Series Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0042",
      "group" => "0008"
    },
    "8" => {
      "KeyWord" => "ImageType",
      "Name" => "Image Type",
      "VM" => "2-n",
      "VR" => "CS",
      "ele" => "0008",
      "group" => "0008"
    },
    "80" => {
      "KeyWord" => "AccessionNumber",
      "Name" => "Accession Number",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0050",
      "group" => "0008"
    },
    "81" => {
      "KeyWord" => "IssuerOfAccessionNumberSequence",
      "Name" => "Issuer of Accession Number Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0051",
      "group" => "0008"
    },
    "82" => {
      "KeyWord" => "QueryRetrieveLevel",
      "Name" => "Query/Retrieve Level",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0052",
      "group" => "0008"
    },
    "83" => {
      "KeyWord" => "QueryRetrieveView",
      "Name" => "Query/Retrieve View",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0053",
      "group" => "0008"
    },
    "84" => {
      "KeyWord" => "RetrieveAETitle",
      "Name" => "Retrieve AE Title",
      "VM" => "1-n",
      "VR" => "AE",
      "ele" => "0054",
      "group" => "0008"
    },
    "8464" => {
      "KeyWord" => "LossyImageCompressionRetired",
      "Name" => "Lossy Image Compression (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2110",
      "group" => "0008"
    },
    "8465" => {
      "KeyWord" => "DerivationDescription",
      "Name" => "Derivation Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "2111",
      "group" => "0008"
    },
    "8466" => {
      "KeyWord" => "SourceImageSequence",
      "Name" => "Source Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2112",
      "group" => "0008"
    },
    "8480" => {
      "KeyWord" => "StageName",
      "Name" => "Stage Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2120",
      "group" => "0008"
    },
    "8482" => {
      "KeyWord" => "StageNumber",
      "Name" => "Stage Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "2122",
      "group" => "0008"
    },
    "8484" => {
      "KeyWord" => "NumberOfStages",
      "Name" => "Number of Stages",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "2124",
      "group" => "0008"
    },
    "8487" => {
      "KeyWord" => "ViewName",
      "Name" => "View Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "2127",
      "group" => "0008"
    },
    "8488" => {
      "KeyWord" => "ViewNumber",
      "Name" => "View Number",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "2128",
      "group" => "0008"
    },
    "8489" => {
      "KeyWord" => "NumberOfEventTimers",
      "Name" => "Number of Event Timers",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "2129",
      "group" => "0008"
    },
    "8490" => {
      "KeyWord" => "NumberOfViewsInStage",
      "Name" => "Number of Views in Stage",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "212a",
      "group" => "0008"
    },
    "8496" => {
      "KeyWord" => "EventElapsedTimes",
      "Name" => "Event Elapsed Time(s)",
      "VM" => "1-n",
      "VR" => "DS",
      "ele" => "2130",
      "group" => "0008"
    },
    "8498" => {
      "KeyWord" => "EventTimerNames",
      "Name" => "Event Timer Name(s)",
      "VM" => "1-n",
      "VR" => "LO",
      "ele" => "2132",
      "group" => "0008"
    },
    "8499" => {
      "KeyWord" => "EventTimerSequence",
      "Name" => "Event Timer Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2133",
      "group" => "0008"
    },
    "8500" => {
      "KeyWord" => "EventTimeOffset",
      "Name" => "Event Time Offset",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "2134",
      "group" => "0008"
    },
    "8501" => {
      "KeyWord" => "EventCodeSequence",
      "Name" => "Event Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2135",
      "group" => "0008"
    },
    "8514" => {
      "KeyWord" => "StartTrim",
      "Name" => "Start Trim",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "2142",
      "group" => "0008"
    },
    "8515" => {
      "KeyWord" => "StopTrim",
      "Name" => "Stop Trim",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "2143",
      "group" => "0008"
    },
    "8516" => {
      "KeyWord" => "RecommendedDisplayFrameRate",
      "Name" => "Recommended Display Frame Rate",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "2144",
      "group" => "0008"
    },
    "86" => {
      "KeyWord" => "InstanceAvailability",
      "Name" => "Instance Availability",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0056",
      "group" => "0008"
    },
    "8704" => {
      "KeyWord" => "TransducerPosition",
      "Name" => "Transducer Position",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2200",
      "group" => "0008"
    },
    "8708" => {
      "KeyWord" => "TransducerOrientation",
      "Name" => "Transducer Orientation",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2204",
      "group" => "0008"
    },
    "8712" => {
      "KeyWord" => "AnatomicStructure",
      "Name" => "Anatomic Structure",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "2208",
      "group" => "0008"
    },
    "8728" => {
      "KeyWord" => "AnatomicRegionSequence",
      "Name" => "Anatomic Region Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2218",
      "group" => "0008"
    },
    "8736" => {
      "KeyWord" => "AnatomicRegionModifierSequence",
      "Name" => "Anatomic Region Modifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2220",
      "group" => "0008"
    },
    "8744" => {
      "KeyWord" => "PrimaryAnatomicStructureSequence",
      "Name" => "Primary Anatomic Structure Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2228",
      "group" => "0008"
    },
    "8745" => {
      "KeyWord" => "AnatomicStructureSpaceOrRegionSequence",
      "Name" => "Anatomic Structure, Space or Region Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2229",
      "group" => "0008"
    },
    "8752" => {
      "KeyWord" => "PrimaryAnatomicStructureModifierSequence",
      "Name" => "Primary Anatomic Structure Modifier Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2230",
      "group" => "0008"
    },
    "8768" => {
      "KeyWord" => "TransducerPositionSequence",
      "Name" => "Transducer Position Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2240",
      "group" => "0008"
    },
    "8770" => {
      "KeyWord" => "TransducerPositionModifierSequence",
      "Name" => "Transducer Position Modifier Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2242",
      "group" => "0008"
    },
    "8772" => {
      "KeyWord" => "TransducerOrientationSequence",
      "Name" => "Transducer Orientation Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2244",
      "group" => "0008"
    },
    "8774" => {
      "KeyWord" => "TransducerOrientationModifierSequence",
      "Name" => "Transducer Orientation Modifier Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2246",
      "group" => "0008"
    },
    "8785" => {
      "KeyWord" => "AnatomicStructureSpaceOrRegionCodeSequenceTrial",
      "Name" => "Anatomic Structure Space Or Region Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2251",
      "group" => "0008"
    },
    "8787" => {
      "KeyWord" => "AnatomicPortalOfEntranceCodeSequenceTrial",
      "Name" => "Anatomic Portal Of Entrance Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2253",
      "group" => "0008"
    },
    "8789" => {
      "KeyWord" => "AnatomicApproachDirectionCodeSequenceTrial",
      "Name" => "Anatomic Approach Direction Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2255",
      "group" => "0008"
    },
    "8790" => {
      "KeyWord" => "AnatomicPerspectiveDescriptionTrial",
      "Name" => "Anatomic Perspective Description (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "2256",
      "group" => "0008"
    },
    "8791" => {
      "KeyWord" => "AnatomicPerspectiveCodeSequenceTrial",
      "Name" => "Anatomic Perspective Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2257",
      "group" => "0008"
    },
    "8792" => {
      "KeyWord" => "AnatomicLocationOfExaminingInstrumentDescriptionTrial",
      "Name" => "Anatomic Location Of Examining Instrument Description (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "2258",
      "group" => "0008"
    },
    "8793" => {
      "KeyWord" => "AnatomicLocationOfExaminingInstrumentCodeSequenceTrial",
      "Name" => "Anatomic Location Of Examining Instrument Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "2259",
      "group" => "0008"
    },
    "8794" => {
      "KeyWord" => "AnatomicStructureSpaceOrRegionModifierCodeSequenceTrial",
      "Name" => "Anatomic Structure Space Or Region Modifier Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "225a",
      "group" => "0008"
    },
    "8796" => {
      "KeyWord" => "OnAxisBackgroundAnatomicStructureCodeSequenceTrial",
      "Name" => "OnAxis Background Anatomic Structure Code Sequence (Trial)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "225c",
      "group" => "0008"
    },
    "88" => {
      "KeyWord" => "FailedSOPInstanceUIDList",
      "Name" => "Failed SOP Instance UID List",
      "VM" => "1-n",
      "VR" => "UI",
      "ele" => "0058",
      "group" => "0008"
    },
    "96" => {
      "KeyWord" => "Modality",
      "Name" => "Modality",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0060",
      "group" => "0008"
    },
    "97" => {
      "KeyWord" => "ModalitiesInStudy",
      "Name" => "Modalities in Study",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "0061",
      "group" => "0008"
    },
    "98" => {
      "KeyWord" => "SOPClassesInStudy",
      "Name" => "SOP Classes in Study",
      "VM" => "1-n",
      "VR" => "UI",
      "ele" => "0062",
      "group" => "0008"
    }
  },
  "80" => {
    "16" => {
      "KeyWord" => "DeviceSequence",
      "Name" => "Device Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "0050"
    },
    "18" => {
      "KeyWord" => "ContainerComponentTypeCodeSequence",
      "Name" => "Container Component Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0012",
      "group" => "0050"
    },
    "19" => {
      "KeyWord" => "ContainerComponentThickness",
      "Name" => "Container Component Thickness",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0013",
      "group" => "0050"
    },
    "20" => {
      "KeyWord" => "DeviceLength",
      "Name" => "Device Length",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0014",
      "group" => "0050"
    },
    "21" => {
      "KeyWord" => "ContainerComponentWidth",
      "Name" => "Container Component Width",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0015",
      "group" => "0050"
    },
    "22" => {
      "KeyWord" => "DeviceDiameter",
      "Name" => "Device Diameter",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0016",
      "group" => "0050"
    },
    "23" => {
      "KeyWord" => "DeviceDiameterUnits",
      "Name" => "Device Diameter Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0017",
      "group" => "0050"
    },
    "24" => {
      "KeyWord" => "DeviceVolume",
      "Name" => "Device Volume",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0018",
      "group" => "0050"
    },
    "25" => {
      "KeyWord" => "InterMarkerDistance",
      "Name" => "Inter-Marker Distance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0019",
      "group" => "0050"
    },
    "26" => {
      "KeyWord" => "ContainerComponentMaterial",
      "Name" => "Container Component Material",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "001a",
      "group" => "0050"
    },
    "27" => {
      "KeyWord" => "ContainerComponentID",
      "Name" => "Container Component ID",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "001b",
      "group" => "0050"
    },
    "28" => {
      "KeyWord" => "ContainerComponentLength",
      "Name" => "Container Component Length",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "001c",
      "group" => "0050"
    },
    "29" => {
      "KeyWord" => "ContainerComponentDiameter",
      "Name" => "Container Component Diameter",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "001d",
      "group" => "0050"
    },
    "30" => {
      "KeyWord" => "ContainerComponentDescription",
      "Name" => "Container Component Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "001e",
      "group" => "0050"
    },
    "32" => {
      "KeyWord" => "DeviceDescription",
      "Name" => "Device Description",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0020",
      "group" => "0050"
    },
    "4" => {
      "KeyWord" => "CalibrationImage",
      "Name" => "Calibration Image",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0004",
      "group" => "0050"
    }
  },
  "8192" => {
    "101" => {
      "KeyWord" => "AnnotationFlag",
      "Name" => "Annotation Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0065",
      "group" => "2000"
    },
    "103" => {
      "KeyWord" => "ImageOverlayFlag",
      "Name" => "Image Overlay Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0067",
      "group" => "2000"
    },
    "105" => {
      "KeyWord" => "PresentationLUTFlag",
      "Name" => "Presentation LUT Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0069",
      "group" => "2000"
    },
    "106" => {
      "KeyWord" => "ImageBoxPresentationLUTFlag",
      "Name" => "Image Box Presentation LUT Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "006a",
      "group" => "2000"
    },
    "1280" => {
      "KeyWord" => "ReferencedFilmBoxSequence",
      "Name" => "Referenced Film Box Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0500",
      "group" => "2000"
    },
    "1296" => {
      "KeyWord" => "ReferencedStoredPrintSequence",
      "Name" => "Referenced Stored Print Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0510",
      "group" => "2000"
    },
    "16" => {
      "KeyWord" => "NumberOfCopies",
      "Name" => "Number of Copies",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0010",
      "group" => "2000"
    },
    "160" => {
      "KeyWord" => "MemoryBitDepth",
      "Name" => "Memory Bit Depth",
      "VM" => "1",
      "VR" => "US",
      "ele" => "00a0",
      "group" => "2000"
    },
    "161" => {
      "KeyWord" => "PrintingBitDepth",
      "Name" => "Printing Bit Depth",
      "VM" => "1",
      "VR" => "US",
      "ele" => "00a1",
      "group" => "2000"
    },
    "162" => {
      "KeyWord" => "MediaInstalledSequence",
      "Name" => "Media Installed Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00a2",
      "group" => "2000"
    },
    "164" => {
      "KeyWord" => "OtherMediaAvailableSequence",
      "Name" => "Other Media Available Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00a4",
      "group" => "2000"
    },
    "168" => {
      "KeyWord" => "SupportedImageDisplayFormatsSequence",
      "Name" => "Supported Image Display Formats Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00a8",
      "group" => "2000"
    },
    "30" => {
      "KeyWord" => "PrinterConfigurationSequence",
      "Name" => "Printer Configuration Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "001e",
      "group" => "2000"
    },
    "32" => {
      "KeyWord" => "PrintPriority",
      "Name" => "Print Priority",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "2000"
    },
    "48" => {
      "KeyWord" => "MediumType",
      "Name" => "Medium Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0030",
      "group" => "2000"
    },
    "64" => {
      "KeyWord" => "FilmDestination",
      "Name" => "Film Destination",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0040",
      "group" => "2000"
    },
    "80" => {
      "KeyWord" => "FilmSessionLabel",
      "Name" => "Film Session Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0050",
      "group" => "2000"
    },
    "96" => {
      "KeyWord" => "MemoryAllocation",
      "Name" => "Memory Allocation",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0060",
      "group" => "2000"
    },
    "97" => {
      "KeyWord" => "MaximumMemoryAllocation",
      "Name" => "Maximum Memory Allocation",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0061",
      "group" => "2000"
    },
    "98" => {
      "KeyWord" => "ColorImagePrintingFlag",
      "Name" => "Color Image Printing Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0062",
      "group" => "2000"
    },
    "99" => {
      "KeyWord" => "CollationFlag",
      "Name" => "Collation Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0063",
      "group" => "2000"
    }
  },
  "82" => {
    "1" => {
      "KeyWord" => "ContrastBolusIngredientPercentByVolume",
      "Name" => "Contrast/Bolus Ingredient Percent by Volume",
      "VM" => "1",
      "VR" => "FL",
      "ele" => "0001",
      "group" => "0052"
    },
    "17" => {
      "KeyWord" => "ALineRate",
      "Name" => "A-line Rate",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0011",
      "group" => "0052"
    },
    "18" => {
      "KeyWord" => "ALinesPerFrame",
      "Name" => "A-lines Per Frame",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0012",
      "group" => "0052"
    },
    "19" => {
      "KeyWord" => "CatheterRotationalRate",
      "Name" => "Catheter Rotational Rate",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0013",
      "group" => "0052"
    },
    "2" => {
      "KeyWord" => "OCTFocalDistance",
      "Name" => "OCT Focal Distance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0002",
      "group" => "0052"
    },
    "20" => {
      "KeyWord" => "ALinePixelSpacing",
      "Name" => "A-line Pixel Spacing",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0014",
      "group" => "0052"
    },
    "22" => {
      "KeyWord" => "ModeOfPercutaneousAccessSequence",
      "Name" => "Mode of Percutaneous Access Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0016",
      "group" => "0052"
    },
    "3" => {
      "KeyWord" => "BeamSpotSize",
      "Name" => "Beam Spot Size",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0003",
      "group" => "0052"
    },
    "37" => {
      "KeyWord" => "IntravascularOCTFrameTypeSequence",
      "Name" => "Intravascular OCT Frame Type Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0025",
      "group" => "0052"
    },
    "38" => {
      "KeyWord" => "OCTZOffsetApplied",
      "Name" => "OCT Z Offset Applied",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0026",
      "group" => "0052"
    },
    "39" => {
      "KeyWord" => "IntravascularFrameContentSequence",
      "Name" => "Intravascular Frame Content Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0027",
      "group" => "0052"
    },
    "4" => {
      "KeyWord" => "EffectiveRefractiveIndex",
      "Name" => "Effective Refractive Index",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0004",
      "group" => "0052"
    },
    "40" => {
      "KeyWord" => "IntravascularLongitudinalDistance",
      "Name" => "Intravascular Longitudinal Distance",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0028",
      "group" => "0052"
    },
    "41" => {
      "KeyWord" => "IntravascularOCTFrameContentSequence",
      "Name" => "Intravascular OCT Frame Content Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0029",
      "group" => "0052"
    },
    "48" => {
      "KeyWord" => "OCTZOffsetCorrection",
      "Name" => "OCT Z Offset Correction",
      "VM" => "1",
      "VR" => "SS",
      "ele" => "0030",
      "group" => "0052"
    },
    "49" => {
      "KeyWord" => "CatheterDirectionOfRotation",
      "Name" => "Catheter Direction of Rotation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0031",
      "group" => "0052"
    },
    "51" => {
      "KeyWord" => "SeamLineLocation",
      "Name" => "Seam Line Location",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0033",
      "group" => "0052"
    },
    "52" => {
      "KeyWord" => "FirstALineLocation",
      "Name" => "First A-line Location",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0034",
      "group" => "0052"
    },
    "54" => {
      "KeyWord" => "SeamLineIndex",
      "Name" => "Seam Line Index",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0036",
      "group" => "0052"
    },
    "56" => {
      "KeyWord" => "NumberOfPaddedALines",
      "Name" => "Number of Padded A-lines",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0038",
      "group" => "0052"
    },
    "57" => {
      "KeyWord" => "InterpolationType",
      "Name" => "Interpolation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0039",
      "group" => "0052"
    },
    "58" => {
      "KeyWord" => "RefractiveIndexApplied",
      "Name" => "Refractive Index Applied",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "003a",
      "group" => "0052"
    },
    "6" => {
      "KeyWord" => "OCTAcquisitionDomain",
      "Name" => "OCT Acquisition Domain",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0006",
      "group" => "0052"
    },
    "7" => {
      "KeyWord" => "OCTOpticalCenterWavelength",
      "Name" => "OCT Optical Center Wavelength",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0007",
      "group" => "0052"
    },
    "8" => {
      "KeyWord" => "AxialResolution",
      "Name" => "Axial Resolution",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0008",
      "group" => "0052"
    },
    "9" => {
      "KeyWord" => "RangingDepth",
      "Name" => "Ranging Depth",
      "VM" => "1",
      "VR" => "FD",
      "ele" => "0009",
      "group" => "0052"
    }
  },
  "8208" => {
    "128" => {
      "KeyWord" => "SmoothingType",
      "Name" => "Smoothing Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0080",
      "group" => "2010"
    },
    "1280" => {
      "KeyWord" => "ReferencedFilmSessionSequence",
      "Name" => "Referenced Film Session Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0500",
      "group" => "2010"
    },
    "1296" => {
      "KeyWord" => "ReferencedImageBoxSequence",
      "Name" => "Referenced Image Box Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0510",
      "group" => "2010"
    },
    "1312" => {
      "KeyWord" => "ReferencedBasicAnnotationBoxSequence",
      "Name" => "Referenced Basic Annotation Box Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0520",
      "group" => "2010"
    },
    "16" => {
      "KeyWord" => "ImageDisplayFormat",
      "Name" => "Image Display Format",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0010",
      "group" => "2010"
    },
    "166" => {
      "KeyWord" => "DefaultMagnificationType",
      "Name" => "Default Magnification Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00a6",
      "group" => "2010"
    },
    "167" => {
      "KeyWord" => "OtherMagnificationTypesAvailable",
      "Name" => "Other Magnification Types Available",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "00a7",
      "group" => "2010"
    },
    "168" => {
      "KeyWord" => "DefaultSmoothingType",
      "Name" => "Default Smoothing Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00a8",
      "group" => "2010"
    },
    "169" => {
      "KeyWord" => "OtherSmoothingTypesAvailable",
      "Name" => "Other Smoothing Types Available",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "00a9",
      "group" => "2010"
    },
    "256" => {
      "KeyWord" => "BorderDensity",
      "Name" => "Border Density",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0100",
      "group" => "2010"
    },
    "272" => {
      "KeyWord" => "EmptyImageDensity",
      "Name" => "Empty Image Density",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0110",
      "group" => "2010"
    },
    "288" => {
      "KeyWord" => "MinDensity",
      "Name" => "Min Density",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0120",
      "group" => "2010"
    },
    "304" => {
      "KeyWord" => "MaxDensity",
      "Name" => "Max Density",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0130",
      "group" => "2010"
    },
    "320" => {
      "KeyWord" => "Trim",
      "Name" => "Trim",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0140",
      "group" => "2010"
    },
    "336" => {
      "KeyWord" => "ConfigurationInformation",
      "Name" => "Configuration Information",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0150",
      "group" => "2010"
    },
    "338" => {
      "KeyWord" => "ConfigurationInformationDescription",
      "Name" => "Configuration Information Description",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0152",
      "group" => "2010"
    },
    "340" => {
      "KeyWord" => "MaximumCollatedFilms",
      "Name" => "Maximum Collated Films",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0154",
      "group" => "2010"
    },
    "350" => {
      "KeyWord" => "Illumination",
      "Name" => "Illumination",
      "VM" => "1",
      "VR" => "US",
      "ele" => "015e",
      "group" => "2010"
    },
    "352" => {
      "KeyWord" => "ReflectedAmbientLight",
      "Name" => "Reflected Ambient Light",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0160",
      "group" => "2010"
    },
    "48" => {
      "KeyWord" => "AnnotationDisplayFormatID",
      "Name" => "Annotation Display Format ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0030",
      "group" => "2010"
    },
    "64" => {
      "KeyWord" => "FilmOrientation",
      "Name" => "Film Orientation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0040",
      "group" => "2010"
    },
    "80" => {
      "KeyWord" => "FilmSizeID",
      "Name" => "Film Size ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0050",
      "group" => "2010"
    },
    "82" => {
      "KeyWord" => "PrinterResolutionID",
      "Name" => "Printer Resolution ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0052",
      "group" => "2010"
    },
    "84" => {
      "KeyWord" => "DefaultPrinterResolutionID",
      "Name" => "Default Printer Resolution ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0054",
      "group" => "2010"
    },
    "886" => {
      "KeyWord" => "PrinterPixelSpacing",
      "Name" => "Printer Pixel Spacing",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "0376",
      "group" => "2010"
    },
    "96" => {
      "KeyWord" => "MagnificationType",
      "Name" => "Magnification Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0060",
      "group" => "2010"
    }
  },
  "8224" => {
    "16" => {
      "KeyWord" => "ImageBoxPosition",
      "Name" => "Image Box Position",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0010",
      "group" => "2020"
    },
    "160" => {
      "KeyWord" => "RequestedImageSizeFlag",
      "Name" => "Requested Image Size Flag",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00a0",
      "group" => "2020"
    },
    "162" => {
      "KeyWord" => "DecimateCropResult",
      "Name" => "Decimate/Crop Result",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "00a2",
      "group" => "2020"
    },
    "272" => {
      "KeyWord" => "BasicGrayscaleImageSequence",
      "Name" => "Basic Grayscale Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0110",
      "group" => "2020"
    },
    "273" => {
      "KeyWord" => "BasicColorImageSequence",
      "Name" => "Basic Color Image Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0111",
      "group" => "2020"
    },
    "304" => {
      "KeyWord" => "ReferencedImageOverlayBoxSequence",
      "Name" => "Referenced Image Overlay Box Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0130",
      "group" => "2020"
    },
    "32" => {
      "KeyWord" => "Polarity",
      "Name" => "Polarity",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "2020"
    },
    "320" => {
      "KeyWord" => "ReferencedVOILUTBoxSequence",
      "Name" => "Referenced VOI LUT Box Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0140",
      "group" => "2020"
    },
    "48" => {
      "KeyWord" => "RequestedImageSize",
      "Name" => "Requested Image Size",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0030",
      "group" => "2020"
    },
    "64" => {
      "KeyWord" => "RequestedDecimateCropBehavior",
      "Name" => "Requested Decimate/Crop Behavior",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0040",
      "group" => "2020"
    },
    "80" => {
      "KeyWord" => "RequestedResolutionID",
      "Name" => "Requested Resolution ID",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0050",
      "group" => "2020"
    }
  },
  "8240" => {
    "16" => {
      "KeyWord" => "AnnotationPosition",
      "Name" => "Annotation Position",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0010",
      "group" => "2030"
    },
    "32" => {
      "KeyWord" => "TextString",
      "Name" => "Text String",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0020",
      "group" => "2030"
    }
  },
  "8256" => {
    "112" => {
      "KeyWord" => "OverlaySmoothingType",
      "Name" => "Overlay Smoothing Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0070",
      "group" => "2040"
    },
    "114" => {
      "KeyWord" => "OverlayOrImageMagnification",
      "Name" => "Overlay or Image Magnification",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0072",
      "group" => "2040"
    },
    "116" => {
      "KeyWord" => "MagnifyToNumberOfColumns",
      "Name" => "Magnify to Number of Columns",
      "RET" => "1",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0074",
      "group" => "2040"
    },
    "128" => {
      "KeyWord" => "OverlayForegroundDensity",
      "Name" => "Overlay Foreground Density",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0080",
      "group" => "2040"
    },
    "1280" => {
      "KeyWord" => "ReferencedImageBoxSequenceRetired",
      "Name" => "Referenced Image Box Sequence (Retired)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0500",
      "group" => "2040"
    },
    "130" => {
      "KeyWord" => "OverlayBackgroundDensity",
      "Name" => "Overlay Background Density",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0082",
      "group" => "2040"
    },
    "144" => {
      "KeyWord" => "OverlayMode",
      "Name" => "Overlay Mode",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0090",
      "group" => "2040"
    },
    "16" => {
      "KeyWord" => "ReferencedOverlayPlaneSequence",
      "Name" => "Referenced Overlay Plane Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "2040"
    },
    "17" => {
      "KeyWord" => "ReferencedOverlayPlaneGroups",
      "Name" => "Referenced Overlay Plane Groups",
      "RET" => "1",
      "VM" => "1-99",
      "VR" => "US",
      "ele" => "0011",
      "group" => "2040"
    },
    "256" => {
      "KeyWord" => "ThresholdDensity",
      "Name" => "Threshold Density",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0100",
      "group" => "2040"
    },
    "32" => {
      "KeyWord" => "OverlayPixelDataSequence",
      "Name" => "Overlay Pixel Data Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0020",
      "group" => "2040"
    },
    "96" => {
      "KeyWord" => "OverlayMagnificationType",
      "Name" => "Overlay Magnification Type",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0060",
      "group" => "2040"
    }
  },
  "8272" => {
    "1280" => {
      "KeyWord" => "ReferencedPresentationLUTSequence",
      "Name" => "Referenced Presentation LUT Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0500",
      "group" => "2050"
    },
    "16" => {
      "KeyWord" => "PresentationLUTSequence",
      "Name" => "Presentation LUT Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "2050"
    },
    "32" => {
      "KeyWord" => "PresentationLUTShape",
      "Name" => "Presentation LUT Shape",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "2050"
    }
  },
  "84" => {
    "1024" => {
      "KeyWord" => "ImageID",
      "Name" => "Image ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0400",
      "group" => "0054"
    },
    "1040" => {
      "KeyWord" => "PatientOrientationCodeSequence",
      "Name" => "Patient Orientation Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0410",
      "group" => "0054"
    },
    "1042" => {
      "KeyWord" => "PatientOrientationModifierCodeSequence",
      "Name" => "Patient Orientation Modifier Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0412",
      "group" => "0054"
    },
    "1044" => {
      "KeyWord" => "PatientGantryRelationshipCodeSequence",
      "Name" => "Patient Gantry Relationship Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0414",
      "group" => "0054"
    },
    "112" => {
      "KeyWord" => "TimeSlotVector",
      "Name" => "Time Slot Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0070",
      "group" => "0054"
    },
    "113" => {
      "KeyWord" => "NumberOfTimeSlots",
      "Name" => "Number of Time Slots",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0071",
      "group" => "0054"
    },
    "114" => {
      "KeyWord" => "TimeSlotInformationSequence",
      "Name" => "Time Slot Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0072",
      "group" => "0054"
    },
    "115" => {
      "KeyWord" => "TimeSlotTime",
      "Name" => "Time Slot Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0073",
      "group" => "0054"
    },
    "128" => {
      "KeyWord" => "SliceVector",
      "Name" => "Slice Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0080",
      "group" => "0054"
    },
    "1280" => {
      "KeyWord" => "SliceProgressionDirection",
      "Name" => "Slice Progression Direction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0500",
      "group" => "0054"
    },
    "129" => {
      "KeyWord" => "NumberOfSlices",
      "Name" => "Number of Slices",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0081",
      "group" => "0054"
    },
    "144" => {
      "KeyWord" => "AngularViewVector",
      "Name" => "Angular View Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0090",
      "group" => "0054"
    },
    "16" => {
      "KeyWord" => "EnergyWindowVector",
      "Name" => "Energy Window Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0010",
      "group" => "0054"
    },
    "17" => {
      "KeyWord" => "NumberOfEnergyWindows",
      "Name" => "Number of Energy Windows",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0011",
      "group" => "0054"
    },
    "18" => {
      "KeyWord" => "EnergyWindowInformationSequence",
      "Name" => "Energy Window Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0012",
      "group" => "0054"
    },
    "19" => {
      "KeyWord" => "EnergyWindowRangeSequence",
      "Name" => "Energy Window Range Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0013",
      "group" => "0054"
    },
    "20" => {
      "KeyWord" => "EnergyWindowLowerLimit",
      "Name" => "Energy Window Lower Limit",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0014",
      "group" => "0054"
    },
    "21" => {
      "KeyWord" => "EnergyWindowUpperLimit",
      "Name" => "Energy Window Upper Limit",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0015",
      "group" => "0054"
    },
    "22" => {
      "KeyWord" => "RadiopharmaceuticalInformationSequence",
      "Name" => "Radiopharmaceutical Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0016",
      "group" => "0054"
    },
    "23" => {
      "KeyWord" => "ResidualSyringeCounts",
      "Name" => "Residual Syringe Counts",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0017",
      "group" => "0054"
    },
    "24" => {
      "KeyWord" => "EnergyWindowName",
      "Name" => "Energy Window Name",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0018",
      "group" => "0054"
    },
    "256" => {
      "KeyWord" => "TimeSliceVector",
      "Name" => "Time Slice Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0100",
      "group" => "0054"
    },
    "257" => {
      "KeyWord" => "NumberOfTimeSlices",
      "Name" => "Number of Time Slices",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0101",
      "group" => "0054"
    },
    "32" => {
      "KeyWord" => "DetectorVector",
      "Name" => "Detector Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0020",
      "group" => "0054"
    },
    "33" => {
      "KeyWord" => "NumberOfDetectors",
      "Name" => "Number of Detectors",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0021",
      "group" => "0054"
    },
    "34" => {
      "KeyWord" => "DetectorInformationSequence",
      "Name" => "Detector Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0022",
      "group" => "0054"
    },
    "4096" => {
      "KeyWord" => "SeriesType",
      "Name" => "Series Type",
      "VM" => "2",
      "VR" => "CS",
      "ele" => "1000",
      "group" => "0054"
    },
    "4097" => {
      "KeyWord" => "Units",
      "Name" => "Units",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1001",
      "group" => "0054"
    },
    "4098" => {
      "KeyWord" => "CountsSource",
      "Name" => "Counts Source",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1002",
      "group" => "0054"
    },
    "4100" => {
      "KeyWord" => "ReprojectionMethod",
      "Name" => "Reprojection Method",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1004",
      "group" => "0054"
    },
    "4102" => {
      "KeyWord" => "SUVType",
      "Name" => "SUV Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1006",
      "group" => "0054"
    },
    "4352" => {
      "KeyWord" => "RandomsCorrectionMethod",
      "Name" => "Randoms Correction Method",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1100",
      "group" => "0054"
    },
    "4353" => {
      "KeyWord" => "AttenuationCorrectionMethod",
      "Name" => "Attenuation Correction Method",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1101",
      "group" => "0054"
    },
    "4354" => {
      "KeyWord" => "DecayCorrection",
      "Name" => "Decay Correction",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1102",
      "group" => "0054"
    },
    "4355" => {
      "KeyWord" => "ReconstructionMethod",
      "Name" => "Reconstruction Method",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1103",
      "group" => "0054"
    },
    "4356" => {
      "KeyWord" => "DetectorLinesOfResponseUsed",
      "Name" => "Detector Lines of Response Used",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1104",
      "group" => "0054"
    },
    "4357" => {
      "KeyWord" => "ScatterCorrectionMethod",
      "Name" => "Scatter Correction Method",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "1105",
      "group" => "0054"
    },
    "4608" => {
      "KeyWord" => "AxialAcceptance",
      "Name" => "Axial Acceptance",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1200",
      "group" => "0054"
    },
    "4609" => {
      "KeyWord" => "AxialMash",
      "Name" => "Axial Mash",
      "VM" => "2",
      "VR" => "IS",
      "ele" => "1201",
      "group" => "0054"
    },
    "4610" => {
      "KeyWord" => "TransverseMash",
      "Name" => "Transverse Mash",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1202",
      "group" => "0054"
    },
    "4611" => {
      "KeyWord" => "DetectorElementSize",
      "Name" => "Detector Element Size",
      "VM" => "2",
      "VR" => "DS",
      "ele" => "1203",
      "group" => "0054"
    },
    "4624" => {
      "KeyWord" => "CoincidenceWindowWidth",
      "Name" => "Coincidence Window Width",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1210",
      "group" => "0054"
    },
    "4640" => {
      "KeyWord" => "SecondaryCountsType",
      "Name" => "Secondary Counts Type",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "1220",
      "group" => "0054"
    },
    "48" => {
      "KeyWord" => "PhaseVector",
      "Name" => "Phase Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0030",
      "group" => "0054"
    },
    "4864" => {
      "KeyWord" => "FrameReferenceTime",
      "Name" => "Frame Reference Time",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1300",
      "group" => "0054"
    },
    "4880" => {
      "KeyWord" => "PrimaryPromptsCountsAccumulated",
      "Name" => "Primary (Prompts) Counts Accumulated",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "1310",
      "group" => "0054"
    },
    "4881" => {
      "KeyWord" => "SecondaryCountsAccumulated",
      "Name" => "Secondary Counts Accumulated",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "1311",
      "group" => "0054"
    },
    "4896" => {
      "KeyWord" => "SliceSensitivityFactor",
      "Name" => "Slice Sensitivity Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1320",
      "group" => "0054"
    },
    "4897" => {
      "KeyWord" => "DecayFactor",
      "Name" => "Decay Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1321",
      "group" => "0054"
    },
    "4898" => {
      "KeyWord" => "DoseCalibrationFactor",
      "Name" => "Dose Calibration Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1322",
      "group" => "0054"
    },
    "4899" => {
      "KeyWord" => "ScatterFractionFactor",
      "Name" => "Scatter Fraction Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1323",
      "group" => "0054"
    },
    "49" => {
      "KeyWord" => "NumberOfPhases",
      "Name" => "Number of Phases",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0031",
      "group" => "0054"
    },
    "4900" => {
      "KeyWord" => "DeadTimeFactor",
      "Name" => "Dead Time Factor",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "1324",
      "group" => "0054"
    },
    "4912" => {
      "KeyWord" => "ImageIndex",
      "Name" => "Image Index",
      "VM" => "1",
      "VR" => "US",
      "ele" => "1330",
      "group" => "0054"
    },
    "50" => {
      "KeyWord" => "PhaseInformationSequence",
      "Name" => "Phase Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0032",
      "group" => "0054"
    },
    "51" => {
      "KeyWord" => "NumberOfFramesInPhase",
      "Name" => "Number of Frames in Phase",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0033",
      "group" => "0054"
    },
    "512" => {
      "KeyWord" => "StartAngle",
      "Name" => "Start Angle",
      "VM" => "1",
      "VR" => "DS",
      "ele" => "0200",
      "group" => "0054"
    },
    "5120" => {
      "KeyWord" => "CountsIncluded",
      "Name" => "Counts Included",
      "RET" => "1",
      "VM" => "1-n",
      "VR" => "CS",
      "ele" => "1400",
      "group" => "0054"
    },
    "5121" => {
      "KeyWord" => "DeadTimeCorrectionFlag",
      "Name" => "Dead Time Correction Flag",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "1401",
      "group" => "0054"
    },
    "514" => {
      "KeyWord" => "TypeOfDetectorMotion",
      "Name" => "Type of Detector Motion",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0202",
      "group" => "0054"
    },
    "528" => {
      "KeyWord" => "TriggerVector",
      "Name" => "Trigger Vector",
      "VM" => "1-n",
      "VR" => "IS",
      "ele" => "0210",
      "group" => "0054"
    },
    "529" => {
      "KeyWord" => "NumberOfTriggersInPhase",
      "Name" => "Number of Triggers in Phase",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0211",
      "group" => "0054"
    },
    "54" => {
      "KeyWord" => "PhaseDelay",
      "Name" => "Phase Delay",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0036",
      "group" => "0054"
    },
    "544" => {
      "KeyWord" => "ViewCodeSequence",
      "Name" => "View Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0220",
      "group" => "0054"
    },
    "546" => {
      "KeyWord" => "ViewModifierCodeSequence",
      "Name" => "View Modifier Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0222",
      "group" => "0054"
    },
    "56" => {
      "KeyWord" => "PauseBetweenFrames",
      "Name" => "Pause Between Frames",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0038",
      "group" => "0054"
    },
    "57" => {
      "KeyWord" => "PhaseDescription",
      "Name" => "Phase Description",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0039",
      "group" => "0054"
    },
    "768" => {
      "KeyWord" => "RadionuclideCodeSequence",
      "Name" => "Radionuclide Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0300",
      "group" => "0054"
    },
    "770" => {
      "KeyWord" => "AdministrationRouteCodeSequence",
      "Name" => "Administration Route Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0302",
      "group" => "0054"
    },
    "772" => {
      "KeyWord" => "RadiopharmaceuticalCodeSequence",
      "Name" => "Radiopharmaceutical Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0304",
      "group" => "0054"
    },
    "774" => {
      "KeyWord" => "CalibrationDataSequence",
      "Name" => "Calibration Data Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0306",
      "group" => "0054"
    },
    "776" => {
      "KeyWord" => "EnergyWindowNumber",
      "Name" => "Energy Window Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0308",
      "group" => "0054"
    },
    "80" => {
      "KeyWord" => "RotationVector",
      "Name" => "Rotation Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0050",
      "group" => "0054"
    },
    "81" => {
      "KeyWord" => "NumberOfRotations",
      "Name" => "Number of Rotations",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0051",
      "group" => "0054"
    },
    "82" => {
      "KeyWord" => "RotationInformationSequence",
      "Name" => "Rotation Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0052",
      "group" => "0054"
    },
    "83" => {
      "KeyWord" => "NumberOfFramesInRotation",
      "Name" => "Number of Frames in Rotation",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0053",
      "group" => "0054"
    },
    "96" => {
      "KeyWord" => "RRIntervalVector",
      "Name" => "R-R Interval Vector",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "0060",
      "group" => "0054"
    },
    "97" => {
      "KeyWord" => "NumberOfRRIntervals",
      "Name" => "Number of R-R Intervals",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0061",
      "group" => "0054"
    },
    "98" => {
      "KeyWord" => "GatedInformationSequence",
      "Name" => "Gated Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0062",
      "group" => "0054"
    },
    "99" => {
      "KeyWord" => "DataInformationSequence",
      "Name" => "Data Information Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0063",
      "group" => "0054"
    }
  },
  "8448" => {
    "112" => {
      "KeyWord" => "Originator",
      "Name" => "Originator",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "0070",
      "group" => "2100"
    },
    "1280" => {
      "KeyWord" => "ReferencedPrintJobSequencePullStoredPrint",
      "Name" => "Referenced Print Job Sequence (Pull Stored Print)",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0500",
      "group" => "2100"
    },
    "16" => {
      "KeyWord" => "PrintJobID",
      "Name" => "Print Job ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0010",
      "group" => "2100"
    },
    "32" => {
      "KeyWord" => "ExecutionStatus",
      "Name" => "Execution Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "2100"
    },
    "320" => {
      "KeyWord" => "DestinationAE",
      "Name" => "Destination AE",
      "RET" => "1",
      "VM" => "1",
      "VR" => "AE",
      "ele" => "0140",
      "group" => "2100"
    },
    "352" => {
      "KeyWord" => "OwnerID",
      "Name" => "Owner ID",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0160",
      "group" => "2100"
    },
    "368" => {
      "KeyWord" => "NumberOfFilms",
      "Name" => "Number of Films",
      "VM" => "1",
      "VR" => "IS",
      "ele" => "0170",
      "group" => "2100"
    },
    "48" => {
      "KeyWord" => "ExecutionStatusInfo",
      "Name" => "Execution Status Info",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0030",
      "group" => "2100"
    },
    "64" => {
      "KeyWord" => "CreationDate",
      "Name" => "Creation Date",
      "VM" => "1",
      "VR" => "DA",
      "ele" => "0040",
      "group" => "2100"
    },
    "80" => {
      "KeyWord" => "CreationTime",
      "Name" => "Creation Time",
      "VM" => "1",
      "VR" => "TM",
      "ele" => "0050",
      "group" => "2100"
    }
  },
  "8464" => {
    "153" => {
      "KeyWord" => "PrintQueueID",
      "Name" => "Print Queue ID",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SH",
      "ele" => "0099",
      "group" => "2110"
    },
    "16" => {
      "KeyWord" => "PrinterStatus",
      "Name" => "Printer Status",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0010",
      "group" => "2110"
    },
    "32" => {
      "KeyWord" => "PrinterStatusInfo",
      "Name" => "Printer Status Info",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "2110"
    },
    "48" => {
      "KeyWord" => "PrinterName",
      "Name" => "Printer Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0030",
      "group" => "2110"
    }
  },
  "8480" => {
    "112" => {
      "KeyWord" => "ReferencedPrintJobSequence",
      "Name" => "Referenced Print Job Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0070",
      "group" => "2120"
    },
    "16" => {
      "KeyWord" => "QueueStatus",
      "Name" => "Queue Status",
      "RET" => "1",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0010",
      "group" => "2120"
    },
    "80" => {
      "KeyWord" => "PrintJobDescriptionSequence",
      "Name" => "Print Job Description Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "2120"
    }
  },
  "8496" => {
    "128" => {
      "KeyWord" => "PresentationLUTContentSequence",
      "Name" => "Presentation LUT Content Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0080",
      "group" => "2130"
    },
    "16" => {
      "KeyWord" => "PrintManagementCapabilitiesSequence",
      "Name" => "Print Management Capabilities Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0010",
      "group" => "2130"
    },
    "160" => {
      "KeyWord" => "ProposedStudySequence",
      "Name" => "Proposed Study Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00a0",
      "group" => "2130"
    },
    "192" => {
      "KeyWord" => "OriginalImageSequence",
      "Name" => "Original Image Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "00c0",
      "group" => "2130"
    },
    "21" => {
      "KeyWord" => "PrinterCharacteristicsSequence",
      "Name" => "Printer Characteristics Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0015",
      "group" => "2130"
    },
    "48" => {
      "KeyWord" => "FilmBoxContentSequence",
      "Name" => "Film Box Content Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0030",
      "group" => "2130"
    },
    "64" => {
      "KeyWord" => "ImageBoxContentSequence",
      "Name" => "Image Box Content Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0040",
      "group" => "2130"
    },
    "80" => {
      "KeyWord" => "AnnotationContentSequence",
      "Name" => "Annotation Content Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0050",
      "group" => "2130"
    },
    "96" => {
      "KeyWord" => "ImageOverlayBoxContentSequence",
      "Name" => "Image Overlay Box Content Sequence",
      "RET" => "1",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0060",
      "group" => "2130"
    }
  },
  "8704" => {
    "1" => {
      "KeyWord" => "LabelUsingInformationExtractedFromInstances",
      "Name" => "Label Using Information Extracted From Instances",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0001",
      "group" => "2200"
    },
    "10" => {
      "KeyWord" => "PreserveCompositeInstancesAfterMediaCreation",
      "Name" => "Preserve Composite Instances After Media Creation",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000a",
      "group" => "2200"
    },
    "11" => {
      "KeyWord" => "TotalNumberOfPiecesOfMediaCreated",
      "Name" => "Total Number of Pieces of Media Created",
      "VM" => "1",
      "VR" => "US",
      "ele" => "000b",
      "group" => "2200"
    },
    "12" => {
      "KeyWord" => "RequestedMediaApplicationProfile",
      "Name" => "Requested Media Application Profile",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "000c",
      "group" => "2200"
    },
    "13" => {
      "KeyWord" => "ReferencedStorageMediaSequence",
      "Name" => "Referenced Storage Media Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000d",
      "group" => "2200"
    },
    "14" => {
      "KeyWord" => "FailureAttributes",
      "Name" => "Failure Attributes",
      "VM" => "1-n",
      "VR" => "AT",
      "ele" => "000e",
      "group" => "2200"
    },
    "15" => {
      "KeyWord" => "AllowLossyCompression",
      "Name" => "Allow Lossy Compression",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "000f",
      "group" => "2200"
    },
    "2" => {
      "KeyWord" => "LabelText",
      "Name" => "Label Text",
      "VM" => "1",
      "VR" => "UT",
      "ele" => "0002",
      "group" => "2200"
    },
    "3" => {
      "KeyWord" => "LabelStyleSelection",
      "Name" => "Label Style Selection",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0003",
      "group" => "2200"
    },
    "32" => {
      "KeyWord" => "RequestPriority",
      "Name" => "Request Priority",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0020",
      "group" => "2200"
    },
    "4" => {
      "KeyWord" => "MediaDisposition",
      "Name" => "Media Disposition",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0004",
      "group" => "2200"
    },
    "5" => {
      "KeyWord" => "BarcodeValue",
      "Name" => "Barcode Value",
      "VM" => "1",
      "VR" => "LT",
      "ele" => "0005",
      "group" => "2200"
    },
    "6" => {
      "KeyWord" => "BarcodeSymbology",
      "Name" => "Barcode Symbology",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0006",
      "group" => "2200"
    },
    "7" => {
      "KeyWord" => "AllowMediaSplitting",
      "Name" => "Allow Media Splitting",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0007",
      "group" => "2200"
    },
    "8" => {
      "KeyWord" => "IncludeNonDICOMObjects",
      "Name" => "Include Non-DICOM Objects",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0008",
      "group" => "2200"
    },
    "9" => {
      "KeyWord" => "IncludeDisplayApplication",
      "Name" => "Include Display Application",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0009",
      "group" => "2200"
    }
  },
  "96" => {
    "12288" => {
      "KeyWord" => "HistogramSequence",
      "Name" => "Histogram Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "3000",
      "group" => "0060"
    },
    "12290" => {
      "KeyWord" => "HistogramNumberOfBins",
      "Name" => "Histogram Number of Bins",
      "VM" => "1",
      "VR" => "US",
      "ele" => "3002",
      "group" => "0060"
    },
    "12292" => {
      "KeyWord" => "HistogramFirstBinValue",
      "Name" => "Histogram First Bin Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "3004",
      "group" => "0060"
    },
    "12294" => {
      "KeyWord" => "HistogramLastBinValue",
      "Name" => "Histogram Last Bin Value",
      "VM" => "1",
      "VR" => "OT",
      "ele" => "3006",
      "group" => "0060"
    },
    "12296" => {
      "KeyWord" => "HistogramBinWidth",
      "Name" => "Histogram Bin Width",
      "VM" => "1",
      "VR" => "US",
      "ele" => "3008",
      "group" => "0060"
    },
    "12304" => {
      "KeyWord" => "HistogramExplanation",
      "Name" => "Histogram Explanation",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "3010",
      "group" => "0060"
    },
    "12320" => {
      "KeyWord" => "HistogramData",
      "Name" => "Histogram Data",
      "VM" => "1-n",
      "VR" => "UL",
      "ele" => "3020",
      "group" => "0060"
    }
  },
  "98" => {
    "1" => {
      "KeyWord" => "SegmentationType",
      "Name" => "Segmentation Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0001",
      "group" => "0062"
    },
    "10" => {
      "KeyWord" => "SegmentIdentificationSequence",
      "Name" => "Segment Identification Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000a",
      "group" => "0062"
    },
    "11" => {
      "KeyWord" => "ReferencedSegmentNumber",
      "Name" => "Referenced Segment Number",
      "VM" => "1-n",
      "VR" => "US",
      "ele" => "000b",
      "group" => "0062"
    },
    "12" => {
      "KeyWord" => "RecommendedDisplayGrayscaleValue",
      "Name" => "Recommended Display Grayscale Value",
      "VM" => "1",
      "VR" => "US",
      "ele" => "000c",
      "group" => "0062"
    },
    "13" => {
      "KeyWord" => "RecommendedDisplayCIELabValue",
      "Name" => "Recommended Display CIELab Value",
      "VM" => "3",
      "VR" => "US",
      "ele" => "000d",
      "group" => "0062"
    },
    "14" => {
      "KeyWord" => "MaximumFractionalValue",
      "Name" => "Maximum Fractional Value",
      "VM" => "1",
      "VR" => "US",
      "ele" => "000e",
      "group" => "0062"
    },
    "15" => {
      "KeyWord" => "SegmentedPropertyTypeCodeSequence",
      "Name" => "Segmented Property Type Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "000f",
      "group" => "0062"
    },
    "16" => {
      "KeyWord" => "SegmentationFractionalType",
      "Name" => "Segmentation Fractional Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0010",
      "group" => "0062"
    },
    "17" => {
      "KeyWord" => "SegmentedPropertyTypeModifierCodeSequence",
      "Name" => "Segmented Property Type Modifier Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0011",
      "group" => "0062"
    },
    "18" => {
      "KeyWord" => "UsedSegmentsSequence",
      "Name" => "Used Segments Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0012",
      "group" => "0062"
    },
    "2" => {
      "KeyWord" => "SegmentSequence",
      "Name" => "Segment Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0002",
      "group" => "0062"
    },
    "3" => {
      "KeyWord" => "SegmentedPropertyCategoryCodeSequence",
      "Name" => "Segmented Property Category Code Sequence",
      "VM" => "1",
      "VR" => "SQ",
      "ele" => "0003",
      "group" => "0062"
    },
    "4" => {
      "KeyWord" => "SegmentNumber",
      "Name" => "Segment Number",
      "VM" => "1",
      "VR" => "US",
      "ele" => "0004",
      "group" => "0062"
    },
    "5" => {
      "KeyWord" => "SegmentLabel",
      "Name" => "Segment Label",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0005",
      "group" => "0062"
    },
    "6" => {
      "KeyWord" => "SegmentDescription",
      "Name" => "Segment Description",
      "VM" => "1",
      "VR" => "ST",
      "ele" => "0006",
      "group" => "0062"
    },
    "8" => {
      "KeyWord" => "SegmentAlgorithmType",
      "Name" => "Segment Algorithm Type",
      "VM" => "1",
      "VR" => "CS",
      "ele" => "0008",
      "group" => "0062"
    },
    "9" => {
      "KeyWord" => "SegmentAlgorithmName",
      "Name" => "Segment Algorithm Name",
      "VM" => "1",
      "VR" => "LO",
      "ele" => "0009",
      "group" => "0062"
    }
  }
};
require Posda::PvtDataDict;
my $VRDesc = {
  AE => {
    name => "Application Entity",
    len => "16",
    type => "text",
    striptrailing => "1",
    stripleading => "1",
  },
  AS => {
    name => "Age String",
    len => "4",
    type => "text",
    fixed => "1",
  },
  AT => {
    name => "Attribute Tag",
    len => "4",
    type => "ulong",
    fixed => "1",
  },
  CS => {
    name => "Code String",
    len => "16",
    type => "text",
    striptrailing => "1",
    stripleading => "1",
  },
  DA => {
    name => "Date",
    len => "10",
    type => "text",
  },
  DS => {
    name => "Decimal String",
    len => "16",
    type => "text",
    striptrailing => "1",
    stripleading => "1",
  },
  DT => {
    name => "Date Time",
    len => "26",
    type => "text",
    striptrailing => "1",
    stripleading => "1",
  },
  FD => {
    name => "Floating Point Double",
    len => "8",
    type => "double",
    fixed => "1",
  },
  FL => {
    name => "Floating Point Single",
    len => "4",
    type => "float",
    fixed => "1",
  },
  IS => {
    name => "Integer String",
    len => "12",
    type => "text",
    striptrailing => "1",
    stripleading => "1",
  },
  LO => {
    name => "Long String",
    len => "64",
    type => "text",
    striptrailing => "1",
    stripleading => "1",
  },
  LT => {
    name => "Long Text",
    len => "10240",
    type => "text",
    striptrailing => "1",
    padtrailing => "1",
  },
  OB => {
    name => "Other Byte",
    type => "raw",
  },
  OF => {
    name => "Other Float String",
    type => "raw",
  },
  OT => {
    name => "Other",
    type => "raw",
  },
  OW => {
    name => "Other Word",
    type => "raw",
  },
  PN => {
    name => "Person Name",
    len => "64",
    type => "text",
    striptrailing => "1",
    padtrailing => "1",
  },
  SH => {
    name => "Short String",
    len => "16",
    type => "text",
    striptrailing => "1",
    stripleading => "1",
  },
  SL => {
    name => "Signed Long",
    len => "4",
    type => "slong",
    fixed => "1",
  },
  SQ => {
    name => "Sequence",
    type => "seq",
  },
  SS => {
    name => "Signed Short",
    len => "2",
    type => "sshort",
    fixed => "1",
  },
  ST => {
    name => "Short Text",
    len => "1024",
    type => "text",
    striptrailing => "1",
    padtrailing => "1",
  },
  TM => {
    name => "Time",
    len => "16",
    type => "text",
    striptrailing => "1",
    padtrailing => "1",
  },
  UC => {
    name => "Unlimited Character",
    type => "text",
    padtrailing => "1",
  },
  UI => {
    name => "Unique Identifier",
    len => "64",
    type => "text",
    striptrailingnull => "1",
    padnull => "1",
  },
  UL => {
    name => "Unsigned Long",
    len => "4",
    type => "ulong",
    fixed => "1",
  },
  UN => {
    name => "Unknown",
    type => "raw",
  },
  UR => {
    name => "Universal Resource Identifier or Universal Resource Locator (URI/URL)",
    type => "text",
    padtrailing => "1",
  },
  US => {
    name => "Unsigned Short",
    len => "2",
    type => "ushort",
    fixed => "1",
  },
  UT => {
    name => "Unlimited Text",
    type => "text",
    padtrailing => "1",
  },
};
my $XferSyntax = {
  "1.2.826.0.1.3680043.2.494.1.1" => {
    name => "Implicit VR Big Endian",
    short_len => "0",
    encap => "0",
    std => "0",
  },
  "1.2.840.10008.1.2" => {
    vax => "1",
    name => "Implicit VR Little Endian",
    std => "1",
    short_len => "0",
    encap => "0",
    std => "1",
  },
  "1.2.840.10008.1.2.1" => {
    vax => "1",
    name => "Explicit VR Little Endian",
    explicit => "1",
    short_len => "1",
    std => "1",
    short_len => "1",
    encap => "0",
    std => "1",
  },
  "1.2.840.10008.1.2.1.99" => {
    vax => "1",
    name => "Deflated Explicit VR Little Endian",
    explicit => "1",
    short_len => "1",
    std => "1",
    short_len => "1",
    encap => "0",
    std => "1",
  },
  "1.2.840.10008.1.2.2" => {
    name => "Explicit VR Big Endian",
    explicit => "1",
    short_len => "1",
    std => "1",
    short_len => "1",
    encap => "0",
    std => "1",
  },
  "1.2.840.10008.1.2.4.100" => {
    vax => "1",
    name => "MPEG2 Main Profile @ Main Level",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.50" => {
    vax => "1",
    name => "JPEG Baseline (Process 1)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.51" => {
    vax => "1",
    name => "JPEG Extended (Process 2 & 4)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.52" => {
    vax => "1",
    name => "JPEG Extended (Process 3 & 5)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.53" => {
    vax => "1",
    name => "JPEG Spectral Selection, Non-hierarchical (Process 6 & 8)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.54" => {
    vax => "1",
    name => "JPEG Spectral Selection, Non-hierarchical (Process 7 & 9)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.55" => {
    vax => "1",
    name => "JPEG Full Progression, Non-hierarchical (Process 10 & 12)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.56" => {
    vax => "1",
    name => "JPEG Full Progression, Non-hierarchical (Process 13)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.57" => {
    vax => "1",
    name => "JPEG Lossless, Non-hierarchical (Process 14)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.58" => {
    vax => "1",
    name => "JPEG Lossless, Non-hierarchical (Process 15)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.59" => {
    vax => "1",
    name => "JPEG Extended, Hierarchical (Process 16 & 18)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.60" => {
    vax => "1",
    name => "JPEG Extended, Hierarchical (Process 17 & 19)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.61" => {
    vax => "1",
    name => "JPEG Spectral Selection, Hierarchical (Process 20 & 22)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.62" => {
    vax => "1",
    name => "JPEG Spectral Selection, Hierarchical (Process 21 & 23)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.63" => {
    vax => "1",
    name => "JPEG Full Progression, Hierarchical (Process 24 & 26)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.64" => {
    vax => "1",
    name => "JPEG Full Progression, Hierarchical (Process 25 & 27)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.65" => {
    vax => "1",
    name => "JPEG Lossless, Hierarchical (Process 28)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.66" => {
    vax => "1",
    name => "JPEG Lossless, Hierarchical (Process 29)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    retired => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.70" => {
    vax => "1",
    name => "JPEG Lossless, Non-hierachchial, 1st Order Prediction (Process 14 [Selection Value 1])",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.80" => {
    vax => "1",
    name => "JPEG-LS Lossless Image Compression",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.81" => {
    vax => "1",
    name => "JPEG-LS Lossy (Near-Lossless) Image Compression",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.90" => {
    vax => "1",
    name => "JPEG 2000 Image Compression (Lossless Only)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.91" => {
    vax => "1",
    name => "JPEG 2000 Image Compression",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.92" => {
    vax => "1",
    name => "JPEG 2000 Part 2 Multi-component Image Compression (Lossless Only)",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.93" => {
    vax => "1",
    name => "JPEG 2000 Part 2 Multi-component Image Compression",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.2.840.10008.1.2.4.94" => {
    vax => "1",
    name => "JPIP Referenced",
    explicit => "1",
    short_len => "1",
    std => "1",
    short_len => "1",
    encap => "0",
    std => "1",
  },
  "1.2.840.10008.1.2.4.95" => {
    vax => "1",
    name => "JPIP Referenced Deflate",
    explicit => "1",
    short_len => "1",
    std => "1",
    short_len => "1",
    encap => "0",
    std => "1",
  },
  "1.2.840.10008.1.2.5" => {
    vax => "1",
    name => "RLE Lossless",
    explicit => "1",
    short_len => "1",
    encap => "1",
    std => "1",
    short_len => "1",
    encap => "1",
    std => "1",
  },
  "1.3.6.1.4.1.22213.1.147" => {
    vax => "1",
    name => "Explicit VR Little Endian with Long Lengths",
    explicit => "1",
    short_len => "0",
    encap => "0",
    std => "0",
  },
};
my $SopCl = {
  "1.2.840.10008.1.1" => {
    "sopcl_desc" => "Verification SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.1.2" => {
    "sopcl_desc" => "Implicit VR Little Endian: Default Transfer Syntax for DICOM",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.1" => {
    "sopcl_desc" => "Explicit VR Little Endian",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.1.99" => {
    "sopcl_desc" => "Deflated Explicit VR Little Endian",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.2" => {
    "retired" => "1",
    "sopcl_desc" => "Explicit VR Big Endian ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.100" => {
    "sopcl_desc" => "MPEG2 Main Profile \@ Main Level",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.101" => {
    "sopcl_desc" => "MPEG2 Main Profile \@ High Level",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.102" => {
    "sopcl_desc" => "MPEG-4 AVC/H.264 High Profile / Level 4.1",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.103" => {
    "sopcl_desc" => "MPEG-4 AVC/H.264 BD-compatible High Profile / Level 4.1",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.50" => {
    "sopcl_desc" => "JPEG Baseline (Process 1) : Default Transfer Syntax for Lossy JPEG 8 Bit Image Compression",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.51" => {
    "sopcl_desc" => "JPEG Extended (Process 2 & 4) : Default Transfer Syntax for Lossy JPEG 12 Bit Image Compression (Process 4 only)",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.52" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Extended (Process 3 & 5) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.53" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Spectral Selection, Non-Hierarchical (Process 6 & 8) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.54" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Spectral Selection, Non-Hierarchical (Process 7 & 9) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.55" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Full Progression, Non-Hierarchical (Process 10 & 12) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.56" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Full Progression, Non-Hierarchical (Process 11 & 13) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.57" => {
    "sopcl_desc" => "JPEG Lossless, Non-Hierarchical (Process 14)",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.58" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Lossless, Non-Hierarchical (Process 15) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.59" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Extended, Hierarchical (Process 16 & 18) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.60" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Extended, Hierarchical (Process 17 & 19) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.61" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Spectral Selection, Hierarchical (Process 20 & 22) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.62" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Spectral Selection, Hierarchical (Process 21 & 23) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.63" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Full Progression, Hierarchical (Process 24 & 26) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.64" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Full Progression, Hierarchical (Process 25 & 27) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.65" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Lossless, Hierarchical (Process 28) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.66" => {
    "retired" => "1",
    "sopcl_desc" => "JPEG Lossless, Hierarchical (Process 29) ",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.70" => {
    "sopcl_desc" => "JPEG Lossless, Non-Hierarchical, First-Order Prediction (Process 14 [Selection Value 1]) : Default Transfer Syntax for Lossless JPEG Image Compression",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.80" => {
    "sopcl_desc" => "JPEG-LS Lossless Image Compression",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.81" => {
    "sopcl_desc" => "JPEG-LS Lossy (Near-Lossless) Image Compression",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.90" => {
    "sopcl_desc" => "JPEG 2000 Image Compression (Lossless Only)",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.91" => {
    "sopcl_desc" => "JPEG 2000 Image Compression",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.92" => {
    "sopcl_desc" => "JPEG 2000 Part 2 Multi-component Image Compression (Lossless Only)",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.93" => {
    "sopcl_desc" => "JPEG 2000 Part 2 Multi-component Image Compression",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.94" => {
    "sopcl_desc" => "JPIP Referenced",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.4.95" => {
    "sopcl_desc" => "JPIP Referenced Deflate",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.5" => {
    "sopcl_desc" => "RLE Lossless",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.6.1" => {
    "sopcl_desc" => "RFC 2557 MIME encapsulation",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.2.6.2" => {
    "sopcl_desc" => "XML Encoding",
    "type" => "Transfer Syntax"
  },
  "1.2.840.10008.1.20.1" => {
    "sopcl_desc" => "Storage Commitment Push Model SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.1.20.1.1" => {
    "sopcl_desc" => "Storage Commitment Push Model SOP Instance",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.1.20.2" => {
    "retired" => "1",
    "sopcl_desc" => "Storage Commitment Pull Model SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.1.20.2.1" => {
    "retired" => "1",
    "sopcl_desc" => "Storage Commitment Pull Model SOP Instance ",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.1.3.10" => {
    "sopcl_desc" => "Media Storage Directory Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.1.4.1.1" => {
    "sopcl_desc" => "Talairach Brain Atlas Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.10" => {
    "sopcl_desc" => "SPM2 GRAY Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.11" => {
    "sopcl_desc" => "SPM2 WHITE Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.12" => {
    "sopcl_desc" => "SPM2 CSF Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.13" => {
    "sopcl_desc" => "SPM2 BRAINMASK Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.14" => {
    "sopcl_desc" => "SPM2 AVG305T1 Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.15" => {
    "sopcl_desc" => "SPM2 AVG152T1 Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.16" => {
    "sopcl_desc" => "SPM2 AVG152T2 Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.17" => {
    "sopcl_desc" => "SPM2 AVG152PD Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.18" => {
    "sopcl_desc" => "SPM2 SINGLESUBJT1 Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.2" => {
    "sopcl_desc" => "SPM2 T1 Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.3" => {
    "sopcl_desc" => "SPM2 T2 Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.4" => {
    "sopcl_desc" => "SPM2 PD Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.5" => {
    "sopcl_desc" => "SPM2 EPI Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.6" => {
    "sopcl_desc" => "SPM2 FIL T1 Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.7" => {
    "sopcl_desc" => "SPM2 PET Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.8" => {
    "sopcl_desc" => "SPM2 TRANSM Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.1.9" => {
    "sopcl_desc" => "SPM2 SPECT Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.2.1" => {
    "sopcl_desc" => "ICBM 452 T1 Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.4.2.2" => {
    "sopcl_desc" => "ICBM Single Subject MRI Frame of Reference",
    "type" => "Well-known frame of reference"
  },
  "1.2.840.10008.1.40" => {
    "sopcl_desc" => "Procedural Event Logging SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.1.40.1" => {
    "sopcl_desc" => "Procedural Event Logging SOP Instance",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.1.42" => {
    "sopcl_desc" => "Substance Administration Logging SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.1.42.1" => {
    "sopcl_desc" => "Substance Administration Logging SOP Instance",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.1.5.1" => {
    "sopcl_desc" => "Hot Iron Color Palette SOP Instance",
    "std_ref" => "PS 3.6",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.1.5.2" => {
    "sopcl_desc" => "PET Color Palette SOP Instance",
    "std_ref" => "PS 3.6",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.1.5.3" => {
    "sopcl_desc" => "Hot Metal Blue Color Palette SOP Instance",
    "std_ref" => "PS 3.6",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.1.5.4" => {
    "sopcl_desc" => "PET 20 Step Color Palette SOP Instance",
    "std_ref" => "PS 3.6",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.1.9" => {
    "retired" => "1",
    "sopcl_desc" => "Basic Study Content Notification SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.15.0.3.1" => {
    "sopcl_desc" => "dicomDeviceName",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.10" => {
    "sopcl_desc" => "dicomAssociationInitiator",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.11" => {
    "sopcl_desc" => "dicomAssociationAcceptor",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.12" => {
    "sopcl_desc" => "dicomHostname",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.13" => {
    "sopcl_desc" => "dicomPort",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.14" => {
    "sopcl_desc" => "dicomSOPClass",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.15" => {
    "sopcl_desc" => "dicomTransferRole",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.16" => {
    "sopcl_desc" => "dicomTransferSyntax",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.17" => {
    "sopcl_desc" => "dicomPrimaryDeviceType",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.18" => {
    "sopcl_desc" => "dicomRelatedDeviceReference",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.19" => {
    "sopcl_desc" => "dicomPreferredCalledAETitle",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.2" => {
    "sopcl_desc" => "dicomDescription",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.20" => {
    "sopcl_desc" => "dicomTLSCyphersuite",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.21" => {
    "sopcl_desc" => "dicomAuthorizedNodeCertificateReference",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.22" => {
    "sopcl_desc" => "dicomThisNodeCertificateReference",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.23" => {
    "sopcl_desc" => "dicomInstalled",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.24" => {
    "sopcl_desc" => "dicomStationName",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.25" => {
    "sopcl_desc" => "dicomDeviceSerialNumber",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.26" => {
    "sopcl_desc" => "dicomInstitutionName",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.27" => {
    "sopcl_desc" => "dicomInstitutionAddress",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.28" => {
    "sopcl_desc" => "dicomInstitutionDepartmentName",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.29" => {
    "sopcl_desc" => "dicomIssuerOfPatientID",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.3" => {
    "sopcl_desc" => "dicomManufacturer",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.30" => {
    "sopcl_desc" => "dicomPreferredCallingAETitle",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.31" => {
    "sopcl_desc" => "dicomSupportedCharacterSet",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.4" => {
    "sopcl_desc" => "dicomManufacturerModelName",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.5" => {
    "sopcl_desc" => "dicomSoftwareVersion",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.6" => {
    "sopcl_desc" => "dicomVendorData",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.7" => {
    "sopcl_desc" => "dicomAETitle",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.8" => {
    "sopcl_desc" => "dicomNetworkConnectionReference",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.3.9" => {
    "sopcl_desc" => "dicomApplicationCluster",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.4.1" => {
    "sopcl_desc" => "dicomConfigurationRoot",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.4.2" => {
    "sopcl_desc" => "dicomDevicesRoot",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.4.3" => {
    "sopcl_desc" => "dicomUniqueAETitlesRegistryRoot",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.4.4" => {
    "sopcl_desc" => "dicomDevice",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.4.5" => {
    "sopcl_desc" => "dicomNetworkAE",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.4.6" => {
    "sopcl_desc" => "dicomNetworkConnection",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.4.7" => {
    "sopcl_desc" => "dicomUniqueAETitle",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.0.4.8" => {
    "sopcl_desc" => "dicomTransferCapability",
    "type" => "LDAP OID"
  },
  "1.2.840.10008.15.1.1" => {
    "sopcl_desc" => "Universal Coordinated Time",
    "type" => "Synchronization Frame of Reference"
  },
  "1.2.840.10008.2.16.4" => {
    "sopcl_desc" => "DICOM Controlled Terminology",
    "type" => "Coding Scheme"
  },
  "1.2.840.10008.2.6.1" => {
    "sopcl_desc" => "DICOM UID Registry",
    "std_ref" => "PS 3.6",
    "type" => "DICOM UIDs as a Coding Scheme"
  },
  "1.2.840.10008.3.1.1.1" => {
    "sopcl_desc" => "DICOM Application Context Name",
    "type" => "Application Context Name"
  },
  "1.2.840.10008.3.1.2.1.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Patient Management SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.1.4" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Patient Management Meta SOP Class ",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.3.1.2.2.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Visit Management SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.3.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Study Management SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.3.2" => {
    "retired" => "1",
    "sopcl_desc" => "Study Component Management SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.5.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Results Management SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.5.4" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Results Management Meta SOP Class ",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.3.1.2.5.5" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Study Management Meta SOP Class ",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.3.1.2.6.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Interpretation Management SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.4.2" => {
    "sopcl_desc" => "Storage Service Class",
    "type" => "Service Class"
  },
  "1.2.840.10008.5.1.1.1" => {
    "sopcl_desc" => "Basic Film Session SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.14" => {
    "sopcl_desc" => "Print Job SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.15" => {
    "sopcl_desc" => "Basic Annotation Box SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.16" => {
    "sopcl_desc" => "Printer SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.16.376" => {
    "sopcl_desc" => "Printer Configuration Retrieval SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.17" => {
    "sopcl_desc" => "Printer SOP Instance",
    "type" => "Well-known Printer SOP Instance"
  },
  "1.2.840.10008.5.1.1.17.376" => {
    "sopcl_desc" => "Printer Configuration Retrieval SOP Instance",
    "type" => "Well-known Printer SOP Instance"
  },
  "1.2.840.10008.5.1.1.18" => {
    "sopcl_desc" => "Basic Color Print Management Meta SOP Class",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.5.1.1.18.1" => {
    "retired" => "1",
    "sopcl_desc" => "Referenced Color Print Management Meta SOP Class ",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.5.1.1.2" => {
    "sopcl_desc" => "Basic Film Box SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.22" => {
    "sopcl_desc" => "VOI LUT Box SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.23" => {
    "sopcl_desc" => "Presentation LUT SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.24" => {
    "retired" => "1",
    "sopcl_desc" => "Image Overlay Box SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.24.1" => {
    "retired" => "1",
    "sopcl_desc" => "Basic Print Image Overlay Box SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.25" => {
    "retired" => "1",
    "sopcl_desc" => "Print Queue SOP Instance ",
    "type" => "Well-known Print Queue SOP Instance"
  },
  "1.2.840.10008.5.1.1.26" => {
    "retired" => "1",
    "sopcl_desc" => "Print Queue Management SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.27" => {
    "retired" => "1",
    "sopcl_desc" => "Stored Print Storage SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.29" => {
    "retired" => "1",
    "sopcl_desc" => "Hardcopy Grayscale Image Storage SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.30" => {
    "retired" => "1",
    "sopcl_desc" => "Hardcopy Color Image Storage SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.31" => {
    "retired" => "1",
    "sopcl_desc" => "Pull Print Request SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.32" => {
    "retired" => "1",
    "sopcl_desc" => "Pull Stored Print Management Meta SOP Class ",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.5.1.1.33" => {
    "sopcl_desc" => "Media Creation Management SOP Class UID",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.4" => {
    "sopcl_desc" => "Basic Grayscale Image Box SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.4.1" => {
    "sopcl_desc" => "Basic Color Image Box SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.4.2" => {
    "retired" => "1",
    "sopcl_desc" => "Referenced Image Box SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.9" => {
    "sopcl_desc" => "Basic Grayscale Print Management Meta SOP Class",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.5.1.1.9.1" => {
    "retired" => "1",
    "sopcl_desc" => "Referenced Grayscale Print Management Meta SOP Class ",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.1" => {
    "sopcl_desc" => "Computed Radiography Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.1.1" => {
    "sopcl_desc" => "Digital X-Ray Image Storage - For Presentation",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.1.1.1" => {
    "sopcl_desc" => "Digital X-Ray Image Storage - For Processing",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.1.2" => {
    "sopcl_desc" => "Digital Mammography X-Ray Image Storage - For Presentation",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.1.2.1" => {
    "sopcl_desc" => "Digital Mammography X-Ray Image Storage - For Processing",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.1.3" => {
    "sopcl_desc" => "Digital Intra-Oral X-Ray Image Storage - For Presentation",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.1.3.1" => {
    "sopcl_desc" => "Digital Intra-Oral X-Ray Image Storage - For Processing",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.10" => {
    "retired" => "1",
    "sopcl_desc" => "Standalone Modality LUT Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.104.1" => {
    "sopcl_desc" => "Encapsulated PDF Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.104.2" => {
    "sopcl_desc" => "Encapsulated CDA Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.11" => {
    "retired" => "1",
    "sopcl_desc" => "Standalone VOI LUT Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.11.1" => {
    "sopcl_desc" => "Grayscale Softcopy Presentation State Storage SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.11.2" => {
    "sopcl_desc" => "Color Softcopy Presentation State Storage SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.11.3" => {
    "sopcl_desc" => "Pseudo-Color Softcopy Presentation State Storage SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.11.4" => {
    "sopcl_desc" => "Blending Softcopy Presentation State Storage SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.11.5" => {
    "sopcl_desc" => "XA/XRF Grayscale Softcopy Presentation State Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.12.1" => {
    "sopcl_desc" => "X-Ray Angiographic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.12.1.1" => {
    "sopcl_desc" => "Enhanced XA Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.12.2" => {
    "sopcl_desc" => "X-Ray Radiofluoroscopic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.12.2.1" => {
    "sopcl_desc" => "Enhanced XRF Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.12.3" => {
    "retired" => "1",
    "sopcl_desc" => "X-Ray Angiographic Bi-Plane Image Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.128" => {
    "sopcl_desc" => "Positron Emission Tomography Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.128.1" => {
    "sopcl_desc" => "Legacy Converted Enhanced PET Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.129" => {
    "retired" => "1",
    "sopcl_desc" => "Standalone PET Curve Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.13.1.1" => {
    "sopcl_desc" => "X-Ray 3D Angiographic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.13.1.2" => {
    "sopcl_desc" => "X-Ray 3D Craniofacial Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.13.1.3" => {
    "sopcl_desc" => "Breast Tomosynthesis Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.130" => {
    "sopcl_desc" => "Enhanced PET Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.131" => {
    "sopcl_desc" => "Basic Structured Display Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.14.1" => {
    "sopcl_desc" => "Intravascular Optical Coherence Tomography Image Storage - For Presentation",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.14.2" => {
    "sopcl_desc" => "Intravascular Optical Coherence Tomography Image Storage - For Processing",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.2" => {
    "sopcl_desc" => "CT Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.2.1" => {
    "sopcl_desc" => "Enhanced CT Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.2.2" => {
    "sopcl_desc" => "Legacy Converted Enhanced CT Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.20" => {
    "sopcl_desc" => "Nuclear Medicine Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.3" => {
    "retired" => "1",
    "sopcl_desc" => "Ultrasound Multi-frame Image Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.3.1" => {
    "sopcl_desc" => "Ultrasound Multi-frame Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.4" => {
    "sopcl_desc" => "MR Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.4.1" => {
    "sopcl_desc" => "Enhanced MR Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.4.2" => {
    "sopcl_desc" => "MR Spectroscopy Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.4.3" => {
    "sopcl_desc" => "Enhanced MR Color Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.4.4" => {
    "sopcl_desc" => "Legacy Converted Enhanced MR Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.1" => {
    "sopcl_desc" => "RT Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.2" => {
    "sopcl_desc" => "RT Dose Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.3" => {
    "sopcl_desc" => "RT Structure Set Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.4" => {
    "sopcl_desc" => "RT Beams Treatment Record Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.5" => {
    "sopcl_desc" => "RT Plan Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.6" => {
    "sopcl_desc" => "RT Brachy Treatment Record Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.7" => {
    "sopcl_desc" => "RT Treatment Summary Record Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.8" => {
    "sopcl_desc" => "RT Ion Plan Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.481.9" => {
    "sopcl_desc" => "RT Ion Beams Treatment Record Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.5" => {
    "retired" => "1",
    "sopcl_desc" => "Nuclear Medicine Image Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.501.1" => {
    "sopcl_desc" => "DICOS CT Image Storage",
    "std_ref" => "DICOS",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.501.2.1" => {
    "sopcl_desc" => "DICOS Digital X-Ray Image Storage - For Presentation",
    "std_ref" => "DICOS",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.501.2.2" => {
    "sopcl_desc" => "DICOS Digital X-Ray Image Storage - For Processing",
    "std_ref" => "DICOS",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.501.3" => {
    "sopcl_desc" => "DICOS Threat Detection Report Storage",
    "std_ref" => "DICOS",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.501.4" => {
    "sopcl_desc" => "DICOS 2D AIT Storage",
    "std_ref" => "DICOS",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.501.5" => {
    "sopcl_desc" => "DICOS 3D AIT Storage",
    "std_ref" => "DICOS",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.501.6" => {
    "sopcl_desc" => "DICOS Quadrupole Resonance (QR) Storage",
    "std_ref" => "DICOS",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.6" => {
    "retired" => "1",
    "sopcl_desc" => "Ultrasound Image Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.6.1" => {
    "sopcl_desc" => "Ultrasound Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.6.2" => {
    "sopcl_desc" => "Enhanced US Volume Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.601.1" => {
    "sopcl_desc" => "Eddy Current Image Storage",
    "std_ref" => "DICONDE ASTM E2934",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.601.2" => {
    "sopcl_desc" => "Eddy Current Multi-frame Image Storage",
    "std_ref" => "DICONDE ASTM E2934",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.66" => {
    "sopcl_desc" => "Raw Data Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.66.1" => {
    "sopcl_desc" => "Spatial Registration Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.66.2" => {
    "sopcl_desc" => "Spatial Fiducials Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.66.3" => {
    "sopcl_desc" => "Deformable Spatial Registration Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.66.4" => {
    "sopcl_desc" => "Segmentation Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.66.5" => {
    "sopcl_desc" => "Surface Segmentation Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.67" => {
    "sopcl_desc" => "Real World Value Mapping Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.68.1" => {
    "sopcl_desc" => "Surface Scan Mesh Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.68.2" => {
    "sopcl_desc" => "Surface Scan Point Cloud Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.7" => {
    "sopcl_desc" => "Secondary Capture Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.7.1" => {
    "sopcl_desc" => "Multi-frame Single Bit Secondary Capture Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.7.2" => {
    "sopcl_desc" => "Multi-frame Grayscale Byte Secondary Capture Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.7.3" => {
    "sopcl_desc" => "Multi-frame Grayscale Word Secondary Capture Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.7.4" => {
    "sopcl_desc" => "Multi-frame True Color Secondary Capture Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1" => {
    "retired" => "1",
    "sopcl_desc" => "VL Image Storage - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.1" => {
    "sopcl_desc" => "VL Endoscopic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.1.1" => {
    "sopcl_desc" => "Video Endoscopic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.2" => {
    "sopcl_desc" => "VL Microscopic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.2.1" => {
    "sopcl_desc" => "Video Microscopic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.3" => {
    "sopcl_desc" => "VL Slide-Coordinates Microscopic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.4" => {
    "sopcl_desc" => "VL Photographic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.4.1" => {
    "sopcl_desc" => "Video Photographic Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.5.1" => {
    "sopcl_desc" => "Ophthalmic Photography 8 Bit Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.5.2" => {
    "sopcl_desc" => "Ophthalmic Photography 16 Bit Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.5.3" => {
    "sopcl_desc" => "Stereometric Relationship Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.5.4" => {
    "sopcl_desc" => "Ophthalmic Tomography Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.1.6" => {
    "sopcl_desc" => "VL Whole Slide Microscopy Image Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.77.2" => {
    "retired" => "1",
    "sopcl_desc" => "VL Multi-frame Image Storage - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.78.1" => {
    "sopcl_desc" => "Lensometry Measurements Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.78.2" => {
    "sopcl_desc" => "Autorefraction Measurements Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.78.3" => {
    "sopcl_desc" => "Keratometry Measurements Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.78.4" => {
    "sopcl_desc" => "Subjective Refraction Measurements Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.78.5" => {
    "sopcl_desc" => "Visual Acuity Measurements Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.78.6" => {
    "sopcl_desc" => "Spectacle Prescription Report Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.78.7" => {
    "sopcl_desc" => "Ophthalmic Axial Measurements Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.78.8" => {
    "sopcl_desc" => "Intraocular Lens Calculations Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.79.1" => {
    "sopcl_desc" => "Macular Grid Thickness and Volume Report Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.8" => {
    "retired" => "1",
    "sopcl_desc" => "Standalone Overlay Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.80.1" => {
    "sopcl_desc" => "Ophthalmic Visual Field Static Perimetry Measurements Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.81.1" => {
    "sopcl_desc" => "Ophthalmic Thickness Map Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.1" => {
    "retired" => "1",
    "sopcl_desc" => "Text SR Storage - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.11" => {
    "sopcl_desc" => "Basic Text SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.2" => {
    "retired" => "1",
    "sopcl_desc" => "Audio SR Storage - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.22" => {
    "sopcl_desc" => "Enhanced SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.3" => {
    "retired" => "1",
    "sopcl_desc" => "Detail SR Storage - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.33" => {
    "sopcl_desc" => "Comprehensive SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.34" => {
    "sopcl_desc" => "Comprehensive 3D SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.4" => {
    "retired" => "1",
    "sopcl_desc" => "Comprehensive SR Storage - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.40" => {
    "sopcl_desc" => "Procedure Log Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.50" => {
    "sopcl_desc" => "Mammography CAD SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.59" => {
    "sopcl_desc" => "Key Object Selection Document Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.71" => {
    "sopcl_desc" => "Acquisition Context SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.65" => {
    "sopcl_desc" => "Chest CAD SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.67" => {
    "sopcl_desc" => "X-Ray Radiation Dose SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.69" => {
    "sopcl_desc" => "Colon CAD SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.88.70" => {
    "sopcl_desc" => "Implantation Plan SR Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9" => {
    "retired" => "1",
    "sopcl_desc" => "Standalone Curve Storage ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.1" => {
    "retired" => "1",
    "sopcl_desc" => "Waveform Storage - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.1.1" => {
    "sopcl_desc" => "12-lead ECG Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.1.2" => {
    "sopcl_desc" => "General ECG Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.1.3" => {
    "sopcl_desc" => "Ambulatory ECG Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.2.1" => {
    "sopcl_desc" => "Hemodynamic Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.3.1" => {
    "sopcl_desc" => "Cardiac Electrophysiology Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.4.1" => {
    "sopcl_desc" => "Basic Voice Audio Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.4.2" => {
    "sopcl_desc" => "General Audio Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.5.1" => {
    "sopcl_desc" => "Arterial Pulse Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.9.6.1" => {
    "sopcl_desc" => "Respiratory Waveform Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.1.1" => {
    "sopcl_desc" => "Patient Root Query/Retrieve Information Model - FIND",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.1.2" => {
    "sopcl_desc" => "Patient Root Query/Retrieve Information Model - MOVE",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.1.3" => {
    "sopcl_desc" => "Patient Root Query/Retrieve Information Model - GET",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.2.1" => {
    "sopcl_desc" => "Study Root Query/Retrieve Information Model - FIND",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.2.2" => {
    "sopcl_desc" => "Study Root Query/Retrieve Information Model - MOVE",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.2.3" => {
    "sopcl_desc" => "Study Root Query/Retrieve Information Model - GET",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.3.1" => {
    "retired" => "1",
    "sopcl_desc" => "Patient/Study Only Query/Retrieve Information Model - FIND ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.3.2" => {
    "retired" => "1",
    "sopcl_desc" => "Patient/Study Only Query/Retrieve Information Model - MOVE ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.3.3" => {
    "retired" => "1",
    "sopcl_desc" => "Patient/Study Only Query/Retrieve Information Model - GET ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.4.2" => {
    "sopcl_desc" => "Composite Instance Root Retrieve - MOVE",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.4.3" => {
    "sopcl_desc" => "Composite Instance Root Retrieve - GET",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.5.3" => {
    "sopcl_desc" => "Composite Instance Retrieve Without Bulk Data - GET",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.31" => {
    "sopcl_desc" => "Modality Worklist Information Model - FIND",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.32" => {
    "retired" => "1",
    "sopcl_desc" => "General Purpose Worklist Management Meta SOP Class ",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.5.1.4.32.1" => {
    "retired" => "1",
    "sopcl_desc" => "General Purpose Worklist Information Model - FIND ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.32.2" => {
    "retired" => "1",
    "sopcl_desc" => "General Purpose Scheduled Procedure Step SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.32.3" => {
    "retired" => "1",
    "sopcl_desc" => "General Purpose Performed Procedure Step SOP Class ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.33" => {
    "sopcl_desc" => "Instance Availability Notification SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.1" => {
    "retired" => "1",
    "sopcl_desc" => "RT Beams Delivery Instruction Storage - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.2" => {
    "retired" => "1",
    "sopcl_desc" => "RT Conventional Machine Verification - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.3" => {
    "retired" => "1",
    "sopcl_desc" => "RT Ion Machine Verification - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.4" => {
    "retired" => "1",
    "sopcl_desc" => "Unified Worklist and Procedure Step Service Class - Trial ",
    "type" => "Service Class"
  },
  "1.2.840.10008.5.1.4.34.4.1" => {
    "retired" => "1",
    "sopcl_desc" => "Unified Procedure Step - Push SOP Class - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.4.2" => {
    "retired" => "1",
    "sopcl_desc" => "Unified Procedure Step - Watch SOP Class - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.4.3" => {
    "retired" => "1",
    "sopcl_desc" => "Unified Procedure Step - Pull SOP Class - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.4.4" => {
    "retired" => "1",
    "sopcl_desc" => "Unified Procedure Step - Event SOP Class - Trial ",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.5" => {
    "sopcl_desc" => "Unified Worklist and Procedure Step SOP Instance",
    "type" => "Well-known SOP Instance"
  },
  "1.2.840.10008.5.1.4.34.6" => {
    "sopcl_desc" => "Unified Worklist and Procedure Step Service Class",
    "type" => "Service Class"
  },
  "1.2.840.10008.5.1.4.34.6.1" => {
    "sopcl_desc" => "Unified Procedure Step - Push SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.6.2" => {
    "sopcl_desc" => "Unified Procedure Step - Watch SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.6.3" => {
    "sopcl_desc" => "Unified Procedure Step - Pull SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.6.4" => {
    "sopcl_desc" => "Unified Procedure Step - Event SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.7" => {
    "sopcl_desc" => "RT Beams Delivery Instruction Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.8" => {
    "sopcl_desc" => "RT Conventional Machine Verification",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.34.9" => {
    "sopcl_desc" => "RT Ion Machine Verification",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.37.1" => {
    "sopcl_desc" => "General Relevant Patient Information Query",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.37.2" => {
    "sopcl_desc" => "Breast Imaging Relevant Patient Information Query",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.37.3" => {
    "sopcl_desc" => "Cardiac Relevant Patient Information Query",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.38.1" => {
    "sopcl_desc" => "Hanging Protocol Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.38.2" => {
    "sopcl_desc" => "Hanging Protocol Information Model - FIND",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.38.3" => {
    "sopcl_desc" => "Hanging Protocol Information Model - MOVE",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.38.4" => {
    "sopcl_desc" => "Hanging Protocol Information Model - GET",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.39.1" => {
    "sopcl_desc" => "Color Palette Storage",
    "type" => "Transfer"
  },
  "1.2.840.10008.5.1.4.39.2" => {
    "sopcl_desc" => "Color Palette Information Model - FIND",
    "type" => "Query/Retrieve"
  },
  "1.2.840.10008.5.1.4.39.3" => {
    "sopcl_desc" => "Color Palette Information Model - MOVE",
    "type" => "Query/Retrieve"
  },
  "1.2.840.10008.5.1.4.39.4" => {
    "sopcl_desc" => "Color Palette Information Model - GET",
    "type" => "Query/Retrieve"
  },
  "1.2.840.10008.5.1.4.41" => {
    "sopcl_desc" => "Product Characteristics Query SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.42" => {
    "sopcl_desc" => "Substance Approval Query SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.43.1" => {
    "sopcl_desc" => "Generic Implant Template Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.43.2" => {
    "sopcl_desc" => "Generic Implant Template Information Model - FIND",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.43.3" => {
    "sopcl_desc" => "Generic Implant Template Information Model - MOVE",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.43.4" => {
    "sopcl_desc" => "Generic Implant Template Information Model - GET",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.44.1" => {
    "sopcl_desc" => "Implant Assembly Template Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.44.2" => {
    "sopcl_desc" => "Implant Assembly Template Information Model - FIND",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.44.3" => {
    "sopcl_desc" => "Implant Assembly Template Information Model - MOVE",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.44.4" => {
    "sopcl_desc" => "Implant Assembly Template Information Model - GET",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.45.1" => {
    "sopcl_desc" => "Implant Template Group Storage",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.45.2" => {
    "sopcl_desc" => "Implant Template Group Information Model - FIND",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.45.3" => {
    "sopcl_desc" => "Implant Template Group Information Model - MOVE",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.45.4" => {
    "sopcl_desc" => "Implant Template Group Information Model - GET",
    "type" => "SOP Class"
  },
  "1.2.840.10008.7.1.1" => {
    "sopcl_desc" => "Native DICOM Model",
    "type" => "Application Hosting Model"
  },
  "1.2.840.10008.7.1.2" => {
    "sopcl_desc" => "Abstract Multi-Dimensional Image Model",
    "type" => "Application Hosting Model"
  },
  "1.2.840.10008.3.1.2.3.3" => {
    "sopcl_desc" => "Modality Performed Procedure Step SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.3.4" => {
    "sopcl_desc" => "Modality Performed Procedure Step Retrieve SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.3.5" => {
    "sopcl_desc" => "Modality Performed Procedure Step Notification SOP Class",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.1.82.1" => {
    "sopcl_desc" => "Corneal Topography Map Storage",
    "type" => "SOP Class"
  }
};
my $DefaultPrivateGroupTags = {
#  16 => "NIRS_Melco",
};
my $ReverseDefaultPrivateGroupTags = {
#  "NIRS_Melco" => 16,
};
sub add_default_private_mapping{
  my($num, $name) = @_;
  unless($num > 0 && $num <256) { die "invalid private mapping: $num" }
  $DefaultPrivateGroupTags->{$num} = $name;
  $ReverseDefaultPrivateGroupTags->{$name} = $num;
}
sub new {
  my($class) = @_;
  my $this = {};
  $this->{VRDesc} = $VRDesc;
  $this->{XferSyntax} = $XferSyntax;
  $this->{Dict} = $Dict;
  $this->{SopCl} = $SopCl;
  $this->{PvtDict} = $PvtDict;
  $this->{DefaultPrivateGroupTags} = $DefaultPrivateGroupTags;
  $this->{ReverseDefaultPrivateGroupTags} = $ReverseDefaultPrivateGroupTags;
  return bless $this, $class;
}
sub GetSopClName{
  my($dd, $sop_cl) = @_;
  if(exists $dd->{SopCl}->{$sop_cl}){
    return $dd->{SopCl}->{$sop_cl}->{sopcl_desc};
  } else {
    return undef;
  }
}
sub GetXferStxName{
  my($dd, $xfr_stx) = @_;
  if(exists($dd->{XferSyntax}->{$xfr_stx})){
    return $dd->{XferSyntax}->{$xfr_stx}->{name};
  }
  return undef;
}
sub get_vr{
  my($dd, $grp, $ele) = @_;
  my $ent = $dd->{Dict}->{$grp}->{$ele};
  unless(defined($ent) && defined($ent->{VR})){
    return "UN";
  }
  return $ent->{VR}
}
sub get_pvt_vr{
  my($dd, $grp, $owner, $ele) = @_;
  my $ent = $dd->{PvtDict}->{$owner}->{$grp}->{$ele};
  unless(defined($ent) && defined($ent->{VR})){
    return "UN";
  }
  return $ent->{VR}
};
sub get_pvt_type{
  my($dd, $grp, $owner, $ele) = @_;
  my $ent = $dd->{PvtDict}->{$owner}->{$grp}->{$ele};
  my $vr = "UN";
  if(defined($ent) && defined($ent->{VR})){
    $vr = $ent->{VR};
#  } else {
#    printf "(%04x,\"$owner\", %0x2) is unknown\n", $grp, $ele;
  }
  my $desc = $VRDesc->{$vr};
  return $desc->{type};
};
sub get_type{
  my($dd, $grp, $ele) = @_;
  my $ent = $dd->{Dict}->{$grp}->{$ele};
  my $vr = "UN";
  if(defined($ent) && defined($ent->{VR})){
    $vr = $ent->{VR};
  }
  my $desc = $VRDesc->{$vr};
  return $desc->{type};
}
sub get_ele_by_sig{
  my($dd, $sig) = @_;
  my $ret;
  if($sig =~ /\(([0-9a-fA-F]{4}),([0-9a-fA-F]{4})\)$/){
    my $grp = hex($1);
    if($grp & 1){
      return undef;
    }
    my $ele = hex($2);
    $ret = $dd->{Dict}->{$grp}->{$ele};
  } elsif ($sig =~ /\(([0-9a-fA-F]{4}),\"([^\"]*)\",([0-9a-fA-F]{2})\)$/){
    my $grp = hex($1);
    my $owner = $2;
    my $ele = hex($3);
    if(exists $dd->{PvtDict}->{$owner}->{$grp}->{$ele}){
      $ret = $dd->{PvtDict}->{$owner}->{$grp}->{$ele};
    } else {
      $ret = undef;
    }
  } else {
    die "non-matching sig: $sig";
  }
  return $ret;
}
sub get_type_by_sig{
  my($dd, $sig) = @_;
  my $ent;
  if($sig =~ /\(([0-9a-fA-F]{4}),([0-9a-fA-F]{4})\)$/){
    my $grp = hex($1);
    my $ele = hex($2);
    $ent = $dd->{Dict}->{$grp}->{$ele};
  } elsif($sig =~ /\(([0-9a-fA-F]{4}),([0-9a-fA-F]{4})\)\[\d+\]$/){
    my $grp = hex($1);
    my $ele = hex($2);
    $ent = $dd->{Dict}->{$grp}->{$ele};
  } elsif ($sig =~ /\(([0-9a-fA-F]{4}),\"([^\"]*)\",([0-9a-fA-F]{2})\)$/){
    my $grp = hex($1);
    my $owner = $2;
    my $ele = hex($3);
    $ent = $dd->{PvtDict}->{$owner}->{$grp}->{$ele};
  } elsif (
    $sig =~ /\(([0-9a-fA-F]{4}),\"([^\"]*)\",([0-9a-fA-F]{2})\)\[\d+\]$/
  ){
    my $grp = hex($1);
    my $owner = $2;
    my $ele = hex($3);
    $ent = $dd->{PvtDict}->{$owner}->{$grp}->{$ele};
  } else {
    die "non-matching sig: $sig";
  }
  my $vr = 'UN';
  if(defined($ent) && defined($ent->{VR})){
    $vr = $ent->{VR};
  }
  my $desc = $VRDesc->{$vr};
  return $desc->{type};
}
sub GetSopClassPrefix {
  my($sop_class) = @_;
  unless(exists $SopCl->{$sop_class}) { return "UN" }
  my $sop_desc = $SopCl->{$sop_class};
  if(exists $sop_desc->{prefix}) { return $sop_desc->{prefix} };
  $sop_desc = $sop_desc->{sopcl_desc};
  if($sop_desc =~ /CT/){ return "CT"}
  if($sop_desc =~ /MR/){ return "MR"}
  if($sop_desc =~ /SR/){ return "SR"}
  if($sop_desc =~ /RT Image/){ return "RTI"}
  if($sop_desc =~ /RT Dose/){ return "RTD"}
  if($sop_desc =~ /RT Struct/){ return "RTS"}
  if($sop_desc =~ /RT Beams Treat/){ return "RTR"}
  if($sop_desc =~ /RT Brachy Treat/){ return "RTR"}
  if($sop_desc =~ /RT Plan/){ return "RTP"}
  if($sop_desc =~ /RT Treat/){ return "RTR"}
  if($sop_desc =~ /RT Ion Plan/){ return "RTP"}
  if($sop_desc =~ /RT Ion Beams Treat/){ return "RTR"}
  if($sop_desc =~ /Positron/){ return "PT"}
  if($sop_desc =~ /Ultrasound/){ return "US"}
  if($sop_desc =~ /Registration/){ return "REG"}
  return "OT";
}
1;
