pst012345678      <Can't handle table_8.8-1 (in table_C.12-1 after (0040,A170))GCan't handle table_8.8-1 (in table_C.12-1:table_10-1 after (0040,1101))GCan't handle table_8.8-1 (in table_C.12-1:table_10-1 after (0008,0082))ICan't handle table_8.8-1 (in table_C.12-1:table_C.12-6 after (0400,0401))>Can't handle table_8.8-1 (in table_C.23.1-1 after (0008,2218))>Can't handle table_8.8-1 (in table_C.23.1-1 after (0008,1032))>Can't handle table_8.8-1 (in table_C.23.1-1 after (0040,100A))MCan't handle table_8.8-1 (in table_C.23.1-1:table_C.23.4-2 after (0072,0080))>Can't handle table_8.8-1 (in table_C.23.1-1 after (0072,003E))>Can't handle table_8.8-1 (in table_C.23.1-1 after (0072,000E))MCan't handle table_8.8-1 (in table_C.23.3-1:table_C.23.4-2 after (0072,0080))   errors �      
M   usage   
table_C.23.3-1table_C.23.4-2
   mod_tables
Hanging Protocol   entity1C   req   HThe value of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is UT.   descSelector UT Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0070)   
M   usage   
table_C.23.1-1table_C.23.4-2
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is LO.   descSelector LO Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0066)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is FD.   descSelector FD Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0074)   
M   usage   
table_C.23.3-1
   mod_tables
Hanging Protocol   entity3   req      nType of blending of superimposed and underlying images from the image set, performed before reformatting. See        select: label	   xrefstylesect_C.23.3.1.3   linkend   attrsxref   el.   
variablelist   typeDefined Terms:   title      COLOR=apply a pseudo-color to the superimposed image while blending   list   descBlending Operation Type   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0500)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   HThe value of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is ST.   descSelector ST Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,006e)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   yEach sequence item of this attribute identifies a group of Display Sets to which synchronized scrolling is to be applied.1One or more Items are permitted in this sequence.~The dimensions along which the synchronization occurs shall be those specified in the Sorting Operations Sequence (0072,0600).   descSynchronized Scrolling Sequence   name
Hanging Protocol Display   module   (0072,0210)   
M   usage   
table_C.23.2-2
   mod_tables
Hanging Protocol   entity1   req   hPositive integer indicating the intended number of rows of the addressable area of the screen in pixels.      
                        'The goal is not absolute size matching.   contentpara   el
                   contentnote   el   descNumber of Vertical Pixels   name
Hanging Protocol Environment   module   (0072,0104)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).�Required if Selector Attribute VR (0072,0050) is present and the value is DS. Some leniency in precision and format (including padding and scientific notation) will be required.   descSelector DS Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0072)   
M   usage   
table_C.23.1-1
   mod_tables
Hanging Protocol   entity1   req   �Indicates the behavior of matching against an image object when Selector Attribute (0072,0026) is not available in the image object.   
variablelist   typeEnumerated Values:   title      MATCHUIf the attribute is not in the image object, consider the image to be a match anyway.   NO_MATCHZIf the attribute is not in the image object, then do not consider the image to be a match.   list   descImage Set Selector Usage Flag   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0024)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req8Date and time on which the Hanging Protocol was created.   desc"Hanging Protocol Creation DateTime   name
Hanging Protocol Definition   module   (0072,000a)   
M   usage   
table_C.12-1table_C.12-6
   mod_tables
Hanging Protocol   entity1   req   "The MAC generated as described in        select: label	   xrefstylesect_C.12.1.1.3.1.1   linkend   attrsxref   el and encrypted using the algorithm, parameters, and private key associated with the Certificate of the Signer (0400,0115). See        select: label	   xrefstylesect_C.12.1.1.3.1.2   linkend   attrsxref   el.   desc	Signature   name

SOP Common   module   (fffa,fffa)[<0>](0400,0120)   
M   usage   
table_C.12-1
   mod_tables
Hanging Protocol   entity3   reqYManufacturer's serial number of the equipment that contributed to the composite instance.   descDevice Serial Number   name

SOP Common   module   (0018,a001)[<0>](0018,1000)   
M   usage   
table_C.23.1-1table_C.23.4-1
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Selector Attribute (0072,0026) value is the Data Element Tag of a Private Attribute.   desc"Selector Attribute Private Creator   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0056)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   ,The type of certificate used in (0400,0115).   Defined Terms:   title
variablelist   type      X509_1993_SIG   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descCertificate Type   name

SOP Common   module   (fffa,fffa)[<0>](0400,0110)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   �Indicates direction in which to vertically justify the image within a viewport that is not the same shape (aspect ratio) as the image.   
variablelist   typeEnumerated Values:   title      TOP   CENTER   BOTTOM   list   desc"Display Set Vertical Justification   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0718)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   �The desired spacing of the reformatted images in millimeters. The spacing is measured from the center-to-center of each reconstructed image.fRequired if value of Reformatting Operation Type (0072,0510) is SLAB or MPR. May be present otherwise.   descReformatting Interval   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0514)   
M   usage    >
   mod_tables
Hanging Protocol   entity2C   req   NDefines the type of small increment scrolling to be applied to this Image Box.�Required if the value of Image Box Layout Type (0072,0304) is TILED, and the value of Image Box Tile Horizontal Dimension (0072,0306) or Image Box Tile Vertical Dimension (0072,0308) is greater than 1. Scrolling is not specified if zero length.   
variablelist   typeEnumerated Values:   title      PAGETIn a TILED image box, replace all image slots with the next N x M images in the set.   
ROW_COLUMN�In a TILED image box, move each row or column of images to the next row or column, depending on Image Box Scroll Direction (0072,0310).   IMAGE�In a TILED image box, move each image to the next slot, either horizontally or vertically, depending on Image Box Scroll Direction (0072,0310).   list      
                        �If there are multiple image boxes of different Tile Dimensions in a Display Set, then only IMAGE scrolling applies, and the value of this attribute is ignored.   contentpara   el
                   contentnote   el   descImage Box Small Scroll Type   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0312)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req     Defines the positive integer number of pages, rows, columns, or images per large increment scroll, based on the values of Image Box Large Scroll Type (0072,0316) and Image Box Scroll Direction (0072,0310). The value applies to both forward and backward scrolling.LRequired if Image Box Large Scroll Type (0072,0316) is present with a value.   descImage Box Large Scroll Amount   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0318)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req�The inherent limiting resolution in mm of the acquisition equipment for high contrast objects for the data gathering and reconstruction technique chosen. If variable across the images of the series, the value at the image center.   descSpatial Resolution   name

SOP Common   module   (0018,a001)[<0>](0018,1050)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is PN.   descSelector PN Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,006a)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   oSequence of Items containing all attributes that were removed or replaced by other values in the main data set.1One or more Items are permitted in this sequence.   descOriginal Attributes Sequence   name

SOP Common   module   (0400,0561)   
M   usage   
table_C.12-1
table_10-1
   mod_tables
Hanging Protocol   entity3   reqPerson's mailing address   descPerson's Address   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1102)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   �Sequence containing Image Set selection attributes and values that are used to identify one type of image or object set for the Hanging Protocol.5One or more Items shall be included in this sequence.   See        select: label	   xrefstylesect_C.23.1.1.3   linkend   attrsxref   el.   descImage Set Selector Sequence   name
Hanging Protocol Definition   module   (0072,0020)[<0>](0072,0022)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   HThe value of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is LT.   descSelector LT Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0068)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   &The purpose of this Digital Signature.1Only a single Item is permitted in this sequence.   desc'Digital Signature Purpose Code Sequence   name

SOP Common   module   (fffa,fffa)[<0>](0400,0401)   
M   usage   
table_C.12-1
table_10-3
   mod_tables
Hanging Protocol   entity1C   req   =Identifies the Segment Number to which the reference applies.�Required if the Referenced SOP Instance is a Segmentation or Surface Segmentation and the reference does not apply to all segments and Referenced Frame Number (0008,1160) is not present.   descReferenced Segment Number   name

SOP Common   module   (0020,9172)[<0>](0062,000b)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   HThe value of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is LT.   descSelector LT Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0068)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqmThe certification number issued to the Application Entity that set the SOP Instance Status (0100,0410) to AO.   desc,Authorization Equipment Certification Number   name

SOP Common   module   (0100,0426)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   �Positive integer identifying which value of the attribute identified by Selector Attribute (0072,0026) is to be used for sorting. The value of 1 identifies the first value. Shall not be zero.6Required if Selector Attribute (0072,0026) is present.   descSelector Value Number   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0072,0028)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req   �Exactly four unitless floating point values indicating the rectangular coordinate position of the image box within the overall bounding box that encompasses all the display space (across all screens). See        select: label	   xrefstylesect_C.23.2.1.1   linkend   attrsxref   el.   desc$Display Environment Spatial Position   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0108)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req?Explanation of the objective or intent of the Hanging Protocol.   descHanging Protocol Description   name
Hanging Protocol Definition   module   (0072,0004)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req0May include Sequence Attributes and their Items.   descBAny Attribute from the main data set that was modified or removed.   name

SOP Common   module)   (0400,0561)[<0>](0400,0550)[0](gggg,eeee)   
M   usage    x
   mod_tables
Hanging Protocol   entity1   req   �Exactly four dimensionless floating point values indicating the rectangular coordinate position of the screen within the overall bounding box that encompasses all the screens. See        select: label	   xrefstylesect_C.23.2.1.1   linkend   attrsxref   el.   desc$Display Environment Spatial Position   name
Hanging Protocol Environment   module   (0072,0108)   
M   usage    �
   mod_tables
Hanging Protocol   entity2   req   uSequence that provides a coded identifier for the person, group, or site for which this Hanging Protocol was defined.4Zero or one item shall be included in this sequence.      
                        �If a standardized naming schema becomes available, it should be used. Meanwhile, local coding schemes such as employee numbers and department numbers are likely to be used.   contentpara   el
                   contentnote   el   desc2Hanging Protocol User Identification Code Sequence   name
Hanging Protocol Definition   module   (0072,000e)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req      
variablelist   typeEnumerated Values:   title      VERTICALscroll images by row   
HORIZONTALscroll images by column   list�Required if the value of Image Box Layout Type (0072,0304) is TILED, and the value of Image Box Tile Horizontal Dimension (0072,0306) or Image Box Tile Vertical Dimension (0072,0308) is greater than 1.   descImage Box Scroll Direction   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0310)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   �The SOP Class in which the Instance was originally encoded that has been replaced during a fall-back conversion to the current Related General SOP Class. See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   desc"Original Specialized SOP Class UID   name

SOP Common   module   (0008,001b)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   hExpected value of interest transformation for display (e.g., Window Center and Window Width or VOI LUT).   
variablelist   typeDefined Terms:   title      LUNG   MEDIASTINUM   ABDO_PELVIS   LIVER   SOFT_TISSUE   BONE   BRAIN   
POST_FOSSA   list   descVOI Type   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0702)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   Encrypted data. See        select: label	   xrefstylesect_C.12.1.1.4.2   linkend   attrsxref   el.   descEncrypted Content   name

SOP Common   module   (0400,0500)[<0>](0400,0520)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   HThe value of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is UT.   descSelector UT Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0070)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req:Group or site for which this Hanging Protocol was defined.   desc Hanging Protocol User Group Name   name
Hanging Protocol Definition   module   (0072,0010)   
M   usage    >
   mod_tables
Hanging Protocol   entity2   req   �Sequence that defines sorting criteria to be applied to the result of filter and reformat operations, to define the order in which to present the images in the Image Boxes.6Zero or more items shall be included in this sequence.   See        select: label	   xrefstylesect_C.23.3.1.2   linkend   attrsxref   el.   descSorting Operations Sequence   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0600)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is UL.   descSelector UL Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0078)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqLDescription of the objective of the image set defined by this sequence item.   descImage Set Label   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0030)[<1>](0072,0040)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req    Type of layout of the image box.�All types except for TILED are single rectangles containing a single frame of image pixel data. The types are primarily distinguished by their interaction technique.   
variablelist   typeDefined Terms:   title      TILEDUa scrollable array of rectangles, each containing a single frame of image pixel data.   STACK�a single rectangle containing a steppable single frame, intended for user-controlled stepping through the image set, usually via continuous device interaction (e.g., mouse scrolling) or by single stepping (mouse or button click).   CINE}a single rectangle, intended for video type play back where the user controls are play sequence, rate of play, and direction.   	PROCESSEDGintended for interactive 3D visualizations that have custom interfaces.   SINGLE[a single rectangle, intended for images and objects with no defined methods of interaction.   list      
                        VThis value may also be used for non-image objects, such as waveforms and SR documents.   contentpara   el
                   contentnote   el   descImage Box Layout Type   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0304)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   reqHIdentifies the number of prior image sets used in this Hanging Protocol.   descNumber of Priors Referenced   name
Hanging Protocol Definition   module   (0072,0014)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is US.   descSelector US Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,007a)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req/Identifies the creator of the Hanging Protocol.   descHanging Protocol Creator   name
Hanging Protocol Definition   module   (0072,0008)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   `Sequence that identifies the anatomic region of interest to which this Hanging Protocol applies.5One or more Items shall be included in this sequence.JRequired if Modality (0008,0060) is not present. May be present otherwise.   descAnatomic Region Sequence   name
Hanging Protocol Definition   module   (0072,000c)[<0>](0008,2218)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   �Sequence of Items containing descriptive attributes of related equipment that has contributed to the acquisition, creation or modification of the composite instance.1One or more Items are permitted in this Sequence.   See        select: label	   xrefstylesect_C.12.1.1.5   linkend   attrsxref   el for further explanation.   descContributing Equipment Sequence   name

SOP Common   module   (0018,a001)   
M   usage   
table_C.23.3-1table_C.23.4-1
   mod_tables
Hanging Protocol   entity1C   req   �Contains the Data Element Tag of the Functional Group Sequence that contains the Attribute that is identified by Selector Attribute (0072,0026).�Required if the value of Selector Attribute (0072,0026) is the Data Element Tag of an Attribute that is contained within a Functional Group Sequence.   descFunctional Group Pointer   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0020,9167)   
M   usage    x
   mod_tables
Hanging Protocol   entity1C   req   oPositive integer indicating the desired minimum total number of bits per color channel used to present a pixel.JRequired if Screen Minimum Grayscale Bit Depth (0072,010A) is not present.      
                        _A 24-bit color system with 8 bits per color channel (red, green, blue) would have a value of 8.   contentpara   el
                   contentnote   el   descScreen Minimum Color Bit Depth   name
Hanging Protocol Environment   module   (0072,010c)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   �A list of Data Element Tags in the order they appear in the Data Set that identify the Data Elements used in creating the MAC for the Digital Signature. See        select: label	   xrefstylesect_C.12.1.1.3.1.1   linkend   attrsxref   el.   descData Elements Signed   name

SOP Common   module   (4ffe,0001)[<0>](0400,0020)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqkName of the organization responsible for the Coding Scheme. May include organizational contact information.   desc&Coding Scheme Responsible Organization   name

SOP Common   module   (0008,0110)[<0>](0008,0116)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   |Sequence that contains all the Attributes, with their previous values, that were modified or removed from the main data set.6Only a single Item shall be included in this sequence.   descModified Attributes Sequence   name

SOP Common   module   (0400,0561)[<0>](0400,0550)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   �The date and time the Digital Signature was created. The time shall include an offset (i.e., time zone indication) from Coordinated Universal Time.      
                            �This is not a certified timestamp, and hence is not completely verifiable. An application can compare this date and time with those of other signatures and the validity date of the certificate to gain confidence in the veracity of this date and time.   contentpara   el
                       contentnote   el   descDigital Signature DateTime   name

SOP Common   module   (fffa,fffa)[<0>](0400,0105)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqVInstitution where the equipment that contributed to the composite instance is located.   descInstitution Name   name

SOP Common   module   (0018,a001)[<0>](0008,0080)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is CS.   descSelector CS Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0062)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   WThe algorithm used in generating the MAC to be encrypted to form the Digital Signature.   Defined Terms:   title
variablelist   type      	RIPEMD160   MD5   SHA1   SHA256   SHA384   SHA512   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descMAC Algorithm   name

SOP Common   module   (4ffe,0001)[<0>](0400,0015)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   �The Transfer Syntax UID used to encode the values of the Data Elements included in the MAC calculation. Only Transfer Syntaxes that explicitly include the VR and use Little Endian encoding shall be used.      
                            �Certain Transfer Syntaxes, particularly those that are used with compressed data, allow the fragmentation of the pixel data to change. If such fragmentation changes, Digital Signatures generated with such Transfer Syntaxes could become invalid.   contentpara   el
                       contentnote   el   desc#MAC Calculation Transfer Syntax UID   name

SOP Common   module   (4ffe,0001)[<0>](0400,0010)   
M   usage   �
   mod_tables
Hanging Protocol   entity1C   req�Institution or organization to which the identified individual is responsible or accountable. Required if Institution Code Sequence (0008,0082) is not present.   descInstitution Name   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0080)   
M   usage   �
   mod_tables
Hanging Protocol   entity1C   req   �Identifies the frame numbers within the Referenced SOP Instance to which the reference applies. The first frame shall be denoted as frame number 1.      
                      #This Attribute may be multi-valued.   contentpara   el
                 contentnote   el�Required if the Referenced SOP Instance is a multi-frame image and the reference does not apply to all frames, and Referenced Segment Number (0062,000B) is not present.   descReferenced Frame Number   name

SOP Common   module   (0020,9172)[<0>](0008,1160)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is FL.   descSelector FL Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0076)   
M   usage   
table_C.23.3-1table_10-11
   mod_tables
Hanging Protocol   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0705)[<1>](0008,1155)   
M   usage   
table_C.23.1-1table_10-11
   mod_tables
Hanging Protocol   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Hanging Protocol Definition   module   (0072,0012)[<0>](0008,1150)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   �Exactly two numeric values, indicating the start and end values of a prior range of instance acquisition times relative to the date and time of a current image set. The units shall be specified in Relative Time Units (0072,003A).�The value pair 0\0 shall indicate a current image set. The value pair n\n shall indicate "prior from the instance acquisition time of a current image set by n units".RRequired if the value of Image Set Selector Category (0072,0034) is RELATIVE_TIME.      
                         arabic
   numeration   attrs   
                          
                            �A value pair "1\7" with Relative Time Units (0072,003A) of DAYS would indicate the range "prior by 1 to 7 days before a current image set".   contentpara   el
                       contentlistitem   el
                          
                            NThe VR of this attribute is unsigned, hence future time cannot be represented.   contentpara   el
                       contentlistitem   el
                     contentorderedlist   el
                   contentnote   el   descRelative Time   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0030)[<1>](0072,0038)   
M   usage   �
   mod_tables
Hanging Protocol   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name
Hanging Protocol Definition   module   (0072,0012)[<0>](0008,1155)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   5Identifies a prior image set using coded terminology.6Only a single Item shall be included in this sequence.zRequired if Image Set Selector Category (0072,0034) is ABSTRACT_PRIOR and Abstract Prior Value (0072,003C) is not present.   descAbstract Prior Code Sequence   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0030)[<1>](0072,003e)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Selector Sequence Pointer (0072,0052) value is the Data Element Tag of a Private Attribute.   desc)Selector Sequence Pointer Private Creator   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0054)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   ;The Value Representation of Selector Attribute (0072,0026).}Required if Selector Attribute (0072,0026) or Filter-by Category (0072,0402), and Filter-by Operator (0072,0406) are present.   descSelector Attribute VR   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0050)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   vA monotonically increasing integer, starting from 1, incrementing by one, unique within the Hanging Protocol Instance.      
                        _Each item of the Display Sets Sequence (0072,0200) references one Image Set Number (0072,0032).   contentpara   el
                   contentnote   el   descImage Set Number   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0030)[<1>](0072,0032)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   "Date the SOP Instance was created.xThis is the date that the SOP Instance UID was assigned, and does not change during subsequent coercion of the instance.   descInstance Creation Date   name

SOP Common   module   (0008,0012)   
M   usage   �
   mod_tables
Hanging Protocol   entity1   req   'A coded entry that identifies a person.�  The Code Meaning attribute, though it will be encoded with a VR of LO, may be encoded according to the rules of the PN VR (e.g., caret '^' delimiters shall separate name components), except that a single component (i.e., the whole name unseparated by caret delimiters) is not permitted. Name component groups for use with multi-byte character sets are permitted, as long as they fit within the 64 characters (the length of the LO VR).5One or more Items shall be included in this Sequence.   desc#Person Identification Code Sequence   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1101)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   �Positive integer identifying which value of the attribute identified by Selector Attribute (0072,0026) is to be used for filtering. The value 1 identifies the first value. The value zero identifies any value.ZRequired if Selector Attribute (0072,0026) and Filter-by Operator (0072,0406) are present.   descSelector Value Number   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0028)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   �Describes the preferred playback sequencing for the Image Box. Overrides any Preferred Playback Sequencing (0018,1244) value in the image objects being displayed.CRequired if the value of Image Box Layout Type (0072,0304) is CINE.   
variablelist   typeEnumerated Values:   title      0(Looping (1,2…n,1,2,…n,1,2,….n,…)   1)Sweeping (1,2,…n,n-1,…2,1,2,…n,…)   2Stop (1,2…n)   list   descPreferred Playback Sequencing   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0018,1244)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req      OData Element Tag of an Attribute from an Image IOD to be used for sorting. See        select: label	   xrefstylesect_C.23.3.1.2   linkend   attrsxref   el for potential attributes.8Required if Sort-by Category (0072,0602) is not present.   descSelector Attribute   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0072,0026)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req      &Category of the filter operation. See        select: label	   xrefstylesect_C.23.3.1.1   linkend   attrsxref   el.   
variablelist   typeDefined Terms:   title      IMAGE_PLANE   list:Required if Selector Attribute (0072,0026) is not present.   descFilter-by Category   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0402)   
M   usage    x
   mod_tables
Hanging Protocol   entity1C   req   aPositive integer indicating the desired minimum number of grayscale bits per pixel of the screen.FRequired if Screen Minimum Color Bit Depth (0072,010C) is not present.   desc"Screen Minimum Grayscale Bit Depth   name
Hanging Protocol Environment   module   (0072,010a)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req[Data Element Tag of an Attribute from an Image or other IOD to use for Image Set selection.   descSelector Attribute   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0026)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqeAddress of the institution where the equipment that contributed to the composite instance is located.   descInstitution Address   name

SOP Common   module   (0018,a001)[<0>](0008,0081)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   reqsA number used to identify which MAC Parameters Sequence item was used in the calculation of this Digital Signature.   descMAC ID Number   name

SOP Common   module   (fffa,fffa)[<0>](0400,0005)   
M   usage   
table_C.12-1table_10-11
   mod_tables
Hanging Protocol   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name

SOP Common   module   (0040,a390)[<0>](0008,1155)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   �Recommended rate at which the frames of a multi-frame image shall be displayed, in frames/second. Shall have a value greater than zero. Overrides any Recommended Display Frame Rate (0008,2144) value in the image objects being displayed.�Required if the value of Image Box Layout Type (0072,0304) is CINE and if Cine Relative to Real-Time (0072,0330) is not present.   descRecommended Display Frame Rate   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0008,2144)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   reqZThe value of a Coding Scheme Designator, used in this SOP Instance, which is being mapped.   descCoding Scheme Designator   name

SOP Common   module   (0008,0110)[<0>](0008,0102)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req�The coding scheme UID identifier. Required if coding scheme is identified by an ISO 8824 object identifier compatible with the UI VR.   descCoding Scheme UID   name

SOP Common   module   (0008,0110)[<0>](0008,010c)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   KDate and time that the SOP Instance was last coerced by a Storage SCP (see        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el).   descInstance Coercion DateTime   name

SOP Common   module   (0008,0015)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is US.   descSelector US Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,007a)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   IDescribes the purpose for which the related equipment is being reference.6Only a single Item shall be included in this sequence.   See        select: label	   xrefstylesect_C.12.1.1.5   linkend   attrsxref   el for further explanation.   desc"Purpose of Reference Code Sequence   name

SOP Common   module   (0018,a001)[<0>](0040,a170)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   tSequence that identifies the Hanging Protocol from which this Hanging Protocol was derived, or on which it is based.1Only a single Item is permitted in this sequence.   desc Source Hanging Protocol Sequence   name
Hanging Protocol Definition   module   (0072,0012)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   gA sequence of items that describe the parameters used to calculate a MAC for use in Digital Signatures.5One or more Items shall be included in this sequence.   descMAC Parameters Sequence   name

SOP Common   module   (4ffe,0001)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req      'Category of the sorting operation. See        select: label	   xrefstylesect_C.23.3.1.2   linkend   attrsxref   el.   
variablelist   typeDefined Terms:   title      
ALONG_AXIS,for CT, MR, other cross-sectional image sets   BY_ACQ_TIME   list:Required if Selector Attribute (0072,0026) is not present.   descSort-by Category   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0072,0602)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqSThe coding scheme version associated with the Coding Scheme Designator (0008,0102).   descCoding Scheme Version   name

SOP Common   module   (0008,0110)[<0>](0008,0103)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is AT.   descSelector AT Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0060)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   @Identification of the operator(s) of the contributing equipment.1One or more items are permitted in this sequence.|The number and order of Items shall correspond to the number and order of values of Operators' Name (0008,1070), if present.   desc Operator Identification Sequence   name

SOP Common   module   (0018,a001)[<0>](0008,1072)   
M   usage    >
   mod_tables
Hanging Protocol   entity2   req   �If one or more Image Sets identified by Image Set Number (0072,0032) in the Display Sets Sequence (0072,0200) Items is not available, indicate whether or not to maintain the expected layout in the absence of complete Image Sets.   
variablelist   typeEnumerated Values:   title      MAINTAIN_LAYOUTWIf one or more Image Sets is not available, maintain the layout with empty Image Boxes.   ADAPT_LAYOUTfIf one or more Image Sets is not available, rearrange the layout at the discretion of the application.   listLIf this attribute is zero length, then the expected behavior is not defined.   descPartial Data Display Handling   name
Hanging Protocol Display   module   (0072,0208)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   �Indicates whether or not to display images with the physical size of the rendered image pixel the same on the screen as specified in the image attributes, unless overridden by a Presentation State instance.   
variablelist   typeEnumerated Values:   title      YESDisplay images at True Size.   NO#The rendered size is not specified.   list   descShow Image True Size Flag   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0710)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   �The type of certified timestamp used in Certified Timestamp (0400,0310). Required if Certified Timestamp (0400,0310) is present.   Defined Terms:   title
variablelist   type      CMS_TSP<Internet X.509 Public Key Infrastructure Time Stamp Protocol   list      
                            )Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el<) may require the use of a restricted subset of these terms.   contentpara   el
                       contentnote   el   descCertified Timestamp Type   name

SOP Common   module   (fffa,fffa)[<0>](0400,0305)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req      �The value(s) of the attribute identified by Selector Attribute (0072,0026). One or more Items shall be included in this sequence. See        select: label	   xrefstylesect_C.23.4.2.1.2   linkend   attrsxref   el.�Required if Selector Attribute VR (0072,0050) is present and the value is SQ, and Selector Attribute (0072,0026) is a code sequence.   descSelector Code Sequence Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0080)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqIThe date and time when the SOP Instance Status (0100,0410) was set to AO.   descSOP Authorization DateTime   name

SOP Common   module   (0100,0420)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req9Name(s) of the operator(s) of the contributing equipment.   descOperators' Name   name

SOP Common   module   (0018,a001)[<0>](0008,1070)   
M   usage   
table_C.23.3-1table_C.23.4-1
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Selector Sequence Pointer (0072,0052) value is the Data Element Tag of a Private Attribute.   desc)Selector Sequence Pointer Private Creator   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0072,0054)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is SS.   descSelector SS Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,007e)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req   �Sorting direction to be applied to the value(s) in the image set of the attribute identified by Selector Attribute (0072,0026) or Sort-by Category (0072,0602).   
variablelist   typeEnumerated Values:   title      
INCREASING   
DECREASING   list   descSorting Direction   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0072,0604)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   XUniquely identifies a Related General SOP Class for the SOP Class of this Instance. See        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descRelated General SOP Class UID   name

SOP Common   module   (0008,001a)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   �Describes the intended 3D rendering type. One or more values shall be present. The first value shall not be zero length. Required if the value of Reformatting Operation Type (0072,0510) is 3D_RENDERING:   
variablelist   typeDefined Terms for Value 1:   title      MIP   SURFACE   VOLUME   listLAdditional values may be used to identify implementation specific sub-types.   desc3D Rendering Type   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0520)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   Contains the Data Element Tag of the Sequence that contains the Attribute that is identified by Selector Attribute (0072,0026).�Required if Selector Attribute (0072,0026) is nested in a Sequence. Shall not be used to identify code sequence attributes. See Selector Code Sequence Value (0072,0080).   descSelector Sequence Pointer   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0052)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is FL.   descSelector FL Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0076)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   eA positive unitless floating point numeric factor equal to playback rate divided by acquisition rate.�Required if the value of Image Box Layout Type (0072,0304) is CINE and if Recommended Display Frame Rate (0008,2144) is not present.      
                        }The capture rate may change within the image object, as specified in Frame Time (0018,1063) or Frame Time Vector (0018,1065).   contentpara   el
                   contentnote   el   descCine Relative to Real-Time   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0330)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   *Uniquely identifies the SOP Instance. See        select: label	   xrefstylesect_C.12.1.1.1   linkend   attrsxref   el# for further explanation. See also        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descSOP Instance UID   name

SOP Common   module   (0008,0018)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req�  Positive integer value that designates this Display Set as part of a specific presentation group. All Display Sets with the same Display Set Presentation Group (0072,0204) value shall be displayed at the same time. The value 1 shall indicate that this Display Set is part of the initial presentation group. Subsequent values incrementing by 1 shall imply successive temporal ordering of display.   descDisplay Set Presentation Group   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0204)   
M   usage   �
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Functional Group Pointer (0020,9167) value is the Data Element Tag of a Private Attribute.   desc Functional Group Private Creator   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0020,9238)   
M   usage    >
   mod_tables
Hanging Protocol   entity2   req   pSequence that defines filter criteria to be applied to the image set identified by Image Set Number (0072,0032).6Zero or more items shall be included in this sequence.   See        select: label	   xrefstylesect_C.23.3.1.1   linkend   attrsxref   el.   descFilter Operations Sequence   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0400)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req�A monotonically increasing integer that identifies the order of image boxes for scrolling, starting from 1, incrementing by one, unique within a Display Set Sequence Item.   descImage Box Number   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0302)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req9Uniquely identifies device that created the SOP Instance.   descInstance Creator UID   name

SOP Common   module   (0008,0014)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).�Required if Selector Attribute VR (0072,0050) is present and the value is DS. Some leniency in precision and format (including padding and scientific notation) will be required.   descSelector DS Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0072)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   HThe value of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is ST.   descSelector ST Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,006e)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is SL.   descSelector SL Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,007c)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   �If this Image Box overlaps in spatial position with others, this attribute indicates the layer of this Image Box in relation to the others. The value shall be a positive integer in the range 1 to 100, where 1 = top and 100 = bottom.LIf this attribute is not present, then the expected behavior is not defined.   descImage Box Overlap Priority   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0320)   
M   usage   �
   mod_tables
Hanging Protocol   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0705)[<1>](0008,1150)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req   Sequence that describes one or more display sets used to present the Image Sets defined in the Image Sets Sequence (0072,0020).5One or more Items shall be included in this sequence.   See        select: label	   xrefstylesect_C.23.3.1   linkend   attrsxref   el.   descDisplay Sets Sequence   name
Hanging Protocol Display   module   (0072,0200)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   �Indicates whether or not to display items from the Graphic Annotation Sequence (0070,0001) in an applied Presentation State, and the attributes of the Overlay Plane module in the image objects or applied Presentation State.   
variablelist   typeEnumerated Values:   title      YES   NO   list   descShow Graphic Annotation Flag   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0712)   
M   usage   
   mod_tables
Hanging Protocol   entity1C   req   Contains the Data Element Tag of the Sequence that contains the Attribute that is identified by Selector Attribute (0072,0026).�Required if Selector Attribute (0072,0026) is nested in a Sequence. Shall not be used to identify code sequence attributes. See Selector Code Sequence Value (0072,0080).   descSelector Sequence Pointer   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0072,0052)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   XThe set of images or other composite SOP Instances that were converted to this instance.zIf this instance was converted from a specific frame in the source instance, the reference shall include the Frame Number.5One or more Items shall be included in this sequence.�Required if this instance was created by conversion, and Conversion Source Attributes Sequence (0020,9172) is not present in an Item of Shared Functional Groups Sequence (5200,9229) or Per-Frame Functional Groups Sequence (5200,9230).   desc%Conversion Source Attributes Sequence   name

SOP Common   module   (0020,9172)   
M   usage   �
   mod_tables
Hanging Protocol   entity1C   req   �Institution or organization to which the identified individual is responsible or accountable. Required if Institution Name (0008,0080) is not present.6Only a single Item shall be included in this Sequence.   descInstitution Code Sequence   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0082)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   VPatient direction of the rows and columns of the images, as intended for display. See        select: label	   xrefstylesect_C.23.3.1.4   linkend   attrsxref   el.   descDisplay Set Patient Orientation   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0700)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   �Sequence of items that map values of Coding Scheme Designator (0008,0102) to an external coding system registration, or to a private or local coding scheme.1One or more Items are permitted in this sequence.   desc%Coding Scheme Identification Sequence   name

SOP Common   module   (0008,0110)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is AT.   descSelector AT Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0060)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).�Required if Selector Attribute VR (0072,0050) is present and the value is IS. Some leniency in precision and format (including padding with spaces and leading zeros, e.g., "001" = " 1 " = "1") will be required.   descSelector IS Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0064)   
M   usage    �
   mod_tables
Hanging Protocol   entity2   req   WSequence that identifies a reason for procedure to which this Hanging Protocol applies.6Zero or more Items shall be included in this sequence.   desc,Reason for Requested Procedure Code Sequence   name
Hanging Protocol Definition   module   (0072,000c)[<0>](0040,100a)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   'Initial view of the reformatted images.rRequired if the value of Reformatting Operation Type (0072,0510) is MPR or 3D_RENDERING. May be present otherwise.   
variablelist   typeDefined Terms:   title      SAGITTAL   
TRANSVERSE   CORONAL   OBLIQUE   list   desc-Reformatting Operation Initial View Direction   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0516)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   �Display Set Number (0072,0202) of the Display Set where the geometric relationship to the Reference Display Sets (0072,0218) is graphically depicted.�Required if there is a one-way interaction such that the location of the Reference Display Sets is indicated on or controlled by the Navigation Display Set.      
                        �For example, the graphical representation may indicate either the number of slices displayed or contained in the Reference Display Set(s).   contentpara   el
                   contentnote   el   descNavigation Display Set   name
Hanging Protocol Display   module   (0072,0214)[<0>](0072,0216)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   &Reason for the attribute modification.   
variablelist   typeDefined Terms:   title      COERCE�Replace values of attributes such as Patient Name, ID, Accession Number, for example, during import of media from an external institution, or reconciliation against a master patient index.   CORRECT�Replace incorrect values, such as Patient Name or ID, for example, when incorrect worklist item was chosen or operator input error.   list   desc%Reason for the Attribute Modification   name

SOP Common   module   (0400,0561)[<0>](0400,0565)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   rTime when the image acquisition device calibration was last changed in any way. Multiple entries may be used. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descTime of Last Calibration   name

SOP Common   module   (0018,a001)[<0>](0018,1201)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqUUser defined name identifying the machine that contributed to the composite instance.   descStation Name   name

SOP Common   module   (0018,a001)[<0>](0008,1010)   
M   usage    �
   mod_tables
Hanging Protocol   entity2   req   LSequence that identifies a procedure to which this Hanging Protocol applies.6Zero or more Items shall be included in this sequence.   descProcedure Code Sequence   name
Hanging Protocol Definition   module   (0072,000c)[<0>](0008,1032)   
M   usage    �
   mod_tables
Hanging Protocol   entity2C   req   CLaterality of the body part to which this Hanging Protocol applies.   
variablelist   typeEnumerated Values:   title      RRight   LLeft   BBoth   UUnpaired   list!Zero length means not applicable.<Required if Anatomic Region Sequence (0008,2218) is present.   desc
Laterality   name
Hanging Protocol Definition   module   (0072,000c)[<0>](0020,0060)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is FD.   descSelector FD Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0074)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   �A certified timestamp of the Digital Signature (0400,0120) Attribute Value, which shall be obtained when the Digital Signature is created. See        select: label	   xrefstylesect_C.12.1.1.3.1.3   linkend   attrsxref   el.   descCertified Timestamp   name

SOP Common   module   (fffa,fffa)[<0>](0400,0310)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).�Required if Selector Attribute VR (0072,0050) is present and the value is IS. Some leniency in precision and format (including padding with spaces and leading zeros, e.g., "001" = " 1 " = "1") will be required.   descSelector IS Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0064)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req"The coding scheme full common name   descCoding Scheme Name   name

SOP Common   module   (0008,0110)[<0>](0008,0115)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqVManufacturer's model name of the equipment that contributed to the composite instance.   descManufacturer's Model Name   name

SOP Common   module   (0018,a001)[<0>](0008,1090)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   �A category of pseudo-color palette choice to be applied after application of the VOI LUT. If this attribute is not present, a pseudo-color palette shall not be applied.   lDefined Terms are the values of Content Label (0070,0080) in the list of standard color palettes defined in        select: labelnumber	   xrefstylePS3.6	   targetdocPS3.6	   targetptr   attrsolink   el Well-Known Color Palettes.   descPseudo-Color Type   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0704)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   QIndicates whether or not to display patient and study identification information.   
variablelist   typeEnumerated Values:   title      YES   NO   list   descShow Patient Demographics Flag   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0714)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   .Category of the Time Based Image Set selector.   
variablelist   typeEnumerated Values:   title      RELATIVE_TIME   ABSTRACT_PRIOR   list   descImage Set Selector Category   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0030)[<1>](0072,0034)   
M   usage   
   mod_tables
Hanging Protocol   entity1C   req   �Contains the Data Element Tag of the Functional Group Sequence that contains the Attribute that is identified by Selector Attribute (0072,0026).�Required if the value of Selector Attribute (0072,0026) is the Data Element Tag of an Attribute that is contained within a Functional Group Sequence.   descFunctional Group Pointer   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0020,9167)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is SH.   descSelector SH Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,006c)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is UL.   descSelector UL Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0078)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   /Identifies a prior image set in abstract terms.  Exactly two integer values, indicating the range of prior studies to include. Each value shall be greater than zero, where 1 indicates the most recent prior and higher values indicate successively older priors. The special value -1 shall indicate the oldest prior.      
                         arabic
   numeration   attrs   
                          
                            +The value pair n\n indicates the nth prior.   contentpara   el
                       contentlistitem   el
                          
                            0The value pair -1\-1 indicates the oldest prior.   contentpara   el
                       contentlistitem   el
                          
                            ZThe value pair m\n indicates the mth through nth priors, where m is the more recent prior.   contentpara   el
                       contentlistitem   el
                          
                            )The value pair 1\-1 indicates all priors.   contentpara   el
                       contentlistitem   el
                          
                            HThe value pair m\-1 indicates the mth prior and all priors older than m.   contentpara   el
                       contentlistitem   el
                     contentorderedlist   el
                   contentnote   el�Required if Image Set Selector Category (0072,0034) is ABSTRACT_PRIOR and Abstract Prior Code Sequence (0072,003E) is not present.   descAbstract Prior Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0030)[<1>](0072,003c)   
M   usage    �
   mod_tables
Hanging Protocol   entity2   req�The source that provided the SOP Instance prior to the removal or replacement of the values. For example, this might be the Institution from which imported SOP Instances were received.   descSource of Previous Values   name

SOP Common   module   (0400,0561)[<0>](0400,0564)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   �Contains the Data Element Tag of the Functional Group Sequence that contains the Attribute that is identified by Selector Attribute (0072,0026).�Required if the value of Selector Attribute (0072,0026) is the Data Element Tag of an Attribute that is contained within a Functional Group Sequence.   descFunctional Group Pointer   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0020,9167)   
M   usage   �
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Selector Attribute (0072,0026) value is the Data Element Tag of a Private Attribute.   desc"Selector Attribute Private Creator   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0056)   
M   usage   �
   mod_tables
Hanging Protocol   entity1C   req   Contains the Data Element Tag of the Sequence that contains the Attribute that is identified by Selector Attribute (0072,0026).�Required if Selector Attribute (0072,0026) is nested in a Sequence. Shall not be used to identify code sequence attributes. See Selector Code Sequence Value (0072,0080).   descSelector Sequence Pointer   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0052)   
M   usage   �
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Selector Sequence Pointer (0072,0052) value is the Data Element Tag of a Private Attribute.   desc)Selector Sequence Pointer Private Creator   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0054)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqhDepartment in the institution where the equipment that contributed to the composite instance is located.   descInstitutional Department Name   name

SOP Common   module   (0018,a001)[<0>](0008,1040)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Functional Group Pointer (0020,9167) value is the Data Element Tag of a Private Attribute.   desc Functional Group Private Creator   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0020,9238)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   �Operation to be applied based on the presence or absence of the attribute represented by Selector Attribute (0072,0026) in each image of the Image Set.hRequired if Selector Attribute (0072,0026) is present and Filter-by Operator (0072,0406) is not present.   
variablelist   typeEnumerated Values:   title      PRESENT.Include the image if the attribute is present.   NOT_PRESENT2Include the image if the attribute is not present.   list   descFilter-by Attribute Presence   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0404)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   �Contains the offset from UTC to the timezone for all DA and TM Attributes present in this SOP Instance, and for all DT Attributes present in this SOP Instance that do not contain an explicitly encoded timezone offset.�Encoded as an ASCII string in the format "&ZZXX". The components of this string, from left to right, are & = "+" or "-", and ZZ = Hours and XX = Minutes of offset. Leading space characters shall not be present.;The offset for UTC shall be +0000; -0000 shall not be used.      
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
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req      KData Element Tag of an Attribute from an Image IOD to use as a filter. See        select: label	   xrefstylesect_C.23.3.1.1   linkend   attrsxref   el for potential attributes.:Required if Filter-by Category (0072,0402) is not present.   descSelector Attribute   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0026)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   reqIIdentification of the system that removed and/or replaced the attributes.   descModifying System   name

SOP Common   module   (0400,0561)[<0>](0400,0563)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req<A UID that can be used to uniquely reference this signature.   descDigital Signature UID   name

SOP Common   module   (fffa,fffa)[<0>](0400,0100)   
M   usage   �
   mod_tables
Hanging Protocol   entity3   reqtMailing address of the institution or organization to which the identified individual is responsible or accountable.   descInstitution Address   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0008,0081)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   ,Units of time for Relative Time (0072,0038).   
variablelist   typeEnumerated Values:   title      SECONDS   MINUTES   HOURS   DAYS   WEEKS   MONTHS   YEARS   list1Required if Relative Time (0072,0038) is present.   descRelative Time Units   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0030)[<1>](0072,003a)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is PN.   descSelector PN Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,006a)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   ZSequence describing one or more types of Image Sets to which the Hanging Protocol applies.5One or more Items shall be included in this sequence.   See        select: label	   xrefstylesect_C.23.1.1.2   linkend   attrsxref   el.   descImage Sets Sequence   name
Hanging Protocol Definition   module   (0072,0020)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req   2One or more Display Set Number (0072,0202) values.�If Navigation Display Set is present, shall list those Display Sets that are controlled by or indicated on the Navigation Display Set.vIf Navigation Display Set is absent, shall indicate that all of the Reference Display Sets cross-reference each other.   descReference Display Sets   name
Hanging Protocol Display   module   (0072,0214)[<0>](0072,0218)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req      �The value(s) of the attribute identified by Selector Attribute (0072,0026). One or more Items shall be included in this sequence. See        select: label	   xrefstylesect_C.23.4.2.1.2   linkend   attrsxref   el.�Required if Selector Attribute VR (0072,0050) is present and the value is SQ, and Selector Attribute (0072,0026) is a code sequence.   descSelector Code Sequence Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0080)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqIThe Date & Time when the equipment contributed to the composite instance.   descContribution DateTime   name

SOP Common   module   (0018,a001)[<0>](0018,a002)   
M   usage    x
   mod_tables
Hanging Protocol   entity3   req   �Positive integer indicating the desired maximum time in milliseconds required by the application to repaint the full screen once (i.e., recalculate all pixels and paint them to the screen).      
                        $This is not the screen refresh time.   contentpara   el
                   contentnote   el   desc Application Maximum Repaint Time   name
Hanging Protocol Environment   module   (0072,010e)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req8A number that identifies this Composite object instance.   descInstance Number   name

SOP Common   module   (0020,0013)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req      �Type of equipment that originally acquired the data used to create images or related objects to which this Hanging Protocol applies. See        select: label	   xrefstylesect_C.7.3.1.1.1   linkend   attrsxref   el for Defined Terms.ZRequired if Anatomic Region Sequence (0008,2218) is not present. May be present otherwise.   descModality   name
Hanging Protocol Definition   module   (0072,000c)[<0>](0008,0060)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req      MWhether or not to invert the rendered luminance of the displayed values. See        select: label	   xrefstylesect_C.23.3.1.4   linkend   attrsxref   el.   
variablelist   typeEnumerated Values:   title      YES}The maximum output value after the display pipeline has been applied shall be displayed with the minimum available luminance.   NO}The maximum output value after the display pipeline has been applied shall be displayed with the maximum available luminance.   list      
                         arabic
   numeration   attrs   
                          
                            �The YES and NO values of this Attribute correspond to the Presentation LUT Shape (2050,0020) values of INVERSE and IDENTITY, as described in        select: label	   xrefstylesect_C.11.6.1.2   linkend   attrsxref   el.   contentpara   el
                       contentlistitem   el
                          
                            /Only applicable to display of grayscale images.   contentpara   el
                       contentlistitem   el
                     contentorderedlist   el
                   contentnote   el   descShow Grayscale Inverted   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0706)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   UIdentifies the level at which this Hanging Protocol is defined, and the intended use.   
variablelist   typeEnumerated Values:   title      MANUFACTURER   SITE   
USER_GROUP   SINGLE_USER   list   descHanging Protocol Level   name
Hanging Protocol Definition   module   (0072,0006)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is SH.   descSelector SH Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,006c)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   YPositive integer defining the horizontal Image Box tile dimension; the number of columns.DRequired if the value of Image Box Layout Type (0072,0304) is TILED.   desc#Image Box Tile Horizontal Dimension   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0306)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   reqIManufacturer of the equipment that contributed to the composite instance.   descManufacturer   name

SOP Common   module   (0018,a001)[<0>](0008,0070)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req�A number, unique within this SOP Instance, used to identify this MAC Parameters Sequence (4FFE,0001) item from an Item of the Digital Signatures Sequence (FFFA,FFFA).   descMAC ID Number   name

SOP Common   module   (4ffe,0001)[<0>](0400,0005)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   |Describes a geometric relationship between Display Sets for the purpose of static or interactive localization or navigation.1One or more Items are permitted in this sequence.   descNavigation Indicator Sequence   name
Hanging Protocol Display   module   (0072,0214)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req     Defines the positive integer number of pages, rows, columns, or images per small increment scroll, based on the values of Image Box Small Scroll Type (0072,0312) and Image Box Scroll Direction (0072,0310). The value applies to both forward and backward scrolling.LRequired if Image Box Small Scroll Type (0072,0312) is present with a value.   descImage Box Small Scroll Amount   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0314)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is CS.   descSelector CS Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0062)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   �The name of the external registry where further definition of the identified coding scheme may be obtained. Required if coding scheme is registered.   
variablelist   typeDefined Terms:   title      HL7   list   descCoding Scheme Registry   name

SOP Common   module   (0008,0110)[<0>](0008,0112)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   =Character Set that expands or replaces the Basic Graphic Set.=Required if an expanded or replacement character set is used.   See        select: label	   xrefstylesect_C.12.1.1.2   linkend   attrsxref   el for Defined Terms.   descSpecific Character Set   name

SOP Common   module   (0008,0005)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   �Sequence containing time based Image Set selection categories and values that are used to identify one type of image set for the Hanging Protocol per sequence item.5One or more Items shall be included in this sequence.   oThe Image Set Selector Sequence (0072,0022) shall be applied to each sequence item to define an image set. See        select: label	   xrefstylesect_C.23.1.1.2   linkend   attrsxref   el.   descTime Based Image Sets Sequence   name
Hanging Protocol Definition   module   (0072,0020)[<0>](0072,0030)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req6Short descriptor that identifies the Hanging Protocol.   descHanging Protocol Name   name
Hanging Protocol Definition   module   (0072,0002)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is SS.   descSelector SS Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,007e)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req:Date and time the attributes were removed and/or replaced.   descAttribute Modification DateTime   name

SOP Common   module   (0400,0561)[<0>](0400,0562)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   TPositive integer defining the vertical Image Box tile dimension; the number of rows.DRequired if the value of Image Box Layout Type (0072,0304) is TILED.   desc!Image Box Tile Vertical Dimension   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0308)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   =A flag that indicates the storage status of the SOP Instance.   
variablelist   typeEnumerated Values:   title      NSwNot Specified; implies that this SOP Instance has no special storage status, and hence no special actions need be taken   OR�Original; implies that this is the primary SOP instance for the purpose of storage, but that it has not yet been authorized for diagnostic use   AO�Authorized Original; implies that this is the primary SOP instance for the purpose of storage, which has been authorized for diagnostic use   AC�Authorized Copy; implies that this is a copy of an Authorized Original SOP Instance; any copies of an Authorized Original should be given the status of Authorized Copy   list      
                        �Proper use of these flags is specified in Security Profiles. Implementations that do not conform to such Security Profiles may not necessarily handle these flags properly.   contentpara   el
                   contentnote   el   descSOP Instance Status   name

SOP Common   module   (0100,0410)   
M   usage   
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Selector Attribute (0072,0026) value is the Data Element Tag of a Private Attribute.   desc"Selector Attribute Private Creator   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0072,0056)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   ?The desired thickness of the reformatted images in millimeters.fRequired if value of Reformatting Operation Type (0072,0510) is SLAB or MPR. May be present otherwise.   descReformatting Thickness   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0512)   
M   usage   �
   mod_tables
Hanging Protocol   entity3   reqPerson's telephone number(s)   descPerson's Telephone Numbers   name

SOP Common   module+   (0018,a001)[<0>](0008,1072)[<1>](0040,1103)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   YSequence that defines the type of imaging studies to which this Hanging Protocol applies.5One or more Items shall be included in this sequence.   See        select: label	   xrefstylesect_C.23.1.1.1   linkend   attrsxref   el.   desc$Hanging Protocol Definition Sequence   name
Hanging Protocol Definition   module   (0072,000c)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqMDescription of the contribution the equipment made to the composite instance.   descContribution Description   name

SOP Common   module   (0018,a001)[<0>](0018,a003)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req   ]Reference to a Color Palette Storage Instance to be applied after application of the VOI LUT.6Only a single Item shall be included in this sequence.MThe Referenced SOP Class UID (0008,1150) shall be "1.2.840.10008.5.1.4.39.1".   �If the value of Pseudo-Color Type (0072,0704) is a reference to the Content Label (0070,0080) of a standard palette, the Referenced SOP Instance UID (0008,1155) shall be the corresponding Well-known SOP Instance UID defined in        select: labelnumber	   xrefstylePS3.6	   targetdocPS3.6	   targetptr   attrsolink   el.�Required if Pseudo-Color Type (0072,0704) is a reference to a standard palette. May be present otherwise if Pseudo-Color Type (0072,0704) is present.   desc0Pseudo-Color Palette Instance Reference Sequence   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0705)   
M   usage   
table_C.12-1
table_10-3table_10-11
   mod_tables
Hanging Protocol   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name

SOP Common   module   (0020,9172)[<0>](0008,1150)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req�Instance Identifier of the referenced HL7 Structured Document, encoded as a UID (OID or UUID), concatenated with a caret ("^") and Extension value (if Extension is present in Instance Identifier).   descHL7 Instance Identifier   name

SOP Common   module   (0040,a390)[<0>](0040,e001)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req�Multi-valued list of two or more Display Set Number (0072,0202) values. Indicates that the images within the specified Display Sets are scrolled in parallel, to maintain the established synchronization.   descDisplay Set Scrolling Group   name
Hanging Protocol Display   module   (0072,0210)[<0>](0072,0212)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   ,  Sequence of items defining mapping between HL7 Instance Identifiers of unencapsulated HL7 Structured Documents referenced from the current SOP Instance as if they were DICOM Composite SOP Class Instances defined by SOP Class and Instance UID pairs. May also define a means of accessing the Documents.5One or more Items shall be included in this sequence.   See        select: label	   xrefstylesect_C.12.1.1.6   linkend   attrsxref   el.�Required if unencapsulated HL7 Structured Documents are referenced within the Instance. Every such document so referenced is required to have a corresponding Item in this Sequence.   desc*HL7 Structured Document Reference Sequence   name

SOP Common   module   (0040,a390)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   reqVAny comments associated with the setting of the SOP Instance Status (0100,0410) to AO.   descSOP Authorization Comment   name

SOP Common   module   (0100,0424)   
M   usage    >
   mod_tables
Hanging Protocol   entity1C   req      "  Operation to be applied between the value(s) in the Hanging Protocol Selector Attribute Value Macro ("selector"), and the value(s) of the attribute identified by Selector Attribute (0072,0026) (or the value implied by the Filter-by Category (0072,0402)) in each image of the Image Set. See        select: label	   xrefstylesect_C.23.3.1.1   linkend   attrsxref   el.�Required if Filter-by Category (0072,0402) is present, or if Selector Attribute (0072,0026) is present and Filter-by Attribute Presence (0072,0404) is not present.   
variablelist   typeEnumerated Values:   title      
RANGE_INCL�all values lie within the specified range, or are equal to the endpoints; applies only to numeric Selector Attribute (0072,0026) values; two values shall be present in the selector, the first of which is less than or equal to the second   
RANGE_EXCL�all values lie outside the specified range, and are not equal to the endpoints; applies only to numeric Selector Attribute (0072,0026) values; two values shall be present in the selector, the first of which is less than or equal to the second   GREATER_OR_EQUALyall values are greater than or equal to the value of the selector; applies only to numeric Selector Attribute (0072,0026)   LESS_OR_EQUALvall values are less than or equal to the value of the selector; applies only to numeric Selector Attribute (0072,0026)   GREATER_THANmall values are greater than the value of the selector; applies only to numeric Selector Attribute (0072,0026)   	LESS_THANjall values are less than the value of the selector; applies only to numeric Selector Attribute (0072,0026)   	MEMBER_OF�one of the values in the image is present in the values of the selector; if one value is present in each, this is an "equal to" operator   NOT_MEMBER_OF�none of the values in the image is present in the values of the selector; if one value is present in each, this is a "not equal to" operator   list   descFilter-by Operator   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0406)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req   �Image Set Number (0072,0032) value from a Time Based Image Sets Sequence (0072,0030) Item within the Image Sets Sequence (0072,0020) Item that is selected for display by this Display Set.      
                        �Multiple Image Boxes Sequence (0072,0300) Items within a Display Sets Sequence (0072,0200) Item may be used to spread one image set over multiple image boxes with the same Display Set characteristics.   contentpara   el
                   contentnote   el   descImage Set Number   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0032)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   "Time the SOP Instance was created.xThis is the time that the SOP Instance UID was assigned, and does not change during subsequent coercion of the instance.   descInstance Creation Time   name

SOP Common   module   (0008,0013)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req   ;Sequence that defines the image boxes for this Display Set.�Only a single Item shall be included in this sequence unless Image Box Layout Type (0072,0304) is TILED, in which case one or more items shall be included in this sequence.   descImage Boxes Sequence   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0300)   
M   usage    
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is LO.   descSelector LO Value   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0066)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req      %  A certificate that holds the identity of the entity producing this Digital Signature, that entity's public key or key identifier, and the algorithm and associated parameters with which that public key is to be used. Algorithms allowed are specified in Digital Signature Security Profiles (see        PS3.15	   targetdocselect: labelnumber	   xrefstylePS3.15	   targetptr   attrsolink   el).      
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
M   usage   
   mod_tables
Hanging Protocol   entity1C   req�Identification of the creator of a group of private data elements. Required if the Functional Group Pointer (0020,9167) value is the Data Element Tag of a Private Attribute.   desc Functional Group Private Creator   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0600)[<1>](0020,9238)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req�Transfer Syntax used to encode the encrypted content. Only Transfer Syntaxes that explicitly include the VR and use Little Endian encoding shall be used.   desc%Encrypted Content Transfer Syntax UID   name

SOP Common   module   (0400,0500)[<0>](0400,0510)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   tManufacturer's designation of the software version of the equipment that contributed to the composite instance. See        select: label	   xrefstylesect_C.7.5.1.1.3   linkend   attrsxref   el.   descSoftware Versions   name

SOP Common   module   (0018,a001)[<0>](0018,1020)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   2Sequence of Items containing encrypted DICOM data.5One or more Items shall be included in this sequence.   �Required if application level confidentiality is needed and certain recipients are allowed to decrypt all or portions of the Encrypted Attributes Data Set. See        select: label	   xrefstylesect_C.12.1.1.4.1   linkend   attrsxref   el.   descEncrypted Attributes Sequence   name

SOP Common   module   (0400,0500)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   'Uniquely identifies the SOP Class. See        select: label	   xrefstylesect_C.12.1.1.1   linkend   attrsxref   el# for further explanation. See also        select: labelnumber	   xrefstylePS3.4	   targetdocPS3.4	   targetptr   attrsolink   el.   descSOP Class UID   name

SOP Common   module   (0008,0016)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   6Reformatting operation to be applied to the Image Set.   
variablelist   typeDefined Terms:   title      MPR   3D_RENDERING   SLAB   list   descReformatting Operation Type   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0510)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   �Indicates direction in which to horizontally justify the image within a viewport that is not the same shape (aspect ratio) as the image.   
variablelist   typeEnumerated Values:   title      LEFT   CENTER   RIGHT   list      
                        �Typically used in mammography display applications in which images from the patient's left and right are displayed "back to back", rather than centered.   contentpara   el
                   contentnote   el   desc$Display Set Horizontal Justification   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0717)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req�Retrieval access path to HL7 Structured Document. Includes fully specified scheme, authority, path, and query in accordance with RFC 2396   descRetrieve URI   name

SOP Common   module   (0040,a390)[<0>](0040,e010)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   rIndicates whether or not the date and time attributes in the instance have been modified during de-identification.   
variablelist   typeEnumerated Values:   title      
UNMODIFIED   MODIFIED   REMOVED   list   See        select: labelnumber	   xrefstylePS3.15	   targetdocPS3.15	   targetptr   attrsolink   el.   desc*Longitudinal Temporal Information Modified   name

SOP Common   module   (0028,0303)   
M   usage   �
   mod_tables
Hanging Protocol   entity1   req0Uniquely identifies the referenced SOP Instance.   descReferenced SOP Instance UID   name

SOP Common   module   (0020,9172)[<0>](0008,1155)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req�Description of the intent of the Display Set Presentation Group (0072,0204). If present, shall have the same value in all sequence Items assigned the same value for Display Set Presentation Group (0072,0204).   desc*Display Set Presentation Group Description   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0206)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   $Sequence holding Digital Signatures.1One or more items are permitted in this sequence.   descDigital Signatures Sequence   name

SOP Common   module   (fffa,fffa)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   reqNDescription of the objective of the display set defined by this sequence item.   descDisplay Set Label   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0203)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   �Specifies the behavior of the Filter-by Operator (0072,0406) when Selector Attribute (0072,0026) is not available in the image or does not contain a value specified by Selector Value Number (0072,0028).OIf this attribute is not present in this sequence item, MATCH shall be assumed.BShall be ignored if Filter-by Operator (0072,0406) is not present.   
variablelist   typeEnumerated Values:   title      MATCH'include the image in the filter output.   NO_MATCH.do not include the image in the filter output.   list   descImage Set Selector Usage Flag   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0400)[<1>](0072,0024)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req�Positive integer identifying which value of a multi-valued attribute identified by Selector Attribute (0072,0026) is to be used for Image Set selection. The value 1 identifies the first value. The value zero identifies any value.   descSelector Value Number   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0028)   
M   usage    #
   mod_tables
Hanging Protocol   entity1C   req   KThe value(s) of the attribute identified by Selector Attribute (0072,0026).MRequired if Selector Attribute VR (0072,0050) is present and the value is SL.   descSelector SL Value   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,007c)   
M   usage    >
   mod_tables
Hanging Protocol   entity2C   req   NDefines the type of large increment scrolling to be applied to this Image Box.�Required if the value of Image Box Layout Type (0072,0304) is TILED, and the value of Image Box Tile Horizontal Dimension (0072,0306) or Image Box Tile Vertical Dimension (0072,0308) is greater than 1.   
variablelist   typeEnumerated Values:   title      PAGETIn a TILED image box, replace all image slots with the next N x M images in the set.   
ROW_COLUMN�In a TILED image box, move each row or column of images to the next row or column, depending on Image Box Scroll Direction (0072,0310).   IMAGE�In a TILED image box, move each image to the next slot, either horizontally or vertically, depending on Image Box Scroll Direction (0072,0310).   list      
                        �If there are multiple image boxes of different Tile Dimensions in a Display Set, then only IMAGE scrolling applies, and the value of the attribute is ignored.   contentpara   el
                   contentnote   el   descImage Box Large Scroll Type   name
Hanging Protocol Display   module+   (0072,0200)[<0>](0072,0300)[<1>](0072,0316)   
M   usage    x
   mod_tables
Hanging Protocol   entity1   req   kPositive integer indicating the intended number of columns of the addressable area of the screen in pixels.      
                        'The goal is not absolute size matching.   contentpara   el
                   contentnote   el   descNumber of Horizontal Pixels   name
Hanging Protocol Environment   module   (0072,0106)   
M   usage    >
   mod_tables
Hanging Protocol   entity1   req�A monotonically increasing integer, starting from 1, incrementing by one, unique within the Hanging Protocol Instance. It shall be used to identify linked display sets in the Display Set Scrolling Group (0072,0212).   descDisplay Set Number   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0202)   
M   usage    �
   mod_tables
Hanging Protocol   entity2C   req�The coding scheme identifier as defined in an external registry. Required if coding scheme is registered and Coding Scheme UID (0008,010C) is not present.   descCoding Scheme External ID   name

SOP Common   module   (0008,0110)[<0>](0008,0114)   
M   usage    �
   mod_tables
Hanging Protocol   entity1C   req   ^The view requested during the C-MOVE operation that resulted in the transfer of this instance.   
variablelist   typeEnumerated Values:   title      CLASSIC   ENHANCED   listRequired if the instance has ever been converted from its source form as the result of a C-MOVE operation with a specific view.   descQuery/Retrieve View   name

SOP Common   module   (0008,0053)   
M   usage    >
   mod_tables
Hanging Protocol   entity3   req   LIndicates whether or not to display image acquisition technique information.   
variablelist   typeEnumerated Values:   title      YES   NO   list   desc Show Acquisition Techniques Flag   name
Hanging Protocol Display   module   (0072,0200)[<0>](0072,0716)   
M   usage    �
   mod_tables
Hanging Protocol   entity3   req   �Date when the image acquisition device calibration was last changed in any way. Multiple entries may be used for additional calibrations at other times. See        select: label	   xrefstylesect_C.7.5.1.1.1   linkend   attrsxref   el for further explanation.   descDate of Last Calibration   name

SOP Common   module   (0018,a001)[<0>](0018,1200)   
M   usage   �
   mod_tables
Hanging Protocol   entity1   req-Uniquely identifies the referenced SOP Class.   descReferenced SOP Class UID   name

SOP Common   module   (0040,a390)[<0>](0008,1150)   
M   usage    �
   mod_tables
Hanging Protocol   entity1   req   @The Value Representation of Selector Attribute (0072,0026). See        select: labelnumber	   xrefstylePS3.5	   targetdocPS3.5	   targetptr   attrsolink   el/ for Enumerated Values of Value Representation.   descSelector Attribute VR   name
Hanging Protocol Definition   module+   (0072,0020)[<0>](0072,0022)[<1>](0072,0050)   tags