#
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::DataDict;
use vars qw($Dict $PvtDict $VRDesc $XferSyntax $SopCl
   $DefaultPrivateGroupTags $ReverseDefaultPrivateGroupTags);
$Dict = {
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
};
require Posda::PubDataDict;
require Posda::PvtDataDict;
#require Posda::CmdDataDict; #to do
#require Posda::DirDataDict; #to do
#require Posda::VrDataDict; #to do
$VRDesc = {
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
    name => "Other Float",
    type => "raw",
  },
  OD => {
    name => "Other Double",
    type => "raw",
  },
  OT => {
    name => "Other",
    type => "raw",
  },
  OV => {
    name => "Other Very Long",
    type => "raw",
  },
  OL => {
    name => "Other Long",
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
  SV => {
    name => "Signed Very Long",
    len => "8",
    type => "sverylong",
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
  UV => {
    name => "Signed Very Long",
    len => "8",
    type => "uverylong",
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
$XferSyntax = {
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
$SopCl = {
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
    "sopcl_desc" => "Storage Commitment Pull Model SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.1.20.2.1" => {
    "retired" => "1",
    "sopcl_desc" => "Storage Commitment Pull Model SOP Instance - Retired",
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
    "sopcl_desc" => "Basic Study Content Notification SOP Class - Retired",
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
    "sopcl_desc" => "Detached Patient Management SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.1.4" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Patient Management Meta SOP Class - Retired",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.3.1.2.2.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Visit Management SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.3.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Study Management SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.3.2" => {
    "retired" => "1",
    "sopcl_desc" => "Study Component Management SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.5.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Results Management SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.3.1.2.5.4" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Results Management Meta SOP Class - Retired",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.3.1.2.5.5" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Study Management Meta SOP Class - Retired",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.3.1.2.6.1" => {
    "retired" => "1",
    "sopcl_desc" => "Detached Interpretation Management SOP Class - Retired",
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
    "sopcl_desc" => "Referenced Color Print Management Meta SOP Class - Retired",
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
    "sopcl_desc" => "Image Overlay Box SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.24.1" => {
    "retired" => "1",
    "sopcl_desc" => "Basic Print Image Overlay Box SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.25" => {
    "retired" => "1",
    "sopcl_desc" => "Print Queue SOP Instance - Retired",
    "type" => "Well-known Print Queue SOP Instance"
  },
  "1.2.840.10008.5.1.1.26" => {
    "retired" => "1",
    "sopcl_desc" => "Print Queue Management SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.27" => {
    "retired" => "1",
    "sopcl_desc" => "Stored Print Storage SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.29" => {
    "retired" => "1",
    "sopcl_desc" => "Hardcopy Grayscale Image Storage SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.30" => {
    "retired" => "1",
    "sopcl_desc" => "Hardcopy Color Image Storage SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.31" => {
    "retired" => "1",
    "sopcl_desc" => "Pull Print Request SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.32" => {
    "retired" => "1",
    "sopcl_desc" => "Pull Stored Print Management Meta SOP Class - Retired",
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
    "sopcl_desc" => "Referenced Image Box SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.1.9" => {
    "sopcl_desc" => "Basic Grayscale Print Management Meta SOP Class",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.5.1.1.9.1" => {
    "retired" => "1",
    "sopcl_desc" => "Referenced Grayscale Print Management Meta SOP Class - Retired",
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
    "sopcl_desc" => "Standalone Modality LUT Storage - Retired",
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
    "sopcl_desc" => "Standalone VOI LUT Storage - Retired",
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
    "sopcl_desc" => "X-Ray Angiographic Bi-Plane Image Storage - Retired",
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
    "sopcl_desc" => "Standalone PET Curve Storage - Retired",
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
    "sopcl_desc" => "Ultrasound Multi-frame Image Storage - Retired",
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
    "sopcl_desc" => "Nuclear Medicine Image Storage - Retired",
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
    "sopcl_desc" => "Ultrasound Image Storage - Retired",
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
    "sopcl_desc" => "VL Image Storage - Trial - Retired",
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
    "sopcl_desc" => "Standalone Overlay Storage - Retired",
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
    "sopcl_desc" => "Standalone Curve Storage - Retired",
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
    "sopcl_desc" => "Patient/Study Only Query/Retrieve Information Model - FIND - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.3.2" => {
    "retired" => "1",
    "sopcl_desc" => "Patient/Study Only Query/Retrieve Information Model - MOVE - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.1.2.3.3" => {
    "retired" => "1",
    "sopcl_desc" => "Patient/Study Only Query/Retrieve Information Model - GET - Retired",
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
    "sopcl_desc" => "General Purpose Worklist Management Meta SOP Class - Retired",
    "type" => "Meta SOP Class"
  },
  "1.2.840.10008.5.1.4.32.1" => {
    "retired" => "1",
    "sopcl_desc" => "General Purpose Worklist Information Model - FIND - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.32.2" => {
    "retired" => "1",
    "sopcl_desc" => "General Purpose Scheduled Procedure Step SOP Class - Retired",
    "type" => "SOP Class"
  },
  "1.2.840.10008.5.1.4.32.3" => {
    "retired" => "1",
    "sopcl_desc" => "General Purpose Performed Procedure Step SOP Class - Retired",
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
$DefaultPrivateGroupTags = {
#  16 => "NIRS_Melco",
};
$ReverseDefaultPrivateGroupTags = {
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
sub GetSopClassFromName{
  my($dd, $sopcl_desc) = @_;
  for my $i (keys %$SopCl){
    if($SopCl->{$i}->{sopcl_desc} eq $sopcl_desc){
      return $i;
    }
  }
  return undef;
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
