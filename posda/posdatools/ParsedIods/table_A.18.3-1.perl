pst012345678   .   GCan't handle table_8.8-1 (in table_C.7-1:table_10-18 after (0040,0039))GCan't handle table_8.8-1 (in table_C.7-1:table_10-18 after (0040,003A))GCan't handle table_8.8-1 (in table_C.7-1:table_10-18 after (0040,0039))GCan't handle table_8.8-1 (in table_C.7-1:table_10-18 after (0040,003A));Can't handle table_8.8-1 (in table_C.7-1 after (0010,2202));Can't handle table_8.8-1 (in table_C.7-1 after (0010,2293));Can't handle table_8.8-1 (in table_C.7-1 after (0010,2296));Can't handle table_8.8-1 (in table_C.7-1 after (0012,0064))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0040,1101))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0008,0082))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0040,1101))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0008,0082))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0040,1101))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0008,0082));Can't handle table_8.8-1 (in table_C.7-3 after (0032,1034));Can't handle table_8.8-1 (in table_C.7-3 after (0008,1032));Can't handle table_8.8-1 (in table_C.7-3 after (0040,1012))<Can't handle table_8.8-1 (in table_C.7-4a after (0008,1084))<Can't handle table_8.8-1 (in table_C.7-4a after (0010,1021))<Can't handle table_8.8-1 (in table_C.8-37 after (0008,103F))GCan't handle table_8.8-1 (in table_C.8-37:table_10-9 after (0032,1064))GCan't handle table_8.8-1 (in table_C.8-37:table_10-9 after (0040,100A))GCan't handle table_8.8-1 (in table_C.8-37:table_10-9 after (0040,0008))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,A043))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,A168))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,08EA))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,A043))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,A168))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,08EA))HCan't handle table_8.8-1 (in table_C.8-37:table_10-16 after (0040,0260))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,A043))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,A168))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,08EA))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,A043))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,A168))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,08EA));Can't handle table_8.8-1 (in table_C.7-9 after (0040,A170));Can't handle table_8.8-1 (in table_C.7-9 after (0008,9215));Can't handle table_8.8-1 (in table_C.7-9 after (0040,A170));Can't handle table_8.8-1 (in table_C.7-9 after (0040,A170))NCan't handle table_8.8-1 (in table_C.7-9:table_C.7.6.16-12b after (0040,08EA))<Can't handle table_8.8-1 (in table_C.8-41 after (0008,9215))<Can't handle table_8.8-1 (in table_C.12-1 after (0040,A170))GCan't handle table_8.8-1 (in table_C.12-1:table_10-1 after (0040,1101))GCan't handle table_8.8-1 (in table_C.12-1:table_10-1 after (0008,0082))ICan't handle table_8.8-1 (in table_C.12-1:table_C.12-6 after (0400,0401))   errors ;     
M   usage   
table_C.7-1table_10-11
   mod_tables
Patient   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Patient   module   (0008,1120)[<0>](0008,1150)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-41
table_10-3
   mod_tables
Dose   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
Structure Set   moduleK   (3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)[<3>](0008,1160)   
M   usage   
table_C.7-1
   mod_tables
Patient   entity3   req   XThe true identity of the patient has been removed from the Attributes and the Pixel Data   
variablelist   typeEnumerated Values:   title      YES   NO   list   descPatient Identity Removed   name
Patient   module   (0012,0062)   
M   usage    _
   mod_tables
Patient   entity3   req   �A sequence of identification numbers or codes used to identify the patient, which may or may not be human readable, and may or may not have been obtained from an implanted or attached device such as an RFID or barcode.1One or more Items are permitted in this sequence.   descOther Patient IDs Sequence   name
Patient   module   (0010,1002)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-41
   mod_tables
Dose   entity3   req;User-defined description of technique used to generate ROI.   descROI Generation Description   name
Structure Set   module   (3006,0020)[<0>](3006,0038)   
U   usage   
table_C.8-40
   mod_tables
Dose   entity1   req   �Sequence of one class/instance pair describing Structure Set containing structures that are used to calculate Dose-Volume Histograms (DVHs).   ;Only a single item shall be included in this sequence. See        select: label	   xrefstylesect_C.8.8.4.1   linkend   attrsxref   el.   desc!Referenced Structure Set Sequence   name
RT DVH   module   (300c,0060)   
M   usage   
table_C.7-3
table_10-1
   mod_tables
Study   entity3   reqtMailing address of the institution or organization to which the identified individual is responsible or accountable.   descInstitution Address   name
General Study   module   (0008,1049)[<0>](0008,0081)   
M   usage   
table_C.7-3
table_10-1
   mod_tables
Study   entity3   reqtMailing address of the institution or organization to which the identified individual is responsible or accountable.   descInstitution Address   name
General Study   module   (0008,0096)[<0>](0008,0081)   
M   usage   
table_C.7-1table_10-18
   mod_tables
Patient   entity3   req   AType of Patient ID. Refer to HL7 v2 Table 0203 for Defined Terms.      
                      ;Equivalent to HL7 v2 CX component 5 (Identifier Type Code).   contentpara   el
                 contentnote   el   descIdentifier Type Code   name
Patient   module+   (0010,1002)[<0>](0010,0024)[<1>](0040,0035)   
M   usage   
table_C.7-3
   mod_tables
Study   entity3   req   FA sequence that provides reference to a Study SOP Class/Instance pair.1One or more Items are permitted in this Sequence.   See        select: label	   xrefstylesect_10.6.1   linkend   attrsxref   el.   descReferenced Study Sequence   name
General Study   module   (0008,1110)   
M   usage   
table_C.8-37
table_10-9
table_10-2
   mod_tables
Series   entity1C   req   ,Coded concept value of this name-value Item.6Only a single Item shall be included in this Sequence.+Required if Value Type (0040,A040) is CODE.   descConcept Code Sequence   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a168)   
M   usage    �
   mod_tables
Study   entity2   req?A RIS generated number that identifies the order for the Study.   descAccession Number   name
General Study   module   (0008,0050)   
U   usage    �
   mod_tables
Dose   entity1   req�Scaling factor that when multiplied by the dose bin widths found in DVH Data (3004,0058), yields dose bin widths in the dose units as specified by Dose Units (3004,0002).   descDVH Dose Scaling   name
RT DVH   module   (3004,0050)[<0>](3004,0052)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-11b
   mod_tables
Dose   entity1C   req   �Specifies the format of the Green Palette Color Lookup Table Data (0028,1202). Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.5   linkend   attrsxref   el for further explanation.   desc+Green Palette Color Lookup Table Descriptor   name
Image Pixel   module   (0028,1102)   
M   usage   
table_C.12-1
table_10-3
   mod_tables
Dose   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name

SOP Common   module   (0020,9172)[<0>](0062,000b)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-9
   mod_tables
Dose   entity2C   req      �Patient direction of the rows and columns of the image. Required if image does not require Image Orientation (Patient) (0020,0037) and Image Position (Patient) (0020,0032). May be present otherwise. See        select: label	   xrefstylesect_C.7.6.1.1.1   linkend   attrsxref   el for further explanation.      
                          �IODs may have attributes other than Patient Orientation, Image Orientation, or Image Position (Patient) to describe orientation in which case this attribute will be zero length.   contentpara   el
                     contentnote   el   descPatient Orientation   name
General Image   module   (0020,0020)   
M   usage    �
   mod_tables
Study   entity3   req   8A Sequence that conveys the type of procedure performed.1One or more Items are permitted in this Sequence.   descProcedure Code Sequence   name
General Study   module   (0008,1032)   
M   usage   
table_C.8-37
table_10-9
   mod_tables
Series   entity3   req   }Sequence that specifies modifiers for a Protocol Context Content Item. One or more Items are permitted in this sequence. See        select: label	   xrefstylesect_C.4.10.1   linkend   attrsxref   el.   descContent Item Modifier Sequence   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)   
M   usage   
table_C.8-39
   mod_tables
Dose   entity1   req  Uniquely identifies Brachy Application Setup specified by Brachy Application Setup Number (300A,0234) in Brachy Application Setup Sequence (300A,0230) of RT Brachy Application Setups Module within RT Plan referenced in Referenced RT Plan Sequence (300C,0002).   desc*Referenced Brachy Application Setup Number   name
RT Dose   module;   (300c,0002)[<0>](300c,0020)[<1>](300c,000a)[<2>](300c,000c)   
M   usage   
table_C.7-3
table_10-1
   mod_tables
Study   entity3   reqtMailing address of the institution or organization to which the identified individual is responsible or accountable.   descInstitution Address   name
General Study   module   (0008,1062)[<0>](0008,0081)   
M   usage    �
   mod_tables
Study   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name
General Study   module   (0008,0096)[<0>](0008,0082)   
M   usage    �
   mod_tables
Series   entity1C   req   $Date value for this name-value Item.+Required if Value Type (0040,A040) is DATE.   descDate   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a121)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-9table_C.7-11b
   mod_tables
Dose   entity1   req   ZMost significant bit for pixel sample data. Each sample shall have the same high bit. See        PS3.5	   targetdocselect: labelnumber	   xrefstylePS3.5	   targetptr   attrsolink   el for further explanation.   descHigh Bit   name
General Image   module   (0088,0200)[<0>](0028,0102)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-9
table_10-3
   mod_tables
Dose   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
General Image   module   (0008,1140)[<0>](0008,1160)   
U   usage    �
   mod_tables
Dose   entity1   req   Type of DVH.   
variablelist   typeEnumerated Values:   title      DIFFERENTIAL"differential dose-volume histogram   
CUMULATIVE cumulative dose-volume histogram   NATURALnatural dose volume histogram   list   descDVH Type   name
RT DVH   module   (3004,0050)[<0>](3004,0001)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-9
table_10-3table_10-11
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
General Image   module   (0008,2112)[<0>](0008,1155)   
M   usage   
table_C.8-39table_10-11
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
RT Dose   module   (300c,0002)[<0>](0008,1155)   
M   usage    �
   mod_tables
Patient   entity3   req   �The geo-political body that assigned the patient identifier. Typically a code for a country or a state/province. Only a single Item is permitted in this sequence.      
                      ;Equivalent to HL7 v2 CX component 9 (Identifier Type Code).   contentpara   el
                 contentnote   el   desc$Assigning Jurisdiction Code Sequence   name
Patient   module+   (0010,1002)[<0>](0010,0024)[<1>](0040,0039)   
U   usage    �
   mod_tables
Dose   entity1   req   Dose axis units.   
variablelist   typeEnumerated Values:   title      GYGray   RELATIVEVdose relative to reference value specified in DVH Normalization Dose Value (3004,0042)   list   desc
Dose Units   name
RT DVH   module   (3004,0050)[<0>](3004,0002)   
M   usage   
table_C.8-37
table_10-9table_10-11
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   module+   (0040,0275)[<0>](0008,1110)[<1>](0008,1150)   
U   usage   
table_C.7-4a
   mod_tables
Study   entity3   reqHIdentifier of the Service Episode as assigned by the healthcare provider   descService Episode ID   name
Patient Study   module   (0038,0060)   
M   usage   
table_C.12-1
   mod_tables
Dose   entity3   reqkName of the organization responsible for the Coding Scheme. May include organizational contact information.   desc&Coding Scheme Responsible Organization   name

SOP Common   module   (0008,0110)[<0>](0008,0116)   
M   usage   c
   mod_tables
Dose   entity3   reqVInstitution where the equipment that contributed to the composite instance is located.   descInstitution Name   name

SOP Common   module   (0018,a001)[<0>](0008,0080)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-42
   mod_tables
Dose   entity3   req�Identification number of the contour. The value of Contour Number (3006,0048) shall be unique within the Contour Sequence (3006,0040) in which it is defined. No semantics or ordering shall be inferred from this attribute.   descContour Number   name
ROI Contour   module+   (3006,0039)[<0>](3006,0040)[<1>](3006,0048)   
M   usage   -
   mod_tables
Dose   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name

SOP Common   module   (0020,9172)[<0>](0008,1160)   
M   usage   
table_C.12-1
table_10-1
   mod_tables
Dose   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0080)   
M   usage   
table_C.12-1table_C.12-6
   mod_tables
Dose   entity1   req   �The Transfer Syntax UID used to encode the values of the Data Elements included in the MAC calculation. Only Transfer Syntaxes that explicitly include the VR and use Little Endian encoding shall be used.      
                            �Certain Transfer Syntaxes, particularly those that are used with compressed data, allow the fragmentation of the pixel data to change. If such fragmentation changes, Digital Signatures generated with such Transfer Syntaxes could become invalid.   contentpara   el
                       contentnote   el   desc#MAC Calculation Transfer Syntax UID   name

SOP Common   module   (4ffe,0001)[<0>](0400,0010)   
M   usage   
table_C.8-37
table_10-9
table_10-2
   mod_tables
Series   entity1C   req   ,Coded concept value of this name-value Item.6Only a single Item shall be included in this Sequence.+Required if Value Type (0040,A040) is CODE.   descConcept Code Sequence   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a168)   
U   usage   X
   mod_tables
Study   entity3   reqOccupation of the Patient.   desc
Occupation   name
Patient Study   module   (0010,2180)   
M   usage   c
   mod_tables
Dose   entity3   req   "Date the SOP Instance was created.xThis is the date that the SOP Instance UID was assigned, and does not change during subsequent coercion of the instance.   descInstance Creation Date   name

SOP Common   module   (0008,0012)   
M   usage   �
   mod_tables
Dose   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1101)   
M   usage   
table_C.8-37table_10-16
table_10-2
   mod_tables
Series   entity1   req   +Coded concept name of this name-value Item.6Only a single Item shall be included in this Sequence.   descConcept Name Code Sequence   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a043)   
M   usage   
table_C.7-1table_10-18
   mod_tables
Patient   entity3   req   oIdentifier of the Assigning Authority (system, organization, agency, or department) that issued the Patient ID.      
                      3Equivalent to HL7 v2 CX component 4 subcomponent 1.   contentpara   el
                 contentnote   el   descIssuer of Patient ID   name
Patient   module   (0010,0021)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-42
table_10-3
   mod_tables
Dose   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
ROI Contour   module;   (3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0062,000b)   
M   usage   
table_C.8-37
table_10-9
table_10-2table_10-11
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0008,1199)[<3>](0008,1155)   
M   usage   
table_C.8-37table_10-16
table_10-2
   mod_tables
Series   entity1C   req   �The floating point representation of Numeric Value (0040,A30A). The same number of values as Numeric Value (0040,A30A) shall be present.~Required if Numeric Value (0040,A30A) has insufficient precision to represent the value as a string. May be present otherwise.   descFloating Point Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a161)   
M   usage   
table_C.7-6
   mod_tables
Frame of Reference   entity1   req   =Uniquely identifies the frame of reference for a Series. See        select: label	   xrefstylesect_C.7.4.1.1.1   linkend   attrsxref   el for further explanation.   descFrame of Reference UID   name
Frame of Reference   module   (0020,0052)   
U   usage   
table_C.7-4b
   mod_tables
Study   entity1C   req   JThe type of distribution for which consent to distribute has been granted.   
variablelist   typeDefined Terms:   title      NAMED_PROTOCOL   RESTRICTED_REUSE   PUBLIC_RELEASE   list   See        select: label	   xrefstylesect_C.7.2.3.1.2   linkend   attrsxref   el.NRequired if Consent for Distribution Flag (0012,0085) equals YES or WITHDRAWN.   descDistribution Type   name
Clinical Trial Study   module   (0012,0083)[<0>](0012,0084)   
M   usage    �
   mod_tables
Patient   entity1C   req   |Standard defining the format of the Universal Entity ID (0040,0032). Required if Universal Entity ID (0040,0032) is present.      
                      GEquivalent to HL7 v2 CX component 4 subcomponent 3 (Universal ID Type).   contentpara   el
                 contentnote   el   See        select: label	   xrefstyle
sect_10.14   linkend   attrsxref   el for Defined Terms.   descUniversal Entity ID Type   name
Patient   module+   (0010,1002)[<0>](0010,0024)[<1>](0040,0033)   
U   usage   
table_C.12-8
   mod_tables
Dose   entity1   req   �Sequence of Items each providing a reference to an Instance that is part of the Series defined by Series Instance UID (0020,000E) in the enclosing Item.5One or more Items shall be included in this sequence.   descReferenced Instance Sequence   name
Common Instance Reference   module   (0008,1115)[<0>](0008,114a)   
M   usage   l
   mod_tables
Series   entity3   reqJThe unique identifier for the Study provided for this Requested Procedure.   descStudy Instance UID   name
	RT Series   module   (0040,0275)[<0>](0020,000d)   
U   usage   
table_C.7-2b
   mod_tables
Patient   entity1   req   'Identifier for the noted protocol. See        select: label	   xrefstylesect_C.7.1.3.1.2   linkend   attrsxref   el.   descClinical Trial Protocol ID   name
Clinical Trial Subject   module   (0012,0020)   
U   usage    �
   mod_tables
Dose   entity1   req4Number of bins n used to store DVH Data (3004,0058).   descDVH Number of Bins   name
RT DVH   module   (3004,0050)[<0>](3004,0056)   
U   usage    �
   mod_tables
Dose   entity1   req   Type of dose.   
variablelist   typeDefined Terms:   title      PHYSICALphysical dose   	EFFECTIVEZphysical dose after correction for biological effect using user-defined modeling technique   ERROR+difference between desired and planned dose   list   desc	Dose Type   name
RT DVH   module   (3004,0050)[<0>](3004,0004)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1C   req   �Green Palette Color Lookup Table Data. Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.6   linkend   attrsxref   el for further explanation.   desc%Green Palette Color Lookup Table Data   name
Image Pixel   module   (0028,1202)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   *Image identification characteristics. See        select: label	   xrefstylesect_C.7.6.1.1.2   linkend   attrsxref   el+ for Defined Terms and further explanation.   desc
Image Type   name
General Image   module   (0008,0008)   
U   usage   
table_C.12-8
table_10-4
   mod_tables
Dose   entity1   req   FSequence of Items each of which includes the Attributes of one Series.5One or more Items shall be included in this sequence.   descReferenced Series Sequence   name
Common Instance Reference   module   (0008,1200)[<0>](0008,1115)   
M   usage   c
   mod_tables
Dose   entity1   req   IDescribes the purpose for which the related equipment is being reference.6Only a single Item shall be included in this sequence.   See        select: label	   xrefstylesect_C.12.1.1.5   linkend   attrsxref   el for further explanation.   desc"Purpose of Reference Code Sequence   name

SOP Common   module   (0018,a001)[<0>](0040,a170)   
M   usage   �
   mod_tables
Series   entity1C   req   �The integer numerator of a rational representation of Numeric Value (0040,A30A). Encoded as a signed integer value. The same number of values as Numeric Value (0040,A30A) shall be present.�Required if Numeric Value (0040,A30A) has insufficient precision to represent a rational value as a string. May be present otherwise.   descRational Numerator Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a162)   
M   usage    _
   mod_tables
Patient   entity3   req$Ethnic group or race of the patient.   descEthnic Group   name
Patient   module   (0010,2160)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   �  Ratio of the vertical size and horizontal size of the pixels in the image specified by a pair of integer values where the first value is the vertical pixel size, and the second value is the horizontal pixel size. Required if the aspect ratio values do not have a ratio of 1:1 and the physical pixel spacing is not specified by Pixel Spacing (0028,0030), or Imager Pixel Spacing (0018,1164) or Nominal Scanned Pixel Spacing (0018,2010), either for the entire Image or per-frame in a Functional Group Macro. See        select: label	   xrefstylesect_C.7.6.3.1.7   linkend   attrsxref   el.   descPixel Aspect Ratio   name
General Image   module   (0088,0200)[<0>](0028,0034)   
M   usage    �
   mod_tables
Study   entity2   reqDate the Study started.   desc
Study Date   name
General Study   module   (0008,0020)   
U   usage   
table_C.11-1b
   mod_tables
Dose   entity1C   req   ZSpecifies the output units of Rescale Slope (0028,1053) and Rescale Intercept (0028,1052).   See        select: label	   xrefstylesect_C.11.1.1.2   linkend   attrsxref   el for further explanation.)Required if Rescale Intercept is present.   descRescale Type   name
Modality LUT   module   (0028,1054)   
M   usage   
table_C.7-8
   mod_tables
	Equipment   entity3   reqcDepartment in the institution where the equipment that produced the composite instances is located.   descInstitutional Department Name   name
General Equipment   module   (0008,1040)   
M   usage    _
   mod_tables
Patient   entity1   req>An identification number or code used to identify the patient.   desc
Patient ID   name
Patient   module   (0010,1002)[<0>](0010,0020)   
U   usage    �
   mod_tables
Dose   entity3   reqTMean calculated dose to ROI(s) described by DVH Referenced ROI Sequence (3004,0060).   descDVH Mean Dose   name
RT DVH   module   (3004,0050)[<0>](3004,0074)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity3   req9The maximum actual pixel value encountered in this image.   descLargest Image Pixel Value   name
General Image   module   (0088,0200)[<0>](0028,0107)   
M   usage    �
   mod_tables
Study   entity3   req   4Identification of the patient's referring physician.1Only a single item is permitted in this sequence.   desc+Referring Physician Identification Sequence   name
General Study   module   (0008,0096)   
M   usage   �
   mod_tables
Dose   entity1C   req   �The type of certified timestamp used in Certified Timestamp (0400,0310). Required if Certified Timestamp (0400,0310) is present.   Defined Terms:   title
variablelist   type      CMS_TSP<Internet X.509 Public Key Infrastructure Time Stamp Protocol   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descCertified Timestamp Type   name

SOP Common   module   (fffa,fffa)[<0>](0400,0305)   
M   usage   
table_C.8-37table_10-11
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   module   (0008,1111)[<0>](0008,1155)   
M   usage   c
   mod_tables
Dose   entity3   req   XUniquely identifies a Related General SOP Class for the SOP Class of this Instance. See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descRelated General SOP Class UID   name

SOP Common   module   (0008,001a)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity1   req      Geometric type of contour. See        select: label	   xrefstylesect_C.8.8.6.1   linkend   attrsxref   el.   
variablelist   typeEnumerated Values:   title      POINTsingle point   OPEN_PLANAR'open contour containing coplanar points   OPEN_NONPLANAR+open contour containing non-coplanar points   CLOSED_PLANAR3closed contour (polygon) containing coplanar points   list   descContour Geometric Type   name
ROI Contour   module+   (3006,0039)[<0>](3006,0040)[<1>](3006,0042)   
M   usage   =
   mod_tables
Series   entity1C   req   (DateTime value for this name-value Item./Required if Value Type (0040,A040) is DATETIME.   descDateTime   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a120)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-9table_C.7.6.16-12b
   mod_tables
Dose   entity1   req   �Specifies the first stored value mapped for the Real Word Value Intercept (0040,9224) and Real World Value Slope (0040,9225) or Real World Value LUT (0040,9212) of this Item.   See        select: label	   xrefstylesect_C.7.6.16.2.11.1   linkend   attrsxref   el for further explanation.   desc#Real World Value First Value Mapped   name
General Image   module   (0040,9096)[<0>](0040,9216)   
U   usage   
   mod_tables
Dose   entity1C   req   6Specifies the format of the LUT Data in this Sequence.   See        select: label	   xrefstylesect_C.11.1.1   linkend   attrsxref   el for further explanation.:Required if the Modality LUT Sequence (0028,3000) is sent.   descLUT Descriptor   name
Modality LUT   module   (0028,3000)[<0>](0028,3002)   
U   usage    �
   mod_tables
Dose   entity1   req
  Uniquely identifies ROI used to calculate DVH specified by ROI Number (3006,0022) in Structure Set ROI Sequence (3006,0020) in Structure Set Module within RT Structure Set referenced by referenced RT Plan in Referenced RT Plan Sequence (300C,0002) in RT Dose Module.   descReferenced ROI Number   name
RT DVH   module+   (3004,0050)[<0>](3004,0060)[<1>](3006,0084)   
M   usage   �
   mod_tables
	Equipment   entity3   req'Identifier of the gantry or positioner.   desc	Gantry ID   name
General Equipment   module   (0018,1008)   
M   usage   c
   mod_tables
Dose   entity3   req9Uniquely identifies device that created the SOP Instance.   descInstance Creator UID   name

SOP Common   module   (0008,0014)   
M   usage   �
   mod_tables
Dose   entity1C   req   �An array that contains the dose image plane offsets (in mm) of the dose image frames in a multi-frame dose. Required if multi-frame pixel data are present and Frame Increment Pointer (0028,0009) points to Grid Frame Offset Vector (3004,000C). See        select: label	   xrefstylesect_C.8.8.3.2   linkend   attrsxref   el.   descGrid Frame Offset Vector   name
RT Dose   module   (3004,000c)   
M   usage   
table_C.8-37table_10-16
table_10-2table_10-11
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   moduleK   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)[<3>](0008,1155)   
M   usage   
table_C.8-37
   mod_tables
Series   entity3   reqDate the Series started.   descSeries Date   name
	RT Series   module   (0008,0021)   
M   usage   �
   mod_tables
Dose   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0082)   
M   usage   �
   mod_tables
Dose   entity3   req   aCoordinates (x, y, z) of normalization point in the patient based coordinate system described in        select: label	   xrefstylesect_C.7.6.2.1.1   linkend   attrsxref   el (mm). See        select: label	   xrefstylesect_C.8.8.3.1   linkend   attrsxref   el.   descNormalization Point   name
RT Dose   module   (3004,0008)   
U   usage   b
   mod_tables
Study   entity1C   req   PThe identifier of the protocol for which consent to distribute has been granted.�Required if Distribution Type (0012,0084) is NAMED_PROTOCOL and the protocol is not that which is specified in Clinical Trial Protocol ID (0012,0020) in the Clinical Trial Subject Module.   descClinical Trial Protocol ID   name
Clinical Trial Study   module   (0012,0083)[<0>](0012,0020)   
M   usage   �
   mod_tables
	Equipment   entity3   reqQInstitution where the equipment that produced the composite instances is located.   descInstitution Name   name
General Equipment   module   (0008,0080)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req   0A coded description of how this ROI was derived.1One or more items are permitted in this Sequence.   See        select: label	   xrefstylesect_C.8.8.5.3   linkend   attrsxref   el for further explanation.   descDerivation Code Sequence   name
Structure Set   module   (3006,0020)[<0>](0008,9215)   
U   usage    �
   mod_tables
Dose   entity3   req   lCoordinates (x, y, z) of common DVH normalization point in the patient based coordinate system described in        select: label	   xrefstylesect_C.7.6.2.1.1   linkend   attrsxref   el (mm).   descDVH Normalization Point   name
RT DVH   module   (3004,0040)   
M   usage    _
   mod_tables
Patient   entity2C   req   FName of person with medical decision making authority for the patient.?Required if the patient is an animal. May be present otherwise.   descResponsible Person   name
Patient   module   (0010,2297)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   JIndicates whether or not this image is a quality control or phantom image.   
variablelist   typeEnumerated Values:   title      YES   NO   list   �If this Attribute is absent, then the image may or may not be a quality control or phantom image. The phantom device in the image can be described using the Device Module. See        select: label	   xrefstylesect_C.7.6.12   linkend   attrsxref   el   descQuality Control Image   name
General Image   module   (0028,0300)   
M   usage   l
   mod_tables
Series   entity1C   req   RIdentifier that identifies the Requested Procedure in the Imaging Service Request.>Required if procedure was scheduled. May be present otherwise.      
                      :  The condition is to allow the contents of this macro to be present (e.g., to convey the reason for the procedure, such as whether a mammogram is for screening or diagnostic purposes) even when the procedure was not formally scheduled and a value for this identifier is unknown, rather than making up a dummy value.   contentpara   el
                 contentnote   el   descRequested Procedure ID   name
	RT Series   module   (0040,0275)[<0>](0040,1001)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1C   req      @A data stream of the pixel samples that comprise the Image. See        select: label	   xrefstylesect_C.7.6.3.1.4   linkend   attrsxref   el for further explanation.?Required if Pixel Data Provider URL (0028,7FE0) is not present.   desc
Pixel Data   name
Image Pixel   module   (7fe0,0010)   
M   usage    _
   mod_tables
Patient   entity1C   req   OA code describing the mechanism or method use to remove the patient's identity.�One or more Items shall be included in this sequence. Multiple items are used if successive de-identification steps have been performed or to describe options of a defined profile.�Required if Patient Identity Removed (0012,0062) is present and has a value of YES and De-identification Method (0012,0063) is not present. May be present otherwise.   desc&De-identification Method Code Sequence   name
Patient   module   (0012,0064)   
M   usage   c
   mod_tables
Dose   entity3   req"The coding scheme full common name   descCoding Scheme Name   name

SOP Common   module   (0008,0110)[<0>](0008,0115)   
4C - Required if dose data contains grid-based doses.   usage   L
   mod_tables
Dose   entity1   req   Units of measurement.6Only a single Item shall be included in this sequence.   See        select: label	   xrefstylesect_C.7.6.16.2.11.1   linkend   attrsxref   el for further explanation.   descMeasurement Units Code Sequence   name
General Image   module   (0040,9096)[<0>](0040,08ea)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-9
table_10-3table_10-11
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
General Image   module   (0008,1140)[<0>](0008,1155)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   �Non-image composite SOP Instances that are significantly related to this Image, including waveforms that may or may not be temporally synchronized with this image.1One or more Items are permitted in this sequence.   descReferenced Instance Sequence   name
General Image   module   (0008,114a)   
M   usage    �
   mod_tables
Study   entity3   req   .Coded reason(s) for performing this procedure.      
                          �May differ from the values in Reason for the Requested Procedure (0040,100A) in Request Attribute Sequence (0040,0275), for example if what was performed differs from what was requested.   contentpara   el
                     contentnote   el1One or more Items are permitted in this Sequence.   desc,Reason For Performed Procedure Code Sequence   name
General Study   module   (0040,1012)   
M   usage    �
   mod_tables
Series   entity1C   req   �The floating point representation of Numeric Value (0040,A30A). The same number of values as Numeric Value (0040,A30A) shall be present.~Required if Numeric Value (0040,A30A) has insufficient precision to represent the value as a string. May be present otherwise.   descFloating Point Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a161)   
M   usage   �
   mod_tables
Dose   entity1   req�Identifies Control Point specified by Control Point Index (300A,0112) within Beam referenced by Referenced Beam Number (300C,0006). This is the first of the two Control Points from which the Dose contribution to the Control Point can be calculated.   desc$Referenced Start Control Point Index   name
RT Dose   moduleK   (300c,0002)[<0>](300c,0020)[<1>](300c,0004)[<2>](300c,00f2)[<3>](300c,00f4)   
ZC - Required if the SOP Instance was created in response to a Frame-Level retrieve request   usage   
table_C.12-9
   mod_tables
Dose   entity1   req   jSequence containing details of how this SOP Instance was extracted from a source multi-frame SOP Instance.�If this instance was created from an instance that contains a Frame Extraction Sequence, then this sequence shall contain all of the items from the parent's Frame Extraction Sequence and a new item that describes this extraction.5One or more Items shall be included in this sequence.   descFrame Extraction Sequence   name
Frame Extraction   module   (0008,1164)   
M   usage    _
   mod_tables
Patient   entity3   reqBirth time of the Patient.   descPatient's Birth Time   name
Patient   module   (0010,0032)   
M   usage   �
   mod_tables
Series   entity1C   req   MNumeric value for this name-value Item. Only a single value shall be present..Required if Value Type (0040,A040) is NUMERIC.   descNumeric Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a30a)   
M   usage    _
   mod_tables
Patient   entity3   req6User-defined additional information about the patient.   descPatient Comments   name
Patient   module   (0010,4000)   
M   usage   �
   mod_tables
Dose   entity1   req<A UID that can be used to uniquely reference this signature.   descDigital Signature UID   name

SOP Common   module   (fffa,fffa)[<0>](0400,0100)   
M   usage    �
   mod_tables
Series   entity1C   req   #UID value for this name-value Item.-Required if Value Type (0040,A040) is UIDREF.   descUID   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a124)   
M   usage   �
   mod_tables
Dose   entity3   reqtMailing address of the institution or organization to which the identified individual is responsible or accountable.   descInstitution Address   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0081)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity3   req   �Thickness of slab (in mm) represented by contour, where Contour Data (3006,0050) defines a plane in the center of the slab, offset by the Contour Offset Vector (3006,0045) if it is present. See        select: label	   xrefstylesect_C.8.8.6.2   linkend   attrsxref   el.   descContour Slab Thickness   name
ROI Contour   module+   (3006,0039)[<0>](3006,0040)[<1>](3006,0044)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1   req   =Specifies the intended interpretation of the pixel data. See        select: label	   xrefstylesect_C.7.6.3.1.2   linkend   attrsxref   el for further explanation.   descPhotometric Interpretation   name
General Image   module   (0088,0200)[<0>](0028,0004)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   �When present, specifies an identity transformation for the Presentation LUT such that the output of all grayscale transformations, if any, are defined to be in P-Values.   
variablelist   typeEnumerated Values:   title      IDENTITY�output is in P-Values - shall be used if Photometric Interpretation (0028,0004) is MONOCHROME2 or any color photometric interpretation.   INVERSEooutput after inversion is in P-Values - shall be used if Photometric Interpretation (0028,0004) is MONOCHROME1.   listpWhen this attribute is used with a color photometric interpretation then the luminance component is in P-Values.   descPresentation LUT Shape   name
General Image   module   (2050,0020)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity3   req   *Sequence of images containing the contour.1One or more items are permitted in this sequence.   descContour Image Sequence   name
ROI Contour   module+   (3006,0039)[<0>](3006,0040)[<1>](3006,0016)   
M   usage   �
   mod_tables
Series   entity3   req   CSequence that contains attributes from the Imaging Service Request.1One or more Items are permitted in this sequence.   descRequest Attributes Sequence   name
	RT Series   module   (0040,0275)   
M   usage   =
   mod_tables
Series   entity1C   req   +Person name value for this name-value Item.,Required if Value Type (0040,A040) is PNAME.   descPerson Name   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a123)   
M   usage   
table_C.8-37
table_10-9table_10-17
   mod_tables
Series   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
	RT Series   module+   (0040,0275)[<0>](0008,0051)[<1>](0040,0031)   
M   usage   
table_C.8-37table_10-16
table_10-2table_10-11
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)[<2>](0008,1155)   
M   usage   
table_C.8-37table_10-16
   mod_tables
Series   entity3   req]Institution-generated description or classification of the Procedure Step that was performed.   desc$Performed Procedure Step Description   name
	RT Series   module   (0040,0254)   
M   usage    _
   mod_tables
Patient   entity2C   req   :Information identifying an animal within a breed registry.6Zero or more Items shall be included in this sequence.%Required if the patient is an animal.   descBreed Registration Sequence   name
Patient   module   (0010,2294)   
M   usage   �
   mod_tables
Dose   entity1C   req   �Scaling factor that when multiplied by the dose grid data found in Pixel Data (7FE0,0010) attribute of the Image Pixel Module, yields grid doses in the dose units as specified by Dose Units (3004,0002)..Required if Pixel Data (7FE0,0010) is present.   descDose Grid Scaling   name
RT Dose   module   (3004,000e)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1   reqNumber of rows in the image.   descRows   name
General Image   module   (0088,0200)[<0>](0028,0010)   
M   usage   c
   mod_tables
Dose   entity1   req:Date and time the attributes were removed and/or replaced.   descAttribute Modification DateTime   name

SOP Common   module   (0400,0561)[<0>](0400,0562)   
U   usage   
table_C.9-2
   mod_tables
Dose   entity1   req   QIndicates whether this overlay represents a region of interest or other graphics.   
variablelist   typeEnumerated Values:   title      GGraphics   RROI   list   descOverlay Type   name
Overlay Plane   module   (60xx,0040)   
M   usage   �
   mod_tables
Series   entity1C   req   MNumeric value for this name-value Item. Only a single value shall be present..Required if Value Type (0040,A040) is NUMERIC.   descNumeric Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a30a)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req   7Sequence of Studies containing series to be referenced.1One or more items are permitted in this sequence.   See        select: label	   xrefstylesect_C.8.8.5.4   linkend   attrsxref   el.   descRT Referenced Study Sequence   name
Structure Set   module   (3006,0010)[<0>](3006,0012)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity1   req   ROIs for current Structure Set.5One or more items shall be included in this sequence.   descStructure Set ROI Sequence   name
Structure Set   module   (3006,0020)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity2   req.Time at which Structure Set was last modified.   descStructure Set Time   name
Structure Set   module   (3006,0009)   
M   usage   c
   mod_tables
Dose   entity3   reqMDescription of the contribution the equipment made to the composite instance.   descContribution Description   name

SOP Common   module   (0018,a001)[<0>](0018,a003)   
U   usage   (
   mod_tables
Dose   entity1   req   �Sequence of Items each providing a reference to an Instance that is part of the Series defined by Series Instance UID (0020,000E) in the enclosing Item.5One or more Items shall be included in this sequence.   descReferenced Instance Sequence   name
Common Instance Reference   module+   (0008,1200)[<0>](0008,1115)[<1>](0008,114a)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-42
table_10-3table_10-11
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
ROI Contour   module;   (3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1150)   
M   usage    �
   mod_tables
Series   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0008,1199)[<3>](0008,1160)   
M   usage   
table_C.8-37
table_10-9
table_10-2table_10-11
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   module[   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)[<4>](0008,1150)   
M   usage   �
   mod_tables
	Equipment   entity3   reqQManufacturer's model name of the equipment that produced the composite instances.   descManufacturer's Model Name   name
General Equipment   module   (0008,1090)   
M   usage   c
   mod_tables
Dose   entity3   req   "Time the SOP Instance was created.xThis is the time that the SOP Instance UID was assigned, and does not change during subsequent coercion of the instance.   descInstance Creation Time   name

SOP Common   module   (0008,0013)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req      7A coded description of how this image was derived. See        select: label	   xrefstylesect_C.7.6.1.1.3   linkend   attrsxref   el for further explanation.�One or more Items are permitted in this Sequence. More than one Item indicates that successive derivation steps have been applied.   descDerivation Code Sequence   name
General Image   module   (0008,9215)   
M   usage    _
   mod_tables
Patient   entity1C   req   The species of the patient.6Only a single Item shall be included in this sequence.}Required if the patient is an animal and if Patient Species Description (0010,2201) is not present. May be present otherwise.   descPatient Species Code Sequence   name
Patient   module   (0010,2202)   
M   usage   �
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)[<2>](0008,1150)   
U   usage   
table_C.9-3
   mod_tables
Dose   entity3   req\Frame number of Multi-frame Image to which this overlay applies; frames are numbered from 1.   descImage Frame Origin   name
Multi-frame Overlay   module   (60xx,0051)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req+User-defined description for Structure Set.   descStructure Set Description   name
Structure Set   module   (3006,0006)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity3   req   CVector (x,y,z) in the patient based coordinate system described in        select: label	   xrefstylesect_C.7.6.2.1.1   linkend   attrsxref   el� that is normal to plane of Contour Data (3006,0050), describing direction and magnitude of the offset (in mm) of each point of the central plane of a contour slab from the corresponding original point of Contour Data (3006,0050). See        select: label	   xrefstylesect_C.8.8.6.2   linkend   attrsxref   el.   descContour Offset Vector   name
ROI Contour   module+   (3006,0039)[<0>](3006,0040)[<1>](3006,0045)   
U   usage   �
   mod_tables
Dose   entity1C   req   �Sequence of items each identifying a Study other than the Study of which this Instance is a part, which Studies contain Instances that are referenced elsewhere in this Instance.5One or more Items shall be included in this sequence.@Required if this Instance references Instances in other Studies.   desc6Studies Containing Other Referenced Instances Sequence   name
Common Instance Reference   module   (0008,1200)   
U   usage   X
   mod_tables
Study   entity3   req+Description of the type of service episode.   descService Episode Description   name
Patient Study   module   (0038,0062)   
M   usage   l
   mod_tables
Series   entity3   reqdInstitution-generated description or classification of the Scheduled Procedure Step to be performed.   desc$Scheduled Procedure Step Description   name
	RT Series   module   (0040,0275)[<0>](0040,0007)   
U   usage   
table_C.7-5b
   mod_tables
Series   entity3   req   DAn identifier of the series in the context of a clinical trial. See        select: label	   xrefstylesect_C.7.3.2.1.2   linkend   attrsxref   el.   descClinical Trial Series ID   name
Clinical Trial Series   module   (0012,0071)   
M   usage   �
   mod_tables
Series   entity1C   req   $Date value for this name-value Item.+Required if Value Type (0040,A040) is DATE.   descDate   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a121)   
M   usage   c
   mod_tables
Dose   entity3   req   �Date when the image acquisition device calibration was last changed in any way. Multiple entries may be used for additional calibrations at other times. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descDate of Last Calibration   name

SOP Common   module   (0018,a001)[<0>](0018,1200)   
M   usage    �
   mod_tables
Study   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name
General Study   module   (0008,0096)[<0>](0040,1103)   
M   usage   l
   mod_tables
Series   entity3   req   +Coded Reason for requesting this procedure.1One or more Items are permitted in this sequence.   desc,Reason for Requested Procedure Code Sequence   name
	RT Series   module   (0040,0275)[<0>](0040,100a)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   reqDThe time the acquisition of data that resulted in this image started   descAcquisition Time   name
General Image   module   (0008,0032)   
M   usage   �
   mod_tables
Series   entity3   req3Time on which the Performed Procedure Step started.   desc#Performed Procedure Step Start Time   name
	RT Series   module   (0040,0245)   
U   usage   �
   mod_tables
Patient   entity2   req   OThe identifier of the site responsible for submitting clinical trial data. See        select: label	   xrefstylesect_C.7.1.3.1.4   linkend   attrsxref   el.   descClinical Trial Site ID   name
Clinical Trial Subject   module   (0012,0030)   
U   usage   �
   mod_tables
Patient   entity1C   req   �Identifies the subject for blinded evaluations. Shall be present if Clinical Trial Subject ID (0012,0040) is absent. May be present otherwise. See        select: label	   xrefstylesect_C.7.1.3.1.7   linkend   attrsxref   el.   desc!Clinical Trial Subject Reading ID   name
Clinical Trial Subject   module   (0012,0042)   
U   usage    �
   mod_tables
Dose   entity1   req   Volume axis units.   
variablelist   typeDefined Terms:   title      CM3cubic centimeters   PERCENTpercent   PER_U   volume per u with u(dose)=dose      -3/2   contentsuperscript   el. See        select: label	   xrefstylesect_C.8.8.4.3   linkend   attrsxref   el.   list   descDVH Volume Units   name
RT DVH   module   (3004,0050)[<0>](3004,0054)   
M   usage   �
   mod_tables
	Equipment   entity3   req   kManufacturer's designation of software version of the equipment that produced the composite instances. See        select: label	   xrefstylesect_C.7.5.1.1.3   linkend   attrsxref   el.   descSoftware Versions   name
General Equipment   module   (0018,1020)   
U   usage   
   mod_tables
Dose   entity1C   req   1Specifies the output values of this Modality LUT.   See        select: label	   xrefstylesect_C.11.1.1.2   linkend   attrsxref   el for further explanation.:Required if the Modality LUT Sequence (0028,3000) is sent.   descModality LUT Type   name
Modality LUT   module   (0028,3000)[<0>](0028,3004)   
U   usage   �
   mod_tables
Dose   entity3   req   Number of pixels in ROI area.   See        select: label	   xrefstylesect_C.9.2.1.2   linkend   attrsxref   el for further explanation.   descROI Area   name
Overlay Plane   module   (60xx,1301)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1   reqNumber of columns in the image   descColumns   name
General Image   module   (0088,0200)[<0>](0028,0011)   
M   usage   c
   mod_tables
Dose   entity3   req�The inherent limiting resolution in mm of the acquisition equipment for high contrast objects for the data gathering and reconstruction technique chosen. If variable across the images of the series, the value at the image center.   descSpatial Resolution   name

SOP Common   module   (0018,a001)[<0>](0018,1050)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   �Specifies the format of the Red Palette Color Lookup Table Data (0028,1201). Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.5   linkend   attrsxref   el for further explanation.   desc)Red Palette Color Lookup Table Descriptor   name
General Image   module   (0088,0200)[<0>](0028,1101)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   6A text description of how this image was derived. See        select: label	   xrefstylesect_C.7.6.1.1.3   linkend   attrsxref   el for further explanation.   descDerivation Description   name
General Image   module   (0008,2111)   
U   usage   
table_C.12-8table_10-11
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Common Instance Reference   module+   (0008,1115)[<0>](0008,114a)[<1>](0008,1150)   
M   usage   =
   mod_tables
Series   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)[<2>](0008,1160)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-10
   mod_tables
Dose   entity3   req   :Relative position of the image plane expressed in mm. See        select: label	   xrefstylesect_C.7.6.2.1.2   linkend   attrsxref   el for further explanation.   descSlice Location   name
Image Plane   module   (0020,1041)   
M   usage   c
   mod_tables
Dose   entity3   reqmThe certification number issued to the Application Entity that set the SOP Instance Status (0100,0410) to AO.   desc,Authorization Equipment Certification Number   name

SOP Common   module   (0100,0426)      
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   req   ZMost significant bit for pixel sample data. Each sample shall have the same high bit. See        select: labelnumber	   xrefstylePS3.5	   targetdocPS3.5	   targetptr   attrsolink   el for further explanation.   descHigh Bit   name
Image Pixel   module   
M   usage   �
   mod_tables
Dose   entity1C   req   ZMost significant bit for each pixel sample. Each sample shall have the same high bit. See        select: label	   xrefstylesect_C.8.8.3.4.5   linkend   attrsxref   elC for specialization. Required if Pixel Data (7FE0,0010) is present.   descHigh Bit   name
RT Dose   module   (0028,0102)   
M   usage   �
   mod_tables
Series   entity1C   req   `Identifies the segments to which the reference applies identified by Segment Number (0062,0004).�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
	RT Series   module[   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)[<4>](0062,000b)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
General Image   module   (0008,2112)[<0>](0008,1150)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-9table_10-11
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
General Image   module   (0008,114a)[<0>](0008,1155)   
M   usage   
   mod_tables
Patient   entity3   req   lAttributes specifying or qualifying the identity of the issuer of the Patient ID, or scoping the Patient ID.1Only a single Item is permitted in this sequence.   desc(Issuer of Patient ID Qualifiers Sequence   name
Patient   module   (0010,0024)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1C   req   �Blue Palette Color Lookup Table Data. Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.6   linkend   attrsxref   el for further explanation.   desc$Blue Palette Color Lookup Table Data   name
Image Pixel   module   (0028,1203)   
U   usage   
table_C.12-8
table_10-4table_10-11
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Common Instance Reference   module;   (0008,1200)[<0>](0008,1115)[<1>](0008,114a)[<2>](0008,1150)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1   req   _Data representation of the pixel samples. Each sample shall have the same pixel representation.   Enumerated Values:   title
variablelist   type      0000Hunsigned integer.   0001H2's complement   list   descPixel Representation   name
General Image   module   (0088,0200)[<0>](0028,0103)   
M   usage    �
   mod_tables
Study   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name
General Study   module   (0008,0096)[<0>](0040,1101)   
M   usage   c
   mod_tables
Dose   entity1   req   Encrypted data. See        select: label	   xrefstylesect_C.12.1.1.4.2   linkend   attrsxref   el.   descEncrypted Content   name

SOP Common   module   (0400,0500)[<0>](0400,0520)   
4C - Required if dose data contains grid-based doses.   usage   
table_C.7-9
table_10-3
   mod_tables
Dose   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
General Image   module   (0008,2112)[<0>](0008,1160)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   /This icon image is representative of the Image.1Only a single Item is permitted in this Sequence.   descIcon Image Sequence   name
General Image   module   (0088,0200)   
M   usage   �
   mod_tables
Dose   entity1C   req   �Sequence of Beams in current Fraction Group contributing to dose. Required if Dose Summation Type (3004,000A) is BEAM, BEAM_SESSION or CONTROL_POINT.5One or more items shall be included in this sequence.   descReferenced Beam Sequence   name
RT Dose   module+   (300c,0002)[<0>](300c,0020)[<1>](300c,0004)   
M   usage    �
   mod_tables
Study   entity3   req   5Institutional department where the request initiated.1Only a single item is permitted in this sequence.   desc Requesting Service Code Sequence   name
General Study   module   (0032,1034)   
U   usage   b
   mod_tables
Study   entity3   req   �A description of a set of one or more studies that are grouped together to represent a clinical time point or submission in a clinical trial. See        select: label	   xrefstylesect_C.7.2.3.1.1   linkend   attrsxref   el.   desc%Clinical Trial Time Point Description   name
Clinical Trial Study   module   (0012,0051)   
M   usage   �
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   module[   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)[<4>](0008,1155)   
M   usage   �
   mod_tables
Series   entity1C   req   ,Coded concept value of this name-value Item.6Only a single Item shall be included in this Sequence.+Required if Value Type (0040,A040) is CODE.   descConcept Code Sequence   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a168)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity3   req9The minimum actual pixel value encountered in this image.   descSmallest Image Pixel Value   name
Image Pixel   module   (0028,0106)   
M   usage   c
   mod_tables
Dose   entity3   req   �Sequence of Items containing descriptive attributes of related equipment that has contributed to the acquisition, creation or modification of the composite instance.1One or more Items are permitted in this Sequence.   See        select: label	   xrefstylesect_C.12.1.1.5   linkend   attrsxref   el for further explanation.   descContributing Equipment Sequence   name

SOP Common   module   (0018,a001)   
M   usage   �
   mod_tables
	Equipment   entity2   reqDManufacturer of the equipment that produced the composite instances.   descManufacturer   name
General Equipment   module   (0008,0070)   
M   usage   c
   mod_tables
Dose   entity1   req   |Sequence that contains all the Attributes, with their previous values, that were modified or removed from the main data set.6Only a single Item shall be included in this sequence.   descModified Attributes Sequence   name

SOP Common   module   (0400,0561)[<0>](0400,0550)   
M   usage   �
   mod_tables
Dose   entity1   req   �The date and time the Digital Signature was created. The time shall include an offset (i.e., time zone indication) from Coordinated Universal Time.      
                            �This is not a certified timestamp, and hence is not completely verifiable. An application can compare this date and time with those of other signatures and the validity date of the certificate to gain confidence in the veracity of this date and time.   contentpara   el
                       contentnote   el   descDigital Signature DateTime   name

SOP Common   module   (fffa,fffa)[<0>](0400,0105)   
M   usage   �
   mod_tables
Dose   entity1   req   WThe algorithm used in generating the MAC to be encrypted to form the Digital Signature.   Defined Terms:   title
variablelist   type      	RIPEMD160   MD5   SHA1   SHA256   SHA384   SHA512   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descMAC Algorithm   name

SOP Common   module   (4ffe,0001)[<0>](0400,0015)   
M   usage   �
   mod_tables
Series   entity1C   req   @Composite SOP Instance Reference value for this name-value Item.6Only a single Item shall be included in this Sequence.9Required if Value Type (0040,A040) is COMPOSITE or IMAGE.   descReferenced SOP Sequence   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)   
M   usage   �
   mod_tables
Study   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name
General Study   module   (0008,1062)[<0>](0040,1101)   
U   usage   
table_C.7-4atable_10-17
   mod_tables
Study   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
Patient Study   module   (0038,0064)[<0>](0040,0032)   
M   usage   �
   mod_tables
Series   entity1C   req   AUnits of measurement for a numeric value in this name-value Item.6Only a single Item shall be included in this Sequence..Required if Value Type (0040,A040) is NUMERIC.   descMeasurement Units Code Sequence   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,08ea)      
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   req   .Number of samples (planes) in this image. See        select: label	   xrefstylesect_C.7.6.3.1.1   linkend   attrsxref   el for further explanation.   descSamples per Pixel   name
Image Pixel   module   
M   usage   �
   mod_tables
Dose   entity1C   req   .Number of samples (planes) in this image. See        select: label	   xrefstylesect_C.8.8.3.4.1   linkend   attrsxref   elC for specialization. Required if Pixel Data (7FE0,0010) is present.   descSamples per Pixel   name
RT Dose   module   (0028,0002)   
M   usage    �
   mod_tables
Patient   entity3   req   �The place or location identifier where the identifier was first assigned to the patient. This component is not an inherent part of the identifier but rather part of the history of the identifier.1Only a single Item is permitted in this sequence.      
                      9Equivalent to HL7 v2 CX component 6 (Assigning Facility).   contentpara   el
                 contentnote   el   descAssigning Facility Sequence   name
Patient   module+   (0010,1002)[<0>](0010,0024)[<1>](0040,0036)   
M   usage   �
   mod_tables
Study   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name
General Study   module   (0008,1062)[<0>](0040,1103)   
4C - Required if dose data contains grid-based doses.   usage   L
   mod_tables
Dose   entity1C   req   LUT Data in this Sequence.BRequired if Real World Value Intercept (0040,9224) is not present.   descReal World Value LUT Data   name
General Image   module   (0040,9096)[<0>](0040,9212)   
M   usage   
table_C.12-1table_10-11
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name

SOP Common   module   (0040,a390)[<0>](0008,1155)   
U   usage   �
   mod_tables
Dose   entity1   req   Overlay pixel data.�The order of pixels sent for each overlay is left to right, top to bottom, i.e., the upper left pixel is sent first followed by the remainder of the first row, followed by the first pixel of the 2nd row, then the remainder of the 2nd row and so on.2Overlay data shall be contained in this Attribute.   See        select: label	   xrefstylesect_C.9.2.1.1   linkend   attrsxref   el for further explanation.   descOverlay Data   name
Overlay Plane   module   (60xx,3000)   
M   usage   �
   mod_tables
Series   entity1C   req   (DateTime value for this name-value Item./Required if Value Type (0040,A040) is DATETIME.   descDateTime   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a120)   
M   usage   �
   mod_tables
Series   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
	RT Series   module+   (0040,0275)[<0>](0008,0051)[<1>](0040,0032)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity2   reqUser-defined name for ROI.   descROI Name   name
Structure Set   module   (3006,0020)[<0>](3006,0026)   
M   usage   c
   mod_tables
Dose   entity1C   req�The coding scheme UID identifier. Required if coding scheme is identified by an ISO 8824 object identifier compatible with the UI VR.   descCoding Scheme UID   name

SOP Common   module   (0008,0110)[<0>](0008,010c)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   \The set of Image SOP Class/Instance pairs of the Images that were used to derive this Image.1One or more Items are permitted in this Sequence.   See        select: label	   xrefstylesect_C.7.6.1.1.4   linkend   attrsxref   el for further explanation.   descSource Image Sequence   name
General Image   module   (0008,2112)   
U   usage   �
   mod_tables
Dose   entity1   reqNumber of Rows in Overlay.   descOverlay Rows   name
Overlay Plane   module   (60xx,0010)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req   IThe Structure Set that has been used to derive the current Structure Set.1Only a single item is permitted in this sequence.   desc"Predecessor Structure Set Sequence   name
Structure Set   module   (3006,0018)   
M   usage   �
   mod_tables
	Equipment   entity3   reqPUser defined name identifying the machine that produced the composite instances.   descStation Name   name
General Equipment   module   (0008,1010)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity3   reqJRGB triplet color representation for ROI, specified using the range 0-255.   descROI Display Color   name
ROI Contour   module   (3006,0039)[<0>](3006,002a)   
M   usage   �
   mod_tables
Series   entity1   req Unique identifier of the series.   descSeries Instance UID   name
	RT Series   module   (0020,000e)   
M   usage   �
   mod_tables
Dose   entity1   req   Units used to describe dose.   
variablelist   typeEnumerated Values:   title      GYGray   RELATIVE)dose relative to implicit reference value   list   desc
Dose Units   name
RT Dose   module   (3004,0002)   
M   usage    _
   mod_tables
Patient   entity2C   req      The breed of the patient. See        select: label	   xrefstylesect_C.7.1.1.1.1   linkend   attrsxref   el.wRequired if the patient is an animal and if Patient Breed Code Sequence (0010,2293) is empty. May be present otherwise.   descPatient Breed Description   name
Patient   module   (0010,2292)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   reqDThe date the acquisition of data that resulted in this image started   descAcquisition Date   name
General Image   module   (0008,0022)   
M   usage   c
   mod_tables
Dose   entity3   reqSThe coding scheme version associated with the Coding Scheme Designator (0008,0102).   descCoding Scheme Version   name

SOP Common   module   (0008,0110)[<0>](0008,0103)   
M   usage    �
   mod_tables
Study   entity2   req-User or equipment generated Study identifier.   descStudy ID   name
General Study   module   (0020,0010)   
4C - Required if dose data contains grid-based doses.   usage   @
   mod_tables
Dose   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
General Image   module   (0008,2112)[<0>](0062,000b)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   �Indicates whether or not image contains sufficient burned in annotation to identify the patient and date the image was acquired.   
variablelist   typeEnumerated Values:   title      YES   NO   listXIf this Attribute is absent, then the image may or may not contain burned in annotation.   descBurned In Annotation   name
General Image   module   (0028,0301)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   �Green Palette Color Lookup Table Data. Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.6   linkend   attrsxref   el for further explanation.   desc%Green Palette Color Lookup Table Data   name
General Image   module   (0088,0200)[<0>](0028,1202)   
ZC - Required if the SOP Instance was created in response to a Frame-Level retrieve request   usage   �
   mod_tables
Dose   entity1C   req   :The start and end times of the frames that were extracted.^Required if object extraction is based on a Frame Level Retrieve using Time Range (0008,1163).   See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el0 "Instance and Frame Level Retrieve SOP Classes"   desc
Time Range   name
Frame Extraction   module   (0008,1164)[<0>](0008,1163)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req!User-defined description for ROI.   descROI Description   name
Structure Set   module   (3006,0020)[<0>](3006,0028)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity3   req   iAn ICC Profile encoding the transformation of device-dependent color stored pixel values into PCS-Values.   See        select: label	   xrefstylesect_C.11.15.1.1   linkend   attrsxref   el.�When present, defines the color space of color Pixel Data (7FE0,0010) values, and the output of Palette Color Lookup Table Data (0028,1201-1203).      
                          �The profile applies only to Pixel Data (7FE0,0010) at the same level of the Data Set and not to any icons nested within sequences, which may or may not have their own ICC profile specified.   contentpara   el
                     contentnote   el   descICC Profile   name
General Image   module   (0088,0200)[<0>](0028,2000)   
M   usage   c
   mod_tables
Dose   entity1   req   *Uniquely identifies the SOP Instance. See        select: label	   xrefstylesect_C.12.1.1.1   linkend   attrsxref   el# for further explanation. See also        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descSOP Instance UID   name

SOP Common   module   (0008,0018)   
U   usage    �
   mod_tables
Dose   entity1   req   Sequence of DVHs.5One or more items shall be included in this sequence.   descDVH Sequence   name
RT DVH   module   (3004,0050)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   6Describes the purpose for which the reference is made.1Only a single Item is permitted in this sequence.   desc"Purpose of Reference Code Sequence   name
General Image   module   (0008,1140)[<0>](0040,a170)   
U   usage   �
   mod_tables
Patient   entity1C   req�Name of the Ethics Committee or Institutional Review Board (IRB) responsible for approval of the Clinical Trial. Required if Clinical Trial Protocol Ethics Committee Approval Number (0012,0082) is present.   desc-Clinical Trial Protocol Ethics Committee Name   name
Clinical Trial Subject   module   (0012,0081)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req<Number of images that resulted from this acquisition of data   descImages in Acquisition   name
General Image   module   (0020,1002)   
U   usage   (
   mod_tables
Dose   entity1   reqDUnique identifier of the Series containing the referenced Instances.   descSeries Instance UID   name
Common Instance Reference   module+   (0008,1200)[<0>](0008,1115)[<1>](0020,000e)   
M   usage   l
   mod_tables
Series   entity3   req�Sequence that specifies the context for the Scheduled Protocol Code Sequence Item. One or more Items are permitted in this sequence.   descProtocol Context Sequence   name
	RT Series   module+   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)   
M   usage    �
   mod_tables
Study   entity1   req Unique identifier for the Study.   descStudy Instance UID   name
General Study   module   (0020,000d)   
M   usage   =
   mod_tables
Series   entity1   req   +Coded concept name of this name-value Item.6Only a single Item shall be included in this Sequence.   descConcept Name Code Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a043)   
M   usage    _
   mod_tables
Patient   entity2   reqBirth date of the patient.   descPatient's Birth Date   name
Patient   module   (0010,0030)   
M   usage    �
   mod_tables
Study   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name
General Study   module   (0008,1049)[<0>](0008,0082)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-41
table_10-3table_10-11
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Structure Set   moduleK   (3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)[<3>](0008,1155)   
U   usage   X
   mod_tables
Study   entity3   req>Identifier of the visit as assigned by the healthcare provider   descAdmission ID   name
Patient Study   module   (0038,0010)   
M   usage   �
   mod_tables
Series   entity1C   req   $Text value for this name-value Item.+Required if Value Type (0040,A040) is TEXT.   desc
Text Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a160)   
4C - Required if dose data contains grid-based doses.   usage   
�
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
General Image   module   (0008,114a)[<0>](0008,1150)   
M   usage   c
   mod_tables
Dose   entity1   req   &Reason for the attribute modification.   
variablelist   typeDefined Terms:   title      COERCE�Replace values of attributes such as Patient Name, ID, Accession Number, for example, during import of media from an external institution, or reconciliation against a master patient index.   CORRECT�Replace incorrect values, such as Patient Name or ID, for example, when incorrect worklist item was chosen or operator input error.   list   desc%Reason for the Attribute Modification   name

SOP Common   module   (0400,0561)[<0>](0400,0565)   
M   usage   c
   mod_tables
Dose   entity3   reqUUser defined name identifying the machine that contributed to the composite instance.   descStation Name   name

SOP Common   module   (0018,a001)[<0>](0008,1010)   
U   usage   �
   mod_tables
Patient   entity3   reqkApproval number issued by committee described in Clinical Trial Protocol Ethics Committee Name (0012,0081).   desc8Clinical Trial Protocol Ethics Committee Approval Number   name
Clinical Trial Subject   module   (0012,0082)   
M   usage    �
   mod_tables
Series   entity1C   req   �The integer denominator of a rational representation of Numeric Value (0040,A30A). Encoded as a non-zero unsigned integer value. The same number of values as Numeric Value (0040,A30A) shall be present.<Required if Rational Numerator Value (0040,A162) is present.   descRational Denominator Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a163)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req%User-defined comments about the image   descImage Comments   name
General Image   module   (0020,4000)   
M   usage   =
   mod_tables
Series   entity1C   req   `Identifies the segments to which the reference applies identified by Segment Number (0062,0004).�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)[<2>](0062,000b)   
M   usage   �
   mod_tables
Dose   entity3   req   �A certified timestamp of the Digital Signature (0400,0120) Attribute Value, which shall be obtained when the Digital Signature is created. See        select: label	   xrefstylesect_C.12.1.1.3.1.3   linkend   attrsxref   el.   descCertified Timestamp   name

SOP Common   module   (fffa,fffa)[<0>](0400,0310)   
U   usage   �
   mod_tables
Patient   entity1   req   ,The name of the clinical trial sponsor. See        select: label	   xrefstylesect_C.7.1.3.1.1   linkend   attrsxref   el.   descClinical Trial Sponsor Name   name
Clinical Trial Subject   module   (0012,0010)   
M   usage   �
   mod_tables
Series   entity1   req   +Coded concept name of this name-value Item.6Only a single Item shall be included in this Sequence.   descConcept Name Code Sequence   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a043)   
U   usage   X
   mod_tables
Study   entity3   reqAge of the Patient.   descPatient's Age   name
Patient Study   module   (0010,1010)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity1   req   ,Sequence of Contour Sequences defining ROIs.5One or more items shall be included in this sequence.   descROI Contour Sequence   name
ROI Contour   module   (3006,0039)   
U   usage   �
   mod_tables
Dose   entity1   req   (Number of Bits Allocated in the Overlay.'The value of this Attribute shall be 1.      
                        �Formerly the standard described embedding the overlay data in the Image Pixel Data (7FE0,0010), in which case the value of this Attribute was required to be the same as Bits Allocated (0028,0100). This usage has been retired. See PS3.3-2004.   contentpara   el
                   contentnote   el   descOverlay Bits Allocated   name
Overlay Plane   module   (60xx,0100)   
M   usage   
   mod_tables
Patient   entity3   req   �The geo-political body that assigned the patient identifier. Typically a code for a country or a state/province. Only a single Item is permitted in this sequence.      
                      ;Equivalent to HL7 v2 CX component 9 (Identifier Type Code).   contentpara   el
                 contentnote   el   desc$Assigning Jurisdiction Code Sequence   name
Patient   module   (0010,0024)[<0>](0040,0039)   
M   usage    �
   mod_tables
Patient   entity3   req   oIdentifier of the Assigning Authority (system, organization, agency, or department) that issued the Patient ID.      
                      3Equivalent to HL7 v2 CX component 4 subcomponent 1.   contentpara   el
                 contentnote   el   descIssuer of Patient ID   name
Patient   module   (0010,1002)[<0>](0010,0021)   
U   usage   
   mod_tables
Dose   entity3   req5Free form text explanation of the meaning of the LUT.   descLUT Explanation   name
Modality LUT   module   (0028,3000)[<0>](0028,3003)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req"Volume of ROI (cubic centimeters).   desc
ROI Volume   name
Structure Set   module   (3006,0020)[<0>](3006,002c)   
M   usage   �
   mod_tables
Series   entity1C   req   �The floating point representation of Numeric Value (0040,A30A). The same number of values as Numeric Value (0040,A30A) shall be present.~Required if Numeric Value (0040,A30A) has insufficient precision to represent the value as a string. May be present otherwise.   descFloating Point Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a161)   
4C - Required if dose data contains grid-based doses.   usage   L
   mod_tables
Dose   entity1C   req   YThe Intercept value in relationship between stored values (SV) and the Real World values.   See        select: label	   xrefstylesect_C.7.6.16.2.11.1.2   linkend   attrsxref   el for further explanation.ARequired if Real World Value LUT Data (0040,9212) is not present.   descReal World Value Intercept   name
General Image   module   (0040,9096)[<0>](0040,9224)   
U   usage    �
   mod_tables
Dose   entity3   req�Dose Value at DVH Normalization Point (3004,0040) used as reference for individual DVHs when Dose Units (3004,0002) is RELATIVE.   descDVH Normalization Dose Value   name
RT DVH   module   (3004,0042)      
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   req   nNumber of bits allocated for each pixel sample. Each sample shall have the same number of bits allocated. See        select: labelnumber	   xrefstylePS3.5	   targetdocPS3.5	   targetptr   attrsolink   el for further explanation.   descBits Allocated   name
Image Pixel   module   
M   usage   �
   mod_tables
Dose   entity1C   req   nNumber of bits allocated for each pixel sample. Each sample shall have the same number of bits allocated. See        select: label	   xrefstylesect_C.8.8.3.4.3   linkend   attrsxref   el@ for specialization. Required Pixel Data (7FE0,0010) is present.   descBits Allocated   name
RT Dose   module   (0028,0100)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-41table_10-11
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Structure Set   module+   (3006,0010)[<0>](3006,0012)[<1>](0008,1150)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1C   req   �Red Palette Color Lookup Table Data. Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.6   linkend   attrsxref   el for further explanation.   desc#Red Palette Color Lookup Table Data   name
Image Pixel   module   (0028,1201)   
U   usage   
   mod_tables
Dose   entity1C   req   rThe value b in relationship between stored values (SV) and the output units specified in Rescale Type (0028,1054).Output units = m*SV + b.]Required if Modality LUT Sequence (0028,3000) is not present. Shall not be present otherwise.   descRescale Intercept   name
Modality LUT   module   (0028,1052)   
M   usage    _
   mod_tables
Patient   entity3   req   BIndicates whether or not the subject is a quality control phantom.   
variablelist   typeEnumerated Values:   title      YES   NO   listJIf this Attribute is absent, then the subject may or may not be a phantom.�This attribute describes a characteristic of the Imaging Subject. It is distinct from Quality Control Image (0028,0300) in the General Image Module, which is used to describe an image acquired.   descQuality Control Subject   name
Patient   module   (0010,0200)   
M   usage   c
   mod_tables
Dose   entity3   reqIThe Date & Time when the equipment contributed to the composite instance.   descContribution DateTime   name

SOP Common   module   (0018,a001)[<0>](0018,a002)   
U   usage   O
   mod_tables
Study   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
Patient Study   module   (0038,0064)[<0>](0040,0031)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity1   req8Number of points (triplets) in Contour Data (3006,0050).   descNumber of Contour Points   name
ROI Contour   module+   (3006,0039)[<0>](3006,0040)[<1>](3006,0046)   
M   usage   �
   mod_tables
Dose   entity1   req�A number, unique within this SOP Instance, used to identify this MAC Parameters Sequence (4FFE,0001) item from an Item of the Digital Signatures Sequence (FFFA,FFFA).   descMAC ID Number   name

SOP Common   module   (4ffe,0001)[<0>](0400,0005)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity1   req   mSequence describing series of images within the referenced study that are used in defining the Structure Set.5One or more items shall be included in this sequence.   descRT Referenced Series Sequence   name
Structure Set   module+   (3006,0010)[<0>](3006,0012)[<1>](3006,0014)   
M   usage   �
   mod_tables
Dose   entity2C   req   �A reference to a Spatial Registration SOP Instance or a Deformable Spatial Registration SOP Instance, which defines the transformation used to transform the dose.eRequired, if Spatial Transform of Dose (3004,0005) is provided and has a value of RIGID or NON_RIGID.6Zero or more items shall be included in this sequence.   See        select: label	   xrefstylesect_C.8.8.3.5   linkend   attrsxref   el   desc(Referenced Spatial Registration Sequence   name
RT Dose   module   (0070,0404)   
M   usage   �
   mod_tables
Series   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
	RT Series   module[   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)[<4>](0008,1160)   
M   usage   �
   mod_tables
Series   entity3   req   }Sequence that specifies modifiers for a Protocol Context Content Item. One or more Items are permitted in this sequence. See        select: label	   xrefstylesect_C.4.10.1   linkend   attrsxref   el.   descContent Item Modifier Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity3   req   iAn ICC Profile encoding the transformation of device-dependent color stored pixel values into PCS-Values.   See        select: label	   xrefstylesect_C.11.15.1.1   linkend   attrsxref   el.�When present, defines the color space of color Pixel Data (7FE0,0010) values, and the output of Palette Color Lookup Table Data (0028,1201-1203).      
                          �The profile applies only to Pixel Data (7FE0,0010) at the same level of the Data Set and not to any icons nested within sequences, which may or may not have their own ICC profile specified.   contentpara   el
                     contentnote   el   descICC Profile   name
Image Pixel   module   (0028,2000)   
U   usage   
N
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Common Instance Reference   module+   (0008,1115)[<0>](0008,114a)[<1>](0008,1155)   
M   usage   �
   mod_tables
Study   entity3   reqPerson's mailing address   descPerson's Address   name
General Study   module   (0008,1062)[<0>](0040,1102)   
M   usage   �
   mod_tables
Series   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
	RT Series   moduleK   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)[<3>](0008,1160)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity3   req9The minimum actual pixel value encountered in this image.   descSmallest Image Pixel Value   name
General Image   module   (0088,0200)[<0>](0028,0106)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-41table_10-11
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Structure Set   module   (3006,0018)[<0>](0008,1155)   
M   usage   �
   mod_tables
Dose   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1103)   
M   usage   
   mod_tables
Patient   entity3   req   �The place or location identifier where the identifier was first assigned to the patient. This component is not an inherent part of the identifier but rather part of the history of the identifier.1Only a single Item is permitted in this sequence.      
                      9Equivalent to HL7 v2 CX component 6 (Assigning Facility).   contentpara   el
                 contentnote   el   descAssigning Facility Sequence   name
Patient   module   (0010,0024)[<0>](0040,0036)   
M   usage   �
   mod_tables
Series   entity2   req1Name(s) of the operator(s) supporting the Series.   descOperators' Name   name
	RT Series   module   (0008,1070)   
M   usage    �
   mod_tables
Patient   entity3   req   �Universal or unique identifier for the Patient ID Assigning Authority. The authority identified by this attribute shall be the same as that of Issuer of Patient ID (0010,0021), if present.      
                      BEquivalent to HL7 v2 CX component 4 subcomponent 2 (Universal ID).   contentpara   el
                 contentnote   el   descUniversal Entity ID   name
Patient   module+   (0010,1002)[<0>](0010,0024)[<1>](0040,0032)   
M   usage   c
   mod_tables
Dose   entity1   req�Instance Identifier of the referenced HL7 Structured Document, encoded as a UID (OID or UUID), concatenated with a caret ("^") and Extension value (if Extension is present in Instance Identifier).   descHL7 Instance Identifier   name

SOP Common   module   (0040,a390)[<0>](0040,e001)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1C   req   �Specifies the format of the Red Palette Color Lookup Table Data (0028,1201). Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.5   linkend   attrsxref   el for further explanation.   desc)Red Palette Color Lookup Table Descriptor   name
Image Pixel   module   (0028,1101)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
General Image   module   (0008,1140)[<0>](0008,1150)   
WC - Required if dose data contains grid-based doses and pixel data is multi-frame data.   usage   
table_C.7-14
   mod_tables
Dose   entity1   req   rContains the Data Element Tag of the attribute that is used as the frame increment in Multi-frame pixel data. See        select: label	   xrefstylesect_C.7.6.6.1.2   linkend   attrsxref   el for further explanation.   descFrame Increment Pointer   name
Multi-frame   module   (0028,0009)   
U   usage    �
   mod_tables
Dose   entity1   req   2Sequence of referenced ROIs used to calculate DVH.5One or more items shall be included in this sequence.   descDVH Referenced ROI Sequence   name
RT DVH   module   (3004,0050)[<0>](3004,0060)   
M   usage   =
   mod_tables
Series   entity1C   req   �The integer numerator of a rational representation of Numeric Value (0040,A30A). Encoded as a signed integer value. The same number of values as Numeric Value (0040,A30A) shall be present.�Required if Numeric Value (0040,A30A) has insufficient precision to represent a rational value as a string. May be present otherwise.   descRational Numerator Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a162)   
M   usage   c
   mod_tables
Dose   entity1C   req   2Sequence of Items containing encrypted DICOM data.5One or more Items shall be included in this sequence.   �Required if application level confidentiality is needed and certain recipients are allowed to decrypt all or portions of the Encrypted Attributes Data Set. See        select: label	   xrefstylesect_C.12.1.1.4.1   linkend   attrsxref   el.   descEncrypted Attributes Sequence   name

SOP Common   module   (0400,0500)   
U   usage   
   mod_tables
Dose   entity1C   req   LUT Data in this Sequence.:Required if the Modality LUT Sequence (0028,3000) is sent.   descLUT Data   name
Modality LUT   module   (0028,3000)[<0>](0028,3006)   
M   usage   c
   mod_tables
Dose   entity3   req�Retrieval access path to HL7 Structured Document. Includes fully specified scheme, authority, path, and query in accordance with RFC 2396   descRetrieve URI   name

SOP Common   module   (0040,a390)[<0>](0040,e010)   
M   usage   
table_C.12-1
table_10-3table_10-11
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name

SOP Common   module   (0020,9172)[<0>](0008,1155)   
M   usage   �
   mod_tables
Dose   entity3   req   $Sequence holding Digital Signatures.1One or more items are permitted in this sequence.   descDigital Signatures Sequence   name

SOP Common   module   (fffa,fffa)   
M   usage   �
   mod_tables
	Equipment   entity3   req   TManufacturer's serial number of the equipment that produced the composite instances.      
                          �This identifier corresponds to the device that actually created the images, such as a CR plate reader or a CT console, and may not be sufficient to identify all of the equipment in the imaging chain, such as the generator or gantry or plate.   contentpara   el
                     contentnote   el   descDevice Serial Number   name
General Equipment   module   (0018,1000)   
M   usage   
   mod_tables
Patient   entity3   req   �Universal or unique identifier for the Patient ID Assigning Authority. The authority identified by this attribute shall be the same as that of Issuer of Patient ID (0010,0021), if present.      
                      BEquivalent to HL7 v2 CX component 4 subcomponent 2 (Universal ID).   contentpara   el
                 contentnote   el   descUniversal Entity ID   name
Patient   module   (0010,0024)[<0>](0040,0032)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity1   req%User-defined label for Structure Set.   descStructure Set Label   name
Structure Set   module   (3006,0002)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity1   req�Uniquely identifies Frame of Reference in which ROI is defined, specified by Frame of Reference UID (0020,0052) in Referenced Frame of Reference Sequence (3006,0010).   desc!Referenced Frame of Reference UID   name
Structure Set   module   (3006,0020)[<0>](3006,0024)   
M   usage    �
   mod_tables
Series   entity1C   req   �The integer numerator of a rational representation of Numeric Value (0040,A30A). Encoded as a signed integer value. The same number of values as Numeric Value (0040,A30A) shall be present.�Required if Numeric Value (0040,A30A) has insufficient precision to represent a rational value as a string. May be present otherwise.   descRational Numerator Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a162)   
M   usage   c
   mod_tables
Dose   entity1C   req   ^The view requested during the C-MOVE operation that resulted in the transfer of this instance.   
variablelist   typeEnumerated Values:   title      CLASSIC   ENHANCED   listRequired if the instance has ever been converted from its source form as the result of a C-MOVE operation with a specific view.   descQuery/Retrieve View   name

SOP Common   module   (0008,0053)   
M   usage   �
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name

SOP Common   module   (0040,a390)[<0>](0008,1150)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity2   req.Date at which Structure Set was last modified.   descStructure Set Date   name
Structure Set   module   (3006,0008)   
U   usage   X
   mod_tables
Study   entity3   req$Weight of the Patient, in kilograms.   descPatient's Weight   name
Patient Study   module   (0010,1030)   
M   usage   l
   mod_tables
Series   entity3   reqJAn identifier of the Imaging Service Request for this Requested Procedure.   descAccession Number   name
	RT Series   module   (0040,0275)[<0>](0008,0050)   
4C - Required if dose data contains grid-based doses.   usage   
s
   mod_tables
Dose   entity1   req   {The x, y, and z coordinates of the upper left hand corner (center of the first voxel transmitted) of the image, in mm. See        select: label	   xrefstylesect_C.7.6.2.1.1   linkend   attrsxref   el for further explanation.   descImage Position (Patient)   name
Image Plane   module   (0020,0032)   
M   usage   
   mod_tables
Patient   entity3   req   pThe agency or department that assigned the patient identifier. Only a single Item is permitted in this sequence.      
                      <Equivalent to HL7 v2 CX component 10 (Identifier Type Code).   contentpara   el
                 contentnote   el   desc,Assigning Agency or Department Code Sequence   name
Patient   module   (0010,0024)[<0>](0040,003a)   
U   usage   X
   mod_tables
Study   entity3   req   Patient's size category code1One or more Items are permitted in this sequence.   descPatient's Size Code Sequence   name
Patient Study   module   (0010,1021)   
M   usage   �
   mod_tables
Dose   entity1C   req   �Sequence describing RT Plan associated with dose. Required if Dose Summation Type (3004,000A) is PLAN, MULTI_PLAN, FRACTION, BEAM, BRACHY, FRACTION_SESSION, BEAM_SESSION, BRACHY_SESSION or CONTROL_POINT.�Only a single item shall be included in this sequence, unless Dose Summation Type (3004,000A) is MULTI_PLAN, in which case two or more items shall be included in this sequence. See Note 1.   descReferenced RT Plan Sequence   name
RT Dose   module   (300c,0002)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   eUnique identification of the irradiation event(s) associated with the acquisition of this image. See        select: label	   xrefstylesect_C.7.6.1.1.7   linkend   attrsxref   el.   descIrradiation Event UID   name
General Image   module   (0008,3010)   
M   usage   =
   mod_tables
Series   entity1   req   6The type of the value encoded in this name-value Item.   
variablelist   typeEnumerated Values:   title
      DATE   TIME   DATETIME   PNAME   UIDREF   TEXT   CODE   NUMERIC   	COMPOSITE   IMAGE   list   desc
Value Type   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a040)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   �Blue Palette Color Lookup Table Data. Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.6   linkend   attrsxref   el for further explanation.   desc$Blue Palette Color Lookup Table Data   name
General Image   module   (0088,0200)[<0>](0028,1203)   
M   usage    �
   mod_tables
Series   entity1   req   6The type of the value encoded in this name-value Item.   
variablelist   typeEnumerated Values:   title
      DATE   TIME   DATETIME   PNAME   UIDREF   TEXT   CODE   NUMERIC   	COMPOSITE   IMAGE   list   desc
Value Type   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a040)   
M   usage   =
   mod_tables
Series   entity1C   req   @Composite SOP Instance Reference value for this name-value Item.6Only a single Item shall be included in this Sequence.9Required if Value Type (0040,A040) is COMPOSITE or IMAGE.   descReferenced SOP Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)   
M   usage   �
   mod_tables
Dose   entity1   req   "The MAC generated as described in        select: label	   xrefstylesect_C.12.1.1.3.1.1   linkend   attrsxref   el and encrypted using the algorithm, parameters, and private key associated with the Certificate of the Signer (0400,0115). See        select: label	   xrefstylesect_C.12.1.1.3.1.2   linkend   attrsxref   el.   desc	Signature   name

SOP Common   module   (fffa,fffa)[<0>](0400,0120)   
M   usage   l
   mod_tables
Series   entity3   req   FA sequence that conveys the Procedure Type of the requested procedure.1Only a single Item is permitted in this sequence.   desc!Requested Procedure Code Sequence   name
	RT Series   module   (0040,0275)[<0>](0032,1064)   
U   usage   X
   mod_tables
Study   entity3   req)Length or size of the Patient, in meters.   descPatient's Size   name
Patient Study   module   (0010,1020)   
U   usage   
table_C.7-4atable_10-17
   mod_tables
Study   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   Enumerated Values:   title
variablelist   type      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
Patient Study   module   (0038,0014)[<0>](0040,0033)   
M   usage   =
   mod_tables
Series   entity1C   req   ,Coded concept value of this name-value Item.6Only a single Item shall be included in this Sequence.+Required if Value Type (0040,A040) is CODE.   descConcept Code Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a168)   
M   usage   �
   mod_tables
Dose   entity1   req   ,The type of certificate used in (0400,0115).   Defined Terms:   title
variablelist   type      X509_1993_SIG   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descCertificate Type   name

SOP Common   module   (fffa,fffa)[<0>](0400,0110)   
M   usage   �
   mod_tables
Series   entity3   req   ]Uniquely identifies the Performed Procedure Step SOP Instance to which the Series is related.1One or more items are permitted in this sequence.   desc,Referenced Performed Procedure Step Sequence   name
	RT Series   module   (0008,1111)   
M   usage   
table_C.7-3table_10-11
   mod_tables
Study   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
General Study   module   (0008,1110)[<0>](0008,1155)   
M   usage    �
   mod_tables
Series   entity1C   req   AUnits of measurement for a numeric value in this name-value Item.6Only a single Item shall be included in this Sequence..Required if Value Type (0040,A040) is NUMERIC.   descMeasurement Units Code Sequence   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,08ea)   
M   usage    �
   mod_tables
Series   entity1C   req   $Time value for this name-value Item.+Required if Value Type (0040,A040) is TIME.   descTime   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a122)   
M   usage   �
   mod_tables
Series   entity1   req   6The type of the value encoded in this name-value Item.   
variablelist   typeEnumerated Values:   title
      DATE   TIME   DATETIME   PNAME   UIDREF   TEXT   CODE   NUMERIC   	COMPOSITE   IMAGE   list   desc
Value Type   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a040)   
U   usage   
table_C.8-40table_10-11
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
RT DVH   module   (300c,0060)[<0>](0008,1150)   
@C - Required if dose data contains dose points or isodose curves   usage    
   mod_tables
Dose   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
ROI Contour   module;   (3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1160)   
M   usage   c
   mod_tables
Dose   entity1   req0May include Sequence Attributes and their Items.   descBAny Attribute from the main data set that was modified or removed.   name

SOP Common   module)   (0400,0561)[<0>](0400,0550)[0](gggg,eeee)   
M   usage   c
   mod_tables
Dose   entity3   req   �The SOP Class in which the Instance was originally encoded that has been replaced during a fall-back conversion to the current Related General SOP Class. See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   desc"Original Specialized SOP Class UID   name

SOP Common   module   (0008,001b)   
U   usage   
�
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Common Instance Reference   module;   (0008,1200)[<0>](0008,1115)[<1>](0008,114a)[<2>](0008,1155)   
M   usage   �
   mod_tables
Series   entity1C   req   $Time value for this name-value Item.+Required if Value Type (0040,A040) is TIME.   descTime   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a122)   
M   usage   l
   mod_tables
Series   entity3   req   NUniquely identifies the Study SOP Instances associated with this SOP Instance.1One or more items are permitted in this sequence.   See        select: label	   xrefstylesect_10.6.1   linkend   attrsxref   el.   descReferenced Study Sequence   name
	RT Series   module   (0040,0275)[<0>](0008,1110)   
M   usage   
   mod_tables
Study   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
General Study   module   (0008,1110)[<0>](0008,1150)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1   req   nNumber of bits allocated for each pixel sample. Each sample shall have the same number of bits allocated. See        PS3.5	   targetdocselect: labelnumber	   xrefstylePS3.5	   targetptr   attrsolink   el for further explanation.   descBits Allocated   name
General Image   module   (0088,0200)[<0>](0028,0100)   
M   usage   �
   mod_tables
Dose   entity1C   req�Sequence of Brachy Application Setups in current Fraction Group contributing to dose. Required if Dose Summation Type (3004,000A) is BRACHY or BRACHY_SESSION. One or more items shall be included in this sequence.   desc,Referenced Brachy Application Setup Sequence   name
RT Dose   module+   (300c,0002)[<0>](300c,0020)[<1>](300c,000a)   
M   usage    _
   mod_tables
Patient   entity3   req)Other names used to identify the patient.   descOther Patient Names   name
Patient   module   (0010,1001)   
M   usage   �
   mod_tables
Dose   entity1   req   �A list of Data Element Tags in the order they appear in the Data Set that identify the Data Elements used in creating the MAC for the Digital Signature. See        select: label	   xrefstylesect_C.12.1.1.3.1.1   linkend   attrsxref   el.   descData Elements Signed   name

SOP Common   module   (4ffe,0001)[<0>](0400,0020)   
M   usage    �
   mod_tables
Study   entity2   reqTime the Study started.   desc
Study Time   name
General Study   module   (0008,0030)   
U   usage   b
   mod_tables
Study   entity3   req   vA Sequence that conveys information about consent for Clinical Trial use of the composite instances within this Study.1One or more Items are permitted in this sequence.   See        select: label	   xrefstylesect_C.7.2.3.1.2   linkend   attrsxref   el.   desc'Consent for Clinical Trial Use Sequence   name
Clinical Trial Study   module   (0012,0083)   
M   usage    _
   mod_tables
Patient   entity2C   req   LName of organization with medical decision making authority for the patient.;Required if patient is an animal. May be present otherwise.   descResponsible Organization   name
Patient   module   (0010,2299)   
M   usage   �
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   moduleK   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)[<3>](0008,1150)   
M   usage    �
   mod_tables
Study   entity3   req   ]Names of the physician(s) who are responsible for overall patient care at time of Study (see        select: label	   xrefstylesect_C.7.3.1   linkend   attrsxref   el for Performing Physician)   descPhysician(s) of Record   name
General Study   module   (0008,1048)   
U   usage   	'
   mod_tables
Series   entity2   req   vThe name of the institution that is responsible for coordinating the medical imaging data for the clinical trial. See        select: label	   xrefstylesect_C.7.3.2.1.1   linkend   attrsxref   el.   desc'Clinical Trial Coordinating Center Name   name
Clinical Trial Series   module   (0012,0060)   
M   usage   M
   mod_tables
Frame of Reference   entity2   req   4Part of the imaging target used as a reference. See        select: label	   xrefstylesect_C.7.4.1.1.2   linkend   attrsxref   el for further explanation.   descPosition Reference Indicator   name
Frame of Reference   module   (0020,1040)   
M   usage   �
   mod_tables
Series   entity1C   req   @Composite SOP Instance Reference value for this name-value Item.6Only a single Item shall be included in this Sequence.9Required if Value Type (0040,A040) is COMPOSITE or IMAGE.   descReferenced SOP Sequence   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)   
M   usage   �
   mod_tables
Series   entity3   req�Sequence that specifies the context for the Performed Protocol Code Sequence Item. One or more Items are permitted in this sequence.   descProtocol Context Sequence   name
	RT Series   module   (0040,0260)[<0>](0040,0440)   
M   usage   �
   mod_tables
Series   entity3   req   "A coded description of the Series.1Only a single Item is permitted in this sequence.   desc Series Description Code Sequence   name
	RT Series   module   (0008,103f)   
M   usage    �
   mod_tables
Patient   entity3   req   pThe agency or department that assigned the patient identifier. Only a single Item is permitted in this sequence.      
                      <Equivalent to HL7 v2 CX component 10 (Identifier Type Code).   contentpara   el
                 contentnote   el   desc,Assigning Agency or Department Code Sequence   name
Patient   module+   (0010,1002)[<0>](0010,0024)[<1>](0040,003a)   
M   usage    �
   mod_tables
Patient   entity3   req   lAttributes specifying or qualifying the identity of the issuer of the Patient ID, or scoping the Patient ID.1Only a single Item is permitted in this sequence.   desc(Issuer of Patient ID Qualifiers Sequence   name
Patient   module   (0010,1002)[<0>](0010,0024)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity3   req9The maximum actual pixel value encountered in this image.   descLargest Image Pixel Value   name
Image Pixel   module   (0028,0107)   
M   usage   �
   mod_tables
Series   entity3   requSequence describing the Protocol performed for this Procedure Step. One or more Items are permitted in this sequence.   desc Performed Protocol Code Sequence   name
	RT Series   module   (0040,0260)   
M   usage   �
   mod_tables
Series   entity3   req6User-defined comments on the Performed Procedure Step.   desc(Comments on the Performed Procedure Step   name
	RT Series   module   (0040,0280)   
M   usage   /
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0008,1199)[<3>](0008,1150)   
M   usage    _
   mod_tables
Patient   entity2C   req      The breed of the patient. See        select: label	   xrefstylesect_C.7.1.1.1.1   linkend   attrsxref   el.6Zero or more Items shall be included in this sequence.%Required if the patient is an animal.   descPatient Breed Code Sequence   name
Patient   module   (0010,2293)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity1   req      dSequence of (x,y,z) triplets defining a contour in the patient based coordinate system described in        select: label	   xrefstylesect_C.7.6.2.1.1   linkend   attrsxref   el (mm). See        select: label	   xrefstylesect_C.8.8.6.1   linkend   attrsxref   el and        select: label	   xrefstylesect_C.8.8.6.3   linkend   attrsxref   el.      
                          �Contour Data may not be properly encoded if Explicit VR transfer syntax is used and the VL of this attribute exceeds 65534 bytes.   contentpara   el
                     contentnote   el   descContour Data   name
ROI Contour   module+   (3006,0039)[<0>](3006,0040)[<1>](3006,0050)   
U   usage   �
   mod_tables
Dose   entity3   req(User-defined comments about the overlay.   descOverlay Description   name
Overlay Plane   module   (60xx,0022)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity1   req7Unique identifier for the series containing the images.   descSeries Instance UID   name
Structure Set   module;   (3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](0020,000e)   
M   usage   �
   mod_tables
Dose   entity3   req   gA sequence of items that describe the parameters used to calculate a MAC for use in Digital Signatures.5One or more Items shall be included in this sequence.   descMAC Parameters Sequence   name

SOP Common   module   (4ffe,0001)   
U   usage   X
   mod_tables
Study   entity3   req   KIdentifier of the Assigning Authority that issued Admission ID (0038,0010).1Only a single Item is permitted in this sequence.   descIssuer of Admission ID Sequence   name
Patient Study   module   (0038,0014)   
M   usage   �
   mod_tables
Series   entity2   req%A number that identifies this series.   descSeries Number   name
	RT Series   module   (0020,0011)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   QA label for the lossy compression method(s) that have been applied to this image.   See        select: label	   xrefstylesect_C.7.6.1.1.5   linkend   attrsxref   el for further explanation.�May be multivalued if successive lossy compression steps have been applied; the value order shall correspond to the values of Lossy Image Compression Ratio (0028,2112).      
                          qFor historical reasons, the lossy compression method may also be described in Derivation Description (0008,2111).   contentpara   el
                     contentnote   el   descLossy Image Compression Method   name
General Image   module   (0028,2114)   
M   usage   �
   mod_tables
Dose   entity3   req$User-defined comments for dose data.   descDose Comment   name
RT Dose   module   (3004,0006)   
U   usage    �
   mod_tables
Dose   entity3   reqWMaximum calculated dose to ROI(s) described by DVH Referenced ROI Sequence (3004,0060).   descDVH Maximum Dose   name
RT DVH   module   (3004,0050)[<0>](3004,0072)   
U   usage   b
   mod_tables
Study   entity1   req   qWhether or not consent to distribute has been granted for the purpose described in Distribution Type (0012,0084).   
variablelist   typeEnumerated Values:   title      NO   YES   	WITHDRAWN   list   See        select: label	   xrefstylesect_C.7.2.3.1.2   linkend   attrsxref   el.      
                          Q  Under some circumstances, consent may be withdrawn. The purpose of encoding this is to warn receiving systems that further distribution may not be appropriate, but no semantics are defined by the Standard for what action is appropriate under such circumstances, such as what to do with previously received images that had a value of YES.   contentpara   el
                     contentnote   el   descConsent for Distribution Flag   name
Clinical Trial Study   module   (0012,0083)[<0>](0012,0085)   
M   usage    �
   mod_tables
Series   entity1C   req   `Identifies the segments to which the reference applies identified by Segment Number (0062,0004).�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0008,1199)[<3>](0062,000b)   
M   usage   
table_C.7-3table_10-17
   mod_tables
Study   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
General Study   module   (0008,0051)[<0>](0040,0032)   
M   usage   �
   mod_tables
Series   entity1C   req   +Person name value for this name-value Item.,Required if Value Type (0040,A040) is PNAME.   descPerson Name   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a123)   
M   usage   c
   mod_tables
Dose   entity3   req9Name(s) of the operator(s) of the contributing equipment.   descOperators' Name   name

SOP Common   module   (0018,a001)[<0>](0008,1070)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   �Indicates whether the pixel data are sent color-by-plane or color-by-pixel. Required if Samples per Pixel (0028,0002) has a value greater than 1. See        select: label	   xrefstylesect_C.7.6.3.1.3   linkend   attrsxref   el for further explanation.   descPlanar Configuration   name
General Image   module   (0088,0200)[<0>](0028,0006)   
4C - Required if dose data contains grid-based doses.   usage   L
   mod_tables
Dose   entity1C   req   UThe Slope value in relationship between stored values (SV) and the real world values.   See        select: label	   xrefstylesect_C.7.6.16.2.11.1.2   linkend   attrsxref   el for further explanation.ARequired if Real World Value LUT Data (0040,9212) is not present.   descReal World Value Slope   name
General Image   module   (0040,9096)[<0>](0040,9225)   
@C - Required if dose data contains dose points or isodose curves   usage   
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Structure Set   module+   (3006,0010)[<0>](3006,0012)[<1>](0008,1155)   
M   usage   �
   mod_tables
Series   entity3   reqDescription of the series.   descSeries Description   name
	RT Series   module   (0008,103e)   
M   usage   �
   mod_tables
Series   entity1C   req   #UID value for this name-value Item.-Required if Value Type (0040,A040) is UIDREF.   descUID   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a124)   
M   usage    _
   mod_tables
Patient   entity2   req   Sex of the named patient.   
variablelist   typeEnumerated Values:   title      Mmale   Ffemale   Oother   list   descPatient's Sex   name
Patient   module   (0010,0040)   
M   usage   �
   mod_tables
Series   entity1C   req   AUnits of measurement for a numeric value in this name-value Item.6Only a single Item shall be included in this Sequence..Required if Value Type (0040,A040) is NUMERIC.   descMeasurement Units Code Sequence   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,08ea)      
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   req   _Data representation of the pixel samples. Each sample shall have the same pixel representation.   
variablelist   typeEnumerated Values:   title      0000Hunsigned integer.   0001H2's complement   list   descPixel Representation   name
Image Pixel   module   
M   usage   �
   mod_tables
Dose   entity1C   req   dData representation of the pixel samples. Each sample shall have the same pixel representation. See        select: label	   xrefstylesect_C.8.8.3.4.6   linkend   attrsxref   el@ for specialization. Required Pixel Data (7FE0,0010) is present.   descPixel Representation   name
RT Dose   module   (0028,0103)   
M   usage   �
   mod_tables
	Equipment   entity3   reqhMailing address of the institution where the equipment that produced the composite instances is located.   descInstitution Address   name
General Equipment   module   (0008,0081)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   Other images significantly related to this image (e.g., post-localizer CT image or Mammographic biopsy or partial view images).1One or more Items are permitted in this sequence.   descReferenced Image Sequence   name
General Image   module   (0008,1140)   
M   usage   c
   mod_tables
Dose   entity1C   req   XThe set of images or other composite SOP Instances that were converted to this instance.zIf this instance was converted from a specific frame in the source instance, the reference shall include the Frame Number.5One or more Items shall be included in this sequence.�Required if this instance was created by conversion, and Conversion Source Attributes Sequence (0020,9172) is not present in an Item of Shared Functional Groups Sequence (5200,9229) or Per-Frame Functional Groups Sequence (5200,9230).   desc%Conversion Source Attributes Sequence   name

SOP Common   module   (0020,9172)   
WC - Required if dose data contains grid-based doses and pixel data is multi-frame data.   usage   �
   mod_tables
Dose   entity1   req   -Number of frames in a Multi-frame Image. See        select: label	   xrefstylesect_C.7.6.6.1.1   linkend   attrsxref   el for further explanation.   descNumber of Frames   name
Multi-frame   module   (0028,0008)   
M   usage   �
   mod_tables
Series   entity1   req   6The type of the value encoded in this name-value Item.   
variablelist   typeEnumerated Values:   title
      DATE   TIME   DATETIME   PNAME   UIDREF   TEXT   CODE   NUMERIC   	COMPOSITE   IMAGE   list   desc
Value Type   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a040)   
M   usage   c
   mod_tables
Dose   entity3   req   �Sequence of items that map values of Coding Scheme Designator (0008,0102) to an external coding system registration, or to a private or local coding scheme.1One or more Items are permitted in this sequence.   desc%Coding Scheme Identification Sequence   name

SOP Common   module   (0008,0110)   
U   usage   v
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
RT DVH   module   (300c,0060)[<0>](0008,1155)   
M   usage   �
   mod_tables
Series   entity1C   req   +Person name value for this name-value Item.,Required if Value Type (0040,A040) is PNAME.   descPerson Name   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a123)   
M   usage    �
   mod_tables
Study   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name
General Study   module   (0008,1049)[<0>](0040,1101)   
M   usage    _
   mod_tables
Patient   entity1C   req   2Relationship of Responsible Person to the patient.   See        select: label	   xrefstylesect_C.7.1.1.1.2   linkend   attrsxref   el for Defined Terms.:Required if Responsible Person is present and has a value.   descResponsible Person Role   name
Patient   module   (0010,2298)   
M   usage   c
   mod_tables
Dose   entity3   req   rTime when the image acquisition device calibration was last changed in any way. Multiple entries may be used. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descTime of Last Calibration   name

SOP Common   module   (0018,a001)[<0>](0018,1201)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   �Red Palette Color Lookup Table Data. Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.6   linkend   attrsxref   el for further explanation.   desc#Red Palette Color Lookup Table Data   name
General Image   module   (0088,0200)[<0>](0028,1201)   
M   usage    �
   mod_tables
Study   entity3   req   GIdentifier of the Assigning Authority that issued the Accession Number.1Only a single Item is permitted in this sequence.   desc#Issuer of Accession Number Sequence   name
General Study   module   (0008,0051)   
U   usage   
   mod_tables
Dose   entity1C   req   =m in the equation specified by Rescale Intercept (0028,1052).)Required if Rescale Intercept is present.   descRescale Slope   name
Modality LUT   module   (0028,1053)   
ZC - Required if the SOP Instance was created in response to a Frame-Level retrieve request   usage   �
   mod_tables
Dose   entity1   reqBSOP Instance from which the frames of this instance are extracted.   desc#Multi-frame Source SOP Instance UID   name
Frame Extraction   module   (0008,1164)[<0>](0008,1167)   
U   usage   X
   mod_tables
Study   entity3   req   <A sequence that conveys the admitting diagnosis (diagnoses).1One or more Items are permitted in this Sequence.   desc!Admitting Diagnoses Code Sequence   name
Patient Study   module   (0008,1084)   
M   usage    _
   mod_tables
Patient   entity1   req7Identification number of an animal within the registry.   descBreed Registration Number   name
Patient   module   (0010,2294)[<0>](0010,2295)   
M   usage    _
   mod_tables
Patient   entity1C   req   �A description or label of the mechanism or method use to remove the patient's identity. May be multi-valued if successive de-identification steps have been performed.      
                           arabic
   numeration   attrs   
                            
                              �This may be used to describe the extent or thoroughness of the de-identification, for example whether or not the de-identification is for a "Limited Data Set" (as per HIPAA Privacy Rule).   contentpara   el
                         contentlistitem   el
                            
                              <  The characteristics of the de-identifying equipment and/or the responsible operator of that equipment may be recorded as an additional item of the Contributing Equipment Sequence (0018,A001) in the SOP Common Module. De-identifying equipment may use a Purpose of Reference of (109104,DCM,"De-identifying Equipment").   contentpara   el
                         contentlistitem   el
                       contentorderedlist   el
                     contentnote   el�Required if Patient Identity Removed (0012,0062) is present and has a value of YES and De-identification Method Code Sequence (0012,0064) is not present. May be present otherwise.   descDe-identification Method   name
Patient   module   (0012,0063)   
M   usage   c
   mod_tables
Dose   entity3   reqVManufacturer's model name of the equipment that contributed to the composite instance.   descManufacturer's Model Name   name

SOP Common   module   (0018,a001)[<0>](0008,1090)   
U   usage   X
   mod_tables
Study   entity3   req   UIdentifier of the Assigning Authority that issued the Service Episode ID (0038,0060).1Only a single Item is permitted in this sequence.   desc%Issuer of Service Episode ID Sequence   name
Patient Study   module   (0038,0064)   
U   usage   X
   mod_tables
Study   entity3   req;Additional information about the Patient's medical history.   descAdditional Patient History   name
Patient Study   module   (0010,21b0)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1C   req   �Indicates whether the pixel data are sent color-by-plane or color-by-pixel. Required if Samples per Pixel (0028,0002) has a value greater than 1. See        select: label	   xrefstylesect_C.7.6.3.1.3   linkend   attrsxref   el for further explanation.   descPlanar Configuration   name
Image Pixel   module   (0028,0006)   
M   usage   �
   mod_tables
	Equipment   entity1C   req      �Single pixel value or one limit (inclusive) of a range of pixel values used in an image to pad to rectangular format or to signal background that may be suppressed. See        select: label	   xrefstylesect_C.7.5.1.1.2   linkend   attrsxref   el for further explanation.�Required if Pixel Padding Range Limit (0028,0121) is present and either Pixel Data (7FE0,0010) or Pixel Data Provider URL (0028,7FE0) is present. May be present otherwise only if Pixel Data (7FE0,0010) or Pixel Data Provider URL (0028,7FE0) is present.      
                           arabic
   numeration   attrs   
                            
                              jThe Value Representation of this Attribute is determined by the value of Pixel Representation (0028,0103).   contentpara   el
                         contentlistitem   el
                            
                              �This Attribute is not used in Presentation State Instances; there is no means in a Presentation State to "override" any Pixel Padding Value specified in the referenced images.   contentpara   el
                         contentlistitem   el
                            
                              _This Attribute does apply to RT Dose and Segmentation instances, since they include Pixel Data.   contentpara   el
                         contentlistitem   el
                       contentorderedlist   el
                     contentnote   el   descPixel Padding Value   name
General Equipment   module   (0028,0120)   
M   usage    �
   mod_tables
Series   entity1C   req   $Text value for this name-value Item.+Required if Value Type (0040,A040) is TEXT.   desc
Text Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a160)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity3   reqTSequence of Contours defining ROI. One or more items are permitted in this sequence.   descContour Sequence   name
ROI Contour   module   (3006,0039)[<0>](3006,0040)   
M   usage    �
   mod_tables
Study   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name
General Study   module   (0008,0096)[<0>](0008,0080)   
M   usage   �
   mod_tables
Dose   entity1   req   Type of dose.   
variablelist   typeDefined Terms:   title      PHYSICALphysical dose   	EFFECTIVEZphysical dose after correction for biological effect using user-defined modeling technique   ERROR+difference between desired and planned dose   list   desc	Dose Type   name
RT Dose   module   (3004,0004)   
M   usage   �
   mod_tables
Dose   entity1   req   Type of dose summation.   
variablelist   typeDefined Terms:   title	      PLANEdose calculated for entire delivery of all fraction groups of RT Plan   
MULTI_PLAN9dose calculated for entire delivery of 2 or more RT Plans   FRACTIONMdose calculated for entire delivery of a single Fraction Group within RT Plan   BEAMGdose calculated for entire delivery of one or more Beams within RT Plan   BRACHY[dose calculated for entire delivery of one or more Brachy Application Setups within RT Plan   FRACTION_SESSION[dose calculated for a single session ("fraction") of a single Fraction Group within RT Plan   BEAM_SESSIONUdose calculated for a single session ("fraction") of one or more Beams within RT Plan   BRACHY_SESSIONidose calculated for a single session ("fraction") of one or more Brachy Application Setups within RT Plan   CONTROL_POINTRdose calculated for one or more Control Points within a Beam for a single fraction   list   descDose Summation Type   name
RT Dose   module   (3004,000a)   
M   usage   =
   mod_tables
Series   entity1C   req   AUnits of measurement for a numeric value in this name-value Item.6Only a single Item shall be included in this Sequence..Required if Value Type (0040,A040) is NUMERIC.   descMeasurement Units Code Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,08ea)   
M   usage   c
   mod_tables
Dose   entity3   req   �Contains the offset from UTC to the timezone for all DA and TM Attributes present in this SOP Instance, and for all DT Attributes present in this SOP Instance that do not contain an explicitly encoded timezone offset.�Encoded as an ASCII string in the format "&ZZXX". The components of this string, from left to right, are & = "+" or "-", and ZZ = Hours and XX = Minutes of offset. Leading space characters shall not be present.;The offset for UTC shall be +0000; -0000 shall not be used.      
                         arabic
   numeration   attrs	   
                          
                            *This encoding is the same as described in        select: labelnumber	   xrefstylePS3.5	   targetdocPS3.5	   targetptr   attrsolink   el9 for the offset component of the DT Value Representation.   contentpara   el
                       contentlistitem   el
                          
                            |This Attribute does not apply to values with a DT Value Representation, that contains an explicitly encoded timezone offset.   contentpara   el
                       contentlistitem   el
                          
                            �The corrected time may cross a 24 hour boundary. For example, if Local Time = 1.00 a.m. and Offset = +0200, then UTC = 11.00 p.m. (23.00) the day before.   contentpara   el
                       contentlistitem   el
                          
                             The "+" sign may not be omitted.   contentpara   el
                       contentlistitem   el
                     contentorderedlist   el
                   contentnote   el8Time earlier than UTC is expressed as a negative offset.   	   
                        For example:   contentpara   el
                        UTC = 5.00 a.m.   contentpara   el
                        Local Time = 3.00 a.m.   contentpara   el
                        Offset = -0200   contentpara   el
                   contentnote   elCThe local timezone offset is undefined if this Attribute is absent.   descTimezone Offset From UTC   name

SOP Common   module   (0008,0201)   
M   usage    �
   mod_tables
Study   entity3   reqPerson's mailing address   descPerson's Address   name
General Study   module   (0008,0096)[<0>](0040,1102)   
M   usage   
table_C.8-39table_10-11
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
RT Dose   module   (0070,0404)[<0>](0008,1150)   
ZC - Required if the SOP Instance was created in response to a Frame-Level retrieve request   usage   �
   mod_tables
Dose   entity1C   req   HA list of Frames that were extracted in the form of one or more tripletswRequired if object extraction is based on a Frame Level Retrieve using the Calculated Frame List (0008,1162) attribute.   See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el0 "Instance and Frame Level Retrieve SOP Classes"   descCalculated Frame List   name
Frame Extraction   module   (0008,1164)[<0>](0008,1162)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   reqoA number identifying the single continuous gathering of data over a period of time that resulted in this image.   descAcquisition Number   name
General Image   module   (0020,0012)   
M   usage   
table_C.7-1table_10-18table_10-17
   mod_tables
Patient   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   
variablelist   typeEnumerated Values:   title      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
Patient   module;   (0010,1002)[<0>](0010,0024)[<1>](0040,0036)[<2>](0040,0033)   
U   usage   b
   mod_tables
Study   entity2   req   �An identifier specifying the one or more studies that are grouped together as a clinical time point or submission in a clinical trial. See        select: label	   xrefstylesect_C.7.2.3.1.1   linkend   attrsxref   el.   descClinical Trial Time Point ID   name
Clinical Trial Study   module   (0012,0050)   
M   usage   �
   mod_tables
Series   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   
variablelist   typeEnumerated Values:   title      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
	RT Series   module+   (0040,0275)[<0>](0008,0051)[<1>](0040,0033)   
M   usage   l
   mod_tables
Series   entity3   reqZInstitution-generated administrative description or classification of Requested Procedure.   descRequested Procedure Description   name
	RT Series   module   (0040,0275)[<0>](0032,1060)   
@C - Required if dose data contains dose points or isodose curves   usage   �
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Structure Set   moduleK   (3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)[<3>](0008,1150)   
M   usage   �
   mod_tables
Series   entity3   req1Time at which the Performed Procedure Step ended.   desc!Performed Procedure Step End Time   name
	RT Series   module   (0040,0251)      
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity2   req   $A number that identifies this image.      
                          KThis Attribute was named Image Number in earlier versions of this Standard.   contentpara   el
                     contentnote   el   descInstance Number   name
General Image   module   
M   usage   �
   mod_tables
Dose   entity3   req.A number that identifies this object instance.   descInstance Number   name
RT Dose   module   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req.A number that identifies this object instance.   descInstance Number   name
Structure Set   module   
M   usage   c
   mod_tables
Dose   entity3   req8A number that identifies this Composite object instance.   descInstance Number   name

SOP Common   module   (0020,0013)   
M   usage    _
   mod_tables
Patient   entity3   reqCOther identification numbers or codes used to identify the patient.   descOther Patient IDs   name
Patient   module   (0010,1000)   
U   usage   �
   mod_tables
Patient   entity2   req   -The name of the clinical trial protocol. See        select: label	   xrefstylesect_C.7.1.3.1.3   linkend   attrsxref   el.   descClinical Trial Protocol Name   name
Clinical Trial Subject   module   (0012,0021)   
U   usage   �
   mod_tables
Dose   entity1   req   YLocation of first overlay point with respect to pixels in the image, given as row\column.9The upper left pixel of the image has the coordinate 1\1.  Column values greater than 1 indicate the overlay plane origin is to the right of the image origin. Row values greater than 1 indicate the overlay plane origin is below the image origin. Values less than 1 indicate the overlay plane origin is above or to the left of the image origin.      
                        pValues of 0\0 indicate that the overlay pixels start 1 row above and one column to the left of the image pixels.   contentpara   el
                   contentnote   el   descOverlay Origin   name
Overlay Plane   module   (60xx,0050)   
M   usage   c
   mod_tables
Dose   entity1C   req   �The name of the external registry where further definition of the identified coding scheme may be obtained. Required if coding scheme is registered.   
variablelist   typeDefined Terms:   title      HL7   list   descCoding Scheme Registry   name

SOP Common   module   (0008,0110)[<0>](0008,0112)   
M   usage    7
   mod_tables
Patient   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Patient   module   (0008,1120)[<0>](0008,1155)   
M   usage   c
   mod_tables
Dose   entity1C   req   =Character Set that expands or replaces the Basic Graphic Set.=Required if an expanded or replacement character set is used.   See        select: label	   xrefstylesect_C.12.1.1.2   linkend   attrsxref   el for Defined Terms.   descSpecific Character Set   name

SOP Common   module   (0008,0005)   
M   usage   =
   mod_tables
Series   entity1C   req   $Text value for this name-value Item.+Required if Value Type (0040,A040) is TEXT.   desc
Text Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a160)   
U   usage   �
   mod_tables
Dose   entity3   reqJA user defined text string that may be used to label or name this overlay.   descOverlay Label   name
Overlay Plane   module   (60xx,1500)   
M   usage   c
   mod_tables
Dose   entity3   req   =A flag that indicates the storage status of the SOP Instance.   
variablelist   typeEnumerated Values:   title      NSwNot Specified; implies that this SOP Instance has no special storage status, and hence no special actions need be taken   OR�Original; implies that this is the primary SOP instance for the purpose of storage, but that it has not yet been authorized for diagnostic use   AO�Authorized Original; implies that this is the primary SOP instance for the purpose of storage, which has been authorized for diagnostic use   AC�Authorized Copy; implies that this is a copy of an Authorized Original SOP Instance; any copies of an Authorized Original should be given the status of Authorized Copy   list      
                        �Proper use of these flags is specified in Security Profiles. Implementations that do not conform to such Security Profiles may not necessarily handle these flags properly.   contentpara   el
                   contentnote   el   descSOP Instance Status   name

SOP Common   module   (0100,0410)   
4C - Required if dose data contains grid-based doses.   usage   
s
   mod_tables
Dose   entity2   reqNominal slice thickness, in mm.   descSlice Thickness   name
Image Plane   module   (0018,0050)   
M   usage    �
   mod_tables
Study   entity3   reqPerson's mailing address   descPerson's Address   name
General Study   module   (0008,1049)[<0>](0040,1102)   
M   usage   �
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name

SOP Common   module   (0020,9172)[<0>](0008,1150)   
M   usage   �
   mod_tables
Series   entity1C   req   $Date value for this name-value Item.+Required if Value Type (0040,A040) is DATE.   descDate   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a121)   
M   usage   �
   mod_tables
Series   entity1C   req   `Identifies the segments to which the reference applies identified by Segment Number (0062,0004).�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
	RT Series   moduleK   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)[<3>](0062,000b)   
U   usage   �
   mod_tables
Dose   entity1   reqNumber of Columns in Overlay.   descOverlay Columns   name
Overlay Plane   module   (60xx,0011)   
M   usage   �
   mod_tables
Dose   entity1   req      %  A certificate that holds the identity of the entity producing this Digital Signature, that entity's public key or key identifier, and the algorithm and associated parameters with which that public key is to be used. Algorithms allowed are specified in Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el).      
                             arabic
   numeration   attrs   
                              
                                �As technology advances, additional encryption algorithms may be allowed in future versions. Implementations should take this possibility into account.   contentpara   el
                           contentlistitem   el
                              
                                �When symmetric encryption is used, the certificate merely identifies which key was used by which entity, but not the actual key itself. Some other means (e.g., a trusted third party) must be used to obtain the key.   contentpara   el
                           contentlistitem   el
                         contentorderedlist   el
                       contentnote   el   descCertificate of Signer   name

SOP Common   module   (fffa,fffa)[<0>](0400,0115)   
M   usage   �
   mod_tables
Study   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name
General Study   module   (0008,1062)[<0>](0008,0082)   
M   usage   �
   mod_tables
Study   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name
General Study   module   (0008,1062)[<0>](0008,0080)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity2C   req   /The date the image pixel data creation started.kRequired if image is part of a series in which the images are temporally related. May be present otherwise.      
                          0This Attribute was formerly known as Image Date.   contentpara   el
                     contentnote   el   descContent Date   name
General Image   module   (0008,0023)   
@C - Required if dose data contains dose points or isodose curves   usage   
table_C.8-43
   mod_tables
Dose   entity1   req   DDose value for ROI, in units defined by Dose Units (3004,0002). See        select: label	   xrefstylesect_C.8.8.7.3   linkend   attrsxref   el.   desc
Dose Value   name
RT Dose ROI   module   (3004,0010)[<0>](3004,0012)   
U   usage   X
   mod_tables
Study   entity2C   req   YWhether or not a procedure has been performed in an effort to render the patient sterile.   
variablelist   typeEnumerated Values:   title      ALTEREDAltered/Neutered   	UNALTEREDUnaltered/intact   list      
                          IIf this Attribute is present but has no value then the status is unknown.   contentpara   el
                     contentnote   el;Required if patient is an animal. May be present otherwise.   descPatient's Sex Neutered   name
Patient Study   module   (0010,2203)   
M   usage   c
   mod_tables
Dose   entity3   req   rIndicates whether or not the date and time attributes in the instance have been modified during de-identification.   
variablelist   typeEnumerated Values:   title      
UNMODIFIED   MODIFIED   REMOVED   list   See        select: labelnumber	   xrefstylePS3.15	   targetdocPS3.15	   targetptr   attrsolink   el.   desc*Longitudinal Temporal Information Modified   name

SOP Common   module   (0028,0303)   
U   usage   �
   mod_tables
Dose   entity3   req   	ROI Mean.   See        select: label	   xrefstylesect_C.9.2.1.2   linkend   attrsxref   el for further explanation.   descROI Mean   name
Overlay Plane   module   (60xx,1302)      
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   req   hNumber of bits stored for each pixel sample. Each sample shall have the same number of bits stored. See        select: labelnumber	   xrefstylePS3.5	   targetdocPS3.5	   targetptr   attrsolink   el for further explanation.   descBits Stored   name
Image Pixel   module   
M   usage   �
   mod_tables
Dose   entity1C   req   hNumber of bits stored for each pixel sample. Each sample shall have the same number of bits stored. See        select: label	   xrefstylesect_C.8.8.3.4.4   linkend   attrsxref   elC for specialization. Required if Pixel Data (7FE0,0010) is present.   descBits Stored   name
RT Dose   module   (0028,0101)   
U   usage    �
   mod_tables
Dose   entity3   reqWMinimum calculated dose to ROI(s) described by DVH Referenced ROI Sequence (3004,0060).   descDVH Minimum Dose   name
RT DVH   module   (3004,0050)[<0>](3004,0070)   
M   usage   c
   mod_tables
Dose   entity2C   req�The coding scheme identifier as defined in an external registry. Required if coding scheme is registered and Coding Scheme UID (0008,010C) is not present.   descCoding Scheme External ID   name

SOP Common   module   (0008,0110)[<0>](0008,0114)   
M   usage   �
   mod_tables
	Equipment   entity3   req   �Date when the image acquisition device calibration was last changed in any way. Multiple entries may be used for additional calibrations at other times. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descDate of Last Calibration   name
General Equipment   module   (0018,1200)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   SThe date and time that the acquisition of data that resulted in this image started.      
                          �The synchronization of this time with an external clock is specified in the Synchronization Module in Acquisition Time Synchronized (0018,1800).   contentpara   el
                     contentnote   el   descAcquisition DateTime   name
General Image   module   (0008,002a)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity1   req<Uniquely identifies Frame of Reference within Structure Set.   descFrame of Reference UID   name
Structure Set   module   (3006,0010)[<0>](0020,0052)   
M   usage    �
   mod_tables
Study   entity3   reqWInstitution-generated description or classification of the Study (component) performed.   descStudy Description   name
General Study   module   (0008,1030)   
U   usage   
   mod_tables
Dose   entity1C   req   $Defines a sequence of Modality LUTs.6Only a single Item shall be included in this sequence.AShall not be present if Rescale Intercept (0028,1052) is present.   descModality LUT Sequence   name
Modality LUT   module   (0028,3000)   
M   usage   
table_C.7-1table_10-18table_10-17
   mod_tables
Patient   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   
variablelist   typeEnumerated Values:   title      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
Patient   module+   (0010,0024)[<0>](0040,0036)[<1>](0040,0033)   
M   usage   �
   mod_tables
Dose   entity3   req   BThe use of transformation in the calculation of the combined dose.   
variablelist   typeDefined Terms:   title      NONE7No transformation. Calculated on the original image set   RIGID   -Only Rigid transform used (see definition in        select: label	   xrefstylesect_C.20.2.1.2   linkend   attrsxref   el)   	NON_RIGIDAny other transform used   list   descSpatial Transform of Dose   name
RT Dose   module   (3004,0005)   
M   usage   �
   mod_tables
Series   entity1C   req   �The integer denominator of a rational representation of Numeric Value (0040,A30A). Encoded as a non-zero unsigned integer value. The same number of values as Numeric Value (0040,A30A) shall be present.<Required if Rational Numerator Value (0040,A162) is present.   descRational Denominator Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a163)   
U   usage   �
   mod_tables
Patient   entity1C   req   <The assigned identifier for the clinical trial subject. See        select: label	   xrefstylesect_C.7.1.3.1.6   linkend   attrsxref   elh. Shall be present if Clinical Trial Subject Reading ID (0012,0042) is absent. May be present otherwise.   descClinical Trial Subject ID   name
Clinical Trial Subject   module   (0012,0040)   
@C - Required if dose data contains dose points or isodose curves   usage   �
   mod_tables
Dose   entity1   req   ^Sequence specifying dose levels for isodose curves or dose points described in the ROI module.5One or more items shall be included in this sequence.   See        select: label	   xrefstylesect_C.8.8.7.1   linkend   attrsxref   el.   descRT Dose ROI Sequence   name
RT Dose ROI   module   (3004,0010)   
U   usage   �
   mod_tables
Dose   entity1   reqCUnique identifier of the Study containing the referenced Instances.   descStudy Instance UID   name
Common Instance Reference   module   (0008,1200)[<0>](0020,000d)   
M   usage    �
   mod_tables
Study   entity3   req�Identification of the physician(s) reading the Study. One or more items are permitted in this sequence. If more than one Item, the number and order shall correspond to the value of Name of Physician(s) Reading Study (0008,1060), if present.   desc2Physician(s) Reading Study Identification Sequence   name
General Study   module   (0008,1062)   
M   usage   c
   mod_tables
Dose   entity3   reqYManufacturer's serial number of the equipment that contributed to the composite instance.   descDevice Serial Number   name

SOP Common   module   (0018,a001)[<0>](0018,1000)   
M   usage   c
   mod_tables
Dose   entity3   req   oSequence of Items containing all attributes that were removed or replaced by other values in the main data set.1One or more Items are permitted in this sequence.   descOriginal Attributes Sequence   name

SOP Common   module   (0400,0561)   
M   usage   �
   mod_tables
Dose   entity3   reqPerson's mailing address   descPerson's Address   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1102)   
M   usage    _
   mod_tables
Patient   entity3   req   HA sequence that provides reference to a Patient SOP Class/Instance pair.1Only a single Item is permitted in this Sequence.   descReferenced Patient Sequence   name
Patient   module   (0008,1120)   
@C - Required if dose data contains dose points or isodose curves   usage    C
   mod_tables
Dose   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
Structure Set   moduleK   (3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)[<3>](0062,000b)   
M   usage   �
   mod_tables
Dose   entity3   req   &The purpose of this Digital Signature.1Only a single Item is permitted in this sequence.   desc'Digital Signature Purpose Code Sequence   name

SOP Common   module   (fffa,fffa)[<0>](0400,0401)   
@C - Required if dose data contains dose points or isodose curves   usage   �
   mod_tables
Dose   entity1   req   Units used for ROI Dose.   
variablelist   typeEnumerated Values:   title      GYGray   RELATIVE)dose relative to implicit reference value   list   desc
Dose Units   name
RT Dose ROI   module   (3004,0010)[<0>](3004,0002)   
U   usage   �
   mod_tables
Dose   entity1   req   'The value of this Attribute shall be 0.      
                        �Formerly the standard described embedding the overlay data in the Image Pixel Data (7FE0,0010), in which case the value of this Attribute specified the bit in which the overlay was stored. This usage has been retired. See PS3.3-2004.   contentpara   el
                   contentnote   el   descOverlay Bit Position   name
Overlay Plane   module   (60xx,0102)   
M   usage   =
   mod_tables
Series   entity1C   req   MNumeric value for this name-value Item. Only a single value shall be present..Required if Value Type (0040,A040) is NUMERIC.   descNumeric Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a30a)   
M   usage   �
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
RT Dose   module   (0070,0404)[<0>](0008,1155)   
4C - Required if dose data contains grid-based doses.   usage   
s
   mod_tables
Dose   entity1   req   �Physical distance in the patient between the center of each pixel, specified by a numeric pair - adjacent row spacing (delimiter) adjacent column spacing in mm. See        select: label	   xrefstylesect_10.7.1.3   linkend   attrsxref   el for further explanation.   descPixel Spacing   name
Image Plane   module   (0028,0030)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity1C   req   3The Patient Orientation values of the source image.TRequired if the value of Spatial Locations Preserved (0028,135A) is REORIENTED_ONLY.   descPatient Orientation   name
General Image   module   (0008,2112)[<0>](0020,0020)   
M   usage    �
   mod_tables
Series   entity1C   req   +Person name value for this name-value Item.,Required if Value Type (0040,A040) is PNAME.   descPerson Name   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a123)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   �Specifies the format of the Green Palette Color Lookup Table Data (0028,1202). Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.5   linkend   attrsxref   el for further explanation.   desc+Green Palette Color Lookup Table Descriptor   name
General Image   module   (0088,0200)[<0>](0028,1102)   
U   usage   �
   mod_tables
Dose   entity3   req   ROI standard deviation.   See        select: label	   xrefstylesect_C.9.2.1.2   linkend   attrsxref   el for further explanation.   descROI Standard Deviation   name
Overlay Plane   module   (60xx,1303)   
M   usage   �
   mod_tables
Series   entity1C   req   �The integer numerator of a rational representation of Numeric Value (0040,A30A). Encoded as a signed integer value. The same number of values as Numeric Value (0040,A30A) shall be present.�Required if Numeric Value (0040,A30A) has insufficient precision to represent a rational value as a string. May be present otherwise.   descRational Numerator Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a162)   
M   usage   �
   mod_tables
Patient   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
Patient   module;   (0010,1002)[<0>](0010,0024)[<1>](0040,0036)[<2>](0040,0032)   
U   usage   O
   mod_tables
Study   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   Enumerated Values:   title
variablelist   type      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
Patient Study   module   (0038,0064)[<0>](0040,0033)   
U   usage   X
   mod_tables
Study   entity3   req2Description of the admitting diagnosis (diagnoses)   descAdmitting Diagnoses Description   name
Patient Study   module   (0008,1080)   
4C - Required if dose data contains grid-based doses.   usage   L
   mod_tables
Dose   entity1   req?Label that is used to identify the transformation of this Item.   desc	LUT Label   name
General Image   module   (0040,9096)[<0>](0040,9210)   
4C - Required if dose data contains grid-based doses.   usage   
s
   mod_tables
Dose   entity1   req   ]The direction cosines of the first row and the first column with respect to the patient. See        select: label	   xrefstylesect_C.7.6.2.1.1   linkend   attrsxref   el for further explanation.   descImage Orientation (Patient)   name
Image Plane   module   (0020,0037)   
M   usage    _
   mod_tables
Patient   entity2   req?Primary hospital identification number or code for the patient.   desc
Patient ID   name
Patient   module   (0010,0020)   
M   usage   l
   mod_tables
Series   entity3   req   GIdentifier of the Assigning Authority that issued the Accession Number.1Only a single Item is permitted in this sequence.   desc#Issuer of Accession Number Sequence   name
	RT Series   module   (0040,0275)[<0>](0008,0051)   
M   usage   �
   mod_tables
Study   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
General Study   module   (0008,0051)[<0>](0040,0031)   
U   usage    �
   mod_tables
Dose   entity1   req   �A data stream describing the dose bin widths Dnand associated volumes Vnin DVH Volume Units (3004,0054) in the order D1V1, D2V2, … DnVn.      
                          �DVH Data arrays may not be properly encoded if Explicit VR transfer syntax is used and the VL of this attribute exceeds 65534 bytes.   contentpara   el
                     contentnote   el   descDVH Data   name
RT DVH   module   (3004,0050)[<0>](3004,0058)   
U   usage   �
   mod_tables
Dose   entity1   reqDUnique identifier of the Series containing the referenced Instances.   descSeries Instance UID   name
Common Instance Reference   module   (0008,1115)[<0>](0020,000e)   
M   usage   �
   mod_tables
Patient   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
Patient   module+   (0010,0024)[<0>](0040,0036)[<1>](0040,0032)   
M   usage   �
   mod_tables
Dose   entity1C   req   �Sequence of one Fraction Group containing beams or brachy application setups contributing to dose. Required if Dose Summation Type (3004,000A) is FRACTION, BEAM, BRACHY, FRACTION_SESSION, BEAM_SESSION, BRACHY_SESSION or CONTROL_POINT.BOnly a single item shall be included in this sequence. See Note 1.   desc"Referenced Fraction Group Sequence   name
RT Dose   module   (300c,0002)[<0>](300c,0020)   
M   usage   �
   mod_tables
Series   entity1C   req   $Text value for this name-value Item.+Required if Value Type (0040,A040) is TEXT.   desc
Text Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a160)   
M   usage   �
   mod_tables
Series   entity3   reqTime the Series started.   descSeries Time   name
	RT Series   module   (0008,0031)   
M   usage   �
   mod_tables
Series   entity1C   req   #UID value for this name-value Item.-Required if Value Type (0040,A040) is UIDREF.   descUID   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a124)   
M   usage    _
   mod_tables
Patient   entity2   reqPatient's full name.   descPatient's Name   name
Patient   module   (0010,0010)   
M   usage   c
   mod_tables
Dose   entity3   reqeAddress of the institution where the equipment that contributed to the composite instance is located.   descInstitution Address   name

SOP Common   module   (0018,a001)[<0>](0008,0081)   
M   usage   �
   mod_tables
Dose   entity1   reqsA number used to identify which MAC Parameters Sequence item was used in the calculation of this Digital Signature.   descMAC ID Number   name

SOP Common   module   (fffa,fffa)[<0>](0400,0005)   
ZC - Required if the SOP Instance was created in response to a Frame-Level retrieve request   usage   �
   mod_tables
Dose   entity1C   req   BA list of Frames that were extracted in the form of a simple list.sRequired if object extraction is based on a Frame Level Retrieve using the Simple Frame List (0008,1161) attribute.   See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el0 "Instance and Frame Level Retrieve SOP Classes"   descSimple Frame List   name
Frame Extraction   module   (0008,1164)[<0>](0008,1161)   
M   usage   �
   mod_tables
Series   entity1C   req   �The integer denominator of a rational representation of Numeric Value (0040,A30A). Encoded as a non-zero unsigned integer value. The same number of values as Numeric Value (0040,A30A) shall be present.<Required if Rational Numerator Value (0040,A162) is present.   descRational Denominator Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a163)   
M   usage   l
   mod_tables
Series   entity1C   req   8Identifier that identifies the Scheduled Procedure Step.$Required if procedure was scheduled.      
                      ?  The condition is to allow the contents of this macro to be present (e.g., to convey the reason for the procedure, such as whether a mammogram is for screening or diagnostic purposes) even when the procedure step was not formally scheduled and a value for this identifier is unknown, rather than making up a dummy value.   contentpara   el
                 contentnote   el   descScheduled Procedure Step ID   name
	RT Series   module   (0040,0275)[<0>](0040,0009)   
M   usage   c
   mod_tables
Dose   entity1   reqZThe value of a Coding Scheme Designator, used in this SOP Instance, which is being mapped.   descCoding Scheme Designator   name

SOP Common   module   (0008,0110)[<0>](0008,0102)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req      @A data stream of the pixel samples that comprise the Image. See        select: label	   xrefstylesect_C.7.6.3.1.4   linkend   attrsxref   el for further explanation.?Required if Pixel Data Provider URL (0028,7FE0) is not present.   desc
Pixel Data   name
General Image   module   (0088,0200)[<0>](7fe0,0010)   
M   usage   c
   mod_tables
Dose   entity3   req   KDate and time that the SOP Instance was last coerced by a Storage SCP (see        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el).   descInstance Coercion DateTime   name

SOP Common   module   (0008,0015)   
M   usage    �
   mod_tables
Series   entity1C   req   MNumeric value for this name-value Item. Only a single value shall be present..Required if Value Type (0040,A040) is NUMERIC.   descNumeric Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a30a)   
M   usage   =
   mod_tables
Series   entity1C   req   #UID value for this name-value Item.-Required if Value Type (0040,A040) is UIDREF.   descUID   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a124)   
U   usage    �
   mod_tables
Dose   entity1   req      HSpecifies whether volume within ROI is included or excluded in DVH. See        select: label	   xrefstylesect_C.8.8.4.2   linkend   attrsxref   el.   
variablelist   typeEnumerated Values:   title      INCLUDED   EXCLUDED   list   descDVH ROI Contribution Type   name
RT DVH   module+   (3004,0050)[<0>](3004,0060)[<1>](3004,0062)   
M   usage   �
   mod_tables
Series   entity1   req   4Type of equipment that originally acquired the data.   
variablelist   typeEnumerated Values:   title      RTIMAGERT Image   RTDOSERT Dose   RTSTRUCTRT Structure Set   RTPLANRT Plan   RTRECORDRT Treatment Record   list   See        select: label	   xrefstylesect_C.8.8.1.1   linkend   attrsxref   el.   descModality   name
	RT Series   module   (0008,0060)   
U   usage   �
   mod_tables
Dose   entity3   req   KDefined Term that identifies the intended purpose of the Overlay Type. See        select: label	   xrefstylesect_C.9.2.1.3   linkend   attrsxref   el for further explanation.   descOverlay Subtype   name
Overlay Plane   module   (60xx,0045)   
M   usage   
   mod_tables
Patient   entity3   req   AType of Patient ID. Refer to HL7 v2 Table 0203 for Defined Terms.      
                      ;Equivalent to HL7 v2 CX component 5 (Identifier Type Code).   contentpara   el
                 contentnote   el   descIdentifier Type Code   name
Patient   module   (0010,0024)[<0>](0040,0035)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity1   req   uSequence of items describing images in a given series used in defining the Structure Set (typically CT or MR images).5One or more items shall be included in this sequence.   descContour Image Sequence   name
Structure Set   module;   (3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)   
M   usage    �
   mod_tables
Series   entity1C   req   (DateTime value for this name-value Item./Required if Value Type (0040,A040) is DATETIME.   descDateTime   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a120)   
M   usage   c
   mod_tables
Dose   entity3   req   @Identification of the operator(s) of the contributing equipment.1One or more items are permitted in this sequence.|The number and order of Items shall correspond to the number and order of values of Operators' Name (0008,1070), if present.   desc Operator Identification Sequence   name

SOP Common   module   (0018,a001)[<0>](0008,1072)   
M   usage    �
   mod_tables
Study   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name
General Study   module   (0008,1049)[<0>](0040,1103)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity3   reqpList of Contour Number (3006,0048) defining lower-numbered contour(s) to which the current contour is connected.   descAttached Contours   name
ROI Contour   module+   (3006,0039)[<0>](3006,0040)[<1>](3006,0049)   
M   usage    �
   mod_tables
Study   entity2   req)Name of the patient's referring physician   descReferring Physician's Name   name
General Study   module   (0008,0090)   
M   usage   =
   mod_tables
Series   entity1C   req   $Date value for this name-value Item.+Required if Value Type (0040,A040) is DATE.   descDate   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a121)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   ZDescribes the approximate lossy compression ratio(s) that have been applied to this image.   See        select: label	   xrefstylesect_C.7.6.1.1.5   linkend   attrsxref   el for further explanation.KMay be multivalued if successive lossy compression steps have been applied.      
                           arabic
   numeration   attrs   
                            
                              hFor example, a compression ratio of 30:1 would be described in this Attribute with a single value of 30.   contentpara   el
                         contentlistitem   el
                            
                              pFor historical reasons, the lossy compression ratio may also be described in Derivation Description (0008,2111).   contentpara   el
                         contentlistitem   el
                       contentorderedlist   el
                     contentnote   el   descLossy Image Compression Ratio   name
General Image   module   (0028,2112)   
M   usage   c
   mod_tables
Dose   entity3   reqIThe date and time when the SOP Instance Status (0100,0410) was set to AO.   descSOP Authorization DateTime   name

SOP Common   module   (0100,0420)   
M   usage   =
   mod_tables
Series   entity1C   req   $Time value for this name-value Item.+Required if Value Type (0040,A040) is TIME.   descTime   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a122)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1   req   .Number of samples (planes) in this image. See        select: label	   xrefstylesect_C.7.6.3.1.1   linkend   attrsxref   el for further explanation.   descSamples per Pixel   name
General Image   module   (0088,0200)[<0>](0028,0002)   
M   usage    _
   mod_tables
Patient   entity1   req   $The type of identifier in this item.   
variablelist   typeDefined Terms:   title      TEXT   RFID   BARCODE   list      
                          RThe identifier is coded as a string regardless of the type, not as a binary value.   contentpara   el
                     contentnote   el   descType of Patient ID   name
Patient   module   (0010,1002)[<0>](0010,0022)   
M   usage    �
   mod_tables
Study   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name
General Study   module   (0008,1049)[<0>](0008,0080)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1C   req   �Specifies the format of the Blue Palette Color Lookup Table Data (0028,1203). Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.5   linkend   attrsxref   el for further explanation.   desc*Blue Palette Color Lookup Table Descriptor   name
Image Pixel   module   (0028,1103)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   �Indicates whether or not the image contains sufficiently recognizable visual features to allow the image or a reconstruction from a set of images to identify the patient.   
variablelist   typeEnumerated Values:   title      YES   NO   list`If this Attribute is absent, then the image may or may not contain recognizable visual features.   descRecognizable Visual Features   name
General Image   module   (0028,0302)   
U   usage   �
   mod_tables
Study   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
Patient Study   module   (0038,0014)[<0>](0040,0032)   
U   usage   	'
   mod_tables
Series   entity3   req   DA description of the series in the context of a clinical trial. See        select: label	   xrefstylesect_C.7.3.2.1.2   linkend   attrsxref   el.   desc!Clinical Trial Series Description   name
Clinical Trial Series   module   (0012,0072)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1   req   hNumber of bits stored for each pixel sample. Each sample shall have the same number of bits stored. See        PS3.5	   targetdocselect: labelnumber	   xrefstylePS3.5	   targetptr   attrsolink   el for further explanation.   descBits Stored   name
General Image   module   (0088,0200)[<0>](0028,0101)   
M   usage   K
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   module+   (0040,0275)[<0>](0008,1110)[<1>](0008,1155)   
M   usage   �
   mod_tables
Dose   entity3   req   �Specifies a list of patient heterogeneity characteristics used for calculating dose. This Attribute shall be multi-valued if beams used to compute the dose have differing correction techniques.   
variablelist   typeEnumerated Values:   title      IMAGE
image data   ROI_OVERRIDEIone or more ROI densities override image or water values where they exist   WATER)entire volume treated as water equivalent   list   descTissue Heterogeneity Correction   name
RT Dose   module   (3004,0014)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1C   req   �  Ratio of the vertical size and horizontal size of the pixels in the image specified by a pair of integer values where the first value is the vertical pixel size, and the second value is the horizontal pixel size. Required if the aspect ratio values do not have a ratio of 1:1 and the physical pixel spacing is not specified by Pixel Spacing (0028,0030), or Imager Pixel Spacing (0018,1164) or Nominal Scanned Pixel Spacing (0018,2010), either for the entire Image or per-frame in a Functional Group Macro. See        select: label	   xrefstylesect_C.7.6.3.1.7   linkend   attrsxref   el.   descPixel Aspect Ratio   name
Image Pixel   module   (0028,0034)   
M   usage   �
   mod_tables
Patient   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
Patient   module;   (0010,1002)[<0>](0010,0024)[<1>](0040,0036)[<2>](0040,0031)   
@C - Required if dose data contains dose points or isodose curves   usage   w
   mod_tables
Dose   entity1   req_Uniquely identifies the referenced ROI described in the Structure Set ROI Sequence (3006,0020).   descReferenced ROI Number   name
ROI Contour   module   (3006,0039)[<0>](3006,0084)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   =The mapping of stored values to associated Real World values.1One or more Items are permitted in this sequence.   desc!Real World Value Mapping Sequence   name
General Image   module   (0040,9096)      
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   req   =Specifies the intended interpretation of the pixel data. See        select: label	   xrefstylesect_C.7.6.3.1.2   linkend   attrsxref   el for further explanation.   descPhotometric Interpretation   name
Image Pixel   module   
M   usage   �
   mod_tables
Dose   entity1C   req   =Specifies the intended interpretation of the pixel data. See        select: label	   xrefstylesect_C.8.8.3.4.2   linkend   attrsxref   elC for specialization. Required if Pixel Data (7FE0,0010) is present.   descPhotometric Interpretation   name
RT Dose   module   (0028,0004)   
M   usage   �
   mod_tables
Dose   entity1   req�Uniquely identifies Fraction Group specified by Fraction Group Number (300A,0071) in Fraction Group Sequence of RT Fraction Scheme Module within RT Plan referenced in Referenced RT Plan Sequence (300C,0002).   desc Referenced Fraction Group Number   name
RT Dose   module+   (300c,0002)[<0>](300c,0020)[<1>](300c,0022)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity1   req   @Code describing the purpose of the reference to the Instance(s).6Only a single Item shall be included in this sequence.   desc"Purpose of Reference Code Sequence   name
General Image   module   (0008,114a)[<0>](0040,a170)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   XSpecifies whether an Image has undergone lossy compression (at a point in its lifetime).   
variablelist   typeEnumerated Values:   title      002Image has NOT been subjected to lossy compression.   01.Image has been subjected to lossy compression.   list9Once this value has been set to 01 it shall not be reset.   See        select: label	   xrefstylesect_C.7.6.1.1.5   linkend   attrsxref   el.   descLossy Image Compression   name
General Image   module   (0028,2110)   
M   usage   �
   mod_tables
	Equipment   entity3   req   rTime when the image acquisition device calibration was last changed in any way. Multiple entries may be used. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descTime of Last Calibration   name
General Equipment   module   (0018,1201)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity1   req�Identification number of the ROI. The value of ROI Number (3006,0022) shall be unique within the Structure Set in which it is created.   desc
ROI Number   name
Structure Set   module   (3006,0020)[<0>](3006,0022)   
M   usage   �
   mod_tables
Series   entity1C   req   $Time value for this name-value Item.+Required if Value Type (0040,A040) is TIME.   descTime   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a122)   
@C - Required if dose data contains dose points or isodose curves   usage   d
   mod_tables
Dose   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
ROI Contour   module;   (3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1155)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity2C   req   /The time the image pixel data creation started.kRequired if image is part of a series in which the images are temporally related. May be present otherwise.   descContent Time   name
General Image   module   (0008,0033)   
U   usage   �
   mod_tables
Patient   entity2   req   EName of the site responsible for submitting clinical trial data. See        select: label	   xrefstylesect_C.7.1.3.1.5   linkend   attrsxref   el   descClinical Trial Site Name   name
Clinical Trial Subject   module   (0012,0031)   
M   usage   �
   mod_tables
	Equipment   entity3   req�The inherent limiting resolution in mm of the acquisition equipment for high contrast objects for the data gathering and reconstruction technique chosen. If variable across the images of the series, the value at the image center.   descSpatial Resolution   name
General Equipment   module   (0018,1050)   
M   usage   l
   mod_tables
Series   entity3   req%Reason for requesting this procedure.   desc"Reason for the Requested Procedure   name
	RT Series   module   (0040,0275)[<0>](0040,1002)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req$User-defined name for Structure Set.   descStructure Set Name   name
Structure Set   module   (3006,0004)   
M   usage   �
   mod_tables
Series   entity1C   req   (DateTime value for this name-value Item./Required if Value Type (0040,A040) is DATETIME.   descDateTime   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a120)   
M   usage   c
   mod_tables
Dose   entity2   req�The source that provided the SOP Instance prior to the removal or replacement of the values. For example, this might be the Institution from which imported SOP Instances were received.   descSource of Previous Values   name

SOP Common   module   (0400,0561)[<0>](0400,0564)   
M   usage   �
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   module   (0008,1111)[<0>](0008,1150)   
M   usage   �
   mod_tables
Series   entity3   req1Date on which the Performed Procedure Step ended.   desc!Performed Procedure Step End Date   name
	RT Series   module   (0040,0250)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   �Describes the purpose for which the reference is made, that is what role the source image or frame(s) played in the derivation of this image.1Only a single Item is permitted in this sequence.   desc"Purpose of Reference Code Sequence   name
General Image   module   (0008,2112)[<0>](0040,a170)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
General Image   module   (0008,1140)[<0>](0062,000b)   
M   usage   c
   mod_tables
Dose   entity3   reqhDepartment in the institution where the equipment that contributed to the composite instance is located.   descInstitutional Department Name   name

SOP Common   module   (0018,a001)[<0>](0008,1040)   
@C - Required if dose data contains dose points or isodose curves   usage   
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Structure Set   module   (3006,0018)[<0>](0008,1150)   
M   usage   �
   mod_tables
Dose   entity1   req   �Identifies Control Point specified by Control Point Index (300A,0112) within Beam referenced by Referenced Beam Number (300C,0006). This is the second of the two Control Points from which the Dose contribution to the Control Point can be calculated.<The Control Point Index (300A,0112) referenced by Referenced�Stop Control Point Index (300C,00F6) shall be the Control Point Index (300A,0112) immediately following the Control Point Index (300A,0112) referenced by Referenced Start Control Point Index (300C,00F4) within the Referenced Beam Number (300C,0006).   desc#Referenced Stop Control Point Index   name
RT Dose   moduleK   (300c,0002)[<0>](300c,0020)[<1>](300c,0004)[<2>](300c,00f2)[<3>](300c,00f6)   
M   usage   c
   mod_tables
Dose   entity1   reqIIdentification of the system that removed and/or replaced the attributes.   descModifying System   name

SOP Common   module   (0400,0561)[<0>](0400,0563)   
M   usage    _
   mod_tables
Patient   entity1   req   FIdentification of the organization with which an animal is registered.6Only a single Item shall be included in this sequence.   descBreed Registry Code Sequence   name
Patient   module   (0010,2294)[<0>](0010,2296)   
M   usage    �
   mod_tables
Series   entity1   req   +Coded concept name of this name-value Item.6Only a single Item shall be included in this Sequence.   descConcept Name Code Sequence   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a043)   
4C - Required if dose data contains grid-based doses.   usage   �
   mod_tables
Dose   entity1C   req   �Specifies the format of the Blue Palette Color Lookup Table Data (0028,1203). Required if Photometric Interpretation (0028,0004) has a value of PALETTE COLOR or Pixel Presentation (0008,9205) at the image level equals COLOR or MIXED. See        select: label	   xrefstylesect_C.7.6.3.1.5   linkend   attrsxref   el for further explanation.   desc*Blue Palette Color Lookup Table Descriptor   name
General Image   module   (0088,0200)[<0>](0028,1103)   
M   usage   �
   mod_tables
Series   entity3   req3Date on which the Performed Procedure Step started.   desc#Performed Procedure Step Start Date   name
	RT Series   module   (0040,0244)   
M   usage    �
   mod_tables
Series   entity1C   req   @Composite SOP Instance Reference value for this name-value Item.6Only a single Item shall be included in this Sequence.9Required if Value Type (0040,A040) is COMPOSITE or IMAGE.   descReferenced SOP Sequence   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0008,1199)   
@C - Required if dose data contains dose points or isodose curves   usage   �
   mod_tables
Dose   entity1   req   RUniquely identifies the referenced ROI within the current RT Dose. See Note 1 and        select: label	   xrefstylesect_C.8.8.7.2   linkend   attrsxref   el.   descReferenced ROI Number   name
RT Dose ROI   module   (3004,0010)[<0>](3006,0084)   
U   usage   �
   mod_tables
Study   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
Patient Study   module   (0038,0014)[<0>](0040,0031)   
M   usage   c
   mod_tables
Dose   entity1   reqIManufacturer of the equipment that contributed to the composite instance.   descManufacturer   name

SOP Common   module   (0018,a001)[<0>](0008,0070)   
M   usage   �
   mod_tables
Dose   entity1   req�Uniquely identifies Beam specified by Beam Number (300A,00C0) in Beam Sequence of RT Beams Module within RT Plan referenced in Referenced RT Plan Sequence (300C,0002).   descReferenced Beam Number   name
RT Dose   module;   (300c,0002)[<0>](300c,0020)[<1>](300c,0004)[<2>](300c,0006)   
M   usage   �
   mod_tables
Study   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   Enumerated Values:   title
variablelist   type      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
General Study   module   (0008,0051)[<0>](0040,0033)   
M   usage   =
   mod_tables
Series   entity1C   req   �The integer denominator of a rational representation of Numeric Value (0040,A30A). Encoded as a non-zero unsigned integer value. The same number of values as Numeric Value (0040,A30A) shall be present.<Required if Rational Numerator Value (0040,A162) is present.   descRational Denominator Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a163)   
M   usage   �
   mod_tables
Series   entity1C   req   �The floating point representation of Numeric Value (0040,A30A). The same number of values as Numeric Value (0040,A30A) shall be present.~Required if Numeric Value (0040,A30A) has insufficient precision to represent the value as a string. May be present otherwise.   descFloating Point Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a161)   
4C - Required if dose data contains grid-based doses.   usage   L
   mod_tables
Dose   entity1   reqMFree form text explanation of the meaning of the transformation in this Item.   descLUT Explanation   name
General Image   module   (0040,9096)[<0>](0028,3003)   
M   usage   l
   mod_tables
Series   entity3   req�Sequence describing the Scheduled Protocol following a specific coding scheme. One or more Items are permitted in this sequence.   desc Scheduled Protocol Code Sequence   name
	RT Series   module   (0040,0275)[<0>](0040,0008)   
M   usage   
   mod_tables
Patient   entity1C   req   |Standard defining the format of the Universal Entity ID (0040,0032). Required if Universal Entity ID (0040,0032) is present.      
                      GEquivalent to HL7 v2 CX component 4 subcomponent 3 (Universal ID Type).   contentpara   el
                 contentnote   el   See        select: label	   xrefstyle
sect_10.14   linkend   attrsxref   el for Defined Terms.   descUniversal Entity ID Type   name
Patient   module   (0010,0024)[<0>](0040,0033)   
M   usage   �
   mod_tables
Patient   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
Patient   module+   (0010,0024)[<0>](0040,0036)[<1>](0040,0031)   
4C - Required if dose data contains grid-based doses.   usage   L
   mod_tables
Dose   entity1   req   �Specifies the last stored value mapped for the Real Word Value Intercept (0040,9224) and Real World Value Slope (0040,9225) or Real World Value LUT (0040,9212) of this Item.   See        select: label	   xrefstylesect_C.7.6.16.2.11.1   linkend   attrsxref   el for further explanation.   desc"Real World Value Last Value Mapped   name
General Image   module   (0040,9096)[<0>](0040,9211)   
M   usage   �
   mod_tables
Dose   entity1C   req   JSequence defining the Control Points in current Beam contributing to dose.=Required if Dose Summation Type (3004,000A) is CONTROL_POINT.6Only a single item shall be included in this sequence.   desc!Referenced Control Point Sequence   name
RT Dose   module;   (300c,0002)[<0>](300c,0020)[<1>](300c,0004)[<2>](300c,00f2)   
U   usage   �
   mod_tables
Dose   entity1   reqONumber of Frames in Overlay. Required if Overlay data contains multiple frames.   descNumber of Frames in Overlay   name
Multi-frame Overlay   module   (60xx,0015)   
M   usage   c
   mod_tables
Dose   entity1C   req   ,  Sequence of items defining mapping between HL7 Instance Identifiers of unencapsulated HL7 Structured Documents referenced from the current SOP Instance as if they were DICOM Composite SOP Class Instances defined by SOP Class and Instance UID pairs. May also define a means of accessing the Documents.5One or more Items shall be included in this sequence.   See        select: label	   xrefstylesect_C.12.1.1.6   linkend   attrsxref   el.�Required if unencapsulated HL7 Structured Documents are referenced within the Instance. Every such document so referenced is required to have a corresponding Item in this Sequence.   desc*HL7 Structured Document Reference Sequence   name

SOP Common   module   (0040,a390)   
M   usage   c
   mod_tables
Dose   entity3   reqVAny comments associated with the setting of the SOP Instance Status (0100,0410) to AO.   descSOP Authorization Comment   name

SOP Common   module   (0100,0424)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity2   req   'Type of algorithm used to generate ROI.   
variablelist   typeDefined Terms:   title      	AUTOMATICcalculated ROI   SEMIAUTOMATIC#ROI calculated with user assistance   MANUALuser-entered ROI   list   descROI Generation Algorithm   name
Structure Set   module   (3006,0020)[<0>](3006,0036)   
M   usage   �
   mod_tables
Series   entity3   reqnUser or equipment generated identifier of that part of a Procedure that has been carried out within this step.   descPerformed Procedure Step ID   name
	RT Series   module   (0040,0253)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   reqNumber of rows in the image.   descRows   name
Image Pixel   module   (0028,0010)   
@C - Required if dose data contains dose points or isodose curves   usage    �
   mod_tables
Dose   entity3   req   }Sequence describing Frames of Reference in which the ROIs are defined. One or more items are permitted in this sequence. See        select: label	   xrefstylesect_C.8.8.5.1   linkend   attrsxref   el.   desc&Referenced Frame of Reference Sequence   name
Structure Set   module   (3006,0010)   
M   usage   c
   mod_tables
Dose   entity1   req�Transfer Syntax used to encode the encrypted content. Only Transfer Syntaxes that explicitly include the VR and use Little Endian encoding shall be used.   desc%Encrypted Content Transfer Syntax UID   name

SOP Common   module   (0400,0500)[<0>](0400,0510)   
M   usage   c
   mod_tables
Dose   entity3   req   tManufacturer's designation of the software version of the equipment that contributed to the composite instance. See        select: label	   xrefstylesect_C.7.5.1.1.3   linkend   attrsxref   el.   descSoftware Versions   name

SOP Common   module   (0018,a001)[<0>](0018,1020)   
M   usage   c
   mod_tables
Dose   entity1   req   'Uniquely identifies the SOP Class. See        select: label	   xrefstylesect_C.12.1.1.1   linkend   attrsxref   el# for further explanation. See also        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descSOP Class UID   name

SOP Common   module   (0008,0016)   
M   usage    �
   mod_tables
Study   entity3   req,Names of the physician(s) reading the Study.   desc"Name of Physician(s) Reading Study   name
General Study   module   (0008,1060)   
4C - Required if dose data contains grid-based doses.   usage   
   mod_tables
Dose   entity1   reqNumber of columns in the image   descColumns   name
Image Pixel   module   (0028,0011)   
U   usage   �
   mod_tables
Dose   entity1C   req   FSequence of Items each of which includes the Attributes of one Series.5One or more Items shall be included in this sequence.=Required if this Instance references Instances in this Study.   descReferenced Series Sequence   name
Common Instance Reference   module   (0008,1115)   
M   usage    �
   mod_tables
Study   entity3   req   aIdentification of the physician(s) who are responsible for overall patient care at time of Study.�One or more items are permitted in this sequence. If more than one Item, the number and order shall correspond to the value of Physician(s) of Record (0008,1048), if present.   desc.Physician(s) of Record Identification Sequence   name
General Study   module   (0008,1049)   
4C - Required if dose data contains grid-based doses.   usage   <
   mod_tables
Dose   entity3   req   �The extent to which the spatial locations of all pixels are preserved during the processing of the source image that resulted in the current image   
variablelist   typeEnumerated Values:   title      YES   NO   REORIENTED_ONLYYA projection radiograph that has been flipped, and/or rotated by a multiple of 90 degrees   list      
                           arabic
   numeration   attrs   
                            
                              V  This applies not only to images with a known relationship to a 3D space, but also to projection images. For example, a projection radiograph such as a mammogram that is processed by a point image processing operation such as contrast enhancement, or a smoothing or edge enhancing convolution, would have a value of YES for this attribute. A projection radiograph that had been magnified or warped geometrically would have a value of NO for this attribute. A projection radiograph that has been flipped, and/or rotated by a multiple of 90 degrees, such that transformation of pixel locations is possible by comparison of the values of Patient Orientation (0020,0020) would have a value of REORIENTED_ONLY. This attribute is typically of importance in relating images with Presentation Intent Type (0008,0068) values of FOR PROCESSING and FOR PRESENTATION.   contentpara   el
                         contentlistitem   el
                            
                              9  When the value of this attribute is NO, it is not possible to locate on the current image any pixel coordinates that are referenced relative to the source image, such as for example, might be required for rendering CAD findings derived from a referenced FOR PROCESSING image on the current FOR PRESENTATION image.   contentpara   el
                         contentlistitem   el
                       contentorderedlist   el
                     contentnote   el   descSpatial Locations Preserved   name
General Image   module   (0008,2112)[<0>](0028,135a)   
M   usage    _
   mod_tables
Patient   entity1C   req   The species of the patient.Required if the patient is an animal and if Patient Species Code Sequence (0010,2202) is not present. May be present otherwise.   descPatient Species Description   name
Patient   module   (0010,2201)   
M   usage   
   mod_tables
Dose   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
RT Dose   module   (300c,0002)[<0>](0008,1150)   tags