pst012345678   (   GCan't handle table_8.8-1 (in table_C.7-1:table_10-18 after (0040,0039))GCan't handle table_8.8-1 (in table_C.7-1:table_10-18 after (0040,003A))GCan't handle table_8.8-1 (in table_C.7-1:table_10-18 after (0040,0039))GCan't handle table_8.8-1 (in table_C.7-1:table_10-18 after (0040,003A));Can't handle table_8.8-1 (in table_C.7-1 after (0010,2202));Can't handle table_8.8-1 (in table_C.7-1 after (0010,2293));Can't handle table_8.8-1 (in table_C.7-1 after (0010,2296));Can't handle table_8.8-1 (in table_C.7-1 after (0012,0064))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0040,1101))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0008,0082))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0040,1101))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0008,0082))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0040,1101))FCan't handle table_8.8-1 (in table_C.7-3:table_10-1 after (0008,0082));Can't handle table_8.8-1 (in table_C.7-3 after (0032,1034));Can't handle table_8.8-1 (in table_C.7-3 after (0008,1032));Can't handle table_8.8-1 (in table_C.7-3 after (0040,1012))<Can't handle table_8.8-1 (in table_C.7-4a after (0008,1084))<Can't handle table_8.8-1 (in table_C.7-4a after (0010,1021))<Can't handle table_8.8-1 (in table_C.8-37 after (0008,103F))GCan't handle table_8.8-1 (in table_C.8-37:table_10-9 after (0032,1064))GCan't handle table_8.8-1 (in table_C.8-37:table_10-9 after (0040,100A))GCan't handle table_8.8-1 (in table_C.8-37:table_10-9 after (0040,0008))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,A043))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,A168))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,08EA))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,A043))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,A168))RCan't handle table_8.8-1 (in table_C.8-37:table_10-9:table_10-2 after (0040,08EA))HCan't handle table_8.8-1 (in table_C.8-37:table_10-16 after (0040,0260))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,A043))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,A168))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,08EA))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,A043))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,A168))SCan't handle table_8.8-1 (in table_C.8-37:table_10-16:table_10-2 after (0040,08EA))<Can't handle table_8.8-1 (in table_C.12-1 after (0040,A170))GCan't handle table_8.8-1 (in table_C.12-1:table_10-1 after (0040,1101))GCan't handle table_8.8-1 (in table_C.12-1:table_10-1 after (0008,0082))ICan't handle table_8.8-1 (in table_C.12-1:table_C.12-6 after (0400,0401))   errors `     
U   usage   
table_C.8-48
table_10-3
   mod_tables
Treatment Record   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0401)[<1>](0008,1160)   
U   usage   
table_C.8-48
   mod_tables
Treatment Record   entity1C   req   Patient position descriptor relative to the equipment. Required if Patient Additional Position (300A,0184) is not present. See        select: label	   xrefstylesect_C.8.8.12.1.2   linkend   attrsxref   el+ for Defined Terms and further explanation.   descPatient Position   name
RT Patient Setup   module   (300a,0180)[<0>](0018,5100)   
M   usage   
table_C.7-1table_10-11
   mod_tables
Patient   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Patient   module   (0008,1120)[<0>](0008,1150)   
U   usage   
table_C.8-59
   mod_tables
Treatment Record   entity3   req  Uniquely identifies Dose Reference specified by Dose Reference Number (300A,0012) in Dose Reference Sequence (300A,0010) in RT Prescription Module of referenced RT Plan referenced in Referenced RT Plan Sequence (300C,0002) of RT General Treatment Record Module.   desc Referenced Dose Reference Number   name
RT Treatment Summary Record   module   (3008,0050)[<0>](300c,0051)   
M   usage   
table_C.7-1
   mod_tables
Patient   entity3   req   XThe true identity of the patient has been removed from the Attributes and the Pixel Data   
variablelist   typeEnumerated Values:   title      YES   NO   list   descPatient Identity Removed   name
Patient   module   (0012,0062)   
M   usage    y
   mod_tables
Patient   entity3   req   �A sequence of identification numbers or codes used to identify the patient, which may or may not be human readable, and may or may not have been obtained from an implanted or attached device such as an RFID or barcode.1One or more Items are permitted in this sequence.   descOther Patient IDs Sequence   name
Patient   module   (0010,1002)   
M   usage   
table_C.8.8.26-1
   mod_tables
Treatment Record   entity3   req   GIntroduces a Sequence of General Accessories associated with this Beam.1One or more items are permitted in this sequence.   descGeneral Accessory Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0420)   
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
M   usage    �
   mod_tables
Treatment Record   entity1   req.Number of wedges associated with current beam.   descNumber of Wedges   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00d0)   
U   usage    n
   mod_tables
Treatment Record   entity1   reqIdentifies fraction.   descReferenced Fraction Number   name
RT Treatment Summary Record   module+   (3008,0220)[<0>](3008,0240)[<1>](3008,0223)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   yIntroduces a sequence of items describing corrections made to any attributes prior to delivery of the next control point.1One or more Items are permitted in this sequence.   descCorrected Parameter Sequence   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0068)   
M   usage   
table_C.12-1
table_10-3
   mod_tables
Treatment Record   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name

SOP Common   module   (0020,9172)[<0>](0062,000b)   
U   usage    M
   mod_tables
Treatment Record   entity1   req   7Signal source from which respiratory motion is derived.   
variablelist   typeDefined Terms:   title      NONE   BELT   NASAL_PROBE   
CO2_SENSOR   	NAVIGATOR%MR navigator and organ edge detection   MR_PHASEphase (of center k-space line)   ECG baseline demodulation of the ECG   
SPIROMETERSignal derived from flow sensor   EXTERNAL_MARKER0Signal determined from external motion surrogate   INTERNAL_MARKER0Signal determined from internal motion surrogate   IMAGESignal derived from an image   UNKNOWNSignal source not known   list   descRespiratory Signal Source   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0410)[<1>](0018,9171)   
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
M   usage    �
   mod_tables
Treatment Record   entity2C   req1  Table Top Longitudinal position in IEC TABLE TOP coordinate system (mm). This value is interpreted as an absolute, rather than relative, Table setting. Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Table Top Longitudinal Position changes during beam administration.   descTable Top Longitudinal Position   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0129)   
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
U   usage   
table_C.8-48
table_10-3table_10-11
   mod_tables
Treatment Record   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0401)[<1>](0008,1150)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f6)[<1>](300a,00f9)   
M   usage   
table_C.8.8.26-1table_10-11
   mod_tables
Treatment Record   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300c,0040)[<1>](0008,1150)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   8Sequence of doses estimated for each treatment delivery.1One or more Items are permitted in this sequence.   desc-Referenced Calculated Dose Reference Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,0090)   
M   usage   
table_C.8-53table_10-11
   mod_tables
Treatment Record   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
RT General Treatment Record   module   (300c,0002)[<0>](0008,1155)   
M   usage    �
   mod_tables
Treatment Record   entity1   req,Number of boli associated with current Beam.   descNumber of Boli   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00ed)   
U   usage    M
   mod_tables
Treatment Record   entity3   reqComment on the Setup Image.   descSetup Image Comment   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0401)[<1>](300a,0402)   
M   usage    �
   mod_tables
Patient   entity3   req   �The geo-political body that assigned the patient identifier. Typically a code for a country or a state/province. Only a single Item is permitted in this sequence.      
                      ;Equivalent to HL7 v2 CX component 9 (Identifier Type Code).   contentpara   el
                 contentnote   el   desc$Assigning Jurisdiction Code Sequence   name
Patient   module+   (0010,1002)[<0>](0010,0024)[<1>](0040,0039)   
M   usage    �
   mod_tables
Treatment Record   entity3   req)User-supplied identifier for compensator.   descCompensator ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00c0)[<1>](300a,00e5)   
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
Treatment Record   entity3   reqkName of the organization responsible for the Coding Scheme. May include organizational contact information.   desc&Coding Scheme Responsible Organization   name

SOP Common   module   (0008,0110)[<0>](0008,0116)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqVInstitution where the equipment that contributed to the composite instance is located.   descInstitution Name   name

SOP Common   module   (0018,a001)[<0>](0008,0080)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   -Sequence of Applicators associated with Beam.�Required if Applicator Sequence (300A,0107) is included in the RT Ion Plan referenced within the Referenced RT Plan Sequence (300C,0002).6Only a single item shall be included in this sequence.   descApplicator Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0107)   
M   usage   2
   mod_tables
Treatment Record   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name

SOP Common   module   (0020,9172)[<0>](0008,1160)   
M   usage   
table_C.12-1
table_10-1
   mod_tables
Treatment Record   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0080)   
M   usage   
table_C.12-1table_C.12-6
   mod_tables
Treatment Record   entity1   req   �The Transfer Syntax UID used to encode the values of the Data Elements included in the MAC calculation. Only Transfer Syntaxes that explicitly include the VR and use Little Endian encoding shall be used.      
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
U   usage   K
   mod_tables
Study   entity3   reqOccupation of the Patient.   desc
Occupation   name
Patient Study   module   (0010,2180)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   Particle type of Beam.   
variablelist   typeDefined Terms:   title      PHOTON   PROTON   ION   list   descRadiation Type   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00c6)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   "Date the SOP Instance was created.xThis is the date that the SOP Instance UID was assigned, and does not change during subsequent coercion of the instance.   descInstance Creation Date   name

SOP Common   module   (0008,0012)   
M   usage   �
   mod_tables
Treatment Record   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1101)   
M   usage    �
   mod_tables
Treatment Record   entity1   reqANumber of lateral spreading devices associated with current beam.   desc#Number of Lateral Spreading Devices   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0330)   
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
M   usage    �
   mod_tables
Treatment Record   entity3   req   FSequence of doses measured during treatment delivery for current Beam.1One or more Items are permitted in this sequence.   desc+Referenced Measured Dose Reference Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,0080)   
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
Treatment Record   entity1   req   �Sequence of Items each providing a reference to an Instance that is part of the Series defined by Series Instance UID (0020,000E) in the enclosing Item.5One or more Items shall be included in this sequence.   descReferenced Instance Sequence   name
Common Instance Reference   module   (0008,1115)[<0>](0008,114a)   
M   usage   �
   mod_tables
Series   entity3   reqJThe unique identifier for the Study provided for this Requested Procedure.   descStudy Instance UID   name
	RT Series   module   (0040,0275)[<0>](0020,000d)   
U   usage   
table_C.7-2b
   mod_tables
Patient   entity1   req   'Identifier for the noted protocol. See        select: label	   xrefstylesect_C.7.1.3.1.2   linkend   attrsxref   el.   descClinical Trial Protocol ID   name
Clinical Trial Subject   module   (0012,0020)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Uniquely identifies Control Point specified by Control Point Index (300A,0112) within the Beam referenced by Referenced Beam Number (300C,0006).   descReferenced Control Point Index   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300c,00f0)   
U   usage   
table_C.12-8
table_10-4
   mod_tables
Treatment Record   entity1   req   FSequence of Items each of which includes the Attributes of one Series.5One or more Items shall be included in this sequence.   descReferenced Series Sequence   name
Common Instance Reference   module   (0008,1200)[<0>](0008,1115)   
M   usage   V
   mod_tables
Treatment Record   entity1   req   IDescribes the purpose for which the related equipment is being reference.6Only a single Item shall be included in this sequence.   See        select: label	   xrefstylesect_C.12.1.1.5   linkend   attrsxref   el for further explanation.   desc"Purpose of Reference Code Sequence   name

SOP Common   module   (0018,a001)[<0>](0040,a170)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqUser-defined name for block.   desc
Block Name   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00d0)[<1>](300a,00fe)   
M   usage   �
   mod_tables
Series   entity1C   req   �The integer numerator of a rational representation of Numeric Value (0040,A30A). Encoded as a signed integer value. The same number of values as Numeric Value (0040,A30A) shall be present.�Required if Numeric Value (0040,A30A) has insufficient precision to represent a rational value as a string. May be present otherwise.   descRational Numerator Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a162)   
M   usage    y
   mod_tables
Patient   entity3   req$Ethnic group or race of the patient.   descEthnic Group   name
Patient   module   (0010,2160)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   B  Direction of Beam Limiting Device Rotation when viewing beam limiting device (collimator) from radiation source, for segment beginning at current Control Point. Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Beam Limiting Device Rotation Direction changes during beam administration.   
variablelist   typeEnumerated Values:   title      CW	clockwise   CCcounter-clockwise   NONEno rotation   list   desc'Beam Limiting Device Rotation Direction   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0121)   
M   usage    �
   mod_tables
Study   entity2   reqDate the Study started.   desc
Study Date   name
General Study   module   (0008,0020)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Measured Dose in units specified by Dose Units (3004,0002) in sequence referenced by Measured Dose Reference Sequence (3008,0010) or Dose Reference Sequence (300A,0010) in RT Prescription Module of Referenced RT Ion Plan as defined above.   descMeasured Dose Value   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0080)[<1>](3008,0016)   
M   usage   
table_C.7-8
   mod_tables
	Equipment   entity3   reqcDepartment in the institution where the equipment that produced the composite instances is located.   descInstitutional Department Name   name
General Equipment   module   (0008,1040)   
M   usage    y
   mod_tables
Patient   entity1   req>An identification number or code used to identify the patient.   desc
Patient ID   name
Patient   module   (0010,1002)[<0>](0010,0020)   
M   usage    �
   mod_tables
Study   entity3   req   4Identification of the patient's referring physician.1Only a single item is permitted in this sequence.   desc+Referring Physician Identification Sequence   name
General Study   module   (0008,0096)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   �Machine specific setting attribute for the range shifter. The specific encoding of this value should be documented in a Conformance Statement. See        select: label	   xrefstylesect_C.8.8.25.5   linkend   attrsxref   el.   descRange Shifter Setting   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,0360)[<2>](300a,0362)   
M   usage   �
   mod_tables
Treatment Record   entity1C   req   �The type of certified timestamp used in Certified Timestamp (0400,0310). Required if Certified Timestamp (0400,0310) is present.   Defined Terms:   title
variablelist   type      CMS_TSP<Internet X.509 Public Key Infrastructure Time Stamp Protocol   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descCertified Timestamp Type   name

SOP Common   module   (fffa,fffa)[<0>](0400,0305)   
M   usage   
table_C.8-37table_10-11
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   module   (0008,1111)[<0>](0008,1155)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   XUniquely identifies a Related General SOP Class for the SOP Class of this Instance. See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descRelated General SOP Class UID   name

SOP Common   module   (0008,001a)   
M   usage    �
   mod_tables
Treatment Record   entity2C   req        Direction of Table Top Pitch Rotation when viewing the table along the positive X-axis of the IEC TABLE TOP coordinate system, for segment following Control Point. Required for first item of Control Point Sequence, or if Table Top Pitch Rotation Direction changes during Beam. See        select: label	   xrefstylesect_C.8.8.14.8   linkend   attrsxref   el and        select: label	   xrefstylesect_C.8.8.25.6.2   linkend   attrsxref   el.   
variablelist   typeEnumerated Values:   title      CW	clockwise   CCcounter-clockwise   NONEno rotation   list   desc"Table Top Pitch Rotation Direction   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0142)   
M   usage   I
   mod_tables
Series   entity1C   req   (DateTime value for this name-value Item./Required if Value Type (0040,A040) is DATETIME.   descDateTime   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a120)   
M   usage   
table_C.8-54
   mod_tables
Treatment Record   entity2   req:Manufacturer of the equipment used for treatment delivery.   descManufacturer   name
RT Treatment Machine Record   module   (300a,0206)[<0>](0008,0070)   
U   usage   
table_C.8-56
   mod_tables
Treatment Record   entity1C   req  Uniquely identifies Dose Reference specified by Dose Reference Number (300A,0012) in Dose Reference Sequence (300A,0010) in RT Prescription Module of referenced RT Plan. Required only if Calculated Dose Reference Number (3008,0072) is not sent. It shall not be present otherwise.   desc Referenced Dose Reference Number   name
 Calculated Dose Reference Record   module   (3008,0070)[<0>](300c,0051)   
M   usage   [
   mod_tables
	Equipment   entity3   req'Identifier of the gantry or positioner.   desc	Gantry ID   name
General Equipment   module   (0018,1008)   
M   usage   V
   mod_tables
Treatment Record   entity3   req9Uniquely identifies device that created the SOP Instance.   descInstance Creator UID   name

SOP Common   module   (0008,0014)   
M   usage    �
   mod_tables
Treatment Record   entity1C   reqHCharge state of radiation. Required if Radiation Type (300A,00C6) is ION   descRadiation Charge State   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0306)   
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
M   usage    �
   mod_tables
Treatment Record   entity1C   req   m  Closest distance from the central axis of the beam along a wedge axis to the thin edge as projected to the machine isocentric plane (mm). Value is positive is the wedge does not cover the central axis, negative if it does. Required if Wedge Type (300A,00D3) of the wedge referenced by Referenced Wedge Number (300C,00C0) is PARTIAL_STANDARD or PARTIAL_MOTORIZ. See        select: label	   xrefstylesect_C.8.8.25.6.4   linkend   attrsxref   el.   descWedge Thin Edge Position   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,03ac)[<2>](300a,00db)   
U   usage    M
   mod_tables
Treatment Record   entity3   req   #Sequence of Motion Synchronization.1One or more items are permitted in this sequence.   descMotion Synchronization Sequence   name
RT Patient Setup   module   (300a,0180)[<0>](300a,0410)   
M   usage   �
   mod_tables
Treatment Record   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0082)   
M   usage    �
   mod_tables
Treatment Record   entity1   req}Uniquely identifies block specified by Block Number (300A,00FC) within Beam referenced by Referenced Beam Number (300C,0006).   descReferenced Block Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00d0)[<1>](300c,00e0)   
U   usage   e
   mod_tables
Study   entity1C   req   PThe identifier of the protocol for which consent to distribute has been granted.�Required if Distribution Type (0012,0084) is NAMED_PROTOCOL and the protocol is not that which is specified in Clinical Trial Protocol ID (0012,0020) in the Clinical Trial Subject Module.   descClinical Trial Protocol ID   name
Clinical Trial Study   module   (0012,0083)[<0>](0012,0020)   
U   usage    M
   mod_tables
Treatment Record   entity3   req-User-defined description of Shielding Device.   descShielding Device Description   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01a0)[<1>](300a,01a6)   
M   usage   [
   mod_tables
	Equipment   entity3   reqQInstitution where the equipment that produced the composite instances is located.   descInstitution Name   name
General Equipment   module   (0008,0080)   
M   usage    y
   mod_tables
Patient   entity2C   req   FName of person with medical decision making authority for the patient.?Required if the patient is an animal. May be present otherwise.   descResponsible Person   name
Patient   module   (0010,2297)   
M   usage   �
   mod_tables
Series   entity1C   req   RIdentifier that identifies the Requested Procedure in the Imaging Service Request.>Required if procedure was scheduled. May be present otherwise.      
                      :  The condition is to allow the contents of this macro to be present (e.g., to convey the reason for the procedure, such as whether a mammogram is for screening or diagnostic purposes) even when the procedure was not formally scheduled and a value for this identifier is unknown, rather than making up a dummy value.   contentpara   el
                 contentnote   el   descRequested Procedure ID   name
	RT Series   module   (0040,0275)[<0>](0040,1001)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Uniquely identifies range shifter specified by Range Shifter Number (300A,0316) within Beam referenced by Referenced Beam Number (300C,0006).   descReferenced Range Shifter Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f2)[<1>](300c,0100)   
M   usage    �
   mod_tables
Treatment Record   entity2C   req)  Table Top Vertical position in IEC TABLE TOP coordinate system (mm). This value is interpreted as an absolute, rather than relative, Table setting. Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Table Top Vertical Position changes during beam administration.   descTable Top Vertical Position   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0128)   
U   usage    M
   mod_tables
Treatment Record   entity3   reqGUser-defined description of Setup Reference used for patient alignment.   descSetup Reference Description   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01b4)[<1>](300a,01d0)   
M   usage    y
   mod_tables
Patient   entity1C   req   OA code describing the mechanism or method use to remove the patient's identity.�One or more Items shall be included in this sequence. Multiple items are used if successive de-identification steps have been performed or to describe options of a defined profile.�Required if Patient Identity Removed (0012,0062) is present and has a value of YES and De-identification Method (0012,0063) is not present. May be present otherwise.   desc&De-identification Method Code Sequence   name
Patient   module   (0012,0064)   
M   usage   V
   mod_tables
Treatment Record   entity3   req"The coding scheme full common name   descCoding Scheme Name   name

SOP Common   module   (0008,0110)[<0>](0008,0115)   
M   usage    �
   mod_tables
Study   entity3   req   .Coded reason(s) for performing this procedure.      
                          �May differ from the values in Reason for the Requested Procedure (0040,100A) in Request Attribute Sequence (0040,0275), for example if what was performed differs from what was requested.   contentpara   el
                     contentnote   el1One or more Items are permitted in this Sequence.   desc,Reason For Performed Procedure Code Sequence   name
General Study   module   (0040,1012)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f4)[<1>](300a,00f9)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req
  The x and y coordinates of the scan spots are defined as projected onto the machine isocentric plane in the IEC GANTRY coordinate system (mm). Required if Scan Mode (300A,0308) is MODULATED. Contains 2N values were N is the Number of Scan Spot Positions (300A,0392).   descScan Spot Position Map   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0394)   
M   usage    �
   mod_tables
Series   entity1C   req   �The floating point representation of Numeric Value (0040,A30A). The same number of values as Numeric Value (0040,A30A) shall be present.~Required if Numeric Value (0040,A30A) has insufficient precision to represent the value as a string. May be present otherwise.   descFloating Point Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a161)   
M   usage    y
   mod_tables
Patient   entity3   reqBirth time of the Patient.   descPatient's Birth Time   name
Patient   module   (0010,0032)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   *Type of beam limiting device (collimator).   
variablelist   typeEnumerated Values:   title      X%symmetric jaw pair in IEC X direction   Y%symmetric jaw pair in IEC Y direction   ASYMX&asymmetric jaw pair in IEC X direction   ASYMY"asymmetric pair in IEC Y direction   MLCX5multileaf (multi-element) jaw pair in IEC X direction   MLCY5multileaf (multi-element) jaw pair in IEC Y direction   list   descRT Beam Limiting Device Type   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00a0)[<1>](300a,00b8)   
M   usage   �
   mod_tables
Series   entity1C   req   MNumeric value for this name-value Item. Only a single value shall be present..Required if Value Type (0040,A040) is NUMERIC.   descNumeric Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a30a)   
M   usage    y
   mod_tables
Patient   entity3   req6User-defined additional information about the patient.   descPatient Comments   name
Patient   module   (0010,4000)   
M   usage   �
   mod_tables
Treatment Record   entity1   req<A UID that can be used to uniquely reference this signature.   descDigital Signature UID   name

SOP Common   module   (fffa,fffa)[<0>](0400,0100)   
M   usage    �
   mod_tables
Series   entity1C   req   #UID value for this name-value Item.-Required if Value Type (0040,A040) is UIDREF.   descUID   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a124)   
M   usage   �
   mod_tables
Treatment Record   entity3   reqtMailing address of the institution or organization to which the identified individual is responsible or accountable.   descInstitution Address   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0081)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   UPolar angle (degrees) of the fixation light coordinate. Used for eye treatments. See        select: label	   xrefstylesect_C.8.8.25.6.4   linkend   attrsxref   el.   descFixation Light Polar Angle   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0358)   
U   usage    n
   mod_tables
Treatment Record   entity2   req!Time when fraction was delivered.   descTreatment Time   name
RT Treatment Summary Record   module+   (3008,0220)[<0>](3008,0240)[<1>](3008,0251)   
M   usage   S
   mod_tables
Series   entity3   req   CSequence that contains attributes from the Imaging Service Request.1One or more Items are permitted in this sequence.   descRequest Attributes Sequence   name
	RT Series   module   (0040,0275)   
M   usage   I
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
M   usage    �
   mod_tables
Treatment Record   entity1   req�Uniquely identifies range modulator specified by Range Modulator Number (300A,0344) within Beam referenced by Referenced Beam Number (300C,0006).   desc!Referenced Range Modulator Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f6)[<1>](300c,0104)   
M   usage   
table_C.8-37table_10-16
   mod_tables
Series   entity3   req]Institution-generated description or classification of the Procedure Step that was performed.   desc$Performed Procedure Step Description   name
	RT Series   module   (0040,0254)   
M   usage    y
   mod_tables
Patient   entity2C   req   :Information identifying an animal within a breed registry.6Zero or more Items shall be included in this sequence.%Required if the patient is an animal.   descBreed Registration Sequence   name
Patient   module   (0010,2294)   
U   usage    M
   mod_tables
Treatment Record   entity3   reqZAn identifier for the accessory intended to be read by a device such as a bar-code reader.   descAccessory Code   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01a0)[<1>](300a,00f9)   
M   usage   V
   mod_tables
Treatment Record   entity1   req:Date and time the attributes were removed and/or replaced.   descAttribute Modification DateTime   name

SOP Common   module   (0400,0561)[<0>](0400,0562)   
U   usage    M
   mod_tables
Treatment Record   entity3   req�The Fixation Device Roll Angle, i.e., orientation of ROLLED FIXATION DEVICE coordinate system with respect to IEC PITCHED FIXATION DEVICE coordinate system (degrees). Rolling is the rotation around IEC PATIENT SUPPORT Y-axis.   descFixation Device Roll Angle   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0190)[<1>](300a,019a)   
U   usage    n
   mod_tables
Treatment Record   entity3   req+User-defined description of Dose Reference.   descDose Reference Description   name
RT Treatment Summary Record   module   (3008,0050)[<0>](300a,0016)   
M   usage   
   mod_tables
Series   entity1C   req   MNumeric value for this name-value Item. Only a single value shall be present..Required if Value Type (0040,A040) is NUMERIC.   descNumeric Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a30a)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqMDescription of the contribution the equipment made to the composite instance.   descContribution Description   name

SOP Common   module   (0018,a001)[<0>](0018,a003)   
U   usage   �
   mod_tables
Treatment Record   entity1   req   �Sequence of Items each providing a reference to an Instance that is part of the Series defined by Series Instance UID (0020,000E) in the enclosing Item.5One or more Items shall be included in this sequence.   descReferenced Instance Sequence   name
Common Instance Reference   module+   (0008,1200)[<0>](0008,1115)[<1>](0008,114a)   
M   usage    �
   mod_tables
Series   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0008,1199)[<3>](0008,1160)   
M   usage    �
   mod_tables
Treatment Record   entity2C   req   �Table Top Roll Angle, i.e., the rotation of the IEC TABLE TOP coordinate system about the Y-axis of the IEC TABLE TOP coordinate system (degrees). Required for first item of Control Point Sequence, or if Table Top Roll Angle changes during Beam. See        select: label	   xrefstylesect_C.8.8.25.6.2   linkend   attrsxref   el.   descTable Top Roll Angle   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0144)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   *Measurement unit of the machine dosimeter.   
variablelist   typeEnumerated Values:   title      MUMonitor Units   NPNumber of Particles   list   descPrimary Dosimeter Unit   name
RT Ion Beams Session Record   module   (300a,00b3)   
M   usage   
table_C.8-37
table_10-9
table_10-2table_10-11
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   module[   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)[<4>](0008,1150)   
M   usage   [
   mod_tables
	Equipment   entity3   reqQManufacturer's model name of the equipment that produced the composite instances.   descManufacturer's Model Name   name
General Equipment   module   (0008,1090)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   "Time the SOP Instance was created.xThis is the time that the SOP Instance UID was assigned, and does not change during subsequent coercion of the instance.   descInstance Creation Time   name

SOP Common   module   (0008,0013)   
M   usage    y
   mod_tables
Patient   entity1C   req   The species of the patient.6Only a single Item shall be included in this sequence.}Required if the patient is an animal and if Patient Species Description (0010,2201) is not present. May be present otherwise.   descPatient Species Code Sequence   name
Patient   module   (0010,2202)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   �Machine setting actually delivered as recorded by primary Meterset in units specified by Primary Dosimeter Unit (300A,00B3). See        select: label	   xrefstylesect_C.8.8.26.1   linkend   attrsxref   el.   descDelivered Primary Meterset   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,0036)   
M   usage   �
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)[<2>](0008,1150)   
U   usage   �
   mod_tables
Treatment Record   entity1C   req   �Sequence of items each identifying a Study other than the Study of which this Instance is a part, which Studies contain Instances that are referenced elsewhere in this Instance.5One or more Items shall be included in this sequence.@Required if this Instance references Instances in other Studies.   desc6Studies Containing Other Referenced Instances Sequence   name
Common Instance Reference   module   (0008,1200)   
U   usage   K
   mod_tables
Study   entity3   req+Description of the type of service episode.   descService Episode Description   name
Patient Study   module   (0038,0062)   
M   usage   �
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
M   usage   V
   mod_tables
Treatment Record   entity3   req   �Date when the image acquisition device calibration was last changed in any way. Multiple entries may be used for additional calibrations at other times. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descDate of Last Calibration   name

SOP Common   module   (0018,a001)[<0>](0018,1200)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqzThe specified speed of delivery of the specified dose in units specified by Primary Dosimeter Unit (300A,00B3) per minute.   descMeterset Rate Set   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0045)   
M   usage    �
   mod_tables
Study   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name
General Study   module   (0008,0096)[<0>](0040,1103)   
M   usage   �
   mod_tables
Series   entity3   req   +Coded Reason for requesting this procedure.1One or more Items are permitted in this sequence.   desc,Reason for Requested Procedure Code Sequence   name
	RT Series   module   (0040,0275)[<0>](0040,100a)   
M   usage   
table_C.8.8.26-1table_C.8.8.27-1
   mod_tables
Treatment Record   entity1   req   �  Positions of beam limiting device (collimator) leaf (element) or jaw pairs (in mm) in IEC BEAM LIMITING DEVICE coordinate axis appropriate to RT Beam Limiting Device Type (300A,00B8), e.g., X-axis for MLCX, Y-axis for MLCY. Contains 2N values, where N is the Number of Leaf/Jaw Pairs (300A,00BC) in Ion Beam Limiting Device Sequence (300A,03A4). Values shall be listed in IEC leaf (element) subscript order 101, 102, … 1N, 201, 202, … 2N. See        select: label	   xrefstylesect_C.8.8.25.3   linkend   attrsxref   el.   descLeaf/Jaw Positions   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,011a)[<2>](300a,011c)   
M   usage   
   mod_tables
Treatment Record   entity2   reqJManufacturer's serial number of the equipment used for treatment delivery.   descDevice Serial Number   name
RT Treatment Machine Record   module   (300a,0206)[<0>](0018,1000)   
M   usage   �
   mod_tables
Series   entity3   req3Time on which the Performed Procedure Step started.   desc#Performed Procedure Step Start Time   name
	RT Series   module   (0040,0245)   
U   usage    M
   mod_tables
Treatment Record   entity3   req9Description of respiratory motion compensation technique.   desc5Respiratory Motion Compensation Technique Description   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0410)[<1>](0018,9185)   
U   usage   �
   mod_tables
Patient   entity2   req   OThe identifier of the site responsible for submitting clinical trial data. See        select: label	   xrefstylesect_C.7.1.3.1.4   linkend   attrsxref   el.   descClinical Trial Site ID   name
Clinical Trial Subject   module   (0012,0030)   
U   usage    n
   mod_tables
Treatment Record   entity3   req   :Sequence describing status of fractions in Fraction Group.1One or more Items are permitted in this sequence.   desc Fraction Status Summary Sequence   name
RT Treatment Summary Record   module   (3008,0220)[<0>](3008,0240)   
U   usage    n
   mod_tables
Treatment Record   entity2   req   0Conditions under which treatment was terminated.   
variablelist   typeEnumerated Values:   title      NORMALtreatment terminated normally   OPERATORoperator terminated treatment   MACHINE<machine terminated treatment for other than NORMAL condition   UNKNOWNstatus at termination unknown   list   descTreatment Termination Status   name
RT Treatment Summary Record   module+   (3008,0220)[<0>](3008,0240)[<1>](3008,002a)   
M   usage    �
   mod_tables
Treatment Record   entity3   req(User-supplied identifier for block tray.   descBlock Tray ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00d0)[<1>](300a,00f5)   
U   usage    n
   mod_tables
Treatment Record   entity2   req   !Indicates type of fraction group.   
variablelist   typeEnumerated Values:   title      EXTERNAL_BEAM   BRACHY   list   descFraction Group Type   name
RT Treatment Summary Record   module   (3008,0220)[<0>](3008,0224)   
U   usage   �
   mod_tables
Patient   entity1C   req   �Identifies the subject for blinded evaluations. Shall be present if Clinical Trial Subject ID (0012,0040) is absent. May be present otherwise. See        select: label	   xrefstylesect_C.7.1.3.1.7   linkend   attrsxref   el.   desc!Clinical Trial Subject Reading ID   name
Clinical Trial Subject   module   (0012,0042)   
M   usage   [
   mod_tables
	Equipment   entity3   req   kManufacturer's designation of software version of the equipment that produced the composite instances. See        select: label	   xrefstylesect_C.7.5.1.1.3   linkend   attrsxref   el.   descSoftware Versions   name
General Equipment   module   (0018,1020)   
U   usage    1
   mod_tables
Treatment Record   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0401)[<1>](0062,000b)   
U   usage   
table_C.8-55
   mod_tables
Treatment Record   entity2   req   Type of dose measurement.   
variablelist   typeDefined Terms:   title      DIODEsemiconductor diode   TLDthermoluminescent dosimeter   ION_CHAMBERion chamber   GELdose sensitive gel   EPID electronic portal imaging device   FILMdose sensitive film   list   descMeasured Dose Type   name
Measured Dose Reference Record   module   (3008,0010)[<0>](3008,0014)   
M   usage    �
   mod_tables
Treatment Record   entity1   req6Number of range shifters associated with current beam.   descNumber of Range Shifters   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0312)   
M   usage   V
   mod_tables
Treatment Record   entity3   req�The inherent limiting resolution in mm of the acquisition equipment for high contrast objects for the data gathering and reconstruction technique chosen. If variable across the images of the series, the value at the image center.   descSpatial Resolution   name

SOP Common   module   (0018,a001)[<0>](0018,1050)   
U   usage   
table_C.12-8table_10-11
   mod_tables
Treatment Record   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Common Instance Reference   module+   (0008,1115)[<0>](0008,114a)[<1>](0008,1150)   
M   usage    �
   mod_tables
Treatment Record   entity2   req)Name of operator who authorized override.   descOperators' Name   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0060)[<2>](0008,1070)   
U   usage    n
   mod_tables
Treatment Record   entity2   req!Date when fraction was delivered.   descTreatment Date   name
RT Treatment Summary Record   module+   (3008,0220)[<0>](3008,0240)[<1>](3008,0250)   
M   usage   I
   mod_tables
Series   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)[<2>](0008,1160)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�Number of spot positions used to specify scanning pattern for current segment beginning at control point. Required if Scan Mode (300A,0308) is MODULATED.   descNumber of Scan Spot Positions   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0392)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   ASequence of Range Shifter settings for the current control point.5One or more items shall be included in this sequence.�Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Range Shifter Setting (300A,0362) changes during beam administration,and Number of Range Shifters (300A,0312) is non-zero.   descRange Shifter Settings Sequence   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0360)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqmThe certification number issued to the Application Entity that set the SOP Instance Status (0100,0410) to AO.   desc,Authorization Equipment Certification Number   name

SOP Common   module   (0100,0426)   
M   usage   �
   mod_tables
Series   entity1C   req   `Identifies the segments to which the reference applies identified by Segment Number (0062,0004).�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
	RT Series   module[   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)[<4>](0062,000b)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req     Direction of Gantry Rotation when viewing gantry from isocenter, for segment beginning at current Control Point. Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041), or if Gantry Rotation Direction changes during beam administration.   
variablelist   typeEnumerated Values:   title      CW	clockwise   CCcounter-clockwise   NONEno rotation   list   descGantry Rotation Direction   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,011f)   
M   usage    
   mod_tables
Patient   entity3   req   lAttributes specifying or qualifying the identity of the issuer of the Patient ID, or scoping the Patient ID.1Only a single Item is permitted in this sequence.   desc(Issuer of Patient ID Qualifiers Sequence   name
Patient   module   (0010,0024)   
U   usage   
table_C.12-8
table_10-4table_10-11
   mod_tables
Treatment Record   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Common Instance Reference   module;   (0008,1200)[<0>](0008,1115)[<1>](0008,114a)[<2>](0008,1150)   
M   usage   
table_C.8-53
   mod_tables
Treatment Record   entity2   req�Date when current fraction was delivered, or Date last fraction was delivered in case of RT Treatment Summary Record IOD. See Note.   descTreatment Date   name
RT General Treatment Record   module   (3008,0250)   
M   usage    �
   mod_tables
Study   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name
General Study   module   (0008,0096)[<0>](0040,1101)   
M   usage   V
   mod_tables
Treatment Record   entity1   req   Encrypted data. See        select: label	   xrefstylesect_C.12.1.1.4.2   linkend   attrsxref   el.   descEncrypted Content   name

SOP Common   module   (0400,0500)[<0>](0400,0520)   
M   usage    �
   mod_tables
Study   entity3   req   5Institutional department where the request initiated.1Only a single item is permitted in this sequence.   desc Requesting Service Code Sequence   name
General Study   module   (0032,1034)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqqUser-defined description of reason for override of parameter specified by Override Parameter Pointer (3008,0062).   descOverride Reason   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0060)[<2>](3008,0066)   
U   usage   e
   mod_tables
Study   entity3   req   �A description of a set of one or more studies that are grouped together to represent a clinical time point or submission in a clinical trial. See        select: label	   xrefstylesect_C.7.2.3.1.1   linkend   attrsxref   el.   desc%Clinical Trial Time Point Description   name
Clinical Trial Study   module   (0012,0051)   
U   usage    M
   mod_tables
Treatment Record   entity3   req7Identifies the device providing the respiratory signal.   descRespiratory Signal Source ID   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0410)[<1>](0018,9186)   
M   usage   �
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   module[   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)[<4>](0008,1155)   
M   usage   
   mod_tables
Series   entity1C   req   ,Coded concept value of this name-value Item.6Only a single Item shall be included in this Sequence.+Required if Value Type (0040,A040) is CODE.   descConcept Code Sequence   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a168)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   �Sequence of Items containing descriptive attributes of related equipment that has contributed to the acquisition, creation or modification of the composite instance.1One or more Items are permitted in this Sequence.   See        select: label	   xrefstylesect_C.12.1.1.5   linkend   attrsxref   el for further explanation.   descContributing Equipment Sequence   name

SOP Common   module   (0018,a001)   
M   usage   [
   mod_tables
	Equipment   entity2   reqDManufacturer of the equipment that produced the composite instances.   descManufacturer   name
General Equipment   module   (0008,0070)   
M   usage   V
   mod_tables
Treatment Record   entity1   req   |Sequence that contains all the Attributes, with their previous values, that were modified or removed from the main data set.6Only a single Item shall be included in this sequence.   descModified Attributes Sequence   name

SOP Common   module   (0400,0561)[<0>](0400,0550)   
M   usage   �
   mod_tables
Treatment Record   entity1   req   �The date and time the Digital Signature was created. The time shall include an offset (i.e., time zone indication) from Coordinated Universal Time.      
                            �This is not a certified timestamp, and hence is not completely verifiable. An application can compare this date and time with those of other signatures and the validity date of the certificate to gain confidence in the veracity of this date and time.   contentpara   el
                       contentnote   el   descDigital Signature DateTime   name

SOP Common   module   (fffa,fffa)[<0>](0400,0105)   
M   usage   �
   mod_tables
Treatment Record   entity1   req   WThe algorithm used in generating the MAC to be encrypted to form the Digital Signature.   Defined Terms:   title
variablelist   type      	RIPEMD160   MD5   SHA1   SHA256   SHA384   SHA512   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descMAC Algorithm   name

SOP Common   module   (4ffe,0001)[<0>](0400,0015)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�Uniquely identifies Dose Reference specified by Dose Reference Number (300A,0012) in Dose Reference Sequence (300A,0010) in RT Prescription Module of referenced RT Ion Plan. Required if Referenced Calculated Dose Reference Number (3008,0092) is not sent.   desc Referenced Dose Reference Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0090)[<1>](300c,0051)   
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
U   usage    n
   mod_tables
Treatment Record   entity3   reqnReferences Fraction Group Number (300A,0071) in Fraction Group Sequence (300A,0070) in the referenced RT Plan.   desc Referenced Fraction Group Number   name
RT Treatment Summary Record   module   (3008,0220)[<0>](300c,0022)   
M   usage   �
   mod_tables
Series   entity1C   req   AUnits of measurement for a numeric value in this name-value Item.6Only a single Item shall be included in this Sequence..Required if Value Type (0040,A040) is NUMERIC.   descMeasurement Units Code Sequence   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,08ea)   
U   usage    M
   mod_tables
Treatment Record   entity3   req   4Sequence of Shielding Devices used in Patient Setup.1One or more items are permitted in this sequence.   descShielding Device Sequence   name
RT Patient Setup   module   (300a,0180)[<0>](300a,01a0)   
U   usage    M
   mod_tables
Treatment Record   entity3   req*Position/Notch number of Shielding Device.   descShielding Device Position   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01a0)[<1>](300a,01a8)   
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
M   usage   
table_C.12-1table_10-11
   mod_tables
Treatment Record   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name

SOP Common   module   (0040,a390)[<0>](0008,1155)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�Start position defines the range modulator position at which the beam is switched on. Required if Range Modulator Type (300A,0348) of the range modulator referenced by Referenced Range Modulator Number (300C,0104) is WHL_MODWEIGHTS or WHL_FIXEDWEIGHTS   desc"Range Modulator Gating Start Value   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,0380)[<2>](300a,0382)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300c,00b0)[<1>](300a,00f9)   
M   usage   �
   mod_tables
Series   entity1C   req   (DateTime value for this name-value Item./Required if Value Type (0040,A040) is DATETIME.   descDateTime   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a120)   
M   usage   �
   mod_tables
Series   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
	RT Series   module+   (0040,0275)[<0>](0008,0051)[<1>](0040,0032)   
M   usage   V
   mod_tables
Treatment Record   entity1C   req�The coding scheme UID identifier. Required if coding scheme is identified by an ISO 8824 object identifier compatible with the UI VR.   descCoding Scheme UID   name

SOP Common   module   (0008,0110)[<0>](0008,010c)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   �Angle (in degrees) of the head fixation for eye treatments with respect to the Table Top Pitch Angle (300A,0140) coordinate system. Positive head fixation angle is the same direction as positive Table Top Pitch. See        select: label	   xrefstylesect_C.8.8.25.6.4   linkend   attrsxref   el.   descHead Fixation Angle   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0148)   
M   usage   [
   mod_tables
	Equipment   entity3   reqPUser defined name identifying the machine that produced the composite instances.   descStation Name   name
General Equipment   module   (0008,1010)   
M   usage    �
   mod_tables
Treatment Record   entity1C   reqB  Beam Limiting Device (collimator) angle, i.e., orientation of IEC BEAM LIMITING DEVICE coordinate system with respect to IEC GANTRY coordinate system (degrees). Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if beam limiting device (collimator) angle changes during beam administration.   descBeam Limiting Device Angle   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0120)   
U   usage    M
   mod_tables
Treatment Record   entity3   req,User-defined description of Setup Technique.   descSetup Technique Description   name
RT Patient Setup   module   (300a,0180)[<0>](300a,01b2)   
M   usage   S
   mod_tables
Series   entity1   req Unique identifier of the series.   descSeries Instance UID   name
	RT Series   module   (0020,000e)   
M   usage    y
   mod_tables
Patient   entity2C   req      The breed of the patient. See        select: label	   xrefstylesect_C.7.1.1.1.1   linkend   attrsxref   el.wRequired if the patient is an animal and if Patient Breed Code Sequence (0010,2293) is empty. May be present otherwise.   descPatient Breed Description   name
Patient   module   (0010,2292)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqSThe coding scheme version associated with the Coding Scheme Designator (0008,0102).   descCoding Scheme Version   name

SOP Common   module   (0008,0110)[<0>](0008,0103)   
M   usage    �
   mod_tables
Study   entity2   req-User or equipment generated Study identifier.   descStudy ID   name
General Study   module   (0020,0010)   
M   usage   Z
   mod_tables
Treatment Record   entity1C   req   NSequence of beam limiting device (collimator) jaw or leaf (element) positions.5One or more items shall be included in this sequence.�Required if Ion Beam Limiting Device Sequence (300A,03A4) or Beam Limiting Device Leaf Pairs Sequence (3008,00A0) is included in this SOP instance and for first item of Ion Control Point Sequence, or if Beam Limiting Device changes during Beam.   desc&Beam Limiting Device Position Sequence   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,011a)   
M   usage   
   mod_tables
Treatment Record   entity2   reqLUser-defined name identifying treatment machine used for treatment delivery.   descTreatment Machine Name   name
RT Treatment Machine Record   module   (300a,0206)[<0>](300a,00b2)   
U   usage   
   mod_tables
Treatment Record   entity1   req   8Sequence of doses estimated for each treatment delivery.5One or more Items shall be included in this sequence.   desc"Calculated Dose Reference Sequence   name
 Calculated Dose Reference Record   module   (3008,0070)   
M   usage    �
   mod_tables
Treatment Record   entity3   req�Uniquely identifies Ion Patient Setup to be used for current beam, specified by Patient Setup Number (300A,0182) within Patient Setup Sequence of RT Patient Setup Module.   descReferenced Patient Setup Number   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300c,006a)   
M   usage   V
   mod_tables
Treatment Record   entity1   req   *Uniquely identifies the SOP Instance. See        select: label	   xrefstylesect_C.12.1.1.1   linkend   attrsxref   el# for further explanation. See also        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descSOP Instance UID   name

SOP Common   module   (0008,0018)   
U   usage   �
   mod_tables
Patient   entity1C   req�Name of the Ethics Committee or Institutional Review Board (IRB) responsible for approval of the Clinical Trial. Required if Clinical Trial Protocol Ethics Committee Approval Number (0012,0082) is present.   desc-Clinical Trial Protocol Ethics Committee Name   name
Clinical Trial Subject   module   (0012,0081)   
M   usage    �
   mod_tables
Treatment Record   entity1   req3User or machine supplied identifier for Applicator.   descApplicator ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0107)[<1>](300a,0108)   
U   usage   �
   mod_tables
Treatment Record   entity1   reqDUnique identifier of the Series containing the referenced Instances.   descSeries Instance UID   name
Common Instance Reference   module+   (0008,1200)[<0>](0008,1115)[<1>](0020,000e)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqMRadiation source to general accessory distance (in mm) for current accessory.   desc$Source to General Accessory Distance   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0420)[<1>](300a,0425)   
M   usage   �
   mod_tables
Series   entity3   req�Sequence that specifies the context for the Scheduled Protocol Code Sequence Item. One or more Items are permitted in this sequence.   descProtocol Context Sequence   name
	RT Series   module+   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)   
M   usage    �
   mod_tables
Study   entity1   req Unique identifier for the Study.   descStudy Instance UID   name
General Study   module   (0020,000d)   
M   usage    �
   mod_tables
Treatment Record   entity3   req�The Scanning Spot Size as calculated using the Full Width Half Maximum (FWHM). Specified by a numeric pair - the size measured in air at isocenter in IEC GANTRY X direction followed by the size in the IEC GANTRY Y direction (mm).   descScanning Spot Size   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0398)   
M   usage   I
   mod_tables
Series   entity1   req   +Coded concept name of this name-value Item.6Only a single Item shall be included in this Sequence.   descConcept Name Code Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a043)   
M   usage    �
   mod_tables
Treatment Record   entity1   req!Number of control points in Beam.   descNumber of Control Points   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0110)   
M   usage   
   mod_tables
Treatment Record   entity2   reqPInstitution where the equipment is located that was used for treatment delivery.   descInstitution Name   name
RT Treatment Machine Record   module   (300a,0206)[<0>](0008,0080)   
M   usage    y
   mod_tables
Patient   entity2   reqBirth date of the patient.   descPatient's Birth Date   name
Patient   module   (0010,0030)   
U   usage    M
   mod_tables
Treatment Record   entity3   req   &Setup Technique used in Patient Setup.   
variablelist   typeDefined Terms:   title      
ISOCENTRIC   	FIXED_SSD   TBI   BREAST_BRIDGE   SKIN_APPOSITION   list   descSetup Technique   name
RT Patient Setup   module   (300a,0180)[<0>](300a,01b0)   
U   usage    M
   mod_tables
Treatment Record   entity1   req   0Sequence of patient setup data for current plan.5One or more items shall be included in this sequence.   descPatient Setup Sequence   name
RT Patient Setup   module   (300a,0180)   
M   usage    �
   mod_tables
Study   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name
General Study   module   (0008,1049)[<0>](0008,0082)   
U   usage   K
   mod_tables
Study   entity3   req>Identifier of the visit as assigned by the healthcare provider   descAdmission ID   name
Patient Study   module   (0038,0010)   
M   usage   �
   mod_tables
Series   entity1C   req   $Text value for this name-value Item.+Required if Value Type (0040,A040) is TEXT.   desc
Text Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a160)   
M   usage    �
   mod_tables
Treatment Record   entity1   reqvUniquely references Range Shifter described by Range Shifter Number (300A,0316) in Range Shifter Sequence (300A,0314).   descReferenced Range Shifter Number   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,0360)[<2>](300c,0100)   
M   usage   
   mod_tables
Treatment Record   entity3   reqgMailing address of the institution where the equipment is located that was used for treatment delivery.   descInstitution Address   name
RT Treatment Machine Record   module   (300a,0206)[<0>](0008,0081)   
M   usage   V
   mod_tables
Treatment Record   entity1   req   &Reason for the attribute modification.   
variablelist   typeDefined Terms:   title      COERCE�Replace values of attributes such as Patient Name, ID, Accession Number, for example, during import of media from an external institution, or reconciliation against a master patient index.   CORRECT�Replace incorrect values, such as Patient Name or ID, for example, when incorrect worklist item was chosen or operator input error.   list   desc%Reason for the Attribute Modification   name

SOP Common   module   (0400,0561)[<0>](0400,0565)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqUUser defined name identifying the machine that contributed to the composite instance.   descStation Name   name

SOP Common   module   (0018,a001)[<0>](0008,1010)   
M   usage    �
   mod_tables
Treatment Record   entity2   reqNominal wedge angle (degrees).   descWedge Angle   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00b0)[<1>](300a,00d5)   
U   usage   �
   mod_tables
Patient   entity3   reqkApproval number issued by committee described in Clinical Trial Protocol Ethics Committee Name (0012,0081).   desc8Clinical Trial Protocol Ethics Committee Approval Number   name
Clinical Trial Subject   module   (0012,0082)   
M   usage    �
   mod_tables
Series   entity1C   req   �The integer denominator of a rational representation of Numeric Value (0040,A30A). Encoded as a non-zero unsigned integer value. The same number of values as Numeric Value (0040,A30A) shall be present.<Required if Rational Numerator Value (0040,A162) is present.   descRational Denominator Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a163)   
M   usage   I
   mod_tables
Series   entity1C   req   `Identifies the segments to which the reference applies identified by Segment Number (0062,0004).�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)[<2>](0062,000b)   
M   usage   �
   mod_tables
Treatment Record   entity3   req   �A certified timestamp of the Digital Signature (0400,0120) Attribute Value, which shall be obtained when the Digital Signature is created. See        select: label	   xrefstylesect_C.12.1.1.3.1.3   linkend   attrsxref   el.   descCertified Timestamp   name

SOP Common   module   (fffa,fffa)[<0>](0400,0310)   
U   usage   �
   mod_tables
Patient   entity1   req   ,The name of the clinical trial sponsor. See        select: label	   xrefstylesect_C.7.1.3.1.1   linkend   attrsxref   el.   descClinical Trial Sponsor Name   name
Clinical Trial Subject   module   (0012,0010)   
M   usage    �
   mod_tables
Treatment Record   entity1   req0Number of shielding blocks associated with Beam.   descNumber of Blocks   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00f0)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   (Sequence of blocks associated with Beam.5Required if Number of Blocks (300A,00F0) is non-zero.5One or more items shall be included in this sequence.TThe number of items shall be identical to the value of Number of Blocks (300A,00F0).   descRecorded Block Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,00d0)   
M   usage   �
   mod_tables
Series   entity1   req   +Coded concept name of this name-value Item.6Only a single Item shall be included in this Sequence.   descConcept Name Code Sequence   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a043)   
U   usage   K
   mod_tables
Study   entity3   reqAge of the Patient.   descPatient's Age   name
Patient Study   module   (0010,1010)   
M   usage    
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
M   usage    �
   mod_tables
Treatment Record   entity1   req�Uniquely identifies compensator specified by Compensator Number (300A,00E4) within Beam referenced by Referenced Beam Number (300C,0006).   descReferenced Compensator Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00c0)[<1>](300c,00d0)   
M   usage   �
   mod_tables
Series   entity1C   req   �The floating point representation of Numeric Value (0040,A30A). The same number of values as Numeric Value (0040,A30A) shall be present.~Required if Numeric Value (0040,A30A) has insufficient precision to represent the value as a string. May be present otherwise.   descFloating Point Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a161)   
U   usage    M
   mod_tables
Treatment Record   entity2   req2User-defined label identifier for Fixation Device.   descFixation Device Label   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0190)[<1>](300a,0194)   
M   usage    �
   mod_tables
Treatment Record   entity1C   reqIAtomic number of radiation. Required if Radiation Type (300A,00C6) is ION   descRadiation Atomic Number   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0304)   
M   usage    �
   mod_tables
Treatment Record   entity3   req    Specifies the type of accessory.   
variablelist   typeDefined Terms:   title      	GRATICULE'Accessory tray with a radio-opaque grid   IMAGE_DETECTOR4Image acquisition device positioned in the beam line   RETICLE5Accessory tray with radio-transparent markers or grid   list   descGeneral Accessory Type   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0420)[<1>](300a,0423)   
M   usage    y
   mod_tables
Patient   entity3   req   BIndicates whether or not the subject is a quality control phantom.   
variablelist   typeEnumerated Values:   title      YES   NO   listJIf this Attribute is absent, then the subject may or may not be a phantom.�This attribute describes a characteristic of the Imaging Subject. It is distinct from Quality Control Image (0028,0300) in the General Image Module, which is used to describe an image acquired.   descQuality Control Subject   name
Patient   module   (0010,0200)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqIThe Date & Time when the equipment contributed to the composite instance.   descContribution DateTime   name

SOP Common   module   (0018,a001)[<0>](0018,a002)   
U   usage    M
   mod_tables
Treatment Record   entity3   req�Longitudinal Displacement in IEC TABLE TOP coordinate system (in mm) relative to initial Setup Position, i.e., longitudinal offset between patient positioning performed using setup and treatment position.   desc)Table Top Longitudinal Setup Displacement   name
RT Patient Setup   module   (300a,0180)[<0>](300a,01d4)   
U   usage   
   mod_tables
Study   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
Patient Study   module   (0038,0064)[<0>](0040,0031)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req.  Patient Support angle, i.e., orientation of IEC PATIENT SUPPORT (turntable) coordinate system with respect to IEC FIXED REFERENCE coordinate system (degrees). Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Patient Support Angle changes during beam administration.   descPatient Support Angle   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0122)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   +Position of Wedge at current control point.   
variablelist   typeEnumerated Values:   title      IN   OUT   list   descWedge Position   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,03ac)[<2>](300a,0118)   
M   usage   �
   mod_tables
Treatment Record   entity1   req�A number, unique within this SOP Instance, used to identify this MAC Parameters Sequence (4FFE,0001) item from an Item of the Digital Signatures Sequence (FFFA,FFFA).   descMAC ID Number   name

SOP Common   module   (4ffe,0001)[<0>](0400,0005)   
M   usage    �
   mod_tables
Treatment Record   entity2   req   (Type of wedge (if any) defined for Beam.   
variablelist   typeDefined Terms:   title      STANDARDstandard (static) wedge   	MOTORIZED4single wedge that can be removed from beam remotely.   PARTIAL_STANDARDFwedge does not extend across the whole field and is operated manually.   PARTIAL_MOTORIZSwedge does not extend across the whole field and can be removed from beam remotely.   list   desc
Wedge Type   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00b0)[<1>](300a,00d3)   
M   usage   �
   mod_tables
Series   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
	RT Series   module[   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0008,1199)[<4>](0008,1160)   
M   usage   �
   mod_tables
Series   entity3   req   }Sequence that specifies modifiers for a Protocol Context Content Item. One or more Items are permitted in this sequence. See        select: label	   xrefstylesect_C.4.10.1   linkend   attrsxref   el.   descContent Item Modifier Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)   
M   usage   
table_C.8.8.26-1table_C.8.8.28-1
   mod_tables
Treatment Record   entity3   reqLUser-specified identifier for manufacturer specific patient support devices.   descPatient Support ID   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0352)   
U   usage   	\
   mod_tables
Treatment Record   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Common Instance Reference   module+   (0008,1115)[<0>](0008,114a)[<1>](0008,1155)   
M   usage   �
   mod_tables
Study   entity3   reqPerson's mailing address   descPerson's Address   name
General Study   module   (0008,1062)[<0>](0040,1102)   
M   usage   
   mod_tables
Series   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name
	RT Series   moduleK   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)[<3>](0008,1160)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   .Sequence of range shifters recorded with Beam.=Required if Number of Range Shifters (300A,0312) is non-zero.5One or more items shall be included in this sequence.\The number of items shall be identical to the value of Number of Range Shifters (300A,0312).   descRecorded Range Shifter Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,00f2)   
M   usage    �
   mod_tables
Treatment Record   entity1   reqZNumber of leaf (element) or jaw pairs (equal to 1 for standard beam limiting device jaws).   descNumber of Leaf/Jaw Pairs   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00a0)[<1>](300a,00bc)   
M   usage   �
   mod_tables
Treatment Record   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1103)   
M   usage    
   mod_tables
Patient   entity3   req   �The place or location identifier where the identifier was first assigned to the patient. This component is not an inherent part of the identifier but rather part of the history of the identifier.1Only a single Item is permitted in this sequence.      
                      9Equivalent to HL7 v2 CX component 6 (Assigning Facility).   contentpara   el
                 contentnote   el   descAssigning Facility Sequence   name
Patient   module   (0010,0024)[<0>](0040,0036)   
M   usage   S
   mod_tables
Series   entity2   req1Name(s) of the operator(s) supporting the Series.   descOperators' Name   name
	RT Series   module   (0008,1070)   
M   usage    �
   mod_tables
Patient   entity3   req   �Universal or unique identifier for the Patient ID Assigning Authority. The authority identified by this attribute shall be the same as that of Issuer of Patient ID (0010,0021), if present.      
                      BEquivalent to HL7 v2 CX component 4 subcomponent 2 (Universal ID).   contentpara   el
                 contentnote   el   descUniversal Entity ID   name
Patient   module+   (0010,1002)[<0>](0010,0024)[<1>](0040,0032)   
M   usage   V
   mod_tables
Treatment Record   entity1   req�Instance Identifier of the referenced HL7 Structured Document, encoded as a UID (OID or UUID), concatenated with a caret ("^") and Extension value (if Extension is present in Instance Identifier).   descHL7 Instance Identifier   name

SOP Common   module   (0040,a390)[<0>](0040,e001)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqzThe delivered speed of delivery of the specified dose in units specified by Primary Dosimeter Unit (300A,00B3) per minute.   descMeterset Rate Delivered   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0046)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   &Sequence of boli associated with Beam.3Required if Number of Boli (300A,00ED) is non-zero.5One or more items shall be included in this sequence.RThe number of items shall be identical to the value of Number of Boli (300A,00ED).   descReferenced Bolus Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300c,00b0)   
M   usage   
   mod_tables
Treatment Record   entity3   reqbDepartment in the institution where the equipment is located that was used for treatment delivery.   descInstitutional Department Name   name
RT Treatment Machine Record   module   (300a,0206)[<0>](0008,1040)   
M   usage    �
   mod_tables
Treatment Record   entity1C   reqGMass number of radiation. Required if Radiation Type (300A,00C6) is ION   descRadiation Mass Number   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0302)   
U   usage    n
   mod_tables
Treatment Record   entity3   req   3Sequence of references to Measured Dose References.1One or more Items are permitted in this sequence.   desc2Treatment Summary Measured Dose Reference Sequence   name
RT Treatment Summary Record   module   (3008,00e0)   
M   usage   I
   mod_tables
Series   entity1C   req   �The integer numerator of a rational representation of Numeric Value (0040,A30A). Encoded as a signed integer value. The same number of values as Numeric Value (0040,A30A) shall be present.�Required if Numeric Value (0040,A30A) has insufficient precision to represent a rational value as a string. May be present otherwise.   descRational Numerator Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a162)   
M   usage   V
   mod_tables
Treatment Record   entity1C   req   2Sequence of Items containing encrypted DICOM data.5One or more Items shall be included in this sequence.   �Required if application level confidentiality is needed and certain recipients are allowed to decrypt all or portions of the Encrypted Attributes Data Set. See        select: label	   xrefstylesect_C.12.1.1.4.1   linkend   attrsxref   el.   descEncrypted Attributes Sequence   name

SOP Common   module   (0400,0500)   
M   usage    �
   mod_tables
Treatment Record   entity2   req�Orientation of wedge, i.e., orientation of IEC WEDGE FILTER coordinate system with respect to the IEC BEAM LIMITING DEVICE coordinate systems (degrees).   descWedge Orientation   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00b0)[<1>](300a,00d8)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Uniquely identifies ROI representing the Bolus specified by ROI Number (3006,0022) in Structure Set ROI Sequence (3006,0020) in Structure Set Module within RT Structure Set in Referenced Structure Set Sequence (300C,0060) in RT General Plan Module.   descReferenced ROI Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300c,00b0)[<1>](3006,0084)   
M   usage   V
   mod_tables
Treatment Record   entity3   req�Retrieval access path to HL7 Structured Document. Includes fully specified scheme, authority, path, and query in accordance with RFC 2396   descRetrieve URI   name

SOP Common   module   (0040,a390)[<0>](0040,e010)   
M   usage   
table_C.12-1
table_10-3table_10-11
   mod_tables
Treatment Record   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name

SOP Common   module   (0020,9172)[<0>](0008,1155)   
U   usage    M
   mod_tables
Treatment Record   entity1   req�Identification number of the Patient Setup. The value of Patient Setup Number (300A,0182) shall be unique within the RT Plan in which it is created.   descPatient Setup Number   name
RT Patient Setup   module   (300a,0180)[<0>](300a,0182)   
M   usage   �
   mod_tables
Treatment Record   entity3   req   $Sequence holding Digital Signatures.1One or more items are permitted in this sequence.   descDigital Signatures Sequence   name

SOP Common   module   (fffa,fffa)   
M   usage   [
   mod_tables
	Equipment   entity3   req   TManufacturer's serial number of the equipment that produced the composite instances.      
                          �This identifier corresponds to the device that actually created the images, such as a CR plate reader or a CT console, and may not be sufficient to identify all of the equipment in the imaging chain, such as the generator or gantry or plate.   contentpara   el
                     contentnote   el   descDevice Serial Number   name
General Equipment   module   (0018,1000)   
M   usage    
   mod_tables
Patient   entity3   req   �Universal or unique identifier for the Patient ID Assigning Authority. The authority identified by this attribute shall be the same as that of Issuer of Patient ID (0010,0021), if present.      
                      BEquivalent to HL7 v2 CX component 4 subcomponent 2 (Universal ID).   contentpara   el
                 contentnote   el   descUniversal Entity ID   name
Patient   module   (0010,0024)[<0>](0040,0032)   
U   usage    M
   mod_tables
Treatment Record   entity3   reqZAn identifier for the accessory intended to be read by a device such as a bar-code reader.   descAccessory Code   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01b4)[<1>](300a,00f9)   
U   usage    M
   mod_tables
Treatment Record   entity3   req�Vertical Displacement in IEC TABLE TOP coordinate system (in mm) relative to initial Setup Position, i.e., vertical offset between patient positioning performed using setup and treatment position.   desc%Table Top Vertical Setup Displacement   name
RT Patient Setup   module   (300a,0180)[<0>](300a,01d2)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   ISequence of verification images obtained during delivery of current beam.1One or more items are permitted in this sequence.   See        select: label	   xrefstylesect_C.8.8.14.2   linkend   attrsxref   el.   desc&Referenced Verification Image Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300c,0040)   
M   usage    �
   mod_tables
Series   entity1C   req   �The integer numerator of a rational representation of Numeric Value (0040,A30A). Encoded as a signed integer value. The same number of values as Numeric Value (0040,A30A) shall be present.�Required if Numeric Value (0040,A30A) has insufficient precision to represent a rational value as a string. May be present otherwise.   descRational Numerator Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a162)   
M   usage   V
   mod_tables
Treatment Record   entity1C   req   ^The view requested during the C-MOVE operation that resulted in the transfer of this instance.   
variablelist   typeEnumerated Values:   title      CLASSIC   ENHANCED   listRequired if the instance has ever been converted from its source form as the result of a C-MOVE operation with a specific view.   descQuery/Retrieve View   name

SOP Common   module   (0008,0053)   
M   usage   e
   mod_tables
Treatment Record   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name

SOP Common   module   (0040,a390)[<0>](0008,1150)   
M   usage    �
   mod_tables
Treatment Record   entity2C   req   �Gantry Pitch Angle. i.e., the rotation of the IEC GANTRY coordinate system about the X-axis of the IEC GANTRY coordinate system (degrees). Required for first item of Control Point Sequence, or if Gantry Pitch Rotation Angle changes during Beam. See        select: label	   xrefstylesect_C.8.8.25.6.5   linkend   attrsxref   el.   descGantry Pitch Angle   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,014a)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   �The intended number of times the scan pattern given by Scan Spot Position Map (300A,0394) and Scan Spot Meterset Weights (300A,0396) in the Referenced RT Plan was to be applied at the current control point.      
                          �The actual number of paintings is not known or recorded. The Scan Spot Metersets Delivered (3008,0047) contains the sum of all complete and partial repaints.   contentpara   el
                     contentnote   el/Required if Scan Mode (300A,0308) is MODULATED.   descNumber of Paintings   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,039a)   
U   usage   K
   mod_tables
Study   entity3   req$Weight of the Patient, in kilograms.   descPatient's Weight   name
Patient Study   module   (0010,1030)   
M   usage   �
   mod_tables
Series   entity3   reqJAn identifier of the Imaging Service Request for this Requested Procedure.   descAccession Number   name
	RT Series   module   (0040,0275)[<0>](0008,0050)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   (Sequence of Snouts associated with Beam.�Required if Snout Sequence (300A,030C) is included in the RT Ion Plan referenced within the Referenced RT Plan Sequence (300C,0002).6Only a single item shall be included in this sequence.   descRecorded Snout Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,00f0)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Contains the Data Element Tag of the parent sequence containing the attribute that was corrected. The value is limited in scope to the Treatment Session Ion Beam Sequence (3008,0021) and all nested sequences therein.   descParameter Sequence Pointer   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0068)[<2>](3008,0061)   
M   usage    
   mod_tables
Patient   entity3   req   pThe agency or department that assigned the patient identifier. Only a single Item is permitted in this sequence.      
                      <Equivalent to HL7 v2 CX component 10 (Identifier Type Code).   contentpara   el
                 contentnote   el   desc,Assigning Agency or Department Code Sequence   name
Patient   module   (0010,0024)[<0>](0040,003a)   
U   usage   K
   mod_tables
Study   entity3   req   Patient's size category code1One or more Items are permitted in this sequence.   descPatient's Size Code Sequence   name
Patient Study   module   (0010,1021)   
M   usage   	�
   mod_tables
Treatment Record   entity2   req   Reference to a RT Plan.4Zero or one Item shall be included in this Sequence.   descReferenced RT Plan Sequence   name
RT General Treatment Record   module   (300c,0002)   
M   usage   I
   mod_tables
Series   entity1   req   6The type of the value encoded in this name-value Item.   
variablelist   typeEnumerated Values:   title
      DATE   TIME   DATETIME   PNAME   UIDREF   TEXT   CODE   NUMERIC   	COMPOSITE   IMAGE   list   desc
Value Type   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a040)   
U   usage    M
   mod_tables
Treatment Record   entity1   req   0Type of Setup Device used for Patient alignment.   
variablelist   typeDefined Terms:   title      LASER_POINTER   DISTANCE_METER   TABLE_HEIGHT   MECHANICAL_PTR   ARC   list   descSetup Device Type   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01b4)[<1>](300a,01b6)   
U   usage    M
   mod_tables
Treatment Record   entity1   req   9Technique applied to reduce respiratory motion artifacts.   
variablelist   typeDefined Terms:   title
      NONE   BREATH_HOLD   REALTIME0image acquisition shorter than respiratory cycle   GATINGProspective gating   TRACKING5prospective through-plane or in-plane motion tracking   PHASE_ORDERINGprospective phase ordering   PHASE_RESCANNINGdprospective techniques, such as real-time averaging, diminishing variance and motion adaptive gating   RETROSPECTIVEretrospective gating   
CORRECTIONretrospective image correction   UNKNOWNtechnique not known   list   desc)Respiratory Motion Compensation Technique   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0410)[<1>](0018,9170)   
M   usage    �
   mod_tables
Series   entity1   req   6The type of the value encoded in this name-value Item.   
variablelist   typeEnumerated Values:   title
      DATE   TIME   DATETIME   PNAME   UIDREF   TEXT   CODE   NUMERIC   	COMPOSITE   IMAGE   list   desc
Value Type   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a040)   
M   usage   �
   mod_tables
Treatment Record   entity1   req   "The MAC generated as described in        select: label	   xrefstylesect_C.12.1.1.3.1.1   linkend   attrsxref   el and encrypted using the algorithm, parameters, and private key associated with the Certificate of the Signer (0400,0115). See        select: label	   xrefstylesect_C.12.1.1.3.1.2   linkend   attrsxref   el.   desc	Signature   name

SOP Common   module   (fffa,fffa)[<0>](0400,0120)   
M   usage   I
   mod_tables
Series   entity1C   req   @Composite SOP Instance Reference value for this name-value Item.6Only a single Item shall be included in this Sequence.9Required if Value Type (0040,A040) is COMPOSITE or IMAGE.   descReferenced SOP Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0008,1199)   
M   usage    �
   mod_tables
Treatment Record   entity2C   req        Direction of Table Top Roll Rotation when viewing the table along the positive Y-axis of the IEC TABLE TOP coordinate system, for segment following Control Point. Required for first item of Control Point Sequence, or if Table Top Roll Rotation Direction changes during Beam. See        select: label	   xrefstylesect_C.8.8.14.8   linkend   attrsxref   el and        select: label	   xrefstylesect_C.8.8.25.6.2   linkend   attrsxref   el.   
variablelist   typeEnumerated Values:   title      CW	clockwise   CCcounter-clockwise   NONEno rotation   list   desc!Table Top Roll Rotation Direction   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0146)   
M   usage   �
   mod_tables
Series   entity3   req   FA sequence that conveys the Procedure Type of the requested procedure.1Only a single Item is permitted in this sequence.   desc!Requested Procedure Code Sequence   name
	RT Series   module   (0040,0275)[<0>](0032,1064)   
U   usage   K
   mod_tables
Study   entity3   req)Length or size of the Patient, in meters.   descPatient's Size   name
Patient Study   module   (0010,1020)   
U   usage   
table_C.7-4atable_10-17
   mod_tables
Study   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   Enumerated Values:   title
variablelist   type      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
Patient Study   module   (0038,0014)[<0>](0040,0033)   
M   usage   I
   mod_tables
Series   entity1C   req   ,Coded concept value of this name-value Item.6Only a single Item shall be included in this Sequence.+Required if Value Type (0040,A040) is CODE.   descConcept Code Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a168)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00d0)[<1>](300a,00f9)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Contains the ones-based sequence item index of the overriden attributes within it's parent sequence. The value is limited in scope to the Treatment Session Ion Beam Sequence (3008,0021) and all nested sequences therein.   descParameter Item Index   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0060)[<2>](3008,0063)   
M   usage   �
   mod_tables
Treatment Record   entity1   req   ,The type of certificate used in (0400,0115).   Defined Terms:   title
variablelist   type      X509_1993_SIG   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descCertificate Type   name

SOP Common   module   (fffa,fffa)[<0>](0400,0110)   
M   usage   S
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
M   usage   
   mod_tables
Series   entity1   req   6The type of the value encoded in this name-value Item.   
variablelist   typeEnumerated Values:   title
      DATE   TIME   DATETIME   PNAME   UIDREF   TEXT   CODE   NUMERIC   	COMPOSITE   IMAGE   list   desc
Value Type   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a040)   
M   usage    �
   mod_tables
Treatment Record   entity2C   req'  Table Top Lateral position in IEC TABLE TOP coordinate system (mm). This value is interpreted as an absolute, rather than relative, Table setting. Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Table Top Lateral Position changes during beam administration.   descTable Top Lateral Position   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,012a)   
U   usage    n
   mod_tables
Treatment Record   entity3   req   5Sequence of references to Calculated Dose References.1One or more Items are permitted in this sequence.   desc4Treatment Summary Calculated Dose Reference Sequence   name
RT Treatment Summary Record   module   (3008,0050)   
M   usage   V
   mod_tables
Treatment Record   entity1   req0May include Sequence Attributes and their Items.   descBAny Attribute from the main data set that was modified or removed.   name

SOP Common   module)   (0400,0561)[<0>](0400,0550)[0](gggg,eeee)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Contains the ones-based sequence item index of the corrected attribute within its parent sequence as indicated by Parameter Sequence Pointer (3008,0061).   descParameter Item Index   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0068)[<2>](3008,0063)   
M   usage    �
   mod_tables
Treatment Record   entity2   req   GConditions under which treatment was verified by a verification system.   
variablelist   typeEnumerated Values:   title      VERIFIEDtreatment verified   VERIFIED_OVRBtreatment verified with at least one out-of-range value overridden   NOT_VERIFIEDtreatment verified manually   list   descTreatment Verification Status   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,002c)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   �The SOP Class in which the Instance was originally encoded that has been replaced during a fall-back conversion to the current Related General SOP Class. See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   desc"Original Specialized SOP Class UID   name

SOP Common   module   (0008,001b)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   6Sequence of Wedge positions for current control point.�Required for first item of Ion Control Point Sequence if Number of Wedges (300A,00D0) is non-zero, and in subsequent control points if Wedge Position (300A,0118) or Wedge Thin Edge Position (300A,00DB) changes during beam.5One or more items shall be included in this sequence.TThe number of items shall be identical to the value of Number of Wedges (300A,00D0).   descIon Wedge Position Sequence   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,03ac)   
U   usage   	�
   mod_tables
Treatment Record   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Common Instance Reference   module;   (0008,1200)[<0>](0008,1115)[<1>](0008,114a)[<2>](0008,1155)   
M   usage   �
   mod_tables
Series   entity1C   req   $Time value for this name-value Item.+Required if Value Type (0040,A040) is TIME.   descTime   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a122)   
M   usage   �
   mod_tables
Series   entity3   req   NUniquely identifies the Study SOP Instances associated with this SOP Instance.1One or more items are permitted in this sequence.   See        select: label	   xrefstylesect_10.6.1   linkend   attrsxref   el.   descReferenced Study Sequence   name
	RT Series   module   (0040,0275)[<0>](0008,1110)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req  Treatment machine gantry angle, i.e., orientation of IEC GANTRY coordinate system with respect to IEC FIXED REFERENCE coordinate system (degrees). Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Gantry Angle changes during beam administration.   descGantry Angle   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,011e)   
U   usage    n
   mod_tables
Treatment Record   entity1   req1Cumulative Dose delivered to Dose Reference (Gy).   desc!Cumulative Dose to Dose Reference   name
RT Treatment Summary Record   module   (3008,0050)[<0>](3008,0052)   
M   usage   �
   mod_tables
Study   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
General Study   module   (0008,1110)[<0>](0008,1150)   
M   usage   �
   mod_tables
Treatment Record   entity1   req      Defined Terms:   title
variablelist   type      TABLETreatment delivery system table   CHAIRTreatment delivery system chair   list   See        select: label	   xrefstylesect_C.8.8.25.6.3   linkend   attrsxref   el.   descPatient Support Type   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0350)   
M   usage    y
   mod_tables
Patient   entity3   req)Other names used to identify the patient.   descOther Patient Names   name
Patient   module   (0010,1001)   
U   usage    n
   mod_tables
Treatment Record   entity3   req  Uniquely identifies Dose Reference specified by Dose Reference Number (300A,0012) in Dose Reference Sequence (300A,0010) in RT Prescription Module of referenced RT Plan referenced in Referenced RT Plan Sequence (300C,0002) of RT General Treatment Record Module.   desc Referenced Dose Reference Number   name
RT Treatment Summary Record   module   (3008,00e0)[<0>](300c,0051)   
M   usage   �
   mod_tables
Treatment Record   entity1   req   �A list of Data Element Tags in the order they appear in the Data Set that identify the Data Elements used in creating the MAC for the Digital Signature. See        select: label	   xrefstylesect_C.12.1.1.3.1.1   linkend   attrsxref   el.   descData Elements Signed   name

SOP Common   module   (4ffe,0001)[<0>](0400,0020)   
M   usage   
table_C.8-53table_10-11
   mod_tables
Treatment Record   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
RT General Treatment Record   module   (3008,0030)[<0>](0008,1150)   
M   usage    �
   mod_tables
Study   entity2   reqTime the Study started.   desc
Study Time   name
General Study   module   (0008,0030)   
U   usage   e
   mod_tables
Study   entity3   req   vA Sequence that conveys information about consent for Clinical Trial use of the composite instances within this Study.1One or more Items are permitted in this sequence.   See        select: label	   xrefstylesect_C.7.2.3.1.2   linkend   attrsxref   el.   desc'Consent for Clinical Trial Use Sequence   name
Clinical Trial Study   module   (0012,0083)   
M   usage    y
   mod_tables
Patient   entity2C   req   LName of organization with medical decision making authority for the patient.;Required if patient is an animal. May be present otherwise.   descResponsible Organization   name
Patient   module   (0010,2299)   
U   usage   
   mod_tables
Treatment Record   entity3   req6User-defined description of Calculated Dose Reference.   desc%Calculated Dose Reference Description   name
 Calculated Dose Reference Record   module   (3008,0070)[<0>](3008,0074)   
M   usage   E
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   moduleK   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)[<3>](0008,1150)   
M   usage    �
   mod_tables
Study   entity3   req   ]Names of the physician(s) who are responsible for overall patient care at time of Study (see        select: label	   xrefstylesect_C.7.3.1   linkend   attrsxref   el for Performing Physician)   descPhysician(s) of Record   name
General Study   module   (0008,1048)   
U   usage   
   mod_tables
Series   entity2   req   vThe name of the institution that is responsible for coordinating the medical imaging data for the clinical trial. See        select: label	   xrefstylesect_C.7.3.2.1.1   linkend   attrsxref   el.   desc'Clinical Trial Coordinating Center Name   name
Clinical Trial Series   module   (0012,0060)   
M   usage   
   mod_tables
Series   entity1C   req   @Composite SOP Instance Reference value for this name-value Item.6Only a single Item shall be included in this Sequence.9Required if Value Type (0040,A040) is COMPOSITE or IMAGE.   descReferenced SOP Sequence   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)   
M   usage   �
   mod_tables
Series   entity3   req�Sequence that specifies the context for the Performed Protocol Code Sequence Item. One or more Items are permitted in this sequence.   descProtocol Context Sequence   name
	RT Series   module   (0040,0260)[<0>](0040,0440)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   tDirection of Patient Support Rotation when viewing table from above, for segment beginning at current Control Point.�Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041), or if Patient Support Rotation Direction changes during beam administration.   
variablelist   typeEnumerated Values:   title      CW	clockwise   CCcounter-clockwise   NONEno rotation   list   desc"Patient Support Rotation Direction   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0123)   
M   usage   S
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
Treatment Record   entity1   req�References Beam specified by Beam Number (300A,00C0) in Ion Beam Sequence (300A,03A2) in RT Ion Beams Module within the referenced RT Ion Plan.   descReferenced Beam Number   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300c,0006)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00c0)[<1>](300a,00f9)   
M   usage    �
   mod_tables
Patient   entity3   req   lAttributes specifying or qualifying the identity of the issuer of the Patient ID, or scoping the Patient ID.1Only a single Item is permitted in this sequence.   desc(Issuer of Patient ID Qualifiers Sequence   name
Patient   module   (0010,1002)[<0>](0010,0024)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�Uniquely references Measured Dose Reference specified by Measured Dose Reference Number (3008,0064) in Measured Dose Reference Sequence (3008,0010). Required if Referenced Dose Reference Number (300C,0051) is not sent.   desc)Referenced Measured Dose Reference Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0080)[<1>](3008,0082)   
M   usage   �
   mod_tables
Series   entity3   requSequence describing the Protocol performed for this Procedure Step. One or more Items are permitted in this sequence.   desc Performed Protocol Code Sequence   name
	RT Series   module   (0040,0260)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   Type of Range Modulator.   
variablelist   typeDefined Terms:   title      FIXEDhfixed modulation width and weights using ridge filter or constant speed wheel with constant beam current   WHL_FIXEDWEIGHTS�selected wheel/track (Range Modulator ID) is spinning at constant speed. Modulation width is adjusted by switching constant beam current on and off at wheel steps indicated by Range Modulator Interrupt Values   WHL_MODWEIGHTS�selected wheel/track (Range Modulator ID) is spinning at constant speed. Weight per wheel step is adjusted by modulating beam current according to selected Beam Current Modulation ID (300A,034C)   list�Only one item in the Recorded Range Modulator Sequence (3008,00F6) can have a Range Modulator Type (300A,0348) of WHL_MODWEIGHTS.   descRange Modulator Type   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f6)[<1>](300a,0348)   
M   usage   �
   mod_tables
Series   entity3   req6User-defined comments on the Performed Procedure Step.   desc(Comments on the Performed Procedure Step   name
	RT Series   module   (0040,0280)   
U   usage    M
   mod_tables
Treatment Record   entity3   req�Lateral Displacement in IEC TABLE TOP coordinate system (in mm) relative to initial Setup Position, i.e., lateral offset between patient positioning performed using setup and treatment position.   desc$Table Top Lateral Setup Displacement   name
RT Patient Setup   module   (300a,0180)[<0>](300a,01d6)   
M   usage   ;
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0008,1199)[<3>](0008,1150)   
U   usage    M
   mod_tables
Treatment Record   entity2   req(User-defined label for Shielding Device.   descShielding Device Label   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01a0)[<1>](300a,01a4)   
M   usage    y
   mod_tables
Patient   entity2C   req      The breed of the patient. See        select: label	   xrefstylesect_C.7.1.1.1.1   linkend   attrsxref   el.6Zero or more Items shall be included in this sequence.%Required if the patient is an animal.   descPatient Breed Code Sequence   name
Patient   module   (0010,2293)   
M   usage   
   mod_tables
Treatment Record   entity2   reqGManufacturer's model name of the equipment used for treatment delivery.   descManufacturer's Model Name   name
RT Treatment Machine Record   module   (300a,0206)[<0>](0008,1090)   
M   usage   �
   mod_tables
Treatment Record   entity3   req   gA sequence of items that describe the parameters used to calculate a MAC for use in Digital Signatures.5One or more Items shall be included in this sequence.   descMAC Parameters Sequence   name

SOP Common   module   (4ffe,0001)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   Motion characteristic of Beam.   
variablelist   typeEnumerated Values:   title      STATIC4all beam parameters remain unchanged during delivery   DYNAMIC3one or more beam parameters changes during delivery   list   desc	Beam Type   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00c4)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Identification number of the Wedges. The value of Wedge Number (300A,00D2) shall be unique within the Beam in which it was created.   descWedge Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00b0)[<1>](300a,00d2)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Time when the delivery of radiation at this control point began. For the final control point this shall be the Time when the previous control point ended.   descTreatment Control Point Time   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0025)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Uniquely references Lateral Spreading Device described by Lateral Spreading Device Number (300A,0334) in Lateral Spreading Device Sequence (300A,0332).   desc*Referenced Lateral Spreading Device Number   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,0370)[<2>](300c,0102)   
U   usage   K
   mod_tables
Study   entity3   req   KIdentifier of the Assigning Authority that issued Admission ID (0038,0010).1Only a single Item is permitted in this sequence.   descIssuer of Admission ID Sequence   name
Patient Study   module   (0038,0014)   
M   usage   S
   mod_tables
Series   entity2   req%A number that identifies this series.   descSeries Number   name
	RT Series   module   (0020,0011)   
U   usage   e
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
M   usage    �
   mod_tables
Treatment Record   entity3   req(Treatment Time actually delivered (sec).   descDelivered Treatment Time   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,003b)   
M   usage   �
   mod_tables
Series   entity1C   req   +Person name value for this name-value Item.,Required if Value Type (0040,A040) is PNAME.   descPerson Name   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a123)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   �Machine specific setting attribute for the lateral spreading device. The specific encoding of this value should be documented in a Conformance Statement. See        select: label	   xrefstylesect_C.8.8.25.5   linkend   attrsxref   el.   desc Lateral Spreading Device Setting   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,0370)[<2>](300a,0372)   
M   usage   V
   mod_tables
Treatment Record   entity3   req9Name(s) of the operator(s) of the contributing equipment.   descOperators' Name   name

SOP Common   module   (0018,a001)[<0>](0008,1070)   
M   usage    �
   mod_tables
Treatment Record   entity3   req(User-defined description for Applicator.   descApplicator Description   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0107)[<1>](300a,010a)   
M   usage   Z
   mod_tables
Treatment Record   entity1   req   �Type of beam limiting device (collimator). The value of this attribute shall correspond to RT Beam Limiting Device Type (300A,00B8) defined in an item of Ion Beam Limiting Device Sequence (300A,03A4).   Enumerated Values:   title
variablelist   type      X%symmetric jaw pair in IEC X direction   Y%symmetric jaw pair in IEC Y direction   ASYMX&asymmetric jaw pair in IEC X direction   ASYMY"asymmetric pair in IEC Y direction   MLCX5multileaf (multi-element) jaw pair in IEC X direction   MLCY5multileaf (multi-element) jaw pair in IEC Y direction   list   descRT Beam Limiting Device Type   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,011a)[<2>](300a,00b8)   
M   usage    �
   mod_tables
Treatment Record   entity3   req#User-supplied identifier for Wedge.   descWedge ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00b0)[<1>](300a,00d4)   
M   usage   S
   mod_tables
Series   entity3   reqDescription of the series.   descSeries Description   name
	RT Series   module   (0008,103e)   
M   usage   �
   mod_tables
Series   entity1C   req   #UID value for this name-value Item.-Required if Value Type (0040,A040) is UIDREF.   descUID   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a124)   
M   usage    �
   mod_tables
Treatment Record   entity1   requMachine setting actually delivered at current control point in units specified by Primary Dosimeter Unit (300A,00B3).   descDelivered Meterset   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0044)   
M   usage    y
   mod_tables
Patient   entity2   req   Sex of the named patient.   
variablelist   typeEnumerated Values:   title      Mmale   Ffemale   Oother   list   descPatient's Sex   name
Patient   module   (0010,0040)   
M   usage   
   mod_tables
Series   entity1C   req   AUnits of measurement for a numeric value in this name-value Item.6Only a single Item shall be included in this Sequence..Required if Value Type (0040,A040) is NUMERIC.   descMeasurement Units Code Sequence   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,08ea)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqiTreatment machine termination code. This code is dependent upon the particular application and equipment.   descTreatment Termination Code   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,002b)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   OSequence of setup and/or treatment beams administered during treatment session.5One or more items shall be included in this sequence.   desc#Treatment Session Ion Beam Sequence   name
RT Ion Beams Session Record   module   (3008,0021)   
M   usage   [
   mod_tables
	Equipment   entity3   reqhMailing address of the institution where the equipment that produced the composite instances is located.   descInstitution Address   name
General Equipment   module   (0008,0081)   
M   usage   V
   mod_tables
Treatment Record   entity1C   req   XThe set of images or other composite SOP Instances that were converted to this instance.zIf this instance was converted from a specific frame in the source instance, the reference shall include the Frame Number.5One or more Items shall be included in this sequence.�Required if this instance was created by conversion, and Conversion Source Attributes Sequence (0020,9172) is not present in an Item of Shared Functional Groups Sequence (5200,9229) or Per-Frame Functional Groups Sequence (5200,9230).   desc%Conversion Source Attributes Sequence   name

SOP Common   module   (0020,9172)   
M   usage   �
   mod_tables
Series   entity1   req   6The type of the value encoded in this name-value Item.   
variablelist   typeEnumerated Values:   title
      DATE   TIME   DATETIME   PNAME   UIDREF   TEXT   CODE   NUMERIC   	COMPOSITE   IMAGE   list   desc
Value Type   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a040)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   �Sequence of items that map values of Coding Scheme Designator (0008,0102) to an external coding system registration, or to a private or local coding scheme.1One or more Items are permitted in this sequence.   desc%Coding Scheme Identification Sequence   name

SOP Common   module   (0008,0110)   
M   usage    �
   mod_tables
Treatment Record   entity2C   req        Direction of Gantry Pitch Angle when viewing along the positive X-axis of the IEC GANTRY coordinate system, for segment following Control Point. Required for first item of Control Point Sequence, or if Gantry Pitch Rotation Direction changes during Beam. See        select: label	   xrefstylesect_C.8.8.14.8   linkend   attrsxref   el and        select: label	   xrefstylesect_C.8.8.25.6.5   linkend   attrsxref   el.   
variablelist   typeEnumerated Values:   title      CW	clockwise   CCcounter-clockwise   NONEno rotation   list   descGantry Pitch Rotation Direction   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,014c)   
M   usage   
   mod_tables
Series   entity1C   req   +Person name value for this name-value Item.,Required if Value Type (0040,A040) is PNAME.   descPerson Name   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a123)   
U   usage    M
   mod_tables
Treatment Record   entity3   req)Position/Notch number of Fixation Device.   descFixation Device Position   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0190)[<1>](300a,0198)   
M   usage    �
   mod_tables
Study   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name
General Study   module   (0008,1049)[<0>](0040,1101)   
M   usage    y
   mod_tables
Patient   entity1C   req   2Relationship of Responsible Person to the patient.   See        select: label	   xrefstylesect_C.7.1.1.1.2   linkend   attrsxref   el for Defined Terms.:Required if Responsible Person is present and has a value.   descResponsible Person Role   name
Patient   module   (0010,2298)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   rTime when the image acquisition device calibration was last changed in any way. Multiple entries may be used. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descTime of Last Calibration   name

SOP Common   module   (0018,a001)[<0>](0018,1201)   
M   usage    �
   mod_tables
Treatment Record   entity1   reqCalculated Dose (Gy).   desc$Calculated Dose Reference Dose Value   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0090)[<1>](3008,0076)   
M   usage    �
   mod_tables
Study   entity3   req   GIdentifier of the Assigning Authority that issued the Accession Number.1Only a single Item is permitted in this sequence.   desc#Issuer of Accession Number Sequence   name
General Study   module   (0008,0051)   
U   usage   �
   mod_tables
Treatment Record   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0401)[<1>](0008,1155)   
U   usage   K
   mod_tables
Study   entity3   req   <A sequence that conveys the admitting diagnosis (diagnoses).1One or more Items are permitted in this Sequence.   desc!Admitting Diagnoses Code Sequence   name
Patient Study   module   (0008,1084)   
M   usage    y
   mod_tables
Patient   entity1   req7Identification number of an animal within the registry.   descBreed Registration Number   name
Patient   module   (0010,2294)[<0>](0010,2295)   
M   usage    y
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
M   usage    �
   mod_tables
Treatment Record   entity2   req   Delivery Type of treatment.   
variablelist   typeDefined Terms:   title      	TREATMENTnormal patient treatment   OPEN_PORTFILMmportal image acquisition with open field (the source of radiation is specified by Radiation Type (300A,00C6))   TRMT_PORTFILMqportal image acquisition with treatment port (the source of radiation is specified by Radiation Type (300A,00C6))   CONTINUATION%continuation of interrupted treatment   SETUP�no treatment beam was applied for this RT Beam. To be used for specifying the gantry, couch, and other machine positions where X-Ray set-up images or measurements were taken   VERIFICATIONBTreatment used for Quality Assurance rather than patient treatment   list   descTreatment Delivery Type   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00ce)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqVManufacturer's model name of the equipment that contributed to the composite instance.   descManufacturer's Model Name   name

SOP Common   module   (0018,a001)[<0>](0008,1090)   
M   usage    �
   mod_tables
Treatment Record   entity2C   reqE  Axial position of the snout (in mm) measured from isocenter to the downstream side of the snout (without consideration of variable length elements such as blocks, MLC and/or compensators). Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Snout Position changes during beam administration.   descSnout Position   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,030d)   
U   usage   K
   mod_tables
Study   entity3   req   UIdentifier of the Assigning Authority that issued the Service Episode ID (0038,0060).1Only a single Item is permitted in this sequence.   desc%Issuer of Service Episode ID Sequence   name
Patient Study   module   (0038,0064)   
U   usage   K
   mod_tables
Study   entity3   req;Additional information about the Patient's medical history.   descAdditional Patient History   name
Patient Study   module   (0010,21b0)   
M   usage   [
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
M   usage    �
   mod_tables
Treatment Record   entity1   reqCContains the Data Element Tag of the attribute that was overridden.   descOverride Parameter Pointer   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0060)[<2>](3008,0062)   
M   usage    �
   mod_tables
Study   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name
General Study   module   (0008,0096)[<0>](0008,0080)   
U   usage   	
   mod_tables
Treatment Record   entity1   req   %Units used to describe measured dose.   
variablelist   typeEnumerated Values:   title      GYGray   RELATIVE)Dose relative to implicit reference value   list   desc
Dose Units   name
Measured Dose Reference Record   module   (3008,0010)[<0>](3004,0002)   
M   usage    �
   mod_tables
Treatment Record   entity2   req-Fraction number for this beam administration.   descCurrent Fraction Number   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,0022)   
M   usage   I
   mod_tables
Series   entity1C   req   AUnits of measurement for a numeric value in this name-value Item.6Only a single Item shall be included in this Sequence..Required if Value Type (0040,A040) is NUMERIC.   descMeasurement Units Code Sequence   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,08ea)   
M   usage    �
   mod_tables
Treatment Record   entity1   req8User or machine supplied identifier for Range Modulator.   descRange Modulator ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f6)[<1>](300a,0346)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   �Contains the offset from UTC to the timezone for all DA and TM Attributes present in this SOP Instance, and for all DT Attributes present in this SOP Instance that do not contain an explicitly encoded timezone offset.�Encoded as an ASCII string in the format "&ZZXX". The components of this string, from left to right, are & = "+" or "-", and ZZ = Hours and XX = Minutes of offset. Leading space characters shall not be present.;The offset for UTC shall be +0000; -0000 shall not be used.      
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
M   usage   
table_C.7-1table_10-18table_10-17
   mod_tables
Patient   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   
variablelist   typeEnumerated Values:   title      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
Patient   module;   (0010,1002)[<0>](0010,0024)[<1>](0040,0036)[<2>](0040,0033)   
U   usage    n
   mod_tables
Treatment Record   entity3   req+User-defined description of Dose Reference.   descDose Reference Description   name
RT Treatment Summary Record   module   (3008,00e0)[<0>](300a,0016)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   LSequence of Lateral Spreading Device settings for the current control point.5One or more items shall be included in this sequence.�Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Lateral Spreading Device Setting (300A,0372) changes during beam administration, and Number of Lateral Spreading Devices (300A,0330) is non-zero.   desc*Lateral Spreading Device Settings Sequence   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0370)   
U   usage   e
   mod_tables
Study   entity2   req   �An identifier specifying the one or more studies that are grouped together as a clinical time point or submission in a clinical trial. See        select: label	   xrefstylesect_C.7.2.3.1.1   linkend   attrsxref   el.   descClinical Trial Time Point ID   name
Clinical Trial Study   module   (0012,0050)   
M   usage   �
   mod_tables
Series   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   
variablelist   typeEnumerated Values:   title      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
	RT Series   module+   (0040,0275)[<0>](0008,0051)[<1>](0040,0033)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   ;Sequence of lateral spreading devices associated with Beam.HRequired if Number of Lateral Spreading Devices (300A,0330) is non-zero.5One or more items shall be included in this sequence.gThe number of items shall be identical to the value of Number of Lateral Spreading Devices (300A,0330).   desc*Recorded Lateral Spreading Device Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,00f4)   
M   usage   �
   mod_tables
Series   entity3   reqZInstitution-generated administrative description or classification of Requested Procedure.   descRequested Procedure Description   name
	RT Series   module   (0040,0275)[<0>](0032,1060)   
M   usage   	�
   mod_tables
Treatment Record   entity3   req   dReference to RT Treatment Records to which the current RT Treatment Record is significantly related.1One or more Items are permitted in this sequence.   desc$Referenced Treatment Record Sequence   name
RT General Treatment Record   module   (3008,0030)   
M   usage   �
   mod_tables
Series   entity3   req1Time at which the Performed Procedure Step ended.   desc!Performed Procedure Step End Time   name
	RT Series   module   (0040,0251)      
M   usage   	�
   mod_tables
Treatment Record   entity1   reqCInstance number identifying this particular instance of the object.   descInstance Number   name
RT General Treatment Record   module   
M   usage   V
   mod_tables
Treatment Record   entity3   req8A number that identifies this Composite object instance.   descInstance Number   name

SOP Common   module   (0020,0013)   
M   usage    y
   mod_tables
Patient   entity3   reqCOther identification numbers or codes used to identify the patient.   descOther Patient IDs   name
Patient   module   (0010,1000)   
U   usage   �
   mod_tables
Patient   entity2   req   -The name of the clinical trial protocol. See        select: label	   xrefstylesect_C.7.1.3.1.3   linkend   attrsxref   el.   descClinical Trial Protocol Name   name
Clinical Trial Subject   module   (0012,0021)   
M   usage   V
   mod_tables
Treatment Record   entity1C   req   �The name of the external registry where further definition of the identified coding scheme may be obtained. Required if coding scheme is registered.   
variablelist   typeDefined Terms:   title      HL7   list   descCoding Scheme Registry   name

SOP Common   module   (0008,0110)[<0>](0008,0112)   
M   usage    b
   mod_tables
Patient   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Patient   module   (0008,1120)[<0>](0008,1155)   
M   usage   V
   mod_tables
Treatment Record   entity1C   req   =Character Set that expands or replaces the Basic Graphic Set.=Required if an expanded or replacement character set is used.   See        select: label	   xrefstylesect_C.12.1.1.2   linkend   attrsxref   el for Defined Terms.   descSpecific Character Set   name

SOP Common   module   (0008,0005)   
U   usage    M
   mod_tables
Treatment Record   entity2   req   LSetup Parameter for Setup Device in appropriate IEC 61217 coordinate system.7Units shall be mm for distances and degrees for angles.   descSetup Device Parameter   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01b4)[<1>](300a,01bc)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   Type of applicator.   
variablelist   typeDefined Terms:   title      
ION_SQUAREsquare ion applicator   ION_RECTrectangular ion applicator   ION_CIRCcircular ion applicator   	ION_SHORTshort ion applicator   ION_OPENopen (dummy) ion applicator   INTRAOPERATIVE"intraoperative (custom) applicator   STEREOTACTICstereotactic applicator   list   descApplicator Type   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0107)[<1>](300a,0109)   
M   usage   I
   mod_tables
Series   entity1C   req   $Text value for this name-value Item.+Required if Value Type (0040,A040) is TEXT.   desc
Text Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a160)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   =A flag that indicates the storage status of the SOP Instance.   
variablelist   typeEnumerated Values:   title      NSwNot Specified; implies that this SOP Instance has no special storage status, and hence no special actions need be taken   OR�Original; implies that this is the primary SOP instance for the purpose of storage, but that it has not yet been authorized for diagnostic use   AO�Authorized Original; implies that this is the primary SOP instance for the purpose of storage, which has been authorized for diagnostic use   AC�Authorized Copy; implies that this is a copy of an Authorized Original SOP Instance; any copies of an Authorized Original should be given the status of Authorized Copy   list      
                        �Proper use of these flags is specified in Security Profiles. Implementations that do not conform to such Security Profiles may not necessarily handle these flags properly.   contentpara   el
                   contentnote   el   descSOP Instance Status   name

SOP Common   module   (0100,0410)   
U   usage    M
   mod_tables
Treatment Record   entity2   req?User-defined label for Setup Device used for patient alignment.   descSetup Device Label   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01b4)[<1>](300a,01b8)   
U   usage   	
   mod_tables
Treatment Record   entity1C   req  Uniquely identifies Dose Reference specified by Dose Reference Number (300A,0012) in Dose Reference Sequence (300A,0010) in RT Prescription Module of referenced RT Plan. Required only if Measured Dose Reference Number (3008,0064) is not sent. It shall not be present otherwise.   desc Referenced Dose Reference Number   name
Measured Dose Reference Record   module   (3008,0010)[<0>](300c,0051)   
M   usage    �
   mod_tables
Study   entity3   reqPerson's mailing address   descPerson's Address   name
General Study   module   (0008,1049)[<0>](0040,1102)   
M   usage    �
   mod_tables
Treatment Record   entity3   req.Machine-readable identifier for this accessory   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0420)[<1>](300a,00f9)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   'User-defined description for Beam. See        select: label	   xrefstylesect_C.8.8.25.1   linkend   attrsxref   el.   descBeam Description   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00c3)   
M   usage   �
   mod_tables
Treatment Record   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name

SOP Common   module   (0020,9172)[<0>](0008,1150)   
M   usage   
   mod_tables
Series   entity1C   req   $Date value for this name-value Item.+Required if Value Type (0040,A040) is DATE.   descDate   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a121)   
M   usage   
   mod_tables
Series   entity1C   req   `Identifies the segments to which the reference applies identified by Segment Number (0062,0004).�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name
	RT Series   moduleK   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0008,1199)[<3>](0062,000b)   
M   usage    �
   mod_tables
Treatment Record   entity1   req    User-defined name for Beam. See        select: label	   xrefstylesect_C.8.8.25.1   linkend   attrsxref   el.   desc	Beam Name   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00c2)   
U   usage    n
   mod_tables
Treatment Record   entity1   req1Cumulative Dose delivered to Dose Reference (Gy).   desc!Cumulative Dose to Dose Reference   name
RT Treatment Summary Record   module   (3008,00e0)[<0>](3008,0052)   
U   usage    M
   mod_tables
Treatment Record   entity3   reqZAn identifier for the accessory intended to be read by a device such as a bar-code reader.   descAccessory Code   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0190)[<1>](300a,00f9)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   JMachine setting actually delivered as recorded by secondary Meterset. See        select: label	   xrefstylesect_C.8.8.26.1   linkend   attrsxref   el.   descDelivered Secondary Meterset   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,0037)   
M   usage    �
   mod_tables
Treatment Record   entity2   reqkDesired machine setting for current control point in units specified by Primary Dosimeter Unit (300A,00B3).   descSpecified Meterset   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0042)   
M   usage   �
   mod_tables
Treatment Record   entity1   req      %  A certificate that holds the identity of the entity producing this Digital Signature, that entity's public key or key identifier, and the algorithm and associated parameters with which that public key is to be used. Algorithms allowed are specified in Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el).      
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
M   usage    �
   mod_tables
Treatment Record   entity1   req   ?Sequence of beam control points for current ion treatment beam.5One or more items shall be included in this sequence.\The number of items shall be identical to the value of Number of Control Points (300A,0110).   See        select: label	   xrefstylesect_C.8.8.21.1   linkend   attrsxref   el.   desc#Ion Control Point Delivery Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,0041)   
U   usage    M
   mod_tables
Treatment Record   entity3   req,User-defined description of Fixation Device.   descFixation Device Description   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0190)[<1>](300a,0196)   
M   usage   �
   mod_tables
Study   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name
General Study   module   (0008,1062)[<0>](0008,0082)   
M   usage   �
   mod_tables
Study   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name
General Study   module   (0008,1062)[<0>](0008,0080)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   jDesired machine setting of primary Meterset in units specified by Primary Dosimeter Unit (300A,00B3). See        select: label	   xrefstylesect_C.8.8.26.1   linkend   attrsxref   el.   descSpecified Primary Meterset   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,0032)   
U   usage   K
   mod_tables
Study   entity2C   req   YWhether or not a procedure has been performed in an effort to render the patient sterile.   
variablelist   typeEnumerated Values:   title      ALTEREDAltered/Neutered   	UNALTEREDUnaltered/intact   list      
                          IIf this Attribute is present but has no value then the status is unknown.   contentpara   el
                     contentnote   el;Required if patient is an animal. May be present otherwise.   descPatient's Sex Neutered   name
Patient Study   module   (0010,2203)   
M   usage    �
   mod_tables
Treatment Record   entity1C   reqV  A data set of Metersets delivered to the scan spot positions. The order of Metersets matches the positions in Scan Spot Position Map (300A,0394). The sum contained in all Metersets shall match the difference of the Delivered Meterset of the current control point to the following control point. Required if Scan Mode (300A,0308) is MODULATED.   descScan Spot Metersets Delivered   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0047)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   rIndicates whether or not the date and time attributes in the instance have been modified during de-identification.   
variablelist   typeEnumerated Values:   title      
UNMODIFIED   MODIFIED   REMOVED   list   See        select: labelnumber	   xrefstylePS3.15	   targetdocPS3.15	   targetptr   attrsolink   el.   desc*Longitudinal Temporal Information Modified   name

SOP Common   module   (0028,0303)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�The value that was added the value referenced by the Parameter Sequence Pointer (3008,0061), Parameter Item Index (3008,0063) and Parameter Pointer (3008,0065).   descCorrection Value   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0068)[<2>](3008,006a)   
M   usage   !
   mod_tables
Treatment Record   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
RT General Treatment Record   module   (3008,0030)[<0>](0008,1155)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   ISequence of beam limiting device (collimator) jaw or leaf (element) sets.1One or more items are permitted in this sequence.   desc(Beam Limiting Device Leaf Pairs Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,00a0)   
M   usage   V
   mod_tables
Treatment Record   entity2C   req�The coding scheme identifier as defined in an external registry. Required if coding scheme is registered and Coding Scheme UID (0008,010C) is not present.   descCoding Scheme External ID   name

SOP Common   module   (0008,0110)[<0>](0008,0114)   
M   usage   [
   mod_tables
	Equipment   entity3   req   �Date when the image acquisition device calibration was last changed in any way. Multiple entries may be used for additional calibrations at other times. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descDate of Last Calibration   name
General Equipment   module   (0018,1200)   
U   usage   
   mod_tables
Treatment Record   entity2   reqCalculated Dose (Gy).   desc$Calculated Dose Reference Dose Value   name
 Calculated Dose Reference Record   module   (3008,0070)[<0>](3008,0076)   
M   usage    �
   mod_tables
Study   entity3   reqWInstitution-generated description or classification of the Study (component) performed.   descStudy Description   name
General Study   module   (0008,1030)   
U   usage   
   mod_tables
Treatment Record   entity1C   req�Unique identifier of dose reference point within RT Treatment Record IOD. Required only if Referenced Dose Reference Number (300C,0051) is not sent. It shall not be present otherwise.   desc Calculated Dose Reference Number   name
 Calculated Dose Reference Record   module   (3008,0070)[<0>](3008,0072)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�Stop position defines the range modulator position at which the beam is switched off. Required if Range Modulator Type (300A,0348) of the range modulator referenced by Referenced Range Modulator Number (300C,0104) is WHL_MODWEIGHTS or WHL_FIXEDWEIGHTS   desc!Range Modulator Gating Stop Value   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,0380)[<2>](300a,0384)   
M   usage   
table_C.7-1table_10-18table_10-17
   mod_tables
Patient   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   
variablelist   typeEnumerated Values:   title      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
Patient   module+   (0010,0024)[<0>](0040,0036)[<1>](0040,0033)   
U   usage    M
   mod_tables
Treatment Record   entity3   req�The Fixation Device Pitch Angle, i.e., orientation of PITCHED FIXATION DEVICE coordinate system with respect to IEC PATIENT SUPPORT coordinate system (degrees). Pitching is the rotation around IEC PATIENT SUPPORT X-axis.   descFixation Device Pitch Angle   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0190)[<1>](300a,0199)   
M   usage   
   mod_tables
Series   entity1C   req   �The integer denominator of a rational representation of Numeric Value (0040,A30A). Encoded as a non-zero unsigned integer value. The same number of values as Numeric Value (0040,A30A) shall be present.<Required if Rational Numerator Value (0040,A162) is present.   descRational Denominator Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a163)   
U   usage    n
   mod_tables
Treatment Record   entity2   req3Date of delivery of the most recent administration.   descMost Recent Treatment Date   name
RT Treatment Summary Record   module   (3008,0056)   
U   usage   �
   mod_tables
Patient   entity1C   req   <The assigned identifier for the clinical trial subject. See        select: label	   xrefstylesect_C.7.1.3.1.6   linkend   attrsxref   elh. Shall be present if Clinical Trial Subject Reading ID (0012,0042) is absent. May be present otherwise.   descClinical Trial Subject ID   name
Clinical Trial Subject   module   (0012,0040)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req,  Nominal Beam Energy at control point in MeV per nucleon. Defined at nozzle entrance before all Beam Modifiers. Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041) or if Nominal Beam Energy (300A,0114) changes during beam administration, and KVP (0018,0060) is not present.   descNominal Beam Energy   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0114)   
U   usage   �
   mod_tables
Treatment Record   entity1   reqCUnique identifier of the Study containing the referenced Instances.   descStudy Instance UID   name
Common Instance Reference   module   (0008,1200)[<0>](0020,000d)   
M   usage    �
   mod_tables
Study   entity3   req�Identification of the physician(s) reading the Study. One or more items are permitted in this sequence. If more than one Item, the number and order shall correspond to the value of Name of Physician(s) Reading Study (0008,1060), if present.   desc2Physician(s) Reading Study Identification Sequence   name
General Study   module   (0008,1062)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqYManufacturer's serial number of the equipment that contributed to the composite instance.   descDevice Serial Number   name

SOP Common   module   (0018,a001)[<0>](0018,1000)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   oSequence of Items containing all attributes that were removed or replaced by other values in the main data set.1One or more Items are permitted in this sequence.   descOriginal Attributes Sequence   name

SOP Common   module   (0400,0561)   
M   usage   �
   mod_tables
Treatment Record   entity3   reqPerson's mailing address   descPerson's Address   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1102)   
M   usage    y
   mod_tables
Patient   entity3   req   HA sequence that provides reference to a Patient SOP Class/Instance pair.1Only a single Item is permitted in this Sequence.   descReferenced Patient Sequence   name
Patient   module   (0008,1120)   
M   usage   �
   mod_tables
Treatment Record   entity3   req   &The purpose of this Digital Signature.1Only a single Item is permitted in this sequence.   desc'Digital Signature Purpose Code Sequence   name

SOP Common   module   (fffa,fffa)[<0>](0400,0401)   
U   usage   	
   mod_tables
Treatment Record   entity3   reqJUser-defined description of Dose Reference (e.g., "Exit dose", "Point A").   descMeasured Dose Description   name
Measured Dose Reference Record   module   (3008,0010)[<0>](3008,0012)   
M   usage   I
   mod_tables
Series   entity1C   req   MNumeric value for this name-value Item. Only a single value shall be present..Required if Value Type (0040,A040) is NUMERIC.   descNumeric Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a30a)   
U   usage   	
   mod_tables
Treatment Record   entity1C   req�Unique identifier of measured dose point. Required only if Referenced Dose Reference Number (300C,0051) is not sent. It shall not be present otherwise.   descMeasured Dose Reference Number   name
Measured Dose Reference Record   module   (3008,0010)[<0>](3008,0064)   
M   usage   
   mod_tables
Treatment Record   entity1   req   BSequence describing treatment machine used for treatment delivery.6Only a single Item shall be included in this Sequence.   descTreatment Machine Sequence   name
RT Treatment Machine Record   module   (300a,0206)   
M   usage    �
   mod_tables
Series   entity1C   req   +Person name value for this name-value Item.,Required if Value Type (0040,A040) is PNAME.   descPerson Name   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a123)   
M   usage   
   mod_tables
Series   entity1C   req   �The integer numerator of a rational representation of Numeric Value (0040,A30A). Encoded as a signed integer value. The same number of values as Numeric Value (0040,A30A) shall be present.�Required if Numeric Value (0040,A30A) has insufficient precision to represent a rational value as a string. May be present otherwise.   descRational Numerator Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a162)   
M   usage   	�
   mod_tables
Treatment Record   entity2   req�Time when current fraction was delivered (begun), or Time last fraction was delivered (begun) in case of RT Treatment Summary Record IOD. See Note.   descTreatment Time   name
RT General Treatment Record   module   (3008,0251)   
M   usage    �
   mod_tables
Treatment Record   entity1   reqBContains the Data Element Tag of the attribute that was corrected.   descParameter Pointer   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0068)[<2>](3008,0065)   
M   usage   �
   mod_tables
Patient   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
Patient   module;   (0010,1002)[<0>](0010,0024)[<1>](0040,0036)[<2>](0040,0032)   
U   usage   
   mod_tables
Study   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   Enumerated Values:   title
variablelist   type      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
Patient Study   module   (0038,0064)[<0>](0040,0033)   
U   usage   K
   mod_tables
Study   entity3   req2Description of the admitting diagnosis (diagnoses)   descAdmitting Diagnoses Description   name
Patient Study   module   (0008,1080)   
U   usage    n
   mod_tables
Treatment Record   entity3   req$Comment on current treatment status.   descTreatment Status Comment   name
RT Treatment Summary Record   module   (3008,0202)   
M   usage    y
   mod_tables
Patient   entity2   req?Primary hospital identification number or code for the patient.   desc
Patient ID   name
Patient   module   (0010,0020)   
M   usage    �
   mod_tables
Treatment Record   entity3   req�Uniquely identifies Ion Tolerance Table specified by Tolerance Table Number (300A,0042) within Ion Tolerance Table Sequence in RT Ion Tolerance Tables Module. These tolerances are to be used for verification of treatment machine settings.   desc!Referenced Tolerance Table Number   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300c,00a0)   
U   usage    n
   mod_tables
Treatment Record   entity2   req4Number of fractions planned for this fraction group.   descNumber of Fractions Planned   name
RT Treatment Summary Record   module   (3008,0220)[<0>](300a,0078)   
M   usage   �
   mod_tables
Series   entity3   req   GIdentifier of the Assigning Authority that issued the Accession Number.1Only a single Item is permitted in this sequence.   desc#Issuer of Accession Number Sequence   name
	RT Series   module   (0040,0275)[<0>](0008,0051)   
M   usage   
   mod_tables
Study   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
General Study   module   (0008,0051)[<0>](0040,0031)   
U   usage   �
   mod_tables
Treatment Record   entity1   reqDUnique identifier of the Series containing the referenced Instances.   descSeries Instance UID   name
Common Instance Reference   module   (0008,1115)[<0>](0020,000e)   
M   usage   
   mod_tables
Patient   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
Patient   module+   (0010,0024)[<0>](0040,0036)[<1>](0040,0032)   
M   usage   �
   mod_tables
Treatment Record   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300c,0040)[<1>](0008,1155)   
U   usage    M
   mod_tables
Treatment Record   entity3   req   @Sequence of devices used for patient alignment in Patient Setup.1One or more items are permitted in this sequence.   descSetup Device Sequence   name
RT Patient Setup   module   (300a,0180)[<0>](300a,01b4)   
M   usage   
   mod_tables
Series   entity1C   req   $Text value for this name-value Item.+Required if Value Type (0040,A040) is TEXT.   desc
Text Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a160)   
U   usage   	
   mod_tables
Treatment Record   entity2   req;Measured Dose in units specified by Dose Units (3004,0002).   descMeasured Dose Value   name
Measured Dose Reference Record   module   (3008,0010)[<0>](3008,0016)   
M   usage   S
   mod_tables
Series   entity3   reqTime the Series started.   descSeries Time   name
	RT Series   module   (0008,0031)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqTreatment Time set (sec).   descSpecified Treatment Time   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,003a)   
M   usage   
   mod_tables
Series   entity1C   req   #UID value for this name-value Item.-Required if Value Type (0040,A040) is UIDREF.   descUID   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a124)   
M   usage    y
   mod_tables
Patient   entity2   reqPatient's full name.   descPatient's Name   name
Patient   module   (0010,0010)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqeAddress of the institution where the equipment that contributed to the composite instance is located.   descInstitution Address   name

SOP Common   module   (0018,a001)[<0>](0008,0081)   
M   usage   �
   mod_tables
Treatment Record   entity1   reqsA number used to identify which MAC Parameters Sequence item was used in the calculation of this Digital Signature.   descMAC ID Number   name

SOP Common   module   (fffa,fffa)[<0>](0400,0005)   
M   usage    �
   mod_tables
Treatment Record   entity1   req.User or machine supplied identifier for Snout.   descSnout ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f0)[<1>](300a,030f)   
M   usage   �
   mod_tables
Series   entity1C   req   �The integer denominator of a rational representation of Numeric Value (0040,A30A). Encoded as a non-zero unsigned integer value. The same number of values as Numeric Value (0040,A30A) shall be present.<Required if Rational Numerator Value (0040,A162) is present.   descRational Denominator Value   name
	RT Series   moduleK   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,0441)[<3>](0040,a163)   
M   usage   �
   mod_tables
Series   entity1C   req   8Identifier that identifies the Scheduled Procedure Step.$Required if procedure was scheduled.      
                      ?  The condition is to allow the contents of this macro to be present (e.g., to convey the reason for the procedure, such as whether a mammogram is for screening or diagnostic purposes) even when the procedure step was not formally scheduled and a value for this identifier is unknown, rather than making up a dummy value.   contentpara   el
                 contentnote   el   descScheduled Procedure Step ID   name
	RT Series   module   (0040,0275)[<0>](0040,0009)   
M   usage    �
   mod_tables
Treatment Record   entity2C   req   �Table Top Pitch Angle, i.e., the rotation of the IEC TABLE TOP coordinate system about the X-axis of the IEC TABLE TOP coordinate system (degrees). Required for first item of Control Point Sequence, or if Table Top Pitch Angle changes during Beam. See        select: label	   xrefstylesect_C.8.8.25.6.2   linkend   attrsxref   el.   descTable Top Pitch Angle   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0140)   
M   usage   V
   mod_tables
Treatment Record   entity1   reqZThe value of a Coding Scheme Designator, used in this SOP Instance, which is being mapped.   descCoding Scheme Designator   name

SOP Common   module   (0008,0110)[<0>](0008,0102)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   KDate and time that the SOP Instance was last coerced by a Storage SCP (see        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el).   descInstance Coercion DateTime   name

SOP Common   module   (0008,0015)   
M   usage    �
   mod_tables
Series   entity1C   req   MNumeric value for this name-value Item. Only a single value shall be present..Required if Value Type (0040,A040) is NUMERIC.   descNumeric Value   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a30a)   
M   usage   I
   mod_tables
Series   entity1C   req   #UID value for this name-value Item.-Required if Value Type (0040,A040) is UIDREF.   descUID   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a124)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Contains the Data Element Tag of the parent sequence containing the attribute that was overriden. The value is limited in scope to the Treatment Session Ion Beam Sequence (3008,0021) and all nested sequences therein.   descParameter Sequence Pointer   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](3008,0060)[<2>](3008,0061)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f2)[<1>](300a,00f9)   
M   usage   S
   mod_tables
Series   entity1   req   4Type of equipment that originally acquired the data.   
variablelist   typeEnumerated Values:   title      RTIMAGERT Image   RTDOSERT Dose   RTSTRUCTRT Structure Set   RTPLANRT Plan   RTRECORDRT Treatment Record   list   See        select: label	   xrefstylesect_C.8.8.1.1   linkend   attrsxref   el.   descModality   name
	RT Series   module   (0008,0060)   
M   usage    �
   mod_tables
Treatment Record   entity1   req8Number of range modulators associated with current beam.   descNumber of Range Modulators   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0340)   
M   usage    
   mod_tables
Patient   entity3   req   AType of Patient ID. Refer to HL7 v2 Table 0203 for Defined Terms.      
                      ;Equivalent to HL7 v2 CX component 5 (Identifier Type Code).   contentpara   el
                 contentnote   el   descIdentifier Type Code   name
Patient   module   (0010,0024)[<0>](0040,0035)   
M   usage    �
   mod_tables
Series   entity1C   req   (DateTime value for this name-value Item./Required if Value Type (0040,A040) is DATETIME.   descDateTime   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a120)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�User-supplied identifier for the beam current modulation pattern. Required if Range Modulator Type (300A,0348) is WHL_MODWEIGHTS   descBeam Current Modulation ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f6)[<1>](300a,034c)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   @Identification of the operator(s) of the contributing equipment.1One or more items are permitted in this sequence.|The number and order of Items shall correspond to the number and order of values of Operators' Name (0008,1070), if present.   desc Operator Identification Sequence   name

SOP Common   module   (0018,a001)[<0>](0008,1072)   
M   usage    �
   mod_tables
Study   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name
General Study   module   (0008,1049)[<0>](0040,1103)   
M   usage    �
   mod_tables
Study   entity2   req)Name of the patient's referring physician   descReferring Physician's Name   name
General Study   module   (0008,0090)   
U   usage    n
   mod_tables
Treatment Record   entity2   req=Number of fractions delivered as of Treatment Summary Report.   descNumber of Fractions Delivered   name
RT Treatment Summary Record   module   (3008,0220)[<0>](3008,005a)   
M   usage    �
   mod_tables
Treatment Record   entity3   req/User supplied description of General Accessory.   descGeneral Accessory Description   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0420)[<1>](300a,0422)   
M   usage   I
   mod_tables
Series   entity1C   req   $Date value for this name-value Item.+Required if Value Type (0040,A040) is DATE.   descDate   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a121)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqIThe date and time when the SOP Instance Status (0100,0410) was set to AO.   descSOP Authorization DateTime   name

SOP Common   module   (0100,0420)   
M   usage    �
   mod_tables
Treatment Record   entity1   req:User or machine supplied identifier for General Accessory.   descGeneral Accessory ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0420)[<1>](300a,0421)   
M   usage   I
   mod_tables
Series   entity1C   req   $Time value for this name-value Item.+Required if Value Type (0040,A040) is TIME.   descTime   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a122)   
M   usage    �
   mod_tables
Treatment Record   entity1   reqAUser or machine supplied identifier for Lateral Spreading Device.   descLateral Spreading Device ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f4)[<1>](300a,0336)   
M   usage    y
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
U   usage    n
   mod_tables
Treatment Record   entity1   req   FStatus of the Treatment at the time the Treatment Summary was created.   
variablelist   typeEnumerated Values:   title      NOT_STARTED   ON_TREATMENT   ON_BREAK   	SUSPENDED   STOPPED   	COMPLETED   list   See        select: label	   xrefstylesect_C.8.8.23.1   linkend   attrsxref   el.   descCurrent Treatment Status   name
RT Treatment Summary Record   module   (3008,0200)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   Sequence of treatment wedges.5Required if Number of Wedges (300A,00D0) is non-zero.5One or more items shall be included in this sequence.TThe number of items shall be identical to the value of Number of Wedges (300A,00D0).   descRecorded Wedge Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,00b0)   
U   usage   H
   mod_tables
Study   entity1C   req�Universal or unique identifier for an entity. Required if Local Namespace Entity ID (0040,0031) is not present; may be present otherwise.   descUniversal Entity ID   name
Patient Study   module   (0038,0014)[<0>](0040,0032)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   0Conditions under which treatment was terminated.   
variablelist   typeEnumerated Values:   title      NORMALtreatment terminated normally   OPERATORoperator terminated treatment   MACHINEmachine terminated treatment   UNKNOWNstatus at termination unknown   list   descTreatment Termination Status   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,002a)   
U   usage   
   mod_tables
Series   entity3   req   DA description of the series in the context of a clinical trial. See        select: label	   xrefstylesect_C.7.3.2.1.2   linkend   attrsxref   el.   desc!Clinical Trial Series Description   name
Clinical Trial Series   module   (0012,0072)   
M   usage   >
   mod_tables
Series   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
	RT Series   module+   (0040,0275)[<0>](0008,1110)[<1>](0008,1155)   
M   usage   �
   mod_tables
Patient   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
Patient   module;   (0010,1002)[<0>](0010,0024)[<1>](0040,0036)[<2>](0040,0031)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   ?Sequence of Range Modulator Settings for current control point.5One or more items shall be included in this sequence.�Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041), or if Range Modulator Settings change during beam administration, and Number of Range Modulators (300A,0340) is non-zero.   desc!Range Modulator Settings Sequence   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0380)   
U   usage    n
   mod_tables
Treatment Record   entity2   req(Date of delivery of the first treatment.   descFirst Treatment Date   name
RT Treatment Summary Record   module   (3008,0054)   
M   usage    �
   mod_tables
Treatment Record   entity1   req^Uniquely references Wedge described by Wedge Number (300A,00D2) in Wedge Sequence (300A,00D1).   descReferenced Wedge Number   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,03ac)[<2>](300c,00c0)   
U   usage    M
   mod_tables
Treatment Record   entity1C   reqqUser-defined additional description of patient position. Required if Patient Position (0018,5100) is not present.   descPatient Additional Position   name
RT Patient Setup   module   (300a,0180)[<0>](300a,0184)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00b0)[<1>](300a,00f9)   
M   usage    �
   mod_tables
Treatment Record   entity1   req:Number of range compensators associated with current Beam.   descNumber of Compensators   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,00e0)   
M   usage   [
   mod_tables
	Equipment   entity3   req   rTime when the image acquisition device calibration was last changed in any way. Multiple entries may be used. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descTime of Last Calibration   name
General Equipment   module   (0018,1201)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f0)[<1>](300a,00f9)   
M   usage   
   mod_tables
Series   entity1C   req   $Time value for this name-value Item.+Required if Value Type (0040,A040) is TIME.   descTime   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a122)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�Uniquely identifies Calculated Dose Reference specified by Calculated Dose Reference Number (3008,0072) within Calculated Dose Reference Sequence (3008,0070). Required if Referenced Dose Reference Number (300C,0051) is not sent.   desc+Referenced Calculated Dose Reference Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0090)[<1>](3008,0092)   
M   usage    �
   mod_tables
Treatment Record   entity1   req^Identification Number of the General Accessory. The value shall be unique within the sequence.   descGeneral Accessory Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0420)[<1>](300a,0424)   
U   usage    M
   mod_tables
Treatment Record   entity3   req   =Sequence of setup verification images for this patient setup.1One or more items are permitted in this sequence.   See        select: label	   xrefstylesect_C.8.8.12.1.1   linkend   attrsxref   el   descReferenced Setup Image Sequence   name
RT Patient Setup   module   (300a,0180)[<0>](300a,0401)   
M   usage    �
   mod_tables
Treatment Record   entity3   req;Identifier of fraction group within referenced RT Ion Plan.   desc Referenced Fraction Group Number   name
RT Ion Beams Session Record   module   (300c,0022)   
M   usage    �
   mod_tables
Treatment Record   entity1   req|Uniquely references Range Modulator described by Range Modulator Number (300A,0344) in Range Modulator Sequence (300A,0342).   desc!Referenced Range Modulator Number   name
RT Ion Beams Session Record   module;   (3008,0021)[<0>](3008,0041)[<1>](300a,0380)[<2>](300c,0104)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Uniquely identifies lateral spreading device specified by Lateral Spreading Device Number (300A,0334) within Beam referenced by Referenced Beam Number (300C,0006).   desc*Referenced Lateral Spreading Device Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f4)[<1>](300c,0102)   
M   usage    �
   mod_tables
Treatment Record   entity1   req8User or machine supplied identifier for Range Modulator.   descRange Shifter ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,00f2)[<1>](300a,0318)   
U   usage   �
   mod_tables
Patient   entity2   req   EName of the site responsible for submitting clinical trial data. See        select: label	   xrefstylesect_C.7.1.3.1.5   linkend   attrsxref   el   descClinical Trial Site Name   name
Clinical Trial Subject   module   (0012,0031)   
M   usage   [
   mod_tables
	Equipment   entity3   req�The inherent limiting resolution in mm of the acquisition equipment for high contrast objects for the data gathering and reconstruction technique chosen. If variable across the images of the series, the value at the image center.   descSpatial Resolution   name
General Equipment   module   (0018,1050)   
M   usage    �
   mod_tables
Treatment Record   entity1   req�Date when the delivery of radiation at this control point began. For the final control point this shall be the Date when the previous control point ended.   descTreatment Control Point Date   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0024)   
M   usage   �
   mod_tables
Series   entity3   req%Reason for requesting this procedure.   desc"Reason for the Requested Procedure   name
	RT Series   module   (0040,0275)[<0>](0040,1002)   
M   usage   �
   mod_tables
Treatment Record   entity3   reqXA Patient Support accessory identifier to be read by a device such as a bar code reader.   descPatient Support Accessory Code   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0354)   
M   usage   V
   mod_tables
Treatment Record   entity2   req�The source that provided the SOP Instance prior to the removal or replacement of the values. For example, this might be the Institution from which imported SOP Instances were received.   descSource of Previous Values   name

SOP Common   module   (0400,0561)[<0>](0400,0564)   
M   usage   
   mod_tables
Series   entity1C   req   (DateTime value for this name-value Item./Required if Value Type (0040,A040) is DATETIME.   descDateTime   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a120)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�Uniquely references Dose Reference specified by Dose Reference Number (300A,0012) in Dose Reference Sequence (300A,0010) in RT Prescription Module of referenced RT Ion Plan. Required if Referenced Measured Dose Reference Number (3008,0082) is not sent.   desc Referenced Dose Reference Number   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0080)[<1>](300c,0051)   
M   usage   �
   mod_tables
Series   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
	RT Series   module   (0008,1111)[<0>](0008,1150)   
M   usage   �
   mod_tables
Series   entity3   req1Date on which the Performed Procedure Step ended.   desc!Performed Procedure Step End Date   name
	RT Series   module   (0040,0250)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqhDepartment in the institution where the equipment that contributed to the composite instance is located.   descInstitutional Department Name   name

SOP Common   module   (0018,a001)[<0>](0008,1040)   
M   usage   V
   mod_tables
Treatment Record   entity1   reqIIdentification of the system that removed and/or replaced the attributes.   descModifying System   name

SOP Common   module   (0400,0561)[<0>](0400,0563)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�User-supplied or machine code identifier for machine configuration to produce beam spot. This may be the nominal spot size or some other machine specific value. Required if Scan Mode (300A,0308) is MODULATED.   descScan Spot Tune ID   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](300a,0390)   
M   usage    y
   mod_tables
Patient   entity1   req   FIdentification of the organization with which an animal is registered.6Only a single Item shall be included in this sequence.   descBreed Registry Code Sequence   name
Patient   module   (0010,2294)[<0>](0010,2296)   
M   usage    �
   mod_tables
Series   entity1   req   +Coded concept name of this name-value Item.6Only a single Item shall be included in this Sequence.   descConcept Name Code Sequence   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0040,a043)   
M   usage   �
   mod_tables
Series   entity3   req3Date on which the Performed Procedure Step started.   desc#Performed Procedure Step Start Date   name
	RT Series   module   (0040,0244)   
M   usage    �
   mod_tables
Series   entity1C   req   @Composite SOP Instance Reference value for this name-value Item.6Only a single Item shall be included in this Sequence.9Required if Value Type (0040,A040) is COMPOSITE or IMAGE.   descReferenced SOP Sequence   name
	RT Series   module;   (0040,0275)[<0>](0040,0008)[<1>](0040,0440)[<2>](0008,1199)   
U   usage   H
   mod_tables
Study   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
Patient Study   module   (0038,0014)[<0>](0040,0031)   
M   usage   V
   mod_tables
Treatment Record   entity1   reqIManufacturer of the equipment that contributed to the composite instance.   descManufacturer   name

SOP Common   module   (0018,a001)[<0>](0008,0070)   
M   usage   
   mod_tables
Study   entity1C   req   pStandard defining the format of the Universal Entity ID. Required if Universal Entity ID (0040,0032) is present.   Enumerated Values:   title
variablelist   type      DNS7An Internet dotted name. Either in ASCII or as integers   EUI64"An IEEE Extended Unique Identifier   ISO9An International Standards Organization Object Identifier   URIUniform Resource Identifier   UUID#The DCE Universal Unique Identifier   X400An X.400 MHS identifier   X500An X.500 directory name   list   descUniversal Entity ID Type   name
General Study   module   (0008,0051)[<0>](0040,0033)   
U   usage    M
   mod_tables
Treatment Record   entity3   req-The user-defined label for the patient setup.   descPatient Setup Label   name
RT Patient Setup   module   (300a,0180)[<0>](300a,0183)   
M   usage   I
   mod_tables
Series   entity1C   req   �The integer denominator of a rational representation of Numeric Value (0040,A30A). Encoded as a non-zero unsigned integer value. The same number of values as Numeric Value (0040,A30A) shall be present.<Required if Rational Numerator Value (0040,A162) is present.   descRational Denominator Value   name
	RT Series   module+   (0040,0260)[<0>](0040,0440)[<1>](0040,a163)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   3Desired machine setting of secondary Meterset. See        select: label	   xrefstylesect_C.8.8.26.1   linkend   attrsxref   el.   descSpecified Secondary Meterset   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,0033)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   2Sequence of range modulators associated with Beam.?Required if Number of Range Modulators (300A,0340) is non-zero.5One or more items shall be included in this sequence.^The number of items shall be identical to the value of Number of Range Modulators (300A,0340).   desc!Recorded Range Modulator Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,00f6)   
M   usage   
   mod_tables
Series   entity1C   req   �The floating point representation of Numeric Value (0040,A30A). The same number of values as Numeric Value (0040,A30A) shall be present.~Required if Numeric Value (0040,A30A) has insufficient precision to represent the value as a string. May be present otherwise.   descFloating Point Value   name
	RT Series   module;   (0040,0260)[<0>](0040,0440)[<1>](0040,0441)[<2>](0040,a161)   
M   usage   �
   mod_tables
Series   entity3   req�Sequence describing the Scheduled Protocol following a specific coding scheme. One or more Items are permitted in this sequence.   desc Scheduled Protocol Code Sequence   name
	RT Series   module   (0040,0275)[<0>](0040,0008)   
M   usage    
   mod_tables
Patient   entity1C   req   |Standard defining the format of the Universal Entity ID (0040,0032). Required if Universal Entity ID (0040,0032) is present.      
                      GEquivalent to HL7 v2 CX component 4 subcomponent 3 (Universal ID Type).   contentpara   el
                 contentnote   el   See        select: label	   xrefstyle
sect_10.14   linkend   attrsxref   el for Defined Terms.   descUniversal Entity ID Type   name
Patient   module   (0010,0024)[<0>](0040,0033)   
U   usage   	
   mod_tables
Treatment Record   entity1   req   QSequence of doses measured during treatment delivery, summed over entire session.5One or more Items shall be included in this sequence.   desc Measured Dose Reference Sequence   name
Measured Dose Reference Record   module   (3008,0010)   
M   usage   
   mod_tables
Patient   entity1C   req�Identifies an entity within the local namespace or domain. Required if Universal Entity ID (0040,0032) is not present; may be present otherwise.   descLocal Namespace Entity ID   name
Patient   module+   (0010,0024)[<0>](0040,0036)[<1>](0040,0031)   
M   usage    �
   mod_tables
Treatment Record   entity3   reqIAn accessory identifier to be read by a device such as a bar code reader.   descAccessory Code   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](300a,0107)[<1>](300a,00f9)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req�Peak kilo voltage output of the setup X-Ray generator used. Required for Control Point 0 of Ion Control Point Delivery Sequence (3008,0041), or if kVp changes during setup, and Nominal Beam Energy (300A,0114) is not present.   descKVP   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](0018,0060)   
M   usage   V
   mod_tables
Treatment Record   entity1C   req   ,  Sequence of items defining mapping between HL7 Instance Identifiers of unencapsulated HL7 Structured Documents referenced from the current SOP Instance as if they were DICOM Composite SOP Class Instances defined by SOP Class and Instance UID pairs. May also define a means of accessing the Documents.5One or more Items shall be included in this sequence.   See        select: label	   xrefstylesect_C.12.1.1.6   linkend   attrsxref   el.�Required if unencapsulated HL7 Structured Documents are referenced within the Instance. Every such document so referenced is required to have a corresponding Item in this Sequence.   desc*HL7 Structured Document Reference Sequence   name

SOP Common   module   (0040,a390)   
M   usage   V
   mod_tables
Treatment Record   entity3   reqVAny comments associated with the setting of the SOP Instance Status (0100,0410) to AO.   descSOP Authorization Comment   name

SOP Common   module   (0100,0424)   
M   usage   �
   mod_tables
Series   entity3   reqnUser or equipment generated identifier of that part of a Procedure that has been carried out within this step.   descPerformed Procedure Step ID   name
	RT Series   module   (0040,0253)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   {Azimuthal angle (degrees) of the fixation light coordinate around IEC PATIENT SUPPORT Y-axis. Used for eye treatments. See        select: label	   xrefstylesect_C.8.8.25.6.4   linkend   attrsxref   el.   descFixation Light Azimuthal Angle   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0356)   
U   usage    M
   mod_tables
Treatment Record   entity1   req   5Type of Fixation Device used during in Patient Setup.   
variablelist   typeDefined Terms:   title      	BITEBLOCK   	HEADFRAME   MASK   MOLD   CAST   HEADREST   BREAST_BOARD   
BODY_FRAME   VACUUM_MOLD   WHOLE_BODY_POD   RECTAL_BALLOON   list   descFixation Device Type   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,0190)[<1>](300a,0192)   
M   usage    �
   mod_tables
Treatment Record   entity1   req   2The method of beam scanning used during treatment.   
variablelist   typeDefined Terms:   title      NONENo beam scanning is performed.   UNIFORMmThe beam is scanned between control points to create a uniform lateral fluence distribution across the field.   	MODULATEDoThe beam is scanned between control points to create a modulated lateral fluence distribution across the field.   list   desc	Scan Mode   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](300a,0308)   
M   usage   V
   mod_tables
Treatment Record   entity1   req�Transfer Syntax used to encode the encrypted content. Only Transfer Syntaxes that explicitly include the VR and use Little Endian encoding shall be used.   desc%Encrypted Content Transfer Syntax UID   name

SOP Common   module   (0400,0500)[<0>](0400,0510)   
M   usage   V
   mod_tables
Treatment Record   entity3   req   tManufacturer's designation of the software version of the equipment that contributed to the composite instance. See        select: label	   xrefstylesect_C.7.5.1.1.3   linkend   attrsxref   el.   descSoftware Versions   name

SOP Common   module   (0018,a001)[<0>](0018,1020)   
M   usage   V
   mod_tables
Treatment Record   entity1   req   'Uniquely identifies the SOP Class. See        select: label	   xrefstylesect_C.12.1.1.1   linkend   attrsxref   el# for further explanation. See also        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descSOP Class UID   name

SOP Common   module   (0008,0016)   
M   usage    �
   mod_tables
Study   entity3   req,Names of the physician(s) reading the Study.   desc"Name of Physician(s) Reading Study   name
General Study   module   (0008,1060)   
M   usage    �
   mod_tables
Treatment Record   entity2   reqJTotal number of treatments (fractions) planned for current fraction group.   descNumber of Fractions Planned   name
RT Ion Beams Session Record   module   (300a,0078)   
U   usage   �
   mod_tables
Treatment Record   entity1C   req   FSequence of Items each of which includes the Attributes of one Series.5One or more Items shall be included in this sequence.=Required if this Instance references Instances in this Study.   descReferenced Series Sequence   name
Common Instance Reference   module   (0008,1115)   
U   usage    M
   mod_tables
Treatment Record   entity1   req   /Type of Shielding Device used in Patient Setup.   
variablelist   typeDefined Terms:   title      GUM   EYE   GONAD   list   descShielding Device Type   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01a0)[<1>](300a,01a2)   
M   usage    �
   mod_tables
Study   entity3   req   aIdentification of the physician(s) who are responsible for overall patient care at time of Study.�One or more items are permitted in this sequence. If more than one Item, the number and order shall correspond to the value of Physician(s) of Record (0008,1048), if present.   desc.Physician(s) of Record Identification Sequence   name
General Study   module   (0008,1049)   
M   usage    y
   mod_tables
Patient   entity1C   req   The species of the patient.Required if the patient is an animal and if Patient Species Code Sequence (0010,2202) is not present. May be present otherwise.   descPatient Species Description   name
Patient   module   (0010,2201)   
U   usage    n
   mod_tables
Treatment Record   entity3   req   KSequence describing current state of planned vs. delivered fraction groups.1One or more Items are permitted in this sequence.   descFraction Group Summary Sequence   name
RT Treatment Summary Record   module   (3008,0220)   
U   usage    M
   mod_tables
Treatment Record   entity3   reqEUser-defined description for Setup Device used for patient alignment.   descSetup Device Description   name
RT Patient Setup   module+   (300a,0180)[<0>](300a,01b4)[<1>](300a,01ba)   
U   usage    M
   mod_tables
Treatment Record   entity3   req   3Sequence of Fixation Devices used in Patient Setup.1One or more items are permitted in this sequence.   descFixation Device Sequence   name
RT Patient Setup   module   (300a,0180)[<0>](300a,0190)   
M   usage    �
   mod_tables
Treatment Record   entity1C   req   #Sequence of treatment compensators.;Required if Number of Compensators (300A,00E0) is non-zero.5One or more items shall be included in this sequence.ZThe number of items shall be identical to the value of Number of Compensators (300A,00E0).   descRecorded Compensator Sequence   name
RT Ion Beams Session Record   module   (3008,0021)[<0>](3008,00c0)   
M   usage    �
   mod_tables
Treatment Record   entity3   req   �Sequence of parameters that were overridden during the administration of the beam segment immediately prior to the current control point.1One or more Items are permitted in this sequence.   descOverride Sequence   name
RT Ion Beams Session Record   module+   (3008,0021)[<0>](3008,0041)[<1>](3008,0060)   
M   usage   �
   mod_tables
Treatment Record   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
RT General Treatment Record   module   (300c,0002)[<0>](0008,1150)   tags