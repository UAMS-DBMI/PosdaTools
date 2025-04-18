pst012345678      @Can't handle table_8.8-1 (in table_C.29.1.1-1 after (0008,2218))@Can't handle table_8.8-1 (in table_C.29.1.1-1 after (0068,62A0))@Can't handle table_8.8-1 (in table_C.29.1.1-1 after (0068,63A0))@Can't handle table_8.8-1 (in table_C.29.1.1-1 after (0068,63A4))@Can't handle table_8.8-1 (in table_C.29.1.1-1 after (0068,63A8))@Can't handle table_8.8-1 (in table_C.29.1.1-1 after (0068,63AC))@Can't handle table_8.8-1 (in table_C.29.1.2-1 after (0068,62E0))@Can't handle table_8.8-1 (in table_C.29.1.2-1 after (0068,62F0))@Can't handle table_8.8-1 (in table_C.29.1.5-1 after (0068,6545))@Can't handle table_8.8-1 (in table_C.29.1.5-1 after (0068,6545))@Can't handle table_8.8-1 (in table_C.29.1.5-1 after (0068,6545))<Can't handle table_8.8-1 (in table_C.12-1 after (0040,A170))GCan't handle table_8.8-1 (in table_C.12-1:table_10-1 after (0040,1101))GCan't handle table_8.8-1 (in table_C.12-1:table_10-1 after (0008,0082))ICan't handle table_8.8-1 (in table_C.12-1:table_C.12-6 after (0400,0401))HCan't handle table_8.8-1 (in table_C.27-1:table_10-19 after (0066,002F))HCan't handle table_8.8-1 (in table_C.27-1:table_10-19 after (0066,0030))   errors �      
EC - Required if Generic Implant Template 3D Models Module is present.   usage   
table_C.27-1table_C.27-3
   mod_tables
Surface Mesh   entity1   req   EThe number of vectors in the Vector Coordinate Data (0066,0021). See        select: label	   xrefstylesect_C.27.3.1   linkend   attrsxref   el.   descNumber of Vectors   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0012)[<1>](0066,001e)   
M   usage   
table_C.29.1.1-1table_10-11
   mod_tables
Implant Template   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
$Generic Implant Template Description   module   (0068,6222)[<0>](0008,1150)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage   
table_C.27-1
   mod_tables
Surface Mesh   entity1   req   uIndicates whether the surface is describing an n-1 dimensional manifold in the underlying n-dimensional vector space.   
variablelist   typeEnumerated Values:   title      YESManifold in every point   NO Does contain non-manifold points   UNKNOWN.Might or might not contain non-manifold points   list   See        select: label	   xrefstylesect_C.27.1.1.5   linkend   attrsxref   el.   descManifold   name
Surface Mesh   module   (0066,0002)[<0>](0066,0010)   
U   usage   
table_C.29.1.4-1
   mod_tables
Implant Template   entity1   req   dIdentification number of the set. Uniquely identifies a mating feature set within this SOP instance.JThe value shall start at 1, and increase monotonically by 1 for each Item.   descMating Feature Set ID   name
(Generic Implant Template Mating Features   module   (0068,63b0)[<0>](0068,63c0)   
U   usage   
table_C.29.1.2-1
   mod_tables
Implant Template   entity3   req:Description of the kind of information drawn with the pen.   descHPGL Pen Description   name
$Generic Implant Template 2D Drawings   module+   (0068,62c0)[<0>](0068,6320)[<1>](0068,6345)   
U   usage   
table_C.29.1.5-1
   mod_tables
Implant Template   entity1   req   eNumeric ID of the planning landmark. Uniquely identifies a planning landmark within the SOP instance.JThe value shall start at 1, and increase monotonically by 1 for each Item.   descPlanning Landmark ID   name
+Generic Implant Template Planning Landmarks   module   (0068,6500)[<0>](0068,6530)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage   
table_C.27-1table_C.27-4
   mod_tables
Surface Mesh   entity2   req   ;Contains 3n point indices describing unconnected Triangles.   See        select: label	   xrefstylesect_C.27.4.1   linkend   attrsxref   el.   descTriangle Point Index List   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0013)[<1>](0066,0023)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage   
table_C.27-1table_10-19
   mod_tables
Surface Mesh   entity3   reqgThe input parameters used by a manufacturer to configure the behavior of a specific software algorithm.   descAlgorithm Parameters   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0035)[<1>](0066,0032)   
U   usage    f
   mod_tables
Implant Template   entity1   req   �Value of the HPGL Document ID (0068,62D0) present in the HPGL Document Sequence (0068,62C0) that contains the 2D Drawing including the Mating Feature.   See        select: label	   xrefstylesect_C.29.1.4.1.2   linkend   attrsxref   el.$Shall be unique within the sequence.   descReferenced HPGL Document ID   name
(Generic Implant Template Mating Features   moduleK   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)[<2>](0068,6470)[<3>](0068,6440)   
M   usage   
table_C.29.1.1-1
   mod_tables
Implant Template   entity1C   req   �Information from the manufacturer concerning a critical notification, recall, or discontinuation of the implant or implant template.5One or more Items shall be included in this sequence.-Required if such information has been issued.   desc'Notification From Manufacturer Sequence   name
$Generic Implant Template Description   module   (0068,6265)   
U   usage    f
   mod_tables
Implant Template   entity3   req   *Degrees of freedom in this mating feature.1One or more Items are permitted in this sequence.   See        select: label	   xrefstylesect_C.29.1.4.1.2   linkend   attrsxref   el.   desc)Mating Feature Degree of Freedom Sequence   name
(Generic Implant Template Mating Features   module+   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage   
table_C.27-1table_C.27-2
   mod_tables
Surface Mesh   entity3   reqvTwo 3D locations defining the cuboid bounding box, parallel to the coordinate system axes, encompassing the point set.   descPoints Bounding Box Coordinates   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0011)[<1>](0066,001a)   
M   usage   
table_C.12-1table_C.12-6
   mod_tables
Implant Template   entity1   req   "The MAC generated as described in        select: label	   xrefstylesect_C.12.1.1.3.1.1   linkend   attrsxref   el and encrypted using the algorithm, parameters, and private key associated with the Certificate of the Signer (0400,0115). See        select: label	   xrefstylesect_C.12.1.1.3.1.2   linkend   attrsxref   el.   desc	Signature   name

SOP Common   module   (fffa,fffa)[<0>](0400,0120)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   req   See        select: label	   xrefstylesect_C.27.4.1   linkend   attrsxref   el.   descPrimitive Point Index List   name
Surface Mesh   module;   (0066,0002)[<0>](0066,0013)[<1>](0066,0034)[<2>](0066,0029)   
M   usage   
table_C.12-1
   mod_tables
Implant Template   entity3   reqYManufacturer's serial number of the equipment that contributed to the composite instance.   descDevice Serial Number   name

SOP Common   module   (0018,a001)[<0>](0018,1000)   
U   usage    f
   mod_tables
Implant Template   entity1   reqaNumeric ID of the mating feature. Uniquely identifies a mating feature within this Sequence Item.   descMating Feature ID   name
(Generic Implant Template Mating Features   module+   (0068,63b0)[<0>](0068,63e0)[<1>](0068,63f0)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req6Only a single item shall be included in this sequence.   desc Surface Mesh Primitives Sequence   name
Surface Mesh   module   (0066,0002)[<0>](0066,0013)   
M   usage    �
   mod_tables
Implant Template   entity1   req   ,The type of certificate used in (0400,0115).   Defined Terms:   title
variablelist   type      X509_1993_SIG   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descCertificate Type   name

SOP Common   module   (fffa,fffa)[<0>](0400,0110)   
U   usage    f
   mod_tables
Implant Template   entity1   req   2Origin of the contact system, in HPGL coordinates.   See        select: label	   xrefstylesect_C.29.1.4.1.1   linkend   attrsxref   el   desc2D Mating Point   name
(Generic Implant Template Mating Features   module;   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6430)[<2>](0068,6450)   
M   usage   ,
   mod_tables
Implant Template   entity3   req�The inherent limiting resolution in mm of the acquisition equipment for high contrast objects for the data gathering and reconstruction technique chosen. If variable across the images of the series, the value at the image center.   descSpatial Resolution   name

SOP Common   module   (0018,a001)[<0>](0018,1050)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   oSequence of Items containing all attributes that were removed or replaced by other values in the main data set.1One or more Items are permitted in this sequence.   descOriginal Attributes Sequence   name

SOP Common   module   (0400,0561)   
M   usage   
table_C.12-1
table_10-1
   mod_tables
Implant Template   entity3   reqPerson's mailing address   descPerson's Address   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1102)   
U   usage   
table_C.29.1.5-1table_C.29.1.5-4
   mod_tables
Implant Template   entity1C   req   #3D Coordinates of the plane normal.3Required if 3D Plane Origin (0068,6610) is present.   desc3D Plane Normal   name
+Generic Implant Template Planning Landmarks   module   (0068,6520)[<0>](0068,6620)   
U   usage    f
   mod_tables
Implant Template   entity1   req   �Value of the HPGL Document ID (0068,62D0) present in the HPGL Document Sequence (0068,62C0) that contains the 2D Drawing including the Mating Feature.$Shall be unique within the sequence.   descReferenced HPGL Document ID   name
(Generic Implant Template Mating Features   module;   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6430)[<2>](0068,6440)   
U   usage    
   mod_tables
Implant Template   entity3   req)Purpose or intended use of this landmark.   descPlanning Landmark Description   name
+Generic Implant Template Planning Landmarks   module   (0068,6510)[<0>](0068,6540)   
U   usage    t
   mod_tables
Implant Template   entity3   reqLabel describing the document.   descHPGL Document Label   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,62d5)   
M   usage    �
   mod_tables
Implant Template   entity3   req   &The purpose of this Digital Signature.1Only a single Item is permitted in this sequence.   desc'Digital Signature Purpose Code Sequence   name

SOP Common   module   (fffa,fffa)[<0>](0400,0401)   
M   usage    �
   mod_tables
Implant Template   entity3   req   QSequence that identifies the anatomical region the implant is to be implanted to.1One or more Items are permitted in this sequence.   descImplant Target Anatomy Sequence   name
$Generic Implant Template Description   module   (0068,6230)   
M   usage   
table_C.12-1
table_10-3
   mod_tables
Implant Template   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name

SOP Common   module   (0020,9172)[<0>](0062,000b)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqmThe certification number issued to the Application Entity that set the SOP Instance Status (0100,0410) to AO.   desc,Authorization Equipment Certification Number   name

SOP Common   module   (0100,0426)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req   NSpecifies the opacity in which it is recommended that the surface be rendered.   See        select: label	   xrefstylesect_C.27.1.1.3   linkend   attrsxref   el.   desc Recommended Presentation Opacity   name
Surface Mesh   module   (0066,0002)[<0>](0066,000c)   
M   usage   ,
   mod_tables
Implant Template   entity1   req0May include Sequence Attributes and their Items.   descBAny Attribute from the main data set that was modified or removed.   name

SOP Common   module)   (0400,0561)[<0>](0400,0550)[0](gggg,eeee)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   DA code sequence specifying the materials the implant is coated with.5One or more Items shall be included in this Sequence."Required if the implant is coated.   descCoating Materials Code Sequence   name
$Generic Implant Template Description   module   (0068,63a4)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   �The SOP Class in which the Instance was originally encoded that has been replaced during a fall-back conversion to the current Related General SOP Class. See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   desc"Original Specialized SOP Class UID   name

SOP Common   module   (0008,001b)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req   �A default triplet value in which it is recommended that the surface be rendered on a color display. The units are specified in PCS-Values, and the value is encoded as CIELab.   See        select: label	   xrefstylesect_C.10.7.1.1   linkend   attrsxref   el   desc Recommended Display CIELab Value   name
Surface Mesh   module   (0066,0002)[<0>](0062,000d)   
U   usage   
table_C.29.1.5-1table_C.29.1.5-2
   mod_tables
Implant Template   entity1   req   mCoordinates of the point in the HPGL document. Coordinates are measured in millimeters of the printing space.   See        select: label	   xrefstylesect_C.29.1.2.1.1   linkend   attrsxref   el.   desc2D Point Coordinates   name
+Generic Implant Template Planning Landmarks   module+   (0068,6500)[<0>](0068,6550)[<1>](0068,6560)   
U   usage   
table_C.29.1.5-1table_C.29.1.5-3
   mod_tables
Implant Template   entity1C   req   12D coordinates of the line in the HPGL documents.5One or more Items shall be included in this sequence.mRequired if 3D Line Coordinates (0068,65D0) is not present and HPGL Document Sequence (0068,62C0) is present.oMay be present if 3D Line Coordinates (0068,65D0) is present and HPGL Document Sequence (0068,62C0) is present.   desc2D Line Coordinates Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6510)[<0>](0068,65a0)   
M   usage    �
   mod_tables
Implant Template   entity3   req   ?The complete manufacturer notification describing the template.WEncapsulated Document stream, containing a document encoded according to the MIME Type.   descEncapsulated Document   name
$Generic Implant Template Description   module   (0068,6265)[<0>](0042,0011)   
M   usage    �
   mod_tables
Implant Template   entity1   req;Date and time from which this Instance is or will be valid.   descEffective DateTime   name
$Generic Implant Template Description   module   (0068,6226)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   req   See        select: label	   xrefstylesect_C.27.4.1   linkend   attrsxref   el.   descPrimitive Point Index List   name
Surface Mesh   module;   (0066,0002)[<0>](0066,0013)[<1>](0066,0026)[<2>](0066,0029)   
M   usage   ,
   mod_tables
Implant Template   entity1   req   Encrypted data. See        select: label	   xrefstylesect_C.12.1.1.4.2   linkend   attrsxref   el.   descEncrypted Content   name

SOP Common   module   (0400,0500)[<0>](0400,0520)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity2   req   eSpecifies whether the surface has been modified subsequent to the original generation of the surface.   
variablelist   typeEnumerated Values:   title      YES   NO   list   See        select: label	   xrefstylesect_C.27.1.1.2   linkend   attrsxref   el.   descSurface Processing   name
Surface Mesh   module   (0066,0002)[<0>](0066,0009)   
U   usage    f
   mod_tables
Implant Template   entity1   reqLabel of the set.   descMating Feature Set Label   name
(Generic Implant Template Mating Features   module   (0068,63b0)[<0>](0068,63d0)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity2   req   All Lines in this Surface.6Zero or more Items shall be included in this sequence.   descLine Sequence   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0013)[<1>](0066,0028)   
U   usage    
   mod_tables
Implant Template   entity2   req   NCoded Description of the real-world point that is represented by the landmark.6Zero or more Items shall be included in this sequence.   desc.Planning Landmark Identification Code Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6500)[<0>](0068,6545)   
U   usage    f
   mod_tables
Implant Template   entity1C   req   MTwo floating point numbers defining a value range for this degree of freedom.   See        select: label	   xrefstylesect_C.29.1.4.1.2   linkend   attrsxref   el.3Required if 3D Mating Point (0068,64C0) is present.   descRange of Freedom   name
(Generic Implant Template Mating Features   module;   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)[<2>](0068,64a0)   
M   usage    �
   mod_tables
Implant Template   entity1   req)Date and Time the information was issued.   descInformation Issue DateTime   name
$Generic Implant Template Description   module   (0068,6265)[<0>](0068,6270)   
U   usage    t
   mod_tables
Implant Template   entity1   reqJNumeric ID of the pen used in the encapsulated HPGL document for outlines.   descHPGL Contour Pen Number   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,6310)   
U   usage   �
   mod_tables
Implant Template   entity1C   req   #3D Coordinates of the plane origin.�Required if 2D Plane Coordinates Sequence (0068,65E0) is not present and Implant Template 3D Model Surface Number (0068,6350) is present.�May be present if 2D Plane Coordinates Sequence (0068,65E0) is present and Implant Template 3D Model Surface Number (0068,6350) is present.   desc3D Plane Origin   name
+Generic Implant Template Planning Landmarks   module   (0068,6520)[<0>](0068,6610)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   �Sequence of Items containing descriptive attributes of related equipment that has contributed to the acquisition, creation or modification of the composite instance.1One or more Items are permitted in this Sequence.   See        select: label	   xrefstylesect_C.12.1.1.5   linkend   attrsxref   el for further explanation.   descContributing Equipment Sequence   name

SOP Common   module   (0018,a001)   
M   usage    �
   mod_tables
Implant Template   entity1   req3Name of the manufacturer that produces the implant.   descManufacturer   name
$Generic Implant Template Description   module   (0008,0070)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   UReference to Implant Template Instance from which this Instance was directly derived.6Only a single Item shall be included in this sequence.0Required if Implant Type (0068,6223) is DERIVED.   desc$Derivation Implant Template Sequence   name
$Generic Implant Template Description   module   (0068,6224)   
M   usage   ,
   mod_tables
Implant Template   entity1   req   |Sequence that contains all the Attributes, with their previous values, that were modified or removed from the main data set.6Only a single Item shall be included in this sequence.   descModified Attributes Sequence   name

SOP Common   module   (0400,0561)[<0>](0400,0550)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqkName of the organization responsible for the Coding Scheme. May include organizational contact information.   desc&Coding Scheme Responsible Organization   name

SOP Common   module   (0008,0110)[<0>](0008,0116)   
M   usage    �
   mod_tables
Implant Template   entity1   req   �A list of Data Element Tags in the order they appear in the Data Set that identify the Data Elements used in creating the MAC for the Digital Signature. See        select: label	   xrefstylesect_C.12.1.1.3.1.1   linkend   attrsxref   el.   descData Elements Signed   name

SOP Common   module   (4ffe,0001)[<0>](0400,0020)   
U   usage   �
   mod_tables
Implant Template   entity1   req   �Value of the HPGL Document ID (0068,62D0) present in the HPGL Document Sequence (0068,62C0) that contains the 2D Drawing including the planning landmark.$Shall be unique within the sequence.   descReferenced HPGL Document ID   name
+Generic Implant Template Planning Landmarks   module+   (0068,6520)[<0>](0068,65e0)[<1>](0068,6440)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqVInstitution where the equipment that contributed to the composite instance is located.   descInstitution Name   name

SOP Common   module   (0018,a001)[<0>](0008,0080)   
M   usage    �
   mod_tables
Implant Template   entity1   req   �The date and time the Digital Signature was created. The time shall include an offset (i.e., time zone indication) from Coordinated Universal Time.      
                            �This is not a certified timestamp, and hence is not completely verifiable. An application can compare this date and time with those of other signatures and the validity date of the certificate to gain confidence in the veracity of this date and time.   contentpara   el
                       contentnote   el   descDigital Signature DateTime   name

SOP Common   module   (fffa,fffa)[<0>](0400,0105)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity3   reqxA 3D location that combined with Center of Rotation (0066,001C) specifies the preferred axis of rotation of this object.   descAxis of Rotation   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0011)[<1>](0066,001b)   
M   usage   �
   mod_tables
Implant Template   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name

SOP Common   module   (0020,9172)[<0>](0008,1160)   
M   usage   �
   mod_tables
Implant Template   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0080)   
M   usage    �
   mod_tables
Implant Template   entity1   req   �The Transfer Syntax UID used to encode the values of the Data Elements included in the MAC calculation. Only Transfer Syntaxes that explicitly include the VR and use Little Endian encoding shall be used.      
                            �Certain Transfer Syntaxes, particularly those that are used with compressed data, allow the fragmentation of the pixel data to change. If such fragmentation changes, Digital Signatures generated with such Transfer Syntaxes could become invalid.   contentpara   el
                       contentnote   el   desc#MAC Calculation Transfer Syntax UID   name

SOP Common   module   (4ffe,0001)[<0>](0400,0010)   
M   usage    �
   mod_tables
Implant Template   entity1   req   WThe algorithm used in generating the MAC to be encrypted to form the Digital Signature.   Defined Terms:   title
variablelist   type      	RIPEMD160   MD5   SHA1   SHA256   SHA384   SHA512   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descMAC Algorithm   name

SOP Common   module   (4ffe,0001)[<0>](0400,0015)   
M   usage    �
   mod_tables
Implant Template   entity3   req   WEncapsulated Document stream, containing a document encoded according to the MIME Type.&The complete manufacturer information.   descEncapsulated Document   name
$Generic Implant Template Description   module   (0068,6260)[<0>](0042,0011)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity2   req   -Contains n point indices describing Vertices.   See        select: label	   xrefstylesect_C.27.4.1   linkend   attrsxref   el.   descVertex Point Index List   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0013)[<1>](0066,0025)   
M   usage    �
   mod_tables
Implant Template   entity1   req   �Sequence that identifies the anatomic region of interest in this Instance (i.e., external anatomy, surface anatomy, or general region of the body).6Only a single Item shall be included in this sequence.   descAnatomic Region Sequence   name
$Generic Implant Template Description   module   (0068,6230)[<0>](0008,2218)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity2   req   CAll Facets in this Surface. Each sequence Item describes one facet.6Zero or more Items shall be included in this sequence.   descFacet Sequence   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0013)[<1>](0066,0034)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   req   See        select: label	   xrefstylesect_C.27.2.1.1   linkend   attrsxref   el   descPoint Coordinates Data   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0011)[<1>](0066,0016)   
M   usage    �
   mod_tables
Implant Template   entity1   req   )The version code of the implant template.�If Implant Type (0068,6223) is DERIVED, this shall have the same value as the Implant Template Version (0068,6221) of the manufacturer's implant template from which this instance was derived.   descImplant Template Version   name
$Generic Implant Template Description   module   (0068,6221)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity2   req   7Contains 2n point indices describing unconnected Edges.   See        select: label	   xrefstylesect_C.27.4.1   linkend   attrsxref   el.   descEdge Point Index List   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0013)[<1>](0066,0024)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   "Date the SOP Instance was created.xThis is the date that the SOP Instance UID was assigned, and does not change during subsequent coercion of the instance.   descInstance Creation Date   name

SOP Common   module   (0008,0012)   
M   usage   �
   mod_tables
Implant Template   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1101)   
M   usage    0
   mod_tables
Implant Template   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
$Generic Implant Template Description   module   (0068,6222)[<0>](0008,1155)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   reqEThe name assigned by a manufacturer to a specific software algorithm.   descAlgorithm Name   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0035)[<1>](0066,0036)   
U   usage    t
   mod_tables
Implant Template   entity1   req   1Conversion factor (real world mm/printed mm) See        select: label	   xrefstylesect_C.29.1.2.1.1   linkend   attrsxref   el.   descHPGL Document Scaling   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,62f2)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqeAddress of the institution where the equipment that contributed to the composite instance is located.   descInstitution Address   name

SOP Common   module   (0018,a001)[<0>](0008,0081)   
M   usage   
table_C.12-1table_10-11
   mod_tables
Implant Template   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name

SOP Common   module   (0040,a390)[<0>](0008,1155)   
M   usage    �
   mod_tables
Implant Template   entity1   reqsA number used to identify which MAC Parameters Sequence item was used in the calculation of this Digital Signature.   descMAC ID Number   name

SOP Common   module   (fffa,fffa)[<0>](0400,0005)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity2C   requThe Ratio of Remaining points to Original points after processing. Required if Surface Processing (0066,0009) is YES.   descSurface Processing Ratio   name
Surface Mesh   module   (0066,0002)[<0>](0066,000a)   
M   usage    �
   mod_tables
Implant Template   entity1   req3Defines a 3D Frame of Reference for this component.   descFrame of Reference UID   name
$Generic Implant Template Description   module   (0020,0052)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    
   mod_tables
Surface Mesh   entity1   req   7The dimensionality of the underlying vector field. See        select: label	   xrefstylesect_C.27.3.1   linkend   attrsxref   el.   descVector Dimensionality   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0012)[<1>](0066,001f)   
U   usage    f
   mod_tables
Implant Template   entity1C   req   uThe Axes of contact described as direction cosines in the 3D coordinate system defined by the Frame Of Reference UID.3Required if 3D Mating Point (0068,64C0) is present.   See        select: label	   xrefstylesect_C.29.1.4.1.1   linkend   attrsxref   el   desc3D Mating Axes   name
(Generic Implant Template Mating Features   module+   (0068,63b0)[<0>](0068,63e0)[<1>](0068,64d0)   
M   usage   ,
   mod_tables
Implant Template   entity1C   req�The coding scheme UID identifier. Required if coding scheme is identified by an ISO 8824 object identifier compatible with the UI VR.   descCoding Scheme UID   name

SOP Common   module   (0008,0110)[<0>](0008,010c)   
M   usage   ,
   mod_tables
Implant Template   entity1   reqZThe value of a Coding Scheme Designator, used in this SOP Instance, which is being mapped.   descCoding Scheme Designator   name

SOP Common   module   (0008,0110)[<0>](0008,0102)   
U   usage    f
   mod_tables
Implant Template   entity1   req�Numeric ID of the degree of freedom. Uniquely identifies a degree of freedom within this Sequence Item. The value shall start at 1, and increase monotonically by 1 for each Item.   descDegree of Freedom ID   name
(Generic Implant Template Mating Features   module;   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)[<2>](0068,6410)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   KDate and time that the SOP Instance was last coerced by a Storage SCP (see        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el).   descInstance Coercion DateTime   name

SOP Common   module   (0008,0015)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity3   req�A single standard deviation of the error for all the points' spatial positions. The units shall be the same as the units of the coordinate system in which the point coordinates are specified.   descPoint Position Accuracy   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0011)[<1>](0066,0017)   
M   usage   ,
   mod_tables
Implant Template   entity1   req   IDescribes the purpose for which the related equipment is being reference.6Only a single Item shall be included in this sequence.   See        select: label	   xrefstylesect_C.12.1.1.5   linkend   attrsxref   el for further explanation.   desc"Purpose of Reference Code Sequence   name

SOP Common   module   (0018,a001)[<0>](0040,a170)   
U   usage    t
   mod_tables
Implant Template   entity1   req   0The 2D template representations of this implant.5One or more Items shall be included in this sequence.   descHPGL Document Sequence   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   req   See        select: label	   xrefstylesect_C.27.4.1   linkend   attrsxref   el.   descPrimitive Point Index List   name
Surface Mesh   module;   (0066,0002)[<0>](0066,0013)[<1>](0066,0027)[<2>](0066,0029)   
M   usage    �
   mod_tables
Implant Template   entity3   req   gA sequence of items that describe the parameters used to calculate a MAC for use in Digital Signatures.5One or more Items shall be included in this sequence.   descMAC Parameters Sequence   name

SOP Common   module   (4ffe,0001)   
U   usage    f
   mod_tables
Implant Template   entity1C   req   aDirection cosines of the axis of the degree of freedom in the Frame of Reference of the template.   See        select: label	   xrefstylesect_C.29.1.4.1.2   linkend   attrsxref   el.3Required if 3D Mating Point (0068,64C0) is present.   desc3D Degree Of Freedom Axis   name
(Generic Implant Template Mating Features   module;   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)[<2>](0068,6490)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqSThe coding scheme version associated with the Coding Scheme Designator (0008,0102).   descCoding Scheme Version   name

SOP Common   module   (0008,0110)[<0>](0008,0103)   
M   usage    �
   mod_tables
Implant Template   entity1   req   DA code sequence specifying the materials the implant was built from.5One or more Items shall be included in this Sequence.   descMaterials Code Sequence   name
$Generic Implant Template Description   module   (0068,63a0)   
U   usage    f
   mod_tables
Implant Template   entity1   req   ,Indicates the type of the degree of freedom.   
variablelist   typeEnumerated Values:   title      TRANSLATION   ROTATION   list   See        select: label	   xrefstylesect_C.29.1.4.1.2   linkend   attrsxref   el.   descDegree of Freedom Type   name
(Generic Implant Template Mating Features   module;   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)[<2>](0068,6420)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   @Identification of the operator(s) of the contributing equipment.1One or more items are permitted in this sequence.|The number and order of Items shall correspond to the number and order of values of Operators' Name (0008,1070), if present.   desc Operator Identification Sequence   name

SOP Common   module   (0018,a001)[<0>](0008,1072)   
U   usage    f
   mod_tables
Implant Template   entity1C   req   Origin of the contact system.�Required if 2D Mating Feature Coordinates Sequence (0068,6430) is not present and Implant Template 3D Model Surface Number (0068,6350) is present.�May be present if 2D Mating Feature Coordinates Sequence (0068,6430) is present and Implant Template 3D Model Surface Number (0068,6350) is present.   See        select: label	   xrefstylesect_C.29.1.4.1.1   linkend   attrsxref   el   desc3D Mating Point   name
(Generic Implant Template Mating Features   module+   (0068,63b0)[<0>](0068,63e0)[<1>](0068,64c0)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   %The size descriptor of the component.nRequired if the component exists in different sizes and the size number is not part of the name or identifier.May be present otherwise.   See        select: label	   xrefstylesect_C.29.1.1.1.1   linkend   attrsxref   el for details.   descImplant Size   name
$Generic Implant Template Description   module   (0068,6210)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   �The type of certified timestamp used in Certified Timestamp (0400,0310). Required if Certified Timestamp (0400,0310) is present.   Defined Terms:   title
variablelist   type      CMS_TSP<Internet X.509 Public Key Infrastructure Time Stamp Protocol   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descCertified Timestamp Type   name

SOP Common   module   (fffa,fffa)[<0>](0400,0305)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqIThe date and time when the SOP Instance Status (0100,0410) was set to AO.   descSOP Authorization DateTime   name

SOP Common   module   (0100,0420)   
M   usage    �
   mod_tables
Implant Template   entity1   req   USequence containing a coded description of the type of implant the template reflects.6Only a single Item shall be included in this sequence.   descImplant Type Code Sequence   name
$Generic Implant Template Description   module   (0068,63a8)   
M   usage   
table_C.29.1.1-1table_10-11
   mod_tables
Implant Template   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
$Generic Implant Template Description   module   (0068,6225)[<0>](0008,1150)   
M   usage    �
   mod_tables
Implant Template   entity1   reqSummary of the information.   descInformation Summary   name
$Generic Implant Template Description   module   (0068,6260)[<0>](0068,6280)   
U   usage    
   mod_tables
Implant Template   entity1   req   gNumeric ID of the planning landmark. Uniquely identifies the planning landmark within the SOP instance.JThe value shall start at 1, and increase monotonically by 1 for each Item.   descPlanning Landmark ID   name
+Generic Implant Template Planning Landmarks   module   (0068,6520)[<0>](0068,6530)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1C   req�A 3D location defining the preferred center of rotation for this point set. Required if Axis of Rotation (0066,001B) is present. May be present otherwise.   descCenter of Rotation   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0011)[<1>](0066,001c)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity2   req   *The normals on the surface for each point.4Zero or one item shall be included in this sequence.   See        select: label	   xrefstylesect_C.27.1.1.6   linkend   attrsxref   el.   descSurface Points Normals Sequence   name
Surface Mesh   module   (0066,0002)[<0>](0066,0012)   
M   usage   ,
   mod_tables
Implant Template   entity3   req9Name(s) of the operator(s) of the contributing equipment.   descOperators' Name   name

SOP Common   module   (0018,a001)[<0>](0008,1070)   
U   usage    t
   mod_tables
Implant Template   entity1   reqVPoint around which the 2D template is rotated in manual planning, in HPGL coordinates.   descRecommended Rotation Point   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,6346)   
U   usage    t
   mod_tables
Implant Template   entity1   req   ;Labels for each pen used in the encapsulated HPGL Document.5One or more Items shall be included in this sequence.9Shall contain one item per pen used in the HPGL document.   descHPGL Pen Sequence   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,6320)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   XUniquely identifies a Related General SOP Class for the SOP Class of this Instance. See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descRelated General SOP Class UID   name

SOP Common   module   (0008,001a)   
M   usage    �
   mod_tables
Implant Template   entity1   req   PIndicates whether the Implant Template is derived from another Implant Template.   
variablelist   typeEnumerated Values:   title      ORIGINAL   DERIVED   list   descImplant Type   name
$Generic Implant Template Description   module   (0068,6223)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   �Reference to the Implant Template Instance with Implant Type (0068,6223) ORIGINAL from which this Instance was ultimately derived.6Only a single Item shall be included in this sequence.0Required if Implant Type (0068,6223) is DERIVED.   desc"Original Implant Template Sequence   name
$Generic Implant Template Description   module   (0068,6225)   
U   usage   
table_C.29.1.3-1
   mod_tables
Implant Template   entity1   reqRReference to a Surface Number (0066,0003) present in Surface Sequence (0066,0002).   descReferenced Surface Number   name
"Generic Implant Template 3D Models   module   (0068,6360)[<0>](0066,002c)   
M   usage    �
   mod_tables
Implant Template   entity1   req"The (product) name of the implant.   descImplant Name   name
$Generic Implant Template Description   module   (0022,1095)   
M   usage   ,
   mod_tables
Implant Template   entity1   req   *Uniquely identifies the SOP Instance. See        select: label	   xrefstylesect_C.12.1.1.1   linkend   attrsxref   el# for further explanation. See also        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descSOP Instance UID   name

SOP Common   module   (0008,0018)   
M   usage   ,
   mod_tables
Implant Template   entity3   req9Uniquely identifies device that created the SOP Instance.   descInstance Creator UID   name

SOP Common   module   (0008,0014)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity3   req   )The mean point distance of the point set.�It is given by the mean of the distances to the nearest neighbor over all points. The units shall be the same as the units of the coordinate system in which the point coordinates are specified.   descMean Point Distance   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0011)[<1>](0066,0018)   
U   usage    f
   mod_tables
Implant Template   entity1   req   /Interval of freedom for this degree of freedom.   See        select: label	   xrefstylesect_C.29.1.4.1.2   linkend   attrsxref   el.   descRange of Freedom   name
(Generic Implant Template Mating Features   moduleK   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)[<2>](0068,6470)[<3>](0068,64a0)   
M   usage   
table_C.29.1.1-1table_10-11
   mod_tables
Implant Template   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
$Generic Implant Template Description   module   (0068,6224)[<0>](0008,1155)   
U   usage   u
   mod_tables
Implant Template   entity1   req   lCoordinates of the line in the HPGL document. Coordinates are measured in millimeters of the printing space.   See        select: label	   xrefstylesect_C.29.1.2.1.1   linkend   attrsxref   el.   desc2D Line Coordinates   name
+Generic Implant Template Planning Landmarks   module+   (0068,6510)[<0>](0068,65a0)[<1>](0068,65b0)   
U   usage   %
   mod_tables
Implant Template   entity1   req    Scaling factor (mm/Surface unit)   See        select: label	   xrefstylesect_C.29.1.3.1.1   linkend   attrsxref   el.   descSurface Model Scaling Factor   name
"Generic Implant Template 3D Models   module   (0068,6390)   
M   usage   �
   mod_tables
Implant Template   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0082)   
M   usage   ,
   mod_tables
Implant Template   entity1C   req   XThe set of images or other composite SOP Instances that were converted to this instance.zIf this instance was converted from a specific frame in the source instance, the reference shall include the Frame Number.5One or more Items shall be included in this sequence.�Required if this instance was created by conversion, and Conversion Source Attributes Sequence (0020,9172) is not present in an Item of Shared Functional Groups Sequence (5200,9229) or Per-Frame Functional Groups Sequence (5200,9230).   desc%Conversion Source Attributes Sequence   name

SOP Common   module   (0020,9172)   
U   usage    t
   mod_tables
Implant Template   entity1   req   KCoded description of the direction of view represented by this 2D template.6Only a single Item shall be included in this sequence.   descView Orientation Code Sequence   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,62e0)   
M   usage   �
   mod_tables
Implant Template   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
$Generic Implant Template Description   module   (0068,6225)[<0>](0008,1155)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   �Sequence of items that map values of Coding Scheme Designator (0008,0102) to an external coding system registration, or to a private or local coding scheme.1One or more Items are permitted in this sequence.   desc%Coding Scheme Identification Sequence   name

SOP Common   module   (0008,0110)   
M   usage    �
   mod_tables
Implant Template   entity2   reqeTolerance in mm applying to all distance measurements and spatial locations in this Implant Template.   desc"Overall Template Spatial Tolerance   name
$Generic Implant Template Description   module   (0068,62a5)   
M   usage    �
   mod_tables
Implant Template   entity1   req   ?The method that will be used to fixate the implant in the body.6Only a single Item shall be included in this sequence.   descFixation Method Code Sequence   name
$Generic Implant Template Description   module   (0068,63ac)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqUUser defined name identifying the machine that contributed to the composite instance.   descStation Name   name

SOP Common   module   (0018,a001)[<0>](0008,1010)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   rTime when the image acquisition device calibration was last changed in any way. Multiple entries may be used. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descTime of Last Calibration   name

SOP Common   module   (0018,a001)[<0>](0018,1201)   
M   usage   ,
   mod_tables
Implant Template   entity1   req   &Reason for the attribute modification.   
variablelist   typeDefined Terms:   title      COERCE�Replace values of attributes such as Patient Name, ID, Accession Number, for example, during import of media from an external institution, or reconciliation against a master patient index.   CORRECT�Replace incorrect values, such as Patient Name or ID, for example, when incorrect worklist item was chosen or operator input error.   list   desc%Reason for the Attribute Modification   name

SOP Common   module   (0400,0561)[<0>](0400,0565)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity2   req   $All Triangle Strips in this Surface.6Zero or more Items shall be included in this sequence.   descTriangle Strip Sequence   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0013)[<1>](0066,0026)   
U   usage    t
   mod_tables
Implant Template   entity3   reqView Orientation Modifier.   descView Orientation Modifier   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,62f0)   
U   usage    
   mod_tables
Implant Template   entity3   req(Purpose or intended use of the landmark.   descPlanning Landmark Description   name
+Generic Implant Template Planning Landmarks   module   (0068,6500)[<0>](0068,6540)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   DReference to the Implant Template that is replaced by this template.6Only a single Item shall be included in this sequence.4Required if this Instance replaces another Instance.   desc"Replaced Implant Template Sequence   name
$Generic Implant Template Description   module   (0068,6222)   
U   usage    f
   mod_tables
Implant Template   entity1C   req   JGeometric specifications of the degrees of freedom for this HPGL Document.5One or more Items shall be included in this sequence.JRequired if 2D Mating Feature Coordinates Sequence (0068,6430) is present.   See        select: label	   xrefstylesect_C.29.1.4.1.2   linkend   attrsxref   el.   desc2D Degree of Freedom Sequence   name
(Generic Implant Template Mating Features   module;   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)[<2>](0068,6470)   
M   usage    �
   mod_tables
Implant Template   entity3   req   �A certified timestamp of the Digital Signature (0400,0120) Attribute Value, which shall be obtained when the Digital Signature is created. See        select: label	   xrefstylesect_C.12.1.1.3.1.3   linkend   attrsxref   el.   descCertified Timestamp   name

SOP Common   module   (fffa,fffa)[<0>](0400,0310)   
U   usage    f
   mod_tables
Implant Template   entity1   req   (Direction cosines of the contact system.   See        select: label	   xrefstylesect_C.29.1.4.1.1   linkend   attrsxref   el   desc2D Mating Axes   name
(Generic Implant Template Mating Features   module;   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6430)[<2>](0068,6460)   
U   usage    t
   mod_tables
Implant Template   entity1   reqfHPGL coordinates of the smallest rectangle parallel to the paper axes that contains the whole drawing.   descBounding Rectangle   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,6347)   
M   usage   ,
   mod_tables
Implant Template   entity3   req"The coding scheme full common name   descCoding Scheme Name   name

SOP Common   module   (0008,0110)[<0>](0008,0115)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqVManufacturer's model name of the equipment that contributed to the composite instance.   descManufacturer's Model Name   name

SOP Common   module   (0018,a001)[<0>](0008,1090)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    
   mod_tables
Surface Mesh   entity3   req   �A single standard deviation for all the vectors' coordinates. The units shall be the same as the units of the coordinate system in which the vector coordinates are specified. See        select: label	   xrefstylesect_C.27.3.1   linkend   attrsxref   el.   descVector Accuracy   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0012)[<1>](0066,0020)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   req   See        select: label	   xrefstylesect_C.27.4.1   linkend   attrsxref   el.   descPrimitive Point Index List   name
Surface Mesh   module;   (0066,0002)[<0>](0066,0013)[<1>](0066,0028)[<2>](0066,0029)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity3   req   EThe code assigned by a manufacturer to a specific software algorithm.1Only a single item is permitted in this sequence.   descAlgorithm Name Code Sequence   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0035)[<1>](0066,0030)   
U   usage    f
   mod_tables
Implant Template   entity1   req   The mating features of the set.5One or more Items shall be included in this sequence.   descMating Feature Sequence   name
(Generic Implant Template Mating Features   module   (0068,63b0)[<0>](0068,63e0)   
M   usage   ,
   mod_tables
Implant Template   entity2   req�The source that provided the SOP Instance prior to the removal or replacement of the values. For example, this might be the Institution from which imported SOP Instances were received.   descSource of Previous Values   name

SOP Common   module   (0400,0561)[<0>](0400,0564)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity2C   req    Describes the processing method.4Zero or one Item shall be included in this sequence.2Required if Surface Processing (0066,0009) is YES.   desc4Surface Processing Algorithm Identification Sequence   name
Surface Mesh   module   (0066,0002)[<0>](0066,0035)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity3   req:A textual description of the surface processing performed.   descSurface Processing Description   name
Surface Mesh   module   (0066,0002)[<0>](0066,000b)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   req\The software version identifier assigned by a manufacturer to a specific software algorithm.   descAlgorithm Version   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0035)[<1>](0066,0031)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   YSequence containing countries and regions in which the implant is not approved for usage.5One or more Items shall be included in this sequence.FRequired if the implant has been disapproved in a country or a region.   desc,Implant Regulatory Disapproval Code Sequence   name
$Generic Implant Template Description   module   (0068,62a0)   
U   usage    
   mod_tables
Implant Template   entity2   req   NCoded Description of the real-world line that is represented by this landmark.6Zero or more Items shall be included in this sequence.   desc.Planning Landmark Identification Code Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6510)[<0>](0068,6545)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   req   KThe family of algorithm(s) that best describes the software algorithm used.6Only a single item shall be included in this sequence.   descAlgorithm Family Code Sequence   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0035)[<1>](0066,002f)   
U   usage   %
   mod_tables
Implant Template   entity1   reqLabel for this surface.   descSurface Model Label   name
"Generic Implant Template 3D Models   module   (0068,6360)[<0>](0068,6380)   
M   usage    �
   mod_tables
Implant Template   entity3   req   jInformation from Manufacturer other than described in Notification From Manufacturer Sequence (0068,6265).5One or more Items shall be included in this sequence.   desc&Information From Manufacturer Sequence   name
$Generic Implant Template Description   module   (0068,6260)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqhDepartment in the institution where the equipment that contributed to the composite instance is located.   descInstitutional Department Name   name

SOP Common   module   (0018,a001)[<0>](0008,1040)   
M   usage   �
   mod_tables
Implant Template   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
$Generic Implant Template Description   module   (0068,6224)[<0>](0008,1150)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   �Contains the offset from UTC to the timezone for all DA and TM Attributes present in this SOP Instance, and for all DT Attributes present in this SOP Instance that do not contain an explicitly encoded timezone offset.�Encoded as an ASCII string in the format "&ZZXX". The components of this string, from left to right, are & = "+" or "-", and ZZ = Hours and XX = Minutes of offset. Leading space characters shall not be present.;The offset for UTC shall be +0000; -0000 shall not be used.      
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
U   usage   �
   mod_tables
Implant Template   entity1   req   �2D Coordinates of the intersection of the plane with the projection plane. Coordinates are measured in Millimeters of the printing space.   See        select: label	   xrefstylesect_C.29.1.2.1.1   linkend   attrsxref   el.   desc2D Plane Intersection   name
+Generic Implant Template Planning Landmarks   module+   (0068,6520)[<0>](0068,65e0)[<1>](0068,65f0)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req   9The point positions representing vertices of the surface.6Only a single item shall be included in this sequence.   descSurface Points Sequence   name
Surface Mesh   module   (0066,0002)[<0>](0066,0011)   
U   usage   �
   mod_tables
Implant Template   entity1C   req   C2D coordinates of the plane's intersection with the HPGL documents.5One or more Items shall be included in this sequence.iRequired if 3D Plane Origin (0068,6610) is not present and HPGL Document Sequence (0068,62C0) is present.kMay be present if 3D Plane Origin (0068,6610) is present and HPGL Document Sequence (0068,62C0) is present.   desc2D Plane Coordinates Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6520)[<0>](0068,65e0)   
M   usage    �
   mod_tables
Implant Template   entity1   req<A UID that can be used to uniquely reference this signature.   descDigital Signature UID   name

SOP Common   module   (fffa,fffa)[<0>](0400,0100)   
M   usage   ,
   mod_tables
Implant Template   entity1   reqIIdentification of the system that removed and/or replaced the attributes.   descModifying System   name

SOP Common   module   (0400,0561)[<0>](0400,0563)   
M   usage   �
   mod_tables
Implant Template   entity3   reqtMailing address of the institution or organization to which the identified individual is responsible or accountable.   descInstitution Address   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0081)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity1   req   �Specifies the number of points in the point set. Shall be less than or equal to 65535, if there are indexes into Points Coordinates Data (0066,0016) that are limited in length. See        select: label	   xrefstylesect_C.27.2.1.1   linkend   attrsxref   el.   descNumber Of Surface Points   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0011)[<1>](0066,0015)   
U   usage    
   mod_tables
Implant Template   entity1   req�Numeric ID of the planning landmark. Uniquely identifies the planning landmark within the SOP instance. The value shall start at 1, and increase monotonically by 1 for each Item.   descPlanning Landmark ID   name
+Generic Implant Template Planning Landmarks   module   (0068,6510)[<0>](0068,6530)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    
   mod_tables
Surface Mesh   entity1   req   4A data stream of coordinates encoded as floats. See        select: label	   xrefstylesect_C.27.3.1   linkend   attrsxref   el.   descVector Coordinate Data   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0012)[<1>](0066,0021)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity2   req   "All Triangle Fans in this Surface.6Zero or more Items shall be included in this sequence.   descTriangle Fan Sequence   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0013)[<1>](0066,0027)   
U   usage    t
   mod_tables
Implant Template   entity1   req   jIdentification number of the HPGL Document. Uniquely identifies an HPGL Document within this SOP instance.<The value shall start at 1, and increase monotonically by 1.   descHPGL Document ID   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,62d0)   
U   usage   %
   mod_tables
Implant Template   entity1   reqZSurface Number (0066,0003) of the surface that represents the shape of the entire implant.   desc(Implant Template 3D Model Surface Number   name
"Generic Implant Template 3D Models   module   (0068,6350)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqIThe Date & Time when the equipment contributed to the composite instance.   descContribution DateTime   name

SOP Common   module   (0018,a001)[<0>](0018,a002)   
U   usage    
   mod_tables
Implant Template   entity3   req   Line landmarks for planning.1One or more Items are permitted in this sequence.   descPlanning Landmark Line Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6510)   
M   usage   ,
   mod_tables
Implant Template   entity3   req8A number that identifies this Composite object instance.   descInstance Number   name

SOP Common   module   (0020,0013)   
U   usage    f
   mod_tables
Implant Template   entity3   req   DMating feature sets used to combine the implant with other implants.5One or more Items shall be included in this sequence.   descMating Feature Sets Sequence   name
(Generic Implant Template Mating Features   module   (0068,63b0)   
U   usage    t
   mod_tables
Implant Template   entity1   req*Numeric ID of the pen in the HPGL document   descHPGL Pen Number   name
$Generic Implant Template 2D Drawings   module+   (0068,62c0)[<0>](0068,6320)[<1>](0068,6330)   
U   usage   \
   mod_tables
Implant Template   entity1C   req   3D Coordinates of the point.�Required if 2D Point Coordinates Sequence (0068,6550) is not present and Implant Template 3D Model Surface Number (0068,6350) is present.�May be present if 2D Point Coordinates Sequence (0068,6550) is present and Implant Template 3D Model Surface Number (0068,6350) is present.   desc3D Point Coordinates   name
+Generic Implant Template Planning Landmarks   module   (0068,6500)[<0>](0068,6590)   
U   usage    
   mod_tables
Implant Template   entity2   req   OCoded Description of the real-world plane that is represented by this landmark.6Zero or more Items shall be included in this sequence.   desc.Planning Landmark Identification Code Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6520)[<0>](0068,6545)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity3   req   �Specifies the radius of the vertex points defined in the Vertex Point Index List (0066,0025) with which it is recommended that the point be rendered.oThe units shall be the same as the units of the coordinate system in which the point coordinates are specified.   descRecommended Point Radius   name
Surface Mesh   module   (0066,0002)[<0>](0066,0037)   
M   usage   ,
   mod_tables
Implant Template   entity1   reqIManufacturer of the equipment that contributed to the composite instance.   descManufacturer   name

SOP Common   module   (0018,a001)[<0>](0008,0070)   
M   usage    �
   mod_tables
Implant Template   entity1   req�A number, unique within this SOP Instance, used to identify this MAC Parameters Sequence (4FFE,0001) item from an Item of the Digital Signatures Sequence (FFFA,FFFA).   descMAC ID Number   name

SOP Common   module   (4ffe,0001)[<0>](0400,0005)   
U   usage    
   mod_tables
Implant Template   entity3   req   Plane landmarks for planning.1One or more Items are permitted in this sequence.   desc Planning Landmark Plane Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6520)   
U   usage   \
   mod_tables
Implant Template   entity1   req   �Value of the HPGL Document ID (0068,62D0) present in the HPGL Document Sequence (0068,62C0) that contains the 2D Drawing including the planning landmark.$Shall be unique within the sequence.   descReferenced HPGL Document ID   name
+Generic Implant Template Planning Landmarks   module+   (0068,6500)[<0>](0068,6550)[<1>](0068,6440)   
M   usage   ,
   mod_tables
Implant Template   entity1C   req   �The name of the external registry where further definition of the identified coding scheme may be obtained. Required if coding scheme is registered.   
variablelist   typeDefined Terms:   title      HL7   list   descCoding Scheme Registry   name

SOP Common   module   (0008,0110)[<0>](0008,0112)   
M   usage    �
   mod_tables
Implant Template   entity1   req)Date and Time the information was issued.   descInformation Issue DateTime   name
$Generic Implant Template Description   module   (0068,6260)[<0>](0068,6270)   
M   usage   ,
   mod_tables
Implant Template   entity1C   req   =Character Set that expands or replaces the Basic Graphic Set.=Required if an expanded or replacement character set is used.   See        select: label	   xrefstylesect_C.12.1.1.2   linkend   attrsxref   el for Defined Terms.   descSpecific Character Set   name

SOP Common   module   (0008,0005)   
U   usage    f
   mod_tables
Implant Template   entity1   req   7Direction cosines of the axis of the degree of freedom.   See        select: label	   xrefstylesect_C.29.1.4.1.2   linkend   attrsxref   el.   desc2D Degree Of Freedom Axis   name
(Generic Implant Template Mating Features   moduleK   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6400)[<2>](0068,6470)[<3>](0068,64f0)   
U   usage   u
   mod_tables
Implant Template   entity1C   req   3D Coordinates of the line.�Required if 2D Line Coordinates Sequence (0068,65A0) is not present and Implant Template 3D Model Surface Number (0068,6350) is present.�May be present, if 2D Line Coordinates Sequence (0068,65A0) is present and Implant Template 3D Model Surface Number (0068,6350) is present.   desc3D Line Coordinates   name
+Generic Implant Template Planning Landmarks   module   (0068,6510)[<0>](0068,65d0)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity3   req   �Specifies the thickness of each edge or line defined in the Edge Point Index List (0066,0024) or Line Sequence (0066,0028) with which it is recommended that the line be rendered.oThe units shall be the same as the units of the coordinate system in which the point coordinates are specified.   descRecommended Line Thickness   name
Surface Mesh   module   (0066,0002)[<0>](0066,0038)   
M   usage   ,
   mod_tables
Implant Template   entity1   req:Date and time the attributes were removed and/or replaced.   descAttribute Modification DateTime   name

SOP Common   module   (0400,0561)[<0>](0400,0562)   
U   usage   u
   mod_tables
Implant Template   entity1   req   �Value of the HPGL Document ID (0068,62D0) present in the HPGL Document Sequence (0068,62C0) that contains the 2D Drawing including the planning landmark.$Shall be unique within the sequence.   descReferenced HPGL Document ID   name
+Generic Implant Template Planning Landmarks   module+   (0068,6510)[<0>](0068,65a0)[<1>](0068,6440)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   =A flag that indicates the storage status of the SOP Instance.   
variablelist   typeEnumerated Values:   title      NSwNot Specified; implies that this SOP Instance has no special storage status, and hence no special actions need be taken   OR�Original; implies that this is the primary SOP instance for the purpose of storage, but that it has not yet been authorized for diagnostic use   AO�Authorized Original; implies that this is the primary SOP instance for the purpose of storage, which has been authorized for diagnostic use   AC�Authorized Copy; implies that this is a copy of an Authorized Original SOP Instance; any copies of an Authorized Original should be given the status of Authorized Copy   list      
                        �Proper use of these flags is specified in Security Profiles. Implementations that do not conform to such Security Profiles may not necessarily handle these flags properly.   contentpara   el
                   contentnote   el   descSOP Instance Status   name

SOP Common   module   (0100,0410)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req   XSpecifies the presentation type in which it is recommended that the surface be rendered.   See        select: label	   xrefstylesect_C.27.1.1.3   linkend   attrsxref   el.   descRecommended Presentation Type   name
Surface Mesh   module   (0066,0002)[<0>](0066,000d)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   `The type of the encapsulated document stream described using the MIME Media Type (see RFC 2046).ORequired if Encapsulated Document (0042,0011) is present in this Sequence item.   
variablelist   typeEnumerated Values:   title      application/pdf   list   desc"MIME Type of Encapsulated Document   name
$Generic Implant Template Description   module   (0068,6260)[<0>](0042,0012)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req   �A default single gray unsigned value in which it is recommended that the maximum pixel value in this surface be rendered on a monochrome display. The units are specified in P-Values from a minimum of 0000H (black) up to a maximum of FFFFH (white).      
                        �The maximum P-Value for this Attribute may be different from the maximum P-Value from the output of the Presentation LUT, which may be less than 16 bits in depth.   contentpara   el
                   contentnote   el   desc#Recommended Display Grayscale Value   name
Surface Mesh   module   (0066,0002)[<0>](0062,000c)   
U   usage    t
   mod_tables
Implant Template   entity1   reqLabel of the pen.   descHPGL Pen Label   name
$Generic Implant Template 2D Drawings   module+   (0068,62c0)[<0>](0068,6320)[<1>](0068,6340)   
M   usage   �
   mod_tables
Implant Template   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1103)   
M   usage    �
   mod_tables
Implant Template   entity1C   req   `The type of the encapsulated document stream described using the MIME Media Type (see RFC 2046).ORequired if Encapsulated Document (0042,0011) is present in this Sequence item.   
variablelist   typeEnumerated Values:   title      application/pdf   list   desc"MIME Type of Encapsulated Document   name
$Generic Implant Template Description   module   (0068,6265)[<0>](0042,0012)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqMDescription of the contribution the equipment made to the composite instance.   descContribution Description   name

SOP Common   module   (0018,a001)[<0>](0018,a003)   
M   usage    �
   mod_tables
Implant Template   entity1   reqSummary of the information.   descInformation Summary   name
$Generic Implant Template Description   module   (0068,6265)[<0>](0068,6280)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity3   req�The maximum distance of one point to its nearest neighbor. The units shall be the same as the units of the coordinate system in which the point coordinates are specified.   descMaximum Point Distance   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0011)[<1>](0066,0019)   
M   usage   
table_C.12-1
table_10-3table_10-11
   mod_tables
Implant Template   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name

SOP Common   module   (0020,9172)[<0>](0008,1150)   
M   usage   ,
   mod_tables
Implant Template   entity1   req�Instance Identifier of the referenced HL7 Structured Document, encoded as a UID (OID or UUID), concatenated with a caret ("^") and Extension value (if Extension is present in Instance Identifier).   descHL7 Instance Identifier   name

SOP Common   module   (0040,a390)[<0>](0040,e001)   
M   usage   ,
   mod_tables
Implant Template   entity1C   req   ,  Sequence of items defining mapping between HL7 Instance Identifiers of unencapsulated HL7 Structured Documents referenced from the current SOP Instance as if they were DICOM Composite SOP Class Instances defined by SOP Class and Instance UID pairs. May also define a means of accessing the Documents.5One or more Items shall be included in this sequence.   See        select: label	   xrefstylesect_C.12.1.1.6   linkend   attrsxref   el.�Required if unencapsulated HL7 Structured Documents are referenced within the Instance. Every such document so referenced is required to have a corresponding Item in this Sequence.   desc*HL7 Structured Document Reference Sequence   name

SOP Common   module   (0040,a390)   
M   usage   ,
   mod_tables
Implant Template   entity3   reqVAny comments associated with the setting of the SOP Instance Status (0100,0410) to AO.   descSOP Authorization Comment   name

SOP Common   module   (0100,0424)   
M   usage    �
   mod_tables
Implant Template   entity1   req(The (product) identifier of the implant.   descImplant Part Number   name
$Generic Implant Template Description   module   (0022,1097)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req�Identification number of the surface. Uniquely identifies a surface within this SOP instance. Shall start at a value of 1, and increase monotonically by 1.   descSurface Number   name
Surface Mesh   module   (0066,0002)[<0>](0066,0003)   
U   usage    f
   mod_tables
Implant Template   entity1C   req   8Coordinates of the mating feature in the HPGL documents.5One or more Items shall be included in this sequence.iRequired if 3D Mating Point (0068,64C0) is not present and HPGL Document Sequence (0068,62C0) is present.kMay be present if 3D Mating Point (0068,64C0) is present and HPGL Document Sequence (0068,62C0) is present.   desc&2D Mating Feature Coordinates Sequence   name
(Generic Implant Template Mating Features   module+   (0068,63b0)[<0>](0068,63e0)[<1>](0068,6430)   
U   usage   %
   mod_tables
Implant Template   entity1   req   %The description of the Surface Model.5One or more Items shall be included in this sequence.@Shall contain one Item per Item in Surface Sequence (0066,0002).   desc"Surface Model Description Sequence   name
"Generic Implant Template 3D Models   module   (0068,6360)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   "Time the SOP Instance was created.xThis is the time that the SOP Instance UID was assigned, and does not change during subsequent coercion of the instance.   descInstance Creation Time   name

SOP Common   module   (0008,0013)   
U   usage   \
   mod_tables
Implant Template   entity1C   req   22D coordinates of the point in the HPGL documents.5One or more Items shall be included in this sequence.nRequired if 3D Point Coordinates (0068,6590) is not present and HPGL Document Sequence (0068,62C0) is present.pMay be present if 3D Point Coordinates (0068,6590) is present and HPGL Document Sequence (0068,62C0) is present.   desc2D Point Coordinates Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6500)[<0>](0068,6550)   
U   usage    
   mod_tables
Implant Template   entity3   req   Point landmarks for planning.1One or more Items are permitted in this sequence.   desc Planning Landmark Point Sequence   name
+Generic Implant Template Planning Landmarks   module   (0068,6500)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req   fIndicates, whether the surface represents a solid ("waterproof") object with an outside and an inside.   
variablelist   typeEnumerated Values:   title      YESContains a finite volume   NO Does not contain a finite volume   UNKNOWN*Might or might not contain a finite volume   list   See        select: label	   xrefstylesect_C.27.1.1.4   linkend   attrsxref   el.   descFinite Volume   name
Surface Mesh   module   (0066,0002)[<0>](0066,000e)   
U   usage    t
   mod_tables
Implant Template   entity1   req   (The HPGL document as a byte stream. See        select: label	   xrefstylesect_C.29.1.2.1.2   linkend   attrsxref   el.   descHPGL Document   name
$Generic Implant Template 2D Drawings   module   (0068,62c0)[<0>](0068,6300)   
M   usage    �
   mod_tables
Implant Template   entity1   req      %  A certificate that holds the identity of the entity producing this Digital Signature, that entity's public key or key identifier, and the algorithm and associated parameters with which that public key is to be used. Algorithms allowed are specified in Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el).      
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
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req   0The surfaces that are described within the data.5One or more Items shall be included in this sequence.DThere shall be Number of Surfaces (0066,0001) Items in the sequence.   See        select: label	   xrefstylesect_C.27.1.1.1   linkend   attrsxref   el.   descSurface Sequence   name
Surface Mesh   module   (0066,0002)   
M   usage   ,
   mod_tables
Implant Template   entity1   req�Transfer Syntax used to encode the encrypted content. Only Transfer Syntaxes that explicitly include the VR and use Little Endian encoding shall be used.   desc%Encrypted Content Transfer Syntax UID   name

SOP Common   module   (0400,0500)[<0>](0400,0510)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   tManufacturer's designation of the software version of the equipment that contributed to the composite instance. See        select: label	   xrefstylesect_C.7.5.1.1.3   linkend   attrsxref   el.   descSoftware Versions   name

SOP Common   module   (0018,a001)[<0>](0018,1020)   
M   usage   ,
   mod_tables
Implant Template   entity1   req   'Uniquely identifies the SOP Class. See        select: label	   xrefstylesect_C.12.1.1.1   linkend   attrsxref   el# for further explanation. See also        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descSOP Class UID   name

SOP Common   module   (0008,0016)   
M   usage   ,
   mod_tables
Implant Template   entity1C   req   2Sequence of Items containing encrypted DICOM data.5One or more Items shall be included in this sequence.   �Required if application level confidentiality is needed and certain recipients are allowed to decrypt all or portions of the Encrypted Attributes Data Set. See        select: label	   xrefstylesect_C.12.1.1.4.1   linkend   attrsxref   el.   descEncrypted Attributes Sequence   name

SOP Common   module   (0400,0500)   
M   usage   ,
   mod_tables
Implant Template   entity3   req�Retrieval access path to HL7 Structured Document. Includes fully specified scheme, authority, path, and query in accordance with RFC 2396   descRetrieve URI   name

SOP Common   module   (0040,a390)[<0>](0040,e010)   
U   usage    
   mod_tables
Implant Template   entity3   req(Purpose or intended use of the landmark.   descPlanning Landmark Description   name
+Generic Implant Template Planning Landmarks   module   (0068,6520)[<0>](0068,6540)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity1   req�Number of surfaces contained in the Instance. Shall be 1 or more. Shall be the same as the number of Items in Surface Sequence (0066,0002).   descNumber of Surfaces   name
Surface Mesh   module   (0066,0001)   
M   usage   B
   mod_tables
Implant Template   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name

SOP Common   module   (0020,9172)[<0>](0008,1155)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   rIndicates whether or not the date and time attributes in the instance have been modified during de-identification.   
variablelist   typeEnumerated Values:   title      
UNMODIFIED   MODIFIED   REMOVED   list   See        select: labelnumber	   xrefstylePS3.15	   targetdocPS3.15	   targetptr   attrsolink   el.   desc*Longitudinal Temporal Information Modified   name

SOP Common   module   (0028,0303)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    �
   mod_tables
Surface Mesh   entity3   reqYSource of the algorithm, e.g., the name of the manufacturer, researcher, university, etc.   descAlgorithm Source   name
Surface Mesh   module+   (0066,0002)[<0>](0066,0035)[<1>](0024,0202)   
M   usage    �
   mod_tables
Implant Template   entity3   req   $Sequence holding Digital Signatures.1One or more items are permitted in this sequence.   descDigital Signatures Sequence   name

SOP Common   module   (fffa,fffa)   
EC - Required if Generic Implant Template 3D Models Module is present.   usage    <
   mod_tables
Surface Mesh   entity3   req-User-defined comments describing the surface.   descSurface Comments   name
Surface Mesh   module   (0066,0002)[<0>](0066,0004)   
M   usage   ,
   mod_tables
Implant Template   entity1C   req   ^The view requested during the C-MOVE operation that resulted in the transfer of this instance.   
variablelist   typeEnumerated Values:   title      CLASSIC   ENHANCED   listRequired if the instance has ever been converted from its source form as the result of a C-MOVE operation with a specific view.   descQuery/Retrieve View   name

SOP Common   module   (0008,0053)   
M   usage   ,
   mod_tables
Implant Template   entity2C   req�The coding scheme identifier as defined in an external registry. Required if coding scheme is registered and Coding Scheme UID (0008,010C) is not present.   descCoding Scheme External ID   name

SOP Common   module   (0008,0110)[<0>](0008,0114)   
M   usage   �
   mod_tables
Implant Template   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name

SOP Common   module   (0040,a390)[<0>](0008,1150)   
M   usage   ,
   mod_tables
Implant Template   entity3   req   �Date when the image acquisition device calibration was last changed in any way. Multiple entries may be used for additional calibrations at other times. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descDate of Last Calibration   name

SOP Common   module   (0018,a001)[<0>](0018,1200)   tags