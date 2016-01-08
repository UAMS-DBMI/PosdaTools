--
-- $Source: /home/bbennett/pass/archive/Posda/sql/dicom_dd_dump.sql,v $
-- $Date: 2010/10/19 20:43:47 $
-- $Revision: 1.6 $
--
-- Copyright 2008, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 

--
--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: ele; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ele (
    ele_sig text NOT NULL,
    grp integer,
    ele integer,
    grp_mask integer,
    ele_mask integer,
    grp_shift integer,
    ele_shift integer,
    vr text,
    vm text,
    vers text,
    owned_by text,
    name text,
    std boolean,
    pvt boolean,
    retired boolean,
    keyword text,
    private_block text
);


--
-- Name: sopcl; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sopcl (
    sopcl_type text,
    sopcl_desc text,
    dir_rec text,
    sopcl_uid text,
    std_ref text,
    retired boolean
);


--
-- Name: vr; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vr (
    vr_code text,
    vr_name text,
    len integer,
    fixed boolean,
    pad_leading boolean,
    pad_null boolean,
    pad_trailing boolean,
    strip_leading boolean,
    strip_trailing boolean,
    strip_trailing_null boolean,
    vr_type text
);


--
-- Name: xfr_stx; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE xfr_stx (
    xfr_stx_uid text NOT NULL,
    ref boolean,
    encap boolean,
    deflated boolean,
    vax boolean,
    explicit boolean,
    short_len boolean,
    std boolean,
    retired boolean,
    name text,
    default_for text,
    doc text
);


--
-- Data for Name: ele; Type: TABLE DATA; Schema: public; Owner: -
--

COPY ele (ele_sig, grp, ele, grp_mask, ele_mask, grp_shift, ele_shift, vr, vm, vers, owned_by, name, std, pvt, retired, keyword, private_block) FROM stdin;
(0009,"SPI",10)	9	16	0	0	0	0	LT	1	SSPI	SPI	Comments	f	t	\N	\N	\N
(0010,0020)	16	32	0	0	0	0	LO	1	3	\N	Patient ID	t	f	f	\N	\N
(0018,1243)	24	4675	0	0	0	0	IS	1	3	\N	Count Rate	t	f	f	\N	\N
(0020,9453)	32	37971	0	0	0	0	LO	1	3-2006	\N	Frame Label	t	\N	f	\N	\N
(7fxx,0011)	32512	17	65280	0	0	0	US	1	2C	\N	Variable Next Data Group	t	f	t	\N	\N
(7fxx,0020)	32512	32	65280	0	0	0	OW	1-n	2C	\N	Variable Coefficients SDVN	t	f	t	\N	\N
(7fxx,0030)	32512	48	65280	0	0	0	OW	1-n	2C	\N	Variable Coefficients SDHN	t	f	t	\N	\N
(7fxx,0040)	32512	64	65280	0	0	0	OW	1-n	2C	\N	Variable Coefficients SDDN	t	f	t	\N	\N
(0028,0071)	40	113	0	0	0	0	OT	1	2C	\N	Perimeter Value	t	f	t	\N	\N
(7fxx,0010)	32512	16	65280	0	0	0	OT	1	2C	\N	Variable Pixel Data	t	f	t	\N	\N
(0028,1111)	40	4369	0	0	0	0	OT	4	3DFT	\N	Large Red Palette Color Lookup Table Descriptor	t	f	t	\N	\N
(0028,1112)	40	4370	0	0	0	0	OT	4	3DFT	\N	Large Green Palette Color Lookup Table Descriptor	t	f	t	\N	\N
(0028,1113)	40	4371	0	0	0	0	OT	4	3DFT	\N	Large Blue Palette Color Lookup Table Descriptor	t	f	t	\N	\N
(0020,0010)	32	16	0	0	0	0	SH	1	3	\N	Study ID	t	f	f	\N	\N
(0018,9059)	24	36953	0	0	0	0	CS	1	3MR	\N	De-coupling	t	f	f	\N	\N
(2010,0140)	8208	320	0	0	0	0	CS	1	3	\N	Trim	t	f	f	\N	\N
(3006,0022)	12294	34	0	0	0	0	IS	1	3RT	\N	ROI Number	t	f	f	\N	\N
(0008,0060)	8	96	0	0	0	0	CS	1	3	\N	Modality	t	f	f	\N	\N
(0018,0015)	24	21	0	0	0	0	CS	1	3	\N	Body Part Examined	t	f	f	\N	\N
(0018,9035)	24	36917	0	0	0	0	FD	1	3MR	\N	Tag Thickness	t	f	f	\N	\N
(3004,0050)	12292	80	0	0	0	0	SQ	1	3RT	\N	DVH Sequence	t	f	f	\N	\N
(3006,00c4)	12294	196	0	0	0	0	CS	1	3RT	\N	Frame of Reference Transformation Type	t	f	f	\N	\N
(300a,00c8)	12298	200	0	0	0	0	IS	1	3RT	\N	Reference Image Number	t	f	f	\N	\N
(0008,0005)	8	5	0	0	0	0	CS	1-n	3	\N	Specific Character Set	t	f	f	\N	\N
(0008,0012)	8	18	0	0	0	0	DA	1	3	\N	Instance Creation Date	t	f	f	\N	\N
(0008,0013)	8	19	0	0	0	0	TM	1	3	\N	Instance Creation Time	t	f	f	\N	\N
(0008,0014)	8	20	0	0	0	0	UI	1	3	\N	Instance Creator UID	t	f	f	\N	\N
(0008,0016)	8	22	0	0	0	0	UI	1	3	\N	SOP Class UID	t	f	f	\N	\N
(0008,0018)	8	24	0	0	0	0	UI	1	3	\N	SOP Instance UID	t	f	f	\N	\N
(0008,0020)	8	32	0	0	0	0	DA	1	3	\N	Study Date	t	f	f	\N	\N
(0008,0021)	8	33	0	0	0	0	DA	1	3	\N	Series Date	t	f	f	\N	\N
(0008,0022)	8	34	0	0	0	0	DA	1	3	\N	Acquisition Date	t	f	f	\N	\N
(0008,0023)	8	35	0	0	0	0	DA	1	3	\N	Content (formerly Image) Date	t	f	f	\N	\N
(0008,002a)	8	42	0	0	0	0	DT	1	3WAV	\N	Acquisition Date Time	t	f	f	\N	\N
(0008,0030)	8	48	0	0	0	0	TM	1	3	\N	Study Time	t	f	f	\N	\N
(0008,0031)	8	49	0	0	0	0	TM	1	3	\N	Series Time	t	f	f	\N	\N
(0008,0032)	8	50	0	0	0	0	TM	1	3	\N	Acquisition Time	t	f	f	\N	\N
(0008,0033)	8	51	0	0	0	0	TM	1	3	\N	Content (formerly Image) Time	t	f	f	\N	\N
(0008,0050)	8	80	0	0	0	0	SH	1	3	\N	Accession Number	t	f	f	\N	\N
(0008,0052)	8	82	0	0	0	0	CS	1	3	\N	Query/Retrieve Level	t	f	f	\N	\N
(0008,0054)	8	84	0	0	0	0	AE	1-n	3	\N	Retrieve AE Title	t	f	f	\N	\N
(0008,0056)	8	86	0	0	0	0	CS	1	3CP	\N	Instance Availability	t	f	f	\N	\N
(0008,0058)	8	88	0	0	0	0	UI	1-n	3	\N	Failed SOP Instance UID List	t	f	f	\N	\N
(0008,0061)	8	97	0	0	0	0	CS	1-n	3CP	\N	Modalities In Study	t	f	f	\N	\N
(0008,0064)	8	100	0	0	0	0	CS	1	3	\N	Conversion Type	t	f	f	\N	\N
(0008,0068)	8	104	0	0	0	0	CS	1	3DX	\N	Presentation Intent Type	t	f	f	\N	\N
(0008,0070)	8	112	0	0	0	0	LO	1	3	\N	Manufacturer	t	f	f	\N	\N
(0008,0080)	8	128	0	0	0	0	LO	1	3	\N	Institution Name	t	f	f	\N	\N
(0008,0081)	8	129	0	0	0	0	ST	1	3	\N	Institution Address	t	f	f	\N	\N
(0008,0082)	8	130	0	0	0	0	SQ	1	3	\N	Institution Code Sequence	t	f	f	\N	\N
(0008,0090)	8	144	0	0	0	0	PN	1	3	\N	Referring Physician's Name	t	f	f	\N	\N
(0008,0092)	8	146	0	0	0	0	ST	1	3	\N	Referring Physician's Address	t	f	f	\N	\N
(0008,0094)	8	148	0	0	0	0	SH	1-n	3	\N	Referring Physician's Telephone Numbers	t	f	f	\N	\N
(0008,0100)	8	256	0	0	0	0	SH	1	3	\N	Code Value	t	f	f	\N	\N
(0008,0102)	8	258	0	0	0	0	SH	1	3	\N	Coding Scheme Designator	t	f	f	\N	\N
(0008,0103)	8	259	0	0	0	0	SH	1	3COD	\N	Coding Scheme Version	t	f	f	\N	\N
(0008,0104)	8	260	0	0	0	0	LO	1	3	\N	Code Meaning	t	f	f	\N	\N
(0008,0105)	8	261	0	0	0	0	CS	1	3COD	\N	Mapping Resource	t	f	f	\N	\N
(0008,0106)	8	262	0	0	0	0	DT	1	3COD	\N	Context Group Version	t	f	f	\N	\N
(0008,0107)	8	263	0	0	0	0	DT	1	3COD	\N	Context Group Local Version	t	f	f	\N	\N
(0008,010b)	8	267	0	0	0	0	CS	1	3COD	\N	Code Set Extension Flag	t	f	f	\N	\N
(0008,010c)	8	268	0	0	0	0	UI	1	3COD	\N	Private Coding Scheme Creator UID	t	f	f	\N	\N
(0008,010d)	8	269	0	0	0	0	UI	1	3COD	\N	Code Set Extension Creator UID	t	f	f	\N	\N
(0008,010f)	8	271	0	0	0	0	CS	1	3COD	\N	Context Identifier	t	f	f	\N	\N
(0008,0201)	8	513	0	0	0	0	SH	1	3CP	\N	Timezone Offset From UTC	t	f	f	\N	\N
(0008,1010)	8	4112	0	0	0	0	SH	1	3	\N	Station Name	t	f	f	\N	\N
(0008,1030)	8	4144	0	0	0	0	LO	1	3	\N	Study Description	t	f	f	\N	\N
(0008,1032)	8	4146	0	0	0	0	SQ	1	3	\N	Procedure Code Sequence	t	f	f	\N	\N
(0008,103e)	8	4158	0	0	0	0	LO	1	3	\N	Series Description	t	f	f	\N	\N
(0008,1040)	8	4160	0	0	0	0	LO	1	3	\N	Institutional Department Name	t	f	f	\N	\N
(0008,1048)	8	4168	0	0	0	0	PN	1-n	3	\N	Physician of Record	t	f	f	\N	\N
(0008,1050)	8	4176	0	0	0	0	PN	1-n	3	\N	Performing Physician's Name	t	f	f	\N	\N
(0008,1060)	8	4192	0	0	0	0	PN	1-n	3	\N	Name of Physician(s) Reading Study	t	f	f	\N	\N
(0008,1070)	8	4208	0	0	0	0	PN	1-n	3	\N	Operator's Name	t	f	f	\N	\N
(0008,1080)	8	4224	0	0	0	0	LO	1-n	3	\N	Admitting Diagnoses Description	t	f	f	\N	\N
(0008,1084)	8	4228	0	0	0	0	SQ	1	3	\N	Admitting Diagnoses Code Sequence	t	f	f	\N	\N
(0008,1090)	8	4240	0	0	0	0	LO	1	3	\N	Manufacturer's Model Name	t	f	f	\N	\N
(0008,1110)	8	4368	0	0	0	0	SQ	1	3	\N	Referenced Study Sequence	t	f	f	\N	\N
(0008,1111)	8	4369	0	0	0	0	SQ	1	3	\N	Referenced Study Component Sequence	t	f	f	\N	\N
(0008,1115)	8	4373	0	0	0	0	SQ	1	3	\N	Referenced Series Sequence	t	f	f	\N	\N
(0008,1120)	8	4384	0	0	0	0	SQ	1	3	\N	Referenced Patient Sequence	t	f	f	\N	\N
(0008,1125)	8	4389	0	0	0	0	SQ	1	3	\N	Referenced Visit Sequence	t	f	f	\N	\N
(0008,113a)	8	4410	0	0	0	0	SQ	1	3WAV	\N	Referenced Waveform Sequence	t	f	f	\N	\N
(0008,1140)	8	4416	0	0	0	0	SQ	1	3	\N	Referenced Image Sequence	t	f	f	\N	\N
(0008,114a)	8	4426	0	0	0	0	SQ	1	3WAV	\N	Referenced Instance Sequence	t	f	f	\N	\N
(0008,1150)	8	4432	0	0	0	0	UI	1	3	\N	Referenced SOP Class UID	t	f	f	\N	\N
(0008,1155)	8	4437	0	0	0	0	UI	1	3	\N	Referenced SOP Instance UID	t	f	f	\N	\N
(0008,115a)	8	4442	0	0	0	0	UI	1-n	3???	\N	SOP Classes Supported	t	f	f	\N	\N
(0008,1160)	8	4448	0	0	0	0	IS	1-n	3	\N	Referenced Frame Number	t	f	f	\N	\N
(0008,1195)	8	4501	0	0	0	0	UI	1	3	\N	Transaction UID	t	f	f	\N	\N
(0008,1197)	8	4503	0	0	0	0	US	1	3	\N	Failure Reason	t	f	f	\N	\N
(0008,1198)	8	4504	0	0	0	0	SQ	1	3	\N	Failed SOP Sequence	t	f	f	\N	\N
(0008,1199)	8	4505	0	0	0	0	SQ	1	3	\N	Referenced SOP Sequence	t	f	f	\N	\N
(0008,2111)	8	8465	0	0	0	0	ST	1	3	\N	Derivation Description	t	f	f	\N	\N
(0008,2112)	8	8466	0	0	0	0	SQ	1	3	\N	Source Image Sequence	t	f	f	\N	\N
(0008,2120)	8	8480	0	0	0	0	SH	1	3	\N	Stage Name	t	f	f	\N	\N
(0008,2122)	8	8482	0	0	0	0	IS	1	3	\N	Stage Number	t	f	f	\N	\N
(0008,2124)	8	8484	0	0	0	0	IS	1	3	\N	Number of Stages	t	f	f	\N	\N
(0008,2127)	8	8487	0	0	0	0	SH	1	3	\N	View Name	t	f	f	\N	\N
(0008,2128)	8	8488	0	0	0	0	IS	1	3	\N	View Number	t	f	f	\N	\N
(0008,2129)	8	8489	0	0	0	0	IS	1	3	\N	Number of Event Timers	t	f	f	\N	\N
(0008,212a)	8	8490	0	0	0	0	IS	1	3	\N	Number of Views in Stage	t	f	f	\N	\N
(0008,2130)	8	8496	0	0	0	0	DS	1-n	3	\N	Event Elapsed Time(s)	t	f	f	\N	\N
(0008,2132)	8	8498	0	0	0	0	LO	1-n	3	\N	Event Timer Name(s)	t	f	f	\N	\N
(0008,2142)	8	8514	0	0	0	0	IS	1	3	\N	Start Trim	t	f	f	\N	\N
(0008,2143)	8	8515	0	0	0	0	IS	1	3	\N	Stop Trim	t	f	f	\N	\N
(0008,2144)	8	8516	0	0	0	0	IS	1	3	\N	Recommended Display Frame Rate	t	f	f	\N	\N
(0008,2218)	8	8728	0	0	0	0	SQ	1	3	\N	Anatomic Region Sequence	t	f	f	\N	\N
(0008,2220)	8	8736	0	0	0	0	SQ	1	3	\N	Anatomic Region Modifier Sequence	t	f	f	\N	\N
(0008,2228)	8	8744	0	0	0	0	SQ	1	3	\N	Primary Anatomic Structure Sequence	t	f	f	\N	\N
(0008,2229)	8	8745	0	0	0	0	SQ	1	3???	\N	Anatomic Structure, Space or Region Sequence	t	f	f	\N	\N
(0008,2230)	8	8752	0	0	0	0	SQ	1	3	\N	Primary Anatomic Structure Modifier Sequence	t	f	f	\N	\N
(0008,9007)	8	36871	0	0	0	0	CS	4	3MR	\N	Frame Type	t	f	f	\N	\N
(0008,9092)	8	37010	0	0	0	0	SQ	1	3MR	\N	Referenced Image Evidence Sequence	t	f	f	\N	\N
(0008,9121)	8	37153	0	0	0	0	SQ	1	3MR	\N	Referenced Raw Data Sequence	t	f	f	\N	\N
(0008,9123)	8	37155	0	0	0	0	UI	1	3MR	\N	Creator-Version UID	t	f	f	\N	\N
(0008,9124)	8	37156	0	0	0	0	SQ	1	3MR	\N	Derivation Image Sequence	t	f	f	\N	\N
(0008,9154)	8	37204	0	0	0	0	SQ	1	3MR	\N	Source Image Evidence Sequence	t	f	f	\N	\N
(0008,9205)	8	37381	0	0	0	0	CS	1	3MR	\N	Pixel Presentation	t	f	f	\N	\N
(0008,9206)	8	37382	0	0	0	0	CS	1	3MR	\N	Volumetric Properties	t	f	f	\N	\N
(0008,9207)	8	37383	0	0	0	0	CS	1	3MR	\N	Volume Based Calculation Technique	t	f	f	\N	\N
(0008,9208)	8	37384	0	0	0	0	CS	1	3MR	\N	Complex Image Component	t	f	f	\N	\N
(0008,9209)	8	37385	0	0	0	0	CS	1	3MR	\N	Acquisition Contrast	t	f	f	\N	\N
(0008,9215)	8	37397	0	0	0	0	SQ	1	3MR	\N	Derivation Code Sequence	t	f	f	\N	\N
(0008,9237)	8	37431	0	0	0	0	SQ	1	3MR	\N	Referenced Grayscale Presentation State Sequence	t	f	f	\N	\N
(0010,0010)	16	16	0	0	0	0	PN	1	3	\N	Patient's Name	t	f	f	\N	\N
(0010,0021)	16	33	0	0	0	0	LO	1	3	\N	Issuer of Patient ID	t	f	f	\N	\N
(0010,0030)	16	48	0	0	0	0	DA	1	3	\N	Patient's Birth Date	t	f	f	\N	\N
(0010,0032)	16	50	0	0	0	0	TM	1	3	\N	Patient's Birth Time	t	f	f	\N	\N
(0010,0040)	16	64	0	0	0	0	CS	1	3	\N	Patient's Sex	t	f	f	\N	\N
(0010,0050)	16	80	0	0	0	0	SQ	1	3	\N	Patient's Insurance Plan Code Sequence	t	f	f	\N	\N
(0010,0101)	16	257	0	0	0	0	SQ	1	3	\N	Patient's Primary Language Code Sequence	t	f	f	\N	\N
(0010,0102)	16	258	0	0	0	0	SQ	1	3	\N	Patient's Primary Language Modifier Code Sequence	t	f	f	\N	\N
(0010,1000)	16	4096	0	0	0	0	LO	1-n	3	\N	Other Patient IDs	t	f	f	\N	\N
(0010,1001)	16	4097	0	0	0	0	PN	1-n	3	\N	Other Patient's Names	t	f	f	\N	\N
(0010,1005)	16	4101	0	0	0	0	PN	1	3	\N	Patient's Birth Name	t	f	f	\N	\N
(0010,1010)	16	4112	0	0	0	0	AS	1	3	\N	Patient's Age	t	f	f	\N	\N
(0010,1020)	16	4128	0	0	0	0	DS	1	3	\N	Patient's Size	t	f	f	\N	\N
(0010,1030)	16	4144	0	0	0	0	DS	1	3	\N	Patient's Weight	t	f	f	\N	\N
(0010,1040)	16	4160	0	0	0	0	LO	1	3	\N	Patient's Address	t	f	f	\N	\N
(0010,1060)	16	4192	0	0	0	0	PN	1	3	\N	Patient's Mother's Birth Name	t	f	f	\N	\N
(0010,1080)	16	4224	0	0	0	0	LO	1	3	\N	Military Rank	t	f	f	\N	\N
(0010,1081)	16	4225	0	0	0	0	LO	1	3	\N	Branch of Service	t	f	f	\N	\N
(0010,1090)	16	4240	0	0	0	0	LO	1	3	\N	Medical Record Locator	t	f	f	\N	\N
(0010,2000)	16	8192	0	0	0	0	LO	1-n	3	\N	Medical Alerts	t	f	f	\N	\N
(0010,2110)	16	8464	0	0	0	0	LO	1-n	3	\N	Contrast Allergies	t	f	f	\N	\N
(0010,2150)	16	8528	0	0	0	0	LO	1	3	\N	Country of Residence	t	f	f	\N	\N
(0010,2152)	16	8530	0	0	0	0	LO	1	3	\N	Region of Residence	t	f	f	\N	\N
(0010,2154)	16	8532	0	0	0	0	SH	1-n	3	\N	Patient's Telephone Numbers	t	f	f	\N	\N
(0010,2160)	16	8544	0	0	0	0	SH	1	3	\N	Ethnic Group	t	f	f	\N	\N
(0010,2180)	16	8576	0	0	0	0	SH	1	3	\N	Occupation	t	f	f	\N	\N
(0010,21a0)	16	8608	0	0	0	0	CS	1	3	\N	Smoking Status	t	f	f	\N	\N
(0010,21b0)	16	8624	0	0	0	0	LT	1	3	\N	Additional Patient History	t	f	f	\N	\N
(0010,21c0)	16	8640	0	0	0	0	US	1	3	\N	Pregnancy Status	t	f	f	\N	\N
(0010,21d0)	16	8656	0	0	0	0	DA	1	3	\N	Last Menstrual Date	t	f	f	\N	\N
(0010,21f0)	16	8688	0	0	0	0	LO	1	3	\N	Patient's Religious Preference	t	f	f	\N	\N
(0010,4000)	16	16384	0	0	0	0	LT	1	3	\N	Patient Comments	t	f	f	\N	\N
(0018,0010)	24	16	0	0	0	0	LO	1	3	\N	Contrast/Bolus Agent	t	f	f	\N	\N
(0018,0012)	24	18	0	0	0	0	SQ	1	3	\N	Contrast/Bolus Agent Sequence	t	f	f	\N	\N
(0018,0014)	24	20	0	0	0	0	SQ	1	3	\N	Contrast/Bolus Administration Route Sequence	t	f	f	\N	\N
(0018,0020)	24	32	0	0	0	0	CS	1-n	3	\N	Scanning Sequence	t	f	f	\N	\N
(0018,0021)	24	33	0	0	0	0	CS	1-n	3	\N	Sequence Variant	t	f	f	\N	\N
(0018,0022)	24	34	0	0	0	0	CS	1-n	3	\N	Scan Options	t	f	f	\N	\N
(0018,0023)	24	35	0	0	0	0	CS	1	3	\N	MR Acquisition Type	t	f	f	\N	\N
(0018,0024)	24	36	0	0	0	0	SH	1	3	\N	Sequence Name	t	f	f	\N	\N
(0018,0025)	24	37	0	0	0	0	CS	1	3	\N	Angio Flag	t	f	f	\N	\N
(0018,0026)	24	38	0	0	0	0	SQ	1	3	\N	Intervention Drug Information Sequence	t	f	f	\N	\N
(0018,0027)	24	39	0	0	0	0	TM	1	3	\N	Intervention Drug Stop Time	t	f	f	\N	\N
(0018,0028)	24	40	0	0	0	0	DS	1	3	\N	Intervention Drug Dose	t	f	f	\N	\N
(0018,0029)	24	41	0	0	0	0	SQ	1	3	\N	Intervention Drug Code Sequence	t	f	f	\N	\N
(0018,002a)	24	42	0	0	0	0	SQ	1	3	\N	Additional Drug Sequence	t	f	f	\N	\N
(0018,0031)	24	49	0	0	0	0	LO	1-n	3	\N	Radiopharmaceutical	t	f	f	\N	\N
(0018,0034)	24	52	0	0	0	0	LO	1	3	\N	Intervention Drug Name	t	f	f	\N	\N
(0018,0035)	24	53	0	0	0	0	TM	1	3	\N	Intervention Drug Start Time	t	f	f	\N	\N
(0018,0036)	24	54	0	0	0	0	SQ	1	3	\N	Intervention Therapy Sequence	t	f	f	\N	\N
(0018,0038)	24	56	0	0	0	0	CS	1	3	\N	Intervention Status	t	f	f	\N	\N
(0018,0040)	24	64	0	0	0	0	IS	1	3	\N	Cine Rate	t	f	f	\N	\N
(0018,0050)	24	80	0	0	0	0	DS	1	3	\N	Slice Thickness	t	f	f	\N	\N
(0018,0060)	24	96	0	0	0	0	DS	1	3	\N	KVP	t	f	f	\N	\N
(0018,0070)	24	112	0	0	0	0	IS	1	3	\N	Counts Accumulated	t	f	f	\N	\N
(0018,0071)	24	113	0	0	0	0	CS	1	3	\N	Acquisition Termination Condition	t	f	f	\N	\N
(0018,0072)	24	114	0	0	0	0	DS	1	3	\N	Effective Series Duration	t	f	f	\N	\N
(0018,0073)	24	115	0	0	0	0	CS	1	3PET	\N	Acquisition Start Condition	t	f	f	\N	\N
(0018,0074)	24	116	0	0	0	0	IS	1	3PET	\N	Acquisition Start Condition Data	t	f	f	\N	\N
(0018,0075)	24	117	0	0	0	0	IS	1	3PET	\N	Acquisition Termination Condition Data	t	f	f	\N	\N
(0018,0080)	24	128	0	0	0	0	DS	1	3	\N	Repetition Time	t	f	f	\N	\N
(0018,0081)	24	129	0	0	0	0	DS	1	3	\N	Echo Time	t	f	f	\N	\N
(0018,0082)	24	130	0	0	0	0	DS	1	3	\N	Inversion Time	t	f	f	\N	\N
(0018,0083)	24	131	0	0	0	0	DS	1	3	\N	Number of Averages	t	f	f	\N	\N
(0018,0084)	24	132	0	0	0	0	DS	1	3	\N	Imaging Frequency	t	f	f	\N	\N
(0018,0085)	24	133	0	0	0	0	SH	1	3	\N	Imaged Nucleus	t	f	f	\N	\N
(0018,0086)	24	134	0	0	0	0	IS	1-n	3	\N	Echo Number(s)	t	f	f	\N	\N
(0018,0087)	24	135	0	0	0	0	DS	1	3	\N	Magnetic Field Strength	t	f	f	\N	\N
(0018,0088)	24	136	0	0	0	0	DS	1	3	\N	Spacing Between Slices	t	f	f	\N	\N
(0018,0089)	24	137	0	0	0	0	IS	1	3	\N	Number of Phase Encoding Steps	t	f	f	\N	\N
(0018,0090)	24	144	0	0	0	0	DS	1	3	\N	Data Collection Diameter	t	f	f	\N	\N
(0018,0091)	24	145	0	0	0	0	IS	1	3	\N	Echo Train Length	t	f	f	\N	\N
(0018,0093)	24	147	0	0	0	0	DS	1	3	\N	Percent Sampling	t	f	f	\N	\N
(0018,0094)	24	148	0	0	0	0	DS	1	3	\N	Percent Phase Field of View	t	f	f	\N	\N
(0018,0095)	24	149	0	0	0	0	DS	1	3	\N	Pixel Bandwidth	t	f	f	\N	\N
(0018,1000)	24	4096	0	0	0	0	LO	1	3	\N	Device Serial Number	t	f	f	\N	\N
(0018,1004)	24	4100	0	0	0	0	LO	1	3	\N	Plate ID	t	f	f	\N	\N
(0018,1010)	24	4112	0	0	0	0	LO	1	3	\N	Secondary Capture Device ID	t	f	f	\N	\N
(0018,1011)	24	4113	0	0	0	0	LO	1	3STP	\N	Hardcopy Creation Device ID	t	f	f	\N	\N
(0018,1012)	24	4114	0	0	0	0	DA	1	3	\N	Date of Secondary Capture	t	f	f	\N	\N
(0018,1014)	24	4116	0	0	0	0	TM	1	3	\N	Time of Secondary Capture	t	f	f	\N	\N
(0018,1016)	24	4118	0	0	0	0	LO	1	3	\N	Secondary Capture Device Manufacturer	t	f	f	\N	\N
(0018,1017)	24	4119	0	0	0	0	LO	1	3STP	\N	Hardcopy Device Manufacturer	t	f	f	\N	\N
(0018,1018)	24	4120	0	0	0	0	LO	1	3	\N	Secondary Capture Device Manufacturer's Model Name	t	f	f	\N	\N
(0018,1019)	24	4121	0	0	0	0	LO	1-n	3	\N	Secondary Capture Device Software Version(s)	t	f	f	\N	\N
(0018,101a)	24	4122	0	0	0	0	LO	1-n	3STP	\N	Hardcopy Device Software Version	t	f	f	\N	\N
(0018,101b)	24	4123	0	0	0	0	LO	1	3STP	\N	Hardcopy Device Manufacturer's Model Name	t	f	f	\N	\N
(0018,1020)	24	4128	0	0	0	0	LO	1-n	3	\N	Software Version(s)	t	f	f	\N	\N
(0018,1022)	24	4130	0	0	0	0	SH	1	3	\N	Video Image Format Acquired	t	f	f	\N	\N
(0018,1023)	24	4131	0	0	0	0	LO	1	3	\N	Digital Image Format Acquired	t	f	f	\N	\N
(0018,1030)	24	4144	0	0	0	0	LO	1	3	\N	Protocol Name	t	f	f	\N	\N
(0018,1040)	24	4160	0	0	0	0	LO	1	3	\N	Contrast/Bolus Route	t	f	f	\N	\N
(0018,1041)	24	4161	0	0	0	0	DS	1	3	\N	Contrast/Bolus Volume	t	f	f	\N	\N
(0018,1042)	24	4162	0	0	0	0	TM	1	3	\N	Contrast/Bolus Start Time	t	f	f	\N	\N
(0018,1043)	24	4163	0	0	0	0	TM	1	3	\N	Contrast/Bolus Stop Time	t	f	f	\N	\N
(0018,1044)	24	4164	0	0	0	0	DS	1	3	\N	Contrast/Bolus Total Dose	t	f	f	\N	\N
(0018,1045)	24	4165	0	0	0	0	IS	1-n	3	\N	Syringe Counts	t	f	f	\N	\N
(0018,1046)	24	4166	0	0	0	0	DS	1-n	3	\N	Contrast Flow Rate	t	f	f	\N	\N
(0018,1047)	24	4167	0	0	0	0	DS	1-n	3	\N	Contrast Flow Duration	t	f	f	\N	\N
(0018,1048)	24	4168	0	0	0	0	CS	1	3	\N	Contrast/Bolus Ingredient	t	f	f	\N	\N
(0018,1049)	24	4169	0	0	0	0	DS	1	3	\N	Contrast/Bolus Ingredient Concentration	t	f	f	\N	\N
(0018,1050)	24	4176	0	0	0	0	DS	1	3	\N	Spatial Resolution	t	f	f	\N	\N
(0018,1060)	24	4192	0	0	0	0	DS	1	3	\N	Trigger Time	t	f	f	\N	\N
(0018,1061)	24	4193	0	0	0	0	LO	1	3	\N	Trigger Source or Type	t	f	f	\N	\N
(0018,1062)	24	4194	0	0	0	0	IS	1	3	\N	Nominal Interval	t	f	f	\N	\N
(0018,1063)	24	4195	0	0	0	0	DS	1	3	\N	Frame Time	t	f	f	\N	\N
(0018,1064)	24	4196	0	0	0	0	LO	1	3	\N	Framing Type	t	f	f	\N	\N
(0018,1065)	24	4197	0	0	0	0	DS	1-n	3	\N	Frame Time Vector	t	f	f	\N	\N
(0018,1066)	24	4198	0	0	0	0	DS	1	3	\N	Frame Delay	t	f	f	\N	\N
(0018,1067)	24	4199	0	0	0	0	DS	1	3WAV	\N	Image Trigger Delay	t	f	f	\N	\N
(0018,1068)	24	4200	0	0	0	0	DS	1	3WAV	\N	Multiplex Group Time Offset	t	f	f	\N	\N
(0018,1069)	24	4201	0	0	0	0	DS	1	3WAV	\N	Trigger Time Offset	t	f	f	\N	\N
(0018,106a)	24	4202	0	0	0	0	CS	1	3WAV	\N	Synchronization Trigger	t	f	f	\N	\N
(0018,106c)	24	4204	0	0	0	0	US	2	3WAV	\N	Synchronization Channel	t	f	f	\N	\N
(0018,106e)	24	4206	0	0	0	0	UL	1	3WAV	\N	Trigger Sample Position	t	f	f	\N	\N
(0018,1070)	24	4208	0	0	0	0	LO	1	3	\N	Radiopharmaceutical Route	t	f	f	\N	\N
(0018,1071)	24	4209	0	0	0	0	DS	1	3	\N	Radiopharmaceutical Volume	t	f	f	\N	\N
(0018,1072)	24	4210	0	0	0	0	TM	1	3	\N	Radiopharmaceutical Start Time	t	f	f	\N	\N
(0018,1073)	24	4211	0	0	0	0	TM	1	3	\N	Radiopharmaceutical Stop Time	t	f	f	\N	\N
(0018,1074)	24	4212	0	0	0	0	DS	1	3	\N	Radionuclide Total Dose	t	f	f	\N	\N
(0018,1075)	24	4213	0	0	0	0	DS	1	3PET	\N	Radionuclide Half Life	t	f	f	\N	\N
(0018,1076)	24	4214	0	0	0	0	DS	1	3PET	\N	Radionuclide Positron Fraction	t	f	f	\N	\N
(0018,1077)	24	4215	0	0	0	0	DS	1	3PET	\N	Radiopharmaceutical Specific Activity	t	f	f	\N	\N
(0018,1080)	24	4224	0	0	0	0	CS	1	3	\N	Beat Rejection Flag	t	f	f	\N	\N
(0018,1081)	24	4225	0	0	0	0	IS	1	3	\N	Low R-R Value	t	f	f	\N	\N
(0018,1082)	24	4226	0	0	0	0	IS	1	3	\N	High R-R Value	t	f	f	\N	\N
(0018,1083)	24	4227	0	0	0	0	IS	1	3	\N	Intervals Acquired	t	f	f	\N	\N
(0018,1084)	24	4228	0	0	0	0	IS	1	3	\N	Intervals Rejected	t	f	f	\N	\N
(0018,1085)	24	4229	0	0	0	0	LO	1	3	\N	PVC Rejection	t	f	f	\N	\N
(0018,1086)	24	4230	0	0	0	0	IS	1	3	\N	Skip Beats	t	f	f	\N	\N
(0018,1088)	24	4232	0	0	0	0	IS	1	3	\N	Heart Rate	t	f	f	\N	\N
(0018,1090)	24	4240	0	0	0	0	IS	1	3	\N	Cardiac Number of Images	t	f	f	\N	\N
(0018,1094)	24	4244	0	0	0	0	IS	1	3	\N	Trigger Window	t	f	f	\N	\N
(0018,1100)	24	4352	0	0	0	0	DS	1	3	\N	Reconstruction Diameter	t	f	f	\N	\N
(0018,1110)	24	4368	0	0	0	0	DS	1	3	\N	Distance Source to Detector	t	f	f	\N	\N
(0018,1111)	24	4369	0	0	0	0	DS	1	3	\N	Distance Source to Patient	t	f	f	\N	\N
(0018,1114)	24	4372	0	0	0	0	DS	1	3	\N	Estimated Radiographic Magnification Factor	t	f	f	\N	\N
(0018,1120)	24	4384	0	0	0	0	DS	1	3	\N	Gantry/Detector Tilt	t	f	f	\N	\N
(0018,1121)	24	4385	0	0	0	0	DS	1	3PET	\N	Gantry/Detector Slew	t	f	f	\N	\N
(0018,1130)	24	4400	0	0	0	0	DS	1	3	\N	Table Height	t	f	f	\N	\N
(0018,1131)	24	4401	0	0	0	0	DS	1	3	\N	Table Traverse	t	f	f	\N	\N
(0018,1134)	24	4404	0	0	0	0	CS	1	3	\N	Table Motion	t	f	f	\N	\N
(0018,1135)	24	4405	0	0	0	0	DS	1-n	3	\N	Table Vertical Increment	t	f	f	\N	\N
(0018,1136)	24	4406	0	0	0	0	DS	1-n	3	\N	Table Lateral Increment	t	f	f	\N	\N
(0018,1137)	24	4407	0	0	0	0	DS	1-n	3	\N	Table Longitudinal Increment	t	f	f	\N	\N
(0018,1138)	24	4408	0	0	0	0	DS	1	3	\N	Table Angle	t	f	f	\N	\N
(0018,113a)	24	4410	0	0	0	0	CS	1	3DX	\N	Table Type	t	f	f	\N	\N
(0018,1140)	24	4416	0	0	0	0	CS	1	3	\N	Rotation Direction	t	f	f	\N	\N
(0018,1141)	24	4417	0	0	0	0	DS	1	3	\N	Angular Position	t	f	f	\N	\N
(0018,1142)	24	4418	0	0	0	0	DS	1-n	3	\N	Radial Position	t	f	f	\N	\N
(0018,1143)	24	4419	0	0	0	0	DS	1	3	\N	Scan Arc	t	f	f	\N	\N
(0018,1144)	24	4420	0	0	0	0	DS	1	3	\N	Angular Step	t	f	f	\N	\N
(0018,1145)	24	4421	0	0	0	0	DS	1	3	\N	Center of Rotation Offset	t	f	f	\N	\N
(0018,1147)	24	4423	0	0	0	0	CS	1	3	\N	Field of View Shape	t	f	f	\N	\N
(0018,1149)	24	4425	0	0	0	0	IS	1-2	3	\N	Field of View Dimension(s)	t	f	f	\N	\N
(0018,1150)	24	4432	0	0	0	0	IS	1	3	\N	Exposure Time	t	f	f	\N	\N
(0018,1151)	24	4433	0	0	0	0	IS	1	3	\N	X-ray Tube Current	t	f	f	\N	\N
(0018,1152)	24	4434	0	0	0	0	IS	1	3	\N	Exposure	t	f	f	\N	\N
(0018,1153)	24	4435	0	0	0	0	IS	1	3	\N	Exposure in uAs	t	f	f	\N	\N
(0018,1154)	24	4436	0	0	0	0	DS	1	3	\N	Average Pulse Width	t	f	f	\N	\N
(0018,1155)	24	4437	0	0	0	0	CS	1	3	\N	Radiation Setting	t	f	f	\N	\N
(0018,1156)	24	4438	0	0	0	0	CS	1	3DX	\N	Rectification Type	t	f	f	\N	\N
(0018,115a)	24	4442	0	0	0	0	CS	1	3	\N	Radiation Mode	t	f	f	\N	\N
(0018,115e)	24	4446	0	0	0	0	DS	1	3	\N	Image Area Dose Product	t	f	f	\N	\N
(0018,1160)	24	4448	0	0	0	0	SH	1	3	\N	Filter Type	t	f	f	\N	\N
(0018,1161)	24	4449	0	0	0	0	LO	1-n	3	\N	Type Of Filters	t	f	f	\N	\N
(0018,1162)	24	4450	0	0	0	0	DS	1	3	\N	Intensifier Size	t	f	f	\N	\N
(0018,1164)	24	4452	0	0	0	0	DS	2	3	\N	Imager Pixel Spacing	t	f	f	\N	\N
(0018,1166)	24	4454	0	0	0	0	CS	1-n	3	\N	Grid	t	f	f	\N	\N
(0018,1170)	24	4464	0	0	0	0	IS	1	3	\N	Generator Power	t	f	f	\N	\N
(0018,1180)	24	4480	0	0	0	0	SH	1	3	\N	Collimator/Grid Name	t	f	f	\N	\N
(0018,1181)	24	4481	0	0	0	0	CS	1	3	\N	Collimator Type	t	f	f	\N	\N
(0018,1182)	24	4482	0	0	0	0	IS	1-2	3	\N	Focal Distance	t	f	f	\N	\N
(0018,1183)	24	4483	0	0	0	0	DS	1-2	3	\N	X Focus Center	t	f	f	\N	\N
(0018,1184)	24	4484	0	0	0	0	DS	1-2	3	\N	Y Focus Center	t	f	f	\N	\N
(0018,1190)	24	4496	0	0	0	0	DS	1-n	3	\N	Focal Spot(s)	t	f	f	\N	\N
(0018,1191)	24	4497	0	0	0	0	CS	1	3DX	\N	Anode Target Material	t	f	f	\N	\N
(0018,11a0)	24	4512	0	0	0	0	DS	1	3DX	\N	Body Part Thickness	t	f	f	\N	\N
(0018,11a2)	24	4514	0	0	0	0	DS	1	3DX	\N	Compression Force	t	f	f	\N	\N
(0018,1200)	24	4608	0	0	0	0	DA	1-n	3	\N	Date of Last Calibration	t	f	f	\N	\N
(0018,1201)	24	4609	0	0	0	0	TM	1-n	3	\N	Time of Last Calibration	t	f	f	\N	\N
(0018,1210)	24	4624	0	0	0	0	SH	1-n	3	\N	Convolution Kernel	t	f	f	\N	\N
(0018,1242)	24	4674	0	0	0	0	IS	1	3	\N	Actual Frame Duration	t	f	f	\N	\N
(0018,1244)	24	4676	0	0	0	0	US	1	3	\N	Preferred Playback Sequencing	t	f	f	\N	\N
(0018,1250)	24	4688	0	0	0	0	SH	1	3	\N	Receive Coil Name	t	f	f	\N	\N
(0018,1251)	24	4689	0	0	0	0	SH	1	3	\N	Transmit Coil Name	t	f	f	\N	\N
(0018,1260)	24	4704	0	0	0	0	SH	1	3	\N	Plate Type	t	f	f	\N	\N
(0018,1261)	24	4705	0	0	0	0	LO	1	3	\N	Phosphor Type	t	f	f	\N	\N
(0018,1300)	24	4864	0	0	0	0	DS	1	3	\N	Scan Velocity	t	f	f	\N	\N
(0018,1301)	24	4865	0	0	0	0	CS	1-n	3	\N	Whole Body Technique	t	f	f	\N	\N
(0018,1302)	24	4866	0	0	0	0	IS	1	3	\N	Scan Length	t	f	f	\N	\N
(0018,1310)	24	4880	0	0	0	0	US	4	3	\N	Acquisition Matrix	t	f	f	\N	\N
(0018,1312)	24	4882	0	0	0	0	CS	1	3	\N	Phase Encoding Direction	t	f	f	\N	\N
(0018,1314)	24	4884	0	0	0	0	DS	1	3	\N	Flip Angle	t	f	f	\N	\N
(0018,1315)	24	4885	0	0	0	0	CS	1	3	\N	Variable Flip Angle Flag	t	f	f	\N	\N
(0018,1316)	24	4886	0	0	0	0	DS	1	3	\N	SAR	t	f	f	\N	\N
(0018,1318)	24	4888	0	0	0	0	DS	1	3	\N	dB/dt	t	f	f	\N	\N
(0018,1400)	24	5120	0	0	0	0	LO	1	3	\N	Acquisition Device Processing Description	t	f	f	\N	\N
(0018,1401)	24	5121	0	0	0	0	LO	1	3	\N	Acquisition Device Processing Code	t	f	f	\N	\N
(0018,1402)	24	5122	0	0	0	0	CS	1	3	\N	Cassette Orientation	t	f	f	\N	\N
(0018,1403)	24	5123	0	0	0	0	CS	1	3	\N	Cassette Size	t	f	f	\N	\N
(0018,1404)	24	5124	0	0	0	0	US	1	3	\N	Exposures on Plate	t	f	f	\N	\N
(0018,1405)	24	5125	0	0	0	0	IS	1	3	\N	Relative X-ray Exposure	t	f	f	\N	\N
(0018,1450)	24	5200	0	0	0	0	DS	1	3	\N	Column Angulation	t	f	f	\N	\N
(0018,1460)	24	5216	0	0	0	0	DS	1	3	\N	Tomo Layer Height	t	f	f	\N	\N
(0018,1470)	24	5232	0	0	0	0	DS	1	3	\N	Tomo Angle	t	f	f	\N	\N
(0018,1480)	24	5248	0	0	0	0	DS	1	3	\N	Tomo Time	t	f	f	\N	\N
(0018,1490)	24	5264	0	0	0	0	CS	1	3DX	\N	Tomo Type	t	f	f	\N	\N
(0018,1491)	24	5265	0	0	0	0	CS	1	3DX	\N	Tomo Class	t	f	f	\N	\N
(0018,1495)	24	5269	0	0	0	0	IS	1	3DX	\N	Number of Tomosynthesis Source Images	t	f	f	\N	\N
(0018,1500)	24	5376	0	0	0	0	CS	1	3	\N	Positioner Motion	t	f	f	\N	\N
(0018,1508)	24	5384	0	0	0	0	CS	1	3DX	\N	Positioner Type	t	f	f	\N	\N
(0018,1510)	24	5392	0	0	0	0	DS	1	3	\N	Positioner Primary Angle	t	f	f	\N	\N
(0018,1511)	24	5393	0	0	0	0	DS	1	3	\N	Positioner Secondary Angle	t	f	f	\N	\N
(0018,1520)	24	5408	0	0	0	0	DS	1-n	3	\N	Positioner Primary Angle Increment	t	f	f	\N	\N
(0018,1521)	24	5409	0	0	0	0	DS	1-n	3	\N	Positioner Secondary Angle Increment	t	f	f	\N	\N
(0018,1530)	24	5424	0	0	0	0	DS	1	3	\N	Detector Primary Angle	t	f	f	\N	\N
(0018,1531)	24	5425	0	0	0	0	DS	1	3	\N	Detector Secondary Angle	t	f	f	\N	\N
(0018,1600)	24	5632	0	0	0	0	CS	1-3	3	\N	Shutter Shape	t	f	f	\N	\N
(0018,1602)	24	5634	0	0	0	0	IS	1	3	\N	Shutter Left Vertical Edge	t	f	f	\N	\N
(0018,1604)	24	5636	0	0	0	0	IS	1	3	\N	Shutter Right Vertical Edge	t	f	f	\N	\N
(0018,1606)	24	5638	0	0	0	0	IS	1	3	\N	Shutter Upper Horizontal Edge	t	f	f	\N	\N
(0018,1608)	24	5640	0	0	0	0	IS	1	3	\N	Shutter Lower Horizontal Edge	t	f	f	\N	\N
(0018,1610)	24	5648	0	0	0	0	IS	2	3	\N	Center of Circular Shutter	t	f	f	\N	\N
(0018,1612)	24	5650	0	0	0	0	IS	1	3	\N	Radius of Circular Shutter	t	f	f	\N	\N
(0018,1620)	24	5664	0	0	0	0	IS	1-n	3	\N	Vertices of Polygonal Shutter	t	f	f	\N	\N
(0018,1622)	24	5666	0	0	0	0	US	1	3SCP	\N	Shutter Presentation Value	t	f	f	\N	\N
(0018,1623)	24	5667	0	0	0	0	US	1	3SCP	\N	Shutter Overlay Group	t	f	f	\N	\N
(0018,1700)	24	5888	0	0	0	0	CS	1-3	3	\N	Collimator Shape	t	f	f	\N	\N
(0018,1702)	24	5890	0	0	0	0	IS	1	3	\N	Collimator Left Vertical Edge	t	f	f	\N	\N
(0018,1704)	24	5892	0	0	0	0	IS	1	3	\N	Collimator Right Vertical Edge	t	f	f	\N	\N
(0018,1706)	24	5894	0	0	0	0	IS	1	3	\N	Collimator Upper Horizontal Edge	t	f	f	\N	\N
(0018,1708)	24	5896	0	0	0	0	IS	1	3	\N	Collimator Lower Horizontal Edge	t	f	f	\N	\N
(0018,1710)	24	5904	0	0	0	0	IS	2	3	\N	Center of Circular Collimator	t	f	f	\N	\N
(0018,1712)	24	5906	0	0	0	0	IS	1	3	\N	Radius of Circular Collimator	t	f	f	\N	\N
(0018,1720)	24	5920	0	0	0	0	IS	1-n	3	\N	Vertices of Polygonal Collimator	t	f	f	\N	\N
(0018,1800)	24	6144	0	0	0	0	CS	1	3WAV	\N	Acquisition Time Synchronized	t	f	f	\N	\N
(0018,1801)	24	6145	0	0	0	0	SH	1	3WAV	\N	Time Source	t	f	f	\N	\N
(0018,1802)	24	6146	0	0	0	0	CS	1	3WAV	\N	Time Distribution Protocol	t	f	f	\N	\N
(0018,2001)	24	8193	0	0	0	0	IS	1-n	3SC	\N	Page Number Vector	t	f	f	\N	\N
(0018,2002)	24	8194	0	0	0	0	SH	1-n	3SC	\N	Frame Label Vector	t	f	f	\N	\N
(0018,2003)	24	8195	0	0	0	0	DS	1-n	3SC	\N	Frame Primary Angle Vector	t	f	f	\N	\N
(0018,2004)	24	8196	0	0	0	0	DS	1-n	3SC	\N	Frame Secondary Angle Vector	t	f	f	\N	\N
(0018,2005)	24	8197	0	0	0	0	DS	1-n	3SC	\N	Slice Location Vector	t	f	f	\N	\N
(0018,2006)	24	8198	0	0	0	0	SH	1-n	3SC	\N	Display Window Label Vector	t	f	f	\N	\N
(0018,2010)	24	8208	0	0	0	0	DS	2	3SC	\N	Nominal Scanned Pixel Spacing	t	f	f	\N	\N
(0018,2020)	24	8224	0	0	0	0	CS	1	3SC	\N	Digitizing Device Transport Direction	t	f	f	\N	\N
(0018,2030)	24	8240	0	0	0	0	DS	1	3SC	\N	Rotation of Scanned Film	t	f	f	\N	\N
(0018,3100)	24	12544	0	0	0	0	CS	1	3USP	\N	IVUS Acquisition	t	f	f	\N	\N
(0018,3101)	24	12545	0	0	0	0	DS	1	3USP	\N	IVUS Pullback Rate	t	f	f	\N	\N
(0018,3102)	24	12546	0	0	0	0	DS	1	3USP	\N	IVUS Gated Rate	t	f	f	\N	\N
(0018,3103)	24	12547	0	0	0	0	IS	1	3USP	\N	IVUS Pullback Start Frame Number	t	f	f	\N	\N
(0018,3104)	24	12548	0	0	0	0	IS	1	3USP	\N	IVUS Pullback Stop Frame Number	t	f	f	\N	\N
(0018,3105)	24	12549	0	0	0	0	IS	1-n	3USP	\N	Lesion Number	t	f	f	\N	\N
(0018,5000)	24	20480	0	0	0	0	SH	1-n	3	\N	Output Power	t	f	f	\N	\N
(0018,5010)	24	20496	0	0	0	0	LO	3	3	\N	Transducer Data	t	f	f	\N	\N
(0018,5012)	24	20498	0	0	0	0	DS	1	3	\N	Focus Depth	t	f	f	\N	\N
(0018,5020)	24	20512	0	0	0	0	LO	1	3	\N	Processing Function	t	f	f	\N	\N
(0018,5021)	24	20513	0	0	0	0	LO	1	3	\N	Postprocessing Function	t	f	f	\N	\N
(0018,5022)	24	20514	0	0	0	0	DS	1	3	\N	Mechanical Index	t	f	f	\N	\N
(0018,5024)	24	20516	0	0	0	0	DS	1	3	\N	Bone Thermal Index	t	f	f	\N	\N
(0018,5026)	24	20518	0	0	0	0	DS	1	3	\N	Cranial Thermal Index	t	f	f	\N	\N
(0018,5027)	24	20519	0	0	0	0	DS	1	3	\N	Soft Tissue Thermal Index	t	f	f	\N	\N
(0018,5028)	24	20520	0	0	0	0	DS	1	3	\N	Soft Tissue-Focus Thermal Index	t	f	f	\N	\N
(0018,5029)	24	20521	0	0	0	0	DS	1	3	\N	Soft Tissue-Surface Thermal Index	t	f	f	\N	\N
(0018,5050)	24	20560	0	0	0	0	IS	1	3	\N	Depth of Scan Field	t	f	f	\N	\N
(0018,5100)	24	20736	0	0	0	0	CS	1	3	\N	Patient Position	t	f	f	\N	\N
(0018,5101)	24	20737	0	0	0	0	CS	1	3	\N	View Position	t	f	f	\N	\N
(0018,5104)	24	20740	0	0	0	0	SQ	1	3DX	\N	Projection Eponymous Name Code Sequence	t	f	f	\N	\N
(0018,6000)	24	24576	0	0	0	0	DS	1	3	\N	Sensitivity	t	f	f	\N	\N
(0018,6011)	24	24593	0	0	0	0	SQ	1	3	\N	Sequence of Ultrasound Regions	t	f	f	\N	\N
(0018,6012)	24	24594	0	0	0	0	US	1	3	\N	Region Spatial Format	t	f	f	\N	\N
(0018,6014)	24	24596	0	0	0	0	US	1	3	\N	Region Data Type	t	f	f	\N	\N
(0018,6016)	24	24598	0	0	0	0	UL	1	3	\N	Region Flags	t	f	f	\N	\N
(0018,6018)	24	24600	0	0	0	0	UL	1	3	\N	Region Location Min X0	t	f	f	\N	\N
(0018,601a)	24	24602	0	0	0	0	UL	1	3	\N	Region Location Min Y0	t	f	f	\N	\N
(0018,601c)	24	24604	0	0	0	0	UL	1	3	\N	Region Location Max X1	t	f	f	\N	\N
(0018,601e)	24	24606	0	0	0	0	UL	1	3	\N	Region Location Max Y1	t	f	f	\N	\N
(0018,6020)	24	24608	0	0	0	0	SL	1	3	\N	Reference Pixel X0	t	f	f	\N	\N
(0018,6022)	24	24610	0	0	0	0	SL	1	3	\N	Reference Pixel Y0	t	f	f	\N	\N
(0018,6024)	24	24612	0	0	0	0	US	1	3	\N	Physical Units X Direction	t	f	f	\N	\N
(0018,6026)	24	24614	0	0	0	0	US	1	3	\N	Physical Units Y Direction	t	f	f	\N	\N
(0018,6028)	24	24616	0	0	0	0	FD	1	3	\N	Reference Pixel Physical Value X	t	f	f	\N	\N
(0018,602a)	24	24618	0	0	0	0	FD	1	3	\N	Reference Pixel Physical Value Y	t	f	f	\N	\N
(0018,602c)	24	24620	0	0	0	0	FD	1	3	\N	Physical Delta X	t	f	f	\N	\N
(0018,602e)	24	24622	0	0	0	0	FD	1	3	\N	Physical Delta Y	t	f	f	\N	\N
(0018,6030)	24	24624	0	0	0	0	UL	1	3	\N	Transducer Frequency	t	f	f	\N	\N
(0018,6031)	24	24625	0	0	0	0	CS	1	3	\N	Transducer Type	t	f	f	\N	\N
(0018,6032)	24	24626	0	0	0	0	UL	1	3	\N	Pulse Repetition Frequency	t	f	f	\N	\N
(0018,6034)	24	24628	0	0	0	0	FD	1	3	\N	Doppler Correction Angle	t	f	f	\N	\N
(0018,6036)	24	24630	0	0	0	0	FD	1	3	\N	Steering Angle	t	f	f	\N	\N
(0018,6044)	24	24644	0	0	0	0	US	1	3	\N	Pixel Component Organization	t	f	f	\N	\N
(0018,6046)	24	24646	0	0	0	0	UL	1	3	\N	Pixel Component Mask	t	f	f	\N	\N
(0018,6048)	24	24648	0	0	0	0	UL	1	3	\N	Pixel Component Range Start	t	f	f	\N	\N
(0018,604a)	24	24650	0	0	0	0	UL	1	3	\N	Pixel Component Range Stop	t	f	f	\N	\N
(0018,604c)	24	24652	0	0	0	0	US	1	3	\N	Pixel Component Physical Units	t	f	f	\N	\N
(0018,604e)	24	24654	0	0	0	0	US	1	3	\N	Pixel Component Data Type	t	f	f	\N	\N
(0018,6050)	24	24656	0	0	0	0	UL	1	3	\N	Number of Table Break Points	t	f	f	\N	\N
(0018,6052)	24	24658	0	0	0	0	UL	1-n	3	\N	Table of X Break Points	t	f	f	\N	\N
(0018,6054)	24	24660	0	0	0	0	FD	1-n	3	\N	Table of Y Break Points	t	f	f	\N	\N
(0018,6056)	24	24662	0	0	0	0	UL	1	3	\N	Number of Table Entries	t	f	f	\N	\N
(0018,6058)	24	24664	0	0	0	0	UL	1-n	3	\N	Table of Pixel Values	t	f	f	\N	\N
(0018,605a)	24	24666	0	0	0	0	FL	1-n	3	\N	Table of Parameter Values	t	f	f	\N	\N
(0018,7000)	24	28672	0	0	0	0	CS	1	3DX	\N	Detector Conditions Nominal Flag	t	f	f	\N	\N
(0018,7001)	24	28673	0	0	0	0	DS	1	3DX	\N	Detector Temperature	t	f	f	\N	\N
(0018,7004)	24	28676	0	0	0	0	CS	1	3DX	\N	Detector Type	t	f	f	\N	\N
(0018,7005)	24	28677	0	0	0	0	CS	1	3DX	\N	Detector Configuration	t	f	f	\N	\N
(0018,7006)	24	28678	0	0	0	0	LT	1	3DX	\N	Detector Description	t	f	f	\N	\N
(0018,7008)	24	28680	0	0	0	0	LT	1	3DX	\N	Detector Mode	t	f	f	\N	\N
(0018,700a)	24	28682	0	0	0	0	SH	1	3DX	\N	Detector ID	t	f	f	\N	\N
(0018,700c)	24	28684	0	0	0	0	DA	1	3DX	\N	Date of Last Detector Calibration 	t	f	f	\N	\N
(0018,700e)	24	28686	0	0	0	0	TM	1	3DX	\N	Time of Last Detector Calibration	t	f	f	\N	\N
(0018,7010)	24	28688	0	0	0	0	IS	1	3DX	\N	Exposures on Detector Since Last Calibration	t	f	f	\N	\N
(0018,7011)	24	28689	0	0	0	0	IS	1	3DX	\N	Exposures on Detector Since Manufactured	t	f	f	\N	\N
(0018,7012)	24	28690	0	0	0	0	DS	1	3DX	\N	Detector Time Since Last Exposure	t	f	f	\N	\N
(0018,7014)	24	28692	0	0	0	0	DS	1	3DX	\N	Detector Active Time	t	f	f	\N	\N
(0018,7016)	24	28694	0	0	0	0	DS	1	3DX	\N	Detector Activation Offset From Exposure	t	f	f	\N	\N
(0018,701a)	24	28698	0	0	0	0	DS	2	3DX	\N	Detector Binning	t	f	f	\N	\N
(0018,7020)	24	28704	0	0	0	0	DS	2	3DX	\N	Detector Element Physical Size	t	f	f	\N	\N
(0018,7022)	24	28706	0	0	0	0	DS	2	3DX	\N	Detector Element Spacing	t	f	f	\N	\N
(0018,7024)	24	28708	0	0	0	0	CS	1	3DX	\N	Detector Active Shape	t	f	f	\N	\N
(0018,7026)	24	28710	0	0	0	0	DS	1-2	3DX	\N	Detector Active Dimensions	t	f	f	\N	\N
(0018,7028)	24	28712	0	0	0	0	DS	2	3DX	\N	Detector Active Origin	t	f	f	\N	\N
(0018,7030)	24	28720	0	0	0	0	DS	2	3DX	\N	Field of View Origin	t	f	f	\N	\N
(0018,7032)	24	28722	0	0	0	0	DS	1	3DX	\N	Field of View Rotation	t	f	f	\N	\N
(0018,7034)	24	28724	0	0	0	0	CS	1	3DX	\N	Field of View Horizontal Flip	t	f	f	\N	\N
(0018,7040)	24	28736	0	0	0	0	LT	1	3DX	\N	Grid Absorbing Material	t	f	f	\N	\N
(0018,7041)	24	28737	0	0	0	0	LT	1	3DX	\N	Grid Spacing Material	t	f	f	\N	\N
(0018,7042)	24	28738	0	0	0	0	DS	1	3DX	\N	Grid Thickness	t	f	f	\N	\N
(0018,7044)	24	28740	0	0	0	0	DS	1	3DX	\N	Grid Pitch	t	f	f	\N	\N
(0018,7046)	24	28742	0	0	0	0	IS	2	3DX	\N	Grid Aspect Ratio	t	f	f	\N	\N
(0018,7048)	24	28744	0	0	0	0	DS	1	3DX	\N	Grid Period	t	f	f	\N	\N
(0018,704c)	24	28748	0	0	0	0	DS	1	3DX	\N	Grid Focal Distance	t	f	f	\N	\N
(0018,7052)	24	28754	0	0	0	0	DS	1-n	3DX	\N	Filter Thickness Minimum	t	f	f	\N	\N
(0018,7054)	24	28756	0	0	0	0	DS	1-n	3DX	\N	Filter Thickness Maximum	t	f	f	\N	\N
(0018,7060)	24	28768	0	0	0	0	CS	1	3DX	\N	Exposure Control Mode	t	f	f	\N	\N
(0018,7062)	24	28770	0	0	0	0	LT	1	3DX	\N	Exposure Control Mode Description	t	f	f	\N	\N
(0018,7064)	24	28772	0	0	0	0	CS	1	3DX	\N	Exposure Status	t	f	f	\N	\N
(0018,7065)	24	28773	0	0	0	0	DS	1	3DX	\N	Phototimer Setting	t	f	f	\N	\N
(0018,8150)	24	33104	0	0	0	0	DS	1	3CP	\N	Exposure Time In uS	t	f	f	\N	\N
(0018,8151)	24	33105	0	0	0	0	DS	1	3CP	\N	X-ray Tube Current in uA	t	f	f	\N	\N
(0018,9004)	24	36868	0	0	0	0	CS	1	3MR	\N	Content Qualification	t	f	f	\N	\N
(0018,9005)	24	36869	0	0	0	0	SH	1	3MR	\N	Pulse Sequence Name	t	f	f	\N	\N
(0018,9006)	24	36870	0	0	0	0	SQ	1	3MR	\N	MR Imaging Modifier Sequence	t	f	f	\N	\N
(0018,9008)	24	36872	0	0	0	0	CS	1	3MR	\N	Echo Pulse Sequence	t	f	f	\N	\N
(0018,9009)	24	36873	0	0	0	0	CS	1	3MR	\N	Inversion Recovery	t	f	f	\N	\N
(0018,9010)	24	36880	0	0	0	0	CS	1	3MR	\N	Flow Compensation	t	f	f	\N	\N
(0018,9011)	24	36881	0	0	0	0	CS	1	3MR	\N	Multiple Spin Echo	t	f	f	\N	\N
(0018,9012)	24	36882	0	0	0	0	CS	1	3MR	\N	Multi-planar Excitation	t	f	f	\N	\N
(0018,9014)	24	36884	0	0	0	0	CS	1	3MR	\N	Phase Contrast	t	f	f	\N	\N
(0018,9015)	24	36885	0	0	0	0	CS	1	3MR	\N	Time of Flight Contrast	t	f	f	\N	\N
(0018,9016)	24	36886	0	0	0	0	CS	1	3MR	\N	Spoiling	t	f	f	\N	\N
(0018,9017)	24	36887	0	0	0	0	CS	1	3MR	\N	Steady State Pulse Sequence	t	f	f	\N	\N
(0018,9018)	24	36888	0	0	0	0	CS	1	3MR	\N	Echo Planar Pulse Sequence	t	f	f	\N	\N
(0018,9019)	24	36889	0	0	0	0	FD	1	3MR	\N	Tag Angle First Axis	t	f	f	\N	\N
(0018,9020)	24	36896	0	0	0	0	CS	1	3MR	\N	Magnetization Transfer	t	f	f	\N	\N
(0018,9021)	24	36897	0	0	0	0	CS	1	3MR	\N	T2 Preparation	t	f	f	\N	\N
(0018,9022)	24	36898	0	0	0	0	CS	1	3MR	\N	Blood Signal Nulling	t	f	f	\N	\N
(0018,9024)	24	36900	0	0	0	0	CS	1	3MR	\N	Saturation Recovery	t	f	f	\N	\N
(0018,9025)	24	36901	0	0	0	0	CS	1	3MR	\N	Spectrally Selected Suppression	t	f	f	\N	\N
(0018,9026)	24	36902	0	0	0	0	CS	1	3MR	\N	Spectrally Selected Excitation	t	f	f	\N	\N
(0018,9027)	24	36903	0	0	0	0	CS	1	3MR	\N	Spatial Pre-saturation	t	f	f	\N	\N
(0018,9028)	24	36904	0	0	0	0	CS	1	3MR	\N	Tagging	t	f	f	\N	\N
(0018,9029)	24	36905	0	0	0	0	CS	1	3MR	\N	Oversampling Phase	t	f	f	\N	\N
(0018,9030)	24	36912	0	0	0	0	FD	1	3MR	\N	Tag Spacing First Dimension	t	f	f	\N	\N
(0018,9032)	24	36914	0	0	0	0	CS	1	3MR	\N	Geometry of k-Space Traversal	t	f	f	\N	\N
(0018,9033)	24	36915	0	0	0	0	CS	1	3MR	\N	Segmented k-Space Traversal	t	f	f	\N	\N
(0018,9034)	24	36916	0	0	0	0	CS	1	3MR	\N	Rectilinear Phase Encode Reordering	t	f	f	\N	\N
(0018,9036)	24	36918	0	0	0	0	CS	1	3MR	\N	Partial Fourier Direction	t	f	f	\N	\N
(0018,9037)	24	36919	0	0	0	0	CS	1	3MR	\N	Cardiac Synchronization Technique	t	f	f	\N	\N
(0018,9041)	24	36929	0	0	0	0	LO	1	3MR	\N	Receive Coil Manufacturer Name	t	f	f	\N	\N
(0018,9042)	24	36930	0	0	0	0	SQ	1	3MR	\N	MR Receive Coil Sequence	t	f	f	\N	\N
(0018,9043)	24	36931	0	0	0	0	CS	1	3MR	\N	Receive Coil Type 	t	f	f	\N	\N
(0018,9044)	24	36932	0	0	0	0	CS	1	3MR	\N	Quadrature Receive Coil 	t	f	f	\N	\N
(0018,9045)	24	36933	0	0	0	0	SQ	1	3MR	\N	Multi-Coil Definition Sequence	t	f	f	\N	\N
(0018,9046)	24	36934	0	0	0	0	LO	1	3MR	\N	Multi-Coil Configuration 	t	f	f	\N	\N
(0018,9047)	24	36935	0	0	0	0	SH	1	3MR	\N	Multi-Coil Element Name	t	f	f	\N	\N
(0018,9048)	24	36936	0	0	0	0	CS	1	3MR	\N	Multi-Coil Element Used	t	f	f	\N	\N
(0018,9049)	24	36937	0	0	0	0	SQ	1	3MR	\N	MR Transmit Coil Sequence	t	f	f	\N	\N
(0018,9050)	24	36944	0	0	0	0	LO	1	3MR	\N	Transmit Coil Manufacturer Name	t	f	f	\N	\N
(0018,9051)	24	36945	0	0	0	0	CS	1	3MR	\N	Transmit Coil Type	t	f	f	\N	\N
(0018,9052)	24	36946	0	0	0	0	FD	1-2	3MR	\N	Spectral Width	t	f	f	\N	\N
(0018,9053)	24	36947	0	0	0	0	FD	1-2	3MR	\N	Chemical Shift Reference	t	f	f	\N	\N
(0018,9054)	24	36948	0	0	0	0	CS	1	3MR	\N	Volume Localization Technique	t	f	f	\N	\N
(0018,9058)	24	36952	0	0	0	0	US	1	3MR	\N	MR Acquisition Frequency Encoding Steps	t	f	f	\N	\N
(0018,9060)	24	36960	0	0	0	0	CS	1-2	3MR	\N	De-coupled Nucleus	t	f	f	\N	\N
(0018,9061)	24	36961	0	0	0	0	FD	1-2	3MR	\N	De-coupling Frequency	t	f	f	\N	\N
(0018,9062)	24	36962	0	0	0	0	CS	1	3MR	\N	De-coupling Method	t	f	f	\N	\N
(0018,9063)	24	36963	0	0	0	0	FD	1-2	3MR	\N	De-coupling Chemical Shift Reference	t	f	f	\N	\N
(0018,9064)	24	36964	0	0	0	0	CS	1	3MR	\N	k-space Filtering	t	f	f	\N	\N
(0018,9065)	24	36965	0	0	0	0	CS	1-2	3MR	\N	Time Domain Filtering	t	f	f	\N	\N
(0018,9066)	24	36966	0	0	0	0	US	1-2	3MR	\N	Number of Zero fills	t	f	f	\N	\N
(0018,9067)	24	36967	0	0	0	0	CS	1	3MR	\N	Baseline Correction	t	f	f	\N	\N
(0018,9070)	24	36976	0	0	0	0	FD	1	3MR	\N	Cardiac R-R Interval Specified	t	f	f	\N	\N
(0018,9073)	24	36979	0	0	0	0	FD	1	3MR	\N	Acquisition Duration	t	f	f	\N	\N
(0018,9074)	24	36980	0	0	0	0	DT	1	3MR	\N	Frame Acquisition Datetime	t	f	f	\N	\N
(0018,9075)	24	36981	0	0	0	0	CS	1	3MR	\N	Diffusion Directionality	t	f	f	\N	\N
(0018,9076)	24	36982	0	0	0	0	SQ	1	3MR	\N	Diffusion Gradient Direction Sequence	t	f	f	\N	\N
(0018,9077)	24	36983	0	0	0	0	CS	1	3MR	\N	Parallel Acquisition	t	f	f	\N	\N
(0018,9078)	24	36984	0	0	0	0	CS	1	3MR	\N	Parallel Acquisition Technique	t	f	f	\N	\N
(0018,9079)	24	36985	0	0	0	0	FD	1-n	3MR	\N	Inversion Times	t	f	f	\N	\N
(0018,9080)	24	36992	0	0	0	0	ST	1	3MR	\N	Metabolite Map Description	t	f	f	\N	\N
(0018,9081)	24	36993	0	0	0	0	CS	1	3MR	\N	Partial Fourier	t	f	f	\N	\N
(0018,9082)	24	36994	0	0	0	0	FD	1	3MR	\N	Effective Echo Time	t	f	f	\N	\N
(0018,9084)	24	36996	0	0	0	0	SQ	1	3MR	\N	Chemical Shift Sequence	t	f	f	\N	\N
(0018,9085)	24	36997	0	0	0	0	CS	1	3MR	\N	Cardiac Signal Source	t	f	f	\N	\N
(0018,9087)	24	36999	0	0	0	0	FD	1	3MR	\N	Diffusion b-value	t	f	f	\N	\N
(0018,9089)	24	37001	0	0	0	0	FD	3	3MR	\N	Diffusion Gradient Orientation	t	f	f	\N	\N
(0018,9090)	24	37008	0	0	0	0	FD	3	3MR	\N	Velocity Encoding Direction	t	f	f	\N	\N
(0018,9091)	24	37009	0	0	0	0	FD	1	3MR	\N	Velocity Encoding Minimum Value	t	f	f	\N	\N
(0018,9093)	24	37011	0	0	0	0	US	1	3MR	\N	Number of k-Space Trajectories	t	f	f	\N	\N
(0018,9094)	24	37012	0	0	0	0	CS	1	3MR	\N	Coverage of k-Space	t	f	f	\N	\N
(0018,9095)	24	37013	0	0	0	0	UL	1	3MR	\N	Spectroscopy Acquisition Phase Rows	t	f	f	\N	\N
(0018,9098)	24	37016	0	0	0	0	FD	1-2	3MR	\N	Transmitter Frequency	t	f	f	\N	\N
(0018,9100)	24	37120	0	0	0	0	CS	1-2	3MR	\N	Resonant Nucleus	t	f	f	\N	\N
(0018,9101)	24	37121	0	0	0	0	CS	1	3MR	\N	Frequency Correction	t	f	f	\N	\N
(0018,9103)	24	37123	0	0	0	0	SQ	1	3MR	\N	MR Spectroscopy FOV/Geometry Sequence	t	f	f	\N	\N
(0018,9104)	24	37124	0	0	0	0	FD	1	3MR	\N	Slab Thickness	t	f	f	\N	\N
(0018,9105)	24	37125	0	0	0	0	FD	3	3MR	\N	Slab Orientation	t	f	f	\N	\N
(0018,9106)	24	37126	0	0	0	0	FD	3	3MR	\N	Mid Slab Position	t	f	f	\N	\N
(0018,9107)	24	37127	0	0	0	0	SQ	1	3MR	\N	MR Spatial Saturation Sequence	t	f	f	\N	\N
(0018,9112)	24	37138	0	0	0	0	SQ	1	3MR	\N	MR Timing and Related Parameters Sequence	t	f	f	\N	\N
(0018,9114)	24	37140	0	0	0	0	SQ	1	3MR	\N	MR Echo Sequence	t	f	f	\N	\N
(0018,9115)	24	37141	0	0	0	0	SQ	1	3MR	\N	MR Modifier Sequence	t	f	f	\N	\N
(0018,9117)	24	37143	0	0	0	0	SQ	1	3MR	\N	MR Diffusion Sequence	t	f	f	\N	\N
(0018,9118)	24	37144	0	0	0	0	SQ	1	3MR	\N	Cardiac Trigger Sequence	t	f	f	\N	\N
(0018,9119)	24	37145	0	0	0	0	SQ	1	3MR	\N	MR Averages Sequence	t	f	f	\N	\N
(0018,9125)	24	37157	0	0	0	0	SQ	1	3MR	\N	MR FOV/Geometry Sequence	t	f	f	\N	\N
(0018,9126)	24	37158	0	0	0	0	SQ	1	3MR	\N	Volume Localization Sequence	t	f	f	\N	\N
(0018,9127)	24	37159	0	0	0	0	UL	1	3MR	\N	Spectroscopy Acquisition Data Columns	t	f	f	\N	\N
(0018,9147)	24	37191	0	0	0	0	CS	1	3MR	\N	Diffusion Anisotropy Type	t	f	f	\N	\N
(0018,9151)	24	37201	0	0	0	0	DT	1	3MR	\N	Frame Reference Datetime	t	f	f	\N	\N
(0018,9152)	24	37202	0	0	0	0	SQ	1	3MR	\N	MR Metabolite Map Sequence	t	f	f	\N	\N
(0018,9155)	24	37205	0	0	0	0	FD	1	3MR	\N	Parallel Reduction Factor out-of-plane	t	f	f	\N	\N
(0018,9159)	24	37209	0	0	0	0	UL	1	3MR	\N	Spectroscopy Acquisition Out-of-plane Phase Steps	t	f	f	\N	\N
(0018,9166)	24	37222	0	0	0	0	CS	1	3MR	\N	Bulk Motion Status	t	f	f	\N	\N
(0018,9168)	24	37224	0	0	0	0	FD	1	3MR	\N	Parallel Reduction Factor Second In-plane	t	f	f	\N	\N
(0018,9169)	24	37225	0	0	0	0	CS	1	3MR	\N	Cardiac Beat Rejection Technique	t	f	f	\N	\N
(0018,9170)	24	37232	0	0	0	0	CS	1	3MR	\N	Respiratory Motion Compensation Technique	t	f	f	\N	\N
(0018,9171)	24	37233	0	0	0	0	CS	1	3MR	\N	Respiratory Signal Source	t	f	f	\N	\N
(0018,9172)	24	37234	0	0	0	0	CS	1	3MR	\N	Bulk Motion Compensation Technique	t	f	f	\N	\N
(0018,9173)	24	37235	0	0	0	0	CS	1	3MR	\N	Bulk Motion Signal Source	t	f	f	\N	\N
(0018,9174)	24	37236	0	0	0	0	CS	1	3MR	\N	Applicable Safety Standard Agency	t	f	f	\N	\N
(0018,9175)	24	37237	0	0	0	0	LO	1	3MR	\N	Applicable Safety Standard Description	t	f	f	\N	\N
(0018,9176)	24	37238	0	0	0	0	SQ	1	3MR	\N	Operating Mode Sequence	t	f	f	\N	\N
(0018,9177)	24	37239	0	0	0	0	CS	1	3MR	\N	Operating Mode Type	t	f	f	\N	\N
(0018,9178)	24	37240	0	0	0	0	CS	1	3MR	\N	Operating Mode	t	f	f	\N	\N
(0018,9179)	24	37241	0	0	0	0	CS	1	3MR	\N	Specific Absorption Rate Definition	t	f	f	\N	\N
(0018,9180)	24	37248	0	0	0	0	CS	1	3MR	\N	Gradient Output Type	t	f	f	\N	\N
(0018,9181)	24	37249	0	0	0	0	FD	1	3MR	\N	Specific Absorption Rate Value	t	f	f	\N	\N
(0018,9182)	24	37250	0	0	0	0	FD	1	3MR	\N	Gradient Output	t	f	f	\N	\N
(0018,9183)	24	37251	0	0	0	0	CS	1	3MR	\N	Flow Compensation Direction	t	f	f	\N	\N
(0018,9184)	24	37252	0	0	0	0	FD	1	3MR	\N	Tagging Delay	t	f	f	\N	\N
(0018,9197)	24	37271	0	0	0	0	SQ	1	3MR	\N	MR Velocity Encoding Sequence	t	f	f	\N	\N
(0018,9198)	24	37272	0	0	0	0	CS	1	3MR	\N	First Order Phase Correction	t	f	f	\N	\N
(0018,9199)	24	37273	0	0	0	0	CS	1	3MR	\N	Water Referenced Phase Correction	t	f	f	\N	\N
(0018,9200)	24	37376	0	0	0	0	CS	1	3MR	\N	MR Spectroscopy Acquisition Type	t	f	f	\N	\N
(0018,9214)	24	37396	0	0	0	0	CS	1	3MR	\N	Respiratory Cycle Position	t	f	f	\N	\N
(0018,9217)	24	37399	0	0	0	0	FD	1	3MR	\N	Velocity Encoding Maximum Value	t	f	f	\N	\N
(0018,9219)	24	37401	0	0	0	0	SS	1	3MR	\N	Tag Angle Second Axis	t	f	f	\N	\N
(0018,9220)	24	37408	0	0	0	0	FD	1	3MR	\N	Frame Acquisition Duration	t	f	f	\N	\N
(0018,9226)	24	37414	0	0	0	0	SQ	1	3MR	\N	MR Image Frame Type Sequence	t	f	f	\N	\N
(0018,9227)	24	37415	0	0	0	0	SQ	1	3MR	\N	MR Spectroscopy Frame Type Sequence	t	f	f	\N	\N
(0018,9231)	24	37425	0	0	0	0	US	1	3MR	\N	MR Acquisition Phase Encoding Steps in-plane	t	f	f	\N	\N
(0018,9232)	24	37426	0	0	0	0	US	1	3MR	\N	MR Acquisition Phase Encoding Steps out-of-plane	t	f	f	\N	\N
(0018,9234)	24	37428	0	0	0	0	UL	1	3MR	\N	Spectroscopy Acquisition Phase Columns	t	f	f	\N	\N
(0018,9236)	24	37430	0	0	0	0	CS	1	3MR	\N	Cardiac Cycle Position	t	f	f	\N	\N
(0018,9239)	24	37433	0	0	0	0	SQ	1	3MR	\N	Specific Absorption Rate Sequence	t	f	f	\N	\N
(0020,000d)	32	13	0	0	0	0	UI	1	3	\N	Study Instance UID	t	f	f	\N	\N
(0020,000e)	32	14	0	0	0	0	UI	1	3	\N	Series Instance UID	t	f	f	\N	\N
(0020,0011)	32	17	0	0	0	0	IS	1	3	\N	Series Number	t	f	f	\N	\N
(0020,0012)	32	18	0	0	0	0	IS	1	3	\N	Acquisition Number	t	f	f	\N	\N
(0020,0013)	32	19	0	0	0	0	IS	1	3	\N	Instance (formerly Image) Number	t	f	f	\N	\N
(0020,0019)	32	25	0	0	0	0	IS	1	3PCF	\N	Item Number	t	f	f	\N	\N
(0020,0020)	32	32	0	0	0	0	CS	2	3	\N	Patient Orientation	t	f	f	\N	\N
(0020,0032)	32	50	0	0	0	0	DS	3	3	\N	Image Position (Patient)	t	f	f	\N	\N
(0020,0037)	32	55	0	0	0	0	DS	6	3	\N	Image Orientation (Patient)	t	f	f	\N	\N
(0020,0052)	32	82	0	0	0	0	UI	1	3	\N	Frame of Reference UID	t	f	f	\N	\N
(0020,0060)	32	96	0	0	0	0	CS	1	3	\N	Laterality	t	f	f	\N	\N
(0020,0062)	32	98	0	0	0	0	CS	1	3DX	\N	Image Laterality	t	f	f	\N	\N
(0020,0100)	32	256	0	0	0	0	IS	1	3	\N	Temporal Position Identifier	t	f	f	\N	\N
(0020,0105)	32	261	0	0	0	0	IS	1	3	\N	Number of Temporal Positions	t	f	f	\N	\N
(0020,0110)	32	272	0	0	0	0	DS	1	3	\N	Temporal Resolution	t	f	f	\N	\N
(0020,0200)	32	512	0	0	0	0	UI	1	3WAV	\N	Synchronization Frame Of Reference UID	t	f	f	\N	\N
(0020,1002)	32	4098	0	0	0	0	IS	1	3	\N	Images in Acquisition	t	f	f	\N	\N
(0020,1040)	32	4160	0	0	0	0	LO	1	3	\N	Position Reference Indicator	t	f	f	\N	\N
(0020,1041)	32	4161	0	0	0	0	DS	1	3	\N	Slice Location	t	f	f	\N	\N
(0020,1200)	32	4608	0	0	0	0	IS	1	3	\N	Number of Patient Related Studies	t	f	f	\N	\N
(0020,1202)	32	4610	0	0	0	0	IS	1	3CP	\N	Number of Patient Related Series	t	f	f	\N	\N
(0020,1204)	32	4612	0	0	0	0	IS	1	3	\N	Number of Patient Related Instances	t	f	f	\N	\N
(0020,1206)	32	4614	0	0	0	0	IS	1	3	\N	Number of Study Related Series	t	f	f	\N	\N
(0020,1208)	32	4616	0	0	0	0	IS	1	3CP	\N	Number of Study Related Instances	t	f	f	\N	\N
(0020,1209)	32	4617	0	0	0	0	IS	1	3CP	\N	Number of Series Related Instances	t	f	f	\N	\N
(0020,4000)	32	16384	0	0	0	0	LT	1	3	\N	Image Comments	t	f	f	\N	\N
(0020,9056)	32	36950	0	0	0	0	SH	1	3MR	\N	Stack ID	t	f	f	\N	\N
(0020,9057)	32	36951	0	0	0	0	UL	1	3MR	\N	In-Stack Position Number	t	f	f	\N	\N
(0020,9071)	32	36977	0	0	0	0	SQ	1	3MR	\N	Frame Anatomy Sequence	t	f	f	\N	\N
(0020,9072)	32	36978	0	0	0	0	CS	1	3MR	\N	Frame Laterality	t	f	f	\N	\N
(0020,9111)	32	37137	0	0	0	0	SQ	1	3MR	\N	Frame Content Sequence	t	f	f	\N	\N
(0020,9113)	32	37139	0	0	0	0	SQ	1	3MR	\N	Plane Position Sequence	t	f	f	\N	\N
(0020,9116)	32	37142	0	0	0	0	SQ	1	3MR	\N	Plane Orientation Sequence	t	f	f	\N	\N
(0020,9128)	32	37160	0	0	0	0	UL	1	3MR	\N	Temporal Position Index	t	f	f	\N	\N
(0020,9153)	32	37203	0	0	0	0	FD	1	3MR	\N	Trigger Delay Time	t	f	f	\N	\N
(0020,9156)	32	37206	0	0	0	0	US	1	3MR	\N	Frame Acquisition Number	t	f	f	\N	\N
(0020,9157)	32	37207	0	0	0	0	UL	1-n	3MR	\N	Dimension Index Values	t	f	f	\N	\N
(0020,9158)	32	37208	0	0	0	0	LT	1	3MR	\N	Frame Comments	t	f	f	\N	\N
(0020,9161)	32	37217	0	0	0	0	UI	1	3MR	\N	Concatenation UID	t	f	f	\N	\N
(0020,9162)	32	37218	0	0	0	0	US	1	3MR	\N	In-concatenation Number	t	f	f	\N	\N
(0020,9163)	32	37219	0	0	0	0	US	1	3MR	\N	In-concatenation Total Number	t	f	f	\N	\N
(0020,9164)	32	37220	0	0	0	0	UI	1	3MR	\N	Dimension Organization UID	t	f	f	\N	\N
(0020,9165)	32	37221	0	0	0	0	AT	1	3MR	\N	Dimension Index Pointer	t	f	f	\N	\N
(0020,9167)	32	37223	0	0	0	0	AT	1	3MR	\N	Functional Group Pointer	t	f	f	\N	\N
(0020,9213)	32	37395	0	0	0	0	LO	1	3MR	\N	Dimension Index Private Creator	t	f	f	\N	\N
(0020,9221)	32	37409	0	0	0	0	SQ	1	3MR	\N	Dimension Organization Sequence	t	f	f	\N	\N
(0020,9222)	32	37410	0	0	0	0	SQ	1	3MR	\N	Dimension Index Sequence	t	f	f	\N	\N
(0020,9228)	32	37416	0	0	0	0	UL	1	3MR	\N	Concatenation Frame Offset Number	t	f	f	\N	\N
(0020,9238)	32	37432	0	0	0	0	LO	1	3MR	\N	Functional Group Private Creator	t	f	f	\N	\N
(0028,0002)	40	2	0	0	0	0	US	1	3	\N	Samples per Pixel	t	f	f	\N	\N
(0028,0004)	40	4	0	0	0	0	CS	1	3	\N	Photometric Interpretation	t	f	f	\N	\N
(0028,0006)	40	6	0	0	0	0	US	1	3	\N	Planar Configuration	t	f	f	\N	\N
(0028,0008)	40	8	0	0	0	0	IS	1	3	\N	Number of Frames	t	f	f	\N	\N
(0028,0009)	40	9	0	0	0	0	AT	1-n	3	\N	Frame Increment Pointer	t	f	f	\N	\N
(0028,0010)	40	16	0	0	0	0	US	1	3	\N	Rows	t	f	f	\N	\N
(0028,0011)	40	17	0	0	0	0	US	1	3	\N	Columns	t	f	f	\N	\N
(0028,0012)	40	18	0	0	0	0	US	1	3	\N	Planes	t	f	f	\N	\N
(0028,0014)	40	20	0	0	0	0	US	1	3	\N	Ultrasound Color Data Present	t	f	f	\N	\N
(0028,0030)	40	48	0	0	0	0	DS	2	3	\N	Pixel Spacing	t	f	f	\N	\N
(0028,0031)	40	49	0	0	0	0	DS	2	3	\N	Zoom Factor	t	f	f	\N	\N
(0028,0032)	40	50	0	0	0	0	DS	2	3	\N	Zoom Center	t	f	f	\N	\N
(0028,0034)	40	52	0	0	0	0	IS	2	3	\N	Pixel Aspect Ratio	t	f	f	\N	\N
(0028,0051)	40	81	0	0	0	0	CS	1-n	3	\N	Corrected Image	t	f	f	\N	\N
(0028,0100)	40	256	0	0	0	0	US	1	3	\N	Bits Allocated	t	f	f	\N	\N
(0028,0101)	40	257	0	0	0	0	US	1	3	\N	Bits Stored	t	f	f	\N	\N
(0028,0102)	40	258	0	0	0	0	US	1	3	\N	High Bit	t	f	f	\N	\N
(0028,0103)	40	259	0	0	0	0	US	1	3	\N	Pixel Representation	t	f	f	\N	\N
(0028,0300)	40	768	0	0	0	0	CS	1	3DX	\N	Quality Control Image	t	f	f	\N	\N
(0028,0301)	40	769	0	0	0	0	CS	1	3DX	\N	Burned In Annotation	t	f	f	\N	\N
(0028,1040)	40	4160	0	0	0	0	CS	1	3	\N	Pixel Intensity Relationship	t	f	f	\N	\N
(0028,1041)	40	4161	0	0	0	0	SS	1	3DX	\N	Pixel Intensity Relationship Sign	t	f	f	\N	\N
(0028,1050)	40	4176	0	0	0	0	DS	1-n	3	\N	Window Center	t	f	f	\N	\N
(0028,1051)	40	4177	0	0	0	0	DS	1-n	3	\N	Window Width	t	f	f	\N	\N
(0028,1052)	40	4178	0	0	0	0	DS	1	3	\N	Rescale Intercept	t	f	f	\N	\N
(0028,1053)	40	4179	0	0	0	0	DS	1	3	\N	Rescale Slope	t	f	f	\N	\N
(0028,1054)	40	4180	0	0	0	0	LO	1	3	\N	Rescale Type	t	f	f	\N	\N
(0028,1055)	40	4181	0	0	0	0	LO	1-n	3	\N	Window Center & Width Explanation	t	f	f	\N	\N
(0028,1090)	40	4240	0	0	0	0	CS	1	3	\N	Recommended Viewing Mode	t	f	f	\N	\N
(0028,1199)	40	4505	0	0	0	0	UI	1	3	\N	Palette Color Lookup Table UID	t	f	f	\N	\N
(0028,1221)	40	4641	0	0	0	0	OW	1	3	\N	Segmented Red Palette Color Lookup Table Data	t	f	f	\N	\N
(0028,1222)	40	4642	0	0	0	0	OW	1	3	\N	Segmented Green Palette Color Lookup Table Data	t	f	f	\N	\N
(0028,1223)	40	4643	0	0	0	0	OW	1	3	\N	Segmented Blue Palette Color Lookup Table Data	t	f	f	\N	\N
(0028,1300)	40	4864	0	0	0	0	CS	1	3DX	\N	Implant Present	t	f	f	\N	\N
(0028,1350)	40	4944	0	0	0	0	CS	1	3CP	\N	Partial View	t	f	f	\N	\N
(0028,1351)	40	4945	0	0	0	0	ST	1	3CP	\N	Partial View Description	t	f	f	\N	\N
(0028,2110)	40	8464	0	0	0	0	CS	1	3	\N	Lossy Image Compression	t	f	f	\N	\N
(0028,2112)	40	8466	0	0	0	0	DS	1-n	3DX	\N	Lossy Image Compression Ratio	t	f	f	\N	\N
(0028,3000)	40	12288	0	0	0	0	SQ	1	3	\N	Modality LUT Sequence	t	f	f	\N	\N
(0028,3003)	40	12291	0	0	0	0	LO	1	3	\N	LUT Explanation	t	f	f	\N	\N
(0028,3004)	40	12292	0	0	0	0	LO	1	3	\N	Modality LUT Type	t	f	f	\N	\N
(0028,3010)	40	12304	0	0	0	0	SQ	1	3	\N	VOI LUT Sequence	t	f	f	\N	\N
(0028,3110)	40	12560	0	0	0	0	SQ	1	3SCP	\N	Softcopy VOI LUT Sequence	t	f	f	\N	\N
(0028,5000)	40	20480	0	0	0	0	SQ	1	3	\N	Biplane Acquisition Sequence	t	f	f	\N	\N
(0028,6010)	40	24592	0	0	0	0	US	1	3	\N	Representative Frame Number	t	f	f	\N	\N
(0028,6020)	40	24608	0	0	0	0	US	1-n	3	\N	Frame Numbers of Interest	t	f	f	\N	\N
(0028,6022)	40	24610	0	0	0	0	LO	1-n	3	\N	Frame of Interest Description	t	f	f	\N	\N
(0028,6040)	40	24640	0	0	0	0	US	1-n	3	\N	R Wave Pointer	t	f	f	\N	\N
(0028,6100)	40	24832	0	0	0	0	SQ	1	3	\N	Mask Subtraction Sequence	t	f	f	\N	\N
(0028,6101)	40	24833	0	0	0	0	CS	1	3	\N	Mask Operation	t	f	f	\N	\N
(0028,6102)	40	24834	0	0	0	0	US	1-n	3	\N	Applicable Frame Range	t	f	f	\N	\N
(0028,6110)	40	24848	0	0	0	0	US	1-n	3	\N	Mask Frame Numbers	t	f	f	\N	\N
(0028,6112)	40	24850	0	0	0	0	US	1	3	\N	Contrast Frame Averaging	t	f	f	\N	\N
(0028,6114)	40	24852	0	0	0	0	FL	2	3	\N	Mask Sub-Pixel Shift	t	f	f	\N	\N
(0028,6120)	40	24864	0	0	0	0	SS	1	3	\N	TID Offset	t	f	f	\N	\N
(0028,6190)	40	24976	0	0	0	0	ST	1	3	\N	Mask Operation Explanation	t	f	f	\N	\N
(0028,9001)	40	36865	0	0	0	0	UL	1	3MR	\N	Data Point Rows	t	f	f	\N	\N
(0028,9002)	40	36866	0	0	0	0	UL	1	3MR	\N	Data Point Columns	t	f	f	\N	\N
(0028,9003)	40	36867	0	0	0	0	CS	1-2	3MR	\N	Signal Domain	t	f	f	\N	\N
(0028,9108)	40	37128	0	0	0	0	CS	1	3MR	\N	Data Representation	t	f	f	\N	\N
(0028,9110)	40	37136	0	0	0	0	SQ	1	3MR	\N	Pixel Measures Sequence	t	f	f	\N	\N
(0028,9132)	40	37170	0	0	0	0	SQ	1	3MR	\N	Frame VOI LUT Sequence	t	f	f	\N	\N
(0028,9145)	40	37189	0	0	0	0	SQ	1	3MR	\N	Pixel Value Transformation Sequence	t	f	f	\N	\N
(0028,9235)	40	37429	0	0	0	0	CS	1	3MR	\N	Signal Domain Rows	t	f	f	\N	\N
(0032,1032)	50	4146	0	0	0	0	PN	1	3	\N	Requesting Physician	t	f	f	\N	\N
(0032,1033)	50	4147	0	0	0	0	LO	1	3	\N	Requesting Service	t	f	f	\N	\N
(0032,1060)	50	4192	0	0	0	0	LO	1	3	\N	Requested Procedure Description	t	f	f	\N	\N
(0032,1064)	50	4196	0	0	0	0	SQ	1	3	\N	Requested Procedure Code Sequence	t	f	f	\N	\N
(0032,1070)	50	4208	0	0	0	0	LO	1	3	\N	Requested Contrast Agent	t	f	f	\N	\N
(0032,4000)	50	16384	0	0	0	0	LT	1	3	\N	Study Comments	t	f	f	\N	\N
(0038,0004)	56	4	0	0	0	0	SQ	1	3	\N	Referenced Patient Alias Sequence	t	f	f	\N	\N
(0038,0008)	56	8	0	0	0	0	CS	1	3	\N	Visit Status ID	t	f	f	\N	\N
(0038,0010)	56	16	0	0	0	0	LO	1	3	\N	Admission ID	t	f	f	\N	\N
(0038,0011)	56	17	0	0	0	0	LO	1	3	\N	Issuer of Admission ID	t	f	f	\N	\N
(0038,0016)	56	22	0	0	0	0	LO	1	3	\N	Route of Admissions	t	f	f	\N	\N
(0038,0020)	56	32	0	0	0	0	DA	1	3	\N	Admitting Date	t	f	f	\N	\N
(0038,0021)	56	33	0	0	0	0	TM	1	3	\N	Admitting Time	t	f	f	\N	\N
(0038,0050)	56	80	0	0	0	0	LO	1	3	\N	Special Needs	t	f	f	\N	\N
(0038,0300)	56	768	0	0	0	0	LO	1	3	\N	Current Patient Location	t	f	f	\N	\N
(0038,0400)	56	1024	0	0	0	0	LO	1	3	\N	Patient's Institution Residence	t	f	f	\N	\N
(0038,0500)	56	1280	0	0	0	0	LO	1	3	\N	Patient State	t	f	f	\N	\N
(0038,4000)	56	16384	0	0	0	0	LT	1	3	\N	Visit Comments	t	f	f	\N	\N
(003a,0004)	58	4	0	0	0	0	CS	1	3WAV	\N	Waveform Originality	t	f	f	\N	\N
(003a,0005)	58	5	0	0	0	0	US	1	3WAV	\N	Number of Waveform Channels	t	f	f	\N	\N
(003a,0010)	58	16	0	0	0	0	UL	1	3WAV	\N	Number of Waveform Samples	t	f	f	\N	\N
(003a,001a)	58	26	0	0	0	0	DS	1	3WAV	\N	Sampling Frequency	t	f	f	\N	\N
(003a,0020)	58	32	0	0	0	0	SH	1	3WAV	\N	Multiplex Group Label	t	f	f	\N	\N
(003a,0200)	58	512	0	0	0	0	SQ	1	3WAV	\N	Channel Definition Sequence	t	f	f	\N	\N
(003a,0202)	58	514	0	0	0	0	IS	1	3WAV	\N	Waveform Channel Number	t	f	f	\N	\N
(003a,0203)	58	515	0	0	0	0	SH	1	3WAV	\N	Channel Label	t	f	f	\N	\N
(003a,0205)	58	517	0	0	0	0	CS	1-n	3WAV	\N	Channel Status	t	f	f	\N	\N
(003a,0208)	58	520	0	0	0	0	SQ	1	3WAV	\N	Channel Source Sequence	t	f	f	\N	\N
(003a,0209)	58	521	0	0	0	0	SQ	1	3WAV	\N	Channel Source Modifiers Sequence	t	f	f	\N	\N
(003a,020a)	58	522	0	0	0	0	SQ	1	3WAV	\N	Source Waveform Sequence	t	f	f	\N	\N
(003a,020c)	58	524	0	0	0	0	LO	1	3WAV	\N	Channel Derivation Description	t	f	f	\N	\N
(003a,0210)	58	528	0	0	0	0	DS	1	3WAV	\N	Channel Sensitivity	t	f	f	\N	\N
(003a,0211)	58	529	0	0	0	0	SQ	1	3WAV	\N	Channel Sensitivity Units Sequence	t	f	f	\N	\N
(003a,0212)	58	530	0	0	0	0	DS	1	3WAV	\N	Channel Sensitivity Correction Factor	t	f	f	\N	\N
(003a,0213)	58	531	0	0	0	0	DS	1	3WAV	\N	Channel Baseline	t	f	f	\N	\N
(003a,0214)	58	532	0	0	0	0	DS	1	3WAV	\N	Channel Time Skew	t	f	f	\N	\N
(003a,0215)	58	533	0	0	0	0	DS	1	3WAV	\N	Channel Sample Skew	t	f	f	\N	\N
(003a,0218)	58	536	0	0	0	0	DS	1	3WAV	\N	Channel Offset	t	f	f	\N	\N
(003a,021a)	58	538	0	0	0	0	US	1	3WAV	\N	Waveform Bits Stored	t	f	f	\N	\N
(003a,0220)	58	544	0	0	0	0	DS	1	3WAV	\N	Filter Low Frequency	t	f	f	\N	\N
(003a,0221)	58	545	0	0	0	0	DS	1	3WAV	\N	Filter High Frequency	t	f	f	\N	\N
(003a,0222)	58	546	0	0	0	0	DS	1	3WAV	\N	Notch Filter Frequency	t	f	f	\N	\N
(003a,0223)	58	547	0	0	0	0	DS	1	3WAV	\N	Notch Filter Bandwidth	t	f	f	\N	\N
(0040,0001)	64	1	0	0	0	0	AE	1	3	\N	Scheduled Station AE Title	t	f	f	\N	\N
(0040,0002)	64	2	0	0	0	0	DA	1	3	\N	Scheduled Procedure Step Start Date	t	f	f	\N	\N
(0040,0003)	64	3	0	0	0	0	TM	1	3	\N	Scheduled Procedure Step Start Time	t	f	f	\N	\N
(0040,0004)	64	4	0	0	0	0	DA	1	3	\N	Scheduled Procedure Step End Date	t	f	f	\N	\N
(0040,0005)	64	5	0	0	0	0	TM	1	3	\N	Scheduled Procedure Step End Time	t	f	f	\N	\N
(0040,0006)	64	6	0	0	0	0	PN	1	3	\N	Scheduled Performing Physician Name	t	f	f	\N	\N
(0040,0007)	64	7	0	0	0	0	LO	1	3	\N	Scheduled Procedure Step Description	t	f	f	\N	\N
(0040,0008)	64	8	0	0	0	0	SQ	1	3	\N	Scheduled Protocol Code Sequence	t	f	f	\N	\N
(0040,0009)	64	9	0	0	0	0	SH	1	3	\N	Scheduled Procedure Step ID	t	f	f	\N	\N
(0040,000a)	64	10	0	0	0	0	SQ	1	3	\N	Stage Code Sequence	t	f	f	\N	\N
(0040,0010)	64	16	0	0	0	0	SH	1	3	\N	Scheduled Station Name	t	f	f	\N	\N
(0040,0011)	64	17	0	0	0	0	SH	1	3	\N	Scheduled Procedure Step Location	t	f	f	\N	\N
(0040,0012)	64	18	0	0	0	0	LO	1	3	\N	Pre-Medication	t	f	f	\N	\N
(0040,0020)	64	32	0	0	0	0	CS	1	3	\N	Scheduled Procedure Step Status	t	f	f	\N	\N
(0040,0100)	64	256	0	0	0	0	SQ	1	3	\N	Scheduled Procedure Step Sequence	t	f	f	\N	\N
(0040,0220)	64	544	0	0	0	0	SQ	1	3PPS	\N	Referenced Non-Image Composite SOP Instance Sequence	t	f	f	\N	\N
(0040,0241)	64	577	0	0	0	0	AE	1	3PPS	\N	Performed Station AE Title	t	f	f	\N	\N
(0040,0242)	64	578	0	0	0	0	SH	1	3PPS	\N	Performed Station Name	t	f	f	\N	\N
(0040,0243)	64	579	0	0	0	0	SH	1	3PPS	\N	Performed Location	t	f	f	\N	\N
(0040,0244)	64	580	0	0	0	0	DA	1	3PPS	\N	Performed Procedure Step Start Date	t	f	f	\N	\N
(0040,0245)	64	581	0	0	0	0	TM	1	3PPS	\N	Performed Procedure Step Start Time	t	f	f	\N	\N
(0040,0250)	64	592	0	0	0	0	DA	1	3PPS	\N	Performed Procedure Step End Date	t	f	f	\N	\N
(0040,0251)	64	593	0	0	0	0	TM	1	3PPS	\N	Performed Procedure Step End Time	t	f	f	\N	\N
(0040,0252)	64	594	0	0	0	0	CS	1	3PPS	\N	Performed Procedure Step Status	t	f	f	\N	\N
(0040,0253)	64	595	0	0	0	0	SH	1	3PPS	\N	Performed Procedure Step ID	t	f	f	\N	\N
(0040,0254)	64	596	0	0	0	0	LO	1	3PPS	\N	Performed Procedure Step Description	t	f	f	\N	\N
(0040,0255)	64	597	0	0	0	0	LO	1	3PPS	\N	Performed Procedure Type Description	t	f	f	\N	\N
(0040,0260)	64	608	0	0	0	0	SQ	1	3PPS	\N	Performed Protocol Code Sequence	t	f	f	\N	\N
(0040,0270)	64	624	0	0	0	0	SQ	1	3PPS	\N	Scheduled Step Attributes Sequence	t	f	f	\N	\N
(0040,0275)	64	629	0	0	0	0	SQ	1	3PPS	\N	Request Attributes Sequence	t	f	f	\N	\N
(0040,0280)	64	640	0	0	0	0	ST	1	3PPS	\N	Comments on the Performed Procedure Step	t	f	f	\N	\N
(0040,0293)	64	659	0	0	0	0	SQ	1	3PPS	\N	Quantity Sequence	t	f	f	\N	\N
(0040,0294)	64	660	0	0	0	0	DS	1	3PPS	\N	Quantity	t	f	f	\N	\N
(0040,0295)	64	661	0	0	0	0	SQ	1	3PPS	\N	Measuring Units Sequence	t	f	f	\N	\N
(0040,0296)	64	662	0	0	0	0	SQ	1	3PPS	\N	Billing Item Sequence	t	f	f	\N	\N
(0040,0300)	64	768	0	0	0	0	US	1	3PPS	\N	Total Time of Flouroscopy	t	f	f	\N	\N
(0040,0301)	64	769	0	0	0	0	US	1	3PPS	\N	Total Number Of Exposures	t	f	f	\N	\N
(0040,0302)	64	770	0	0	0	0	US	1	3PPS	\N	Entrance Dose	t	f	f	\N	\N
(0040,0303)	64	771	0	0	0	0	US	1-2	3PPS	\N	Exposed Area	t	f	f	\N	\N
(0040,0306)	64	774	0	0	0	0	DS	1	3DX	\N	Distance Source to Entrance	t	f	f	\N	\N
(0040,030e)	64	782	0	0	0	0	SQ	1	3	\N	Exposure Dose Sequence	t	f	f	\N	\N
(0040,0310)	64	784	0	0	0	0	ST	1	3PPS	\N	Comments On Radiation Dose	t	f	f	\N	\N
(0040,0312)	64	786	0	0	0	0	DS	1	3DX	\N	X-Ray Output	t	f	f	\N	\N
(0040,0314)	64	788	0	0	0	0	DS	1	3DX	\N	Half Value Layer	t	f	f	\N	\N
(0040,0316)	64	790	0	0	0	0	DS	1	3DX	\N	Organ Dose	t	f	f	\N	\N
(0040,0318)	64	792	0	0	0	0	CS	1	3DX	\N	Organ Exposed	t	f	f	\N	\N
(0040,0320)	64	800	0	0	0	0	SQ	1	3PPS	\N	Billing Procedure Step Sequence	t	f	f	\N	\N
(0040,0321)	64	801	0	0	0	0	SQ	1	3PPS	\N	Film Consumption Sequence	t	f	f	\N	\N
(0040,0324)	64	804	0	0	0	0	SQ	1	3PPS	\N	Billing Supplies And Devices Sequence	t	f	f	\N	\N
(0040,0340)	64	832	0	0	0	0	SQ	1	3PPS	\N	Performed Series Sequence	t	f	f	\N	\N
(0040,0400)	64	1024	0	0	0	0	LT	1	3	\N	Comments On Scheduled Procedure Step	t	f	f	\N	\N
(0040,050a)	64	1290	0	0	0	0	LO	1	3DX	\N	Specimen Accession Number	t	f	f	\N	\N
(0040,0550)	64	1360	0	0	0	0	SQ	1	3DX	\N	Specimen Sequence	t	f	f	\N	\N
(0040,0551)	64	1361	0	0	0	0	LO	1	3DX	\N	Specimen Identifier	t	f	f	\N	\N
(0040,0555)	64	1365	0	0	0	0	SQ	1	3DX	\N	Acquisition Context Sequence	t	f	f	\N	\N
(0040,0556)	64	1366	0	0	0	0	ST	1	3DX	\N	Acquisition Context Description	t	f	f	\N	\N
(0040,059a)	64	1434	0	0	0	0	SQ	1	3DX	\N	Specimen Type Code Sequence	t	f	f	\N	\N
(0040,06fa)	64	1786	0	0	0	0	LO	1	3DX	\N	Slide Identifier	t	f	f	\N	\N
(0040,071a)	64	1818	0	0	0	0	SQ	1	3VLI	\N	Image Center Point Coordinates Sequence	t	f	f	\N	\N
(0040,072a)	64	1834	0	0	0	0	DS	1	3VLI	\N	X Offset In Slide Coordinate System	t	f	f	\N	\N
(0040,073a)	64	1850	0	0	0	0	DS	1	3VLI	\N	Y Offset In Slide Coordinate System	t	f	f	\N	\N
(0040,074a)	64	1866	0	0	0	0	DS	1	3VLI	\N	Z Offset In Slide Coordinate System	t	f	f	\N	\N
(0040,08d8)	64	2264	0	0	0	0	SQ	1	3VLI	\N	Pixel Spacing Sequence	t	f	f	\N	\N
(0040,08da)	64	2266	0	0	0	0	SQ	1	3VLI	\N	Coordinate System Axis Code Sequence	t	f	f	\N	\N
(0040,08ea)	64	2282	0	0	0	0	SQ	1	3DX	\N	Measurement Units Code Sequence	t	f	f	\N	\N
(0040,1001)	64	4097	0	0	0	0	SH	1	3	\N	Requested Procedure ID	t	f	f	\N	\N
(0040,1002)	64	4098	0	0	0	0	LO	1	3	\N	Reason For Requested Procedure	t	f	f	\N	\N
(0040,1003)	64	4099	0	0	0	0	SH	1	3	\N	Requested Procedure Priority	t	f	f	\N	\N
(0040,1004)	64	4100	0	0	0	0	LO	1	3	\N	Patient Transport Arrangements	t	f	f	\N	\N
(0040,1005)	64	4101	0	0	0	0	LO	1	3	\N	Requested Procedure Location	t	f	f	\N	\N
(0040,1008)	64	4104	0	0	0	0	LO	1	3	\N	Confidentiality Code	t	f	f	\N	\N
(0040,1009)	64	4105	0	0	0	0	SH	1	3	\N	Reporting Priority	t	f	f	\N	\N
(0040,1010)	64	4112	0	0	0	0	PN	1-n	3	\N	Names of Intended Recipients of Results	t	f	f	\N	\N
(0040,1400)	64	5120	0	0	0	0	LT	1	3	\N	Requested Procedure Comments	t	f	f	\N	\N
(0040,2004)	64	8196	0	0	0	0	DA	1	3	\N	Issue Date of Imaging Service Request	t	f	f	\N	\N
(0040,2005)	64	8197	0	0	0	0	TM	1	3	\N	Issue Time of Imaging Service Request	t	f	f	\N	\N
(0040,2008)	64	8200	0	0	0	0	PN	1	3	\N	Order Entered By	t	f	f	\N	\N
(0040,2009)	64	8201	0	0	0	0	SH	1	3	\N	Order Enterer Location	t	f	f	\N	\N
(0040,2010)	64	8208	0	0	0	0	SH	1	3	\N	Order Callback Phone Number	t	f	f	\N	\N
(0040,2016)	64	8214	0	0	0	0	LO	1	3	\N	Placer Order Number of Imaging Service Request	t	f	f	\N	\N
(0040,2017)	64	8215	0	0	0	0	LO	1	3	\N	Filler Order Number of Imaging Service Request	t	f	f	\N	\N
(0040,2400)	64	9216	0	0	0	0	LT	1	3	\N	Imaging Service Request Comments	t	f	f	\N	\N
(0040,3001)	64	12289	0	0	0	0	LO	1	3	\N	Confidentiality Constraint On Patient Data Description	t	f	f	\N	\N
(0040,4001)	64	16385	0	0	0	0	CS	1	3GPW	\N	General Purpose Scheduled Procedure Step Status	t	f	f	\N	\N
(0040,4002)	64	16386	0	0	0	0	CS	1	3GPW	\N	General Purpose Performed Procedure Step Status	t	f	f	\N	\N
(0040,4003)	64	16387	0	0	0	0	CS	1	3GPW	\N	General Purpose Scheduled Procedure Step Priority	t	f	f	\N	\N
(0040,4004)	64	16388	0	0	0	0	SQ	1	3GPW	\N	Scheduled Processing Applications Code Sequence	t	f	f	\N	\N
(0040,4005)	64	16389	0	0	0	0	DT	1	3GPW	\N	Scheduled Procedure Step Start Date and Time	t	f	f	\N	\N
(0040,4006)	64	16390	0	0	0	0	CS	1	3GPW	\N	Multiple Copies Flag	t	f	f	\N	\N
(0040,4007)	64	16391	0	0	0	0	SQ	1	3GPW	\N	Performed Processing Applications Code Sequence	t	f	f	\N	\N
(0040,4009)	64	16393	0	0	0	0	SQ	1	3GPW	\N	Human Performer Code Sequence	t	f	f	\N	\N
(0040,4011)	64	16401	0	0	0	0	DT	1	3GPW	\N	Expected Completion Date and Time	t	f	f	\N	\N
(0040,4015)	64	16405	0	0	0	0	SQ	1	3GPW	\N	Resulting General Purpose Performed Procedure Steps Sequence	t	f	f	\N	\N
(0040,4016)	64	16406	0	0	0	0	SQ	1	3GPW	\N	Referenced General Purpose Scheduled Procedure Step Sequence	t	f	f	\N	\N
(0040,4018)	64	16408	0	0	0	0	SQ	1	3GPW	\N	Scheduled Workitem Code Sequence	t	f	f	\N	\N
(0040,4019)	64	16409	0	0	0	0	SQ	1	3GPW	\N	Performed Workitem Code Sequence	t	f	f	\N	\N
(0040,4020)	64	16416	0	0	0	0	CS	1	3GPW	\N	Input Availability Flag	t	f	f	\N	\N
(0040,4021)	64	16417	0	0	0	0	SQ	1	3GPW	\N	Input Information Sequence	t	f	f	\N	\N
(0040,4022)	64	16418	0	0	0	0	SQ	1	3GPW	\N	Relevant Information Sequence	t	f	f	\N	\N
(0040,4023)	64	16419	0	0	0	0	UI	1	3GPW	\N	Referenced General Purpose Scheduled Procedure Step Transaction UID	t	f	f	\N	\N
(0040,4025)	64	16421	0	0	0	0	SQ	1	3GPW	\N	Scheduled Station Name Code Sequence	t	f	f	\N	\N
(0040,4026)	64	16422	0	0	0	0	SQ	1	3GPW	\N	Scheduled Station Class Code Sequence	t	f	f	\N	\N
(0040,4027)	64	16423	0	0	0	0	SQ	1	3GPW	\N	Scheduled Station Geographic Location Code Sequence	t	f	f	\N	\N
(0040,4028)	64	16424	0	0	0	0	SQ	1	3GPW	\N	Performed Station Name Code Sequence	t	f	f	\N	\N
(0040,4029)	64	16425	0	0	0	0	SQ	1	3GPW	\N	Performed Station Class Code Sequence	t	f	f	\N	\N
(0040,4030)	64	16432	0	0	0	0	SQ	1	3GPW	\N	Performed Station Geographic Location Code Sequence	t	f	f	\N	\N
(0040,4031)	64	16433	0	0	0	0	SQ	1	3GPW	\N	Requested Subsequent Workitem Code Sequence	t	f	f	\N	\N
(0040,4032)	64	16434	0	0	0	0	SQ	1	3GPW	\N	Non-DICOM Output Code Sequence	t	f	f	\N	\N
(0040,4033)	64	16435	0	0	0	0	SQ	1	3GPW	\N	Output Information Sequence	t	f	f	\N	\N
(0040,4034)	64	16436	0	0	0	0	SQ	1	3GPW	\N	Scheduled Human Performers Sequence	t	f	f	\N	\N
(0040,4035)	64	16437	0	0	0	0	SQ	1	3GPW	\N	Actual Human Performers Sequence	t	f	f	\N	\N
(0040,4036)	64	16438	0	0	0	0	LO	1	3GPW	\N	Human Performer's Organization	t	f	f	\N	\N
(0040,4037)	64	16439	0	0	0	0	PN	1	3GPW	\N	Human Performer's Name	t	f	f	\N	\N
(0040,8302)	64	33538	0	0	0	0	DS	1	3CP	\N	Entrance Dose in mGy	t	f	f	\N	\N
(0040,9096)	64	37014	0	0	0	0	SQ	1	3MR	\N	Real World Value Mapping Sequence 	t	f	f	\N	\N
(0040,9212)	64	37394	0	0	0	0	FD	1-n	3MR	\N	Real World Value LUT Data	t	f	f	\N	\N
(0040,9224)	64	37412	0	0	0	0	FD	1	3MR	\N	Real World Value Intercept	t	f	f	\N	\N
(0040,9225)	64	37413	0	0	0	0	FD	1	3MR	\N	Real World Value Slope	t	f	f	\N	\N
(0040,a010)	64	40976	0	0	0	0	CS	1	3STR	\N	Relationship Type	t	f	f	\N	\N
(0040,a027)	64	40999	0	0	0	0	LO	1	3STR	\N	Verifying Organization	t	f	f	\N	\N
(0040,a030)	64	41008	0	0	0	0	DT	1	3STR	\N	Verification DateTime	t	f	f	\N	\N
(0040,a032)	64	41010	0	0	0	0	DT	1	3STR	\N	Observation DateTime	t	f	f	\N	\N
(0040,a040)	64	41024	0	0	0	0	CS	1	3STR	\N	Value Type	t	f	f	\N	\N
(0040,a043)	64	41027	0	0	0	0	SQ	1	3DX	\N	Concept Name Code Sequence	t	f	f	\N	\N
(0040,a050)	64	41040	0	0	0	0	CS	1	3STR	\N	Continuity Of Content	t	f	f	\N	\N
(0040,a073)	64	41075	0	0	0	0	SQ	1	3STR	\N	Verifying Observer Sequence	t	f	f	\N	\N
(0040,a075)	64	41077	0	0	0	0	PN	1	3STR	\N	Verifying Observer Name	t	f	f	\N	\N
(0040,a088)	64	41096	0	0	0	0	SQ	1	3STR	\N	Verifying Observer Identification Code Sequence	t	f	f	\N	\N
(0040,a0b0)	64	41136	0	0	0	0	US	1-n	3WAV	\N	Referenced Waveform Channels	t	f	f	\N	\N
(0040,a120)	64	41248	0	0	0	0	DT	1	3STR	\N	DateTime	t	f	f	\N	\N
(0040,a121)	64	41249	0	0	0	0	DA	1	3DX	\N	Date	t	f	f	\N	\N
(0040,a122)	64	41250	0	0	0	0	TM	1	3DX	\N	Time	t	f	f	\N	\N
(0040,a123)	64	41251	0	0	0	0	PN	1	3DX	\N	Person Name	t	f	f	\N	\N
(0040,a124)	64	41252	0	0	0	0	UI	1	3STR	\N	UID	t	f	f	\N	\N
(0040,a130)	64	41264	0	0	0	0	CS	1	3WAV	\N	Temporal Range Type	t	f	f	\N	\N
(0040,a132)	64	41266	0	0	0	0	UL	1-n	3WAV	\N	Referenced Sample Positions	t	f	f	\N	\N
(0040,a136)	64	41270	0	0	0	0	US	1-n	3DX	\N	Referenced Frame Numbers	t	f	f	\N	\N
(0040,a138)	64	41272	0	0	0	0	DS	1-n	3WAV	\N	Referenced Time Offsets	t	f	f	\N	\N
(0040,a13a)	64	41274	0	0	0	0	DT	1-n	3WAV	\N	Referenced Datetime	t	f	f	\N	\N
(0040,a160)	64	41312	0	0	0	0	UT	1	3DX	\N	Text Value	t	f	f	\N	\N
(0040,a168)	64	41320	0	0	0	0	SQ	1	3DX	\N	Concept Code Sequence	t	f	f	\N	\N
(0040,a170)	64	41328	0	0	0	0	SQ	1	3	\N	Purpose of Reference Code Sequence	t	f	f	\N	\N
(0040,a180)	64	41344	0	0	0	0	US	1	3WAV	\N	Annotation Group Number	t	f	f	\N	\N
(0040,a195)	64	41365	0	0	0	0	SQ	1	3WAV	\N	Modifier Code Sequence	t	f	f	\N	\N
(0040,a300)	64	41728	0	0	0	0	SQ	1	3STR	\N	Measured Value Sequence	t	f	f	\N	\N
(0040,a30a)	64	41738	0	0	0	0	DS	1-n	3DX	\N	Numeric Value	t	f	f	\N	\N
(0040,a360)	64	41824	0	0	0	0	SQ	1	3STR	\N	Predecessor Documents Sequence	t	f	f	\N	\N
(0040,a370)	64	41840	0	0	0	0	SQ	1	3STR	\N	Referenced Request Sequence	t	f	f	\N	\N
(0040,a372)	64	41842	0	0	0	0	SQ	1	3STR	\N	Performed Procedure Code Sequence	t	f	f	\N	\N
(0040,a375)	64	41845	0	0	0	0	SQ	1	3STR	\N	Current Requested Procedure Evidence Sequence	t	f	f	\N	\N
(0040,a385)	64	41861	0	0	0	0	SQ	1	3STR	\N	Pertinent Other Evidence Sequence	t	f	f	\N	\N
(0040,a491)	64	42129	0	0	0	0	CS	1	3STR	\N	Completion Flag	t	f	f	\N	\N
(0040,a492)	64	42130	0	0	0	0	LO	1	3STR	\N	Completion Flag Description	t	f	f	\N	\N
(0040,a493)	64	42131	0	0	0	0	CS	1	3STR	\N	Verification Flag	t	f	f	\N	\N
(0040,a504)	64	42244	0	0	0	0	SQ	1	3STR	\N	Content Template Sequence	t	f	f	\N	\N
(0040,a525)	64	42277	0	0	0	0	SQ	1	3STR	\N	Identical Documents Sequence	t	f	f	\N	\N
(0040,a730)	64	42800	0	0	0	0	SQ	1	3STR	\N	Content Sequence	t	f	f	\N	\N
(0040,b020)	64	45088	0	0	0	0	SQ	1	3WAV	\N	Annotation Sequence	t	f	f	\N	\N
(0040,db00)	64	56064	0	0	0	0	CS	1	3STR	\N	Template Identifier	t	f	f	\N	\N
(0040,db73)	64	56179	0	0	0	0	UL	1-n	3STR	\N	Referenced Content Item Identifier	t	f	f	\N	\N
(0050,0004)	80	4	0	0	0	0	CS	1	3	\N	Calibration Image	t	f	f	\N	\N
(0050,0010)	80	16	0	0	0	0	SQ	1	3	\N	Device Sequence	t	f	f	\N	\N
(0050,0014)	80	20	0	0	0	0	DS	1	3	\N	Device Length	t	f	f	\N	\N
(0050,0016)	80	22	0	0	0	0	DS	1	3	\N	Device Diameter	t	f	f	\N	\N
(0050,0017)	80	23	0	0	0	0	CS	1	3	\N	Device Diameter Units	t	f	f	\N	\N
(0050,0018)	80	24	0	0	0	0	DS	1	3	\N	Device Volume	t	f	f	\N	\N
(0050,0019)	80	25	0	0	0	0	DS	1	3	\N	Inter Marker Distance	t	f	f	\N	\N
(0050,0020)	80	32	0	0	0	0	LO	1	3	\N	Device Description	t	f	f	\N	\N
(0054,0010)	84	16	0	0	0	0	US	1-n	3	\N	Energy Window Vector	t	f	f	\N	\N
(0054,0011)	84	17	0	0	0	0	US	1	3	\N	Number of Energy Windows	t	f	f	\N	\N
(0054,0012)	84	18	0	0	0	0	SQ	1	3	\N	Energy Window Information Sequence	t	f	f	\N	\N
(0054,0013)	84	19	0	0	0	0	SQ	1	3	\N	Energy Window Range Sequence	t	f	f	\N	\N
(0054,0014)	84	20	0	0	0	0	DS	1	3	\N	Energy Window Lower Limit	t	f	f	\N	\N
(0054,0015)	84	21	0	0	0	0	DS	1	3	\N	Energy Window Upper Limit	t	f	f	\N	\N
(0054,0016)	84	22	0	0	0	0	SQ	1	3	\N	Radiopharmaceutical Information Sequence	t	f	f	\N	\N
(0054,0017)	84	23	0	0	0	0	IS	1	3	\N	Residual Syringe Counts	t	f	f	\N	\N
(0054,0018)	84	24	0	0	0	0	SH	1	3	\N	Energy Window Name	t	f	f	\N	\N
(0054,0020)	84	32	0	0	0	0	US	1-n	3	\N	Detector Vector	t	f	f	\N	\N
(0054,0021)	84	33	0	0	0	0	US	1	3	\N	Number of Detectors	t	f	f	\N	\N
(0054,0022)	84	34	0	0	0	0	SQ	1	3	\N	Detector Information Sequence	t	f	f	\N	\N
(0054,0030)	84	48	0	0	0	0	US	1-n	3	\N	Phase Vector	t	f	f	\N	\N
(0054,0031)	84	49	0	0	0	0	US	1	3	\N	Number of Phases	t	f	f	\N	\N
(0054,0032)	84	50	0	0	0	0	SQ	1	3	\N	Phase Information Sequence	t	f	f	\N	\N
(0054,0033)	84	51	0	0	0	0	US	1	3	\N	Number of Frames In Phase	t	f	f	\N	\N
(0054,0036)	84	54	0	0	0	0	IS	1	3	\N	Phase Delay	t	f	f	\N	\N
(0054,0038)	84	56	0	0	0	0	IS	1	3	\N	Pause Between Frames	t	f	f	\N	\N
(0054,0050)	84	80	0	0	0	0	US	1-n	3	\N	Rotation Vector	t	f	f	\N	\N
(0054,0051)	84	81	0	0	0	0	US	1	3	\N	Number of Rotations	t	f	f	\N	\N
(0054,0052)	84	82	0	0	0	0	SQ	1	3	\N	Rotation Information Sequence	t	f	f	\N	\N
(0054,0053)	84	83	0	0	0	0	US	1	3	\N	Number of Frames In Rotation	t	f	f	\N	\N
(0054,0060)	84	96	0	0	0	0	US	1-n	3	\N	R-R Interval Vector	t	f	f	\N	\N
(0054,0061)	84	97	0	0	0	0	US	1	3	\N	Number of R-R Intervals	t	f	f	\N	\N
(0054,0062)	84	98	0	0	0	0	SQ	1	3	\N	Gated Information Sequence	t	f	f	\N	\N
(0054,0063)	84	99	0	0	0	0	SQ	1	3	\N	Data Information Sequence	t	f	f	\N	\N
(0054,0070)	84	112	0	0	0	0	US	1-n	3	\N	Time Slot Vector	t	f	f	\N	\N
(0054,0071)	84	113	0	0	0	0	US	1	3	\N	Number of Time Slots	t	f	f	\N	\N
(0054,0072)	84	114	0	0	0	0	SQ	1	3	\N	Time Slot Information Sequence	t	f	f	\N	\N
(0054,0073)	84	115	0	0	0	0	DS	1-n	3	\N	Time Slot Time	t	f	f	\N	\N
(0054,0080)	84	128	0	0	0	0	US	1-n	3	\N	Slice Vector	t	f	f	\N	\N
(0054,0081)	84	129	0	0	0	0	US	1	3	\N	Number of Slices	t	f	f	\N	\N
(0054,0090)	84	144	0	0	0	0	US	1-n	3	\N	Angular View Vector	t	f	f	\N	\N
(0054,0100)	84	256	0	0	0	0	US	1-n	3	\N	Time Slice Vector	t	f	f	\N	\N
(0054,0101)	84	257	0	0	0	0	US	1	3PET	\N	Number Of Time Slices	t	f	f	\N	\N
(0054,0200)	84	512	0	0	0	0	DS	1	3	\N	Start Angle	t	f	f	\N	\N
(0054,0202)	84	514	0	0	0	0	CS	1	3	\N	Type of Detector Motion	t	f	f	\N	\N
(0054,0210)	84	528	0	0	0	0	IS	1-n	3	\N	Trigger Vector	t	f	f	\N	\N
(0054,0211)	84	529	0	0	0	0	US	1	3	\N	Number of Triggers in Phase	t	f	f	\N	\N
(0054,0220)	84	544	0	0	0	0	SQ	1	3	\N	View Code Sequence	t	f	f	\N	\N
(0054,0222)	84	546	0	0	0	0	SQ	1	3	\N	View Modifier Code Sequence	t	f	f	\N	\N
(0054,0300)	84	768	0	0	0	0	SQ	1	3	\N	Radionuclide Code Sequence	t	f	f	\N	\N
(0054,0302)	84	770	0	0	0	0	SQ	1	3	\N	Administration Route Code Sequence	t	f	f	\N	\N
(0054,0304)	84	772	0	0	0	0	SQ	1	3	\N	Radiopharmaceutical Code Sequence	t	f	f	\N	\N
(0054,0306)	84	774	0	0	0	0	SQ	1	3	\N	Calibration Data Sequence	t	f	f	\N	\N
(0054,0308)	84	776	0	0	0	0	US	1	3	\N	Energy Window Number	t	f	f	\N	\N
(0054,0400)	84	1024	0	0	0	0	SH	1	3	\N	Image ID	t	f	f	\N	\N
(0054,0410)	84	1040	0	0	0	0	SQ	1	3	\N	Patient Orientation Code Sequence	t	f	f	\N	\N
(0054,0412)	84	1042	0	0	0	0	SQ	1	3	\N	Patient Orientation Modifier Code Sequence	t	f	f	\N	\N
(0054,0414)	84	1044	0	0	0	0	SQ	1	3	\N	Patient Gantry Relationship Code Sequence	t	f	f	\N	\N
(0054,1000)	84	4096	0	0	0	0	CS	2	3PET	\N	Series Type	t	f	f	\N	\N
(0054,1001)	84	4097	0	0	0	0	CS	1	3PET	\N	Units	t	f	f	\N	\N
(0054,1002)	84	4098	0	0	0	0	CS	1	3PET	\N	Counts Source	t	f	f	\N	\N
(0054,1004)	84	4100	0	0	0	0	CS	1	3PET	\N	Reprojection Method	t	f	f	\N	\N
(0054,1100)	84	4352	0	0	0	0	CS	1	3PET	\N	Randoms Correction Method	t	f	f	\N	\N
(0054,1101)	84	4353	0	0	0	0	LO	1	3PET	\N	Attenuation Correction Method	t	f	f	\N	\N
(0054,1102)	84	4354	0	0	0	0	CS	1	3PET	\N	Decay Correction	t	f	f	\N	\N
(0054,1103)	84	4355	0	0	0	0	LO	1	3PET	\N	Reconstruction Method	t	f	f	\N	\N
(0054,1104)	84	4356	0	0	0	0	LO	1	3PET	\N	Detector Lines of Response Used	t	f	f	\N	\N
(0054,1105)	84	4357	0	0	0	0	LO	1	3PET	\N	Scatter Correction Method	t	f	f	\N	\N
(0054,1200)	84	4608	0	0	0	0	DS	1	3PET	\N	Axial Acceptance	t	f	f	\N	\N
(0054,1201)	84	4609	0	0	0	0	IS	2	3PET	\N	Axial Mash	t	f	f	\N	\N
(0054,1202)	84	4610	0	0	0	0	IS	1	3PET	\N	Transverse Mash	t	f	f	\N	\N
(0054,1203)	84	4611	0	0	0	0	DS	2	3PET	\N	Detector Element Size	t	f	f	\N	\N
(0054,1210)	84	4624	0	0	0	0	DS	1	3PET	\N	Coincidence Window Width	t	f	f	\N	\N
(0054,1220)	84	4640	0	0	0	0	CS	1-n	3PET	\N	Secondary Counts Type	t	f	f	\N	\N
(0054,1300)	84	4864	0	0	0	0	DS	1	3PET	\N	Frame Reference Time	t	f	f	\N	\N
(0054,1310)	84	4880	0	0	0	0	IS	1	3PET	\N	Primary Prompts Counts Accumulated	t	f	f	\N	\N
(0054,1311)	84	4881	0	0	0	0	IS	1-n	3PET	\N	Secondary Counts Accumulated	t	f	f	\N	\N
(0054,1320)	84	4896	0	0	0	0	DS	1	3PET	\N	Slice Sensitivity Factor	t	f	f	\N	\N
(0054,1321)	84	4897	0	0	0	0	DS	1	3PET	\N	Decay Factor	t	f	f	\N	\N
(0054,1322)	84	4898	0	0	0	0	DS	1	3PET	\N	Dose Calibration Factor	t	f	f	\N	\N
(0054,1323)	84	4899	0	0	0	0	DS	1	3PET	\N	Scatter Fraction Factor	t	f	f	\N	\N
(0054,1324)	84	4900	0	0	0	0	DS	1	3PET	\N	Dead Time Factor	t	f	f	\N	\N
(0054,1330)	84	4912	0	0	0	0	US	1	3PET	\N	Image Index	t	f	f	\N	\N
(0054,1400)	84	5120	0	0	0	0	CS	1-n	3PET	\N	Counts Included	t	f	f	\N	\N
(0054,1401)	84	5121	0	0	0	0	CS	1	3PET	\N	Dead Time Correction Flag	t	f	f	\N	\N
(0060,3000)	96	12288	0	0	0	0	SQ	1	3DX	\N	Histogram Sequence	t	f	f	\N	\N
(0060,3002)	96	12290	0	0	0	0	US	1	3DX	\N	Histogram Number of Bins	t	f	f	\N	\N
(0060,3008)	96	12296	0	0	0	0	US	1	3DX	\N	Histogram Bin Width	t	f	f	\N	\N
(0060,3010)	96	12304	0	0	0	0	LO	1	3DX	\N	Histogram Explanation	t	f	f	\N	\N
(0060,3020)	96	12320	0	0	0	0	UL	1-n	3DX	\N	Histogram Data	t	f	f	\N	\N
(0070,0001)	112	1	0	0	0	0	SQ	1	3SCP	\N	Graphic Annotation Sequence	t	f	f	\N	\N
(0070,0002)	112	2	0	0	0	0	CS	1	3SCP	\N	Graphic Layer	t	f	f	\N	\N
(0070,0003)	112	3	0	0	0	0	CS	1	3SCP	\N	Bounding Box Annotation Units	t	f	f	\N	\N
(0070,0004)	112	4	0	0	0	0	CS	1	3SCP	\N	Anchor Point Annotation Units	t	f	f	\N	\N
(0070,0005)	112	5	0	0	0	0	CS	1	3SCP	\N	Graphic Annotation Units	t	f	f	\N	\N
(0070,0006)	112	6	0	0	0	0	ST	1	3SCP	\N	Unformatted Text Value	t	f	f	\N	\N
(0070,0008)	112	8	0	0	0	0	SQ	1	3SCP	\N	Text Object Sequence	t	f	f	\N	\N
(0070,0009)	112	9	0	0	0	0	SQ	1	3SCP	\N	Graphic Object Sequence	t	f	f	\N	\N
(0070,0010)	112	16	0	0	0	0	FL	2	3SCP	\N	Bounding Box TLHC	t	f	f	\N	\N
(0070,0011)	112	17	0	0	0	0	FL	2	3SCP	\N	Bounding Box BRHC	t	f	f	\N	\N
(0070,0012)	112	18	0	0	0	0	CS	1	3SCP	\N	Bounding Box Text Horizontal Justification	t	f	f	\N	\N
(0070,0014)	112	20	0	0	0	0	FL	2	3SCP	\N	Anchor Point	t	f	f	\N	\N
(0070,0015)	112	21	0	0	0	0	CS	1	3SCP	\N	Anchor Point Visibility	t	f	f	\N	\N
(0070,0020)	112	32	0	0	0	0	US	1	3SCP	\N	Graphic Dimensions	t	f	f	\N	\N
(0070,0021)	112	33	0	0	0	0	US	1	3SCP	\N	Number Of Graphic Points	t	f	f	\N	\N
(0070,0022)	112	34	0	0	0	0	FL	1-n	3SCP	\N	Graphic Data	t	f	f	\N	\N
(0070,0023)	112	35	0	0	0	0	CS	1	3SCP	\N	Graphic Type	t	f	f	\N	\N
(0070,0024)	112	36	0	0	0	0	CS	1	3SCP	\N	Graphic Filled	t	f	f	\N	\N
(0070,0041)	112	65	0	0	0	0	CS	1	3SCP	\N	Image Horizontal Flip	t	f	f	\N	\N
(0070,0042)	112	66	0	0	0	0	US	1	3SCP	\N	Image Rotation	t	f	f	\N	\N
(0070,0052)	112	82	0	0	0	0	SL	2	3SCP	\N	Displayed Area TLHC	t	f	f	\N	\N
(0070,0053)	112	83	0	0	0	0	SL	2	3SCP	\N	Displayed Area BRHC	t	f	f	\N	\N
(0070,005a)	112	90	0	0	0	0	SQ	1	3SCP	\N	Displayed Area Selection Sequence	t	f	f	\N	\N
(0070,0060)	112	96	0	0	0	0	SQ	1	3SCP	\N	Graphic Layer Sequence	t	f	f	\N	\N
(0070,0062)	112	98	0	0	0	0	IS	1	3SCP	\N	Graphic Layer Order	t	f	f	\N	\N
(0070,0066)	112	102	0	0	0	0	US	1	3SCP	\N	Graphic Layer Recommended Display Grayscale Value	t	f	f	\N	\N
(0070,0068)	112	104	0	0	0	0	LO	1	3SCP	\N	Graphic Layer Description	t	f	f	\N	\N
(0070,0080)	112	128	0	0	0	0	CS	1	3SCP	\N	Presentation Label	t	f	f	\N	\N
(0070,0081)	112	129	0	0	0	0	LO	1	3SCP	\N	Presentation Description	t	f	f	\N	\N
(0070,0082)	112	130	0	0	0	0	DA	1	3SCP	\N	Presentation Creation Date	t	f	f	\N	\N
(0070,0083)	112	131	0	0	0	0	TM	1	3SCP	\N	Presentation Creation Time	t	f	f	\N	\N
(0070,0084)	112	132	0	0	0	0	PN	1	3SCP	\N	Presentation Creator's Name	t	f	f	\N	\N
(0070,0100)	112	256	0	0	0	0	CS	1	3SCP	\N	Presentation Size Mode	t	f	f	\N	\N
(0070,0101)	112	257	0	0	0	0	DS	2	3SCP	\N	Presentation Pixel Spacing	t	f	f	\N	\N
(0070,0102)	112	258	0	0	0	0	IS	2	3SCP	\N	Presentation Pixel Aspect Ratio	t	f	f	\N	\N
(0070,0103)	112	259	0	0	0	0	FL	1	3SCP	\N	Presentation Pixel Magnification Ratio	t	f	f	\N	\N
(0088,0130)	136	304	0	0	0	0	SH	1	3	\N	Storage Media FileSet ID	t	f	f	\N	\N
(0088,0140)	136	320	0	0	0	0	UI	1	3	\N	Storage Media FileSet UID	t	f	f	\N	\N
(0088,0200)	136	512	0	0	0	0	SQ	1	3	\N	Icon Image Sequence	t	f	f	\N	\N
(0088,0904)	136	2308	0	0	0	0	LO	1	3	\N	Topic Title	t	f	f	\N	\N
(0088,0906)	136	2310	0	0	0	0	ST	1	3	\N	Topic Subject	t	f	f	\N	\N
(0088,0910)	136	2320	0	0	0	0	LO	1	3	\N	Topic Author	t	f	f	\N	\N
(0088,0912)	136	2322	0	0	0	0	LO	1-32	3	\N	Topic Key Words	t	f	f	\N	\N
(0100,0410)	256	1040	0	0	0	0	CS	1	3SEC	\N	SOP Instance Status	t	f	f	\N	\N
(0100,0420)	256	1056	0	0	0	0	DT	1	3SEC	\N	SOP Authorization Date and Time	t	f	f	\N	\N
(0100,0424)	256	1060	0	0	0	0	LT	1	3SEC	\N	SOP Authorization Comment	t	f	f	\N	\N
(0100,0426)	256	1062	0	0	0	0	LO	1	3SEC	\N	Authorization Equipment Certification Number	t	f	f	\N	\N
(0400,0005)	1024	5	0	0	0	0	US	1	3SIG	\N	MAC ID Number	t	f	f	\N	\N
(0400,0010)	1024	16	0	0	0	0	UI	1	3SIG	\N	MAC Calculation Transfer Syntax UID	t	f	f	\N	\N
(0400,0015)	1024	21	0	0	0	0	CS	1	3SIG	\N	MAC Algorithm	t	f	f	\N	\N
(0400,0020)	1024	32	0	0	0	0	AT	1-n	3SIG	\N	Data Elements Signed	t	f	f	\N	\N
(0400,0100)	1024	256	0	0	0	0	UI	1	3SIG	\N	Digital Signature UID	t	f	f	\N	\N
(0400,0105)	1024	261	0	0	0	0	DT	1	3SIG	\N	Digital Signature DateTime	t	f	f	\N	\N
(0400,0110)	1024	272	0	0	0	0	CS	1	3SIG	\N	Certificate Type	t	f	f	\N	\N
(0400,0115)	1024	277	0	0	0	0	OB	1	3SIG	\N	Certificate of Signer	t	f	f	\N	\N
(0400,0120)	1024	288	0	0	0	0	OB	1	3SIG	\N	Signature	t	f	f	\N	\N
(0400,0305)	1024	773	0	0	0	0	CS	1	3SIG	\N	CertifiedTimestampType	t	f	f	\N	\N
(0400,0310)	1024	784	0	0	0	0	OB	1	3SIG	\N	CertifiedTimestamp	t	f	f	\N	\N
(2000,0010)	8192	16	0	0	0	0	IS	1	3	\N	Number of Copies	t	f	f	\N	\N
(2000,001e)	8192	30	0	0	0	0	SQ	1	3PCF	\N	Printer Configuration Sequence	t	f	f	\N	\N
(2000,0020)	8192	32	0	0	0	0	CS	1	3	\N	Print Priority	t	f	f	\N	\N
(2000,0030)	8192	48	0	0	0	0	CS	1	3	\N	Medium Type	t	f	f	\N	\N
(2000,0040)	8192	64	0	0	0	0	CS	1	3	\N	Film Destination	t	f	f	\N	\N
(2000,0050)	8192	80	0	0	0	0	LO	1	3	\N	Film Session Label	t	f	f	\N	\N
(2000,0060)	8192	96	0	0	0	0	IS	1	3	\N	Memory Allocation	t	f	f	\N	\N
(2000,0061)	8192	97	0	0	0	0	IS	1	3PCF	\N	Maximum Memory Allocation	t	f	f	\N	\N
(2000,00a0)	8192	160	0	0	0	0	US	1	3PCF	\N	Memory Bit Depth	t	f	f	\N	\N
(2000,00a1)	8192	161	0	0	0	0	US	1	3PCF	\N	Printing Bit Depth	t	f	f	\N	\N
(2000,00a2)	8192	162	0	0	0	0	SQ	1	3PCF	\N	Media Installed Sequence	t	f	f	\N	\N
(2000,00a4)	8192	164	0	0	0	0	SQ	1	3PCF	\N	Other Media Available Sequence	t	f	f	\N	\N
(2000,00a8)	8192	168	0	0	0	0	SQ	1	3PCF	\N	Supported Image Display Formats Sequence	t	f	f	\N	\N
(2000,0500)	8192	1280	0	0	0	0	SQ	1	3	\N	Referenced Film Box Sequence	t	f	f	\N	\N
(2000,0510)	8192	1296	0	0	0	0	SQ	1	3STP	\N	Referenced Stored Print Sequence	t	f	f	\N	\N
(2010,0010)	8208	16	0	0	0	0	ST	1	3	\N	Image Display Format	t	f	f	\N	\N
(2010,0030)	8208	48	0	0	0	0	CS	1	3	\N	Annotation Display Format ID	t	f	f	\N	\N
(2010,0040)	8208	64	0	0	0	0	CS	1	3	\N	Film Orientation	t	f	f	\N	\N
(2010,0050)	8208	80	0	0	0	0	CS	1	3	\N	Film Size ID	t	f	f	\N	\N
(2010,0052)	8208	82	0	0	0	0	CS	1	3PCF	\N	Printer Resolution ID	t	f	f	\N	\N
(2010,0054)	8208	84	0	0	0	0	CS	1	3PCF	\N	Default Printer Resolution ID	t	f	f	\N	\N
(2010,0060)	8208	96	0	0	0	0	CS	1	3	\N	Magnification Type	t	f	f	\N	\N
(2010,0080)	8208	128	0	0	0	0	CS	1	3	\N	Smoothing Type	t	f	f	\N	\N
(2010,00a6)	8208	166	0	0	0	0	CS	1	3PCF	\N	Default Magnification Type	t	f	f	\N	\N
(2010,00a7)	8208	167	0	0	0	0	CS	1-n	3PCF	\N	Other Magnification Types Available	t	f	f	\N	\N
(2010,00a8)	8208	168	0	0	0	0	CS	1	3PCF	\N	Default Smoothing Type	t	f	f	\N	\N
(2010,00a9)	8208	169	0	0	0	0	CS	1-n	3PCF	\N	Other Smoothing Types Available	t	f	f	\N	\N
(2010,0100)	8208	256	0	0	0	0	CS	1	3	\N	Border Density	t	f	f	\N	\N
(2010,0110)	8208	272	0	0	0	0	CS	1	3	\N	Empty Image Density	t	f	f	\N	\N
(2010,0120)	8208	288	0	0	0	0	US	1	3	\N	Min Density	t	f	f	\N	\N
(2010,0130)	8208	304	0	0	0	0	US	1	3	\N	Max Density	t	f	f	\N	\N
(2010,0150)	8208	336	0	0	0	0	ST	1	3	\N	Configuration Information	t	f	f	\N	\N
(2010,0152)	8208	338	0	0	0	0	LT	1	3PCF	\N	Configuration Information Description	t	f	f	\N	\N
(2010,0154)	8208	340	0	0	0	0	IS	1	3PCF	\N	Maximum Collated Films	t	f	f	\N	\N
(2010,015e)	8208	350	0	0	0	0	US	1	3LUT	\N	Illumination	t	f	f	\N	\N
(2010,0160)	8208	352	0	0	0	0	US	1	3LUT	\N	Reflected Ambient Light	t	f	f	\N	\N
(2010,0376)	8208	886	0	0	0	0	DS	2	3PCF	\N	Printer Pixel Spacing	t	f	f	\N	\N
(2010,0500)	8208	1280	0	0	0	0	SQ	1	3	\N	Referenced Film Session Sequence	t	f	f	\N	\N
(2010,0510)	8208	1296	0	0	0	0	SQ	1	3	\N	Referenced Image Box Sequence	t	f	f	\N	\N
(2010,0520)	8208	1312	0	0	0	0	SQ	1	3	\N	Referenced Basic Annotation Box Sequence	t	f	f	\N	\N
(2020,0010)	8224	16	0	0	0	0	US	1	3	\N	Image Box Position	t	f	f	\N	\N
(2020,0020)	8224	32	0	0	0	0	CS	1	3	\N	Polarity	t	f	f	\N	\N
(2020,0030)	8224	48	0	0	0	0	DS	1	3	\N	Requested Image Size	t	f	f	\N	\N
(2020,0040)	8224	64	0	0	0	0	CS	1	3PCF	\N	Requested Decimate/Crop Behavior	t	f	f	\N	\N
(2020,0050)	8224	80	0	0	0	0	CS	1	3PCF	\N	Requested Resolution ID	t	f	f	\N	\N
(2020,00a0)	8224	160	0	0	0	0	CS	1	3PCF	\N	Requested Image Size Flag	t	f	f	\N	\N
(2020,00a2)	8224	162	0	0	0	0	CS	1	3PCF	\N	Decimate/Crop Result	t	f	f	\N	\N
(2020,0110)	8224	272	0	0	0	0	SQ	1	3	\N	Basic Grayscale Image Sequence	t	f	f	\N	\N
(2020,0111)	8224	273	0	0	0	0	SQ	1	3	\N	Basic Color Image Sequence	t	f	f	\N	\N
(2030,0010)	8240	16	0	0	0	0	US	1	3	\N	Annotation Position	t	f	f	\N	\N
(2030,0020)	8240	32	0	0	0	0	LO	1	3	\N	Text String	t	f	f	\N	\N
(2050,0010)	8272	16	0	0	0	0	SQ	1	3PLT	\N	Presentation LUT Sequence	t	f	f	\N	\N
(2050,0020)	8272	32	0	0	0	0	CS	1	3	\N	Presentation LUT Shape	t	f	f	\N	\N
(2050,0500)	8272	1280	0	0	0	0	SQ	1	3???	\N	Referenced Presentation LUT Sequence	t	f	f	\N	\N
(2100,0010)	8448	16	0	0	0	0	SH	1	3PQ	\N	Print Job ID	t	f	f	\N	\N
(2100,0020)	8448	32	0	0	0	0	CS	1	3	\N	Execution Status	t	f	f	\N	\N
(2100,0030)	8448	48	0	0	0	0	CS	1	3	\N	Execution Status Info	t	f	f	\N	\N
(2100,0040)	8448	64	0	0	0	0	DA	1	3	\N	Creation Date	t	f	f	\N	\N
(2100,0050)	8448	80	0	0	0	0	TM	1	3	\N	Creation Time	t	f	f	\N	\N
(2100,0070)	8448	112	0	0	0	0	AE	1	3	\N	Originator	t	f	f	\N	\N
(2100,0140)	8448	320	0	0	0	0	AE	1	3PQ	\N	Destination AE	t	f	f	\N	\N
(2100,0160)	8448	352	0	0	0	0	SH	1	3PQ	\N	OwnerID	t	f	f	\N	\N
(2100,0170)	8448	368	0	0	0	0	IS	1	3PQ	\N	Number Of Films	t	f	f	\N	\N
(2110,0010)	8464	16	0	0	0	0	CS	1	3	\N	Printer Status	t	f	f	\N	\N
(2110,0020)	8464	32	0	0	0	0	CS	1	3	\N	Printer Status Info	t	f	f	\N	\N
(2110,0030)	8464	48	0	0	0	0	LO	1	3	\N	Printer Name	t	f	f	\N	\N
(3002,0002)	12290	2	0	0	0	0	SH	1	3RT	\N	RT Image Label	t	f	f	\N	\N
(3002,0003)	12290	3	0	0	0	0	LO	1	3RT	\N	RT Image Name	t	f	f	\N	\N
(3002,0004)	12290	4	0	0	0	0	ST	1	3RT	\N	RT Image Description	t	f	f	\N	\N
(3002,000a)	12290	10	0	0	0	0	CS	1	3RT	\N	Reported Values Origin	t	f	f	\N	\N
(3002,000c)	12290	12	0	0	0	0	CS	1	3RT	\N	RT Image Plane	t	f	f	\N	\N
(3002,000e)	12290	14	0	0	0	0	DS	1	3RT	\N	X-Ray Image Receptor Angle	t	f	f	\N	\N
(3002,0010)	12290	16	0	0	0	0	DS	6	3RT	\N	RTImageOrientation	t	f	f	\N	\N
(3002,0011)	12290	17	0	0	0	0	DS	2	3RT	\N	Image Plane Pixel Spacing	t	f	f	\N	\N
(3002,0012)	12290	18	0	0	0	0	DS	2	3RT	\N	RT Image Position	t	f	f	\N	\N
(3002,0020)	12290	32	0	0	0	0	SH	1	3RT	\N	Radiation Machine Name	t	f	f	\N	\N
(3002,0022)	12290	34	0	0	0	0	DS	1	3RT	\N	Radiation Machine SAD	t	f	f	\N	\N
(3002,0024)	12290	36	0	0	0	0	DS	1	3RT	\N	Radiation Machine SSD	t	f	f	\N	\N
(3002,0026)	12290	38	0	0	0	0	DS	1	3RT	\N	RT Image SID	t	f	f	\N	\N
(3002,0028)	12290	40	0	0	0	0	DS	1	3RT	\N	Source to Reference Object Distance	t	f	f	\N	\N
(3002,0029)	12290	41	0	0	0	0	IS	1	3RT	\N	Fraction Number	t	f	f	\N	\N
(3002,0030)	12290	48	0	0	0	0	SQ	1	3RT	\N	Exposure Sequence	t	f	f	\N	\N
(3002,0032)	12290	50	0	0	0	0	DS	1	3RT	\N	Meterset Exposure	t	f	f	\N	\N
(3002,0034)	12290	52	0	0	0	0	DS	4	3RT	\N	Diaphragm Position	t	f	f	\N	\N
(3004,0001)	12292	1	0	0	0	0	CS	1	3RT	\N	DVH Type	t	f	f	\N	\N
(3004,0002)	12292	2	0	0	0	0	CS	1	3RT	\N	Dose Units	t	f	f	\N	\N
(3004,0004)	12292	4	0	0	0	0	CS	1	3RT	\N	Dose Type	t	f	f	\N	\N
(3004,0006)	12292	6	0	0	0	0	LO	1	3RT	\N	Dose Comment	t	f	f	\N	\N
(3004,0008)	12292	8	0	0	0	0	DS	3	3RT	\N	Normalization Point	t	f	f	\N	\N
(3004,000a)	12292	10	0	0	0	0	CS	1	3RT	\N	Dose Summation Type	t	f	f	\N	\N
(3004,000c)	12292	12	0	0	0	0	DS	2-n	3RT	\N	GridFrame Offset Vector	t	f	f	\N	\N
(3004,000e)	12292	14	0	0	0	0	DS	1	3RT	\N	Dose Grid Scaling	t	f	f	\N	\N
(3004,0010)	12292	16	0	0	0	0	SQ	1	3RT	\N	RT Dose ROI Sequence	t	f	f	\N	\N
(3004,0012)	12292	18	0	0	0	0	DS	1	3RT	\N	Dose Value	t	f	f	\N	\N
(3004,0040)	12292	64	0	0	0	0	DS	3	3RT	\N	DVH Normalization Point	t	f	f	\N	\N
(3004,0042)	12292	66	0	0	0	0	DS	1	3RT	\N	DVH Normalization Dose Value	t	f	f	\N	\N
(3004,0052)	12292	82	0	0	0	0	DS	1	3RT	\N	DVH Dose Scaling	t	f	f	\N	\N
(3004,0054)	12292	84	0	0	0	0	CS	1	3RT	\N	DVH Volume Units	t	f	f	\N	\N
(3004,0056)	12292	86	0	0	0	0	IS	1	3RT	\N	DVH Number of Bins	t	f	f	\N	\N
(3004,0058)	12292	88	0	0	0	0	DS	2-n	3RT	\N	DVH Data	t	f	f	\N	\N
(3004,0060)	12292	96	0	0	0	0	SQ	1	3RT	\N	DVH Referenced ROI Sequence	t	f	f	\N	\N
(3004,0062)	12292	98	0	0	0	0	CS	1	3RT	\N	DVH ROI Contribution Type	t	f	f	\N	\N
(3004,0070)	12292	112	0	0	0	0	DS	1	3RT	\N	DVH Minimum Dose	t	f	f	\N	\N
(3004,0072)	12292	114	0	0	0	0	DS	1	3RT	\N	DVH Maximum Dose	t	f	f	\N	\N
(3004,0074)	12292	116	0	0	0	0	DS	1	3RT	\N	DVH Mean Dose	t	f	f	\N	\N
(3006,0002)	12294	2	0	0	0	0	SH	1	3RT	\N	Structure Set Label	t	f	f	\N	\N
(3006,0004)	12294	4	0	0	0	0	LO	1	3RT	\N	Structure Set Name	t	f	f	\N	\N
(3006,0006)	12294	6	0	0	0	0	ST	1	3RT	\N	Structure Set Description	t	f	f	\N	\N
(3006,0008)	12294	8	0	0	0	0	DA	1	3RT	\N	Structure Set Date	t	f	f	\N	\N
(3006,0009)	12294	9	0	0	0	0	TM	1	3RT	\N	Structure Set Time	t	f	f	\N	\N
(3006,0010)	12294	16	0	0	0	0	SQ	1	3RT	\N	Referenced Frame of Reference Sequence	t	f	f	\N	\N
(3006,0012)	12294	18	0	0	0	0	SQ	1	3RT	\N	RT Referenced Study Sequence	t	f	f	\N	\N
(3006,0014)	12294	20	0	0	0	0	SQ	1	3RT	\N	RT Referenced Series Sequence	t	f	f	\N	\N
(3006,0016)	12294	22	0	0	0	0	SQ	1	3RT	\N	Contour Image Sequence	t	f	f	\N	\N
(3006,0020)	12294	32	0	0	0	0	SQ	1	3RT	\N	Structure Set ROI Sequence	t	f	f	\N	\N
(3006,0024)	12294	36	0	0	0	0	UI	1	3RT	\N	Referenced Frame of Reference UID	t	f	f	\N	\N
(3006,0026)	12294	38	0	0	0	0	LO	1	3RT	\N	ROI Name	t	f	f	\N	\N
(3006,0028)	12294	40	0	0	0	0	ST	1	3RT	\N	ROI Description	t	f	f	\N	\N
(3006,002a)	12294	42	0	0	0	0	IS	3	3RT	\N	ROI Display Color	t	f	f	\N	\N
(3006,002c)	12294	44	0	0	0	0	DS	1	3RT	\N	ROI Volume	t	f	f	\N	\N
(3006,0030)	12294	48	0	0	0	0	SQ	1	3RT	\N	RT Related ROI Sequence	t	f	f	\N	\N
(3006,0033)	12294	51	0	0	0	0	CS	1	3RT	\N	RT ROI Relationship	t	f	f	\N	\N
(3006,0036)	12294	54	0	0	0	0	CS	1	3RT	\N	ROI Generation Algorithm	t	f	f	\N	\N
(3006,0038)	12294	56	0	0	0	0	LO	1	3RT	\N	ROI Generation Description	t	f	f	\N	\N
(3006,0039)	12294	57	0	0	0	0	SQ	1	3RT	\N	ROI Contour Sequence	t	f	f	\N	\N
(3006,0040)	12294	64	0	0	0	0	SQ	1	3RT	\N	Contour Sequence	t	f	f	\N	\N
(3006,0042)	12294	66	0	0	0	0	CS	1	3RT	\N	Contour Geometric Type	t	f	f	\N	\N
(3006,0044)	12294	68	0	0	0	0	DS	1	3RT	\N	Contour Slab Thickness	t	f	f	\N	\N
(3006,0045)	12294	69	0	0	0	0	DS	3	3RT	\N	Contour Offset Vector	t	f	f	\N	\N
(3006,0046)	12294	70	0	0	0	0	IS	1	3RT	\N	Number of Contour Points	t	f	f	\N	\N
(3006,0048)	12294	72	0	0	0	0	IS	1	3RT	\N	Contour Number	t	f	f	\N	\N
(3006,0049)	12294	73	0	0	0	0	IS	1-n	3RT	\N	Attached Contours	t	f	f	\N	\N
(3006,0050)	12294	80	0	0	0	0	DS	3-n	3RT	\N	Contour Data	t	f	f	\N	\N
(3006,0080)	12294	128	0	0	0	0	SQ	1	3RT	\N	RT ROI Observations Sequence	t	f	f	\N	\N
(3006,0082)	12294	130	0	0	0	0	IS	1	3RT	\N	Observation Number	t	f	f	\N	\N
(3006,0084)	12294	132	0	0	0	0	IS	1	3RT	\N	Referenced ROI Number	t	f	f	\N	\N
(3006,0085)	12294	133	0	0	0	0	SH	1	3RT	\N	ROI Observation Label	t	f	f	\N	\N
(3006,0086)	12294	134	0	0	0	0	SQ	1	3RT	\N	RT ROI Identification Code Sequence	t	f	f	\N	\N
(3006,0088)	12294	136	0	0	0	0	ST	1	3RT	\N	ROI Observation Description	t	f	f	\N	\N
(3006,00a0)	12294	160	0	0	0	0	SQ	1	3RT	\N	Related RT ROI Observations Sequence	t	f	f	\N	\N
(3006,00a4)	12294	164	0	0	0	0	CS	1	3RT	\N	RT ROI Interpreted Type	t	f	f	\N	\N
(3006,00a6)	12294	166	0	0	0	0	PN	1	3RT	\N	ROI Interpreter	t	f	f	\N	\N
(3006,00b0)	12294	176	0	0	0	0	SQ	1	3RT	\N	ROI Physical Properties Sequence	t	f	f	\N	\N
(3006,00b2)	12294	178	0	0	0	0	CS	1	3RT	\N	ROI Physical Property	t	f	f	\N	\N
(3006,00b4)	12294	180	0	0	0	0	DS	1	3RT	\N	ROI Physical Property Value	t	f	f	\N	\N
(3006,00c0)	12294	192	0	0	0	0	SQ	1	3RT	\N	Frame of Reference Relationship Sequence	t	f	f	\N	\N
(3006,00c2)	12294	194	0	0	0	0	UI	1	3RT	\N	Related Frame of Reference UID	t	f	f	\N	\N
(3006,00c6)	12294	198	0	0	0	0	DS	16	3RT	\N	Frame of Reference Transformation Matrix	t	f	f	\N	\N
(3006,00c8)	12294	200	0	0	0	0	LO	1	3RT	\N	Frame of Reference Transformation Comment	t	f	f	\N	\N
(3008,0010)	12296	16	0	0	0	0	SQ	1	3RT	\N	Measured Dose Reference Sequence	t	f	f	\N	\N
(3008,0012)	12296	18	0	0	0	0	ST	1	3RT	\N	Measured Dose Description	t	f	f	\N	\N
(3008,0014)	12296	20	0	0	0	0	CS	1	3RT	\N	Measured Dose Type	t	f	f	\N	\N
(3008,0016)	12296	22	0	0	0	0	DS	1	3RT	\N	Measured Dose Value	t	f	f	\N	\N
(3008,0020)	12296	32	0	0	0	0	SQ	1	3RT	\N	Treatment Session Beam Sequence	t	f	f	\N	\N
(3008,0022)	12296	34	0	0	0	0	IS	1	3RT	\N	Current Fraction  Number	t	f	f	\N	\N
(3008,0024)	12296	36	0	0	0	0	DA	1	3RT	\N	Treatment Control Point Date	t	f	f	\N	\N
(3008,0025)	12296	37	0	0	0	0	TM	1	3RT	\N	Treatment Control Point Time	t	f	f	\N	\N
(3008,002a)	12296	42	0	0	0	0	CS	1	3RT	\N	Treatment Termination Status	t	f	f	\N	\N
(3008,002b)	12296	43	0	0	0	0	SH	1	3RT	\N	Treatment Termination Code	t	f	f	\N	\N
(3008,002c)	12296	44	0	0	0	0	CS	1	3RT	\N	Treatment Verification Status	t	f	f	\N	\N
(3008,0030)	12296	48	0	0	0	0	SQ	1	3RT	\N	Referenced Treatment Record Sequence	t	f	f	\N	\N
(3008,0032)	12296	50	0	0	0	0	DS	1	3RT	\N	Specified Primary Meterset	t	f	f	\N	\N
(3008,0033)	12296	51	0	0	0	0	DS	1	3RT	\N	Specified Secondary Meterset	t	f	f	\N	\N
(3008,0036)	12296	54	0	0	0	0	DS	1	3RT	\N	Delivered Primary Meterset	t	f	f	\N	\N
(3008,0037)	12296	55	0	0	0	0	DS	1	3RT	\N	Delivered Secondary Meterset	t	f	f	\N	\N
(3008,003a)	12296	58	0	0	0	0	DS	1	3RT	\N	Specified Treatment  Time	t	f	f	\N	\N
(3008,003b)	12296	59	0	0	0	0	DS	1	3RT	\N	Delivered Treatment Time	t	f	f	\N	\N
(3008,0040)	12296	64	0	0	0	0	SQ	1	3RT	\N	Control Point Delivery Sequence	t	f	f	\N	\N
(3008,0042)	12296	66	0	0	0	0	DS	1	3RT	\N	Specified Meterset	t	f	f	\N	\N
(3008,0044)	12296	68	0	0	0	0	DS	1	3RT	\N	Delivered Meterset	t	f	f	\N	\N
(3008,0048)	12296	72	0	0	0	0	DS	1	3RT	\N	Dose Rate Delivered	t	f	f	\N	\N
(3008,0050)	12296	80	0	0	0	0	SQ	1	3RT	\N	Treatment Summary Calculated Dose Reference Sequence	t	f	f	\N	\N
(3008,0052)	12296	82	0	0	0	0	DS	1	3RT	\N	Cumulative Dose to Dose Reference	t	f	f	\N	\N
(3008,0054)	12296	84	0	0	0	0	DA	1	3RT	\N	First Treatment Date	t	f	f	\N	\N
(3008,0056)	12296	86	0	0	0	0	DA	1	3RT	\N	Most Recent Treatment Date	t	f	f	\N	\N
(3008,005a)	12296	90	0	0	0	0	IS	1	3RT	\N	Number of Fractions Delivered	t	f	f	\N	\N
(3008,0060)	12296	96	0	0	0	0	SQ	1	3RT	\N	Override Sequence	t	f	f	\N	\N
(3008,0062)	12296	98	0	0	0	0	AT	1	3RT	\N	Override Parameter Pointer	t	f	f	\N	\N
(3008,0064)	12296	100	0	0	0	0	IS	1	3RT	\N	Measured Dose Reference Number	t	f	f	\N	\N
(3008,0066)	12296	102	0	0	0	0	ST	1	3RT	\N	Override Reason	t	f	f	\N	\N
(3008,0070)	12296	112	0	0	0	0	SQ	1	3RT	\N	Calculated Dose Reference Sequence	t	f	f	\N	\N
(3008,0072)	12296	114	0	0	0	0	IS	1	3RT	\N	Calculated Dose Reference Number	t	f	f	\N	\N
(3008,0074)	12296	116	0	0	0	0	ST	1	3RT	\N	Calculated Dose Reference Description	t	f	f	\N	\N
(3008,0076)	12296	118	0	0	0	0	DS	1	3RT	\N	Calculated Dose Reference Dose Value	t	f	f	\N	\N
(3008,0078)	12296	120	0	0	0	0	DS	1	3RT	\N	Start Meterset	t	f	f	\N	\N
(3008,007a)	12296	122	0	0	0	0	DS	1	3RT	\N	End Meterset	t	f	f	\N	\N
(3008,0080)	12296	128	0	0	0	0	SQ	1	3RT	\N	Referenced Measured Dose Reference Sequence	t	f	f	\N	\N
(3008,0082)	12296	130	0	0	0	0	IS	1	3RT	\N	Referenced Measured Dose Reference Number	t	f	f	\N	\N
(3008,0090)	12296	144	0	0	0	0	SQ	1	3RT	\N	Referenced Calculated Dose Reference Sequence	t	f	f	\N	\N
(3008,0092)	12296	146	0	0	0	0	IS	1	3RT	\N	Referenced Calculated Dose Reference Number	t	f	f	\N	\N
(3008,00a0)	12296	160	0	0	0	0	SQ	1	3RT	\N	Beam Limiting Device Leaf Pairs Sequence	t	f	f	\N	\N
(3008,00b0)	12296	176	0	0	0	0	SQ	1	3RT	\N	Recorded Wedge Sequence	t	f	f	\N	\N
(3008,00c0)	12296	192	0	0	0	0	SQ	1	3RT	\N	Recorded Compensator Sequence	t	f	f	\N	\N
(3008,00d0)	12296	208	0	0	0	0	SQ	1	3RT	\N	Recorded Block Sequence	t	f	f	\N	\N
(3008,00e0)	12296	224	0	0	0	0	SQ	1	3RT	\N	Treatment Summary Measured Dose Reference Sequence 	t	f	f	\N	\N
(3008,0100)	12296	256	0	0	0	0	SQ	1	3RT	\N	Recorded Source Sequence	t	f	f	\N	\N
(3008,0105)	12296	261	0	0	0	0	LO	1	3RT	\N	Source Serial Number	t	f	f	\N	\N
(3008,0110)	12296	272	0	0	0	0	SQ	1	3RT	\N	Treatment Session Application Setup Sequence	t	f	f	\N	\N
(3008,0116)	12296	278	0	0	0	0	CS	1	3RT	\N	Application Setup  Check	t	f	f	\N	\N
(3008,0120)	12296	288	0	0	0	0	SQ	1	3RT	\N	Recorded Brachy Accessory Device Sequence	t	f	f	\N	\N
(3008,0122)	12296	290	0	0	0	0	IS	1	3RT	\N	Referenced Brachy Accessory Device Number	t	f	f	\N	\N
(3008,0130)	12296	304	0	0	0	0	SQ	1	3RT	\N	Recorded Channel Sequence	t	f	f	\N	\N
(3008,0132)	12296	306	0	0	0	0	DS	1	3RT	\N	Specified Channel Total Time	t	f	f	\N	\N
(3008,0134)	12296	308	0	0	0	0	DS	1	3RT	\N	Delivered Channel Total Time	t	f	f	\N	\N
(3008,0136)	12296	310	0	0	0	0	IS	1	3RT	\N	Specified Number of Pulses	t	f	f	\N	\N
(3008,0138)	12296	312	0	0	0	0	IS	1	3RT	\N	Delivered Number of Pulses	t	f	f	\N	\N
(3008,013a)	12296	314	0	0	0	0	DS	1	3RT	\N	Specified Pulse Repetition Interval	t	f	f	\N	\N
(3008,013c)	12296	316	0	0	0	0	DS	1	3RT	\N	Delivered Pulse Repetition Interval	t	f	f	\N	\N
(3008,0140)	12296	320	0	0	0	0	SQ	1	3RT	\N	Recorded Source Applicator Sequence	t	f	f	\N	\N
(3008,0142)	12296	322	0	0	0	0	IS	1	3RT	\N	Referenced Source Applicator Number	t	f	f	\N	\N
(3008,0150)	12296	336	0	0	0	0	SQ	1	3RT	\N	Recorded Channel Shield Sequence	t	f	f	\N	\N
(3008,0152)	12296	338	0	0	0	0	IS	1	3RT	\N	Referenced Channel Shield Number	t	f	f	\N	\N
(3008,0160)	12296	352	0	0	0	0	SQ	1	3RT	\N	Brachy Control Point Delivered Sequence	t	f	f	\N	\N
(3008,0162)	12296	354	0	0	0	0	DA	1	3RT	\N	Safe Position Exit Date	t	f	f	\N	\N
(3008,0164)	12296	356	0	0	0	0	TM	1	3RT	\N	Safe Position Exit Time	t	f	f	\N	\N
(3008,0166)	12296	358	0	0	0	0	DA	1	3RT	\N	Safe Position Return  Date	t	f	f	\N	\N
(3008,0168)	12296	360	0	0	0	0	TM	1	3RT	\N	Safe Position Return Time	t	f	f	\N	\N
(3008,0200)	12296	512	0	0	0	0	CS	1	3RT	\N	Current Treatment  Status	t	f	f	\N	\N
(3008,0202)	12296	514	0	0	0	0	ST	1	3RT	\N	Treatment Status Comment	t	f	f	\N	\N
(3008,0220)	12296	544	0	0	0	0	SQ	1	3RT	\N	Fraction Group Summary Sequence	t	f	f	\N	\N
(3008,0223)	12296	547	0	0	0	0	IS	1	3RT	\N	Referenced Fraction Number	t	f	f	\N	\N
(3008,0224)	12296	548	0	0	0	0	CS	1	3RT	\N	Fraction Group Type	t	f	f	\N	\N
(3008,0230)	12296	560	0	0	0	0	CS	1	3RT	\N	Beam Stopper Position	t	f	f	\N	\N
(3008,0240)	12296	576	0	0	0	0	SQ	1	3RT	\N	Fraction Status Summary Sequence	t	f	f	\N	\N
(3008,0250)	12296	592	0	0	0	0	DA	1	3RT	\N	Treatment Date	t	f	f	\N	\N
(3008,0251)	12296	593	0	0	0	0	TM	1	3RT	\N	Treatment Time	t	f	f	\N	\N
(300a,0002)	12298	2	0	0	0	0	SH	1	3RT	\N	RT Plan Label	t	f	f	\N	\N
(300a,0003)	12298	3	0	0	0	0	LO	1	3RT	\N	RT Plan Name	t	f	f	\N	\N
(300a,0004)	12298	4	0	0	0	0	ST	1	3RT	\N	RT Plan Description	t	f	f	\N	\N
(300a,0006)	12298	6	0	0	0	0	DA	1	3RT	\N	RT Plan Date	t	f	f	\N	\N
(300a,0007)	12298	7	0	0	0	0	TM	1	3RT	\N	RT Plan Time	t	f	f	\N	\N
(300a,0009)	12298	9	0	0	0	0	LO	1-n	3RT	\N	Treatment Protocols	t	f	f	\N	\N
(300a,000a)	12298	10	0	0	0	0	CS	1	3RT	\N	Treatment Intent	t	f	f	\N	\N
(300a,000b)	12298	11	0	0	0	0	LO	1-n	3RT	\N	Treatment Sites	t	f	f	\N	\N
(300a,000c)	12298	12	0	0	0	0	CS	1	3RT	\N	RT Plan Geometry	t	f	f	\N	\N
(300a,000e)	12298	14	0	0	0	0	ST	1	3RT	\N	Prescription Description	t	f	f	\N	\N
(300a,0010)	12298	16	0	0	0	0	SQ	1	3RT	\N	Dose ReferenceSequence	t	f	f	\N	\N
(300a,0012)	12298	18	0	0	0	0	IS	1	3RT	\N	Dose ReferenceNumber	t	f	f	\N	\N
(300a,0014)	12298	20	0	0	0	0	CS	1	3RT	\N	Dose Reference Structure Type	t	f	f	\N	\N
(300a,0015)	12298	21	0	0	0	0	CS	1	3RT	\N	Nominal Beam Energy Unit	t	f	f	\N	\N
(300a,0016)	12298	22	0	0	0	0	LO	1	3RT	\N	Dose ReferenceDescription	t	f	f	\N	\N
(300a,0018)	12298	24	0	0	0	0	DS	3	3RT	\N	Dose Reference Point Coordinates	t	f	f	\N	\N
(300a,001a)	12298	26	0	0	0	0	DS	1	3RT	\N	Nominal Prior Dose	t	f	f	\N	\N
(300a,0020)	12298	32	0	0	0	0	CS	1	3RT	\N	Dose Reference Type	t	f	f	\N	\N
(300a,0021)	12298	33	0	0	0	0	DS	1	3RT	\N	Constraint Weight	t	f	f	\N	\N
(300a,0022)	12298	34	0	0	0	0	DS	1	3RT	\N	Delivery Warning Dose	t	f	f	\N	\N
(300a,0023)	12298	35	0	0	0	0	DS	1	3RT	\N	Delivery Maximum Dose	t	f	f	\N	\N
(300a,0025)	12298	37	0	0	0	0	DS	1	3RT	\N	Target Minimum Dose	t	f	f	\N	\N
(300a,0026)	12298	38	0	0	0	0	DS	1	3RT	\N	Target Prescription Dose	t	f	f	\N	\N
(300a,0027)	12298	39	0	0	0	0	DS	1	3RT	\N	Target Maximum Dose	t	f	f	\N	\N
(300a,0028)	12298	40	0	0	0	0	DS	1	3RT	\N	Target Underdose Volume Fraction	t	f	f	\N	\N
(300a,002a)	12298	42	0	0	0	0	DS	1	3RT	\N	Organ at Risk Full-volume Dose	t	f	f	\N	\N
(300a,002b)	12298	43	0	0	0	0	DS	1	3RT	\N	Organ at Risk Limit Dose	t	f	f	\N	\N
(300a,002c)	12298	44	0	0	0	0	DS	1	3RT	\N	Organ at Risk Maximum Dose	t	f	f	\N	\N
(300a,002d)	12298	45	0	0	0	0	DS	1	3RT	\N	Organ at Risk Overdose Volume Fraction	t	f	f	\N	\N
(300a,0040)	12298	64	0	0	0	0	SQ	1	3RT	\N	Tolerance Table Sequence	t	f	f	\N	\N
(300a,0042)	12298	66	0	0	0	0	IS	1	3RT	\N	Tolerance Table Number	t	f	f	\N	\N
(300a,0043)	12298	67	0	0	0	0	SH	1	3RT	\N	Tolerance Table Label	t	f	f	\N	\N
(300a,0044)	12298	68	0	0	0	0	DS	1	3RT	\N	Gantry Angle Tolerance	t	f	f	\N	\N
(300a,0046)	12298	70	0	0	0	0	DS	1	3RT	\N	Beam Limiting Device Angle Tolerance	t	f	f	\N	\N
(300a,0048)	12298	72	0	0	0	0	SQ	1	3RT	\N	Beam Limiting Device Tolerance Sequence	t	f	f	\N	\N
(300a,004a)	12298	74	0	0	0	0	DS	1	3RT	\N	Beam Limiting Device Position Tolerance	t	f	f	\N	\N
(300a,004c)	12298	76	0	0	0	0	DS	1	3RT	\N	Patient Support Angle Tolerance	t	f	f	\N	\N
(300a,004e)	12298	78	0	0	0	0	DS	1	3RT	\N	Table Top Eccentric Angle Tolerance	t	f	f	\N	\N
(300a,0051)	12298	81	0	0	0	0	DS	1	3RT	\N	Table Top Vertical Position Tolerance	t	f	f	\N	\N
(300a,0052)	12298	82	0	0	0	0	DS	1	3RT	\N	Table Top Longitudinal Position Tolerance	t	f	f	\N	\N
(300a,0053)	12298	83	0	0	0	0	DS	1	3RT	\N	Table Top Lateral Position Tolerance	t	f	f	\N	\N
(300a,0055)	12298	85	0	0	0	0	CS	1	3RT	\N	RT Plan Relationship	t	f	f	\N	\N
(300a,0070)	12298	112	0	0	0	0	SQ	1	3RT	\N	Fraction Group Sequence	t	f	f	\N	\N
(300a,0071)	12298	113	0	0	0	0	IS	1	3RT	\N	Fraction Group Number	t	f	f	\N	\N
(300a,0078)	12298	120	0	0	0	0	IS	1	3RT	\N	Number of Fractions Planned	t	f	f	\N	\N
(300a,0079)	12298	121	0	0	0	0	IS	1	3RT	\N	Number of Fraction Pattern Digits Per Day	t	f	f	\N	\N
(300a,007a)	12298	122	0	0	0	0	IS	1	3RT	\N	Repeat Fraction Cycle Length	t	f	f	\N	\N
(300a,007b)	12298	123	0	0	0	0	LT	1	3RT	\N	Fraction Pattern	t	f	f	\N	\N
(300a,0080)	12298	128	0	0	0	0	IS	1	3RT	\N	Number of Beams	t	f	f	\N	\N
(300a,0082)	12298	130	0	0	0	0	DS	3	3RT	\N	Beam Dose Specification Point	t	f	f	\N	\N
(300a,0084)	12298	132	0	0	0	0	DS	1	3RT	\N	Beam Dose	t	f	f	\N	\N
(300a,0086)	12298	134	0	0	0	0	DS	1	3RT	\N	Beam Meterset	t	f	f	\N	\N
(300a,00a0)	12298	160	0	0	0	0	IS	1	3RT	\N	Number of Brachy Application Setups	t	f	f	\N	\N
(300a,00a2)	12298	162	0	0	0	0	DS	3	3RT	\N	Brachy Application Setup Dose Specification Point	t	f	f	\N	\N
(300a,00a4)	12298	164	0	0	0	0	DS	1	3RT	\N	Brachy Application Setup Dose	t	f	f	\N	\N
(300a,00b0)	12298	176	0	0	0	0	SQ	1	3RT	\N	Beam Sequence	t	f	f	\N	\N
(300a,00b2)	12298	178	0	0	0	0	SH	1	3RT	\N	Treatment Machine Name 	t	f	f	\N	\N
(300a,00b3)	12298	179	0	0	0	0	CS	1	3RT	\N	Primary Dosimeter Unit	t	f	f	\N	\N
(300a,00b4)	12298	180	0	0	0	0	DS	1	3RT	\N	Source-Axis Distance	t	f	f	\N	\N
(300a,00b6)	12298	182	0	0	0	0	SQ	1	3RT	\N	Beam Limiting Device Sequence	t	f	f	\N	\N
(300a,00b8)	12298	184	0	0	0	0	CS	1	3RT	\N	RT Beam Limiting Device Type	t	f	f	\N	\N
(300a,00ba)	12298	186	0	0	0	0	DS	1	3RT	\N	Source to Beam Limiting Device Distance	t	f	f	\N	\N
(300a,00bc)	12298	188	0	0	0	0	IS	1	3RT	\N	Number of Leaf/Jaw Pairs	t	f	f	\N	\N
(300a,00be)	12298	190	0	0	0	0	DS	3-n	3RT	\N	Leaf Position Boundaries	t	f	f	\N	\N
(300a,00c0)	12298	192	0	0	0	0	IS	1	3RT	\N	Beam Number	t	f	f	\N	\N
(300a,00c2)	12298	194	0	0	0	0	LO	1	3RT	\N	Beam Name	t	f	f	\N	\N
(300a,00c3)	12298	195	0	0	0	0	ST	1	3RT	\N	Beam Description	t	f	f	\N	\N
(300a,00c4)	12298	196	0	0	0	0	CS	1	3RT	\N	Beam Type	t	f	f	\N	\N
(300a,00c6)	12298	198	0	0	0	0	CS	1	3RT	\N	Radiation Type	t	f	f	\N	\N
(300a,00c7)	12298	199	0	0	0	0	CS	1	3RT	\N	High-Dose Technique Type	t	f	f	\N	\N
(300a,00ca)	12298	202	0	0	0	0	SQ	1	3RT	\N	Planned Verification Image Sequence	t	f	f	\N	\N
(300a,00cc)	12298	204	0	0	0	0	LO	1-n	3RT	\N	Imaging Device Specific Acquisition Parameters	t	f	f	\N	\N
(300a,00ce)	12298	206	0	0	0	0	CS	1	3RT	\N	Treatment Delivery Type	t	f	f	\N	\N
(300a,00d0)	12298	208	0	0	0	0	IS	1	3RT	\N	Number of Wedges	t	f	f	\N	\N
(300a,00d1)	12298	209	0	0	0	0	SQ	1	3RT	\N	Wedge Sequence	t	f	f	\N	\N
(300a,00d2)	12298	210	0	0	0	0	IS	1	3RT	\N	Wedge Number	t	f	f	\N	\N
(300a,00d3)	12298	211	0	0	0	0	CS	1	3RT	\N	Wedge Type	t	f	f	\N	\N
(300a,00d4)	12298	212	0	0	0	0	SH	1	3RT	\N	Wedge ID	t	f	f	\N	\N
(300a,00d5)	12298	213	0	0	0	0	IS	1	3RT	\N	Wedge Angle	t	f	f	\N	\N
(300a,00d6)	12298	214	0	0	0	0	DS	1	3RT	\N	Wedge Factor	t	f	f	\N	\N
(300a,00d8)	12298	216	0	0	0	0	DS	1	3RT	\N	Wedge Orientation	t	f	f	\N	\N
(300a,00da)	12298	218	0	0	0	0	DS	1	3RT	\N	Source to Wedge Tray Distance	t	f	f	\N	\N
(300a,00e0)	12298	224	0	0	0	0	IS	1	3RT	\N	Number of Compensators	t	f	f	\N	\N
(300a,00e1)	12298	225	0	0	0	0	SH	1	3RT	\N	Material ID	t	f	f	\N	\N
(300a,00e2)	12298	226	0	0	0	0	DS	1	3RT	\N	Total Compensator Tray Factor	t	f	f	\N	\N
(300a,00e3)	12298	227	0	0	0	0	SQ	1	3RT	\N	Compensator Sequence	t	f	f	\N	\N
(300a,00e4)	12298	228	0	0	0	0	IS	1	3RT	\N	Compensator Number	t	f	f	\N	\N
(300a,00e5)	12298	229	0	0	0	0	SH	1	3RT	\N	Compensator ID	t	f	f	\N	\N
(300a,00e6)	12298	230	0	0	0	0	DS	1	3RT	\N	Source to Compensator Tray Distance	t	f	f	\N	\N
(300a,00e7)	12298	231	0	0	0	0	IS	1	3RT	\N	Compensator Rows	t	f	f	\N	\N
(300a,00e8)	12298	232	0	0	0	0	IS	1	3RT	\N	Compensator Columns	t	f	f	\N	\N
(300a,00e9)	12298	233	0	0	0	0	DS	2	3RT	\N	Compensator Pixel Spacing	t	f	f	\N	\N
(300a,00ea)	12298	234	0	0	0	0	DS	2	3RT	\N	Compensator Position	t	f	f	\N	\N
(300a,00eb)	12298	235	0	0	0	0	DS	1-n	3RT	\N	Compensator Transmission Data	t	f	f	\N	\N
(300a,00ec)	12298	236	0	0	0	0	DS	1-n	3RT	\N	Compensator Thickness Data	t	f	f	\N	\N
(300a,00ed)	12298	237	0	0	0	0	IS	1	3RT	\N	Number of Boli	t	f	f	\N	\N
(300a,00ee)	12298	238	0	0	0	0	CS	1	3CP	\N	CompensatorType	t	f	f	\N	\N
(300a,00f0)	12298	240	0	0	0	0	IS	1	3RT	\N	Number of Blocks	t	f	f	\N	\N
(300a,00f2)	12298	242	0	0	0	0	DS	1	3RT	\N	Total Block Tray Factor	t	f	f	\N	\N
(300a,00f4)	12298	244	0	0	0	0	SQ	1	3RT	\N	Block Sequence	t	f	f	\N	\N
(300a,00f5)	12298	245	0	0	0	0	SH	1	3RT	\N	Block Tray ID	t	f	f	\N	\N
(300a,00f6)	12298	246	0	0	0	0	DS	1	3RT	\N	Source to Block Tray Distance	t	f	f	\N	\N
(300a,00f8)	12298	248	0	0	0	0	CS	1	3RT	\N	Block Type	t	f	f	\N	\N
(300a,00fa)	12298	250	0	0	0	0	CS	1	3RT	\N	Block Divergence	t	f	f	\N	\N
(300a,00fc)	12298	252	0	0	0	0	IS	1	3RT	\N	Block Number	t	f	f	\N	\N
(300a,00fe)	12298	254	0	0	0	0	LO	1	3RT	\N	Block Name	t	f	f	\N	\N
(300a,0100)	12298	256	0	0	0	0	DS	1	3RT	\N	Block Thickness	t	f	f	\N	\N
(300a,0102)	12298	258	0	0	0	0	DS	1	3RT	\N	Block Transmission	t	f	f	\N	\N
(300a,0104)	12298	260	0	0	0	0	IS	1	3RT	\N	Block Number of Points	t	f	f	\N	\N
(300a,0106)	12298	262	0	0	0	0	DS	2-n	3RT	\N	Block Data	t	f	f	\N	\N
(300a,0107)	12298	263	0	0	0	0	SQ	1	3RT	\N	Applicator Sequence	t	f	f	\N	\N
(300a,0108)	12298	264	0	0	0	0	SH	1	3RT	\N	Applicator ID	t	f	f	\N	\N
(300a,0109)	12298	265	0	0	0	0	CS	1	3RT	\N	Applicator Type	t	f	f	\N	\N
(300a,010a)	12298	266	0	0	0	0	LO	1	3RT	\N	Applicator Description	t	f	f	\N	\N
(300a,010c)	12298	268	0	0	0	0	DS	1	3RT	\N	Cumulative Dose Reference Coefficient	t	f	f	\N	\N
(300a,010e)	12298	270	0	0	0	0	DS	1	3RT	\N	Final Cumulative Meterset Weight	t	f	f	\N	\N
(300a,0110)	12298	272	0	0	0	0	IS	1	3RT	\N	Number of Control Points	t	f	f	\N	\N
(300a,0111)	12298	273	0	0	0	0	SQ	1	3RT	\N	Control Point Sequence	t	f	f	\N	\N
(300a,0112)	12298	274	0	0	0	0	IS	1	3RT	\N	Control Point Index	t	f	f	\N	\N
(300a,0114)	12298	276	0	0	0	0	DS	1	3RT	\N	Nominal Beam Energy	t	f	f	\N	\N
(300a,0115)	12298	277	0	0	0	0	DS	1	3RT	\N	Dose Rate Set	t	f	f	\N	\N
(300a,0116)	12298	278	0	0	0	0	SQ	1	3RT	\N	Wedge Position Sequence	t	f	f	\N	\N
(300a,0118)	12298	280	0	0	0	0	CS	1	3RT	\N	Wedge Position	t	f	f	\N	\N
(300a,011a)	12298	282	0	0	0	0	SQ	1	3RT	\N	Beam Limiting Device Position Sequence	t	f	f	\N	\N
(300a,011c)	12298	284	0	0	0	0	DS	2-n	3RT	\N	Leaf Jaw Positions	t	f	f	\N	\N
(300a,011e)	12298	286	0	0	0	0	DS	1	3RT	\N	Gantry Angle	t	f	f	\N	\N
(300a,011f)	12298	287	0	0	0	0	CS	1	3RT	\N	Gantry Rotation Direction	t	f	f	\N	\N
(300a,0120)	12298	288	0	0	0	0	DS	1	3RT	\N	Beam Limiting Device Angle	t	f	f	\N	\N
(300a,0121)	12298	289	0	0	0	0	CS	1	3RT	\N	Beam Limiting Device Rotation Direction	t	f	f	\N	\N
(300a,0122)	12298	290	0	0	0	0	DS	1	3RT	\N	Patient Support Angle	t	f	f	\N	\N
(300a,0123)	12298	291	0	0	0	0	CS	1	3RT	\N	Patient Support Rotation Direction	t	f	f	\N	\N
(300a,0124)	12298	292	0	0	0	0	DS	1	3RT	\N	Table Top Eccentric Axis Distance	t	f	f	\N	\N
(300a,0125)	12298	293	0	0	0	0	DS	1	3RT	\N	Table Top Eccentric Angle	t	f	f	\N	\N
(300a,0126)	12298	294	0	0	0	0	CS	1	3RT	\N	Table Top Eccentric Rotation Direction	t	f	f	\N	\N
(300a,0128)	12298	296	0	0	0	0	DS	1	3RT	\N	Table Top Vertical Position	t	f	f	\N	\N
(300a,0129)	12298	297	0	0	0	0	DS	1	3RT	\N	Table Top Longitudinal Position	t	f	f	\N	\N
(300a,012a)	12298	298	0	0	0	0	DS	1	3RT	\N	Table Top Lateral Position	t	f	f	\N	\N
(300a,012c)	12298	300	0	0	0	0	DS	3	3RT	\N	Isocenter Position	t	f	f	\N	\N
(300a,012e)	12298	302	0	0	0	0	DS	3	3RT	\N	Surface Entry Point	t	f	f	\N	\N
(300a,0130)	12298	304	0	0	0	0	DS	1	3RT	\N	Source to Surface Distance	t	f	f	\N	\N
(300a,0134)	12298	308	0	0	0	0	DS	1	3RT	\N	Cumulative Meterset Weight	t	f	f	\N	\N
(300a,0180)	12298	384	0	0	0	0	SQ	1	3RT	\N	Patient Setup Sequence	t	f	f	\N	\N
(300a,0182)	12298	386	0	0	0	0	IS	1	3RT	\N	Patient Setup Number	t	f	f	\N	\N
(300a,0184)	12298	388	0	0	0	0	LO	1	3RT	\N	Patient Additional Position	t	f	f	\N	\N
(300a,0190)	12298	400	0	0	0	0	SQ	1	3RT	\N	Fixation Device Sequence	t	f	f	\N	\N
(300a,0192)	12298	402	0	0	0	0	CS	1	3RT	\N	Fixation Device Type	t	f	f	\N	\N
(300a,0194)	12298	404	0	0	0	0	SH	1	3RT	\N	Fixation Device Label	t	f	f	\N	\N
(300a,0196)	12298	406	0	0	0	0	ST	1	3RT	\N	Fixation Device Description	t	f	f	\N	\N
(300a,0198)	12298	408	0	0	0	0	SH	1	3RT	\N	Fixation Device Position	t	f	f	\N	\N
(300a,01a0)	12298	416	0	0	0	0	SQ	1	3RT	\N	Shielding Device Sequence	t	f	f	\N	\N
(300a,01a2)	12298	418	0	0	0	0	CS	1	3RT	\N	Shielding Device Type	t	f	f	\N	\N
(300a,01a4)	12298	420	0	0	0	0	SH	1	3RT	\N	Shielding Device Label	t	f	f	\N	\N
(300a,01a6)	12298	422	0	0	0	0	ST	1	3RT	\N	Shielding Device Description	t	f	f	\N	\N
(300a,01a8)	12298	424	0	0	0	0	SH	1	3RT	\N	Shielding Device Position	t	f	f	\N	\N
(300a,01b0)	12298	432	0	0	0	0	CS	1	3RT	\N	Setup Technique	t	f	f	\N	\N
(300a,01b2)	12298	434	0	0	0	0	ST	1	3RT	\N	Setup TechniqueDescription	t	f	f	\N	\N
(300a,01b4)	12298	436	0	0	0	0	SQ	1	3RT	\N	Setup Device Sequence	t	f	f	\N	\N
(300a,01b6)	12298	438	0	0	0	0	CS	1	3RT	\N	Setup Device Type	t	f	f	\N	\N
(300a,01b8)	12298	440	0	0	0	0	SH	1	3RT	\N	Setup Device Label	t	f	f	\N	\N
(300a,01ba)	12298	442	0	0	0	0	ST	1	3RT	\N	Setup Device Description	t	f	f	\N	\N
(300a,01bc)	12298	444	0	0	0	0	DS	1	3RT	\N	Setup Device Parameter	t	f	f	\N	\N
(300a,01d0)	12298	464	0	0	0	0	ST	1	3RT	\N	Setup ReferenceDescription	t	f	f	\N	\N
(300a,01d2)	12298	466	0	0	0	0	DS	1	3RT	\N	Table Top Vertical Setup Displacement	t	f	f	\N	\N
(300a,01d4)	12298	468	0	0	0	0	DS	1	3RT	\N	Table Top Longitudinal Setup Displacement	t	f	f	\N	\N
(300a,01d6)	12298	470	0	0	0	0	DS	1	3RT	\N	Table Top Lateral Setup Displacement	t	f	f	\N	\N
(300a,0200)	12298	512	0	0	0	0	CS	1	3RT	\N	Brachy Treatment Technique	t	f	f	\N	\N
(300a,0202)	12298	514	0	0	0	0	CS	1	3RT	\N	Brachy Treatment Type	t	f	f	\N	\N
(300a,0206)	12298	518	0	0	0	0	SQ	1	3RT	\N	Treatment Machine Sequence	t	f	f	\N	\N
(300a,0210)	12298	528	0	0	0	0	SQ	1	3RT	\N	Source Sequence	t	f	f	\N	\N
(300a,0212)	12298	530	0	0	0	0	IS	1	3RT	\N	Source Number	t	f	f	\N	\N
(300a,0214)	12298	532	0	0	0	0	CS	1	3RT	\N	Source Type	t	f	f	\N	\N
(300a,0216)	12298	534	0	0	0	0	LO	1	3RT	\N	Source Manufacturer	t	f	f	\N	\N
(300a,0218)	12298	536	0	0	0	0	DS	1	3RT	\N	Active Source Diameter	t	f	f	\N	\N
(300a,021a)	12298	538	0	0	0	0	DS	1	3RT	\N	Active Source Length	t	f	f	\N	\N
(300a,0222)	12298	546	0	0	0	0	DS	1	3RT	\N	Source Encapsulation Nominal Thickness	t	f	f	\N	\N
(300a,0224)	12298	548	0	0	0	0	DS	1	3RT	\N	Source Encapsulation Nominal Transmission	t	f	f	\N	\N
(300a,0226)	12298	550	0	0	0	0	LO	1	3RT	\N	Source IsotopeName	t	f	f	\N	\N
(300a,0228)	12298	552	0	0	0	0	DS	1	3RT	\N	Source Isotope Half Life	t	f	f	\N	\N
(300a,022a)	12298	554	0	0	0	0	DS	1	3RT	\N	Reference Air Kerma Rate	t	f	f	\N	\N
(300a,022c)	12298	556	0	0	0	0	DA	1	3RT	\N	Air Kerma Rate Reference Date	t	f	f	\N	\N
(300a,022e)	12298	558	0	0	0	0	TM	1	3RT	\N	Air Kerma Rate Reference Time	t	f	f	\N	\N
(300a,0230)	12298	560	0	0	0	0	SQ	1	3RT	\N	Application Setup Sequence	t	f	f	\N	\N
(300a,0232)	12298	562	0	0	0	0	CS	1	3RT	\N	Application Setup Type	t	f	f	\N	\N
(300a,0234)	12298	564	0	0	0	0	IS	1	3RT	\N	Application Setup Number	t	f	f	\N	\N
(300a,0236)	12298	566	0	0	0	0	LO	1	3RT	\N	Application Setup Name	t	f	f	\N	\N
(300a,0238)	12298	568	0	0	0	0	LO	1	3RT	\N	Application Setup Manufacturer	t	f	f	\N	\N
(300a,0240)	12298	576	0	0	0	0	IS	1	3RT	\N	Template Number	t	f	f	\N	\N
(300a,0242)	12298	578	0	0	0	0	SH	1	3RT	\N	Template Type	t	f	f	\N	\N
(300a,0244)	12298	580	0	0	0	0	LO	1	3RT	\N	Template Name	t	f	f	\N	\N
(300a,0250)	12298	592	0	0	0	0	DS	1	3RT	\N	Total Reference Air Kerma	t	f	f	\N	\N
(300a,0260)	12298	608	0	0	0	0	SQ	1	3RT	\N	Brachy Accessory Device Sequence	t	f	f	\N	\N
(300a,0262)	12298	610	0	0	0	0	IS	1	3RT	\N	Brachy Accessory Device Number	t	f	f	\N	\N
(300a,0263)	12298	611	0	0	0	0	SH	1	3RT	\N	Brachy Accessory Device ID	t	f	f	\N	\N
(300a,0264)	12298	612	0	0	0	0	CS	1	3RT	\N	Brachy Accessory Device Type	t	f	f	\N	\N
(300a,0266)	12298	614	0	0	0	0	LO	1	3RT	\N	Brachy Accessory Device Name	t	f	f	\N	\N
(300a,026a)	12298	618	0	0	0	0	DS	1	3RT	\N	Brachy Accessory Device Nominal Thickness	t	f	f	\N	\N
(300a,026c)	12298	620	0	0	0	0	DS	1	3RT	\N	Brachy Accessory Device Nominal Transmission	t	f	f	\N	\N
(300a,0280)	12298	640	0	0	0	0	SQ	1	3RT	\N	Channel Sequence	t	f	f	\N	\N
(300a,0282)	12298	642	0	0	0	0	IS	1	3RT	\N	Channel Number	t	f	f	\N	\N
(300a,0284)	12298	644	0	0	0	0	DS	1	3RT	\N	Channel Length	t	f	f	\N	\N
(300a,0286)	12298	646	0	0	0	0	DS	1	3RT	\N	Channel Total Time	t	f	f	\N	\N
(300a,0288)	12298	648	0	0	0	0	CS	1	3RT	\N	Source Movement Type	t	f	f	\N	\N
(300a,028a)	12298	650	0	0	0	0	IS	1	3RT	\N	Number of Pulses	t	f	f	\N	\N
(300a,028c)	12298	652	0	0	0	0	DS	1	3RT	\N	Pulse Repetition Interval	t	f	f	\N	\N
(300a,0290)	12298	656	0	0	0	0	IS	1	3RT	\N	Source Applicator Number	t	f	f	\N	\N
(300a,0291)	12298	657	0	0	0	0	SH	1	3RT	\N	Source Applicator ID	t	f	f	\N	\N
(300a,0292)	12298	658	0	0	0	0	CS	1	3RT	\N	Source Applicator Type	t	f	f	\N	\N
(300a,0294)	12298	660	0	0	0	0	LO	1	3RT	\N	Source Applicator Name	t	f	f	\N	\N
(300a,0296)	12298	662	0	0	0	0	DS	1	3RT	\N	Source Applicator Length	t	f	f	\N	\N
(300a,0298)	12298	664	0	0	0	0	LO	1	3RT	\N	Source Applicator Manufacturer	t	f	f	\N	\N
(300a,029c)	12298	668	0	0	0	0	DS	1	3RT	\N	Source Applicator Wall Nominal Thickness	t	f	f	\N	\N
(300a,029e)	12298	670	0	0	0	0	DS	1	3RT	\N	Source Applicator Wall Nominal Transmission	t	f	f	\N	\N
(300a,02a0)	12298	672	0	0	0	0	DS	1	3RT	\N	Source Applicator Step Size	t	f	f	\N	\N
(300a,02a2)	12298	674	0	0	0	0	IS	1	3RT	\N	Transfer Tube Number	t	f	f	\N	\N
(300a,02a4)	12298	676	0	0	0	0	DS	1	3RT	\N	Transfer Tube Length	t	f	f	\N	\N
(300a,02b0)	12298	688	0	0	0	0	SQ	1	3RT	\N	Channel Shield Sequence	t	f	f	\N	\N
(300a,02b2)	12298	690	0	0	0	0	IS	1	3RT	\N	Channel Shield Number	t	f	f	\N	\N
(300a,02b3)	12298	691	0	0	0	0	SH	1	3RT	\N	Channel Shield ID	t	f	f	\N	\N
(300a,02b4)	12298	692	0	0	0	0	LO	1	3RT	\N	Channel Shield Name	t	f	f	\N	\N
(300a,02b8)	12298	696	0	0	0	0	DS	1	3RT	\N	Channel Shield Nominal Thickness	t	f	f	\N	\N
(300a,02ba)	12298	698	0	0	0	0	DS	1	3RT	\N	Channel Shield Nominal Transmission	t	f	f	\N	\N
(300a,02c8)	12298	712	0	0	0	0	DS	1	3RT	\N	Final Cumulative Time Weight	t	f	f	\N	\N
(300a,02d0)	12298	720	0	0	0	0	SQ	1	3RT	\N	Brachy Control Point Sequence	t	f	f	\N	\N
(300a,02d2)	12298	722	0	0	0	0	DS	1	3RT	\N	Control Point Relative Position	t	f	f	\N	\N
(300a,02d4)	12298	724	0	0	0	0	DS	3	3RT	\N	Control Point 3D Position	t	f	f	\N	\N
(300a,02d6)	12298	726	0	0	0	0	DS	1	3RT	\N	Cumulative Time Weight	t	f	f	\N	\N
(300c,0002)	12300	2	0	0	0	0	SQ	1	3RT	\N	Referenced RT Plan Sequence	t	f	f	\N	\N
(300c,0004)	12300	4	0	0	0	0	SQ	1	3RT	\N	Referenced Beam Sequence	t	f	f	\N	\N
(300c,0006)	12300	6	0	0	0	0	IS	1	3RT	\N	Referenced Beam Number	t	f	f	\N	\N
(300c,0007)	12300	7	0	0	0	0	IS	1	3RT	\N	Referenced Reference Image Number	t	f	f	\N	\N
(300c,0008)	12300	8	0	0	0	0	DS	1	3RT	\N	Start Cumulative Meterset Weight	t	f	f	\N	\N
(300c,0009)	12300	9	0	0	0	0	DS	1	3RT	\N	End Cumulative Meterset Weight	t	f	f	\N	\N
(300c,000a)	12300	10	0	0	0	0	SQ	1	3RT	\N	Referenced Brachy Application Setup Sequence	t	f	f	\N	\N
(300c,000c)	12300	12	0	0	0	0	IS	1	3RT	\N	Referenced Brachy Application Setup Number	t	f	f	\N	\N
(300c,000e)	12300	14	0	0	0	0	IS	1	3RT	\N	Referenced Source Number	t	f	f	\N	\N
(300c,0020)	12300	32	0	0	0	0	SQ	1	3RT	\N	Referenced Fraction Group Sequence	t	f	f	\N	\N
(300c,0022)	12300	34	0	0	0	0	IS	1	3RT	\N	Referenced Fraction Group Number	t	f	f	\N	\N
(300c,0040)	12300	64	0	0	0	0	SQ	1	3RT	\N	Referenced Verification Image Sequence	t	f	f	\N	\N
(300c,0042)	12300	66	0	0	0	0	SQ	1	3RT	\N	Referenced Reference Image Sequence	t	f	f	\N	\N
(300c,0050)	12300	80	0	0	0	0	SQ	1	3RT	\N	Referenced Dose Reference Sequence	t	f	f	\N	\N
(300c,0051)	12300	81	0	0	0	0	IS	1	3RT	\N	Referenced Dose Reference Number	t	f	f	\N	\N
(300c,0055)	12300	85	0	0	0	0	SQ	1	3RT	\N	Brachy Referenced Dose Reference Sequence	t	f	f	\N	\N
(300c,0060)	12300	96	0	0	0	0	SQ	1	3RT	\N	Referenced Structure Set Sequence	t	f	f	\N	\N
(300c,006a)	12300	106	0	0	0	0	IS	1	3RT	\N	Referenced Patient Setup Number	t	f	f	\N	\N
(300c,0080)	12300	128	0	0	0	0	SQ	1	3RT	\N	Referenced Dose Sequence	t	f	f	\N	\N
(300c,00a0)	12300	160	0	0	0	0	IS	1	3RT	\N	Referenced Tolerance Table Number	t	f	f	\N	\N
(300c,00b0)	12300	176	0	0	0	0	SQ	1	3RT	\N	Referenced Bolus Sequence	t	f	f	\N	\N
(300c,00c0)	12300	192	0	0	0	0	IS	1	3RT	\N	Referenced Wedge Number	t	f	f	\N	\N
(300c,00d0)	12300	208	0	0	0	0	IS	1	3RT	\N	Referenced Compensator Number	t	f	f	\N	\N
(300c,00e0)	12300	224	0	0	0	0	IS	1	3RT	\N	Referenced Block Number	t	f	f	\N	\N
(300c,00f0)	12300	240	0	0	0	0	IS	1	3RT	\N	Referenced Control Point Index	t	f	f	\N	\N
(300e,0002)	12302	2	0	0	0	0	CS	1	3RT	\N	Approval Status	t	f	f	\N	\N
(300e,0004)	12302	4	0	0	0	0	DA	1	3RT	\N	Review Date	t	f	f	\N	\N
(300e,0005)	12302	5	0	0	0	0	TM	1	3RT	\N	Review Time	t	f	f	\N	\N
(300e,0008)	12302	8	0	0	0	0	PN	1	3RT	\N	Reviewer Name	t	f	f	\N	\N
(4ffe,0001)	20478	1	0	0	0	0	SQ	1	3SIG	\N	MAC Parameters Sequence	t	f	f	\N	\N
(5200,9229)	20992	37417	0	0	0	0	SQ	1	3MR	\N	Shared Functional Groups Sequence	t	f	f	\N	\N
(5200,9230)	20992	37424	0	0	0	0	SQ	1	3MR	\N	Per-frame Functional Groups Sequence	t	f	f	\N	\N
(5400,0100)	21504	256	0	0	0	0	SQ	1	3WAV	\N	Waveform Sequence	t	f	f	\N	\N
(5400,1004)	21504	4100	0	0	0	0	US	1	3WAV	\N	Waveform Bits Allocated	t	f	f	\N	\N
(5400,1006)	21504	4102	0	0	0	0	CS	1	3WAV	\N	Waveform Sample Interpretation	t	f	f	\N	\N
(5600,0010)	22016	16	0	0	0	0	OF	1	3MR	\N	First Order Phase Correction Angle	t	f	f	\N	\N
(5600,0020)	22016	32	0	0	0	0	OF	1	3MR	\N	Spectroscopy Data	t	f	f	\N	\N
(60xx,0010)	24576	16	65280	0	0	0	US	1	3	\N	Overlay Rows	t	f	f	\N	\N
(60xx,0011)	24576	17	65280	0	0	0	US	1	3	\N	Overlay Columns	t	f	f	\N	\N
(60xx,0012)	24576	18	65280	0	0	0	US	1	3	\N	Overlay Planes	t	f	f	\N	\N
(60xx,0015)	24576	21	65280	0	0	0	IS	1	3	\N	Number of Frames in Overlay	t	f	f	\N	\N
(60xx,0022)	24576	34	65280	0	0	0	LO	1	3	\N	Overlay Description	t	f	f	\N	\N
(60xx,0040)	24576	64	65280	0	0	0	CS	1	3	\N	Overlay Type	t	f	f	\N	\N
(60xx,0050)	24576	80	65280	0	0	0	SS	2	3	\N	Overlay Origin	t	f	f	\N	\N
(60xx,0051)	24576	81	65280	0	0	0	US	1	3	\N	Image Frame Origin	t	f	f	\N	\N
(60xx,0052)	24576	82	65280	0	0	0	US	1	3	\N	Plane Origin	t	f	f	\N	\N
(60xx,0100)	24576	256	65280	0	0	0	US	1	3	\N	Overlay Bits Allocated	t	f	f	\N	\N
(60xx,0102)	24576	258	65280	0	0	0	US	1	3	\N	Overlay Bit Position	t	f	f	\N	\N
(60xx,1001)	24576	4097	65280	0	0	0	CS	1	3SCP	\N	Overlay Activation Layer	t	f	f	\N	\N
(60xx,1301)	24576	4865	65280	0	0	0	IS	1	3	\N	ROI Area	t	f	f	\N	\N
(60xx,1302)	24576	4866	65280	0	0	0	DS	1	3	\N	ROI Mean	t	f	f	\N	\N
(60xx,1303)	24576	4867	65280	0	0	0	DS	1	3	\N	ROI Standard Deviation	t	f	f	\N	\N
(60xx,1500)	24576	5376	65280	0	0	0	LO	1	3	\N	Overlay Label	t	f	f	\N	\N
(60xx,3000)	24576	12288	65280	0	0	0	OW	1	3	\N	Overlay Data	t	f	f	\N	\N
(fffa,fffa)	65530	65530	0	0	0	0	SQ	1	3SIG	\N	Digital Signatures Sequence	t	f	f	\N	\N
(fffc,fffc)	65532	65532	0	0	0	0	OB	1	3	\N	Data Set Trailing Padding	t	f	f	\N	\N
(0008,0008)	8	8	0	0	0	0	CS	1-n	3	\N	Image Type	t	f	f	\N	\N
(0028,0106)	40	262	0	0	0	0	OT	1	3	\N	Smallest Image Pixel Value	t	f	f	\N	\N
(0028,0107)	40	263	0	0	0	0	OT	1	3	\N	Largest Image Pixel Value	t	f	f	\N	\N
(0028,0108)	40	264	0	0	0	0	OT	1	3	\N	Smallest Pixel Value in Series	t	f	f	\N	\N
(0028,0109)	40	265	0	0	0	0	OT	1	3	\N	Largest Pixel Value in Series	t	f	f	\N	\N
(0028,0110)	40	272	0	0	0	0	OT	1	3	\N	Smallest Pixel Value in Plane	t	f	f	\N	\N
(0028,0111)	40	273	0	0	0	0	OT	1	3	\N	Largest Pixel Value in Plane	t	f	f	\N	\N
(0028,0120)	40	288	0	0	0	0	OT	1	3	\N	Pixel Padding Value	t	f	f	\N	\N
(0040,9211)	64	37393	0	0	0	0	OT	1	3MR	\N	Real World Last Value Mapped	t	f	f	\N	\N
(0040,9216)	64	37398	0	0	0	0	OT	1	3MR	\N	Real World First Value Mapped	t	f	f	\N	\N
(0060,3004)	96	12292	0	0	0	0	OT	1	3DX	\N	Histogram First Bin Value	t	f	f	\N	\N
(0060,3006)	96	12294	0	0	0	0	OT	1	3DX	\N	Histogram Last Bin Value	t	f	f	\N	\N
(5400,0110)	21504	272	0	0	0	0	OT	1	3WAV	\N	Channel Minimum Value	t	f	f	\N	\N
(5400,0112)	21504	274	0	0	0	0	OT	1	3WAV	\N	Channel Maximum Value	t	f	f	\N	\N
(5400,100a)	21504	4106	0	0	0	0	OT	1	3WAV	\N	Waveform Padding Value	t	f	f	\N	\N
(5400,1010)	21504	4112	0	0	0	0	OT	1	3WAV	\N	Waveform Data	t	f	f	\N	\N
(7fe0,0010)	32736	16	0	0	0	0	OT	1	3	\N	Pixel Data	t	f	f	\N	\N
(0028,1101)	40	4353	0	0	0	0	OT	3	3	\N	Red Palette Color Lookup Table Descriptor	t	f	f	\N	\N
(0028,1102)	40	4354	0	0	0	0	OT	3	3	\N	Green Palette Color Lookup Table Descriptor	t	f	f	\N	\N
(0028,1103)	40	4355	0	0	0	0	OT	3	3	\N	Blue Palette Color Lookup Table Descriptor	t	f	f	\N	\N
(0008,001a)	8	26	0	0	0	0	UI	1-n	3-2006	\N	Related General SOP Class UID	t	\N	f	\N	\N
(0008,001b)	8	27	0	0	0	0	UI	1	3-2006	\N	Original Specialized SOP Class UID	t	\N	f	\N	\N
(0008,0062)	8	98	0	0	0	0	UI	1-n	3-2006	\N	SOP Classes in Study	t	\N	f	\N	\N
(0008,0096)	8	150	0	0	0	0	SQ	1	3-2006	\N	Referring Physician Identification Sequence	t	\N	f	\N	\N
(0008,0110)	8	272	0	0	0	0	SQ	1	3-2006	\N	Coding Scheme Identification Sequence	t	\N	f	\N	\N
(0008,0112)	8	274	0	0	0	0	LO	1	3-2006	\N	Coding Scheme Registry	t	\N	f	\N	\N
(0008,0114)	8	276	0	0	0	0	ST	1	3-2006	\N	Coding Scheme External ID	t	\N	f	\N	\N
(0008,0115)	8	277	0	0	0	0	ST	1	3-2006	\N	Coding Scheme Name	t	\N	f	\N	\N
(0008,0116)	8	278	0	0	0	0	ST	1	3-2006	\N	Responsible Organization	t	\N	f	\N	\N
(0008,1049)	8	4169	0	0	0	0	SQ	1	3-2006	\N	Physician(s) of Record Identification Sequence	t	\N	f	\N	\N
(0008,1052)	8	4178	0	0	0	0	SQ	1	3-2006	\N	Performing Physician Identification Sequence	t	\N	f	\N	\N
(0008,1062)	8	4194	0	0	0	0	SQ	1	3-2006	\N	Physician(s) Reading Study Identification Sequence	t	\N	f	\N	\N
(0008,1072)	8	4210	0	0	0	0	SQ	1	3-2006	\N	Operator Identification Sequence	t	\N	f	\N	\N
(0008,114b)	8	4427	0	0	0	0	SQ	1	3-2006	\N	Referenced Real World Value Mapping Instance Sequence	t	\N	f	\N	\N
(0008,1200)	8	4608	0	0	0	0	SQ	1	3-2006	\N	Studies Containing Other Referenced Instances Sequence	t	\N	f	\N	\N
(0008,1250)	8	4688	0	0	0	0	SQ	1	3-2006	\N	Related Series Sequence	t	\N	f	\N	\N
(0008,3001)	8	12289	0	0	0	0	SQ	1	3-2006	\N	Alternate Representation Sequence	t	\N	f	\N	\N
(0008,3010)	8	12304	0	0	0	0	UI	1	3-2006	\N	Irradiation Event UID	t	\N	f	\N	\N
(0008,9410)	8	37904	0	0	0	0	SQ	1	3-2006	\N	Referenced Other Plane Sequence	t	\N	f	\N	\N
(0008,9458)	8	37976	0	0	0	0	SQ	1	3-2006	\N	Frame Display Sequence	t	\N	f	\N	\N
(0008,9459)	8	37977	0	0	0	0	FL	1	3-2006	\N	Recommended Display Frame Rate in Float	t	\N	f	\N	\N
(0008,9460)	8	37984	0	0	0	0	CS	1	3-2006	\N	Skip Frame Range Flag	t	\N	f	\N	\N
(0010,9431)	16	37937	0	0	0	0	FL	1	3-2006	\N	Examined Body Thickness	t	\N	f	\N	\N
(0012,0010)	18	16	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Sponsor Name	t	\N	f	\N	\N
(0012,0020)	18	32	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Protocol ID	t	\N	f	\N	\N
(0012,0021)	18	33	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Protocol Name	t	\N	f	\N	\N
(0012,0030)	18	48	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Site ID	t	\N	f	\N	\N
(0012,0031)	18	49	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Site Name	t	\N	f	\N	\N
(0012,0040)	18	64	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Subject ID	t	\N	f	\N	\N
(0012,0042)	18	66	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Subject Reading ID	t	\N	f	\N	\N
(0012,0050)	18	80	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Time Point ID	t	\N	f	\N	\N
(0012,0051)	18	81	0	0	0	0	ST	1	3-2006	\N	Clinical Trial Time Point Description	t	\N	f	\N	\N
(0012,0060)	18	96	0	0	0	0	LO	1	3-2006	\N	Clinical Trial Coordinating Center Name	t	\N	f	\N	\N
(0012,0062)	18	98	0	0	0	0	CS	1	3-2006	\N	Patient Identify Removed	t	\N	f	\N	\N
(0012,0063)	18	99	0	0	0	0	LO	1-n	3-2006	\N	De-identification Method	t	\N	f	\N	\N
(0012,0064)	18	100	0	0	0	0	SQ	1	3-2006	\N	De-identification Method Code Sequence	t	\N	f	\N	\N
(0018,003a)	24	58	0	0	0	0	ST	1	3-2006	\N	Intervention Description	t	\N	f	\N	\N
(0018,1002)	24	4098	0	0	0	0	UI	1	3-2006	\N	Device UID	t	\N	f	\N	\N
(0018,1078)	24	4216	0	0	0	0	DT	1	3-2006	\N	Radiopharmaceutical Start Datetime	t	\N	f	\N	\N
(0018,1079)	24	4217	0	0	0	0	DT	1	3-2006	\N	Radiopharmaceutical Stop Datetime	t	\N	f	\N	\N
(0018,1624)	24	5668	0	0	0	0	US	3	3-2006	\N	Shutter Presentation Color CIELab Value	t	\N	f	\N	\N
(0018,1803)	24	6147	0	0	0	0	LO	1	3-2006	\N	NTP Source Address	t	\N	f	\N	\N
(0018,6039)	24	24633	0	0	0	0	SL	1	3-2006	\N	Doppler Sample Volume X Position	t	\N	f	\N	\N
(0018,603b)	24	24635	0	0	0	0	SL	1	3-2006	\N	Doppler Sample Volume Y Position	t	\N	f	\N	\N
(0018,603d)	24	24637	0	0	0	0	SL	1	3-2006	\N	TM-Line Position X0	t	\N	f	\N	\N
(0018,603f)	24	24639	0	0	0	0	SL	1	3-2006	\N	TM-Line Position Y0	t	\N	f	\N	\N
(0018,6041)	24	24641	0	0	0	0	SL	1	3-2006	\N	TM-Line Position X1	t	\N	f	\N	\N
(0018,6043)	24	24643	0	0	0	0	SL	1	3-2006	\N	TM-Line Position Y1	t	\N	f	\N	\N
(0018,6060)	24	24672	0	0	0	0	FL	1-n	3-2006	\N	R Wave Time Vector	t	\N	f	\N	\N
(0018,702a)	24	28714	0	0	0	0	LO	1	3-2006	\N	Detector Manufacturer Name	t	\N	f	\N	\N
(0018,702b)	24	28715	0	0	0	0	LO	1	3-2006	\N	Detector Manufacturer's Model Name	t	\N	f	\N	\N
(0018,9069)	24	36969	0	0	0	0	FD	1	3-2006	\N	Parallel Reduction Factor In-plane	t	\N	f	\N	\N
(0018,9083)	24	36995	0	0	0	0	SQ	1	3-2006	\N	Metabolite Map Code Sequence	t	\N	f	\N	\N
(0018,9295)	24	37525	0	0	0	0	FD	1	3-2006	\N	Chemical Shifts Minimum Integration Limit in ppm	t	\N	f	\N	\N
(0018,9296)	24	37526	0	0	0	0	FD	1	3-2006	\N	Chemical Shifts Maximum Integration Limit in ppm	t	\N	f	\N	\N
(0018,9240)	24	37440	0	0	0	0	US	1	3-2006	\N	RF Echo Train Length	t	\N	f	\N	\N
(0018,9241)	24	37441	0	0	0	0	US	1	3-2006	\N	Gradient Echo Train Length	t	\N	f	\N	\N
(0018,9301)	24	37633	0	0	0	0	SQ	1	3-2006	\N	CT Acquisition Type Sequence	t	\N	f	\N	\N
(0018,9302)	24	37634	0	0	0	0	CS	1	3-2006	\N	Acquisition Type	t	\N	f	\N	\N
(0018,9303)	24	37635	0	0	0	0	FD	1	3-2006	\N	Tube Angle	t	\N	f	\N	\N
(0018,9304)	24	37636	0	0	0	0	SQ	1	3-2006	\N	CT Acquisition Details Sequence	t	\N	f	\N	\N
(0018,9305)	24	37637	0	0	0	0	FD	1	3-2006	\N	Revolution Time	t	\N	f	\N	\N
(0018,9306)	24	37638	0	0	0	0	FD	1	3-2006	\N	Single Collimation Width	t	\N	f	\N	\N
(0018,9307)	24	37639	0	0	0	0	FD	1	3-2006	\N	Total Collimation Width	t	\N	f	\N	\N
(0018,9308)	24	37640	0	0	0	0	SQ	1	3-2006	\N	CT Table Dynamics Sequence	t	\N	f	\N	\N
(0018,9309)	24	37641	0	0	0	0	FD	1	3-2006	\N	Table Speed	t	\N	f	\N	\N
(0018,9310)	24	37648	0	0	0	0	FD	1	3-2006	\N	Table Feed per Rotation	t	\N	f	\N	\N
(0018,9311)	24	37649	0	0	0	0	FD	1	3-2006	\N	Spiral Pitch Factor	t	\N	f	\N	\N
(0018,9312)	24	37650	0	0	0	0	SQ	1	3-2006	\N	CT Geometry Sequence	t	\N	f	\N	\N
(0018,9313)	24	37651	0	0	0	0	FD	3	3-2006	\N	Data Collection Center (Patient)	t	\N	f	\N	\N
(0018,9314)	24	37652	0	0	0	0	SQ	1	3-2006	\N	CT Reconstruction Sequence	t	\N	f	\N	\N
(0018,9315)	24	37653	0	0	0	0	CS	1	3-2006	\N	Reconstruction Algorithm	t	\N	f	\N	\N
(0018,9316)	24	37654	0	0	0	0	CS	1	3-2006	\N	Convolution Kernel Group	t	\N	f	\N	\N
(0018,9317)	24	37655	0	0	0	0	FD	2	3-2006	\N	Reconstruction Field of View	t	\N	f	\N	\N
(0018,9318)	24	37656	0	0	0	0	FD	3	3-2006	\N	Reconstruction Target Center (Patient)	t	\N	f	\N	\N
(0018,9319)	24	37657	0	0	0	0	FD	1	3-2006	\N	Reconstruction Angle	t	\N	f	\N	\N
(0018,9320)	24	37664	0	0	0	0	SH	1	3-2006	\N	Image Filter	t	\N	f	\N	\N
(0018,9321)	24	37665	0	0	0	0	SQ	1	3-2006	\N	CT Exposure Sequence	t	\N	f	\N	\N
(0018,9322)	24	37666	0	0	0	0	FD	2	3-2006	\N	Reconstruction Pixel Spacing 	t	\N	f	\N	\N
(0018,9323)	24	37667	0	0	0	0	CS	1	3-2006	\N	Exposure Modulation Type	t	\N	f	\N	\N
(0018,9324)	24	37668	0	0	0	0	FD	1	3-2006	\N	Estimated Dose Saving	t	\N	f	\N	\N
(0018,9325)	24	37669	0	0	0	0	SQ	1	3-2006	\N	CT X-ray Details Sequence	t	\N	f	\N	\N
(0018,9326)	24	37670	0	0	0	0	SQ	1	3-2006	\N	CT Position Sequence	t	\N	f	\N	\N
(0018,9327)	24	37671	0	0	0	0	FD	1	3-2006	\N	Table Position	t	\N	f	\N	\N
(0018,9328)	24	37672	0	0	0	0	FD	1	3-2006	\N	Exposure Time in ms	t	\N	f	\N	\N
(0018,9329)	24	37673	0	0	0	0	SQ	1	3-2006	\N	CT Image Frame Type Sequence	t	\N	f	\N	\N
(0018,9330)	24	37680	0	0	0	0	FD	1	3-2006	\N	X-Ray Tube Current in mA	t	\N	f	\N	\N
(0018,9332)	24	37682	0	0	0	0	FD	1	3-2006	\N	Exposure in mAs	t	\N	f	\N	\N
(0018,9333)	24	37683	0	0	0	0	CS	1	3-2006	\N	Constant Volume Flag 	t	\N	f	\N	\N
(0018,9334)	24	37684	0	0	0	0	CS	1	3-2006	\N	Fluoroscopy Flag	t	\N	f	\N	\N
(0018,9335)	24	37685	0	0	0	0	FD	1	3-2006	\N	Distance Source to Data Collection Center	t	\N	f	\N	\N
(0018,9337)	24	37687	0	0	0	0	US	1	3-2006	\N	Contrast/Bolus Agent Number	t	\N	f	\N	\N
(0018,9338)	24	37688	0	0	0	0	SQ	1	3-2006	\N	Contrast/Bolus Ingredient Code Sequence	t	\N	f	\N	\N
(0018,9340)	24	37696	0	0	0	0	SQ	1	3-2006	\N	Contrast Administration Profile Sequence	t	\N	f	\N	\N
(0018,9341)	24	37697	0	0	0	0	SQ	1	3-2006	\N	Contrast/Bolus Usage Sequence	t	\N	f	\N	\N
(0018,9342)	24	37698	0	0	0	0	CS	1	3-2006	\N	Contrast/Bolus Agent Administered	t	\N	f	\N	\N
(0018,9343)	24	37699	0	0	0	0	CS	1	3-2006	\N	Contrast/Bolus Agent Detected	t	\N	f	\N	\N
(0018,9344)	24	37700	0	0	0	0	CS	1	3-2006	\N	Contrast/Bolus Agent Phase	t	\N	f	\N	\N
(0018,9345)	24	37701	0	0	0	0	FD	1	3-2006	\N	CTDIvol	t	\N	f	\N	\N
(0018,9401)	24	37889	0	0	0	0	SQ	1	3-2006	\N	Projection Pixel Calibration Sequence	t	\N	f	\N	\N
(0018,9402)	24	37890	0	0	0	0	FL	1	3-2006	\N	Distance Source to Isocenter	t	\N	f	\N	\N
(0018,9403)	24	37891	0	0	0	0	FL	1	3-2006	\N	Distance Object to Table Top	t	\N	f	\N	\N
(0018,9404)	24	37892	0	0	0	0	FL	2	3-2006	\N	Object Pixel Spacing in Center of Beam	t	\N	f	\N	\N
(0018,9405)	24	37893	0	0	0	0	SQ	1	3-2006	\N	Positioner Position Sequence	t	\N	f	\N	\N
(0018,9406)	24	37894	0	0	0	0	SQ	1	3-2006	\N	Table Position Sequence	t	\N	f	\N	\N
(0018,9407)	24	37895	0	0	0	0	SQ	1	3-2006	\N	Collimator Shape Sequence	t	\N	f	\N	\N
(0018,9412)	24	37906	0	0	0	0	SQ	1	3-2006	\N	XA/XRF Frame Characteristics Sequence	t	\N	f	\N	\N
(0018,9417)	24	37911	0	0	0	0	SQ	1	3-2006	\N	Frame Acquisition Sequence	t	\N	f	\N	\N
(0018,9420)	24	37920	0	0	0	0	CS	1	3-2006	\N	X-Ray Receptor Type	t	\N	f	\N	\N
(0018,9423)	24	37923	0	0	0	0	LO	1	3-2006	\N	Acquisition Protocol Name	t	\N	f	\N	\N
(0018,9424)	24	37924	0	0	0	0	LT	1	3-2006	\N	Acquisition Protocol Description	t	\N	f	\N	\N
(0018,9425)	24	37925	0	0	0	0	CS	1	3-2006	\N	Contrast/Bolus Ingredient Opaque	t	\N	f	\N	\N
(0018,9426)	24	37926	0	0	0	0	FL	1	3-2006	\N	Distance Receptor Plane to Detector Housing	t	\N	f	\N	\N
(0018,9427)	24	37927	0	0	0	0	CS	1	3-2006	\N	Intensifier Active Shape	t	\N	f	\N	\N
(0018,9428)	24	37928	0	0	0	0	FL	1-2	3-2006	\N	Intensifier Active Dimension(s)	t	\N	f	\N	\N
(0018,9429)	24	37929	0	0	0	0	FL	2	3-2006	\N	Physical Detector Size	t	\N	f	\N	\N
(0018,9430)	24	37936	0	0	0	0	US	2	3-2006	\N	Position of Isocenter Projection	t	\N	f	\N	\N
(0018,9432)	24	37938	0	0	0	0	SQ	1	3-2006	\N	Field of View Sequence	t	\N	f	\N	\N
(0018,9433)	24	37939	0	0	0	0	LO	1	3-2006	\N	Field of View Description	t	\N	f	\N	\N
(0018,9434)	24	37940	0	0	0	0	SQ	1	3-2006	\N	Exposure Control Sensing Regions Sequence	t	\N	f	\N	\N
(0018,9435)	24	37941	0	0	0	0	CS	1	3-2006	\N	Exposure Control Sensing Region Shape	t	\N	f	\N	\N
(0018,9436)	24	37942	0	0	0	0	SS	1	3-2006	\N	Exposure Control Sensing Region Left Vertical Edge	t	\N	f	\N	\N
(0018,9437)	24	37943	0	0	0	0	SS	1	3-2006	\N	Exposure Control Sensing Region Right Vertical Edge	t	\N	f	\N	\N
(0018,9438)	24	37944	0	0	0	0	SS	1	3-2006	\N	Exposure Control Sensing Region Upper Horizontal Edge	t	\N	f	\N	\N
(0018,9439)	24	37945	0	0	0	0	SS	1	3-2006	\N	Exposure Control Sensing Region Lower Horizontal Edge	t	\N	f	\N	\N
(0018,9440)	24	37952	0	0	0	0	SS	2	3-2006	\N	Center of Circular Exposure Control Sensing Region	t	\N	f	\N	\N
(0018,9441)	24	37953	0	0	0	0	US	1	3-2006	\N	Radius of Circular Exposure Control Sensing Region	t	\N	f	\N	\N
(0018,9442)	24	37954	0	0	0	0	SS	2-n	3-2006	\N	Vertices of the Polygonal Exposure Control Sensing Region	t	\N	f	\N	\N
(0018,9447)	24	37959	0	0	0	0	FL	1	3-2006	\N	Column Angulation (Patient)	t	\N	f	\N	\N
(0018,9449)	24	37961	0	0	0	0	FL	1	3-2006	\N	Beam Angle	t	\N	f	\N	\N
(0018,9451)	24	37969	0	0	0	0	SQ	1	3-2006	\N	Frame Detector Parameters Sequence	t	\N	f	\N	\N
(0018,9452)	24	37970	0	0	0	0	FL	1	3-2006	\N	Calculated Anatomy Thickness	t	\N	f	\N	\N
(0018,9455)	24	37973	0	0	0	0	SQ	1	3-2006	\N	Calibration Sequence	t	\N	f	\N	\N
(0018,9456)	24	37974	0	0	0	0	SQ	1	3-2006	\N	Object Thickness Sequence	t	\N	f	\N	\N
(0018,9457)	24	37975	0	0	0	0	CS	1	3-2006	\N	Plane Identification	t	\N	f	\N	\N
(0018,9461)	24	37985	0	0	0	0	FL	1-2	3-2006	\N	Field of View Dimension(s) in Float	t	\N	f	\N	\N
(0018,9462)	24	37986	0	0	0	0	SQ	1	3-2006	\N	Isocenter Reference System Sequence	t	\N	f	\N	\N
(0018,9463)	24	37987	0	0	0	0	FL	1	3-2006	\N	Positioner Isocenter Primary Angle	t	\N	f	\N	\N
(0018,9464)	24	37988	0	0	0	0	FL	1	3-2006	\N	Positioner Isocenter Secondary Angle	t	\N	f	\N	\N
(0018,9465)	24	37989	0	0	0	0	FL	1	3-2006	\N	Positioner Isocenter Detector Rotation Angle	t	\N	f	\N	\N
(0018,9466)	24	37990	0	0	0	0	FL	1	3-2006	\N	Table X Position to Isocenter	t	\N	f	\N	\N
(0018,9467)	24	37991	0	0	0	0	FL	1	3-2006	\N	Table Y Position to Isocenter	t	\N	f	\N	\N
(0018,9468)	24	37992	0	0	0	0	FL	1	3-2006	\N	Table Z Position to Isocenter	t	\N	f	\N	\N
(0018,9469)	24	37993	0	0	0	0	FL	1	3-2006	\N	Table Horizontal Rotation Angle	t	\N	f	\N	\N
(0018,9470)	24	38000	0	0	0	0	FL	1	3-2006	\N	Table Head Tilt Angle	t	\N	f	\N	\N
(0018,9471)	24	38001	0	0	0	0	FL	1	3-2006	\N	Table Cradle Tilt Angle	t	\N	f	\N	\N
(0018,9472)	24	38002	0	0	0	0	SQ	1	3-2006	\N	Frame Display Shutter Sequence	t	\N	f	\N	\N
(0018,9473)	24	38003	0	0	0	0	FL	1	3-2006	\N	Acquired Image Area Dose Product	t	\N	f	\N	\N
(0018,9474)	24	38004	0	0	0	0	CS	1	3-2006	\N	C-arm Positioner Tabletop Relationship	t	\N	f	\N	\N
(0018,9476)	24	38006	0	0	0	0	SQ	1	3-2006	\N	X-Ray Geometry Sequence	t	\N	f	\N	\N
(0018,9477)	24	38007	0	0	0	0	SQ	1	3-2006	\N	Irradiation Event Identification Sequence	t	\N	f	\N	\N
(0018,a001)	24	40961	0	0	0	0	SQ	1	3-2006	\N	Contributing Equipment Sequence	t	\N	f	\N	\N
(0018,a002)	24	40962	0	0	0	0	DT	1	3-2006	\N	Contribution Date Time	t	\N	f	\N	\N
(0018,a003)	24	40963	0	0	0	0	ST	1	3-2006	\N	Contribution Description	t	\N	f	\N	\N
(0020,9251)	32	37457	0	0	0	0	FD	1	3-2006	\N	R - R Interval Time Measured	t	\N	f	\N	\N
(0020,9253)	32	37459	0	0	0	0	SQ	1	3-2006	\N	Respiratory Trigger Sequence	t	\N	f	\N	\N
(0020,9254)	32	37460	0	0	0	0	FD	1	3-2006	\N	Respiratory Interval Time	t	\N	f	\N	\N
(0020,9255)	32	37461	0	0	0	0	FD	1	3-2006	\N	Respiratory Trigger Delay Time	t	\N	f	\N	\N
(0020,9256)	32	37462	0	0	0	0	FD	1	3-2006	\N	Respiratory Trigger Delay Threshold	t	\N	f	\N	\N
(0020,9421)	32	37921	0	0	0	0	LO	1	3-2006	\N	Dimension Description Label	t	\N	f	\N	\N
(0020,9450)	32	37968	0	0	0	0	SQ	1	3-2006	\N	Patient Orientation in Frame Sequence	t	\N	f	\N	\N
(0022,0001)	34	1	0	0	0	0	US	1	3-2006	\N	Light Path Filter Pass-Through Wavelength	t	\N	f	\N	\N
(0022,0002)	34	2	0	0	0	0	US	2	3-2006	\N	Light Path Filter Pass Band	t	\N	f	\N	\N
(0022,0003)	34	3	0	0	0	0	US	1	3-2006	\N	Image Path Filter Pass-Through Wavelength	t	\N	f	\N	\N
(0022,0004)	34	4	0	0	0	0	US	2	3-2006	\N	Image Path Filter Pass Band	t	\N	f	\N	\N
(0022,0005)	34	5	0	0	0	0	CS	1	3-2006	\N	Patient Eye Movement Commanded	t	\N	f	\N	\N
(0022,0006)	34	6	0	0	0	0	SQ	1	3-2006	\N	Patient Eye Movement Command Code Sequence	t	\N	f	\N	\N
(0022,0007)	34	7	0	0	0	0	FL	1	3-2006	\N	Spherical Lens Power	t	\N	f	\N	\N
(0022,0008)	34	8	0	0	0	0	FL	1	3-2006	\N	Cylinder Lens Power	t	\N	f	\N	\N
(0022,0009)	34	9	0	0	0	0	FL	1	3-2006	\N	Cylinder Axis	t	\N	f	\N	\N
(0022,000a)	34	10	0	0	0	0	FL	1	3-2006	\N	Emmetropic Magnification	t	\N	f	\N	\N
(0022,000b)	34	11	0	0	0	0	FL	1	3-2006	\N	Intra Ocular Pressure	t	\N	f	\N	\N
(0022,000c)	34	12	0	0	0	0	FL	1	3-2006	\N	Horizontal Field of View	t	\N	f	\N	\N
(0022,000d)	34	13	0	0	0	0	CS	1	3-2006	\N	Pupil Dilated	t	\N	f	\N	\N
(0022,000e)	34	14	0	0	0	0	FL	1	3-2006	\N	Degree of Dilation	t	\N	f	\N	\N
(0022,0010)	34	16	0	0	0	0	FL	1	3-2006	\N	Stereo Baseline Angle	t	\N	f	\N	\N
(0022,0011)	34	17	0	0	0	0	FL	1	3-2006	\N	Stereo Baseline Displacement	t	\N	f	\N	\N
(0022,0012)	34	18	0	0	0	0	FL	1	3-2006	\N	Stereo Horizontal Pixel Offset	t	\N	f	\N	\N
(0022,0013)	34	19	0	0	0	0	FL	1	3-2006	\N	Stereo Vertical Pixel Offset	t	\N	f	\N	\N
(0022,0014)	34	20	0	0	0	0	FL	1	3-2006	\N	Stereo Rotation	t	\N	f	\N	\N
(0022,0015)	34	21	0	0	0	0	SQ	1	3-2006	\N	Acquisition Device Type Code Sequence	t	\N	f	\N	\N
(0022,0016)	34	22	0	0	0	0	SQ	1	3-2006	\N	Illumination Type Code Sequence	t	\N	f	\N	\N
(0022,0017)	34	23	0	0	0	0	SQ	1	3-2006	\N	Light Path Filter Type Stack Code Sequence	t	\N	f	\N	\N
(0022,0018)	34	24	0	0	0	0	SQ	1	3-2006	\N	Image Path Filter Type Stack Code Sequence	t	\N	f	\N	\N
(0022,0019)	34	25	0	0	0	0	SQ	1	3-2006	\N	Lenses Code Sequence	t	\N	f	\N	\N
(0022,001a)	34	26	0	0	0	0	SQ	1	3-2006	\N	Channel Description Code Sequence	t	\N	f	\N	\N
(0022,001b)	34	27	0	0	0	0	SQ	1	3-2006	\N	Refractive State Sequence	t	\N	f	\N	\N
(0022,001c)	34	28	0	0	0	0	SQ	1	3-2006	\N	Mydriatic Agent Code Sequence	t	\N	f	\N	\N
(0022,001d)	34	29	0	0	0	0	SQ	1	3-2006	\N	Relative Image Position Code Sequence	t	\N	f	\N	\N
(0022,0020)	34	32	0	0	0	0	SQ	1	3-2006	\N	Stereo Pairs Sequence	t	\N	f	\N	\N
(0022,0021)	34	33	0	0	0	0	SQ	1	3-2006	\N	Left Image Sequence	t	\N	f	\N	\N
(0022,0022)	34	34	0	0	0	0	SQ	1	3-2006	\N	Right Image Sequence	t	\N	f	\N	\N
(0028,0003)	40	3	0	0	0	0	US	1	3-2006	\N	Samples per Pixel Used	t	\N	f	\N	\N
(0028,000a)	40	10	0	0	0	0	AT	1-n	3-2006	\N	Frame Dimension Pointer	t	\N	f	\N	\N
(0028,1056)	40	4182	0	0	0	0	CS	1	3-2006	\N	VOI LUT Function	t	\N	f	\N	\N
(0028,1352)	40	4946	0	0	0	0	SQ	1	3-2006	\N	Partial View Code Sequence	t	\N	f	\N	\N
(0028,135a)	40	4954	0	0	0	0	CS	1	3-2006	\N	Spatial Locations Preserved	t	\N	f	\N	\N
(0028,2000)	40	8192	0	0	0	0	OB	1	3-2006	\N	ICC Profile	t	\N	f	\N	\N
(0028,2114)	40	8468	0	0	0	0	CS	1-n	3-2006	\N	Lossy Image Compression Method	t	\N	f	\N	\N
(0028,6023)	40	24611	0	0	0	0	CS	1-n	3-2006	\N	Frame of Interest Type	t	\N	f	\N	\N
(0028,7fe0)	40	32736	0	0	0	0	UT	1	3-2006	\N	Pixel Data Provider URL	t	\N	f	\N	\N
(0028,9411)	40	37905	0	0	0	0	FL	1	3-2006	\N	Display Filter Percentage	t	\N	f	\N	\N
(0028,9415)	40	37909	0	0	0	0	SQ	1	3-2006	\N	Frame Pixel Shift Sequence	t	\N	f	\N	\N
(0028,9416)	40	37910	0	0	0	0	US	1	3-2006	\N	Subtraction Item ID	t	\N	f	\N	\N
(0028,9422)	40	37922	0	0	0	0	SQ	1	3-2006	\N	Pixel Intensity Relationship LUT Sequence	t	\N	f	\N	\N
(0028,9443)	40	37955	0	0	0	0	SQ	1	3-2006	\N	Frame Pixel Data Properties Sequence	t	\N	f	\N	\N
(0028,9444)	40	37956	0	0	0	0	CS	1	3-2006	\N	Geometrical Properties	t	\N	f	\N	\N
(0028,9445)	40	37957	0	0	0	0	FL	1	3-2006	\N	Geometric Maximum Distortion	t	\N	f	\N	\N
(0028,9446)	40	37958	0	0	0	0	CS	1-n	3-2006	\N	Image Processing Applied	t	\N	f	\N	\N
(0028,9454)	40	37972	0	0	0	0	CS	1	3-2006	\N	Mask Selection Mode	t	\N	f	\N	\N
(0028,9474)	40	38004	0	0	0	0	CS	1	3-2006	\N	LUT Function	t	\N	f	\N	\N
(0032,1031)	50	4145	0	0	0	0	SQ	1	3-2006	\N	Requesting Physician Identification Sequence	t	\N	f	\N	\N
(0038,0100)	56	256	0	0	0	0	SQ	1	3-2006	\N	Pertinent Documents Sequence	t	\N	f	\N	\N
(0038,0502)	56	1282	0	0	0	0	SQ	1	3-2006	\N	Patient Clinical Trial Participation Sequence	t	\N	f	\N	\N
(003a,0300)	58	768	0	0	0	0	SQ	1	3-2006	\N	Multiplexed Audio Channels Description Code Sequence	t	\N	f	\N	\N
(003a,0301)	58	769	0	0	0	0	IS	1	3-2006	\N	Channel Identification Code	t	\N	f	\N	\N
(003a,0302)	58	770	0	0	0	0	CS	1	3-2006	\N	Channel Mode	t	\N	f	\N	\N
(0040,000b)	64	11	0	0	0	0	SQ	1	3-2006	\N	Scheduled Performing Physician Identification Sequence	t	\N	f	\N	\N
(0040,0281)	64	641	0	0	0	0	SQ	1	3-2006	\N	Performed Procedure Step Discontinuation Reason Code Sequence	t	\N	f	\N	\N
(0040,0440)	64	1088	0	0	0	0	SQ	1	3-2006	\N	Protocol Context Sequence	t	\N	f	\N	\N
(0040,0441)	64	1089	0	0	0	0	SQ	1	3-2006	\N	Content Item Modifier Sequence	t	\N	f	\N	\N
(0040,100a)	64	4106	0	0	0	0	SQ	1	3-2006	\N	Reason for Requested Procedure Code Sequence	t	\N	f	\N	\N
(0040,1011)	64	4113	0	0	0	0	SQ	1	3-2006	\N	Intended Recipients of Results Identification Sequence	t	\N	f	\N	\N
(0040,1101)	64	4353	0	0	0	0	SQ	1	3-2006	\N	Person Identification Code Sequence	t	\N	f	\N	\N
(0040,1102)	64	4354	0	0	0	0	ST	1	3-2006	\N	Person's Address	t	\N	f	\N	\N
(0040,1103)	64	4355	0	0	0	0	LO	1-n	3-2006	\N	Person's Telephone Numbers	t	\N	f	\N	\N
(0040,4010)	64	16400	0	0	0	0	DT	1	3-2006	\N	Scheduled Procedure Step Modification Date and Time	t	\N	f	\N	\N
(0040,9094)	64	37012	0	0	0	0	SQ	1	3-2006	\N	Referenced Image Real World Value Mapping Sequence	t	\N	f	\N	\N
(0040,9098)	64	37016	0	0	0	0	SQ	1	3-2006	\N	Pixel Value Mapping Code Sequence	t	\N	f	\N	\N
(0040,a078)	64	41080	0	0	0	0	SQ	1	3-2006	\N	Author Observer Sequence	t	\N	f	\N	\N
(0040,a07a)	64	41082	0	0	0	0	SQ	1	3-2006	\N	Participant Sequence	t	\N	f	\N	\N
(0040,a07c)	64	41084	0	0	0	0	SQ	1	3-2006	\N	Custodial Organization Sequence	t	\N	f	\N	\N
(0040,a080)	64	41088	0	0	0	0	CS	1	3-2006	\N	Participation Type	t	\N	f	\N	\N
(0040,a082)	64	41090	0	0	0	0	DT	1	3-2006	\N	Participation Datetime	t	\N	f	\N	\N
(0040,a084)	64	41092	0	0	0	0	CS	1	3-2006	\N	Observer Type	t	\N	f	\N	\N
(0040,a090)	64	41104	0	0	0	0	SQ	1	3-2006	\N	Equivalent CDA Document Sequence	t	\N	f	\N	\N
(0040,a301)	64	41729	0	0	0	0	SQ	1	3-2006	\N	Numeric Value Qualifier Code Sequence	t	\N	f	\N	\N
(0040,a390)	64	41872	0	0	0	0	SQ	1	3-2006	\N	HL7 Structured Document Reference Sequence	t	\N	f	\N	\N
(0040,e001)	64	57345	0	0	0	0	ST	1	3-2006	\N	HL7 Instance Identifier 	t	\N	f	\N	\N
(0040,e004)	64	57348	0	0	0	0	DT	1	3-2006	\N	HL7 Document Effective Time	t	\N	f	\N	\N
(0040,e006)	64	57350	0	0	0	0	SQ	1	3-2006	\N	HL7 Document Type Code Sequence	t	\N	f	\N	\N
(0040,e010)	64	57360	0	0	0	0	UT	1	3-2006	\N	Retrieve URI 	t	\N	f	\N	\N
(0042,0010)	66	16	0	0	0	0	ST	1	3-2006	\N	Document Title	t	\N	f	\N	\N
(0042,0011)	66	17	0	0	0	0	OB	1	3-2006	\N	Encapsulated Document	t	\N	f	\N	\N
(0042,0012)	66	18	0	0	0	0	LO	1	3-2006	\N	MIME Type of Encapsulated Document	t	\N	f	\N	\N
(0042,0013)	66	19	0	0	0	0	SQ	1	3-2006	\N	Source Instance Sequence	t	\N	f	\N	\N
(0054,0039)	84	57	0	0	0	0	CS	1	3-2006	\N	Phase Description	t	\N	f	\N	\N
(0054,0500)	84	1280	0	0	0	0	CS	1	3-2006	\N	Slice Progression Direction	t	\N	f	\N	\N
(0070,0086)	112	134	0	0	0	0	SQ	1	3-2006	\N	Content Creator's Identification Code Sequence	t	\N	f	\N	\N
(0070,0306)	112	774	0	0	0	0	CS	1	3-2006	\N	Shape Type	t	\N	f	\N	\N
(0070,0308)	112	776	0	0	0	0	SQ	1	3-2006	\N	Registration Sequence	t	\N	f	\N	\N
(0070,0309)	112	777	0	0	0	0	SQ	1	3-2006	\N	Matrix Registration Sequence	t	\N	f	\N	\N
(0070,030a)	112	778	0	0	0	0	SQ	1	3-2006	\N	Matrix Sequence	t	\N	f	\N	\N
(0070,030c)	112	780	0	0	0	0	CS	1	3-2006	\N	Frame of Reference Transformation Matrix Type	t	\N	f	\N	\N
(0070,030d)	112	781	0	0	0	0	SQ	1	3-2006	\N	Registration Type Code Sequence	t	\N	f	\N	\N
(0070,030f)	112	783	0	0	0	0	ST	1	3-2006	\N	Fiducial Description	t	\N	f	\N	\N
(0070,0310)	112	784	0	0	0	0	SH	1	3-2006	\N	Fiducial Identifier	t	\N	f	\N	\N
(0070,0311)	112	785	0	0	0	0	SQ	1	3-2006	\N	Fiducial Identifier Code Sequence	t	\N	f	\N	\N
(0070,0312)	112	786	0	0	0	0	FD	1	3-2006	\N	Contour Uncertainty Radius	t	\N	f	\N	\N
(0070,0314)	112	788	0	0	0	0	SQ	1	3-2006	\N	Used Fiducials Sequence	t	\N	f	\N	\N
(0070,0318)	112	792	0	0	0	0	SQ	1	3-2006	\N	Graphic Coordinates Data Sequence	t	\N	f	\N	\N
(0070,031a)	112	794	0	0	0	0	UI	1	3-2006	\N	Fiducial UID	t	\N	f	\N	\N
(0070,031c)	112	796	0	0	0	0	SQ	1	3-2006	\N	Fiducial Set Sequence	t	\N	f	\N	\N
(0070,031e)	112	798	0	0	0	0	SQ	1	3-2006	\N	Fiducial Sequence	t	\N	f	\N	\N
(0070,0401)	112	1025	0	0	0	0	US	3	3-2006	\N	Graphic Layer Recommended Display CIELab Value	t	\N	f	\N	\N
(0070,0402)	112	1026	0	0	0	0	SQ	1	3-2006	\N	Blending Sequence	t	\N	f	\N	\N
(0070,0403)	112	1027	0	0	0	0	FL	1	3-2006	\N	Relative Opacity	t	\N	f	\N	\N
(0070,0404)	112	1028	0	0	0	0	SQ	1	3-2006	\N	Referenced Spatial Registration Sequence	t	\N	f	\N	\N
(0070,0405)	112	1029	0	0	0	0	CS	1	3-2006	\N	Blending Position	t	\N	f	\N	\N
(0072,0002)	114	2	0	0	0	0	SH	1	3-2006	\N	Hanging Protocol Name	t	\N	f	\N	\N
(0072,0004)	114	4	0	0	0	0	LO	1	3-2006	\N	Hanging Protocol Description	t	\N	f	\N	\N
(0072,0006)	114	6	0	0	0	0	CS	1	3-2006	\N	Hanging Protocol Level	t	\N	f	\N	\N
(0072,0008)	114	8	0	0	0	0	LO	1	3-2006	\N	Hanging Protocol Creator	t	\N	f	\N	\N
(0072,000a)	114	10	0	0	0	0	DT	1	3-2006	\N	Hanging Protocol Creation Datetime	t	\N	f	\N	\N
(0072,000c)	114	12	0	0	0	0	SQ	1	3-2006	\N	Hanging Protocol Definition Sequence	t	\N	f	\N	\N
(0072,000e)	114	14	0	0	0	0	SQ	1	3-2006	\N	Hanging Protocol User Identification Code Sequence	t	\N	f	\N	\N
(0072,0010)	114	16	0	0	0	0	LO	1	3-2006	\N	Hanging Protocol User Group Name	t	\N	f	\N	\N
(0072,0012)	114	18	0	0	0	0	SQ	1	3-2006	\N	Source Hanging Protocol Sequence	t	\N	f	\N	\N
(0072,0014)	114	20	0	0	0	0	US	1	3-2006	\N	Number of Priors Referenced	t	\N	f	\N	\N
(0072,0020)	114	32	0	0	0	0	SQ	1	3-2006	\N	Image Sets Sequence	t	\N	f	\N	\N
(0072,0022)	114	34	0	0	0	0	SQ	1	3-2006	\N	Image Set Selector Sequence	t	\N	f	\N	\N
(0072,0024)	114	36	0	0	0	0	CS	1	3-2006	\N	Image Set Selector Usage Flag	t	\N	f	\N	\N
(0072,0026)	114	38	0	0	0	0	AT	1	3-2006	\N	Selector Attribute	t	\N	f	\N	\N
(0072,0028)	114	40	0	0	0	0	US	1	3-2006	\N	Selector Value Number	t	\N	f	\N	\N
(0072,0030)	114	48	0	0	0	0	SQ	1	3-2006	\N	Time Based Image Sets Sequence	t	\N	f	\N	\N
(0072,0032)	114	50	0	0	0	0	US	1	3-2006	\N	Image Set Number	t	\N	f	\N	\N
(0072,0034)	114	52	0	0	0	0	CS	1	3-2006	\N	Image Set Selector Category	t	\N	f	\N	\N
(0072,0038)	114	56	0	0	0	0	US	2	3-2006	\N	Relative Time	t	\N	f	\N	\N
(0072,003a)	114	58	0	0	0	0	CS	1	3-2006	\N	Relative Time Units	t	\N	f	\N	\N
(0072,003c)	114	60	0	0	0	0	SS	2	3-2006	\N	Abstract Prior Value	t	\N	f	\N	\N
(0072,003e)	114	62	0	0	0	0	SQ	1	3-2006	\N	Abstract Prior Code Sequence	t	\N	f	\N	\N
(0072,0040)	114	64	0	0	0	0	LO	1	3-2006	\N	Image Set Label	t	\N	f	\N	\N
(0072,0050)	114	80	0	0	0	0	CS	1	3-2006	\N	Selector Attribute VR	t	\N	f	\N	\N
(0072,0052)	114	82	0	0	0	0	AT	1	3-2006	\N	Selector Sequence Pointer	t	\N	f	\N	\N
(0072,0054)	114	84	0	0	0	0	LO	1	3-2006	\N	Selector Sequence Pointer Private Creator	t	\N	f	\N	\N
(0072,0056)	114	86	0	0	0	0	LO	1	3-2006	\N	Selector Attribute Private Creator	t	\N	f	\N	\N
(0072,0060)	114	96	0	0	0	0	AT	1-n	3-2006	\N	Selector AT Value	t	\N	f	\N	\N
(0072,0062)	114	98	0	0	0	0	CS	1-n	3-2006	\N	Selector CS Value	t	\N	f	\N	\N
(0072,0064)	114	100	0	0	0	0	IS	1-n	3-2006	\N	Selector IS Value	t	\N	f	\N	\N
(0072,0066)	114	102	0	0	0	0	LO	1-n	3-2006	\N	Selector LO Value	t	\N	f	\N	\N
(0072,0068)	114	104	0	0	0	0	LT	1-n	3-2006	\N	Selector LT Value	t	\N	f	\N	\N
(0072,006a)	114	106	0	0	0	0	PN	1-n	3-2006	\N	Selector PN Value	t	\N	f	\N	\N
(0072,006c)	114	108	0	0	0	0	SH	1-n	3-2006	\N	Selector SH Value	t	\N	f	\N	\N
(0072,006e)	114	110	0	0	0	0	ST	1-n	3-2006	\N	Selector ST Value	t	\N	f	\N	\N
(0072,0070)	114	112	0	0	0	0	UT	1-n	3-2006	\N	Selector UT Value	t	\N	f	\N	\N
(0072,0072)	114	114	0	0	0	0	DS	1-n	3-2006	\N	Selector DS Value	t	\N	f	\N	\N
(0072,0074)	114	116	0	0	0	0	FD	1-n	3-2006	\N	Selector FD Value	t	\N	f	\N	\N
(0072,0076)	114	118	0	0	0	0	FL	1-n	3-2006	\N	Selector FL Value	t	\N	f	\N	\N
(0072,0078)	114	120	0	0	0	0	UL	1-n	3-2006	\N	Selector UL Value	t	\N	f	\N	\N
(0072,007a)	114	122	0	0	0	0	US	1-n	3-2006	\N	Selector US Value	t	\N	f	\N	\N
(0072,007c)	114	124	0	0	0	0	SL	1-n	3-2006	\N	Selector SL Value	t	\N	f	\N	\N
(0072,007e)	114	126	0	0	0	0	SS	1-n	3-2006	\N	Selector SS Value	t	\N	f	\N	\N
(0072,0080)	114	128	0	0	0	0	SQ	1	3-2006	\N	Selector Code Sequence Value	t	\N	f	\N	\N
(0072,0100)	114	256	0	0	0	0	US	1	3-2006	\N	Number of Screens	t	\N	f	\N	\N
(0072,0102)	114	258	0	0	0	0	SQ	1	3-2006	\N	Nominal Screen Definition Sequence	t	\N	f	\N	\N
(0072,0104)	114	260	0	0	0	0	US	1	3-2006	\N	Number of Vertical Pixels	t	\N	f	\N	\N
(0072,0106)	114	262	0	0	0	0	US	1	3-2006	\N	Number of Horizontal Pixels	t	\N	f	\N	\N
(0072,0108)	114	264	0	0	0	0	FD	4	3-2006	\N	Display Environment Spatial Position	t	\N	f	\N	\N
(0072,010a)	114	266	0	0	0	0	US	1	3-2006	\N	Screen Minimum Grayscale Bit Depth	t	\N	f	\N	\N
(0072,010c)	114	268	0	0	0	0	US	1	3-2006	\N	Screen Minimum Color Bit Depth	t	\N	f	\N	\N
(0072,010e)	114	270	0	0	0	0	US	1	3-2006	\N	Application Maximum Repaint Time	t	\N	f	\N	\N
(0072,0200)	114	512	0	0	0	0	SQ	1	3-2006	\N	Display Sets Sequence	t	\N	f	\N	\N
(0072,0202)	114	514	0	0	0	0	US	1	3-2006	\N	Display Set Number	t	\N	f	\N	\N
(0072,0203)	114	515	0	0	0	0	LO	1	3-2006	\N	Display Set Label	t	\N	f	\N	\N
(0072,0204)	114	516	0	0	0	0	US	1	3-2006	\N	Display Set Presentation Group	t	\N	f	\N	\N
(0072,0206)	114	518	0	0	0	0	LO	1	3-2006	\N	Display Set Presentation Group Description	t	\N	f	\N	\N
(0072,0208)	114	520	0	0	0	0	CS	1	3-2006	\N	Partial Data Display Handling	t	\N	f	\N	\N
(0072,0210)	114	528	0	0	0	0	SQ	1	3-2006	\N	Synchronized Scrolling Sequence	t	\N	f	\N	\N
(0072,0212)	114	530	0	0	0	0	US	2-n	3-2006	\N	Display Set Scrolling Group	t	\N	f	\N	\N
(0072,0214)	114	532	0	0	0	0	SQ	1	3-2006	\N	Navigation Indicator Sequence	t	\N	f	\N	\N
(0072,0216)	114	534	0	0	0	0	US	1	3-2006	\N	Navigation Display Set 	t	\N	f	\N	\N
(0072,0218)	114	536	0	0	0	0	US	1-n	3-2006	\N	Reference Display Sets	t	\N	f	\N	\N
(0072,0300)	114	768	0	0	0	0	SQ	1	3-2006	\N	Image Boxes Sequence	t	\N	f	\N	\N
(0072,0302)	114	770	0	0	0	0	US	1	3-2006	\N	Image Box Number	t	\N	f	\N	\N
(0072,0304)	114	772	0	0	0	0	CS	1	3-2006	\N	Image Box Layout Type	t	\N	f	\N	\N
(0072,0306)	114	774	0	0	0	0	US	1	3-2006	\N	Image Box Tile Horizontal Dimension	t	\N	f	\N	\N
(0072,0308)	114	776	0	0	0	0	US	1	3-2006	\N	Image Box Tile Vertical Dimension	t	\N	f	\N	\N
(0072,0310)	114	784	0	0	0	0	CS	1	3-2006	\N	Image Box Scroll Direction	t	\N	f	\N	\N
(0072,0312)	114	786	0	0	0	0	CS	1	3-2006	\N	Image Box Small Scroll Type	t	\N	f	\N	\N
(0072,0314)	114	788	0	0	0	0	US	1	3-2006	\N	Image Box Small Scroll Amount	t	\N	f	\N	\N
(0072,0316)	114	790	0	0	0	0	CS	1	3-2006	\N	Image Box Large Scroll Type	t	\N	f	\N	\N
(0072,0318)	114	792	0	0	0	0	US	1	3-2006	\N	Image Box Large Scroll Amount	t	\N	f	\N	\N
(0072,0320)	114	800	0	0	0	0	US	1	3-2006	\N	Image Box Overlap Priority	t	\N	f	\N	\N
(0072,0330)	114	816	0	0	0	0	FD	1	3-2006	\N	Cine Relative to Real-Time	t	\N	f	\N	\N
(0072,0400)	114	1024	0	0	0	0	SQ	1	3-2006	\N	Filter Operations Sequence	t	\N	f	\N	\N
(0072,0402)	114	1026	0	0	0	0	CS	1	3-2006	\N	Filter-by Category	t	\N	f	\N	\N
(0072,0404)	114	1028	0	0	0	0	CS	1	3-2006	\N	Filter-by Attribute Presence	t	\N	f	\N	\N
(0072,0406)	114	1030	0	0	0	0	CS	1	3-2006	\N	Filter-by Operator	t	\N	f	\N	\N
(0072,0500)	114	1280	0	0	0	0	CS	1	3-2006	\N	Blending Operation Type	t	\N	f	\N	\N
(0072,0510)	114	1296	0	0	0	0	CS	1	3-2006	\N	Reformatting Operation Type	t	\N	f	\N	\N
(0072,0512)	114	1298	0	0	0	0	FD	1	3-2006	\N	Reformatting Thickness	t	\N	f	\N	\N
(0072,0514)	114	1300	0	0	0	0	FD	1	3-2006	\N	Reformatting Interval	t	\N	f	\N	\N
(0072,0516)	114	1302	0	0	0	0	CS	1	3-2006	\N	Reformatting Operation Initial View Direction	t	\N	f	\N	\N
(0072,0520)	114	1312	0	0	0	0	CS	1-n	3-2006	\N	3D Rendering Type	t	\N	f	\N	\N
(0072,0600)	114	1536	0	0	0	0	SQ	1	3-2006	\N	Sorting Operations Sequence	t	\N	f	\N	\N
(0072,0602)	114	1538	0	0	0	0	CS	1	3-2006	\N	Sort-by Category	t	\N	f	\N	\N
(0072,0604)	114	1540	0	0	0	0	CS	1	3-2006	\N	Sorting Direction	t	\N	f	\N	\N
(0072,0700)	114	1792	0	0	0	0	CS	2	3-2006	\N	Display Set Patient Orientation	t	\N	f	\N	\N
(0072,0702)	114	1794	0	0	0	0	CS	1	3-2006	\N	VOI Type	t	\N	f	\N	\N
(0072,0704)	114	1796	0	0	0	0	CS	1	3-2006	\N	Pseudo-color Type	t	\N	f	\N	\N
(0072,0706)	114	1798	0	0	0	0	CS	1	3-2006	\N	Show Grayscale Inverted	t	\N	f	\N	\N
(0072,0710)	114	1808	0	0	0	0	CS	1	3-2006	\N	Show Image True Size Flag	t	\N	f	\N	\N
(0072,0712)	114	1810	0	0	0	0	CS	1	3-2006	\N	Show Graphic Annotation Flag	t	\N	f	\N	\N
(0072,0714)	114	1812	0	0	0	0	CS	1	3-2006	\N	Show Patient Demographics Flag	t	\N	f	\N	\N
(0072,0716)	114	1814	0	0	0	0	CS	1	3-2006	\N	Show Acquisition Techniques Flag	t	\N	f	\N	\N
(0072,0717)	114	1815	0	0	0	0	CS	1	3-2006	\N	Display Set Horizontal Justification 	t	\N	f	\N	\N
(0072,0718)	114	1816	0	0	0	0	CS	1	3-2006	\N	Display Set Vertical Justification	t	\N	f	\N	\N
(0400,0401)	1024	1025	0	0	0	0	SQ	1	3-2006	\N	Digital Signature Purpose Code Sequence	t	\N	f	\N	\N
(0400,0402)	1024	1026	0	0	0	0	SQ	1	3-2006	\N	Referenced Digital Signature Sequence	t	\N	f	\N	\N
(0400,0403)	1024	1027	0	0	0	0	SQ	1	3-2006	\N	Referenced SOP Instance MAC Sequence	t	\N	f	\N	\N
(0400,0404)	1024	1028	0	0	0	0	OB	1	3-2006	\N	MAC	t	\N	f	\N	\N
(0400,0500)	1024	1280	0	0	0	0	SQ	1	3-2006	\N	Encrypted Attributes Sequence	t	\N	f	\N	\N
(0400,0510)	1024	1296	0	0	0	0	UI	1	3-2006	\N	Encrypted Content Transfer Syntax UID	t	\N	f	\N	\N
(0400,0520)	1024	1312	0	0	0	0	OB	1	3-2006	\N	Encrypted Content	t	\N	f	\N	\N
(0400,0550)	1024	1360	0	0	0	0	SQ	1	3-2006	\N	Modified Attributes Sequence	t	\N	f	\N	\N
(2200,0001)	8704	1	0	0	0	0	CS	1	3-2006	\N	Label Using Information Extracted From Instances	t	\N	f	\N	\N
(2200,0002)	8704	2	0	0	0	0	UT	1	3-2006	\N	Label Text	t	\N	f	\N	\N
(2200,0003)	8704	3	0	0	0	0	CS	1	3-2006	\N	Label Style Selection	t	\N	f	\N	\N
(2200,0004)	8704	4	0	0	0	0	LT	1	3-2006	\N	Media Disposition	t	\N	f	\N	\N
(2200,0005)	8704	5	0	0	0	0	LT	1	3-2006	\N	Barcode Value	t	\N	f	\N	\N
(2200,0006)	8704	6	0	0	0	0	CS	1	3-2006	\N	Barcode Symbology	t	\N	f	\N	\N
(2200,0007)	8704	7	0	0	0	0	CS	1	3-2006	\N	Allow Media Splitting	t	\N	f	\N	\N
(2200,0008)	8704	8	0	0	0	0	CS	1	3-2006	\N	Include Non-DICOM Objects	t	\N	f	\N	\N
(2200,0009)	8704	9	0	0	0	0	CS	1	3-2006	\N	Include Display Application	t	\N	f	\N	\N
(2200,000a)	8704	10	0	0	0	0	CS	1	3-2006	\N	Preserve Composite Instances After Media Creation	t	\N	f	\N	\N
(2200,000b)	8704	11	0	0	0	0	US	1	3-2006	\N	Total Number of Pieces of Media Created	t	\N	f	\N	\N
(2200,000c)	8704	12	0	0	0	0	LO	1	3-2006	\N	Requested Media Application Profile	t	\N	f	\N	\N
(2200,000d)	8704	13	0	0	0	0	SQ	1	3-2006	\N	Referenced Storage Media Sequence	t	\N	f	\N	\N
(2200,000e)	8704	14	0	0	0	0	AT	1-n	3-2006	\N	Failure Attributes	t	\N	f	\N	\N
(2200,000f)	8704	15	0	0	0	0	CS	1	3-2006	\N	Allow Lossy Compression	t	\N	f	\N	\N
(2200,0020)	8704	32	0	0	0	0	CS	1	3-2006	\N	Request Priority	t	\N	f	\N	\N
(3002,000d)	12290	13	0	0	0	0	DS	3	3-2006	\N	X-Ray Image Receptor Translation	t	\N	f	\N	\N
(3002,0040)	12290	64	0	0	0	0	SQ	1	3-2006	\N	Fluence Map Sequence	t	\N	f	\N	\N
(3002,0041)	12290	65	0	0	0	0	CS	1	3-2006	\N	Fluence Data Source	t	\N	f	\N	\N
(3002,0042)	12290	66	0	0	0	0	DS	1	3-2006	\N	Fluence Data Scale	t	\N	f	\N	\N
(3004,0014)	12292	20	0	0	0	0	CS	1-3	3-2006	\N	Tissue Heterogeneity Correction	t	\N	f	\N	\N
(3008,0021)	12296	33	0	0	0	0	SQ	1	3-2006	\N	Treatment Session Ion Beam Sequence	t	\N	f	\N	\N
(3008,0041)	12296	65	0	0	0	0	SQ	1	3-2006	\N	Ion Control Point Delivery Sequence	t	\N	f	\N	\N
(3008,0045)	12296	69	0	0	0	0	FL	1	3-2006	\N	Meterset Rate Set	t	\N	f	\N	\N
(3008,0046)	12296	70	0	0	0	0	FL	1	3-2006	\N	Meterset Rate Delivered	t	\N	f	\N	\N
(3008,0047)	12296	71	0	0	0	0	FL	1-n	3-2006	\N	Scan Spot Metersets Delivered	t	\N	f	\N	\N
(3008,0061)	12296	97	0	0	0	0	AT	1	3-2006	\N	Parameter Sequence Pointer	t	\N	f	\N	\N
(3008,0063)	12296	99	0	0	0	0	IS	1	3-2006	\N	Parameter Item Index	t	\N	f	\N	\N
(3008,0065)	12296	101	0	0	0	0	AT	1	3-2006	\N	Parameter Pointer	t	\N	f	\N	\N
(3008,0068)	12296	104	0	0	0	0	SQ	1	3-2006	\N	Corrected Parameter Sequence	t	\N	f	\N	\N
(3008,006a)	12296	106	0	0	0	0	FL	1	3-2006	\N	Correction Value	t	\N	f	\N	\N
(3008,00f0)	12296	240	0	0	0	0	SQ	1	3-2006	\N	Recorded Snout Sequence	t	\N	f	\N	\N
(3008,00f2)	12296	242	0	0	0	0	SQ	1	3-2006	\N	Recorded Range Shifter Sequence	t	\N	f	\N	\N
(3008,00f4)	12296	244	0	0	0	0	SQ	1	3-2006	\N	Recorded Lateral Spreading Device Sequence	t	\N	f	\N	\N
(3008,00f6)	12296	246	0	0	0	0	SQ	1	3-2006	\N	Recorded Range Modulator Sequence	t	\N	f	\N	\N
(300a,0013)	12298	19	0	0	0	0	UI	1	3-2006	\N	Dose Reference UID	t	\N	f	\N	\N
(300a,004b)	12298	75	0	0	0	0	FL	1	3-2006	\N	Snout Position Tolerance	t	\N	f	\N	\N
(300a,004f)	12298	79	0	0	0	0	FL	1	3-2006	\N	Table Top Pitch Angle Tolerance	t	\N	f	\N	\N
(300a,0050)	12298	80	0	0	0	0	FL	1	3-2006	\N	Table Top Roll Angle Tolerance	t	\N	f	\N	\N
(300a,0072)	12298	114	0	0	0	0	LO	1	3-2006	\N	Fraction Group Description	t	\N	f	\N	\N
(300a,00bb)	12298	187	0	0	0	0	FL	1	3-2006	\N	Isocenter to Beam Limiting Device Distance	t	\N	f	\N	\N
(300a,00d7)	12298	215	0	0	0	0	FL	1	3-2006	\N	Total Wedge Tray Water-Equivalent Thickness	t	\N	f	\N	\N
(300a,00d9)	12298	217	0	0	0	0	FL	1	3-2006	\N	Isocenter to Wedge Tray Distance	t	\N	f	\N	\N
(300a,00db)	12298	219	0	0	0	0	FL	1	3-2006	\N	Wedge Thin Edge Position	t	\N	f	\N	\N
(300a,00dc)	12298	220	0	0	0	0	SH	1	3-2006	\N	Bolus ID	t	\N	f	\N	\N
(300a,00dd)	12298	221	0	0	0	0	ST	1	3-2006	\N	Bolus Description	t	\N	f	\N	\N
(300a,00f3)	12298	243	0	0	0	0	FL	1	3-2006	\N	Total Block Tray Water-Equivalent Thickness	t	\N	f	\N	\N
(300a,00f7)	12298	247	0	0	0	0	FL	1	3-2006	\N	Isocenter to Block Tray Distance	t	\N	f	\N	\N
(300a,00f9)	12298	249	0	0	0	0	LO	1	3-2006	\N	Accessory Code	t	\N	f	\N	\N
(300a,00fb)	12298	251	0	0	0	0	CS	1	3-2006	\N	Block Mounting Position	t	\N	f	\N	\N
(300a,0140)	12298	320	0	0	0	0	FL	1	3-2006	\N	Table Top Pitch Angle	t	\N	f	\N	\N
(300a,0142)	12298	322	0	0	0	0	CS	1	3-2006	\N	Table Top Pitch Rotation Direction	t	\N	f	\N	\N
(300a,0144)	12298	324	0	0	0	0	FL	1	3-2006	\N	Table Top Roll Angle	t	\N	f	\N	\N
(300a,0146)	12298	326	0	0	0	0	CS	1	3-2006	\N	Table Top Roll Rotation Direction	t	\N	f	\N	\N
(300a,0148)	12298	328	0	0	0	0	FL	1	3-2006	\N	Head Fixation Angle	t	\N	f	\N	\N
(300a,014a)	12298	330	0	0	0	0	FL	1	3-2006	\N	Gantry Pitch Angle	t	\N	f	\N	\N
(300a,014c)	12298	332	0	0	0	0	CS	1	3-2006	\N	Gantry Pitch Rotation Direction	t	\N	f	\N	\N
(300a,0183)	12298	387	0	0	0	0	LO	1	3-2006	\N	Patient Setup Label	t	\N	f	\N	\N
(300a,0199)	12298	409	0	0	0	0	FL	1	3-2006	\N	Fixation Device Pitch Angle	t	\N	f	\N	\N
(300a,019a)	12298	410	0	0	0	0	FL	1	3-2006	\N	Fixation Device Roll Angle	t	\N	f	\N	\N
(300a,0229)	12298	553	0	0	0	0	CS	1	3-2006	\N	Source Strength Units	t	\N	f	\N	\N
(300a,022b)	12298	555	0	0	0	0	DS	1	3-2006	\N	Source Strength	t	\N	f	\N	\N
(300a,02e0)	12298	736	0	0	0	0	CS	1	3-2006	\N	Compensator Divergence	t	\N	f	\N	\N
(300a,02e1)	12298	737	0	0	0	0	CS	1	3-2006	\N	Compensator Mounting Position	t	\N	f	\N	\N
(300a,02e2)	12298	738	0	0	0	0	DS	1-n	3-2006	\N	Source to Compensator Distance	t	\N	f	\N	\N
(300a,02e3)	12298	739	0	0	0	0	FL	1	3-2006	\N	Total Compensator Tray Water-Equivalent Thickness	t	\N	f	\N	\N
(300a,02e4)	12298	740	0	0	0	0	FL	1	3-2006	\N	Isocenter to Compensator Tray Distance	t	\N	f	\N	\N
(300a,02e5)	12298	741	0	0	0	0	FL	1	3-2006	\N	Compensator Column Offset	t	\N	f	\N	\N
(300a,02e6)	12298	742	0	0	0	0	FL	1-n	3-2006	\N	Isocenter to Compensator Distances	t	\N	f	\N	\N
(300a,02e7)	12298	743	0	0	0	0	FL	1	3-2006	\N	Compensator Relative Stopping Power Ratio	t	\N	f	\N	\N
(300a,02e8)	12298	744	0	0	0	0	FL	1	3-2006	\N	Compensator Milling Tool Diameter	t	\N	f	\N	\N
(300a,02ea)	12298	746	0	0	0	0	SQ	1	3-2006	\N	Ion Range Compensator Sequence	t	\N	f	\N	\N
(300a,0302)	12298	770	0	0	0	0	IS	1	3-2006	\N	Radiation Mass Number	t	\N	f	\N	\N
(300a,0304)	12298	772	0	0	0	0	IS	1	3-2006	\N	Radiation Atomic Number	t	\N	f	\N	\N
(300a,0306)	12298	774	0	0	0	0	SS	1	3-2006	\N	Radiation Charge State	t	\N	f	\N	\N
(300a,0308)	12298	776	0	0	0	0	CS	1	3-2006	\N	Scan Mode	t	\N	f	\N	\N
(300a,030a)	12298	778	0	0	0	0	FL	2	3-2006	\N	Virtual Source-Axis Distances	t	\N	f	\N	\N
(300a,030c)	12298	780	0	0	0	0	SQ	1	3-2006	\N	Snout Sequence	t	\N	f	\N	\N
(300a,030d)	12298	781	0	0	0	0	FL	1	3-2006	\N	Snout Position	t	\N	f	\N	\N
(300a,030f)	12298	783	0	0	0	0	SH	1	3-2006	\N	Snout ID	t	\N	f	\N	\N
(300a,0312)	12298	786	0	0	0	0	IS	1	3-2006	\N	Number of Range Shifters	t	\N	f	\N	\N
(300a,0314)	12298	788	0	0	0	0	SQ	1	3-2006	\N	Range Shifter Sequence	t	\N	f	\N	\N
(300a,0316)	12298	790	0	0	0	0	IS	1	3-2006	\N	Range Shifter Number	t	\N	f	\N	\N
(300a,0318)	12298	792	0	0	0	0	SH	1	3-2006	\N	Range Shifter ID	t	\N	f	\N	\N
(300a,0320)	12298	800	0	0	0	0	CS	1	3-2006	\N	Range Shifter Type	t	\N	f	\N	\N
(300a,0322)	12298	802	0	0	0	0	LO	1	3-2006	\N	Range Shifter Description	t	\N	f	\N	\N
(300a,0330)	12298	816	0	0	0	0	IS	1	3-2006	\N	Number of Lateral Spreading Devices	t	\N	f	\N	\N
(300a,0332)	12298	818	0	0	0	0	SQ	1	3-2006	\N	Lateral Spreading Device Sequence	t	\N	f	\N	\N
(300a,0334)	12298	820	0	0	0	0	IS	1	3-2006	\N	Lateral Spreading Device Number	t	\N	f	\N	\N
(300a,0336)	12298	822	0	0	0	0	SH	1	3-2006	\N	Lateral Spreading Device ID	t	\N	f	\N	\N
(300a,0338)	12298	824	0	0	0	0	CS	1	3-2006	\N	Lateral Spreading Device Type	t	\N	f	\N	\N
(300a,033a)	12298	826	0	0	0	0	LO	1	3-2006	\N	Lateral Spreading Device Description	t	\N	f	\N	\N
(300a,033c)	12298	828	0	0	0	0	FL	1	3-2006	\N	Lateral Spreading Device Water Equivalent Thickness	t	\N	f	\N	\N
(300a,0340)	12298	832	0	0	0	0	IS	1	3-2006	\N	Number of Range Modulators	t	\N	f	\N	\N
(300a,0342)	12298	834	0	0	0	0	SQ	1	3-2006	\N	Range Modulator Sequence	t	\N	f	\N	\N
(300a,0344)	12298	836	0	0	0	0	IS	1	3-2006	\N	Range Modulator Number	t	\N	f	\N	\N
(300a,0346)	12298	838	0	0	0	0	SH	1	3-2006	\N	Range Modulator ID	t	\N	f	\N	\N
(300a,0348)	12298	840	0	0	0	0	CS	1	3-2006	\N	Range Modulator Type	t	\N	f	\N	\N
(300a,034a)	12298	842	0	0	0	0	LO	1	3-2006	\N	Range Modulator Description	t	\N	f	\N	\N
(300a,034c)	12298	844	0	0	0	0	SH	1	3-2006	\N	Beam Current Modulation ID	t	\N	f	\N	\N
(300a,0350)	12298	848	0	0	0	0	CS	1	3-2006	\N	Patient Support Type	t	\N	f	\N	\N
(300a,0352)	12298	850	0	0	0	0	SH	1	3-2006	\N	Patient Support ID	t	\N	f	\N	\N
(300a,0354)	12298	852	0	0	0	0	LO	1	3-2006	\N	Patient Support Accessory Code	t	\N	f	\N	\N
(300a,0356)	12298	854	0	0	0	0	FL	1	3-2006	\N	Fixation Light Azimuthal Angle	t	\N	f	\N	\N
(300a,0358)	12298	856	0	0	0	0	FL	1	3-2006	\N	Fixation Light Polar Angle	t	\N	f	\N	\N
(300a,035a)	12298	858	0	0	0	0	FL	1	3-2006	\N	Meterset Rate	t	\N	f	\N	\N
(300a,0360)	12298	864	0	0	0	0	SQ	1	3-2006	\N	Range Shifter Settings Sequence	t	\N	f	\N	\N
(300a,0362)	12298	866	0	0	0	0	LO	1	3-2006	\N	Range Shifter Setting	t	\N	f	\N	\N
(300a,0364)	12298	868	0	0	0	0	FL	1	3-2006	\N	Isocenter to Range Shifter Distance	t	\N	f	\N	\N
(300a,0366)	12298	870	0	0	0	0	FL	1	3-2006	\N	Range Shifter Water Equivalent Thickness	t	\N	f	\N	\N
(300a,0370)	12298	880	0	0	0	0	SQ	1	3-2006	\N	Lateral Spreading Device Settings Sequence	t	\N	f	\N	\N
(300a,0372)	12298	882	0	0	0	0	LO	1	3-2006	\N	Lateral Spreading Device Setting	t	\N	f	\N	\N
(300a,0374)	12298	884	0	0	0	0	FL	1	3-2006	\N	Isocenter to Lateral Spreading Device Distance	t	\N	f	\N	\N
(300a,0380)	12298	896	0	0	0	0	SQ	1	3-2006	\N	Range Modulator Settings Sequence	t	\N	f	\N	\N
(300a,0382)	12298	898	0	0	0	0	FL	1	3-2006	\N	Range Modulator Gating Start Value	t	\N	f	\N	\N
(300a,0384)	12298	900	0	0	0	0	FL	1	3-2006	\N	Range Modulator Gating Stop Value	t	\N	f	\N	\N
(300a,0386)	12298	902	0	0	0	0	FL	1	3-2006	\N	Range Modulator Gating Start Water Equivalent Thickness	t	\N	f	\N	\N
(300a,0388)	12298	904	0	0	0	0	FL	1	3-2006	\N	Range Modulator Gating Stop Water Equivalent Thickness	t	\N	f	\N	\N
(300a,038a)	12298	906	0	0	0	0	FL	1	3-2006	\N	Isocenter to Range Modulator Distance	t	\N	f	\N	\N
(300a,0390)	12298	912	0	0	0	0	SH	1	3-2006	\N	Scan Spot Tune ID	t	\N	f	\N	\N
(300a,0392)	12298	914	0	0	0	0	IS	1	3-2006	\N	Number of Scan Spot Positions	t	\N	f	\N	\N
(300a,0394)	12298	916	0	0	0	0	FL	1-n	3-2006	\N	Scan Spot Position Map	t	\N	f	\N	\N
(300a,0396)	12298	918	0	0	0	0	FL	1-n	3-2006	\N	Scan Spot Meterset Weights	t	\N	f	\N	\N
(300a,0398)	12298	920	0	0	0	0	FL	2	3-2006	\N	Scanning Spot Size	t	\N	f	\N	\N
(300a,039a)	12298	922	0	0	0	0	IS	1	3-2006	\N	Number of Paintings	t	\N	f	\N	\N
(300a,03a0)	12298	928	0	0	0	0	SQ	1	3-2006	\N	Ion Tolerance Table Sequence	t	\N	f	\N	\N
(300a,03a2)	12298	930	0	0	0	0	SQ	1	3-2006	\N	Ion Beam Sequence	t	\N	f	\N	\N
(300a,03a4)	12298	932	0	0	0	0	SQ	1	3-2006	\N	Ion Beam Limiting Device Sequence	t	\N	f	\N	\N
(300a,03a6)	12298	934	0	0	0	0	SQ	1	3-2006	\N	Ion Block Sequence	t	\N	f	\N	\N
(300a,03a8)	12298	936	0	0	0	0	SQ	1	3-2006	\N	Ion Control Point Sequence	t	\N	f	\N	\N
(300a,03aa)	12298	938	0	0	0	0	SQ	1	3-2006	\N	Ion Wedge Sequence	t	\N	f	\N	\N
(300a,03ac)	12298	940	0	0	0	0	SQ	1	3-2006	\N	Ion Wedge Position Sequence	t	\N	f	\N	\N
(300a,0401)	12298	1025	0	0	0	0	SQ	1	3-2006	\N	Referenced Image Setup Sequence	t	\N	f	\N	\N
(300a,0402)	12298	1026	0	0	0	0	ST	1	3-2006	\N	Setup Image Comment	t	\N	f	\N	\N
(300c,00f2)	12300	242	0	0	0	0	SQ	1	3-2006	\N	Referenced Control Point Sequence	t	\N	f	\N	\N
(300c,00f4)	12300	244	0	0	0	0	IS	1	3-2006	\N	Referenced Start Control Point Index	t	\N	f	\N	\N
(300c,00f6)	12300	246	0	0	0	0	IS	1	3-2006	\N	Referenced Stop Control Point Index	t	\N	f	\N	\N
(300c,0100)	12300	256	0	0	0	0	IS	1	3-2006	\N	Referenced Range Shifter Number	t	\N	f	\N	\N
(300c,0102)	12300	258	0	0	0	0	IS	1	3-2006	\N	Referenced Lateral Spreading Device Number	t	\N	f	\N	\N
(300c,0104)	12300	260	0	0	0	0	IS	1	3-2006	\N	Referenced Range Modulator Number	t	\N	f	\N	\N
(0000,0000)	0	0	0	0	0	0	UL	1	3	\N	Group Length	t	f	f	\N	\N
(0000,0002)	0	2	0	0	0	0	UI	1	3	\N	Affected SOP Class UID	t	f	f	\N	\N
(0000,0003)	0	3	0	0	0	0	UI	1	3	\N	Requested SOP Class UID	t	f	f	\N	\N
(0000,0100)	0	256	0	0	0	0	US	1	3	\N	Command Field	t	f	f	\N	\N
(0000,0110)	0	272	0	0	0	0	US	1	3	\N	Message ID	t	f	f	\N	\N
(0000,0120)	0	288	0	0	0	0	US	1	3	\N	Message ID Being Responded To	t	f	f	\N	\N
(0000,0600)	0	1536	0	0	0	0	AE	1	3	\N	Move Destination	t	f	f	\N	\N
(0000,0700)	0	1792	0	0	0	0	US	1	3	\N	Priority	t	f	f	\N	\N
(0000,0800)	0	2048	0	0	0	0	US	1	3	\N	Data Set Type	t	f	f	\N	\N
(0000,0900)	0	2304	0	0	0	0	US	1	3	\N	Status	t	f	f	\N	\N
(0000,0901)	0	2305	0	0	0	0	AT	1-n	3	\N	Offending Element	t	f	f	\N	\N
(0000,0902)	0	2306	0	0	0	0	LO	1	3	\N	Error Comment	t	f	f	\N	\N
(0000,0903)	0	2307	0	0	0	0	US	1	3	\N	Error ID	t	f	f	\N	\N
(0000,1000)	0	4096	0	0	0	0	UI	1	3	\N	Affected SOP Instance UID	t	f	f	\N	\N
(0000,1001)	0	4097	0	0	0	0	UI	1	3	\N	Requested SOP Instance UID	t	f	f	\N	\N
(0000,1002)	0	4098	0	0	0	0	US	1	3	\N	Event Type ID	t	f	f	\N	\N
(0000,1005)	0	4101	0	0	0	0	AT	1-n	3	\N	Attribute Identifier List	t	f	f	\N	\N
(0000,1008)	0	4104	0	0	0	0	US	1	3	\N	Action Type ID	t	f	f	\N	\N
(0000,1020)	0	4128	0	0	0	0	US	1	3	\N	Number of Remaining Suboperations	t	f	f	\N	\N
(0000,1021)	0	4129	0	0	0	0	US	1	3	\N	Number of Completed Suboperations	t	f	f	\N	\N
(0000,1022)	0	4130	0	0	0	0	US	1	3	\N	Number of Failed Suboperations	t	f	f	\N	\N
(0000,1023)	0	4131	0	0	0	0	US	1	3	\N	Number of Warning Suboperations	t	f	f	\N	\N
(0000,1030)	0	4144	0	0	0	0	AE	1	3	\N	Move Originator Application Entity Title	t	f	f	\N	\N
(0002,0000)	2	0	0	0	0	0	UL	1	3	\N	Meta Element Group Length	t	f	f	\N	\N
(0002,0001)	2	1	0	0	0	0	OB	1	3	\N	File Meta Information Version	t	f	f	\N	\N
(0002,0002)	2	2	0	0	0	0	UI	1	3	\N	Media Storage SOP Class UID	t	f	f	\N	\N
(0002,0003)	2	3	0	0	0	0	UI	1	3	\N	Media Storage SOP Instance UID	t	f	f	\N	\N
(0002,0010)	2	16	0	0	0	0	UI	1	3	\N	Transfer Syntax UID	t	f	f	\N	\N
(0002,0012)	2	18	0	0	0	0	UI	1	3	\N	Implementation Class UID	t	f	f	\N	\N
(0002,0013)	2	19	0	0	0	0	SH	1	3	\N	Implementation Version Name	t	f	f	\N	\N
(0002,0016)	2	22	0	0	0	0	AE	1	3	\N	Source Application Entity Title	t	f	f	\N	\N
(0002,0100)	2	256	0	0	0	0	UI	1	3	\N	Private Information Creator UID	t	f	f	\N	\N
(0002,0102)	2	258	0	0	0	0	OB	1	3	\N	Private Information	t	f	f	\N	\N
(0004,0000)	4	0	0	0	0	0	UL	1	3	\N	File Set Group Length	t	f	f	\N	\N
(0004,1130)	4	4400	0	0	0	0	CS	1	3	\N	File Set ID	t	f	f	\N	\N
(0004,1141)	4	4417	0	0	0	0	CS	1-8	3	\N	File Set Descriptor File ID	t	f	f	\N	\N
(0004,1142)	4	4418	0	0	0	0	CS	1	3	\N	File Set Descriptor File Specific Character Set	t	f	f	\N	\N
(0004,1200)	4	4608	0	0	0	0	UL	1	3	\N	Root Directory Entity First Directory Record Offset	t	f	f	\N	\N
(0004,1202)	4	4610	0	0	0	0	UL	1	3	\N	Root Directory Entity Last Directory Record Offset	t	f	f	\N	\N
(0004,1212)	4	4626	0	0	0	0	US	1	3	\N	File Set Consistency Flag	t	f	f	\N	\N
(0004,1220)	4	4640	0	0	0	0	SQ	1	3	\N	Directory Record Sequence	t	f	f	\N	\N
(0004,1400)	4	5120	0	0	0	0	UL	1	3	\N	Next Directory Record Offset	t	f	f	\N	\N
(0004,1410)	4	5136	0	0	0	0	US	1	3	\N	Record In Use Flag	t	f	f	\N	\N
(0004,1420)	4	5152	0	0	0	0	UL	1	3	\N	Referenced Lower Level Directory Entity Offset	t	f	f	\N	\N
(0004,1430)	4	5168	0	0	0	0	CS	1	3	\N	Directory Record Type	t	f	f	\N	\N
(0004,1432)	4	5170	0	0	0	0	UI	1	3	\N	Private Record UID	t	f	f	\N	\N
(0004,1500)	4	5376	0	0	0	0	CS	1-8	3	\N	Referenced File ID	t	f	f	\N	\N
(0004,1504)	4	5380	0	0	0	0	UL	1	3	\N	MRDR Directory Record Offset	t	f	f	\N	\N
(0004,1510)	4	5392	0	0	0	0	UI	1	3	\N	Referenced SOP Class UID In File	t	f	f	\N	\N
(0004,1511)	4	5393	0	0	0	0	UI	1	3	\N	Referenced SOP Instance UID In File	t	f	f	\N	\N
(0004,1512)	4	5394	0	0	0	0	UI	1	3	\N	Referenced Transfer Syntax UID In File	t	f	f	\N	\N
(0004,1600)	4	5632	0	0	0	0	UL	1	3	\N	Number of References	t	f	f	\N	\N
(0004,151a)	4	5402	0	0	0	0	UI	1-n  	3-2006	\N	Referenced Related General SOP Class UID in File	t	\N	f	\N	\N
(0000,0001)	0	1	0	0	0	0	UL	1	2	\N	Command Length to End	t	f	t	\N	\N
(0000,0010)	0	16	0	0	0	0	LT	1	2	\N	Command Recognition Code	t	f	t	\N	\N
(0000,0200)	0	512	0	0	0	0	AE	1	2	\N	Initiator	t	f	t	\N	\N
(0000,0300)	0	768	0	0	0	0	AE	1	2	\N	Receiver	t	f	t	\N	\N
(0000,0400)	0	1024	0	0	0	0	AE	1	2	\N	Find Location	t	f	t	\N	\N
(0000,0850)	0	2128	0	0	0	0	US	1	2	\N	Number of Matches	t	f	t	\N	\N
(0000,0860)	0	2144	0	0	0	0	US	1	2	\N	Response Sequence Number	t	f	t	\N	\N
(0000,4000)	0	16384	0	0	0	0	LT	1	2	\N	Dialog Receiver	t	f	t	\N	\N
(0000,4010)	0	16400	0	0	0	0	LT	1	2	\N	Terminal Type	t	f	t	\N	\N
(0000,5010)	0	20496	0	0	0	0	SH	1	3	\N	Message Set ID	t	f	t	\N	\N
(0000,5020)	0	20512	0	0	0	0	SH	1	3	\N	End Message Set	t	f	t	\N	\N
(0000,5110)	0	20752	0	0	0	0	LT	1	2	\N	Display Format	t	f	t	\N	\N
(0000,5120)	0	20768	0	0	0	0	LT	1	2	\N	Page Position ID	t	f	t	\N	\N
(0000,5130)	0	20784	0	0	0	0	LT	1	2	\N	Text Format ID	t	f	t	\N	\N
(0000,5140)	0	20800	0	0	0	0	LT	1	2	\N	Normal Reverse	t	f	t	\N	\N
(0000,5150)	0	20816	0	0	0	0	LT	1	2	\N	Add Gray Scale	t	f	t	\N	\N
(0000,5160)	0	20832	0	0	0	0	LT	1	2	\N	Borders	t	f	t	\N	\N
(0000,5170)	0	20848	0	0	0	0	IS	1	2	\N	Copies	t	f	t	\N	\N
(0000,5180)	0	20864	0	0	0	0	LT	1	2	\N	Old Magnification Type	t	f	t	\N	\N
(0000,5190)	0	20880	0	0	0	0	LT	1	2	\N	Erase	t	f	t	\N	\N
(0000,51a0)	0	20896	0	0	0	0	LT	1	2	\N	Print	t	f	t	\N	\N
(0000,51b0)	0	20912	0	0	0	0	US	1-n	2	\N	Overlays	t	f	t	\N	\N
(0008,0001)	8	1	0	0	0	0	UL	1	2	\N	Length to End	t	f	t	\N	\N
(0008,0024)	8	36	0	0	0	0	DA	1	3	\N	Overlay Date	t	f	t	\N	\N
(0008,0025)	8	37	0	0	0	0	DA	1	3	\N	Curve Date	t	f	t	\N	\N
(0008,0034)	8	52	0	0	0	0	TM	1	3	\N	Overlay Time	t	f	t	\N	\N
(0008,0035)	8	53	0	0	0	0	TM	1	3	\N	Curve Time	t	f	t	\N	\N
(0008,0040)	8	64	0	0	0	0	US	1	2	\N	Old Data Set Type	t	f	t	\N	\N
(0008,0041)	8	65	0	0	0	0	LO	1	2	\N	Old Data Set Subtype	t	f	t	\N	\N
(0008,0042)	8	66	0	0	0	0	CS	1	3RET	\N	Nuclear Medicine Series Type {Retired)	t	f	t	\N	\N
(0008,1100)	8	4352	0	0	0	0	SQ	1	3	\N	Referenced Results Sequence	t	f	t	\N	\N
(0008,1130)	8	4400	0	0	0	0	SQ	1	3	\N	Referenced Overlay Sequence	t	f	t	\N	\N
(0008,1145)	8	4421	0	0	0	0	SQ	1	3	\N	Referenced Curve Sequence	t	f	t	\N	\N
(0008,2110)	8	8464	0	0	0	0	CS	1	3RET	\N	Old Lossy Image Compression	t	f	t	\N	\N
(0008,2200)	8	8704	0	0	0	0	CS	1	3RET	\N	Transducer Position	t	f	t	\N	\N
(0008,2204)	8	8708	0	0	0	0	CS	1	3RET	\N	Transducer Orientation	t	f	t	\N	\N
(0008,2208)	8	8712	0	0	0	0	CS	1	3RET	\N	Anatomic Structure	t	f	t	\N	\N
(0008,2240)	8	8768	0	0	0	0	SQ	1	3	\N	Transducer Position Sequence	t	f	t	\N	\N
(0008,2242)	8	8770	0	0	0	0	SQ	1	3	\N	Transducer Position Modifier Sequence	t	f	t	\N	\N
(0008,2244)	8	8772	0	0	0	0	SQ	1	3	\N	Transducer Orientation Sequence	t	f	t	\N	\N
(0008,2246)	8	8774	0	0	0	0	SQ	1	3	\N	Transducer Orientation Modifier Sequence	t	f	t	\N	\N
(0008,4000)	8	16384	0	0	0	0	LT	1-n	2	\N	Identifying Comments	t	f	t	\N	\N
(0018,0030)	24	48	0	0	0	0	LO	1-n	3RET	\N	Radionuclide	t	f	t	\N	\N
(0018,0032)	24	50	0	0	0	0	DS	1	3RET	\N	Energy Window Centerline	t	f	t	\N	\N
(0018,0033)	24	51	0	0	0	0	DS	1-n	3RET	\N	Energy Window Total Width	t	f	t	\N	\N
(0018,0037)	24	55	0	0	0	0	CS	1	3	\N	Therapy Type	t	f	t	\N	\N
(0018,0039)	24	57	0	0	0	0	CS	1	3	\N	Therapy Description	t	f	t	\N	\N
(0018,1146)	24	4422	0	0	0	0	DS	1-n	3RET	\N	Rotation Offset	t	f	t	\N	\N
(0018,1240)	24	4672	0	0	0	0	IS	1-n	2	\N	Upper/Lower Pixel Values	t	f	t	\N	\N
(0018,5030)	24	20528	0	0	0	0	DS	1	2	\N	Dynamic Range	t	f	t	\N	\N
(0018,5040)	24	20544	0	0	0	0	DS	1	2	\N	Total Gain	t	f	t	\N	\N
(0018,5210)	24	21008	0	0	0	0	DS	6	3	\N	Image Transformation Matrix	t	f	t	\N	\N
(0018,5212)	24	21010	0	0	0	0	DS	3	3	\N	Image Translation Vector	t	f	t	\N	\N
(0018,6038)	24	24632	0	0	0	0	UL	1	3	\N	Doppler Sample Volume X Position	t	f	t	\N	\N
(0018,603a)	24	24634	0	0	0	0	UL	1	3	\N	Doppler Sample Volume Y Position	t	f	t	\N	\N
(0018,603c)	24	24636	0	0	0	0	UL	1	3	\N	TM-Line Position X0	t	f	t	\N	\N
(0018,603e)	24	24638	0	0	0	0	UL	1	3	\N	TM-Line Position Y0	t	f	t	\N	\N
(0018,6040)	24	24640	0	0	0	0	UL	1	3	\N	TM-Line Position X1	t	f	t	\N	\N
(0018,6042)	24	24642	0	0	0	0	UL	1	3	\N	TM-Line Position Y1	t	f	t	\N	\N
(0018,9195)	24	37269	0	0	0	0	FD	1	3MR	\N	Chemical Shift Minimum Integration Limit	t	f	t	\N	\N
(0018,9196)	24	37270	0	0	0	0	FD	1	3MR	\N	Chemical Shift Maximum Integration Limit	t	f	t	\N	\N
(0020,0014)	32	20	0	0	0	0	IS	1	3RET	\N	Isotope Number	t	f	t	\N	\N
(0020,0015)	32	21	0	0	0	0	IS	1	3RET	\N	Phase Number	t	f	t	\N	\N
(0020,0016)	32	22	0	0	0	0	IS	1	3RET	\N	Interval Number	t	f	t	\N	\N
(0020,0017)	32	23	0	0	0	0	IS	1	3RET	\N	Time Slot Number	t	f	t	\N	\N
(0020,0018)	32	24	0	0	0	0	IS	1	3RET	\N	Angle Number	t	f	t	\N	\N
(0020,0022)	32	34	0	0	0	0	IS	1	3	\N	Overlay Number	t	f	t	\N	\N
(0020,0024)	32	36	0	0	0	0	IS	1	3	\N	Curve Number	t	f	t	\N	\N
(0020,0026)	32	38	0	0	0	0	IS	1	3	\N	LUT Number	t	f	t	\N	\N
(0020,0030)	32	48	0	0	0	0	DS	3	2	\N	Image Position	t	f	t	\N	\N
(0020,0035)	32	53	0	0	0	0	DS	6	2	\N	Image Orientation	t	f	t	\N	\N
(0020,0050)	32	80	0	0	0	0	DS	1	2	\N	Location	t	f	t	\N	\N
(0020,1000)	32	4096	0	0	0	0	IS	1	3	\N	Series in Study	t	f	t	\N	\N
(0020,1001)	32	4097	0	0	0	0	IS	1	2	\N	Acquisitions in Series	t	f	t	\N	\N
(0020,1004)	32	4100	0	0	0	0	IS	1	3	\N	Acquisitions in Study	t	f	t	\N	\N
(0020,1070)	32	4208	0	0	0	0	IS	1-n	3	\N	Other Study Numbers	t	f	t	\N	\N
(0020,3403)	32	13315	0	0	0	0	DA	1	2	\N	Modified Image Date	t	f	t	\N	\N
(0020,3405)	32	13317	0	0	0	0	TM	1	2	\N	Modified Image Time	t	f	t	\N	\N
(0020,5000)	32	20480	0	0	0	0	AT	1-n	2	\N	Original Image Identification	t	f	t	\N	\N
(0028,0005)	40	5	0	0	0	0	US	1	2	\N	Image Dimensions	t	f	t	\N	\N
(0028,0050)	40	80	0	0	0	0	LO	1-n	2	\N	Manipulated Image	t	f	t	\N	\N
(0028,0104)	40	260	0	0	0	0	OT	1	2	\N	Smallest Valid Pixel Value	t	f	t	\N	\N
(0028,0105)	40	261	0	0	0	0	OT	1	2	\N	Largest Valid Pixel Value	t	f	t	\N	\N
(0028,0200)	40	512	0	0	0	0	US	1	2	\N	Image Location	t	f	t	\N	\N
(0028,1100)	40	4352	0	0	0	0	OT	3	2	\N	Gray Lookup Table Descriptor	t	f	t	\N	\N
(0028,4000)	40	16384	0	0	0	0	LT	1-n	2	\N	Image Presentation Comments	t	f	t	\N	\N
(0028,6030)	40	24624	0	0	0	0	US	1-n	3	\N	Mask Pointer	t	f	t	\N	\N
(0028,9099)	40	37017	0	0	0	0	US	1	3MR	\N	Largest Monochrome Pixel Value	t	f	t	\N	\N
(0032,000a)	50	10	0	0	0	0	CS	1	3	\N	Study Status ID	t	f	t	\N	\N
(0032,000c)	50	12	0	0	0	0	CS	1	3	\N	Study Priority ID	t	f	t	\N	\N
(0032,0012)	50	18	0	0	0	0	LO	1	3	\N	Study ID Issuer	t	f	t	\N	\N
(0032,0032)	50	50	0	0	0	0	DA	1	3	\N	Study Verified Date	t	f	t	\N	\N
(0032,0033)	50	51	0	0	0	0	TM	1	3	\N	Study Verified Time	t	f	t	\N	\N
(0032,0034)	50	52	0	0	0	0	DA	1	3	\N	Study Read Date	t	f	t	\N	\N
(0032,0035)	50	53	0	0	0	0	TM	1	3	\N	Study Read Time	t	f	t	\N	\N
(0032,1000)	50	4096	0	0	0	0	DA	1	3	\N	Scheduled Study Start Date	t	f	t	\N	\N
(0032,1001)	50	4097	0	0	0	0	TM	1	3	\N	Scheduled Study Start Time	t	f	t	\N	\N
(0032,1010)	50	4112	0	0	0	0	DA	1	3	\N	Scheduled Study Stop Date	t	f	t	\N	\N
(0032,1011)	50	4113	0	0	0	0	TM	1	3	\N	Scheduled Study Stop Time	t	f	t	\N	\N
(0032,1020)	50	4128	0	0	0	0	LO	1	3	\N	Scheduled Study Location	t	f	t	\N	\N
(0032,1021)	50	4129	0	0	0	0	AE	1-n	3	\N	Scheduled Study Location AE Title(s)	t	f	t	\N	\N
(0032,1030)	50	4144	0	0	0	0	LO	1	3	\N	Reason for Study	t	f	t	\N	\N
(0032,1040)	50	4160	0	0	0	0	DA	1	3	\N	Study Arrival Date	t	f	t	\N	\N
(0032,1041)	50	4161	0	0	0	0	TM	1	3	\N	Study Arrival Time	t	f	t	\N	\N
(0032,1050)	50	4176	0	0	0	0	DA	1	3	\N	Study Completion Date	t	f	t	\N	\N
(0032,1051)	50	4177	0	0	0	0	TM	1	3	\N	Study Completion Time	t	f	t	\N	\N
(0032,1055)	50	4181	0	0	0	0	CS	1	3	\N	Study Component Status ID	t	f	t	\N	\N
(0038,001a)	56	26	0	0	0	0	DA	1	3	\N	Scheduled Admission Date	t	f	t	\N	\N
(0038,001b)	56	27	0	0	0	0	TM	1	3	\N	Scheduled Admission Time	t	f	t	\N	\N
(0038,001c)	56	28	0	0	0	0	DA	1	3	\N	Scheduled Discharge Date	t	f	t	\N	\N
(0038,001d)	56	29	0	0	0	0	TM	1	3	\N	Scheduled Discharge Time	t	f	t	\N	\N
(0038,001e)	56	30	0	0	0	0	LO	1	3	\N	Scheduled Patient Institution Residence	t	f	t	\N	\N
(0038,0030)	56	48	0	0	0	0	DA	1	3	\N	Discharge Date	t	f	t	\N	\N
(0038,0032)	56	50	0	0	0	0	TM	1	3	\N	Discharge Time	t	f	t	\N	\N
(0038,0040)	56	64	0	0	0	0	LO	1	3	\N	Discharge Diagnosis Description	t	f	t	\N	\N
(0038,0044)	56	68	0	0	0	0	SQ	1	3	\N	Discharge Diagnosis Code Sequence	t	f	t	\N	\N
(0040,0307)	64	775	0	0	0	0	DS	1	3DX	\N	Distance Source to Support	t	f	t	\N	\N
(0040,0330)	64	816	0	0	0	0	SQ	1	3PPS	\N	Referenced Procedure Step Sequence	t	f	t	\N	\N
(0040,1006)	64	4102	0	0	0	0	SH	1	3RET	\N	Placer Order Number of Procedure	t	f	t	\N	\N
(0040,1007)	64	4103	0	0	0	0	SH	1	3RET	\N	Filler Order Number of Procedure	t	f	t	\N	\N
(0040,2001)	64	8193	0	0	0	0	LO	1	3	\N	Reason For Imaging Service Request	t	f	t	\N	\N
(0040,2006)	64	8198	0	0	0	0	SH	1	3RET	\N	Placer Order Number of Imaging Service Request (Retired)	t	f	t	\N	\N
(0040,2007)	64	8199	0	0	0	0	SH	1	3RET	\N	Filler Order Number of Imaging Service Request (Retired)	t	f	t	\N	\N
(0040,db06)	64	56070	0	0	0	0	DT	1	3STR	\N	Template Version	t	f	t	\N	\N
(0040,db07)	64	56071	0	0	0	0	DT	1	3STR	\N	Template Local Version	t	f	t	\N	\N
(0040,db0b)	64	56075	0	0	0	0	CS	1	3STR	\N	Template Extension Flag	t	f	t	\N	\N
(0040,db0c)	64	56076	0	0	0	0	UI	1	3STR	\N	Template Extension Organization UID	t	f	t	\N	\N
(0040,db0d)	64	56077	0	0	0	0	UI	1	3STR	\N	Template Extension Creator UID	t	f	t	\N	\N
(0070,0067)	112	103	0	0	0	0	US	3	3SCP	\N	Graphic Layer Recommended Display RGB Value	t	f	t	\N	\N
(2000,0062)	8192	98	0	0	0	0	CS	1	3PCF	\N	Color Image Printing Flag	t	f	t	\N	\N
(2000,0063)	8192	99	0	0	0	0	CS	1	3PCF	\N	Collation Flag	t	f	t	\N	\N
(2000,0065)	8192	101	0	0	0	0	CS	1	3PCF	\N	Annotation Flag	t	f	t	\N	\N
(2000,0067)	8192	103	0	0	0	0	CS	1	3PCF	\N	Image Overlay Flag	t	f	t	\N	\N
(2000,0069)	8192	105	0	0	0	0	CS	1	3PCF	\N	Presentation LUT Flag	t	f	t	\N	\N
(2000,006a)	8192	106	0	0	0	0	CS	1	3PCF	\N	Image Box Presentation LUT Flag	t	f	t	\N	\N
(2020,0130)	8224	304	0	0	0	0	SQ	1	3RET	\N	Referenced Image Overlay Box Sequence	t	f	t	\N	\N
(2020,0140)	8224	320	0	0	0	0	SQ	1	3RET	\N	Referenced VOI LUT Box Sequence	t	f	t	\N	\N
(2040,0010)	8256	16	0	0	0	0	SQ	1	3	\N	Referenced Overlay Plane Sequence	t	f	t	\N	\N
(2040,0011)	8256	17	0	0	0	0	US	1-99	3	\N	Referenced Overlay Plane Groups	t	f	t	\N	\N
(2040,0020)	8256	32	0	0	0	0	SQ	1	3OVL	\N	Overlay Pixel Data Sequence	t	f	t	\N	\N
(2040,0060)	8256	96	0	0	0	0	CS	1	3	\N	Overlay Magnification Type	t	f	t	\N	\N
(2040,0070)	8256	112	0	0	0	0	CS	1	3	\N	Overlay Smoothing Type	t	f	t	\N	\N
(2040,0072)	8256	114	0	0	0	0	CS	1	3	\N	Overlay Or Image Magnification	t	f	t	\N	\N
(2040,0074)	8256	116	0	0	0	0	US	1	3	\N	Magnify to Number of Columns	t	f	t	\N	\N
(2040,0080)	8256	128	0	0	0	0	CS	1	3	\N	Overlay Foreground Density	t	f	t	\N	\N
(2040,0082)	8256	130	0	0	0	0	CS	1	3	\N	Overlay Background Density	t	f	t	\N	\N
(2040,0090)	8256	144	0	0	0	0	CS	1	3RET	\N	Overlay Mode	t	f	t	\N	\N
(2040,0100)	8256	256	0	0	0	0	CS	1	3RET	\N	Threshold Density	t	f	t	\N	\N
(2040,0500)	8256	1280	0	0	0	0	SQ	1	3RET	\N	Referenced Overlay Image Box Sequence	t	f	t	\N	\N
(2100,0500)	8448	1280	0	0	0	0	SQ	1	3STP	\N	Referenced Print Job Sequence (in Pull Request N-Action)	t	f	t	\N	\N
(2110,0099)	8464	153	0	0	0	0	SH	1	3	\N	Print Queue ID	t	f	t	\N	\N
(2120,0010)	8480	16	0	0	0	0	CS	1	3PQ	\N	Queue Status	t	f	t	\N	\N
(2120,0050)	8480	80	0	0	0	0	SQ	1	3PQ	\N	Print Job Description Sequence	t	f	t	\N	\N
(2120,0070)	8480	112	0	0	0	0	SQ	1	3PQ	\N	Referenced Print Job Sequence (in Queue Mx Module)	t	f	t	\N	\N
(2130,0010)	8496	16	0	0	0	0	SQ	1	3???	\N	Print Management Capabilities Sequence	t	f	t	\N	\N
(2130,0015)	8496	21	0	0	0	0	SQ	1	3???	\N	Printer Characteristics Sequence	t	f	t	\N	\N
(2130,0030)	8496	48	0	0	0	0	SQ	1	3???	\N	Film Box Content Sequence	t	f	t	\N	\N
(2130,0040)	8496	64	0	0	0	0	SQ	1	3???	\N	Image Box Content Sequence	t	f	t	\N	\N
(2130,0050)	8496	80	0	0	0	0	SQ	1	3???	\N	Annotation Content Sequence	t	f	t	\N	\N
(2130,0060)	8496	96	0	0	0	0	SQ	1	3???	\N	Image Overlay Box Content Sequence	t	f	t	\N	\N
(2130,0080)	8496	128	0	0	0	0	SQ	1	3???	\N	Presentation LUT Content Sequence	t	f	t	\N	\N
(2130,00a0)	8496	160	0	0	0	0	SQ	1	3???	\N	Proposed Study Sequence	t	f	t	\N	\N
(2130,00c0)	8496	192	0	0	0	0	SQ	1	3???	\N	Original Image Sequence	t	f	t	\N	\N
(4000,0010)	16384	16	0	0	0	0	LT	1-n	2	\N	Text Arbitrary	t	f	t	\N	\N
(4000,4000)	16384	16384	0	0	0	0	LT	1-n	2	\N	Text Comments	t	f	t	\N	\N
(4008,0040)	16392	64	0	0	0	0	SH	1	3	\N	Results ID	t	f	t	\N	\N
(4008,0042)	16392	66	0	0	0	0	LO	1	3	\N	Results ID Issuer	t	f	t	\N	\N
(4008,0050)	16392	80	0	0	0	0	SQ	1	3	\N	Referenced Interpretation Sequence	t	f	t	\N	\N
(4008,0100)	16392	256	0	0	0	0	DA	1	3	\N	Interpretation Recorded Date	t	f	t	\N	\N
(4008,0101)	16392	257	0	0	0	0	TM	1	3	\N	Interpretation Recorded Time	t	f	t	\N	\N
(4008,0102)	16392	258	0	0	0	0	PN	1	3	\N	Interpretation Recorder	t	f	t	\N	\N
(4008,0103)	16392	259	0	0	0	0	LO	1	3	\N	Reference to Recorded Sound	t	f	t	\N	\N
(4008,0108)	16392	264	0	0	0	0	DA	1	3	\N	Interpretation Transcription Date	t	f	t	\N	\N
(4008,0109)	16392	265	0	0	0	0	TM	1	3	\N	Interpretation Transcription Time	t	f	t	\N	\N
(4008,010a)	16392	266	0	0	0	0	PN	1	3	\N	Interpretation Transcriber	t	f	t	\N	\N
(4008,010b)	16392	267	0	0	0	0	ST	1	3	\N	Interpretation Text	t	f	t	\N	\N
(4008,010c)	16392	268	0	0	0	0	PN	1	3	\N	Interpretation Author	t	f	t	\N	\N
(4008,0111)	16392	273	0	0	0	0	SQ	1	3	\N	Interpretation Approver Sequence	t	f	t	\N	\N
(4008,0112)	16392	274	0	0	0	0	DA	1	3	\N	Interpretation Approval Date	t	f	t	\N	\N
(4008,0113)	16392	275	0	0	0	0	TM	1	3	\N	Interpretation Approval Time	t	f	t	\N	\N
(4008,0114)	16392	276	0	0	0	0	PN	1	3	\N	Physician Approving Interpretation	t	f	t	\N	\N
(4008,0115)	16392	277	0	0	0	0	LT	1	3	\N	Interpretation Diagnosis Description	t	f	t	\N	\N
(4008,0117)	16392	279	0	0	0	0	SQ	1	3	\N	Interpretation Diagnosis Code Sequence	t	f	t	\N	\N
(4008,0118)	16392	280	0	0	0	0	SQ	1	3	\N	Results Distribution List Sequence	t	f	t	\N	\N
(4008,0119)	16392	281	0	0	0	0	PN	1	3	\N	Distribution Name	t	f	t	\N	\N
(4008,011a)	16392	282	0	0	0	0	LO	1	3	\N	Distribution Address	t	f	t	\N	\N
(4008,0200)	16392	512	0	0	0	0	SH	1	3	\N	Interpretation ID	t	f	t	\N	\N
(4008,0202)	16392	514	0	0	0	0	LO	1	3	\N	Interpretation ID Issuer	t	f	t	\N	\N
(4008,0210)	16392	528	0	0	0	0	CS	1	3	\N	Interpretation Type ID	t	f	t	\N	\N
(4008,0212)	16392	530	0	0	0	0	CS	1	3	\N	Interpretation Status ID	t	f	t	\N	\N
(4008,0300)	16392	768	0	0	0	0	ST	1	3	\N	Impressions	t	f	t	\N	\N
(4008,4000)	16392	16384	0	0	0	0	ST	1	3	\N	Results Comments	t	f	t	\N	\N
(50xx,0005)	20480	5	65280	0	0	0	US	1	3	\N	Curve Dimensions	t	f	t	\N	\N
(50xx,0010)	20480	16	65280	0	0	0	US	1	3	\N	Number of Points	t	f	t	\N	\N
(50xx,0020)	20480	32	65280	0	0	0	CS	1	3	\N	Type of Data	t	f	t	\N	\N
(50xx,0022)	20480	34	65280	0	0	0	LO	1	3	\N	Curve Description	t	f	t	\N	\N
(50xx,0030)	20480	48	65280	0	0	0	SH	1-n	3	\N	Axis Units	t	f	t	\N	\N
(50xx,0040)	20480	64	65280	0	0	0	SH	1-n	3	\N	Axis Labels	t	f	t	\N	\N
(50xx,0103)	20480	259	65280	0	0	0	US	1	3	\N	Data Value Representation	t	f	t	\N	\N
(50xx,0104)	20480	260	65280	0	0	0	US	1-n	3	\N	Minimum Coordinate Value	t	f	t	\N	\N
(50xx,0105)	20480	261	65280	0	0	0	US	1-n	3	\N	Maximum Coordinate Value	t	f	t	\N	\N
(50xx,0106)	20480	262	65280	0	0	0	SH	1-n	3	\N	Curve Range	t	f	t	\N	\N
(50xx,0110)	20480	272	65280	0	0	0	US	1	3	\N	Curve Data Descriptor	t	f	t	\N	\N
(50xx,0112)	20480	274	65280	0	0	0	US	1	3	\N	Coordinate Start Value	t	f	t	\N	\N
(50xx,0114)	20480	276	65280	0	0	0	US	1	3	\N	Coordinate Step Value	t	f	t	\N	\N
(50xx,1001)	20480	4097	65280	0	0	0	CS	1	3SCP	\N	Curve Activation Layer	t	f	t	\N	\N
(50xx,2000)	20480	8192	65280	0	0	0	US	1	3	\N	Audio Type	t	f	t	\N	\N
(50xx,2002)	20480	8194	65280	0	0	0	US	1	3	\N	Audio Sample Format	t	f	t	\N	\N
(50xx,2004)	20480	8196	65280	0	0	0	US	1	3	\N	Number of Channels	t	f	t	\N	\N
(50xx,2006)	20480	8198	65280	0	0	0	UL	1	3	\N	Number of Samples	t	f	t	\N	\N
(50xx,2008)	20480	8200	65280	0	0	0	UL	1	3	\N	Sample Rate	t	f	t	\N	\N
(50xx,200a)	20480	8202	65280	0	0	0	UL	1	3	\N	Total Time	t	f	t	\N	\N
(50xx,200c)	20480	8204	65280	0	0	0	OT	1	3	\N	Audio Sample Data	t	f	t	\N	\N
(50xx,200e)	20480	8206	65280	0	0	0	LT	1	3	\N	Audio Comments	t	f	t	\N	\N
(50xx,2500)	20480	9472	65280	0	0	0	LO	1	3	\N	Curve Label	t	f	t	\N	\N
(50xx,2600)	20480	9728	65280	0	0	0	SQ	1	3	\N	CurveReferenced Overlay Sequence	t	f	t	\N	\N
(50xx,2610)	20480	9744	65280	0	0	0	US	1	3	\N	CurveReferenced Overlay Group	t	f	t	\N	\N
(50xx,3000)	20480	12288	65280	0	0	0	OT	1	3	\N	Curve Data	t	f	t	\N	\N
(60xx,0200)	24576	512	65280	0	0	0	US	1	2	\N	Overlay Location	t	f	t	\N	\N
(60xx,1100)	24576	4352	65280	0	0	0	US	1	3	\N	Overlay Descriptor - Gray	t	f	t	\N	\N
(60xx,1101)	24576	4353	65280	0	0	0	US	1	3	\N	Overlay Descriptor - Red	t	f	t	\N	\N
(60xx,1102)	24576	4354	65280	0	0	0	US	1	3	\N	Overlay Descriptor - Green	t	f	t	\N	\N
(60xx,1103)	24576	4355	65280	0	0	0	US	1	3	\N	Overlay Descriptor - Blue	t	f	t	\N	\N
(60xx,1200)	24576	4608	65280	0	0	0	US	1-n	3	\N	Overlays - Gray	t	f	t	\N	\N
(60xx,1201)	24576	4609	65280	0	0	0	US	1-n	3	\N	Overlays - Red	t	f	t	\N	\N
(60xx,1202)	24576	4610	65280	0	0	0	US	1-n	3	\N	Overlays - Green	t	f	t	\N	\N
(60xx,1203)	24576	4611	65280	0	0	0	US	1-n	3	\N	Overlays - Blue	t	f	t	\N	\N
(60xx,4000)	24576	16384	65280	0	0	0	LT	1-n	2	\N	Overlay Comments	t	f	t	\N	\N
(0000,1031)	0	4145	0	0	0	0	US	1	3	\N	Move Originator Message ID	t	f	t	\N	\N
(0008,0000)	8	0	0	0	0	0	UL	1	3	\N	Identifying Group Length	t	f	t	\N	\N
(0010,0000)	16	0	0	0	0	0	UL	1	3	\N	Patient Group Length	t	f	t	\N	\N
(0018,0000)	24	0	0	0	0	0	UL	1	3	\N	Acquisition Group Length	t	f	t	\N	\N
(0018,9096)	24	37014	0	0	0	0	FD	1	3MR	\N	Parallel Reduction Factor In-plane 	t	f	t	\N	\N
(0020,0000)	32	0	0	0	0	0	UL	1	3	\N	Relationship Group Length	t	f	t	\N	\N
(0020,1003)	32	4099	0	0	0	0	IS	1	2	\N	Images in Series	t	f	t	\N	\N
(0020,1005)	32	4101	0	0	0	0	IS	1	2	\N	Images in Study	t	f	t	\N	\N
(0028,0000)	40	0	0	0	0	0	UL	1	3	\N	Image Presentation Group Length	t	f	t	\N	\N
(0028,005f)	40	95	0	0	0	0	LO	1	2C	\N	Compression Recognition Code	t	f	t	\N	\N
(0028,0061)	40	97	0	0	0	0	SH	1	2C	\N	Compression Originator	t	f	t	\N	\N
(0028,0062)	40	98	0	0	0	0	SH	1	2C	\N	Compression Label	t	f	t	\N	\N
(0028,0063)	40	99	0	0	0	0	SH	1	2C	\N	Compression Description	t	f	t	\N	\N
(0028,0065)	40	101	0	0	0	0	LO	1-n	2C	\N	Compression Sequence	t	f	t	\N	\N
(0028,0066)	40	102	0	0	0	0	AT	1-n	2C	\N	Compression Step Pointers	t	f	t	\N	\N
(0028,0068)	40	104	0	0	0	0	US	1	2C	\N	Repeat Interval	t	f	t	\N	\N
(0028,0069)	40	105	0	0	0	0	US	1	2C	\N	Bits Grouped	t	f	t	\N	\N
(0028,0070)	40	112	0	0	0	0	US	1-n	2C	\N	Perimeter Table	t	f	t	\N	\N
(0028,0080)	40	128	0	0	0	0	US	1	2C	\N	Predictor Rows	t	f	t	\N	\N
(0028,0081)	40	129	0	0	0	0	US	1	2C	\N	Predictor Columns	t	f	t	\N	\N
(0028,0082)	40	130	0	0	0	0	US	1-n	2C	\N	Predictor Constants	t	f	t	\N	\N
(0028,0090)	40	144	0	0	0	0	LO	1	2C	\N	Blocked Pixels	t	f	t	\N	\N
(0028,0091)	40	145	0	0	0	0	US	1	2C	\N	Block Rows	t	f	t	\N	\N
(0028,0092)	40	146	0	0	0	0	US	1	2C	\N	Block Columns	t	f	t	\N	\N
(0028,0093)	40	147	0	0	0	0	US	1	2C	\N	Row Overlap	t	f	t	\N	\N
(0028,0094)	40	148	0	0	0	0	US	1	2C	\N	Column Overlap	t	f	t	\N	\N
(0028,0400)	40	1024	0	0	0	0	LO	1	2C	\N	Transform Label	t	f	t	\N	\N
(0028,0401)	40	1025	0	0	0	0	LO	1	2C	\N	Transform Version Number	t	f	t	\N	\N
(0028,0403)	40	1027	0	0	0	0	LO	1-n	2C	\N	Sequence of Compressed Data	t	f	t	\N	\N
(0028,04x0)	40	1024	0	65295	0	4	US	1	2C	\N	Rows For Nth Order Coefficients	t	f	t	\N	\N
(0028,04x1)	40	1025	0	65295	0	4	US	1	2C	\N	Columns For Nth Order Coefficients	t	f	t	\N	\N
(0028,04x2)	40	1026	0	65295	0	4	LO	1-n	2C	\N	CoefficientCoding	t	f	t	\N	\N
(0028,04x3)	40	1027	0	65295	0	4	AT	1-n	2C	\N	Coefficient Coding Pointers	t	f	t	\N	\N
(0028,0700)	40	1792	0	0	0	0	LO	1	2C	\N	DCT Label	t	f	t	\N	\N
(0028,0701)	40	1793	0	0	0	0	LO	1-n	2C	\N	Data Block Description	t	f	t	\N	\N
(0028,0702)	40	1794	0	0	0	0	AT	1-n	2C	\N	Data Block	t	f	t	\N	\N
(0028,0710)	40	1808	0	0	0	0	US	1	2C	\N	Normalization Factor Format	t	f	t	\N	\N
(0028,0720)	40	1824	0	0	0	0	US	1	2C	\N	Zonal Map Number Format	t	f	t	\N	\N
(0028,0721)	40	1825	0	0	0	0	AT	1-n	2C	\N	Zonal Map Location	t	f	t	\N	\N
(0028,0722)	40	1826	0	0	0	0	US	1	2C	\N	Zonal Map Format	t	f	t	\N	\N
(0028,0730)	40	1840	0	0	0	0	US	1	2C	\N	Adaptive Map Format	t	f	t	\N	\N
(0028,0740)	40	1856	0	0	0	0	US	1	2C	\N	Code Number Format	t	f	t	\N	\N
(0028,08x0)	40	2048	0	65295	0	4	LO	1-n	2C	\N	Code Label	t	f	t	\N	\N
(0028,08x2)	40	2050	0	65295	0	4	US	1	2C	\N	Number of Tables	t	f	t	\N	\N
(0028,08x3)	40	2051	0	65295	0	4	AT	1-n	2C	\N	Code Table Location	t	f	t	\N	\N
(0028,08x4)	40	2052	0	65295	0	4	US	1	2C	\N	Bits For Code Word	t	f	t	\N	\N
(0028,08x8)	40	2056	0	65295	0	4	AT	1-n	2C	\N	Image Data Location	t	f	t	\N	\N
(0028,1211)	40	4625	0	0	0	0	OW	1	3DFT	\N	Large Red Palette Color Lookup Table Data	t	f	t	\N	\N
(0028,1212)	40	4626	0	0	0	0	OW	1	3DFT	\N	Large Green Palette Color Lookup Table Data	t	f	t	\N	\N
(0028,1213)	40	4627	0	0	0	0	OW	1	3DFT	\N	Large Blue Palette Color Lookup Table Data	t	f	t	\N	\N
(0028,1214)	40	4628	0	0	0	0	UI	1	3DFT	\N	Large Palette Color Lookup Table UID	t	f	t	\N	\N
(0032,0000)	50	0	0	0	0	0	UL	1	3	\N	Study Group Length	t	f	t	\N	\N
(0038,0000)	56	0	0	0	0	0	UL	1	3	\N	Visit Group Length	t	f	t	\N	\N
(0050,0000)	80	0	0	0	0	0	UL	1	3	\N	Calibration Group Length	t	f	t	\N	\N
(0054,0000)	84	0	0	0	0	0	UL	1	3	\N	Nuclear Acquisition Group Length	t	f	t	\N	\N
(0070,0040)	112	64	0	0	0	0	IS	1	3SCP	\N	Image Rotation (Frozen Draft Retired)	t	f	t	\N	\N
(0070,0050)	112	80	0	0	0	0	US	2	3SCP	\N	Displayed Area TLHC (Frozen Draft Retired)	t	f	t	\N	\N
(0070,0051)	112	81	0	0	0	0	US	2	3SCP	\N	Displayed Area BRHC (Frozen Draft Retired)	t	f	t	\N	\N
(0088,0000)	136	0	0	0	0	0	UL	1	3	\N	Storage Group Length	t	f	t	\N	\N
(1000,0000)	4096	0	0	0	0	0	UL	1	2C	\N	Code Table Group Length	t	f	t	\N	\N
(1000,00x0)	4096	0	0	65295	0	4	US	3	2C	\N	Escape Triplet	t	f	t	\N	\N
(1000,00x1)	4096	1	0	65295	0	4	US	3	2C	\N	Run Length Triplet	t	f	t	\N	\N
(1000,00x2)	4096	2	0	65295	0	4	US	1	2C	\N	Huffman Table Size	t	f	t	\N	\N
(1000,00x3)	4096	3	0	65295	0	4	US	3	2C	\N	Huffman Table Triplet	t	f	t	\N	\N
(1000,00x4)	4096	4	0	65295	0	4	US	1	2C	\N	Shift Table Size	t	f	t	\N	\N
(1000,00x5)	4096	5	0	65295	0	4	US	3	2C	\N	Shift Table Triplet	t	f	t	\N	\N
(1010,0000)	4112	0	0	0	0	0	UL	1	2C	\N	Zonal Map Group Length	t	f	t	\N	\N
(1010,xxxx)	4112	0	0	0	0	0	US	1-n	2C	\N	Zonal Map	t	f	t	\N	\N
(2000,0000)	8192	0	0	0	0	0	UL	1	3	\N	Film Session Group Length	t	f	t	\N	\N
(2010,0000)	8208	0	0	0	0	0	UL	1	3	\N	Film Box Group Length	t	f	t	\N	\N
(2020,0000)	8224	0	0	0	0	0	UL	1	3	\N	Image Box Group Length	t	f	t	\N	\N
(2030,0000)	8240	0	0	0	0	0	UL	1	3	\N	Annotation Group Length	t	f	t	\N	\N
(2040,0000)	8256	0	0	0	0	0	UL	1	3	\N	Overlay Box Group Length	t	f	t	\N	\N
(2100,0000)	8448	0	0	0	0	0	UL	1	3	\N	Print Job Group Length	t	f	t	\N	\N
(2110,0000)	8464	0	0	0	0	0	UL	1	3	\N	Printer Group Length	t	f	t	\N	\N
(4000,0000)	16384	0	0	0	0	0	UL	1	2	\N	Text Group Length	t	f	t	\N	\N
(4008,0000)	16392	0	0	0	0	0	UL	1	3	\N	Results Group Length	t	f	t	\N	\N
(50xx,0000)	20480	0	65280	0	0	0	UL	1	3	\N	Curve Group Length	t	f	t	\N	\N
(60xx,0000)	24576	0	65280	0	0	0	UL	1	3	\N	Overlay Group Length	t	f	t	\N	\N
(60xx,0061)	24576	97	65280	0	0	0	SH	1	2C	\N	Overlay Compression Originator	t	f	t	\N	\N
(60xx,0062)	24576	98	65280	0	0	0	SH	1	2C	\N	Overlay Compression Label	t	f	t	\N	\N
(60xx,0063)	24576	99	65280	0	0	0	SH	1	2C	\N	Overlay Compression Description	t	f	t	\N	\N
(60xx,0066)	24576	102	65280	0	0	0	AT	1-n	2C	\N	Overlay Compression Step Pointers	t	f	t	\N	\N
(60xx,0068)	24576	104	65280	0	0	0	US	1	2C	\N	Overlay Repeat Interval	t	f	t	\N	\N
(60xx,0069)	24576	105	65280	0	0	0	US	1	2C	\N	Overlay Bits Grouped	t	f	t	\N	\N
(60xx,0800)	24576	2048	65280	0	0	0	LO	1-n	2C	\N	Overlay Code Label	t	f	t	\N	\N
(60xx,0802)	24576	2050	65280	0	0	0	US	1	2C	\N	Overlay Number of Tables	t	f	t	\N	\N
(60xx,0803)	24576	2051	65280	0	0	0	AT	1-n	2C	\N	Overlay Code Table Location	t	f	t	\N	\N
(60xx,0804)	24576	2052	65280	0	0	0	US	1	2C	\N	Overlay Bits For Code Word	t	f	t	\N	\N
(7fe0,0000)	32736	0	0	0	0	0	UL	1	3	\N	Pixel Data Group Length	t	f	t	\N	\N
(7fe0,0020)	32736	32	0	0	0	0	OW	1-n	2C	\N	Coefficients SDVN	t	f	t	\N	\N
(7fe0,0030)	32736	48	0	0	0	0	OW	1-n	2C	\N	Coefficients SDHN	t	f	t	\N	\N
(7fe0,0040)	32736	64	0	0	0	0	OW	1-n	2C	\N	Coefficients SDDN	t	f	t	\N	\N
(7fxx,0000)	32512	0	65280	0	0	0	UL	1	2C	\N	Variable Pixel Data Group Length	t	f	t	\N	\N
(0028,1201)	40	4609	0	0	0	0	OW	1-n	3	\N	Red Palette Color Lookup Table Data	t	f	f	\N	\N
(0028,1202)	40	4610	0	0	0	0	OW	1-n	3	\N	Green Palette Color Lookup Table Data	t	f	f	\N	\N
(0028,1203)	40	4611	0	0	0	0	OW	1-n	3	\N	Blue Palette Color Lookup Table Data	t	f	f	\N	\N
(0028,1200)	40	4608	0	0	0	0	OW	1-n	2	\N	Gray Lookup Table Data	t	f	t	\N	\N
(0011,"SIEMENS RA GEN",25)	17	37	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",42)	25	66	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",62)	25	98	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",70)	25	112	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",30)	67	48	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Raw Data Type	f	t	\N	\N	\N
(0003,"AEGIS_DICOM_2.00",00)	3	0	0	0	0	0	US	1-n	AEG	AEGIS_DICOM_2.00	?	f	t	\N	\N	\N
(0003,"SIEMENS ISI",08)	3	8	0	0	0	0	US	1	SSPI	SIEMENS ISI	ISI Command Field	f	t	\N	\N	\N
(0003,"SIEMENS ISI",11)	3	17	0	0	0	0	US	1	SSPI	SIEMENS ISI	Attach ID Application Code	f	t	\N	\N	\N
(0003,"SIEMENS ISI",12)	3	18	0	0	0	0	UL	1	SSPI	SIEMENS ISI	Attach ID Message Count	f	t	\N	\N	\N
(0003,"SIEMENS ISI",13)	3	19	0	0	0	0	DA	1	SSPI	SIEMENS ISI	Attach ID Date	f	t	\N	\N	\N
(0003,"SIEMENS ISI",14)	3	20	0	0	0	0	TM	1	SSPI	SIEMENS ISI	Attach ID Time	f	t	\N	\N	\N
(0003,"SIEMENS ISI",20)	3	32	0	0	0	0	US	1	SSPI	SIEMENS ISI	Message Type	f	t	\N	\N	\N
(0003,"SIEMENS ISI",30)	3	48	0	0	0	0	DA	1	SSPI	SIEMENS ISI	Max Waiting Date	f	t	\N	\N	\N
(0003,"SIEMENS ISI",31)	3	49	0	0	0	0	TM	1	SSPI	SIEMENS ISI	Max Waiting Time	f	t	\N	\N	\N
(0005,"AEGIS_DICOM_2.00",00)	5	0	0	0	0	0	US	1-n	AEG	AEGIS_DICOM_2.00	?	f	t	\N	\N	\N
(0009,"ACUSON",00)	9	0	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"AEGIS_DICOM_2.00",00)	9	0	0	0	0	0	US	1-n	AEG	AEGIS_DICOM_2.00	?	f	t	\N	\N	\N
(0009,"MERGE TECHNOLOGIES, INC.",00)	9	0	0	0	0	0	OB	1	MRG	MERGE TECHNOLOGIES, INC.	?	f	t	\N	\N	\N
(0009,"PAPYRUS",00)	9	0	0	0	0	0	LT	1	PAP	PAPYRUS	Original File Name	f	t	\N	\N	\N
(0009,"CARDIO-D.R. 1.0",00)	9	0	0	0	0	0	UL	1	PDIC	CARDIO-D.R. 1.0	File Location	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",00)	9	0	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",00)	9	0	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Data Object Recognition Code	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  CMS",00)	9	0	0	0	0	0	DS	1	SSPI	SIEMENS CM VA0  CMS	Number of Measurements	f	t	\N	\N	\N
(0009,"ACUSON",01)	9	1	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",01)	9	1	0	0	0	0	LO	1	GEM	GEMS_IDEN_01	Full Fidelity	f	t	\N	\N	\N
(0009,"CARDIO-D.R. 1.0",01)	9	1	0	0	0	0	UL	1	PDIC	CARDIO-D.R. 1.0	File Size	f	t	\N	\N	\N
(0009,"FFP DATA",01)	9	1	0	0	0	0	UN	1	SSPI	FFP DATA	CR Header Information	f	t	\N	\N	\N
(0009,"ISI",01)	9	1	0	0	0	0	UN	1	SSPI	ISI	SIENET General Purpose IMGEF	f	t	\N	\N	\N
(0009,"SIEMENS ISI",01)	9	1	0	0	0	0	UN	1	SSPI	SIEMENS ISI	RIS Patient Info IMGEF	f	t	\N	\N	\N
(0009,"SIENET",01)	9	1	0	0	0	0	US	1	SSPI	SIENET	SIENET Command Field	f	t	\N	\N	\N
(0009,"TOSHIBA_MEC_1.0",01)	9	1	0	0	0	0	LT	1	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0009,"ACUSON",02)	9	2	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",02)	9	2	0	0	0	0	SH	1	GEM	GEMS_IDEN_01	Suite Id	f	t	\N	\N	\N
(0009,"TOSHIBA_MEC_1.0",02)	9	2	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0009,"ACUSON",03)	9	3	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"TOSHIBA_MEC_1.0",03)	9	3	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0009,"ACUSON",04)	9	4	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",04)	9	4	0	0	0	0	SH	1	GEM	GEMS_IDEN_01	Product Id	f	t	\N	\N	\N
(0009,"SPI-P Release 1",04)	9	4	0	0	0	0	LO	1	PSPI	SPI-P Release 1	Image Data Consistence	f	t	\N	\N	\N
(0009,"TOSHIBA_MEC_1.0",04)	9	4	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0009,"ACUSON",05)	9	5	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",06)	9	6	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",07)	9	7	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",08)	9	8	0	0	0	0	LT	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",08)	9	8	0	0	0	0	US	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"ACUSON",09)	9	9	0	0	0	0	LT	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",0a)	9	10	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",0b)	9	11	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",0c)	9	12	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",0d)	9	13	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",0e)	9	14	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",0f)	9	15	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"ACUSON",10)	9	16	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"AGFA",10)	9	16	0	0	0	0	LO	1	AGFA	AGFA	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",10)	9	16	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0009,"PAPYRUS",10)	9	16	0	0	0	0	LT	1	PAP	PAPYRUS	Original File Location	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",10)	9	16	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"PHILIPS MR",10)	9	16	0	0	0	0	LO	1	PSPI	PHILIPS MR	SPI Release	f	t	\N	\N	\N
(0009,"SPI RELEASE 1",10)	9	16	0	0	0	0	LT	1	SPI	SPI RELEASE 1	Comments	f	t	\N	\N	\N
(0009,"SPI Release 1",10)	9	16	0	0	0	0	LT	1	SPI	SPI Release 1	Comments	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  CMS",10)	9	16	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Storage Mode	f	t	\N	\N	\N
(0009,"SIEMENS DICOM",10)	9	16	0	0	0	0	UN	1	SSPI	SIEMENS DICOM	?	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  LAB",10)	9	16	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  LAB	Generator Identification Label	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",10)	9	16	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"SIEMENS MED",10)	9	16	0	0	0	0	LT	1	SSPI	SIEMENS MED	Recognition Code	f	t	\N	\N	\N
(0009,"ACUSON",11)	9	17	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"AGFA",11)	9	17	0	0	0	0	LO	1	AGFA	AGFA	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",11)	9	17	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Study Flags	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  LAB",11)	9	17	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  LAB	Gantry Identification Label	f	t	\N	\N	\N
(0009,"ACUSON",12)	9	18	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",12)	9	18	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Study Type	f	t	\N	\N	\N
(0009,"PHILIPS MR",12)	9	18	0	0	0	0	LO	1	PSPI	PHILIPS MR	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",12)	9	18	0	0	0	0	LO	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  CMS",12)	9	18	0	0	0	0	UL	1	SSPI	SIEMENS CM VA0  CMS	Evaluation Mask - Image	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  LAB",12)	9	18	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  LAB	X-Ray Tube Identification Label	f	t	\N	\N	\N
(0009,"SIEMENS DICOM",12)	9	18	0	0	0	0	LT	1	SSPI	SIEMENS DICOM	?	f	t	\N	\N	\N
(0009,"ACUSON",13)	9	19	0	0	0	0	IS	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"AGFA",13)	9	19	0	0	0	0	LO	1	AGFA	AGFA	?	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  LAB",13)	9	19	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  LAB	Detector Identification Label	f	t	\N	\N	\N
(0009,"ACUSON",14)	9	20	0	0	0	0	LT	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"AGFA",14)	9	20	0	0	0	0	LO	1	AGFA	AGFA	?	f	t	\N	\N	\N
(0009,"SIENET",14)	9	20	0	0	0	0	LT	1	SSPI	SIENET	Receiver PLA	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  LAB",14)	9	20	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  LAB	DAS Identification Label	f	t	\N	\N	\N
(0009,"ACUSON",15)	9	21	0	0	0	0	UN	1	ACU	ACUSON	?	f	t	\N	\N	\N
(0009,"AGFA",15)	9	21	0	0	0	0	LO	1	AGFA	AGFA	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",15)	9	21	0	0	0	0	LO	1	PSPI	SPI-P Release 1	Unique Identifier	f	t	\N	\N	\N
(0009,"SPI RELEASE 1",15)	9	21	0	0	0	0	LO	1	SPI	SPI RELEASE 1	UID	f	t	\N	\N	\N
(0009,"SPI Release 1",15)	9	21	0	0	0	0	LO	1	SPI	SPI Release 1	UID	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  LAB",15)	9	21	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  LAB	SMI Identification Label	f	t	\N	\N	\N
(0009,"SPI",15)	9	21	0	0	0	0	LT	1	SSPI	SPI	UID	f	t	\N	\N	\N
(0009,"SPI-P Release 1",16)	9	22	0	0	0	0	LO	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"SIENET",16)	9	22	0	0	0	0	US	1	SSPI	SIENET	Transfer Priority	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  LAB",16)	9	22	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  LAB	CPU Identification Label	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",17)	9	23	0	0	0	0	LT	1	GEM	GEMS_IDEN_01	?	f	t	\N	\N	\N
(0009,"PAPYRUS",18)	9	24	0	0	0	0	LT	1	PAP	PAPYRUS	Data Set Identifier	f	t	\N	\N	\N
(0009,"SPI-P Release 1",18)	9	24	0	0	0	0	LO	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",1a)	9	26	0	0	0	0	US	1	GEM	GEMS_IDEN_01	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",1e)	9	30	0	0	0	0	UI	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",20)	9	32	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",20)	9	32	0	0	0	0	US	1	GEM	GEMS_IDEN_01	?	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",20)	9	32	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  LAB",20)	9	32	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  LAB	Header Version	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  ORI",20)	9	32	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  ORI	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",21)	9	33	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Series Flags	f	t	\N	\N	\N
(0009,"SPI-P Release 1",21)	9	33	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",22)	9	34	0	0	0	0	SH	1	GEM	GEMS_GENIE_1	User Orientation	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",23)	9	35	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Initiation Type	f	t	\N	\N	\N
(0009,"GEMS_ACQU_01",24)	9	36	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",24)	9	36	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Initiation Delay	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",25)	9	37	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Initiation Count Rate	f	t	\N	\N	\N
(0009,"GEMS_ACQU_01",25)	9	37	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",26)	9	38	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Number Energy Sets	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  CMS",26)	9	38	0	0	0	0	DA	1	SSPI	SIEMENS CM VA0  CMS	Last Move Date	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",27)	9	39	0	0	0	0	SL	1	GEM	GEMS_IDEN_01	Image Actual Date	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",27)	9	39	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Number Detectors	f	t	\N	\N	\N
(0009,"SIEMENS CM VA0  CMS",27)	9	39	0	0	0	0	TM	1	SSPI	SIEMENS CM VA0  CMS	Last Move Time	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",29)	9	41	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0009,"SIENET",29)	9	41	0	0	0	0	LT	1	SSPI	SIENET	Actual User	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",2a)	9	42	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",2c)	9	44	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	Series Comments	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",2d)	9	45	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Track Beat Average	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",2e)	9	46	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Distance Prescribed	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",2f)	9	47	0	0	0	0	LT	1	GEM	GEMS_IDEN_01	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",30)	9	48	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",30)	9	48	0	0	0	0	SH	1	GEM	GEMS_IDEN_01	Service Id	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",30)	9	48	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SIEMENS MED",30)	9	48	0	0	0	0	UL	1	SSPI	SIEMENS MED	Byte Offset of Original Header	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",30)	9	48	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  ORI",30)	9	48	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  ORI	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",31)	9	49	0	0	0	0	SH	1	GEM	GEMS_IDEN_01	Mobile Location Number	f	t	\N	\N	\N
(0009,"SPI-P Release 1",31)	9	49	0	0	0	0	LT	1	PSPI	SPI-P Release 1	PACS Unique Identifier	f	t	\N	\N	\N
(0009,"SIEMENS MED",31)	9	49	0	0	0	0	UL	1	SSPI	SIEMENS MED	Length of Original Header	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",31)	9	49	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",32)	9	50	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",34)	9	52	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Cluster Unique Identifier	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",34)	9	52	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",35)	9	53	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Gantry Locus Type	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",37)	9	55	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Starting Heart Rate	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",38)	9	56	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	RR Window Width	f	t	\N	\N	\N
(0009,"SPI-P Release 1",38)	9	56	0	0	0	0	LT	1	PSPI	SPI-P Release 1	System Unique Identifier	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",39)	9	57	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	RR Window Offset	f	t	\N	\N	\N
(0009,"SPI-P Release 1",39)	9	57	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",3a)	9	58	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Percent Cycle Imaged	f	t	\N	\N	\N
(0009,"GEMS_ACQU_01",3e)	9	62	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0009,"GEMS_ACQU_01",3f)	9	63	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",40)	9	64	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0009,"CARDIO-D.R. 1.0",40)	9	64	0	0	0	0	SQ	1	PDIC	CARDIO-D.R. 1.0	Alternate Image Sequence	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",40)	9	64	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SPI RELEASE 1",40)	9	64	0	0	0	0	US	1	SPI	SPI RELEASE 1	Data Object Type	f	t	\N	\N	\N
(0009,"SPI Release 1",40)	9	64	0	0	0	0	US	1	SPI	SPI Release 1	Data Object Type	f	t	\N	\N	\N
(0009,"SIEMENS MED",40)	9	64	0	0	0	0	UL	1	SSPI	SIEMENS MED	Byte Offset of Pixelmatrix	f	t	\N	\N	\N
(0009,"SPI",40)	9	64	0	0	0	0	US	1	SSPI	SPI	Data Object Type	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",40)	9	64	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",41)	9	65	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Patient Flags	f	t	\N	\N	\N
(0009,"SPI RELEASE 1",41)	9	65	0	0	0	0	LO	1	SPI	SPI RELEASE 1	Data Object Subtype	f	t	\N	\N	\N
(0009,"SPI Release 1",41)	9	65	0	0	0	0	LO	1	SPI	SPI Release 1	Data Object Subtype	f	t	\N	\N	\N
(0009,"SPI",41)	9	65	0	0	0	0	LT	1	SSPI	SPI	Data Object Subtype	f	t	\N	\N	\N
(0009,"SIEMENS MED",41)	9	65	0	0	0	0	UL	1	SSPI	SIEMENS MED	Length of Pixelmatrix In Bytes	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",42)	9	66	0	0	0	0	DA	1	GEM	GEMS_GENIE_1	Patient Creation Date	f	t	\N	\N	\N
(0009,"GEMS_ACQU_01",42)	9	66	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",42)	9	66	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"GEMS_GENIE_1",43)	9	67	0	0	0	0	TM	1	GEM	GEMS_GENIE_1	Patient Creation Time	f	t	\N	\N	\N
(0009,"GEMS_ACQU_01",43)	9	67	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",50)	9	80	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",50)	9	80	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"SIEMENS MED",50)	9	80	0	0	0	0	LT	1	SSPI	SIEMENS MED	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",51)	9	81	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Study Unique Identifier	f	t	\N	\N	\N
(0009,"SIEMENS CT VA0  IDE",51)	9	81	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  IDE	?	f	t	\N	\N	\N
(0009,"SIEMENS MED",51)	9	81	0	0	0	0	LT	1	SSPI	SIEMENS MED	?	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",60)	9	96	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",61)	9	97	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Series Unique Identifier	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",70)	9	112	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",75)	9	117	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",80)	9	128	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P-GV-CT Release 1",90)	9	144	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",91)	9	145	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1;1",c0)	9	192	0	0	0	0	LT	1	PSPI	SPI-P Release 1;1	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1;1",c1)	9	193	0	0	0	0	LT	1	PSPI	SPI-P Release 1;1	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",e2)	9	226	0	0	0	0	LT	1	GEM	GEMS_IDEN_01	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",e3)	9	227	0	0	0	0	UI	1	GEM	GEMS_IDEN_01	Equipment UID	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",e6)	9	230	0	0	0	0	SH	1	GEM	GEMS_IDEN_01	Genesis Version Now	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",e7)	9	231	0	0	0	0	UL	1	GEM	GEMS_IDEN_01	Exam Record Checksum	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",e8)	9	232	0	0	0	0	UL	1	GEM	GEMS_IDEN_01	?	f	t	\N	\N	\N
(0009,"GEMS_IDEN_01",e9)	9	233	0	0	0	0	SL	1	GEM	GEMS_IDEN_01	Actual Series Data Time Stamp	f	t	\N	\N	\N
(0009,"SPI-P Release 1",f2)	9	242	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",f3)	9	243	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",f4)	9	244	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"SPI-P Release 1",f5)	9	245	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"SIEMENS MED",f5)	9	245	0	0	0	0	LT	1	SSPI	SIEMENS MED	PDM EFID Placeholder	f	t	\N	\N	\N
(0009,"SIEMENS MED",f6)	9	246	0	0	0	0	LT	1	SSPI	SIEMENS MED	PDM Data Object Type Extension	f	t	\N	\N	\N
(0009,"SPI-P Release 1",f7)	9	247	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0009,"GEMS_ACQU_01",f8)	9	248	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0009,"GEMS_ACQU_01",fb)	9	251	0	0	0	0	IS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0011,"DLX_PATNT_01",01)	17	1	0	0	0	0	LT	1	DLX	DLX_PATNT_01	Patient DOB	f	t	\N	\N	\N
(0011,"TOSHIBA_MEC_1.0",01)	17	1	0	0	0	0	LT	1	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0011,"TOSHIBA_MEC_1.0",02)	17	2	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0011,"SIEMENS ISI",03)	17	3	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Patient UID	f	t	\N	\N	\N
(0011,"SIEMENS ISI",04)	17	4	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Patient ID	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",0a)	17	10	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Series Type	f	t	\N	\N	\N
(0011,"SIEMENS CM VA0  CMS",0a)	17	10	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0011,"SIEMENS ISI",0a)	17	10	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Case ID	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",0b)	17	11	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Effective Series Duration	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",0c)	17	12	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Num Beats	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",0d)	17	13	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	Radio Nuclide Name	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",10)	17	16	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0011,"GEMS_PATI_01",10)	17	16	0	0	0	0	SS	1	GEM	GEMS_PATI_01	Patient Status	f	t	\N	\N	\N
(0011,"SPI-P Release 1",10)	17	16	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Patient Entry ID	f	t	\N	\N	\N
(0011,"SPI RELEASE 1",10)	17	16	0	0	0	0	LT	1	SPI	SPI RELEASE 1	Organ	f	t	\N	\N	\N
(0011,"SPI Release 1",10)	17	16	0	0	0	0	LT	1	SPI	SPI Release 1	Organ	f	t	\N	\N	\N
(0011,"SIEMENS CM VA0  CMS",10)	17	16	0	0	0	0	DA	1	SSPI	SIEMENS CM VA0  CMS	Registration Date	f	t	\N	\N	\N
(0011,"SIEMENS RIS",10)	17	16	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Patient UID	f	t	\N	\N	\N
(0011,"SPI",10)	17	16	0	0	0	0	LT	1	SSPI	SPI	Organ	f	t	\N	\N	\N
(0011,"SIEMENS CM VA0  CMS",11)	17	17	0	0	0	0	TM	1	SSPI	SIEMENS CM VA0  CMS	Registration Time	f	t	\N	\N	\N
(0011,"SIEMENS RIS",11)	17	17	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Patient ID	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",12)	17	18	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	Dataset Name	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",13)	17	19	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Dataset Type	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",15)	17	21	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Detector Number	f	t	\N	\N	\N
(0011,"SPI RELEASE 1",15)	17	21	0	0	0	0	LT	1	SPI	SPI RELEASE 1	Allergy Indication	f	t	\N	\N	\N
(0011,"SPI Release 1",15)	17	21	0	0	0	0	LT	1	SPI	SPI Release 1	Allergy Indication	f	t	\N	\N	\N
(0011,"SPI",15)	17	21	0	0	0	0	LT	1	SSPI	SPI	Allergy Indication	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",16)	17	22	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Energy Number	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",17)	17	23	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	RR Interval Window Number	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",18)	17	24	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	MG Bin Number	f	t	\N	\N	\N
(0011,"SPI-P Release 2;1",18)	17	24	0	0	0	0	LT	1	PSPI	SPI-P Release 2;1	?	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",19)	17	25	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Radius Of Rotation	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",1a)	17	26	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Detector Count Zone	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",1b)	17	27	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Num Energy Windows	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",1c)	17	28	0	0	0	0	SL	4	GEM	GEMS_GENIE_1	Energy Offset	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",1d)	17	29	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Energy Range	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",1f)	17	31	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Image Orientation	f	t	\N	\N	\N
(0011,"SPI RELEASE 1",20)	17	32	0	0	0	0	LT	1	SPI	SPI RELEASE 1	Pregnancy	f	t	\N	\N	\N
(0011,"SPI Release 1",20)	17	32	0	0	0	0	LT	1	SPI	SPI Release 1	Pregnancy	f	t	\N	\N	\N
(0011,"SIEMENS RIS",20)	17	32	0	0	0	0	DA	1	SSPI	SIEMENS RIS	Patient Registration Date	f	t	\N	\N	\N
(0011,"SIEMENS RA GEN",20)	17	32	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0011,"SPI",20)	17	32	0	0	0	0	LT	1	SSPI	SPI	Pregnancy	f	t	\N	\N	\N
(0011,"SPI-P Release 1",21)	17	33	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0011,"SIEMENS RIS",21)	17	33	0	0	0	0	TM	1	SSPI	SIEMENS RIS	Patient Registration Time	f	t	\N	\N	\N
(0011,"SPI-P Release 1",22)	17	34	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0011,"SIEMENS CM VA0  CMS",22)	17	34	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0011,"SIEMENS ISI",22)	17	34	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Request ID	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",23)	17	35	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Use FOV Mask	f	t	\N	\N	\N
(0011,"SIEMENS CM VA0  CMS",23)	17	35	0	0	0	0	DS	1	SSPI	SIEMENS CM VA0  CMS	Used Patient Weight	f	t	\N	\N	\N
(0011,"SIEMENS ISI",23)	17	35	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Examination UID	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",24)	17	36	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	FOV Mask Y Cutoff Angle	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",25)	17	37	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	FOV Mask Cutoff Angle	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",26)	17	38	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Table Orientation	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",27)	17	39	0	0	0	0	SL	2	GEM	GEMS_GENIE_1	ROI Top Left	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",28)	17	40	0	0	0	0	SL	2	GEM	GEMS_GENIE_1	ROI Bottom Right	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",30)	17	48	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0011,"SIEMENS RA GEN",30)	17	48	0	0	0	0	LT	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0011,"SIEMENS RIS",30)	17	48	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Patientname RIS	f	t	\N	\N	\N
(0011,"SPI-P Release 1",31)	17	49	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0011,"SIEMENS RIS",31)	17	49	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Patientprename RIS	f	t	\N	\N	\N
(0011,"SPI-P Release 1",32)	17	50	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",33)	17	51	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	Energy Correct Name	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",34)	17	52	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	Spatial Correct Name	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",35)	17	53	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	Tuning Calib Name	f	t	\N	\N	\N
(0011,"SIEMENS RA GEN",35)	17	53	0	0	0	0	LT	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",36)	17	54	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	Uniformity Correct Name	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",37)	17	55	0	0	0	0	LO	1	GEM	GEMS_GENIE_1	Acquisition Specific Correct Name	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",38)	17	56	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Byte Order	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",3a)	17	58	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Picture Format	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",3b)	17	59	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Pixel Scale	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",3c)	17	60	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Pixel Offset	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",3e)	17	62	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	FOV Shape	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",3f)	17	63	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Dataset Flags	f	t	\N	\N	\N
(0011,"SIEMENS CM VA0  CMS",40)	17	64	0	0	0	0	IS	1	SSPI	SIEMENS CM VA0  CMS	Organ Code	f	t	\N	\N	\N
(0011,"SIEMENS RA GEN",40)	17	64	0	0	0	0	LT	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0011,"SIEMENS RIS",40)	17	64	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Patient Hospital Status	f	t	\N	\N	\N
(0011,"SIEMENS RIS",41)	17	65	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Medical Alerts	f	t	\N	\N	\N
(0011,"SIEMENS RIS",42)	17	66	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Contrast Allergies	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",44)	17	68	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Threshold Center	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",45)	17	69	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Threshold Width	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",46)	17	70	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	Interpolation Type	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",55)	17	85	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Period	f	t	\N	\N	\N
(0011,"GEMS_GENIE_1",56)	17	86	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	ElapsedTime	f	t	\N	\N	\N
(0011,"SIEMENS ISI",a1)	17	161	0	0	0	0	DA	1	SSPI	SIEMENS ISI	Patient Registration Date	f	t	\N	\N	\N
(0011,"SIEMENS ISI",a2)	17	162	0	0	0	0	TM	1	SSPI	SIEMENS ISI	Patient Registration Time	f	t	\N	\N	\N
(0011,"SIEMENS ISI",b0)	17	176	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Patient Last Name	f	t	\N	\N	\N
(0011,"SIEMENS ISI",b2)	17	178	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Patient First Name	f	t	\N	\N	\N
(0011,"SIEMENS ISI",b4)	17	180	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Patient Hospital Status	f	t	\N	\N	\N
(0011,"SIEMENS ISI",bc)	17	188	0	0	0	0	TM	1	SSPI	SIEMENS ISI	Current Location Time	f	t	\N	\N	\N
(0011,"SIEMENS ISI",c0)	17	192	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Patient Insurance Status	f	t	\N	\N	\N
(0011,"SIEMENS ISI",d0)	17	208	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Patient Billing Type	f	t	\N	\N	\N
(0011,"SIEMENS ISI",d2)	17	210	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Patient Billing Address	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",00)	19	0	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Modifying Physician	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",10)	19	16	0	0	0	0	FD	2	GEM	GEMS_GENIE_1	Digital FOV	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",10)	19	16	0	0	0	0	DA	1	SSPI	SIEMENS CM VA0  CMS	Modification Date	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",11)	19	17	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",12)	19	18	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",12)	19	18	0	0	0	0	TM	1	SSPI	SIEMENS CM VA0  CMS	Modification Time	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",16)	19	22	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	AutoTrack Peak	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",17)	19	23	0	0	0	0	SL	1	GEM	GEMS_GENIE_1	AutoTrack Width	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",18)	19	24	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Transmission Scan Time	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",19)	19	25	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Transmission Mask Width	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",1a)	19	26	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	Copper Attenuator Thickness	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",1c)	19	28	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",1d)	19	29	0	0	0	0	FD	1	GEM	GEMS_GENIE_1	?	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",1e)	19	30	0	0	0	0	FD	1-n	GEM	GEMS_GENIE_1	Tomo View Offset	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",20)	19	32	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Patient Name	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",22)	19	34	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Patient Id	f	t	\N	\N	\N
(0013,"GEMS_GENIE_1",26)	19	38	0	0	0	0	LT	1	GEM	GEMS_GENIE_1	Study Comments	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",30)	19	48	0	0	0	0	DA	1	SSPI	SIEMENS CM VA0  CMS	Patient Birthdate	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",31)	19	49	0	0	0	0	DS	1	SSPI	SIEMENS CM VA0  CMS	Patient Weight	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",32)	19	50	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Patients Maiden Name	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",33)	19	51	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Referring Physician	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",34)	19	52	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Admitting Diagnosis	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",35)	19	53	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Patient Sex	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",40)	19	64	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Procedure Description	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",42)	19	66	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Patient Rest Direction	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",44)	19	68	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Patient Position	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",46)	19	70	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	View Direction	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",50)	19	80	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",51)	19	81	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",52)	19	82	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",53)	19	83	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",54)	19	84	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",55)	19	85	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0013,"SIEMENS CM VA0  CMS",56)	19	86	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0015,"DLX_EXAMS_01",01)	21	1	0	0	0	0	DS	1	DLX	DLX_EXAMS_01	Stenosis Calibration Ratio	f	t	\N	\N	\N
(0015,"DLX_EXAMS_01",02)	21	2	0	0	0	0	DS	1	DLX	DLX_EXAMS_01	Stenosis Magnification	f	t	\N	\N	\N
(0015,"DLX_EXAMS_01",03)	21	3	0	0	0	0	DS	1	DLX	DLX_EXAMS_01	Cardiac Calibration Ratio	f	t	\N	\N	\N
(0019,"AEGIS_DICOM_2.00",00)	25	0	0	0	0	0	US	1-n	AEG	AEGIS_DICOM_2.00	?	f	t	\N	\N	\N
(0019,"CARDIO-D.R. 1.0",00)	25	0	0	0	0	0	CS	1	PDIC	CARDIO-D.R. 1.0	Image Blanking Shape	f	t	\N	\N	\N
(0019,"PHILIPS MR R5.5/PART",00)	25	0	0	0	0	0	DS	1	PSPI	PHILIPS MR R5.5/PART	Field of View	f	t	\N	\N	\N
(0019,"PHILIPS MR R5.6/PART",00)	25	0	0	0	0	0	DS	1	PSPI	PHILIPS MR R5.6/PART	Field of View	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",00)	25	0	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Field of View	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",00)	25	0	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Stacks	f	t	\N	\N	\N
(0019,"SPI-P Release 1",00)	25	0	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",00)	25	0	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Physiological Data Type	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",01)	25	1	0	0	0	0	DS	1	DLX	DLX_SERIE_01	Angle Value L Arm	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",01)	25	1	0	0	0	0	LT	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",01)	25	1	0	0	0	0	IS	1-n	PSPI	PHILIPS MR/PART	Stack Type	f	t	\N	\N	\N
(0019,"SPI-P Release 1",01)	25	1	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",01)	25	1	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Physiological Data Channel And Kind	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",01)	25	1	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",01)	25	1	0	0	0	0	IS	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_1.0",01)	25	1	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",02)	25	2	0	0	0	0	DS	1	DLX	DLX_SERIE_01	Angle Value P Arm	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",02)	25	2	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Number Of Cells In Detector	f	t	\N	\N	\N
(0019,"CARDIO-D.R. 1.0",02)	25	2	0	0	0	0	IS	1	PDIC	CARDIO-D.R. 1.0	Image Blanking Left Vertical Edge	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",02)	25	2	0	0	0	0	IS	1-n	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",02)	25	2	0	0	0	0	UN	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",02)	25	2	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",02)	25	2	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Sample Bits Allocated	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",02)	25	2	0	0	0	0	IS	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_1.0",02)	25	2	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",03)	25	3	0	0	0	0	DS	1	DLX	DLX_SERIE_01	Angle Value C Arm	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",03)	25	3	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Cell Number At Theta	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",03)	25	3	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",03)	25	3	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Sample Bits Stored	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",03)	25	3	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",04)	25	4	0	0	0	0	CS	1	DLX	DLX_SERIE_01	Angle Label L Arm	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",04)	25	4	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Cell Spacing	f	t	\N	\N	\N
(0019,"CARDIO-D.R. 1.0",04)	25	4	0	0	0	0	IS	1	PDIC	CARDIO-D.R. 1.0	Image Blanking Right Vertical Edge	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",04)	25	4	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",04)	25	4	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Sample High Bit	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",04)	25	4	0	0	0	0	LT	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",05)	25	5	0	0	0	0	CS	1	DLX	DLX_SERIE_01	Angle Label P Arm	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",05)	25	5	0	0	0	0	LT	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",05)	25	5	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	CC Angulation	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",05)	25	5	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",05)	25	5	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Sample Representation	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",05)	25	5	0	0	0	0	LT	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",06)	25	6	0	0	0	0	CS	1	DLX	DLX_SERIE_01	Angle Label C Arm	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",06)	25	6	0	0	0	0	UN	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"CARDIO-D.R. 1.0",06)	25	6	0	0	0	0	IS	1	PDIC	CARDIO-D.R. 1.0	Image Blanking Upper Horizontal Edge	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",06)	25	6	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	AP Angulation	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",06)	25	6	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Smallest Sample Value	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",06)	25	6	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",06)	25	6	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",07)	25	7	0	0	0	0	ST	1	DLX	DLX_SERIE_01	Procedure Name	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",07)	25	7	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	LR Angulation	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",07)	25	7	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",07)	25	7	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Largest Sample Value	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",07)	25	7	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",08)	25	8	0	0	0	0	ST	1	DLX	DLX_SERIE_01	Exam Name	f	t	\N	\N	\N
(0019,"CARDIO-D.R. 1.0",08)	25	8	0	0	0	0	IS	1	PDIC	CARDIO-D.R. 1.0	Image Blanking Lower Horizontal Edge	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",08)	25	8	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",08)	25	8	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Patient Orientation 1	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",08)	25	8	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Patient Position	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",08)	25	8	0	0	0	0	IS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",08)	25	8	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Number Of Samples	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",08)	25	8	0	0	0	0	LT	1	TSH	TOSHIBA_MEC_CT_1.0	Orientation Head Feet	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",09)	25	9	0	0	0	0	SH	1	DLX	DLX_SERIE_01	Patient Size	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",09)	25	9	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	Main Magnetic Field	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",09)	25	9	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",09)	25	9	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Patient Orientation	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",09)	25	9	0	0	0	0	IS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",09)	25	9	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Sample Data	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",09)	25	9	0	0	0	0	LT	1	TSH	TOSHIBA_MEC_CT_1.0	View Direction	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",0a)	25	10	0	0	0	0	IS	1	DLX	DLX_SERIE_01	Record View	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0a)	25	10	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Slice Orientation	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",0a)	25	10	0	0	0	0	IS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",0a)	25	10	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Sample Rate	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",0a)	25	10	0	0	0	0	LT	1	TSH	TOSHIBA_MEC_CT_1.0	Orientation Supine Prone	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0b)	25	11	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	LR Offcenter	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0b)	25	11	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	LR Offcenter	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",0b)	25	11	0	0	0	0	DS	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0c)	25	12	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	CC Offcenter	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0c)	25	12	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	CC Offcenter	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",0c)	25	12	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0d)	25	13	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	AP Offcenter	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0d)	25	13	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	AP Offcenter	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",0d)	25	13	0	0	0	0	TM	1	TSH	TOSHIBA_MEC_CT_1.0	Time	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",0e)	25	14	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0e)	25	14	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",0e)	25	14	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	Flow Compensation	f	t	\N	\N	\N
(0019,"TOSHIBA_MEC_CT_1.0",0e)	25	14	0	0	0	0	DS	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",0f)	25	15	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Horizontal Frame Of Reference	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",0f)	25	15	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Slices	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",10)	25	16	0	0	0	0	DS	1	DLX	DLX_SERIE_01	Injector Delay	f	t	\N	\N	\N
(0019,"1.2.840.113681",10)	25	16	0	0	0	0	ST	1	DUP	1.2.840.113681	CR Image Params Common	f	t	\N	\N	\N
(0019,"CARDIO-D.R. 1.0",10)	25	16	0	0	0	0	IS	1	PDIC	CARDIO-D.R. 1.0	Center of Circular Image Blanking	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",10)	25	16	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Slice Factor	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",10)	25	16	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",10)	25	16	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P-XSB-DCI Release 1",10)	25	16	0	0	0	0	LT	1	PSPI	SPI-P-XSB-DCI Release 1	Video Beam Boost	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",10)	25	16	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Physiological Data Type 2	f	t	\N	\N	\N
(0019,"SPI-P-Private-DCI Release 1",10)	25	16	0	0	0	0	UN	1	PSPI	SPI-P-Private-DCI Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",10)	25	16	0	0	0	0	US	1	PSPI	SPI-P Release 1	Mains Frequency	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  CMS",10)	25	16	0	0	0	0	DS	1	SSPI	SIEMENS CM VA0  CMS	Net Frequency	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",10)	25	16	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Distance Source To Source Side Collimator	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",10)	25	16	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Source Side Collimator Aperture	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",10)	25	16	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Total Measurement Time Nominal	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  ACQU",10)	25	16	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  ACQU	Parameter File Name	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",10)	25	16	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Measurement Mode	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",11)	25	17	0	0	0	0	CS	1	DLX	DLX_SERIE_01	Auto Inject	f	t	\N	\N	\N
(0019,"1.2.840.113681",11)	25	17	0	0	0	0	ST	1	DUP	1.2.840.113681	CR Image IP Params Single	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",11)	25	17	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Series Contrast	f	t	\N	\N	\N
(0019,"PHILIPS-MR-1",11)	25	17	0	0	0	0	IS	1	PDIC	PHILIPS-MR-1	Chemical Shift Number	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",11)	25	17	0	0	0	0	DS	1-n	PSPI	PHILIPS MR/PART	Echo Times	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",11)	25	17	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Physiological Data Channel And Kind 2	f	t	\N	\N	\N
(0019,"SPI-P-Private-DCI Release 1",11)	25	17	0	0	0	0	UN	1	PSPI	SPI-P-Private-DCI Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P-XSB-DCI Release 1",11)	25	17	0	0	0	0	US	1	PSPI	SPI-P-XSB-DCI Release 1	Channel Generating Video Sync	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",11)	25	17	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Distance Source To Detector Side Collimator	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",11)	25	17	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Detector Side Collimator Aperture	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",11)	25	17	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Total Measurement Time Current	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  ACQU",11)	25	17	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  ACQU	Sequence File Name	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",11)	25	17	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Image Type	f	t	\N	\N	\N
(0019,"1.2.840.113681",12)	25	18	0	0	0	0	ST	1	DUP	1.2.840.113681	CR Image IP Params Left	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",12)	25	18	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Last Pseq	f	t	\N	\N	\N
(0019,"CARDIO-D.R. 1.0",12)	25	18	0	0	0	0	IS	1	PDIC	CARDIO-D.R. 1.0	Radius of Circular Image Blanking	f	t	\N	\N	\N
(0019,"PHILIPS-MR-1",12)	25	18	0	0	0	0	IS	1	PDIC	PHILIPS-MR-1	Phase Number	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",12)	25	18	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P-Private-DCI Release 1",12)	25	18	0	0	0	0	UN	1	PSPI	SPI-P-Private-DCI Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",12)	25	18	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Sample Bits Allocated 2	f	t	\N	\N	\N
(0019,"SPI-P-XSB-DCI Release 1",12)	25	18	0	0	0	0	US	1	PSPI	SPI-P-XSB-DCI Release 1	Video Gain	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",12)	25	18	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Magnetic Field Strength	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",12)	25	18	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Start Delay Time	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  ACQU",12)	25	18	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  ACQU	Sequence File Owner	f	t	\N	\N	\N
(0019,"1.2.840.113681",13)	25	19	0	0	0	0	ST	1	DUP	1.2.840.113681	CR Image IP Params Right	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",13)	25	19	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Start Number For Baseline	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",13)	25	19	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P-Private-DCI Release 1",13)	25	19	0	0	0	0	UN	1	PSPI	SPI-P-Private-DCI Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",13)	25	19	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Sample Bits Stored 2	f	t	\N	\N	\N
(0019,"SPI-P-XSB-DCI Release 1",13)	25	19	0	0	0	0	US	1	PSPI	SPI-P-XSB-DCI Release 1	Video Offset	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",13)	25	19	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Dwell Time	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  ACQU",13)	25	19	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  ACQU	Sequence Description	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",14)	25	20	0	0	0	0	IS	1	DLX	DLX_SERIE_01	Acquisition Mode	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",14)	25	20	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	End Number For Baseline	f	t	\N	\N	\N
(0019,"SPI-P-Private-DCI Release 1",14)	25	20	0	0	0	0	UN	1	PSPI	SPI-P-Private-DCI Release 1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",14)	25	20	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",14)	25	20	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Sample High Bit 2	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",14)	25	20	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	ADC Voltage	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",14)	25	20	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Phases	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  ACQU",14)	25	20	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  ACQU	EPI File Name	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",15)	25	21	0	0	0	0	CS	1	DLX	DLX_SERIE_01	Camera Rotation Enabled	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",15)	25	21	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Start Number For Enhanced Scans	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",15)	25	21	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Dynamic Study	f	t	\N	\N	\N
(0019,"SPI-P-Private-DCI Release 1",15)	25	21	0	0	0	0	UN	1	PSPI	SPI-P-Private-DCI Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",15)	25	21	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Sample Representation 2	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",15)	25	21	0	0	0	0	US	1-n	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",15)	25	21	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",15)	25	21	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Software Version	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",16)	25	22	0	0	0	0	CS	1	DLX	DLX_SERIE_01	Reverse Sweep	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",16)	25	22	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	End Number For Enhanced Scans	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",16)	25	22	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",16)	25	22	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Smallest Sample Value 2	f	t	\N	\N	\N
(0019,"SPI-P-Private-DCI Release 1",16)	25	22	0	0	0	0	UN	1	PSPI	SPI-P-Private-DCI Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",16)	25	22	0	0	0	0	DS	2	SSPI	SIEMENS MR VA0  COAD	ADC Offset	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",16)	25	22	0	0	0	0	UL	2	SSPI	SIEMENS MR VA0  GEN	Sequence Control Mask	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",17)	25	23	0	0	0	0	IS	1	DLX	DLX_SERIE_01	Spatial Filter Strength	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",17)	25	23	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Series Plane	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",17)	25	23	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",17)	25	23	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Largest Sample Value 2	f	t	\N	\N	\N
(0019,"SPI-P-Private-DCI Release 1",17)	25	23	0	0	0	0	UN	1	PSPI	SPI-P-Private-DCI Release 1	?	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",18)	25	24	0	0	0	0	IS	1	DLX	DLX_SERIE_01	Zoom Factor	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",18)	25	24	0	0	0	0	LO	1	GEM	GEMS_ACQU_01	First Scan RAS	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",18)	25	24	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Heartbeat Interval	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",18)	25	24	0	0	0	0	UN	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",18)	25	24	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Number Of Samples 2	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",18)	25	24	0	0	0	0	UL	1	SSPI	SIEMENS MR VA0  GEN	Measurement Status Mask	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",19)	25	25	0	0	0	0	IS	1	DLX	DLX_SERIE_01	X Zoom Center	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",19)	25	25	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	First Scan Location	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",19)	25	25	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Repetition Time FFE	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",19)	25	25	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Sample Data 2	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",1a)	25	26	0	0	0	0	IS	1	DLX	DLX_SERIE_01	Y Zoom Center	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",1a)	25	26	0	0	0	0	LO	1	GEM	GEMS_ACQU_01	Last Scan RAS	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",1a)	25	26	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	FFE Flip Angle	f	t	\N	\N	\N
(0019,"SPI-P Release 1;1",1a)	25	26	0	0	0	0	UN	1	PSPI	SPI-P Release 1;1	Sample Rate 2	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",1b)	25	27	0	0	0	0	DS	1	DLX	DLX_SERIE_01	Focus	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",1b)	25	27	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Last Scan Location	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",1b)	25	27	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Scans	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",1c)	25	28	0	0	0	0	CS	1	DLX	DLX_SERIE_01	Dose	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",1d)	25	29	0	0	0	0	IS	1	DLX	DLX_SERIE_01	Side Mark	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",1e)	25	30	0	0	0	0	IS	1	DLX	DLX_SERIE_01	Percentage Landscape	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",1e)	25	30	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Display Field Of View	f	t	\N	\N	\N
(0019,"DLX_SERIE_01",1f)	25	31	0	0	0	0	DS	1	DLX	DLX_SERIE_01	Exposure Duration	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",20)	25	32	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SPI-P-XSB-DCI Release 1",20)	25	32	0	0	0	0	DS	1	PSPI	SPI-P-XSB-DCI Release 1	RTD Data Compression Factor	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",20)	25	32	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",20)	25	32	0	0	0	0	TM	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",20)	25	32	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Exposure Time	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",20)	25	32	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Transmitter Amplitude	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",20)	25	32	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  COAD	Number of Possible Channels	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",20)	25	32	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Fourier Lines Nominal	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",20)	25	32	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",20)	25	32	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",20)	25	32	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  CMS",20)	25	32	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Measurement Mode	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",20)	25	32	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	MPM Code	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",21)	25	33	0	0	0	0	DS	1-n	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",21)	25	33	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",21)	25	33	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Exposure Current	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",21)	25	33	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  COAD	Mean Channel Number	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",21)	25	33	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  COAD	Number of Transmitter Amplitudes	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",21)	25	33	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Fourier Lines Current	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",21)	25	33	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Latitude	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",22)	25	34	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",22)	25	34	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Dynamic Scan Time Begin	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",22)	25	34	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",22)	25	34	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Detector Spacing	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",22)	25	34	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Transmitter Attenuator	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",22)	25	34	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",22)	25	34	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",22)	25	34	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",22)	25	34	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Sensitivity	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",23)	25	35	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Table Speed	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",23)	25	35	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",23)	25	35	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Detector Center	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",23)	25	35	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	EDR	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",24)	25	36	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Mid Scan Time	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",24)	25	36	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",24)	25	36	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",24)	25	36	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Reading Integration Time	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",24)	25	36	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Transmitter Calibration	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",24)	25	36	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",24)	25	36	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",24)	25	36	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	L Fix	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",24)	25	36	0	0	0	0	LT	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",25)	25	37	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Mid Scan Flag	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",25)	25	37	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",25)	25	37	0	0	0	0	LT	1-n	PSPI	SPI-P Release 1	Original Pixel Data Quality	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",25)	25	37	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	KVP Generator Power Current	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",25)	25	37	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	S Fix	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",26)	25	38	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Degrees Of Azimuth	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",26)	25	38	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",26)	25	38	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Generator Voltage	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",26)	25	38	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Transmitter Reference	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",26)	25	38	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Fourier Lines after Zero	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",26)	25	38	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",26)	25	38	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",26)	25	38	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",26)	25	38	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Preset Mode	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",27)	25	39	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Gantry Period	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",27)	25	39	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",27)	25	39	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Region	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",28)	25	40	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",28)	25	40	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	First Measured Fourier Line	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",28)	25	40	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",28)	25	40	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",28)	25	40	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",28)	25	40	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Subregion	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",29)	25	41	0	0	0	0	IS	1-n	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",2a)	25	42	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Xray On Position	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",2a)	25	42	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",2a)	25	42	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",2a)	25	42	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",2b)	25	43	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Xray Off Position	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",2c)	25	44	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Number Of Triggers	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",2c)	25	44	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",2c)	25	44	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",2c)	25	44	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",2d)	25	45	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",2e)	25	46	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Angle Of First View	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",2e)	25	46	0	0	0	0	UN	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",2e)	25	46	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",2e)	25	46	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",2f)	25	47	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Trigger Frequency	f	t	\N	\N	\N
(0019,"GE ??? From Adantage Review CS",30)	25	48	0	0	0	0	LO	1	GEM	GE ??? From Adantage Review CS	CR EDR Mode	f	t	\N	\N	\N
(0019,"CARDIO-D.R. 1.0",30)	25	48	0	0	0	0	UL	1	PDIC	CARDIO-D.R. 1.0	Maximum Image Frame Size	f	t	\N	\N	\N
(0019,"SPI-P-Private_ICS Release 1",30)	25	48	0	0	0	0	DS	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",30)	25	48	0	0	0	0	US	1	PSPI	SPI-P Release 1	ECG Triggering	f	t	\N	\N	\N
(0019,"SPI-P-PCR Release 2",30)	25	48	0	0	0	0	US	1	PSPI	SPI-P-PCR Release 2	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",30)	25	48	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Acquisition Columns	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",30)	25	48	0	0	0	0	UN	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",30)	25	48	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",30)	25	48	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  CMS",30)	25	48	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Calculation Mode	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",30)	25	48	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Orientation	f	t	\N	\N	\N
(0019,"SPI-P-Private_ICS Release 1",31)	25	49	0	0	0	0	LO	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",31)	25	49	0	0	0	0	UN	1	PSPI	SPI-P Release 1	ECG 1 Offset	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",31)	25	49	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",31)	25	49	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Reconstruction Columns	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",31)	25	49	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Mark On Film	f	t	\N	\N	\N
(0019,"SPI-P Release 1",32)	25	50	0	0	0	0	UN	1	PSPI	SPI-P Release 1	ECG 2 Offset 1	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",32)	25	50	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",32)	25	50	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",32)	25	50	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",32)	25	50	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",32)	25	50	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Rotation On DRC	f	t	\N	\N	\N
(0019,"SPI-P Release 1",33)	25	51	0	0	0	0	UN	1	PSPI	SPI-P Release 1	ECG 2 Offset 2	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",34)	25	52	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",34)	25	52	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",34)	25	52	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",36)	25	54	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",36)	25	54	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",36)	25	54	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",38)	25	56	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",38)	25	56	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",38)	25	56	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",39)	25	57	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Scan FOV Type	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",39)	25	57	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Axial Type	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",3a)	25	58	0	0	0	0	IS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",3a)	25	58	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",3a)	25	58	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",3a)	25	58	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",3b)	25	59	0	0	0	0	LT	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",3c)	25	60	0	0	0	0	UN	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",3c)	25	60	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",3c)	25	60	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",3c)	25	60	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",3e)	25	62	0	0	0	0	UN	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",3e)	25	62	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",3e)	25	62	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",3e)	25	62	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",3f)	25	63	0	0	0	0	UN	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GE ??? From Adantage Review CS",40)	25	64	0	0	0	0	LO	1	GEM	GE ??? From Adantage Review CS	CR Latitude	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",40)	25	64	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Stat Recon Flag	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",40)	25	64	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Array Coil Element Number	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",40)	25	64	0	0	0	0	UL	1	SSPI	SIEMENS CT VA0  GEN	Master Control Mask	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",40)	25	64	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",40)	25	64	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",40)	25	64	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",40)	25	64	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Reader Type	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",41)	25	65	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Compute Type	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",41)	25	65	0	0	0	0	LT	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",41)	25	65	0	0	0	0	UL	1	SSPI	SIEMENS MR VA0  GEN	Array Coil Element Select Mask	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",41)	25	65	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Sub Modality	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",42)	25	66	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Segment Number	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",42)	25	66	0	0	0	0	IS	2	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",42)	25	66	0	0	0	0	UL	1	SSPI	SIEMENS MR VA0  GEN	Array Coil Element Data Mask	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",42)	25	66	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",42)	25	66	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",42)	25	66	0	0	0	0	US	5	SSPI	SIEMENS CT VA0  GEN	Processing Mask	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",42)	25	66	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Reader Serial Number	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",43)	25	67	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Total Segments Requested	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",43)	25	67	0	0	0	0	IS	2	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",43)	25	67	0	0	0	0	IS	1-n	SSPI	SIEMENS MR VA0  GEN	Array Coil Element To ADC Connect	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",44)	25	68	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Interscan Delay	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",44)	25	68	0	0	0	0	DS	1-n	SSPI	SIEMENS MR VA0  GEN	Array Coil Element Noise Level	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",44)	25	68	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",44)	25	68	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",44)	25	68	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",44)	25	68	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  GEN	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",45)	25	69	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Reconstruction Resolution	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",45)	25	69	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",45)	25	69	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Array Coil ADC Pair Number	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",45)	25	69	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  GEN	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",46)	25	70	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",46)	25	70	0	0	0	0	UL	1	SSPI	SIEMENS MR VA0  GEN	Array Coil Combination Mask	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",46)	25	70	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",46)	25	70	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",46)	25	70	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",47)	25	71	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	View Compression Factor	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",47)	25	71	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",48)	25	72	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",48)	25	72	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",48)	25	72	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",48)	25	72	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",48)	25	72	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",49)	25	73	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",49)	25	73	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",4a)	25	74	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Total Number Of Ref Channels	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",4a)	25	74	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",4a)	25	74	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",4a)	25	74	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",4b)	25	75	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Data Size For Scan Data	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",4c)	25	76	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",4c)	25	76	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",4c)	25	76	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",4e)	25	78	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",4e)	25	78	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GE ??? From Adantage Review CS",50)	25	80	0	0	0	0	LO	1	GEM	GE ??? From Adantage Review CS	CR Group Number	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",50)	25	80	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",50)	25	80	0	0	0	0	UN	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",50)	25	80	0	0	0	0	US	1	PSPI	SPI-P Release 1	Video Scan Mode	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",50)	25	80	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Detector Alignment	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",50)	25	80	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Receiver Total Gain	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  CMS",50)	25	80	0	0	0	0	IS	1	SSPI	SIEMENS CM VA0  CMS	Noise Level	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",50)	25	80	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Averages Current	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",50)	25	80	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",50)	25	80	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",50)	25	80	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",50)	25	80	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Cassette Scale	f	t	\N	\N	\N
(0019,"SPI-P Release 1",51)	25	81	0	0	0	0	US	1	PSPI	SPI-P Release 1	Video LineRate	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",51)	25	81	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Receiver Amplifier Gain	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",51)	25	81	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Cassette Matrix	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",52)	25	82	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Recon Post Processing Flag	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",52)	25	82	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	? 	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",52)	25	82	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Receiver Preamplifier Gain	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",52)	25	82	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",52)	25	82	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",52)	25	82	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",52)	25	82	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Cassette Submatrix	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",53)	25	83	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Barcode	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",54)	25	84	0	0	0	0	UN	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",54)	25	84	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	? 	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",54)	25	84	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Receiver Cable Attenuation	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",54)	25	84	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",54)	25	84	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",54)	25	84	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",55)	25	85	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Receiver Reference Gain	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",56)	25	86	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Receiver Filter Frequency	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",56)	25	86	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",56)	25	86	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",56)	25	86	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",57)	25	87	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	CT Water Number	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",58)	25	88	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	CT Bone Number	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",58)	25	88	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",58)	25	88	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",58)	25	88	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",5a)	25	90	0	0	0	0	FL	1	GEM	GEMS_ACQU_01	Acquisition Duration	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",5a)	25	90	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",5a)	25	90	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",5a)	25	90	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",5c)	25	92	0	0	0	0	UN	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",5c)	25	92	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",5c)	25	92	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",5d)	25	93	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",5e)	25	94	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Number Of Channels 1 To 512	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",5e)	25	94	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",5e)	25	94	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",5e)	25	94	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",5f)	25	95	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Increment Between Channels	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",60)	25	96	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Starting View	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",60)	25	96	0	0	0	0	DS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",60)	25	96	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",60)	25	96	0	0	0	0	US	1	PSPI	SPI-P Release 1	Xray Technique	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",60)	25	96	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Focus Alignment	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",60)	25	96	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Reconstruction Scale Factor	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",60)	25	96	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Flip Angle	f	t	\N	\N	\N
(0019,"SIEMENS CM VA0  CMS",60)	25	96	0	0	0	0	IS	1	SSPI	SIEMENS CM VA0  CMS	Number of Data Bytes	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",60)	25	96	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",60)	25	96	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",60)	25	96	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",60)	25	96	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	GT - Contrast Type	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",61)	25	97	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Number Of Views	f	t	\N	\N	\N
(0019,"SPI-P Release 1",61)	25	97	0	0	0	0	DS	1	PSPI	SPI-P Release 1	Image Identifier Fromat	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",61)	25	97	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",61)	25	97	0	0	0	0	US	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",61)	25	97	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	GA - Rotation Amount	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",62)	25	98	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Increment Between Views	f	t	\N	\N	\N
(0019,"SPI-P Release 1",62)	25	98	0	0	0	0	US	1	PSPI	SPI-P Release 1	Iris Diaphragm	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",62)	25	98	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Reference Scale Factor	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",62)	25	98	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Number of Virtuell Channels	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",62)	25	98	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",62)	25	98	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",62)	25	98	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	GC - Rotation Center	f	t	\N	\N	\N
(0019,"SPI-P Release 1",63)	25	99	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Filter	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",63)	25	99	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",63)	25	99	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	GS - Density Shift	f	t	\N	\N	\N
(0019,"SPI-P Release 1",64)	25	100	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Cine Parallel	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",64)	25	100	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Repetition Time SE	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",64)	25	100	0	0	0	0	US	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",64)	25	100	0	0	0	0	US	1	SSPI	SIEMENS DLR.01	RN - Frequency Rank	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",64)	25	100	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",64)	25	100	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",64)	25	100	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",65)	25	101	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Cine Master	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",65)	25	101	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Repetition Time IR	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",65)	25	101	0	0	0	0	IS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",65)	25	101	0	0	0	0	UL	1	SSPI	SIEMENS CT VA0  COAD	Focal Spot Deflection Amplitude	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",65)	25	101	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	RE - Frequency Enhancement	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",66)	25	102	0	0	0	0	UL	1	SSPI	SIEMENS CT VA0  COAD	Focal Spot Deflection Phase	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",66)	25	102	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",66)	25	102	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",66)	25	102	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",66)	25	102	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	RT - Frequency Type	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",67)	25	103	0	0	0	0	UL	1	SSPI	SIEMENS CT VA0  COAD	Focal Spot Deflection Offset	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",67)	25	103	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Kernel Length	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",68)	25	104	0	0	0	0	UL	1	SSPI	SIEMENS DLR.01	Kernel Mode	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",68)	25	104	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",68)	25	104	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",68)	25	104	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",69)	25	105	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Phases	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",69)	25	105	0	0	0	0	UL	1	SSPI	SIEMENS DLR.01	Convolution Mode	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",6a)	25	106	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Dependant On Number Of Views Processed	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",6a)	25	106	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Cardiac Frequency	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",6a)	25	106	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",6a)	25	106	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",6a)	25	106	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",6b)	25	107	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Field Of View In Detector Cells	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",6b)	25	107	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Inversion Delay	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",6c)	25	108	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Gate Delay	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",6c)	25	108	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",6c)	25	108	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",6d)	25	109	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Gate Width	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",6e)	25	110	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Trigger Delay Time	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",6e)	25	110	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",6e)	25	110	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GE ??? From Adantage Review CS",70)	25	112	0	0	0	0	LO	1	GEM	GE ??? From Adantage Review CS	CR Image Serial Number	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",70)	25	112	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Value Of Back Projection Button	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",70)	25	112	0	0	0	0	LT	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",70)	25	112	0	0	0	0	UN	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",70)	25	112	0	0	0	0	US	1	PSPI	SPI-P Release 1	Exposure Channel	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",70)	25	112	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Water Scaling Factor	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",70)	25	112	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Phase Gradient Amplitude	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",70)	25	112	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Number of Readings	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",70)	25	112	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Prescans	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",70)	25	112	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",70)	25	112	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",70)	25	112	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	PLA Source	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",71)	25	113	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Set If Fatq Estimates Were Used	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",71)	25	113	0	0	0	0	IS	1-n	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",71)	25	113	0	0	0	0	UN	1	PSPI	SPI-P Release 1	Exposure Channel First Image	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",71)	25	113	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Interpolation Factor	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",71)	25	113	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Readout Gradient Amplitude	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",71)	25	113	0	0	0	0	LT	1-n	SSPI	SIEMENS CT VA0  GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",71)	25	113	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	PLA Destination	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",72)	25	114	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Z Channel Avg Over Views	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",72)	25	114	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",72)	25	114	0	0	0	0	US	1	PSPI	SPI-P Release 1	Processing Channel	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",72)	25	114	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Selection Gradient Amplitude	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",72)	25	114	0	0	0	0	UN	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",72)	25	114	0	0	0	0	UN	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",72)	25	114	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",73)	25	115	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Avg Of Left Ref Channels Over Views	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",73)	25	115	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",74)	25	116	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Max Left Channel Over Views	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",74)	25	116	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",74)	25	116	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Number of Projections	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",74)	25	116	0	0	0	0	UN	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",74)	25	116	0	0	0	0	UN	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",74)	25	116	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",75)	25	117	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Avg Of Right Ref Channels Over Views	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",75)	25	117	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Number of Bytes	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",75)	25	117	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	UID Original Image	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",76)	25	118	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Max Right Channel Over Views	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",76)	25	118	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",76)	25	118	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",76)	25	118	0	0	0	0	UN	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",76)	25	118	0	0	0	0	UN	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",76)	25	118	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",77)	25	119	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",78)	25	120	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",78)	25	120	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",78)	25	120	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",78)	25	120	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",79)	25	121	0	0	0	0	US	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",7a)	25	122	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",7a)	25	122	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",7a)	25	122	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",7c)	25	124	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",7c)	25	124	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",7c)	25	124	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",7d)	25	125	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Second Echo	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",7e)	25	126	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Number Of Echos	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",7e)	25	126	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",7e)	25	126	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",7e)	25	126	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",7f)	25	127	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Table Delta	f	t	\N	\N	\N
(0019,"GE ??? From Adantage Review CS",80)	25	128	0	0	0	0	LO	1	GEM	GE ??? From Adantage Review CS	CR Bar Code Number	f	t	\N	\N	\N
(0019,"SPI-P Release 1",80)	25	128	0	0	0	0	DS	1	PSPI	SPI-P Release 1	Acquisition Delay	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",80)	25	128	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Chemical Shifts	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",80)	25	128	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR SPECTRO;1",80)	25	128	0	0	0	0	IS	1	PSPI	PHILIPS MR SPECTRO;1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",80)	25	128	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  COAD	Gradient Delay Time	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",80)	25	128	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  GEN	Reconstruction Algorithm Set	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",80)	25	128	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",80)	25	128	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",80)	25	128	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",80)	25	128	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  COAD	Patient Region	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",80)	25	128	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Reader Header	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",81)	25	129	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Contiguous	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",81)	25	129	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Chemical Shift	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",81)	25	129	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",81)	25	129	0	0	0	0	UN	1	PSPI	SPI-P Release 1	Relative Image Time	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",81)	25	129	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  GEN	Reconstruction Algorithm Index	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",81)	25	129	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  GEN	Filter Type for Raw Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",82)	25	130	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",82)	25	130	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Total Gradient Delay Time	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",82)	25	130	0	0	0	0	DS	1-n	SSPI	SIEMENS MR VA0  GEN	Filter Parameter for Raw Data	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",82)	25	130	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",82)	25	130	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",82)	25	130	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",82)	25	130	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  COAD	Patient Phase of Life	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",82)	25	130	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  GEN	Regeneration Software Version	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",83)	25	131	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",83)	25	131	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  GEN	Filter Type for Image Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",84)	25	132	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Peak SAR	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",84)	25	132	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Rows	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",84)	25	132	0	0	0	0	DS	1-n	SSPI	SIEMENS MR VA0  GEN	Filter Parameter for Image Data	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",84)	25	132	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",84)	25	132	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",84)	25	132	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",85)	25	133	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Monitor SAR	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",85)	25	133	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Samples	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",85)	25	133	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  GEN	Filter Type for Phase Correction	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",86)	25	134	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",86)	25	134	0	0	0	0	DS	1-n	SSPI	SIEMENS MR VA0  GEN	Filter Parameter for Phase Correction	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",86)	25	134	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",86)	25	134	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",86)	25	134	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",87)	25	135	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Cardiac Repetition Time	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",87)	25	135	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  GEN	Normalization Filter Type for Image Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",88)	25	136	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Images Per Cardiac Cycle	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  GEN",88)	25	136	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",88)	25	136	0	0	0	0	DS	1-n	SSPI	SIEMENS MR VA0  GEN	Normalization Filter Parameter for Image Data	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",88)	25	136	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",88)	25	136	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",88)	25	136	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",8a)	25	138	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Actual Receive Gain Analog	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",8a)	25	138	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",8a)	25	138	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",8a)	25	138	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",8b)	25	139	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Actual Receive Gain Digital	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",8c)	25	140	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",8c)	25	140	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",8c)	25	140	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",8d)	25	141	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Delay After Trigger	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",8e)	25	142	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",8e)	25	142	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",8e)	25	142	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",8f)	25	143	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Swap Phase Frequency	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",8f)	25	143	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Swap Phase Frequency	f	t	\N	\N	\N
(0019,"GE ??? From Adantage Review CS",90)	25	144	0	0	0	0	LO	1	GEM	GE ??? From Adantage Review CS	CR Film Output Exposures	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",90)	25	144	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Pause Interval	f	t	\N	\N	\N
(0019,"SPI-P Release 1",90)	25	144	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Video White Compression	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",90)	25	144	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",90)	25	144	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Osteo Offset	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",90)	25	144	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Saturation Regions	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",90)	25	144	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",90)	25	144	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",90)	25	144	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	PLA of Secondary Destination	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",90)	25	144	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  COAD	Sensitivity Correction Label	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",91)	25	145	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Pulse Time	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",91)	25	145	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  COAD	Saturation Phase Encoding Vector Coronal Component	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",91)	25	145	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  GEN	Saturation Phase Encoding Vector Sagittal Component	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",92)	25	146	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Slice Offset On Frequency Axis	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",92)	25	146	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  COAD	Saturation Readout Vector Coronal Component	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",92)	25	146	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  GEN	Saturation Readout Vector Sagittal Component	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",92)	25	146	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",92)	25	146	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",92)	25	146	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",93)	25	147	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Center Frequency	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",93)	25	147	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Osteo Regression Line Intercept	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",93)	25	147	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	EPI Stimulation Monitor Mode	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",94)	25	148	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Transmit Gain	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",94)	25	148	0	0	0	0	LO	1	PSPI	PHILIPS MR/PART	Magnetization Transfer Contrast	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",94)	25	148	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	Osteo Standardization Code	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",94)	25	148	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Image Rotation Angle	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",94)	25	148	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",94)	25	148	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",94)	25	148	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",95)	25	149	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Analog Receiver Gain	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",95)	25	149	0	0	0	0	LO	1	PSPI	PHILIPS MR/PART	Spectral Presaturation With Inversion Recovery	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",96)	25	150	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Digital Receiver Gain	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",96)	25	150	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",96)	25	150	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  COAD	Osteo Phantom Number	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",96)	25	150	0	0	0	0	UL	3	SSPI	SIEMENS MR VA0  GEN	Coil ID Mask	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",96)	25	150	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",96)	25	150	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",96)	25	150	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",97)	25	151	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Bitmap Defining CVs	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",97)	25	151	0	0	0	0	LO	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",97)	25	151	0	0	0	0	UL	2	SSPI	SIEMENS MR VA0  GEN	Coil Class Mask	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",98)	25	152	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Center Frequency Method	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",98)	25	152	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  GEN	Coil Position	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",98)	25	152	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",98)	25	152	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",98)	25	152	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",99)	25	153	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",9a)	25	154	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",9a)	25	154	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",9a)	25	154	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",9b)	25	155	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Pulse Sequence Mode	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",9c)	25	156	0	0	0	0	LO	1	GEM	GEMS_ACQU_01	Pulse Sequence Name	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",9c)	25	156	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Pulse Sequence Name	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",9c)	25	156	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",9c)	25	156	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",9c)	25	156	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",9d)	25	157	0	0	0	0	DT	1	GEM	GEMS_ACQU_01	Pulse Sequence Date	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",9e)	25	158	0	0	0	0	LO	1	GEM	GEMS_ACQU_01	Internal Pulse Sequence Name	f	t	\N	\N	\N
(0019,"SIEMENS RA GEN",9e)	25	158	0	0	0	0	US	1-n	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",9e)	25	158	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",9e)	25	158	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",9f)	25	159	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Transmitting Coil	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",9f)	25	159	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Coil Type	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a0)	25	160	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Surface Coil Type	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",a0)	25	160	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SPI-P Release 1",a0)	25	160	0	0	0	0	US	1	PSPI	SPI-P Release 1	Angulation	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",a0)	25	160	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",a0)	25	160	0	0	0	0	DS	1	SSPI	SIEMENS DLR.01	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",a0)	25	160	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	EPI Reconstruction Phase	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",a0)	25	160	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",a0)	25	160	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",a0)	25	160	0	0	0	0	US	3	SSPI	SIEMENS MR VA0  COAD	RF Watchdog Mask	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a1)	25	161	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Extremity Coil Flag	f	t	\N	\N	\N
(0019,"SPI-P Release 1",a1)	25	161	0	0	0	0	US	1	PSPI	SPI-P Release 1	Rotation	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",a1)	25	161	0	0	0	0	US	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",a1)	25	161	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS DLR.01",a1)	25	161	0	0	0	0	DS	1	SSPI	SIEMENS DLR.01	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",a1)	25	161	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	EPI Reconstruction Slope	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  GEN",a1)	25	161	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	EPI Reconstruction Slope	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a2)	25	162	0	0	0	0	SL	1	GEM	GEMS_ACQU_01	Raw Data Run Number	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",a2)	25	162	0	0	0	0	US	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",a2)	25	162	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	RF Power Error Indicator	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",a2)	25	162	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",a2)	25	162	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a3)	25	163	0	0	0	0	UL	1	GEM	GEMS_ACQU_01	Calibrated Field Strength	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",a3)	25	163	0	0	0	0	US	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",a3)	25	163	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",a3)	25	163	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a4)	25	164	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Fat Water Bone	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",a4)	25	164	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	SAT Fat Water Bone	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",a4)	25	164	0	0	0	0	CS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",a4)	25	164	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",a4)	25	164	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",a4)	25	164	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a5)	25	165	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Receive Bandwidth	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",a5)	25	165	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",a5)	25	165	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  COAD	Specific Absorption Rate Whole Body	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",a6)	25	166	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  COAD	Specific Energy Dose	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",a6)	25	166	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",a6)	25	166	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",a6)	25	166	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a7)	25	167	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",a7)	25	167	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a8)	25	168	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",a8)	25	168	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",a8)	25	168	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",a8)	25	168	0	0	0	0	US	1-n	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",a9)	25	169	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",a9)	25	169	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",aa)	25	170	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",aa)	25	170	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",aa)	25	170	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",aa)	25	170	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",ab)	25	171	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",ab)	25	171	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",ac)	25	172	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",ac)	25	172	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE A",ac)	25	172	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE A	?	f	t	\N	\N	\N
(0019,"SIEMENS RA PLANE B",ac)	25	172	0	0	0	0	US	1	SSPI	SIEMENS RA PLANE B	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",ad)	25	173	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",ad)	25	173	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",ae)	25	174	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",ae)	25	174	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",af)	25	175	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SIEMENS CT VA0  COAD",af)	25	175	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  COAD	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b0)	25	176	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",b0)	25	176	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",b0)	25	176	0	0	0	0	UL	1	SSPI	SIEMENS MR VA0  COAD	Adjustment Status Mask	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b1)	25	177	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",b1)	25	177	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	Minimum RR Interval	f	t	\N	\N	\N
(0019,"SPI-P-GV-CT Release 1",b1)	25	177	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b2)	25	178	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",b2)	25	178	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	Maximum RR Interval	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b3)	25	179	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",b3)	25	179	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	Number of Rejections	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b4)	25	180	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",b4)	25	180	0	0	0	0	IS	1-n	PSPI	PHILIPS MR/LAST	Number of RR Intervals	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b5)	25	181	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",b5)	25	181	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	Arrhythmia Rejection	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b6)	25	182	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b7)	25	183	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b8)	25	184	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",b9)	25	185	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",ba)	25	186	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",bb)	25	187	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",bc)	25	188	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",bd)	25	189	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",be)	25	190	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Projection Angle	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c0)	25	192	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Saturation Planes	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",c0)	25	192	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Bitmap Of SAT Selections	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",c0)	25	192	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Trigger Delay Times	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",c0)	25	192	0	0	0	0	DS	1-n	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c1)	25	193	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Surface Coil Intensity Correction Flag	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",c1)	25	193	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Surface Coil Intensity Correction Flag	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",c1)	25	193	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  COAD	EPI Capacity	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c2)	25	194	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Location R	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",c2)	25	194	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  COAD	EPI Inductance	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c3)	25	195	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Location L	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",c3)	25	195	0	0	0	0	IS	1-n	SSPI	SIEMENS MR VA0  COAD	EPI Switch Configuration Code	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c4)	25	196	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Location A	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",c4)	25	196	0	0	0	0	IS	1-n	SSPI	SIEMENS MR VA0  COAD	EPI Switch Hardware Code	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c5)	25	197	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Location P	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",c5)	25	197	0	0	0	0	DS	1-n	SSPI	SIEMENS MR VA0  COAD	EPI Switch Delay Time	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c6)	25	198	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Location H	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",c6)	25	198	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	Cycled Multiple Slice	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c7)	25	199	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Location F	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c8)	25	200	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Thickness R L	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",c8)	25	200	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",c9)	25	201	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Thickness A P	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",c9)	25	201	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Foldover Direction Transverse	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",ca)	25	202	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	SAT Thickness H F	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",ca)	25	202	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Foldover Direction Sagittal	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",cb)	25	203	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Prescribed Flow Axis	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",cb)	25	203	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Phase Contrast Flow Axis	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",cb)	25	203	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Foldover Direction Coronal	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",cc)	25	204	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Velocity Encoding	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",cc)	25	204	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Phase Contrast Velocity Encoding	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",cc)	25	204	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",cd)	25	205	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Thickness Disclaimer	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",cd)	25	205	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",ce)	25	206	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Prescan Type	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",ce)	25	206	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	REST	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",ce)	25	206	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",cf)	25	207	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Prescan Status	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",cf)	25	207	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Echoes	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d0)	25	208	0	0	0	0	SH	1	GEM	GEMS_ACQU_01	Raw Data Type	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",d0)	25	208	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Scan Resolution	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d1)	25	209	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Flow Sensitivity	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d2)	25	210	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Projection Algorithm	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",d2)	25	210	0	0	0	0	LO	2	PSPI	PHILIPS MR/PART	Water Fat Shift	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d2)	25	210	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  COAD	Calculation Submode	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d3)	25	211	0	0	0	0	SH	1	GEM	GEMS_ACQU_01	Projection Algorithm	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d3)	25	211	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  COAD	Field of View Ratio	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d4)	25	212	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",d4)	25	212	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Artifact Reduction	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d4)	25	212	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  COAD	Base Raw Matrix Size	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d5)	25	213	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Fractional Echo	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",d5)	25	213	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Fractional Echo	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",d5)	25	213	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",d5)	25	213	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d5)	25	213	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  COAD	2D Oversampling Lines	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d6)	25	214	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Prep Pulse	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",d6)	25	214	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	Fourier Interpolation	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",d6)	25	214	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d6)	25	214	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  COAD	3D Phase Oversampling Partitions	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d7)	25	215	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Cardiac Phases	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",d7)	25	215	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Scan Percentage	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d7)	25	215	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  COAD	Echo Line Position	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d8)	25	216	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Variable Echo Flag	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",d8)	25	216	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Variable Echo Flag	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",d8)	25	216	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Halfscan	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d8)	25	216	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  COAD	Echo Column Position	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",d9)	25	217	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Concatenated SAT	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",d9)	25	217	0	0	0	0	DS	1	GEM	GE_GENESIS_REV3.0	Concatenated Sat	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",d9)	25	217	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	EPI Factor	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",d9)	25	217	0	0	0	0	IS	1-n	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",d9)	25	217	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  COAD	Lines Per Segment	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",da)	25	218	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Reference Channel Used	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",da)	25	218	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Turbo Factor	f	t	\N	\N	\N
(0019,"SIEMENS MR VA0  COAD",da)	25	218	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  COAD	PhaseCodingDirection	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",db)	25	219	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Back Projector Coefficient	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",db)	25	219	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",dc)	25	220	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Primary Speed Correction Used	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",dd)	25	221	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Overrange Correction Used	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",de)	25	222	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Dynamic Z Alpha Value	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",df)	25	223	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e0)	25	224	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	User Data	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",e0)	25	224	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	Prepulse	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",e0)	25	224	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Percentage of Scan Completed	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",e0)	25	224	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Prepulse Type	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e1)	25	225	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",e1)	25	225	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	Prepulse Delay	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",e1)	25	225	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Prepulse Delay	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",e1)	25	225	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e2)	25	226	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Velocity Encode Scale	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",e2)	25	226	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e3)	25	227	0	0	0	0	LT	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",e3)	25	227	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",e3)	25	227	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Phase Contrast Velocity	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e4)	25	228	0	0	0	0	LT	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e5)	25	229	0	0	0	0	IS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e6)	25	230	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e8)	25	232	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",e9)	25	233	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",eb)	25	235	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",ec)	25	236	0	0	0	0	US	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",f0)	25	240	0	0	0	0	UN	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",f0)	25	240	0	0	0	0	LT	1	PSPI	PHILIPS MR/LAST	WS Protocol String 1	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",f1)	25	241	0	0	0	0	LT	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",f1)	25	241	0	0	0	0	LT	1	PSPI	PHILIPS MR/LAST	WS Protocol String 2	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",f2)	25	242	0	0	0	0	SS	1	GEM	GEMS_ACQU_01	Fast Phases	f	t	\N	\N	\N
(0019,"GE_GENESIS_REV3.0",f2)	25	242	0	0	0	0	SS	1	GEM	GE_GENESIS_REV3.0	Number Of Phases	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",f2)	25	242	0	0	0	0	LT	1	PSPI	PHILIPS MR/LAST	WS Protocol String 3	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",f3)	25	243	0	0	0	0	LT	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"PHILIPS MR/LAST",f3)	25	243	0	0	0	0	LT	1	PSPI	PHILIPS MR/LAST	WS Protocol String 4	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",f4)	25	244	0	0	0	0	LT	1	GEM	GEMS_ACQU_01	?	f	t	\N	\N	\N
(0019,"GEMS_ACQU_01",f9)	25	249	0	0	0	0	DS	1	GEM	GEMS_ACQU_01	Transmission Gain	f	t	\N	\N	\N
(0019,"PHILIPS MR/PART",fc)	25	252	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Resonance Frequency	f	t	\N	\N	\N
(0021,"PHILIPS MR/LAST",00)	33	0	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",00)	33	0	0	0	0	0	DA	1	PSPI	PHILIPS MR/PART	Scan Date	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",00)	33	0	0	0	0	0	DA	1	PSPI	PHILIPS MR/PART	Series Date	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",00)	33	0	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Reconstruction Number	f	t	\N	\N	\N
(0021,"SPI-P-Private-CWS Release 1",00)	33	0	0	0	0	0	LT	1	PSPI	SPI-P-Private-CWS Release 1	Window Of Images ID	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",00)	33	0	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  RAW	Sequence Type	f	t	\N	\N	\N
(0021,"PHILIPS-MR-1",01)	33	1	0	0	0	0	IS	1	PDIC	PHILIPS-MR-1	Reconstruction Number	f	t	\N	\N	\N
(0021,"SPI-P-Private-CWS Release 1",01)	33	1	0	0	0	0	CS	1	PSPI	SPI-P-Private-CWS Release 1	Window Of Images Type	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",01)	33	1	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  RAW	Vector Size Original	f	t	\N	\N	\N
(0021,"TOSHIBA_MEC_1.0",01)	33	1	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0021,"PHILIPS-MR-1",02)	33	2	0	0	0	0	IS	1	PDIC	PHILIPS-MR-1	Slice Number	f	t	\N	\N	\N
(0021,"SPI-P-Private-CWS Release 1",02)	33	2	0	0	0	0	IS	1-n	PSPI	SPI-P-Private-CWS Release 1	WindowOfImagesScope	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",02)	33	2	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  RAW	Vector Size Extended	f	t	\N	\N	\N
(0021,"TOSHIBA_MEC_1.0",02)	33	2	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",03)	33	3	0	0	0	0	SS	1	GEM	GEMS_RELA_01	Series From Which Prescribed	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",03)	33	3	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	Acquired Spectral Range	f	t	\N	\N	\N
(0021,"TOSHIBA_MEC_1.0",03)	33	3	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",04)	33	4	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  RAW	VOI Position	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",05)	33	5	0	0	0	0	SH	1	GEM	GEMS_RELA_01	Genesis Version Now	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",05)	33	5	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  RAW	VOI Size	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",06)	33	6	0	0	0	0	IS	3	SSPI	SIEMENS MR VA0  RAW	CSI Matrix Size Original	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",07)	33	7	0	0	0	0	UL	1	GEM	GEMS_RELA_01	Series Record Checksum	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",07)	33	7	0	0	0	0	IS	3	SSPI	SIEMENS MR VA0  RAW	CSI Matrix Size Extended	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",08)	33	8	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  RAW	Spatial Grid Shift	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",09)	33	9	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	Signal Limits Minimum	f	t	\N	\N	\N
(0021,"PHILIPS MR/LAST",10)	33	16	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",10)	33	16	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Image Type	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",10)	33	16	0	0	0	0	TM	1	PSPI	PHILIPS MR/PART	Scan Time	f	t	\N	\N	\N
(0021,"SIEMENS MED",10)	33	16	0	0	0	0	DS	1	SSPI	SIEMENS MED	Zoom	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",10)	33	16	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	Signal Limits Maximum	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",10)	33	16	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Rotation Angle	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",10)	33	16	0	0	0	0	UL	2	SSPI	SIEMENS CT VA0  RAW	Creation Mask	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",11)	33	17	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	Spec Info Mask	f	t	\N	\N	\N
(0021,"SIEMENS MED",11)	33	17	0	0	0	0	DS	2	SSPI	SIEMENS MED	Target	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",11)	33	17	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Start Angle	f	t	\N	\N	\N
(0021,"SPI-P Release 1",12)	33	18	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Series Unique Identifier	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",12)	33	18	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Time Rate of Change of Magnitude	f	t	\N	\N	\N
(0021,"SIEMENS MED",12)	33	18	0	0	0	0	IS	1	SSPI	SIEMENS MED	Tube Angle	f	t	\N	\N	\N
(0021,"CARDIO-D.R. 1.0",13)	33	19	0	0	0	0	IS	1	PDIC	CARDIO-D.R. 1.0	Image Sequence Number	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",13)	33	19	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Time Rate of Change of X Component	f	t	\N	\N	\N
(0021,"SPI-P Release 1",14)	33	20	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",14)	33	20	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Time Rate of Change of Y Component	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",15)	33	21	0	0	0	0	US	1	GEM	GEMS_RELA_01	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",15)	33	21	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Time Rate of Change of Z Component	f	t	\N	\N	\N
(0021,"SIEMENS RA GEN",15)	33	21	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",16)	33	22	0	0	0	0	SS	1	GEM	GEMS_RELA_01	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",16)	33	22	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Time Rate of Change Legal Limit 1	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",17)	33	23	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Operation Mode Flag	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",18)	33	24	0	0	0	0	SH	1	GEM	GEMS_RELA_01	Genesis Version Now	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",18)	33	24	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Field Calculation Safety Factor	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",19)	33	25	0	0	0	0	UL	1	GEM	GEMS_RELA_01	Acq Recon Record Checksum	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",19)	33	25	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Legal Limit 1 of Change Value	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",20)	33	32	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Table Start Location	f	t	\N	\N	\N
(0021,"PHILIPS MR/LAST",20)	33	32	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",20)	33	32	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Slice Number	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",20)	33	32	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",20)	33	32	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Legal Limit 2 of Change Value	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",20)	33	32	0	0	0	0	DS	2	SSPI	SIEMENS CM VA0  CMS	FoV	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",20)	33	32	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Phase Correction Rows Sequence	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",20)	33	32	0	0	0	0	UL	2	SSPI	SIEMENS CT VA0  RAW	Evaluation Mask	f	t	\N	\N	\N
(0021,"SIEMENS MED",20)	33	32	0	0	0	0	US	1	SSPI	SIEMENS MED	ROI Mask	f	t	\N	\N	\N
(0021,"SIEMENS RA GEN",20)	33	32	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",20)	33	32	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  GEN	?	f	t	\N	\N	\N
(0021,"PHILIPS MR/LAST",21)	33	33	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	Slice Gap	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",21)	33	33	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Slice Gap	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",21)	33	33	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  RAW	EPI Rise Time	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",21)	33	33	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Phase Correction Columns Sequence	f	t	\N	\N	\N
(0021,"PHILIPS MR/LAST",22)	33	34	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	Stack Radial Angle	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",22)	33	34	0	0	0	0	DS	1	SSPI	SIEMENS CM VA0  CMS	Image Magnification Factor	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",22)	33	34	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Phase Correction Rows Reconstruction	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",24)	33	36	0	0	0	0	DS	2	SSPI	SIEMENS CM VA0  CMS	Image Scroll Offset	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",24)	33	36	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Phase Correction Columns Reconstruction	f	t	\N	\N	\N
(0021,"SIEMENS RA GEN",25)	33	37	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",26)	33	38	0	0	0	0	IS	1	SSPI	SIEMENS CM VA0  CMS	Image Pixel Offset	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",30)	33	48	0	0	0	0	DS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",30)	33	48	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Echo Number	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",30)	33	48	0	0	0	0	DS	16	SSPI	SIEMENS MR VA0  RAW	Array Coil ADC Offset	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",30)	33	48	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Topogram Tube Position	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",30)	33	48	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of 3D Raw Partitions Nominal	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",30)	33	48	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	View Direction	f	t	\N	\N	\N
(0021,"SIEMENS RA GEN",30)	33	48	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",30)	33	48	0	0	0	0	US	7	SSPI	SIEMENS CT VA0  RAW	Extended Processing Mask	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",31)	33	49	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	Patient Reference ID	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",31)	33	49	0	0	0	0	DS	16	SSPI	SIEMENS MR VA0  RAW	Array Coil Preamplifier Gain	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",31)	33	49	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of 3D Raw Partitions Current	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",32)	33	50	0	0	0	0	CS	1	SSPI	SIEMENS CM VA0  CMS	Patient Rest Direction	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",32)	33	50	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Length of Topogram	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",34)	33	52	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Topogram Correction Factor	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",34)	33	52	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of 3D Image Partitions	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",35)	33	53	0	0	0	0	SS	1	GEM	GEMS_RELA_01	Series From Which Prescribed	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",35)	33	53	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Chemical Shift Number	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",36)	33	54	0	0	0	0	SS	1	GEM	GEMS_RELA_01	Image From Which Prescribed	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",36)	33	54	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Maximum Table Position	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",36)	33	54	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Actual 3D Image Partition Number	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",37)	33	55	0	0	0	0	SS	1	GEM	GEMS_RELA_01	Screen Format	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",39)	33	57	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Slab Thickness	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",40)	33	64	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Phase Number	f	t	\N	\N	\N
(0021,"SPI-P-Private_CDS Release 1",40)	33	64	0	0	0	0	IS	1	PSPI	SPI-P-Private_CDS Release 1	?	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",40)	33	64	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",40)	33	64	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Table Move Direction Code	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",40)	33	64	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Slices Nominal	f	t	\N	\N	\N
(0021,"SIEMENS RA GEN",40)	33	64	0	0	0	0	US	1	SSPI	SIEMENS RA GEN	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",40)	33	64	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  RAW	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",41)	33	65	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Slices Current	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",41)	33	65	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  RAW	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",42)	33	66	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Current Slice Number	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",42)	33	66	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  RAW	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",43)	33	67	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Current Group Number	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",43)	33	67	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  RAW	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",44)	33	68	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Current Slice Distance Factor	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",44)	33	68	0	0	0	0	US	1-n	SSPI	SIEMENS CT VA0  RAW	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",45)	33	69	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	VOI Start Row	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",45)	33	69	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	MIP Start Row	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",46)	33	70	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	VOI Stop Row	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",46)	33	70	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	MIP Stop Row	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",47)	33	71	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	VOI Start Column	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",47)	33	71	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	MIP Start Column	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",48)	33	72	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	VOI Stop Column	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",48)	33	72	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	MIP Stop Column	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",49)	33	73	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	VOI Start Slice	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",49)	33	73	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	MIP Start Slice	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",4a)	33	74	0	0	0	0	LO	1	GEM	GEMS_RELA_01	Anatomical Reference For Scout	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",4a)	33	74	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	VOI Stop Slice	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",4a)	33	74	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	MIP Stop Slice	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",4e)	33	78	0	0	0	0	US	1	GEM	GEMS_RELA_01	?	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",4f)	33	79	0	0	0	0	SS	1	GEM	GEMS_RELA_01	Locations In Acquisition	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",4f)	33	79	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  GEN	Order of Slices	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",50)	33	80	0	0	0	0	SS	1	GEM	GEMS_RELA_01	Graphically Prescribed	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",50)	33	80	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Dynamic Scan Number	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",50)	33	80	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",50)	33	80	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Vector Start Row	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",50)	33	80	0	0	0	0	US	1	SSPI	SIEMENS MR VA0  GEN	Signal Mask	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  RAW",50)	33	80	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  RAW	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",50)	33	80	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  RAW	Saturation Type	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",51)	33	81	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Rotation From Source X Rot	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",51)	33	81	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  RAW	Saturation Normal Vector	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",51)	33	81	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Vector Row Step	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",52)	33	82	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Rotation From Source Y Rot	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",52)	33	82	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Delay After Trigger	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",52)	33	82	0	0	0	0	DS	3	SSPI	SIEMENS MR VA0  RAW	Saturation Position Vector	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",52)	33	82	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Vector Start Column	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",53)	33	83	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Rotation From Source Z Rot	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",53)	33	83	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  RAW	Saturation Thickness	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",53)	33	83	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Vector Column Step	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",53)	33	83	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	RR Interval	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",54)	33	84	0	0	0	0	SH	3	GEM	GEMS_RELA_01	Image Position	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",54)	33	84	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Number of Trigger Pulses	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",54)	33	84	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  RAW	Saturation Width	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",55)	33	85	0	0	0	0	SH	6	GEM	GEMS_RELA_01	Image Orientation	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  RAW",55)	33	85	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  RAW	Saturation Distance	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",56)	33	86	0	0	0	0	SL	1	GEM	GEMS_RELA_01	Integer Slop	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",56)	33	86	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Repetition Time Effective	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",57)	33	87	0	0	0	0	SL	1	GEM	GEMS_RELA_01	Integer Slop	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",57)	33	87	0	0	0	0	LT	1	SSPI	SIEMENS MR VA0  GEN	Gate Phase	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",58)	33	88	0	0	0	0	SL	1	GEM	GEMS_RELA_01	Integer Slop	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",58)	33	88	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Gate Threshold	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",59)	33	89	0	0	0	0	SL	1	GEM	GEMS_RELA_01	Integer Slop	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",59)	33	89	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Gated Ratio	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",5a)	33	90	0	0	0	0	SL	1	GEM	GEMS_RELA_01	Integer Slop	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",5b)	33	91	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Float Slop	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",5c)	33	92	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Float Slop	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",5d)	33	93	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Float Slop	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",5e)	33	94	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Float Slop	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",5f)	33	95	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Float Slop	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",60)	33	96	0	0	0	0	DS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",60)	33	96	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Number of Rows In Object	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",60)	33	96	0	0	0	0	DS	3	SSPI	SIEMENS CM VA0  CMS	Image Position	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",60)	33	96	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Range Type Code	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",60)	33	96	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Interpolated Images	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",61)	33	97	0	0	0	0	IS	1-n	PSPI	PHILIPS MR/PART	Row Number	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",61)	33	97	0	0	0	0	DS	3	SSPI	SIEMENS CM VA0  CMS	Image Normal	f	t	\N	\N	\N
(0021,"PHILIPS MR/PART",62)	33	98	0	0	0	0	IS	1-n	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",62)	33	98	0	0	0	0	IS	1	SSPI	SIEMENS CT VA0  GEN	Reference Type Code	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",63)	33	99	0	0	0	0	DS	1	SSPI	SIEMENS CM VA0  CMS	Image Distance	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",65)	33	101	0	0	0	0	US	1	SSPI	SIEMENS CM VA0  CMS	Image Positioning History Mask	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",6a)	33	106	0	0	0	0	DS	3	SSPI	SIEMENS CM VA0  CMS	Image Row	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",6b)	33	107	0	0	0	0	DS	3	SSPI	SIEMENS CM VA0  CMS	Image Column	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",70)	33	112	0	0	0	0	LT	1	GEM	GEMS_RELA_01	?	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",70)	33	112	0	0	0	0	DS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",70)	33	112	0	0	0	0	DS	3	SSPI	SIEMENS CT VA0  GEN	Object Orientation	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",70)	33	112	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Number of Echoes	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",70)	33	112	0	0	0	0	LT	3	SSPI	SIEMENS CM VA0  CMS	Patient Orientation Set1	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",71)	33	113	0	0	0	0	LT	1	GEM	GEMS_RELA_01	?	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",71)	33	113	0	0	0	0	LT	3	SSPI	SIEMENS CM VA0  CMS	Patient Orientation Set2	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",72)	33	114	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Second Echo Time	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",72)	33	114	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Second Repetition Time	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",72)	33	114	0	0	0	0	DS	3	SSPI	SIEMENS CT VA0  GEN	Light Orientation	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",73)	33	115	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	Second Repetition Time	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",75)	33	117	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Light Brightness	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",76)	33	118	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	Light Contrast	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",7a)	33	122	0	0	0	0	IS	2	SSPI	SIEMENS CT VA0  GEN	Overlay Threshold	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",7b)	33	123	0	0	0	0	IS	2	SSPI	SIEMENS CT VA0  GEN	Surface Threshold	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",7c)	33	124	0	0	0	0	IS	2	SSPI	SIEMENS CT VA0  GEN	Grey Scale Threshold	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",80)	33	128	0	0	0	0	DS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",80)	33	128	0	0	0	0	IS	1	SSPI	SIEMENS MR VA0  GEN	Cardiac Code	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",80)	33	128	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Study Name	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",81)	33	129	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Auto Window Level Alpha	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",82)	33	130	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Auto Window Level Beta	f	t	\N	\N	\N
(0021,"SIEMENS CM VA0  CMS",82)	33	130	0	0	0	0	LT	3	SSPI	SIEMENS CM VA0  CMS	Study Type	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",83)	33	131	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Auto Window Level Window	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",84)	33	132	0	0	0	0	DS	1	GEM	GEMS_RELA_01	Auto Window Level Level	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",90)	33	144	0	0	0	0	SS	1	GEM	GEMS_RELA_01	Tube Focal Spot Position	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",90)	33	144	0	0	0	0	DS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",91)	33	145	0	0	0	0	SS	1	GEM	GEMS_RELA_01	Biopsy Position	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",91)	33	145	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  GEN	Saturation PhaseEncoding Vector Transverse Component	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",92)	33	146	0	0	0	0	FL	1	GEM	GEMS_RELA_01	Biopsy T Location	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",92)	33	146	0	0	0	0	DS	6	SSPI	SIEMENS MR VA0  GEN	Saturation Readout Vector Transverse Component	f	t	\N	\N	\N
(0021,"GEMS_RELA_01",93)	33	147	0	0	0	0	FL	1	GEM	GEMS_RELA_01	Biopsy Ref Location	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",93)	33	147	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	EPI Change Value of Magnitude	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",94)	33	148	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	EPI Change Value of X Component	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",95)	33	149	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	EPI Change Value of Y Component	f	t	\N	\N	\N
(0021,"SIEMENS MR VA0  GEN",96)	33	150	0	0	0	0	DS	1	SSPI	SIEMENS MR VA0  GEN	EPI Change Value of Z Component	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",a0)	33	160	0	0	0	0	US	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",a0)	33	160	0	0	0	0	DS	1	SSPI	SIEMENS CT VA0  GEN	?	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",a1)	33	161	0	0	0	0	DS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",a2)	33	162	0	0	0	0	DS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",a2)	33	162	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  GEN	?	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",a3)	33	163	0	0	0	0	LT	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",a4)	33	164	0	0	0	0	LT	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SIEMENS CT VA0  GEN",a7)	33	167	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  GEN	?	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",b0)	33	176	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0021,"SPI-P-GV-CT Release 1",c0)	33	192	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",00)	35	0	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR DRE	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",00)	35	0	0	0	0	0	DS	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR DRE	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",00)	35	0	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR Exposure Menu Code	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",00)	35	0	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR Exposure Menu Code	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",00)	35	0	0	0	0	0	US	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR S Shift	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",00)	35	0	0	0	0	0	US	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR S Shift	f	t	\N	\N	\N
(0023,"GEMS_STDY_01",01)	35	1	0	0	0	0	SL	1	GEM	GEMS_STDY_01	Number Of Series In Study	f	t	\N	\N	\N
(0023,"GEMS_STDY_01",02)	35	2	0	0	0	0	SL	1	GEM	GEMS_STDY_01	Number Of Unarchived Series	f	t	\N	\N	\N
(0023,"SPI-P Release 2;1",0d)	35	13	0	0	0	0	UI	1	PSPI	SPI-P Release 2;1	?	f	t	\N	\N	\N
(0023,"SPI-P Release 2;1",0e)	35	14	0	0	0	0	UI	1	PSPI	SPI-P Release 2;1	?	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",10)	35	16	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR C Shift	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",10)	35	16	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR Exposure Menu String	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",10)	35	16	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR Exposure Menu String	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",10)	35	16	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR C Shift	f	t	\N	\N	\N
(0023,"GEMS_STDY_01",10)	35	16	0	0	0	0	SS	1	GEM	GEMS_STDY_01	Reference Image Field	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",10)	35	16	0	0	0	0	US	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR DRN	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",10)	35	16	0	0	0	0	US	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR DRN	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",20)	35	32	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR GT	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",20)	35	32	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR ORE	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",20)	35	32	0	0	0	0	DS	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR ORE	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",20)	35	32	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR EDR Mode	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",20)	35	32	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR EDR Mode	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",20)	35	32	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR GT	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",30)	35	48	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR GA	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",30)	35	48	0	0	0	0	DS	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR GA	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",30)	35	48	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR Latitude	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",30)	35	48	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR Latitude	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",30)	35	48	0	0	0	0	US	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR ORN	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",30)	35	48	0	0	0	0	US	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR ORN	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",40)	35	64	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR GC	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",40)	35	64	0	0	0	0	DS	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR GC	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",40)	35	64	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR Group Number	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",40)	35	64	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR Group Number	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",40)	35	64	0	0	0	0	US	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR ORD	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",40)	35	64	0	0	0	0	US	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR ORD	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",50)	35	80	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR GS	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",50)	35	80	0	0	0	0	DS	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR GS	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",50)	35	80	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR Cassette Size	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",50)	35	80	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR Cassette Size	f	t	\N	\N	\N
(0023,"GEMS_STDY_01",50)	35	80	0	0	0	0	SS	1	GEM	GEMS_STDY_01	Summary Image	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",50)	35	80	0	0	0	0	US	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR Image Serial Number	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",50)	35	80	0	0	0	0	US	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR Image Serial Number	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",60)	35	96	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR RT	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",60)	35	96	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR Bar Code Number	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",60)	35	96	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR Machine ID	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",60)	35	96	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR Bar Code Number	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",60)	35	96	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR RT	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",60)	35	96	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR Machine ID	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",70)	35	112	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR RE	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",70)	35	112	0	0	0	0	DS	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR RE	f	t	\N	\N	\N
(0023,"GEMS_STDY_01",70)	35	112	0	0	0	0	FD	1	GEM	GEMS_STDY_01	Start Time Secs In First Axial	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",70)	35	112	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR Film Output Exposure	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",70)	35	112	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR Machine Type	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",70)	35	112	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR Film Output Exposure	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",70)	35	112	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR Machine Type	f	t	\N	\N	\N
(0023,"GEMS_STDY_01",74)	35	116	0	0	0	0	SL	1	GEM	GEMS_STDY_01	Number Of Updates To Header	f	t	\N	\N	\N
(0023,"GEMS_STDY_01",7d)	35	125	0	0	0	0	SS	1	GEM	GEMS_STDY_01	Indicates If Study Has Complete Info	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",80)	35	128	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR Film Format	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",80)	35	128	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR Technician Code	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",80)	35	128	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR Film Format	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",80)	35	128	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR Technician Code	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",80)	35	128	0	0	0	0	US	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR RN	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",80)	35	128	0	0	0	0	US	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR RN	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK2",90)	35	144	0	0	0	0	DS	1	GEM	GEMS_ACRQA_1.0 BLOCK2	CR DRT	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK2",90)	35	144	0	0	0	0	DS	1	GEM	GEMS_ACRQA_2.0 BLOCK2	CR DRT	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK1",90)	35	144	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK1	CR S Shift String	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_1.0 BLOCK3",90)	35	144	0	0	0	0	LO	1	GEM	GEMS_ACRQA_1.0 BLOCK3	CR Energy Subtraction Parameters	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK1",90)	35	144	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK1	CR S Shift String	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",90)	35	144	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR Energy Subtraction Parameters	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",f0)	35	240	0	0	0	0	LO	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR Distribution Code	f	t	\N	\N	\N
(0023,"GEMS_ACRQA_2.0 BLOCK3",ff)	35	255	0	0	0	0	US	1	GEM	GEMS_ACRQA_2.0 BLOCK3	CR Shutters Applied	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",06)	37	6	0	0	0	0	SS	1	GEM	GEMS_SERS_01	Last Pulse Sequence Used	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",07)	37	7	0	0	0	0	SL	1	GEM	GEMS_SERS_01	Images In Series	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",10)	37	16	0	0	0	0	SL	1	GEM	GEMS_SERS_01	Landmark Counter	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",11)	37	17	0	0	0	0	SS	1	GEM	GEMS_SERS_01	Number Of Acquisitions	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",14)	37	20	0	0	0	0	SL	1	GEM	GEMS_SERS_01	Indicates Number Of Updates To Header	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",17)	37	23	0	0	0	0	SL	1	GEM	GEMS_SERS_01	Series Complete Flag	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",18)	37	24	0	0	0	0	SL	1	GEM	GEMS_SERS_01	Number Of Images Archived	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",19)	37	25	0	0	0	0	SL	1	GEM	GEMS_SERS_01	Last Image Number Used	f	t	\N	\N	\N
(0025,"GEMS_SERS_01",1a)	37	26	0	0	0	0	SH	1	GEM	GEMS_SERS_01	Primary Receiver Suite And Host	f	t	\N	\N	\N
(0027,"PHILIPS MR/LAST",00)	39	0	0	0	0	0	US	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",06)	39	6	0	0	0	0	SL	1	GEM	GEMS_IMAG_01	Image Archive Flag	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",10)	39	16	0	0	0	0	SS	1	GEM	GEMS_IMAG_01	Scout Type	f	t	\N	\N	\N
(0027,"PHILIPS MR/LAST",11)	39	17	0	0	0	0	US	1-n	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0027,"PHILIPS MR/LAST",12)	39	18	0	0	0	0	DS	1-n	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0027,"PHILIPS MR/LAST",13)	39	19	0	0	0	0	DS	1-n	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0027,"PHILIPS MR/LAST",14)	39	20	0	0	0	0	DS	1-n	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0027,"PHILIPS MR/LAST",15)	39	21	0	0	0	0	DS	1-n	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0027,"PHILIPS MR/LAST",16)	39	22	0	0	0	0	LO	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",1c)	39	28	0	0	0	0	SL	1	GEM	GEMS_IMAG_01	Vma Mamp	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",1d)	39	29	0	0	0	0	SS	1	GEM	GEMS_IMAG_01	Vma Phase	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",1e)	39	30	0	0	0	0	SL	1	GEM	GEMS_IMAG_01	Vma Mod	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",1f)	39	31	0	0	0	0	SL	1	GEM	GEMS_IMAG_01	Vma Clip	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",20)	39	32	0	0	0	0	SS	1	GEM	GEMS_IMAG_01	Smart Scan On Off Flag	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",30)	39	48	0	0	0	0	SH	1	GEM	GEMS_IMAG_01	Foreign Image Revision	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",31)	39	49	0	0	0	0	SS	1	GEM	GEMS_IMAG_01	Imaging Mode	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",32)	39	50	0	0	0	0	SS	1	GEM	GEMS_IMAG_01	Pulse Sequence	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",33)	39	51	0	0	0	0	SL	1	GEM	GEMS_IMAG_01	Imaging Options	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",35)	39	53	0	0	0	0	SS	1	GEM	GEMS_IMAG_01	Plane Type	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",36)	39	54	0	0	0	0	SL	1	GEM	GEMS_IMAG_01	Oblique Plane	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",40)	39	64	0	0	0	0	SH	1	GEM	GEMS_IMAG_01	RAS Letter Of Image Location	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",41)	39	65	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Image Location	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",42)	39	66	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Center R Coord Of Plane Image	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",43)	39	67	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Center A Coord Of Plane Image	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",44)	39	68	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Center S Coord Of Plane Image	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",45)	39	69	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Normal R Coord	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",46)	39	70	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Normal A Coord	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",47)	39	71	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Normal S Coord	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",48)	39	72	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	R Coord Of Top Right Corner	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",49)	39	73	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	A Coord Of Top Right Corner	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",4a)	39	74	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	S Coord Of Top Right Corner	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",4b)	39	75	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	R Coord Of Bottom Right Corner	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",4c)	39	76	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	A Coord Of Bottom Right Corner	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",4d)	39	77	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	S Coord Of Bottom Right Corner	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",50)	39	80	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Table Start Location	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",51)	39	81	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Table End Location	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",52)	39	82	0	0	0	0	SH	1	GEM	GEMS_IMAG_01	RAS Letter For Side Of Image	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",53)	39	83	0	0	0	0	SH	1	GEM	GEMS_IMAG_01	RAS Letter For Anterior Posterior	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",54)	39	84	0	0	0	0	SH	1	GEM	GEMS_IMAG_01	RAS Letter For Scout Start Loc	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",55)	39	85	0	0	0	0	SH	1	GEM	GEMS_IMAG_01	RAS Letter For Scout End Loc	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",60)	39	96	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Image Dimension X	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",61)	39	97	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Image Dimension Y	f	t	\N	\N	\N
(0027,"GEMS_IMAG_01",62)	39	98	0	0	0	0	FL	1	GEM	GEMS_IMAG_01	Number Of Excitations	f	t	\N	\N	\N
(0029,"AEGIS_DICOM_2.00",00)	41	0	0	0	0	0	US	1-n	AEG	AEGIS_DICOM_2.00	?	f	t	\N	\N	\N
(0029,"Silhouette Graphics Export V1.0",00)	41	0	0	0	0	0	UI	1	ISG	Silhouette Graphics Export V1.0	?	f	t	\N	\N	\N
(0029,"CARDIO-D.R. 1.0",00)	41	0	0	0	0	0	SQ	1	PDIC	CARDIO-D.R. 1.0	Edge Enhancement Sequence	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",00)	41	0	0	0	0	0	DS	2	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",00)	41	0	0	0	0	0	DS	4	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;2",00)	41	0	0	0	0	0	FD	1	PSPI	SPI-P-Private_ICS Release 1;2	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;1",00)	41	0	0	0	0	0	SL	1	PSPI	SPI-P-Private_ICS Release 1;1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_CDS Release 1",00)	41	0	0	0	0	0	UN	1	PSPI	SPI-P-Private_CDS Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",00)	41	0	0	0	0	0	LT	1	PSPI	SPI-P Release 1;1	Zoom ID	f	t	\N	\N	\N
(0029,"SPI-P Release 1;2",00)	41	0	0	0	0	0	LT	1	PSPI	SPI-P Release 1;2	Subtraction Mask ID	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",00)	41	0	0	0	0	0	LT	1	PSPI	SPI-P Release 1;3	Image Enhancement ID	f	t	\N	\N	\N
(0029,"CARDIO-D.R. 1.0",01)	41	1	0	0	0	0	US	2	PDIC	CARDIO-D.R. 1.0	Convolution Kernel Size	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;2",01)	41	1	0	0	0	0	FD	1	PSPI	SPI-P-Private_ICS Release 1;2	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",01)	41	1	0	0	0	0	DS	1-n	PSPI	SPI-P Release 1;1	Zoom Rectangle	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",01)	41	1	0	0	0	0	LT	1	PSPI	SPI-P Release 1;3	Image Enhancement	f	t	\N	\N	\N
(0029,"CARDIO-D.R. 1.0",02)	41	2	0	0	0	0	DS	1-n	PDIC	CARDIO-D.R. 1.0	Convolution Kernel Coefficients	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;2",02)	41	2	0	0	0	0	FD	1	PSPI	SPI-P-Private_ICS Release 1;2	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",02)	41	2	0	0	0	0	LT	1	PSPI	SPI-P Release 1;3	Convolution ID	f	t	\N	\N	\N
(0029,"CARDIO-D.R. 1.0",03)	41	3	0	0	0	0	DS	1	PDIC	CARDIO-D.R. 1.0	Edge Enhancement Gain	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;2",03)	41	3	0	0	0	0	SL	1	PSPI	SPI-P-Private_ICS Release 1;2	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",03)	41	3	0	0	0	0	DS	1	PSPI	SPI-P Release 1;1	Zoom Factor	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",03)	41	3	0	0	0	0	LT	1	PSPI	SPI-P Release 1;3	Convolution Type	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",04)	41	4	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;2",04)	41	4	0	0	0	0	SL	1	PSPI	SPI-P-Private_ICS Release 1;2	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;2",04)	41	4	0	0	0	0	UN	1	PSPI	SPI-P Release 1;2	Masking Function	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",04)	41	4	0	0	0	0	US	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",04)	41	4	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Zoom Function	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",04)	41	4	0	0	0	0	LT	1	PSPI	SPI-P Release 1;3	Convolution Kernel Size ID	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",04)	41	4	0	0	0	0	LT	1	SSPI	SIEMENS MED DISPLAY	Photometric Interpretation	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",05)	41	5	0	0	0	0	DS	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;1",05)	41	5	0	0	0	0	FL	1	PSPI	SPI-P-Private_ICS Release 1;1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;2",05)	41	5	0	0	0	0	SL	1	PSPI	SPI-P-Private_ICS Release 1;2	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",05)	41	5	0	0	0	0	US	2	PSPI	SPI-P Release 1;3	Convolution Kernel Size	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",06)	41	6	0	0	0	0	DS	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;1",06)	41	6	0	0	0	0	FL	1	PSPI	SPI-P-Private_ICS Release 1;1	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",06)	41	6	0	0	0	0	US	1-n	PSPI	SPI-P Release 1;3	Convolution Kernel	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",07)	41	7	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",08)	41	8	0	0	0	0	SH	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",09)	41	9	0	0	0	0	SH	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",0a)	41	10	0	0	0	0	SS	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",0c)	41	12	0	0	0	0	DS	1	PSPI	SPI-P Release 1;3	Enhancement Gain	f	t	\N	\N	\N
(0029,"SPI-P Release 1;2",0c)	41	12	0	0	0	0	UN	1	PSPI	SPI-P Release 1;2	Proprietary Masking Parameters	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",0e)	41	14	0	0	0	0	CS	1	PSPI	SPI-P Release 1;1	Zoom Enable Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",0f)	41	15	0	0	0	0	CS	1	PSPI	SPI-P Release 1;1	Zoom Select Status	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",0f)	41	15	0	0	0	0	SQ	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"CAMTRONICS IP",10)	41	16	0	0	0	0	LT	1	CMT	CAMTRONICS IP	?	f	t	\N	\N	\N
(0029,"CAMTRONICS",10)	41	16	0	0	0	0	LT	1	CMT	CAMTRONICS	Commentline	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",10)	41	16	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	FP Min	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",10)	41	16	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",10)	41	16	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",10)	41	16	0	0	0	0	SQ	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",10)	41	16	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Rows of Submatrix	f	t	\N	\N	\N
(0029,"SIEMENS MED HG",10)	41	16	0	0	0	0	US	1	SSPI	SIEMENS MED HG	List of Group Numbers	f	t	\N	\N	\N
(0029,"SIEMENS MED MG",10)	41	16	0	0	0	0	US	1	SSPI	SIEMENS MED MG	List of Group Numbers	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",10)	41	16	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Window Style	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",11)	41	17	0	0	0	0	IS	1	ISG	Silhouette Annot V1.0	Annotation Name	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",11)	41	17	0	0	0	0	IS	1	ISG	Silhouette Line V1.0	Line Name	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",11)	41	17	0	0	0	0	IS	1	ISG	Silhouette ROI V1.0	ROI Name	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",11)	41	17	0	0	0	0	DS	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",11)	41	17	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Columns of Submatrix	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",11)	41	17	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",12)	41	18	0	0	0	0	LT	1	ISG	Silhouette Annot V1.0	Annotation Font	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",12)	41	18	0	0	0	0	LT	1	ISG	Silhouette Line V1.0	Line Name Font	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",12)	41	18	0	0	0	0	LT	1	ISG	Silhouette ROI V1.0	ROI Name Font	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",13)	41	19	0	0	0	0	LT	1	ISG	Silhouette Annot V1.0	Annotation Text Foreground Color	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",13)	41	19	0	0	0	0	LT	1	ISG	Silhouette ROI V1.0	ROI Normal Color	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",13)	41	19	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Name Display	f	t	\N	\N	\N
(0029,"Silhouette V1.0",13)	41	19	0	0	0	0	UL	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",13)	41	19	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",14)	41	20	0	0	0	0	LT	1	ISG	Silhouette Annot V1.0	Annotation Text Background Color	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",14)	41	20	0	0	0	0	LT	1	ISG	Silhouette Line V1.0	Line Normal Color	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",14)	41	20	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Fill Pattern	f	t	\N	\N	\N
(0029,"Silhouette V1.0",14)	41	20	0	0	0	0	UL	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",15)	41	21	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",15)	41	21	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Text Backing Mode	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",15)	41	21	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Type	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",15)	41	21	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Bp Seg	f	t	\N	\N	\N
(0029,"SIEMENS MED HG",15)	41	21	0	0	0	0	LT	1	SSPI	SIEMENS MED HG	List of Shadow Owner Codes	f	t	\N	\N	\N
(0029,"SIEMENS MED MG",15)	41	21	0	0	0	0	LT	1	SSPI	SIEMENS MED MG	List of Shadow Owner Codes	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",16)	41	22	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",16)	41	22	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Text Justification	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",16)	41	22	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Thickness	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",16)	41	22	0	0	0	0	UN	1	ISG	Silhouette ROI V1.0	ROI Bp Seg Pairs	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",17)	41	23	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Lower Range Of Pixels	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",17)	41	23	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Text Location	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",17)	41	23	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Style	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",17)	41	23	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Seed Space	f	t	\N	\N	\N
(0029,"Silhouette V1.0",17)	41	23	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",18)	41	24	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Upper Range Of Pixels	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",18)	41	24	0	0	0	0	LT	1	ISG	Silhouette Annot V1.0	Annotation Text String	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",18)	41	24	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Dash Length	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",18)	41	24	0	0	0	0	UN	1	ISG	Silhouette ROI V1.0	ROI Seeds	f	t	\N	\N	\N
(0029,"Silhouette V1.0",18)	41	24	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",19)	41	25	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Text Attach Mode	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",19)	41	25	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Interactivity	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",19)	41	25	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Line Thickness	f	t	\N	\N	\N
(0029,"Silhouette V1.0",19)	41	25	0	0	0	0	UL	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",1a)	41	26	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Length Of Total Header In Bytes	f	t	\N	\N	\N
(0029,"Silhouette V1.0",1a)	41	26	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette V1.0",1b)	41	27	0	0	0	0	UL	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",1b)	41	27	0	0	0	0	SQ	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"Silhouette V1.0",1c)	41	28	0	0	0	0	UL	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",1c)	41	28	0	0	0	0	SQ	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"Silhouette V1.0",1d)	41	29	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette V1.0",1e)	41	30	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;2",1e)	41	30	0	0	0	0	CS	1	PSPI	SPI-P Release 1;2	Subtraction Mask Enable Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",1e)	41	30	0	0	0	0	CS	1	PSPI	SPI-P Release 1;3	Image Enhancement Enable Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1;2",1f)	41	31	0	0	0	0	CS	1	PSPI	SPI-P Release 1;2	Subtraction Mask Select Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1;3",1f)	41	31	0	0	0	0	CS	1	PSPI	SPI-P Release 1;3	Image Enhancement Select Status	f	t	\N	\N	\N
(0029,"CAMTRONICS",20)	41	32	0	0	0	0	DS	1	CMT	CAMTRONICS	Edge Enhancement Coefficient	f	t	\N	\N	\N
(0029,"CAMTRONICS IP",20)	41	32	0	0	0	0	UN	1	CMT	CAMTRONICS IP	?	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",20)	41	32	0	0	0	0	LT	1	ISG	Silhouette Line V1.0	Line Measurement Color	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",20)	41	32	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Text Cursor Mode	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",20)	41	32	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Line Style	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",20)	41	32	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	FP Max	f	t	\N	\N	\N
(0029,"SPI-P Release 1",20)	41	32	0	0	0	0	DS	1	PSPI	SPI-P Release 1	Pixel Aspect Ratio	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;1",20)	41	32	0	0	0	0	FL	1	PSPI	SPI-P-Private_ICS Release 1;1	?	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",20)	41	32	0	0	0	0	LO	1	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0029,"SIEMENS MED HG",20)	41	32	0	0	0	0	US	1	SSPI	SIEMENS MED HG	List of Element Numbers	f	t	\N	\N	\N
(0029,"SIEMENS MED MG",20)	41	32	0	0	0	0	US	1	SSPI	SIEMENS MED MG	List of Element Numbers	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",20)	41	32	0	0	0	0	LT	3	SSPI	SIEMENS CM VA0  CMS	Pixel Quality Code	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",20)	41	32	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	?	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",21)	41	33	0	0	0	0	LT	1	ISG	Silhouette Line V1.0	Line Measurement Font	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",21)	41	33	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Text Shadow Offset X	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",21)	41	33	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Line Dash Length	f	t	\N	\N	\N
(0029,"Silhouette V1.0",21)	41	33	0	0	0	0	US	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;1",21)	41	33	0	0	0	0	FL	1	PSPI	SPI-P-Private_ICS Release 1;1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",21)	41	33	0	0	0	0	SQ	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",21)	41	33	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",22)	41	34	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Text Shadow Offset Y	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",22)	41	34	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Measurement Dash Length	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",22)	41	34	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Interactivity	f	t	\N	\N	\N
(0029,"Silhouette V1.0",22)	41	34	0	0	0	0	US	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",22)	41	34	0	0	0	0	IS	3	SSPI	SIEMENS CM VA0  CMS	Pixel Quality Value	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",23)	41	35	0	0	0	0	LT	1	ISG	Silhouette Annot V1.0	Annotation Line Color	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",23)	41	35	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Point Space	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",23)	41	35	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Name Position	f	t	\N	\N	\N
(0029,"Silhouette V1.0",23)	41	35	0	0	0	0	US	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",24)	41	36	0	0	0	0	FD	1	ISG	Silhouette Line V1.0	Line Points	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",24)	41	36	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Line Thickness	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",24)	41	36	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Name Display	f	t	\N	\N	\N
(0029,"Silhouette V1.0",24)	41	36	0	0	0	0	US	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",25)	41	37	0	0	0	0	LT	1	ISG	Silhouette ROI V1.0	ROI Label	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",25)	41	37	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Line Type	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",25)	41	37	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Control Point Size	f	t	\N	\N	\N
(0029,"Silhouette V1.0",25)	41	37	0	0	0	0	US	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",25)	41	37	0	0	0	0	LO	1-n	PSPI	SPI-P Release 1	Processed Pixel Data Quality	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",26)	41	38	0	0	0	0	SS	1	GEM	GEMS_IMPS_01	Version Of Header Structure	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",26)	41	38	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Line Style	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",26)	41	38	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Control Point Space	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",26)	41	38	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Shape	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",27)	41	39	0	0	0	0	FD	1	ISG	Silhouette Line V1.0	Line Control Points	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",27)	41	39	0	0	0	0	FD	1	ISG	Silhouette ROI V1.0	ROI Shape Tilt	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",27)	41	39	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Line Dash Length	f	t	\N	\N	\N
(0029,"Silhouette V1.0",27)	41	39	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",28)	41	40	0	0	0	0	LT	1	ISG	Silhouette Line V1.0	Line Label	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",28)	41	40	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Line Attach Mode	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",28)	41	40	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Shape Points Count	f	t	\N	\N	\N
(0029,"Silhouette V1.0",28)	41	40	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",29)	41	41	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Line Point Count	f	t	\N	\N	\N
(0029,"Silhouette Line V1.0",29)	41	41	0	0	0	0	UL	1	ISG	Silhouette Line V1.0	Line Don't Save	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",29)	41	41	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Shape Points Space	f	t	\N	\N	\N
(0029,"Silhouette V1.0",29)	41	41	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"CAMTRONICS IP",30)	41	48	0	0	0	0	UN	1	CMT	CAMTRONICS IP	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",30)	41	48	0	0	0	0	FD	1	ISG	Silhouette Annot V1.0	Annotation Line Points	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",30)	41	48	0	0	0	0	FD	1	ISG	Silhouette ROI V1.0	ROI Shape Points	f	t	\N	\N	\N
(0029,"Silhouette V1.0",30)	41	48	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",30)	41	48	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	Scaled Minimum	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",30)	41	48	0	0	0	0	UL	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",30)	41	48	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0029,"SIEMENS MED HG",30)	41	48	0	0	0	0	US	1	SSPI	SIEMENS MED HG	List of Total Display Length	f	t	\N	\N	\N
(0029,"SIEMENS MED MG",30)	41	48	0	0	0	0	US	1	SSPI	SIEMENS MED MG	List of Total Display Length	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",31)	41	49	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Line Control Size	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",31)	41	49	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Shape Control Points Count	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",31)	41	49	0	0	0	0	DS	2	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",31)	41	49	0	0	0	0	UL	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"DIGISCAN IMAGE",31)	41	49	0	0	0	0	US	1-n	SSPI	DIGISCAN IMAGE	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",32)	41	50	0	0	0	0	LT	1	ISG	Silhouette Annot V1.0	Annotation Marker Color	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",32)	41	50	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Shape Control Points Space	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",32)	41	50	0	0	0	0	DS	2	PSPI	PHILIPS MR/PART	?	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",32)	41	50	0	0	0	0	UL	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"DIGISCAN IMAGE",32)	41	50	0	0	0	0	US	1-n	SSPI	DIGISCAN IMAGE	?	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",33)	41	51	0	0	0	0	FD	1	ISG	Silhouette ROI V1.0	ROI Shape Control Points	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",33)	41	51	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Marker Type	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",33)	41	51	0	0	0	0	UL	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"DIGISCAN IMAGE",33)	41	51	0	0	0	0	LT	1	SSPI	DIGISCAN IMAGE	?	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",34)	41	52	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Advantage Comp Overflow	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",34)	41	52	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Marker Size	f	t	\N	\N	\N
(0029,"Silhouette ROI V1.0",34)	41	52	0	0	0	0	UL	1	ISG	Silhouette ROI V1.0	ROI Don't Save	f	t	\N	\N	\N
(0029,"DIGISCAN IMAGE",34)	41	52	0	0	0	0	LT	1	SSPI	DIGISCAN IMAGE	?	f	t	\N	\N	\N
(0029,"GEMS_IMPS_01",35)	41	53	0	0	0	0	SL	1	GEM	GEMS_IMPS_01	Advantage Comp Underflow	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",35)	41	53	0	0	0	0	FD	1	ISG	Silhouette Annot V1.0	Annotation Marker Location	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",36)	41	54	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Marker Attach Mode	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",37)	41	55	0	0	0	0	LT	1	ISG	Silhouette Annot V1.0	Annotation Geom Color	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",38)	41	56	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Geom Thickness	f	t	\N	\N	\N
(0029,"SPI-P Release 1",38)	41	56	0	0	0	0	US	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",39)	41	57	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Geom Line Style	f	t	\N	\N	\N
(0029,"CAMTRONICS IP",40)	41	64	0	0	0	0	UN	1	CMT	CAMTRONICS IP	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",40)	41	64	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Geom Dash Length	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",40)	41	64	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	Scaled Maximum	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",40)	41	64	0	0	0	0	LT	1	PSPI	SPI-P Release 1;1	Magnifying Glass ID	f	t	\N	\N	\N
(0029,"SIEMENS MED HG",40)	41	64	0	0	0	0	LT	1	SSPI	SIEMENS MED HG	List of Display Prefix	f	t	\N	\N	\N
(0029,"SIEMENS MED MG",40)	41	64	0	0	0	0	LT	1	SSPI	SIEMENS MED MG	List of Display Prefix	f	t	\N	\N	\N
(0029,"Silhouette Sequence Ids V1.0",41)	41	65	0	0	0	0	SQ	1	ISG	Silhouette Sequence Ids V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",41)	41	65	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Geom Fill Pattern	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",41)	41	65	0	0	0	0	DS	1-n	PSPI	SPI-P Release 1;1	Magnifying Glass Rectangle	f	t	\N	\N	\N
(0029,"Silhouette Sequence Ids V1.0",42)	41	66	0	0	0	0	SQ	1	ISG	Silhouette Sequence Ids V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",42)	41	66	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Interactivity	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",43)	41	67	0	0	0	0	FD	1	ISG	Silhouette Annot V1.0	Annotation Arrow Length	f	t	\N	\N	\N
(0029,"Silhouette Sequence Ids V1.0",43)	41	67	0	0	0	0	SQ	1	ISG	Silhouette Sequence Ids V1.0	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",43)	41	67	0	0	0	0	DS	1	PSPI	SPI-P Release 1;1	Magnifying Glass Factor	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",44)	41	68	0	0	0	0	FD	1	ISG	Silhouette Annot V1.0	Annotation Arrow Angle	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",44)	41	68	0	0	0	0	US	1	PSPI	SPI-P Release 1;1	Magnifying Glass Function	f	t	\N	\N	\N
(0029,"Silhouette Annot V1.0",45)	41	69	0	0	0	0	UL	1	ISG	Silhouette Annot V1.0	Annotation Don't Save	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",4c)	41	76	0	0	0	0	SQ	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",4e)	41	78	0	0	0	0	CS	1	PSPI	SPI-P Release 1;1	Magnifying Glass Enable Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1;1",4f)	41	79	0	0	0	0	CS	1	PSPI	SPI-P Release 1;1	Magnifying Glass Select Status	f	t	\N	\N	\N
(0029,"CAMTRONICS",50)	41	80	0	0	0	0	LT	1	CMT	CAMTRONICS	Scene Text	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",50)	41	80	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	Window Minimum	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;5",50)	41	80	0	0	0	0	CS	1	PSPI	SPI-P-Private_ICS Release 1;5	?	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",50)	41	80	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Origin of Submatrix	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",50)	41	80	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Archive Code	f	t	\N	\N	\N
(0029,"SIEMENS MED HG",50)	41	80	0	0	0	0	LT	1	SSPI	SIEMENS MED HG	List of Display Postfix	f	t	\N	\N	\N
(0029,"SIEMENS MED MG",50)	41	80	0	0	0	0	LT	1	SSPI	SIEMENS MED MG	List of Display Postfix	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",51)	41	81	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Exposure Code	f	t	\N	\N	\N
(0029,"Silhouette V1.0",52)	41	82	0	0	0	0	US	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",52)	41	82	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Sort Code	f	t	\N	\N	\N
(0029,"Silhouette V1.0",53)	41	83	0	0	0	0	LT	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",53)	41	83	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	?	f	t	\N	\N	\N
(0029,"Silhouette V1.0",54)	41	84	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette V1.0",55)	41	85	0	0	0	0	LT	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;5",55)	41	85	0	0	0	0	CS	1	PSPI	SPI-P-Private_ICS Release 1;5	?	f	t	\N	\N	\N
(0029,"Silhouette V1.0",56)	41	86	0	0	0	0	LT	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"Silhouette V1.0",57)	41	87	0	0	0	0	UN	1	ISG	Silhouette V1.0	?	f	t	\N	\N	\N
(0029,"CAMTRONICS",60)	41	96	0	0	0	0	LT	1	CMT	CAMTRONICS	Image Text	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",60)	41	96	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	Window Maximum	f	t	\N	\N	\N
(0029,"SPI-P Release 1",60)	41	96	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0029,"SPI RELEASE 1",60)	41	96	0	0	0	0	LT	1	SPI	SPI RELEASE 1	Compression Algorithm	f	t	\N	\N	\N
(0029,"SPI Release 1",60)	41	96	0	0	0	0	LT	1	SPI	SPI Release 1	Compression Algorithm	f	t	\N	\N	\N
(0029,"SIEMENS CM VA0  CMS",60)	41	96	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Splash	f	t	\N	\N	\N
(0029,"SIEMENS MED HG",60)	41	96	0	0	0	0	US	1	SSPI	SIEMENS MED HG	List of Text Position	f	t	\N	\N	\N
(0029,"SIEMENS MED MG",60)	41	96	0	0	0	0	US	1	SSPI	SIEMENS MED MG	List of Text Position	f	t	\N	\N	\N
(0029,"SPI",60)	41	96	0	0	0	0	LT	1	SSPI	SPI	Compression Algorithm	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",61)	41	97	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",61)	41	97	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",67)	41	103	0	0	0	0	LO	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",67)	41	103	0	0	0	0	LT	1	PSPI	SPI-P Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",68)	41	104	0	0	0	0	US	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",6a)	41	106	0	0	0	0	LO	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1",6b)	41	107	0	0	0	0	US	1	PSPI	SPI-P-Private_ICS Release 1	?	f	t	\N	\N	\N
(0029,"CAMTRONICS",70)	41	112	0	0	0	0	IS	1	CMT	CAMTRONICS	Pixel Shift Horizontal	f	t	\N	\N	\N
(0029,"ISG shadow",70)	41	112	0	0	0	0	IS	1	ISG	ISG shadow	?	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",70)	41	112	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",70)	41	112	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Window ID	f	t	\N	\N	\N
(0029,"SIEMENS MED HG",70)	41	112	0	0	0	0	LT	1	SSPI	SIEMENS MED HG	List of Text Concatenation	f	t	\N	\N	\N
(0029,"SIEMENS MED MG",70)	41	112	0	0	0	0	LT	1	SSPI	SIEMENS MED MG	List of Text Concatenation	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",71)	41	113	0	0	0	0	DS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",71)	41	113	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Video Invert Subtracted	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",72)	41	114	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",72)	41	114	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Video Invert Nonsubtracted	f	t	\N	\N	\N
(0029,"SPI-P Release 1",77)	41	119	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Window Select Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1",78)	41	120	0	0	0	0	LT	1	PSPI	SPI-P Release 1	ECG Display Printing ID	f	t	\N	\N	\N
(0029,"SPI-P Release 1",79)	41	121	0	0	0	0	CS	1	PSPI	SPI-P Release 1	ECG Display Printing	f	t	\N	\N	\N
(0029,"SPI-P Release 1",7e)	41	126	0	0	0	0	CS	1	PSPI	SPI-P Release 1	ECG Display Printing Enable Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1",7f)	41	127	0	0	0	0	CS	1	PSPI	SPI-P Release 1	ECG Display Printing Select Status	f	t	\N	\N	\N
(0029,"CAMTRONICS",80)	41	128	0	0	0	0	IS	1	CMT	CAMTRONICS	Pixel Shift Vertical	f	t	\N	\N	\N
(0029,"ISG shadow",80)	41	128	0	0	0	0	IS	1	ISG	ISG shadow	?	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",80)	41	128	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	View Center	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",80)	41	128	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P Release 1",80)	41	128	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Physiological Display ID	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",81)	41	129	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	View Size	f	t	\N	\N	\N
(0029,"SPI-P Release 1",81)	41	129	0	0	0	0	US	1	PSPI	SPI-P Release 1	Preferred Physiological Channel Display	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",82)	41	130	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	View Zoom	f	t	\N	\N	\N
(0029,"PHILIPS MR/LAST",83)	41	131	0	0	0	0	IS	1	PSPI	PHILIPS MR/LAST	View Transform	f	t	\N	\N	\N
(0029,"SPI-P Release 1",8e)	41	142	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Physiological Display Enable Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1",8f)	41	143	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Physiological Display Select Status	f	t	\N	\N	\N
(0029,"CAMTRONICS",90)	41	144	0	0	0	0	IS	1	CMT	CAMTRONICS	?	f	t	\N	\N	\N
(0029,"ISG shadow",90)	41	144	0	0	0	0	IS	1	ISG	ISG shadow	?	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",90)	41	144	0	0	0	0	LO	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",99)	41	153	0	0	0	0	LT	1	SSPI	SIEMENS MED DISPLAY	Shutter Type	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;1",cd)	41	205	0	0	0	0	SQ	1	PSPI	SPI-P-Private_ICS Release 1;1	?	f	t	\N	\N	\N
(0029,"SPI-P-Private_ICS Release 1;4",e0)	41	224	0	0	0	0	SQ	1	PSPI	SPI-P-Private_ICS Release 1;4	?	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",a0)	41	160	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Rows of Rectangular Shutter	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",a1)	41	161	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Columns of Rectangular Shutter	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",a2)	41	162	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Origin of Rectangular Shutter	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",b0)	41	176	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Radius of Circular Shutter	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",b2)	41	178	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Origin of Circular Shutter	f	t	\N	\N	\N
(0029,"SPI-P Release 1",c0)	41	192	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Functional Shutter ID	f	t	\N	\N	\N
(0029,"SPI-P Release 1",c1)	41	193	0	0	0	0	US	1	PSPI	SPI-P Release 1	Field Of Shutter	f	t	\N	\N	\N
(0029,"SIEMENS MED DISPLAY",c1)	41	193	0	0	0	0	US	1	SSPI	SIEMENS MED DISPLAY	Contour of Irregular Shutter	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",c3)	41	195	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Scan Resolution	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",c4)	41	196	0	0	0	0	IS	1	PSPI	PHILIPS MR/PART	Field of View	f	t	\N	\N	\N
(0029,"SPI-P Release 1",c5)	41	197	0	0	0	0	LT	1	PSPI	SPI-P Release 1	Field Of Shutter Rectangle	f	t	\N	\N	\N
(0029,"SPI-P Release 1",ce)	41	206	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Shutter Enable Status	f	t	\N	\N	\N
(0029,"SPI-P Release 1",cf)	41	207	0	0	0	0	CS	1	PSPI	SPI-P Release 1	Shutter Select Status	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",d0)	41	208	0	0	0	0	IS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"SPI-P-GV-CT Release 1",d1)	41	209	0	0	0	0	IS	1	PSPI	SPI-P-GV-CT Release 1	?	f	t	\N	\N	\N
(0029,"PHILIPS MR/PART",d5)	41	213	0	0	0	0	LT	1	PSPI	PHILIPS MR/PART	Slice Thickness	f	t	\N	\N	\N
(0031,"SIEMENS RIS",10)	49	16	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Request UID	f	t	\N	\N	\N
(0031,"SIEMENS ISI",12)	49	18	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Examination Reason	f	t	\N	\N	\N
(0031,"SIEMENS ISI",30)	49	48	0	0	0	0	DA	1	SSPI	SIEMENS ISI	Requested Date	f	t	\N	\N	\N
(0031,"SIEMENS ISI",32)	49	50	0	0	0	0	TM	1	SSPI	SIEMENS ISI	Worklist Request Start Time	f	t	\N	\N	\N
(0031,"SIEMENS ISI",33)	49	51	0	0	0	0	TM	1	SSPI	SIEMENS ISI	Worklist Request End Time	f	t	\N	\N	\N
(0031,"SIEMENS RIS",45)	49	69	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Requesting Physician	f	t	\N	\N	\N
(0031,"SIEMENS ISI",4a)	49	74	0	0	0	0	TM	1	SSPI	SIEMENS ISI	Requested Time	f	t	\N	\N	\N
(0031,"SIEMENS RIS",50)	49	80	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Requested Physician	f	t	\N	\N	\N
(0031,"SIEMENS ISI",80)	49	128	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Requested Location	f	t	\N	\N	\N
(0033,"GEMS_GNHD_01",01)	51	1	0	0	0	0	UN	1	GEM	GEMS_GNHD_01	?	f	t	\N	\N	\N
(0033,"GEMS_CTHD_01",02)	51	2	0	0	0	0	UN	1	GEM	GEMS_CTHD_01	?	f	t	\N	\N	\N
(0033,"GEMS_GNHD_01",02)	51	2	0	0	0	0	UN	1	GEM	GEMS_GNHD_01	?	f	t	\N	\N	\N
(0033,"GEMS_YMHD_01",05)	51	5	0	0	0	0	UN	1	GEM	GEMS_YMHD_01	?	f	t	\N	\N	\N
(0033,"GEMS_YMHD_01",06)	51	6	0	0	0	0	UN	1	GEM	GEMS_YMHD_01	?	f	t	\N	\N	\N
(0033,"SIEMENS RIS",10)	51	16	0	0	0	0	LT	1	SSPI	SIEMENS RIS	Patient Study UID	f	t	\N	\N	\N
(0037,"GEMS_DRS_1",10)	55	16	0	0	0	0	LO	1	GEM	GEMS_DRS_1	ReferringDepartment	f	t	\N	\N	\N
(0037,"GEMS_DRS_1",20)	55	32	0	0	0	0	US	1	GEM	GEMS_DRS_1	ScreenNumber	f	t	\N	\N	\N
(0037,"GEMS_DRS_1",40)	55	64	0	0	0	0	SH	1	GEM	GEMS_DRS_1	LeftOrientation	f	t	\N	\N	\N
(0037,"GEMS_DRS_1",42)	55	66	0	0	0	0	SH	1	GEM	GEMS_DRS_1	RightOrientation	f	t	\N	\N	\N
(0037,"GEMS_DRS_1",50)	55	80	0	0	0	0	CS	1	GEM	GEMS_DRS_1	Inversion	f	t	\N	\N	\N
(0037,"GEMS_DRS_1",60)	55	96	0	0	0	0	US	1	GEM	GEMS_DRS_1	DSA	f	t	\N	\N	\N
(0039,"GEMS_ADWSoft_DPO",80)	57	128	0	0	0	0	IS	1	GEM	GEMS_ADWSoft_DPO	Private Entity Number	f	t	\N	\N	\N
(0039,"GEMS_ADWSoft_DPO",85)	57	133	0	0	0	0	DA	1	GEM	GEMS_ADWSoft_DPO	Private Entity Date	f	t	\N	\N	\N
(0039,"GEMS_ADWSoft_DPO",90)	57	144	0	0	0	0	TM	1	GEM	GEMS_ADWSoft_DPO	Private Entity Time	f	t	\N	\N	\N
(0039,"GEMS_ADWSoft_DPO",95)	57	149	0	0	0	0	LO	1	GEM	GEMS_ADWSoft_DPO	Private Entity Launch Command	f	t	\N	\N	\N
(0039,"GEMS_ADWSoft_DPO",aa)	57	170	0	0	0	0	CS	1	GEM	GEMS_ADWSoft_DPO	Private Entity Type	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",00)	65	0	0	0	0	0	LT	1	PA3	PAPYRUS 3.0	Papyrus Comments	f	t	\N	\N	\N
(0041,"PAPYRUS",00)	65	0	0	0	0	0	LT	1-n	PAP	PAPYRUS	Papyrus Comments	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",10)	65	16	0	0	0	0	SQ	1	PA3	PAPYRUS 3.0	Pointer Sequence	f	t	\N	\N	\N
(0041,"PAPYRUS",10)	65	16	0	0	0	0	US	1	PAP	PAPYRUS	Folder Type	f	t	\N	\N	\N
(0041,"SIEMENS DLR.01",10)	65	16	0	0	0	0	US	1	SSPI	SIEMENS DLR.01	Number of Hardcopies	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",11)	65	17	0	0	0	0	UL	1	PA3	PAPYRUS 3.0	Image Pointer	f	t	\N	\N	\N
(0041,"PAPYRUS",11)	65	17	0	0	0	0	LT	1	PAP	PAPYRUS	Patient Folder Data Set ID	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",12)	65	18	0	0	0	0	UL	1	PA3	PAPYRUS 3.0	Pixel Offset	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",13)	65	19	0	0	0	0	SQ	1	PA3	PAPYRUS 3.0	Image Identifier Sequence	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",14)	65	20	0	0	0	0	SQ	1	PA3	PAPYRUS 3.0	External File Reference Sequence	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",15)	65	21	0	0	0	0	US	1	PA3	PAPYRUS 3.0	Number of Images	f	t	\N	\N	\N
(0041,"PAPYRUS",20)	65	32	0	0	0	0	LT	1	PAP	PAPYRUS	Folder Name	f	t	\N	\N	\N
(0041,"SIEMENS DLR.01",20)	65	32	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Film Format	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",21)	65	33	0	0	0	0	UI	1	PA3	PAPYRUS 3.0	Referenced SOP Class UID	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",22)	65	34	0	0	0	0	UI	1	PA3	PAPYRUS 3.0	Referenced SOP Instance UID	f	t	\N	\N	\N
(0041,"PAPYRUS",30)	65	48	0	0	0	0	DA	1	PAP	PAPYRUS	Creation Date	f	t	\N	\N	\N
(0041,"SIEMENS DLR.01",30)	65	48	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Film Size	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",31)	65	49	0	0	0	0	LT	1	PA3	PAPYRUS 3.0	Referenced File Name	f	t	\N	\N	\N
(0041,"SIEMENS DLR.01",31)	65	49	0	0	0	0	LT	1	SSPI	SIEMENS DLR.01	Full Film Format	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",32)	65	50	0	0	0	0	LT	1-n	PA3	PAPYRUS 3.0	Referenced File Path	f	t	\N	\N	\N
(0041,"PAPYRUS",32)	65	50	0	0	0	0	TM	1	PAP	PAPYRUS	Creation Time	f	t	\N	\N	\N
(0041,"PAPYRUS",34)	65	52	0	0	0	0	DA	1	PAP	PAPYRUS	Modified Date	f	t	\N	\N	\N
(0041,"PAPYRUS",36)	65	54	0	0	0	0	TM	1	PAP	PAPYRUS	Modified Time	f	t	\N	\N	\N
(0041,"PAPYRUS",40)	65	64	0	0	0	0	LT	1-n	PAP	PAPYRUS	Owner Name	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",41)	65	65	0	0	0	0	UI	1	PA3	PAPYRUS 3.0	Referenced Image SOP Class UID	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",42)	65	66	0	0	0	0	UI	1	PA3	PAPYRUS 3.0	Referenced Image SOP Instance UID	f	t	\N	\N	\N
(0041,"PAPYRUS 3.0",50)	65	80	0	0	0	0	SQ	1	PA3	PAPYRUS 3.0	Image Sequence	f	t	\N	\N	\N
(0041,"PAPYRUS",50)	65	80	0	0	0	0	LT	1	PAP	PAPYRUS	Folder Status	f	t	\N	\N	\N
(0041,"PAPYRUS",60)	65	96	0	0	0	0	UL	1	PAP	PAPYRUS	Number of Images	f	t	\N	\N	\N
(0041,"PAPYRUS",62)	65	98	0	0	0	0	UL	1	PAP	PAPYRUS	Number of Other	f	t	\N	\N	\N
(0041,"PAPYRUS",a0)	65	160	0	0	0	0	LT	1-n	PAP	PAPYRUS	External Folder Element DSID	f	t	\N	\N	\N
(0041,"PAPYRUS",a1)	65	161	0	0	0	0	US	1-n	PAP	PAPYRUS	External Folder Element Data Set Type	f	t	\N	\N	\N
(0041,"PAPYRUS",a2)	65	162	0	0	0	0	LT	1-n	PAP	PAPYRUS	External Folder Element File Location	f	t	\N	\N	\N
(0041,"PAPYRUS",a3)	65	163	0	0	0	0	UL	1-n	PAP	PAPYRUS	External Folder Element Length	f	t	\N	\N	\N
(0041,"PAPYRUS",b0)	65	176	0	0	0	0	LT	1-n	PAP	PAPYRUS	Internal Folder Element DSID	f	t	\N	\N	\N
(0041,"PAPYRUS",b1)	65	177	0	0	0	0	US	1-n	PAP	PAPYRUS	Internal Folder Element Data Set Type	f	t	\N	\N	\N
(0041,"PAPYRUS",b2)	65	178	0	0	0	0	UL	1-n	PAP	PAPYRUS	Internal Offset To Data Set	f	t	\N	\N	\N
(0041,"PAPYRUS",b3)	65	179	0	0	0	0	UL	1-n	PAP	PAPYRUS	Internal Offset To Image	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",01)	67	1	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Bitmap Of Prescan Options	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",02)	67	2	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Gradient Offset In X	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",03)	67	3	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Gradient Offset In Y	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",04)	67	4	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Gradient Offset In Z	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",05)	67	5	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Image Is Original Or Unoriginal	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",06)	67	6	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Number Of EPI Shots	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",07)	67	7	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Views Per Segment	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",08)	67	8	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Respiratory Rate In BPM	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",09)	67	9	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Respiratory Trigger Point	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",0a)	67	10	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Type Of Receiver Used	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",0b)	67	11	0	0	0	0	DS	1	GEM	GEMS_PARM_01	Peak Rate Of Change Of Gradient Field	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",0c)	67	12	0	0	0	0	DS	1	GEM	GEMS_PARM_01	Limits In Units Of Percent	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",0d)	67	13	0	0	0	0	DS	1	GEM	GEMS_PARM_01	PSD Estimated Limit	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",0e)	67	14	0	0	0	0	DS	1	GEM	GEMS_PARM_01	PSD Estimated Limit In Tesla Per Second	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",0f)	67	15	0	0	0	0	DS	1	GEM	GEMS_PARM_01	SAR Avg Head	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",10)	67	16	0	0	0	0	US	1	GEM	GEMS_PARM_01	Window Value	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",11)	67	17	0	0	0	0	US	1	GEM	GEMS_PARM_01	Total Input Views	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",12)	67	18	0	0	0	0	SS	3	GEM	GEMS_PARM_01	Xray Chain	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",13)	67	19	0	0	0	0	SS	5	GEM	GEMS_PARM_01	Recon Kernel Parameters	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",14)	67	20	0	0	0	0	SS	3	GEM	GEMS_PARM_01	Calibration Parameters	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",15)	67	21	0	0	0	0	SS	3	GEM	GEMS_PARM_01	Total Output Views	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",16)	67	22	0	0	0	0	SS	5	GEM	GEMS_PARM_01	Number Of Overranges	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",17)	67	23	0	0	0	0	DS	1	GEM	GEMS_PARM_01	IBH Image Scale Factors	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",18)	67	24	0	0	0	0	DS	3	GEM	GEMS_PARM_01	BBH Coefficients	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",19)	67	25	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Number Of BBH Chains To Blend	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",1a)	67	26	0	0	0	0	SL	1	GEM	GEMS_PARM_01	Starting Channel Number	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",1b)	67	27	0	0	0	0	SS	1	GEM	GEMS_PARM_01	PPScan Parameters	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",1c)	67	28	0	0	0	0	SS	1	GEM	GEMS_PARM_01	GE Image Integrity	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",1d)	67	29	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Level Value	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",1e)	67	30	0	0	0	0	DS	1	GEM	GEMS_PARM_01	Delta Start Time	f	t	\N	\N	\N
(0043,"GE_GENESIS_REV3.0",1e)	67	30	0	0	0	0	DS	1	GEM	GE_GENESIS_REV3.0	Delta Start Time	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",1f)	67	31	0	0	0	0	SL	1	GEM	GEMS_PARM_01	Max Overranges In A View	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",20)	67	32	0	0	0	0	DS	1	GEM	GEMS_PARM_01	Avg Overranges All Views	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",21)	67	33	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Corrected Afterglow Terms	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",25)	67	37	0	0	0	0	SS	6	GEM	GEMS_PARM_01	Reference Channels	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",26)	67	38	0	0	0	0	US	6	GEM	GEMS_PARM_01	No Views Ref Channels Blocked	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",27)	67	39	0	0	0	0	SH	1	GEM	GEMS_PARM_01	Scan Pitch Ratio	f	t	\N	\N	\N
(0043,"GE_GENESIS_REV3.0",27)	67	39	0	0	0	0	SH	1	GEM	GE_GENESIS_REV3.0	Scan Pitch Ratio	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",28)	67	40	0	0	0	0	OB	1	GEM	GEMS_PARM_01	Unique Image Identifier	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",29)	67	41	0	0	0	0	OB	1	GEM	GEMS_PARM_01	Histogram Tables	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",2a)	67	42	0	0	0	0	OB	1	GEM	GEMS_PARM_01	User Defined Data	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",2b)	67	43	0	0	0	0	SS	4	GEM	GEMS_PARM_01	Private Scan Options	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",2c)	67	44	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Effective Echo Spacing	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",2d)	67	45	0	0	0	0	SH	1	GEM	GEMS_PARM_01	String Slop Field 1	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",2e)	67	46	0	0	0	0	SH	1	GEM	GEMS_PARM_01	String Slop Field 2	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",2f)	67	47	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Raw Data Type	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",31)	67	49	0	0	0	0	DS	2	GEM	GEMS_PARM_01	RA Coord Of Target Recon Centre	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",32)	67	50	0	0	0	0	SS	1	GEM	GEMS_PARM_01	Raw Data Type	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",33)	67	51	0	0	0	0	FL	1	GEM	GEMS_PARM_01	Neg Scan Spacing	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",34)	67	52	0	0	0	0	IS	1	GEM	GEMS_PARM_01	Offset Frequency	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",35)	67	53	0	0	0	0	UL	1	GEM	GEMS_PARM_01	User Usage Tag	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",36)	67	54	0	0	0	0	UL	1	GEM	GEMS_PARM_01	User Fill Map MSW	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",37)	67	55	0	0	0	0	UL	1	GEM	GEMS_PARM_01	User Fill Map LSW	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",38)	67	56	0	0	0	0	FL	24	GEM	GEMS_PARM_01	User 25 To User 48	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",39)	67	57	0	0	0	0	IS	4	GEM	GEMS_PARM_01	Slop Integer 6 To Slop Integer 9	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",40)	67	64	0	0	0	0	FL	4	GEM	GEMS_PARM_01	Trigger On Position	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",41)	67	65	0	0	0	0	FL	4	GEM	GEMS_PARM_01	Degree Of Rotation	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",42)	67	66	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Trigger Source	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",43)	67	67	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Fpa Gain	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",44)	67	68	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Output Source	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",45)	67	69	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Ad Input	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",46)	67	70	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Cal Mode	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",47)	67	71	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Cal Frequency	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",48)	67	72	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Reg Xm	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",49)	67	73	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Auto Zero	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",4a)	67	74	0	0	0	0	SS	4	GEM	GEMS_PARM_01	Starting Channel Of View	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",4b)	67	75	0	0	0	0	SL	4	GEM	GEMS_PARM_01	DAS Xm Pattern	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",4c)	67	76	0	0	0	0	SS	4	GEM	GEMS_PARM_01	TGGC Trigger Mode	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",4d)	67	77	0	0	0	0	FL	4	GEM	GEMS_PARM_01	Start Scan To Xray On Delay	f	t	\N	\N	\N
(0043,"GEMS_PARM_01",4e)	67	78	0	0	0	0	FL	4	GEM	GEMS_PARM_01	Duration Of Xray On	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",04)	69	4	0	0	0	0	CS	1	GEM	GEMS_SENO_02	AES	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",06)	69	6	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Angulation	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",09)	69	9	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Real Magnification Factor	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",0b)	69	11	0	0	0	0	CS	1	GEM	GEMS_SENO_02	Senograph Type	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",0c)	69	12	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Integration Time	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",0d)	69	13	0	0	0	0	DS	1	GEM	GEMS_SENO_02	ROI Origin X and Y	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",11)	69	17	0	0	0	0	DS	2	GEM	GEMS_SENO_02	Receptor Size cm X and Y	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",12)	69	18	0	0	0	0	IS	2	GEM	GEMS_SENO_02	Receptor Size Pixels X and Y	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",13)	69	19	0	0	0	0	ST	1	GEM	GEMS_SENO_02	Screen	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",14)	69	20	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Pixel Pitch Microns	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",15)	69	21	0	0	0	0	IS	1	GEM	GEMS_SENO_02	Pixel Depth Bits	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",16)	69	22	0	0	0	0	IS	2	GEM	GEMS_SENO_02	Binning Factor X and Y	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",1b)	69	27	0	0	0	0	CS	1	GEM	GEMS_SENO_02	Clinical View	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",1d)	69	29	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Mean Of Raw Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",1e)	69	30	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Mean Of Offset Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",1f)	69	31	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Mean Of Corrected Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",20)	69	32	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Mean Of Region Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",21)	69	33	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Mean Of Log Region Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",22)	69	34	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Standard Deviation Of Raw Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",23)	69	35	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Standard Deviation Of Corrected Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",24)	69	36	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Standard Deviation Of Region Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",25)	69	37	0	0	0	0	DS	1	GEM	GEMS_SENO_02	Standard Deviation Of Log Region Gray Levels	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",26)	69	38	0	0	0	0	OB	1	GEM	GEMS_SENO_02	MAO Buffer	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",27)	69	39	0	0	0	0	IS	1	GEM	GEMS_SENO_02	Set Number	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",28)	69	40	0	0	0	0	CS	1	GEM	GEMS_SENO_02	WindowingType (LINEAR or GAMMA)	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",29)	69	41	0	0	0	0	DS	1-n	GEM	GEMS_SENO_02	WindowingParameters	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",2a)	69	42	0	0	0	0	IS	1	GEM	GEMS_SENO_02	Crosshair Cursor X Coordinates	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",2b)	69	43	0	0	0	0	IS	1	GEM	GEMS_SENO_02	Crosshair Cursor Y Coordinates	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",39)	69	57	0	0	0	0	US	1	GEM	GEMS_SENO_02	Vignette Rows	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",3a)	69	58	0	0	0	0	US	1	GEM	GEMS_SENO_02	Vignette Columns	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",3b)	69	59	0	0	0	0	US	1	GEM	GEMS_SENO_02	Vignette Bits Allocated	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",3c)	69	60	0	0	0	0	US	1	GEM	GEMS_SENO_02	Vignette Bits Stored	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",3d)	69	61	0	0	0	0	US	1	GEM	GEMS_SENO_02	Vignette High Bit	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",3e)	69	62	0	0	0	0	US	1	GEM	GEMS_SENO_02	Vignette Pixel Representation	f	t	\N	\N	\N
(0045,"GEMS_SENO_02",3f)	69	63	0	0	0	0	OB	1	GEM	GEMS_SENO_02	Vignette Pixel Data	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",01)	71	1	0	0	0	0	SQ	1	GEM	GEMS_ADWSoft_3D1	Reconstruction Parameters Sequence	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",50)	71	80	0	0	0	0	UL	1	GEM	GEMS_ADWSoft_3D1	Volume Voxel Count	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",51)	71	81	0	0	0	0	UL	1	GEM	GEMS_ADWSoft_3D1	Volume Segment Count	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",53)	71	83	0	0	0	0	US	1	GEM	GEMS_ADWSoft_3D1	Volume Slice Size	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",54)	71	84	0	0	0	0	US	1	GEM	GEMS_ADWSoft_3D1	Volume Slice Count	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",55)	71	85	0	0	0	0	SL	1	GEM	GEMS_ADWSoft_3D1	Volume Threshold Value	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",57)	71	87	0	0	0	0	DS	1	GEM	GEMS_ADWSoft_3D1	Volume Voxel Ratio	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",58)	71	88	0	0	0	0	DS	1	GEM	GEMS_ADWSoft_3D1	Volume Voxel Size	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",59)	71	89	0	0	0	0	US	1	GEM	GEMS_ADWSoft_3D1	Volume Z Position Size	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",60)	71	96	0	0	0	0	DS	9	GEM	GEMS_ADWSoft_3D1	Volume Base Line	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",61)	71	97	0	0	0	0	DS	3	GEM	GEMS_ADWSoft_3D1	Volume Center Point	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",63)	71	99	0	0	0	0	SL	1	GEM	GEMS_ADWSoft_3D1	Volume Skew Base	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",64)	71	100	0	0	0	0	DS	9	GEM	GEMS_ADWSoft_3D1	Volume Registration Transform Rotation Matrix	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",65)	71	101	0	0	0	0	DS	3	GEM	GEMS_ADWSoft_3D1	Volume Registration Transform Translation Vector	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",70)	71	112	0	0	0	0	DS	1-n	GEM	GEMS_ADWSoft_3D1	KVP List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",71)	71	113	0	0	0	0	IS	1-n	GEM	GEMS_ADWSoft_3D1	XRay Tube Current List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",72)	71	114	0	0	0	0	IS	1-n	GEM	GEMS_ADWSoft_3D1	Exposure List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",80)	71	128	0	0	0	0	LO	1	GEM	GEMS_ADWSoft_3D1	Acquisition DLX Identifier	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",85)	71	133	0	0	0	0	SQ	1	GEM	GEMS_ADWSoft_3D1	Acquisition DLX 2D Series Sequence	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",89)	71	137	0	0	0	0	DS	1-n	GEM	GEMS_ADWSoft_3D1	Contrast Agent Volume List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",8a)	71	138	0	0	0	0	US	1	GEM	GEMS_ADWSoft_3D1	Number Of Injections	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",8b)	71	139	0	0	0	0	US	1	GEM	GEMS_ADWSoft_3D1	Frame Count	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",91)	71	145	0	0	0	0	LO	1	GEM	GEMS_ADWSoft_3D1	XA 3D Reconstruction Algorithm Name	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",92)	71	146	0	0	0	0	CS	1	GEM	GEMS_ADWSoft_3D1	XA 3D Reconstruction Algorithm Version	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",93)	71	147	0	0	0	0	DA	1	GEM	GEMS_ADWSoft_3D1	DLX Calibration Date	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",94)	71	148	0	0	0	0	TM	1	GEM	GEMS_ADWSoft_3D1	DLX Calibration Time	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",95)	71	149	0	0	0	0	CS	1	GEM	GEMS_ADWSoft_3D1	DLX Calibration Status	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",96)	71	150	0	0	0	0	IS	1-n	GEM	GEMS_ADWSoft_3D1	Used Frames	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",98)	71	152	0	0	0	0	US	1	GEM	GEMS_ADWSoft_3D1	Transform Count	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",99)	71	153	0	0	0	0	SQ	1	GEM	GEMS_ADWSoft_3D1	Transform Sequence	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",9a)	71	154	0	0	0	0	DS	9	GEM	GEMS_ADWSoft_3D1	Transform Rotation Matrix	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",9b)	71	155	0	0	0	0	DS	3	GEM	GEMS_ADWSoft_3D1	Transform Translation Vector	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",9c)	71	156	0	0	0	0	LO	1	GEM	GEMS_ADWSoft_3D1	Transform Label	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",b0)	71	176	0	0	0	0	SQ	1	GEM	GEMS_ADWSoft_3D1	Wireframe List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",b1)	71	177	0	0	0	0	US	1	GEM	GEMS_ADWSoft_3D1	Wireframe Count	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",b2)	71	178	0	0	0	0	US	1	GEM	GEMS_ADWSoft_3D1	Location System	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",b5)	71	181	0	0	0	0	LO	1	GEM	GEMS_ADWSoft_3D1	Wireframe Name	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",b6)	71	182	0	0	0	0	LO	1	GEM	GEMS_ADWSoft_3D1	Wireframe Group Name	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",b7)	71	183	0	0	0	0	LO	1	GEM	GEMS_ADWSoft_3D1	Wireframe Color	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",b8)	71	184	0	0	0	0	SL	1	GEM	GEMS_ADWSoft_3D1	Wireframe Attributes	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",b9)	71	185	0	0	0	0	SL	1	GEM	GEMS_ADWSoft_3D1	Wireframe Point Count	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",ba)	71	186	0	0	0	0	SL	1	GEM	GEMS_ADWSoft_3D1	Wireframe Timestamp	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",bb)	71	187	0	0	0	0	SQ	1	GEM	GEMS_ADWSoft_3D1	Wireframe Point List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",bc)	71	188	0	0	0	0	DS	3	GEM	GEMS_ADWSoft_3D1	Wireframe Points Coordinates	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",c0)	71	192	0	0	0	0	DS	3	GEM	GEMS_ADWSoft_3D1	Volume Upper Left High Corner RAS	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",c1)	71	193	0	0	0	0	DS	9	GEM	GEMS_ADWSoft_3D1	Volume Slice To RAS Rotation Matrix	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",c2)	71	194	0	0	0	0	DS	1	GEM	GEMS_ADWSoft_3D1	Volume Upper Left High Corner TLOC	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",d1)	71	209	0	0	0	0	OB	1	GEM	GEMS_ADWSoft_3D1	Volume Segment List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",d2)	71	210	0	0	0	0	OB	1	GEM	GEMS_ADWSoft_3D1	Volume Gradient List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",d3)	71	211	0	0	0	0	OB	1	GEM	GEMS_ADWSoft_3D1	Volume Density List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",d4)	71	212	0	0	0	0	OB	1	GEM	GEMS_ADWSoft_3D1	Volume Z Position List	f	t	\N	\N	\N
(0047,"GEMS_ADWSoft_3D1",d5)	71	213	0	0	0	0	OB	1	GEM	GEMS_ADWSoft_3D1	Volume Original Index List	f	t	\N	\N	\N
(0051,"SIEMENS CM VA0  CMS",10)	81	16	0	0	0	0	LT	1-n	SSPI	SIEMENS CM VA0  CMS	Image Text	f	t	\N	\N	\N
(0055,"SIEMENS ISI",46)	85	70	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Current Ward	f	t	\N	\N	\N
(0087,"1.2.840.113708.794.1.1.2.0",10)	135	16	0	0	0	0	CS	1	ARM	1.2.840.113708.794.1.1.2.0	Media Type	f	t	\N	\N	\N
(0087,"1.2.840.113708.794.1.1.2.0",20)	135	32	0	0	0	0	CS	1	ARM	1.2.840.113708.794.1.1.2.0	Media Location	f	t	\N	\N	\N
(0087,"1.2.840.113708.794.1.1.2.0",50)	135	80	0	0	0	0	IS	1	ARM	1.2.840.113708.794.1.1.2.0	Estimated Retrieve Time	f	t	\N	\N	\N
(0095,"SIENET",01)	149	1	0	0	0	0	LT	1	SSPI	SIENET	Examination Folder ID	f	t	\N	\N	\N
(0095,"SIENET",04)	149	4	0	0	0	0	UL	1	SSPI	SIENET	Folder Reported Status	f	t	\N	\N	\N
(0095,"SIENET",05)	149	5	0	0	0	0	LT	1	SSPI	SIENET	Folder Reporting Radiologist	f	t	\N	\N	\N
(0095,"SIENET",07)	149	7	0	0	0	0	LT	1	SSPI	SIENET	SIENET ISA PLA	f	t	\N	\N	\N
(0099,"SIENET",02)	153	2	0	0	0	0	UL	1	SSPI	SIENET	Data Object Attributes	f	t	\N	\N	\N
(00e1,"ELSCINT1",01)	225	1	0	0	0	0	US	1	EL1	ELSCINT1	Data Dictionary Version	f	t	\N	\N	\N
(00e1,"ELSCINT1",14)	225	20	0	0	0	0	LT	1	EL1	ELSCINT1	?	f	t	\N	\N	\N
(00e1,"ELSCINT1",22)	225	34	0	0	0	0	DS	2	EL1	ELSCINT1	?	f	t	\N	\N	\N
(00e1,"ELSCINT1",23)	225	35	0	0	0	0	DS	2	EL1	ELSCINT1	?	f	t	\N	\N	\N
(00e1,"ELSCINT1",24)	225	36	0	0	0	0	LT	1	EL1	ELSCINT1	?	f	t	\N	\N	\N
(00e1,"ELSCINT1",25)	225	37	0	0	0	0	LT	1	EL1	ELSCINT1	?	f	t	\N	\N	\N
(00e1,"ELSCINT1",40)	225	64	0	0	0	0	SH	1	EL1	ELSCINT1	Offset From CT MR Images	f	t	\N	\N	\N
(0193,"SIEMENS ISI",02)	403	2	0	0	0	0	DS	1	SSPI	SIEMENS ISI	RIS Key	f	t	\N	\N	\N
(0307,"SIEMENS ISI",01)	775	1	0	0	0	0	UN	1	SSPI	SIEMENS ISI	RIS Worklist IMGEF	f	t	\N	\N	\N
(0309,"SIEMENS ISI",01)	777	1	0	0	0	0	UN	1	SSPI	SIEMENS ISI	RIS Report IMGEF	f	t	\N	\N	\N
(0601,"ELSCINT1",00)	1537	0	0	0	0	0	SH	1	EL1	ELSCINT1	Implementation Version	f	t	\N	\N	\N
(0601,"ELSCINT1",20)	1537	32	0	0	0	0	DS	1	EL1	ELSCINT1	Relative Table Position	f	t	\N	\N	\N
(0601,"ELSCINT1",21)	1537	33	0	0	0	0	DS	1	EL1	ELSCINT1	Relative Table Height	f	t	\N	\N	\N
(0601,"ELSCINT1",30)	1537	48	0	0	0	0	SH	1	EL1	ELSCINT1	Surview Direction	f	t	\N	\N	\N
(0601,"ELSCINT1",31)	1537	49	0	0	0	0	DS	1	EL1	ELSCINT1	Surview Length	f	t	\N	\N	\N
(0601,"ELSCINT1",50)	1537	80	0	0	0	0	SH	1	EL1	ELSCINT1	Image View Type	f	t	\N	\N	\N
(0601,"ELSCINT1",70)	1537	112	0	0	0	0	DS	1	EL1	ELSCINT1	Batch Number	f	t	\N	\N	\N
(0601,"ELSCINT1",71)	1537	113	0	0	0	0	DS	1	EL1	ELSCINT1	Batch Size	f	t	\N	\N	\N
(0601,"ELSCINT1",72)	1537	114	0	0	0	0	DS	1	EL1	ELSCINT1	Batch Slice Number	f	t	\N	\N	\N
(1369,"AEGIS_DICOM_2.00",00)	4969	0	0	0	0	0	US	1-n	AEG	AEGIS_DICOM_2.00	?	f	t	\N	\N	\N
(4009,"SIEMENS ISI",01)	16393	1	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Report ID	f	t	\N	\N	\N
(4009,"SIEMENS ISI",20)	16393	32	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Report Status	f	t	\N	\N	\N
(4009,"SIEMENS ISI",30)	16393	48	0	0	0	0	DA	1	SSPI	SIEMENS ISI	Report Creation Date	f	t	\N	\N	\N
(4009,"SIEMENS ISI",70)	16393	112	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Report Approving Physician	f	t	\N	\N	\N
(4009,"SIEMENS ISI",e0)	16393	224	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Report Text	f	t	\N	\N	\N
(4009,"SIEMENS ISI",e1)	16393	225	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Report Author	f	t	\N	\N	\N
(4009,"SIEMENS ISI",e3)	16393	227	0	0	0	0	LT	1	SSPI	SIEMENS ISI	Reporting Radiologist	f	t	\N	\N	\N
(6001,"PHILIPS MR/LAST",00)	24577	0	0	0	0	0	LT	1	PSPI	PHILIPS MR/LAST	?	f	t	\N	\N	\N
(6021,"SIEMENS CM VA0  CMS",00)	24609	0	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Image Graphics Format Code	f	t	\N	\N	\N
(6021,"SIEMENS CT VA0  OST",00)	24609	0	0	0	0	0	LT	1	SSPI	SIEMENS CT VA0  OST	Osteo Contour Comment	f	t	\N	\N	\N
(6021,"SIEMENS CM VA0  CMS",10)	24609	16	0	0	0	0	LT	1	SSPI	SIEMENS CM VA0  CMS	Image Graphics	f	t	\N	\N	\N
(6021,"SIEMENS CT VA0  OST",10)	24609	16	0	0	0	0	US	256	SSPI	SIEMENS CT VA0  OST	Osteo Contour Buffer	f	t	\N	\N	\N
(6000,"DLX_LKUP_01",01)	24576	1	65280	0	0	0	US	3	GEM	DLX_LKUP_01	Gray Palette Color Lookup Table Descriptor	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",01)	24576	1	65280	0	0	0	LT	1-n	PA3	PAPYRUS 3.0	Linked Overlays	f	t	\N	\N	\N
(6000,"DLX_LKUP_01",02)	24576	2	65280	0	0	0	US	1	GEM	DLX_LKUP_01	Gray Palette Color Lookup Table Data	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",10)	24576	16	65280	0	0	0	US	1	PA3	PAPYRUS 3.0	Overlay Rows	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",11)	24576	17	65280	0	0	0	US	1	PA3	PAPYRUS 3.0	Overlay Columns	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",40)	24576	64	65280	0	0	0	LO	1	PA3	PAPYRUS 3.0	Overlay Type	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",50)	24576	80	65280	0	0	0	US	1-n	PA3	PAPYRUS 3.0	Overlay Origin	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",70)	24576	112	65280	0	0	0	LO	1	PA3	PAPYRUS 3.0	Overlay Font	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",72)	24576	114	65280	0	0	0	LO	1	PA3	PAPYRUS 3.0	Overlay Style	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",74)	24576	116	65280	0	0	0	US	1	PA3	PAPYRUS 3.0	Overlay Font Size	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",76)	24576	118	65280	0	0	0	LO	1	PA3	PAPYRUS 3.0	Overlay Color	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",78)	24576	120	65280	0	0	0	US	1	PA3	PAPYRUS 3.0	Shadow Size	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",80)	24576	128	65280	0	0	0	LO	1	PA3	PAPYRUS 3.0	Fill Pattern	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",82)	24576	130	65280	0	0	0	US	1	PA3	PAPYRUS 3.0	Overlay Pen Size	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",a0)	24576	160	65280	0	0	0	LO	1	PA3	PAPYRUS 3.0	Label	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",a2)	24576	162	65280	0	0	0	LT	1	PA3	PAPYRUS 3.0	Post It Text	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",a4)	24576	164	65280	0	0	0	US	2	PA3	PAPYRUS 3.0	Anchor Point	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",b0)	24576	176	65280	0	0	0	LO	1	PA3	PAPYRUS 3.0	ROI Type	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",b2)	24576	178	65280	0	0	0	LT	1	PA3	PAPYRUS 3.0	Attached Annotation	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",ba)	24576	186	65280	0	0	0	US	1-n	PA3	PAPYRUS 3.0	Contour Points	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",bc)	24576	188	65280	0	0	0	US	1-n	PA3	PAPYRUS 3.0	Mask Data	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",c0)	24576	192	65280	0	0	0	SQ	1	PA3	PAPYRUS 3.0	UIN Overlay Sequence	f	t	\N	\N	\N
(7001,"Picker NM Private Group",01)	28673	1	0	0	0	0	UI	1	PCK	Picker NM Private Group	?	f	t	\N	\N	\N
(7001,"Picker NM Private Group",02)	28673	2	0	0	0	0	OB	1	PCK	Picker NM Private Group	?	f	t	\N	\N	\N
(7001,"SIEMENS MED",10)	28673	16	0	0	0	0	LT	1	SSPI	SIEMENS MED	Dummy	f	t	\N	\N	\N
(7003,"SIEMENS MED",10)	28675	16	0	0	0	0	LT	1	SSPI	SIEMENS MED	Header	f	t	\N	\N	\N
(7005,"SIEMENS MED",10)	28677	16	0	0	0	0	LT	1	SSPI	SIEMENS MED	Dummy	f	t	\N	\N	\N
(7000,"DLX_ANNOT_01",04)	28672	4	65280	0	0	0	ST	1	DLX	DLX_ANNOT_01	TextAnnotation	f	t	\N	\N	\N
(7000,"DLX_ANNOT_01",05)	28672	5	65280	0	0	0	IS	2	DLX	DLX_ANNOT_01	Box	f	t	\N	\N	\N
(7000,"DLX_ANNOT_01",07)	28672	7	65280	0	0	0	IS	2	DLX	DLX_ANNOT_01	ArrowEnd	f	t	\N	\N	\N
(7fe1,"SIEMENS CM VA0  CMS",00)	32737	0	0	0	0	0	OB	1-n	SSPI	SIEMENS CM VA0  CMS	Binary Data	f	t	\N	\N	\N
(7fe3,"SIEMENS NUMARIS II",00)	32739	0	0	0	0	0	LT	1	SSPI	SIEMENS NUMARIS II	Image Graphics Format Code	f	t	\N	\N	\N
(7fe3,"SIEMENS NUMARIS II",10)	32739	16	0	0	0	0	OB	1	SSPI	SIEMENS NUMARIS II	Image Graphics	f	t	\N	\N	\N
(7fe3,"SIEMENS NUMARIS II",20)	32739	32	0	0	0	0	OB	1	SSPI	SIEMENS NUMARIS II	Image Graphics Dummy	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_1.0",01)	32753	1	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",01)	32753	1	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_1.0",02)	32753	2	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",02)	32753	2	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",03)	32753	3	0	0	0	0	IS	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_1.0",03)	32753	3	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",04)	32753	4	0	0	0	0	IS	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",05)	32753	5	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",07)	32753	7	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",08)	32753	8	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",09)	32753	9	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",0a)	32753	10	0	0	0	0	LT	1	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",0b)	32753	11	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",0c)	32753	12	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_CT_1.0",0d)	32753	13	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_CT_1.0	?	f	t	\N	\N	\N
(7ff1,"TOSHIBA_MEC_1.0",10)	32753	16	0	0	0	0	US	1-n	TSH	TOSHIBA_MEC_1.0	?	f	t	\N	\N	\N
(7fe1,"SPI-P Release 1",10)	32737	16	0	0	0	0	OT	1	PSPI	SPI-P Release 1	Pixel Data	f	t	\N	\N	\N
(6000,"PAPYRUS 3.0",60)	24576	96	65280	0	0	0	LO	1	PA3	PAPYRUS 3.0	Editable	f	t	t	\N	\N
(6000,"PAPYRUS 3.0",00)	24576	0	65280	0	0	0	IS	1	PA3	PAPYRUS 3.0	Overlay ID	f	t	t	\N	\N
(0008,0010)	8	16	0	0	0	0	CS	1	2	\N	Recognition Code	t	f	t	\N	\N
(0008,1000)	8	4096	0	0	0	0	AE	1	2	\N	Network ID	t	f	t	\N	\N
(0010,1050)	16	4176	0	0	0	0	LO	1-n	2	\N	Insurance Plan Identification	t	f	t	\N	\N
(0018,4000)	24	16384	0	0	0	0	LT	1-n	2	\N	Acquisition Comments	t	f	t	\N	\N
(0018,7050)	24	28752	0	0	0	0	CS	1-n	3DX	\N	Filter Material	t	f	f	\N	\N
(0018,9218)	24	37400	0	0	0	0	FD	1	3MR	\N	Tag Spacing Second Dimension	t	f	f	\N	\N
(0020,0070)	32	112	0	0	0	0	LO	1	2	\N	Image Geometry Type	t	f	t	\N	\N
(0020,0080)	32	128	0	0	0	0	CS	1-n	2	\N	Masking Image	t	f	t	\N	\N
(0020,1020)	32	4128	0	0	0	0	CS	1-n	2	\N	Reference	t	f	t	\N	\N
(0020,31xx)	32	12544	0	65280	0	0	CS	1-n	2	\N	Source Image IDs	t	f	t	\N	\N
(0020,3401)	32	13313	0	0	0	0	CS	1	2	\N	Modifying Device ID	t	f	t	\N	\N
(0020,3402)	32	13314	0	0	0	0	CS	1	2	\N	Modified Image ID	t	f	t	\N	\N
(0020,3404)	32	13316	0	0	0	0	LO	1	2	\N	Modifying Device Manufacturer	t	f	t	\N	\N
(0020,3406)	32	13318	0	0	0	0	LO	1	2	\N	Modified Image Description	t	f	t	\N	\N
(0020,5002)	32	20482	0	0	0	0	CS	1-n	2	\N	Original Image Identification Nomenclature	t	f	t	\N	\N
(0028,0040)	40	64	0	0	0	0	CS	1	2	\N	Image Format	t	f	t	\N	\N
(0028,0060)	40	96	0	0	0	0	CS	1	2	\N	Compression Code	t	f	t	\N	\N
(0028,0402)	40	1026	0	0	0	0	CS	1	2C	\N	Number of Transform Steps	t	f	f	\N	\N
(0028,0404)	40	1028	0	0	0	0	LO	1-n	2C	\N	Details of Coefficients	t	f	f	\N	\N
(0028,1080)	40	4224	0	0	0	0	CS	1	2	\N	Gray Scale	t	f	t	\N	\N
(0028,3002)	40	12290	0	0	0	0	SS	3	3	\N	LUT Descriptor	t	f	f	\N	\N
(0028,3006)	40	12294	0	0	0	0	OW	1-n	3	\N	LUT Data	t	f	f	\N	\N
(0040,9210)	64	37392	0	0	0	0	SH	1	3MR	\N	LUT Label	t	f	f	\N	\N
(60xx,0045)	24576	69	65280	0	0	0	LO	1	3	\N	Overlay Subtype	t	f	f	\N	\N
(60xx,0060)	24576	96	65280	0	0	0	CS	1	2	\N	Overlay Compression Code	t	f	t	\N	\N
(60xx,0110)	24576	272	65280	0	0	0	CS	1	2	\N	Overlay Format	t	f	t	\N	\N
(fffe,e000)	65534	57344	0	0	0	0		1	3	\N	Item	t	f	f	\N	\N
(fffe,e00d)	65534	57357	0	0	0	0		1	3	\N	Item Delimitation Item	t	f	f	\N	\N
(fffe,e0dd)	65534	57565	0	0	0	0		1	3	\N	Sequence Delimitation Item	t	f	f	\N	\N
(0018,9445)	24	37957	0	0	0	0	UN	1	3-2006	\N		t	\N	t	\N	\N
(300a,02eb)	12298	747	0	0	0	0	LT	1	3-2006	\N	Compensator Description	t	\N	f	\N	\N
(300b,"IMPAC",02)	12299	2	\N	\N	\N	\N	FL	1	\N	IMPAC	Max Collimated Field Diameter	f	t	\N	\N	\N
(300b,"IMPAC",04)	12299	4	\N	\N	\N	\N	FL	1	\N	IMPAC	Planned Distal Target Distance	f	t	\N	\N	\N
(300b,"IMPAC",0e)	12299	14	\N	\N	\N	\N	FL	1	\N	IMPAC	Nominal SOBP Width	f	t	\N	\N	\N
(300b,"ION_PRIVATE",0c)	12299	12	\N	\N	\N	\N	FL	1	\N	ION_PRIVATE	Fixation Light Position	f	t	\N	\N	\N
\.


--
-- Data for Name: sopcl; Type: TABLE DATA; Schema: public; Owner: -
--

COPY sopcl (sopcl_type, sopcl_desc, dir_rec, sopcl_uid, std_ref, retired) FROM stdin;
Instance	Storage Commitment Push Model	\N	1.2.840.10008.1.20.1.1	\N	f
Instance	Storage Commitment Pull Model	\N	1.2.840.10008.1.20.2.1	\N	f
\N	Detached Patient Management Meta	\N	1.2.840.10008.3.1.2.1.4	\N	f
\N	Detached Results Management Meta	\N	1.2.840.10008.3.1.2.5.4	\N	f
\N	Detached Study Management Meta	\N	1.2.840.10008.3.1.2.5.5	\N	f
\N	Basic Grayscale Print Management Meta	\N	1.2.840.10008.5.1.1.9	\N	f
\N	Referenced Grayscale Print Management Meta - Retired	\N	1.2.840.10008.5.1.1.9.1	\N	f
Instance	Printer	\N	1.2.840.10008.5.1.1.17	\N	f
Instance	Printer Configuration Retrieval	\N	1.2.840.10008.5.1.1.17.376	\N	f
\N	Basic Color Print Management Meta	\N	1.2.840.10008.5.1.1.18	\N	f
\N	Referenced Color Print Management Meta - Retired	\N	1.2.840.10008.5.1.1.18.1	\N	f
Instance	Print Queue	\N	1.2.840.10008.5.1.1.25	\N	f
\N	Pull Stored Print Management Meta	\N	1.2.840.10008.5.1.1.32	\N	f
\N	General Purpose Scheduled Procedure Step	STUDY COMPONENT	1.2.840.10008.3.1.4.32.2	\N	f
\N	General Purpose Performed Procedure Step	STUDY COMPONENT	1.2.840.10008.3.1.4.32.3	\N	f
\N	GE Private Dicom MR Image Info Object	IMAGE	1.2.840.113619.4.2	\N	f
\N	GE Private Dicom CT Image Info Object	IMAGE	1.2.840.113619.4.3	\N	f
\N	GE Private Dicom Display Image Info Object	IMAGE	1.2.840.113619.4.4	\N	f
\N	GE Private ARM Migration	\N	1.2.840.113619.4.10	\N	f
Instance	GE Private ARM Migration	\N	1.2.840.113619.7.2	\N	f
\N	Visible Light Image Storage - Trial	IMAGE	1.2.840.10008.5.1.4.1.1.77.1	\N	f
\N	Visible Light Multiframe Image Storage - Trial	IMAGE	1.2.840.10008.5.1.4.1.1.77.2	\N	f
\N	WaveformStorageTrial	WAVEFORM	1.2.840.10008.5.1.4.1.1.9.1	\N	f
\N	TextSRStorageTrial	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.1	\N	f
\N	AudioSRStorageTrial	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.2	\N	f
\N	DetailSRStorageTrial	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.3	\N	f
\N	ComprehensiveSRStorageTrial	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.4	\N	f
\N	Verification SOP Class	\N	1.2.840.10008.1.1	PS 3.4	f
\N	Media Storage Directory Storage	\N	1.2.840.10008.1.3.10	PS 3.4	f
\N	Basic Study Content Notification SOP Class	\N	1.2.840.10008.1.9	PS 3.4	t
\N	Storage Commitment Push Model SOP Class	\N	1.2.840.10008.1.20.1	PS 3.4	f
\N	Storage Commitment Pull Model SOP Class	\N	1.2.840.10008.1.20.2	PS 3.4	t
\N	Procedural Event Logging SOP Class	\N	1.2.840.10008.1.40	PS 3.4	f
\N	Detached Patient Management SOP Class	PATIENT	1.2.840.10008.3.1.2.1.1	PS 3.4	t
\N	Detached Visit Management SOP Class	VISIT	1.2.840.10008.3.1.2.2.1	PS 3.4	t
\N	Detached Study Management SOP Class	STUDY	1.2.840.10008.3.1.2.3.1	PS 3.4	t
\N	Study Component Management SOP Class	STUDY COMPONENT	1.2.840.10008.3.1.2.3.2	PS 3.4	t
\N	Modality Performed Procedure Step SOP Class	STUDY COMPONENT	1.2.840.10008.3.1.2.3.3	PS 3.4	f
\N	Modality Performed Procedure Step Retrieve SOP Class	\N	1.2.840.10008.3.1.2.3.4	PS 3.4	f
\N	Modality Performed Procedure Step Notification SOP Class	\N	1.2.840.10008.3.1.2.3.5	PS 3.4	f
\N	Detached Results Management SOP Class	RESULTS	1.2.840.10008.3.1.2.5.1	PS 3.4	t
\N	Chest CAD SR	\N	1.2.840.10008.5.1.4.1.1.88.65	PS 3.4	f
\N	Detached Interpretation Management SOP Class	INTERPRETATION	1.2.840.10008.3.1.2.6.1	PS 3.4	t
\N	Basic Film Session SOP Class	FILM SESSION	1.2.840.10008.5.1.1.1	PS 3.4	f
\N	Basic Film Box SOP Class	FILM BOX	1.2.840.10008.5.1.1.2	PS 3.4	f
\N	Basic Grayscale Image Box SOP Class	IMAGE BOX	1.2.840.10008.5.1.1.4	PS 3.4	f
\N	Basic Color Image Box SOP Class	IMAGE BOX	1.2.840.10008.5.1.1.4.1	PS 3.4	f
\N	Referenced Image Box SOP Class	\N	1.2.840.10008.5.1.1.4.2	PS 3.4	t
\N	Print Job SOP Class	\N	1.2.840.10008.5.1.1.14	PS 3.4	f
\N	Basic Annotation Box SOP Class	\N	1.2.840.10008.5.1.1.15	PS 3.4	f
\N	Printer SOP Class	\N	1.2.840.10008.5.1.1.16	PS 3.4	f
\N	Printer Configuration Retrieval SOP Class	\N	1.2.840.10008.5.1.1.16.376	PS 3.4	f
\N	VOI LUT Box SOP Class	\N	1.2.840.10008.5.1.1.22	PS 3.4	f
\N	Presentation LUT SOP Class	\N	1.2.840.10008.5.1.1.23	PS 3.4	f
\N	Image Overlay Box SOP Class	\N	1.2.840.10008.5.1.1.24	PS 3.4	t
\N	Basic Print Image Overlay Box SOP Class	\N	1.2.840.10008.5.1.1.24.1	PS 3.4	t
\N	Print Queue Management SOP Class	PRINT QUEUE	1.2.840.10008.5.1.1.26	PS 3.4	t
\N	Stored Print Storage SOP Class	STORED PRINT	1.2.840.10008.5.1.1.27	PS 3.4	t
\N	Hardcopy  Grayscale Image Storage SOP Class	IMAGE	1.2.840.10008.5.1.1.29	PS 3.4	t
\N	Hardcopy Color Image Storage SOP Class	IMAGE	1.2.840.10008.5.1.1.30	PS 3.4	t
\N	Pull Print Request SOP Class	\N	1.2.840.10008.5.1.1.31	PS 3.4	t
\N	Computed Radiography Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.1	PS 3.4	f
\N	Digital X-Ray Image Storage - For Presentation	IMAGE	1.2.840.10008.5.1.4.1.1.1.1	PS 3.4	f
\N	Digital X-Ray Image Storage - For Processing	IMAGE	1.2.840.10008.5.1.4.1.1.1.1.1	PS 3.4	f
\N	Digital Mammography X-Ray Image Storage - For Presentation	IMAGE	1.2.840.10008.5.1.4.1.1.1.2	PS 3.4	f
\N	Digital Mammography X-Ray Image Storage - For Processing	IMAGE	1.2.840.10008.5.1.4.1.1.1.2.1	PS 3.4	f
\N	Digital Intra-oral X-Ray Image Storage - For Presentation	IMAGE	1.2.840.10008.5.1.4.1.1.1.3	PS 3.4	f
\N	Digital Intra-oral X-Ray Image Storage - For Processing	IMAGE	1.2.840.10008.5.1.4.1.1.1.3.1	PS 3.4	f
\N	CT Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.2	PS 3.4	f
\N	Enhanced CT Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.2.1	PS 3.4	f
\N	Ultrasound Multi-frame Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.3	PS 3.4	t
\N	Ultrasound Multi-frame Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.3.1	PS 3.4	f
\N	MR Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.4	PS 3.4	f
\N	Enhanced MR Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.4.1	PS 3.4	f
\N	MR Spectroscopy Storage	\N	1.2.840.10008.5.1.4.1.1.4.2	PS 3.4	f
\N	Nuclear Medicine Image  Storage	IMAGE	1.2.840.10008.5.1.4.1.1.5	PS 3.4	t
\N	Ultrasound Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.6	PS 3.4	t
\N	Ultrasound Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.6.1	PS 3.4	f
\N	Secondary Capture Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.7	PS 3.4	f
\N	Multi-frame Single Bit Secondary Capture Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.7.1	PS 3.4	f
\N	Multi-frame Grayscale Byte Secondary Capture Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.7.2	PS 3.4	f
\N	Multi-frame Grayscale Word Secondary Capture Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.7.3	PS 3.4	f
\N	Multi-frame True Color Secondary Capture Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.7.4	PS 3.4	f
\N	Standalone Overlay Storage	OVERLAY	1.2.840.10008.5.1.4.1.1.8	PS 3.4	t
\N	Standalone Curve Storage	CURVE	1.2.840.10008.5.1.4.1.1.9	PS 3.4	t
\N	12-lead ECG Waveform Storage	WAVEFORM	1.2.840.10008.5.1.4.1.1.9.1.1	PS 3.4	f
\N	General ECG Waveform Storage	WAVEFORM	1.2.840.10008.5.1.4.1.1.9.1.2	PS 3.4	f
\N	Ambulatory ECG Waveform Storage	WAVEFORM	1.2.840.10008.5.1.4.1.1.9.1.3	PS 3.4	f
\N	Hemodynamic Waveform Storage	WAVEFORM	1.2.840.10008.5.1.4.1.1.9.2.1	PS 3.4	f
\N	Cardiac Electrophysiology Waveform Storage	WAVEFORM	1.2.840.10008.5.1.4.1.1.9.3.1	PS 3.4	f
\N	Basic Voice Audio Waveform Storage	WAVEFORM	1.2.840.10008.5.1.4.1.1.9.4.1	PS 3.4	f
\N	Standalone Modality LUT Storage	MODALITY LUT	1.2.840.10008.5.1.4.1.1.10	PS 3.4	t
\N	Standalone VOI LUT Storage	VOI LUT	1.2.840.10008.5.1.4.1.1.11	PS 3.4	t
\N	Grayscale Softcopy Presentation State Storage SOP Class	PRESENTATION	1.2.840.10008.5.1.4.1.1.11.1	PS 3.4	f
\N	Color Softcopy Presentation State Storage SOP Class	\N	1.2.840.10008.5.1.4.1.1.11.2	PS 3.4	f
\N	Pseudo-Color Softcopy Presentation State Storage SOP Class	\N	1.2.840.10008.5.1.4.1.1.11.3	PS 3.4	f
\N	Blending Softcopy Presentation State Storage SOP Class	\N	1.2.840.10008.5.1.4.1.1.11.4	PS 3.4	f
\N	X-Ray Angiographic Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.12.1	PS 3.4	f
\N	Enhanced XA Image Storage	\N	1.2.840.10008.5.1.4.1.1.12.1.1	PS 3.4	f
\N	X-Ray Radiofluoroscopic Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.12.2	PS 3.4	f
\N	Enhanced XRF Image Storage	\N	1.2.840.10008.5.1.4.1.1.12.2.1	PS 3.4	f
\N	X-Ray Angiographic Bi-Plane Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.12.3	PS 3.4	t
\N	Nuclear Medicine Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.20	PS 3.4	f
\N	Raw Data Storage	\N	1.2.840.10008.5.1.4.1.1.66	PS 3.4	f
\N	Spatial Registration Storage	\N	1.2.840.10008.5.1.4.1.1.66.1	PS 3.4	f
\N	Spatial Fiducials Storage	\N	1.2.840.10008.5.1.4.1.1.66.2	PS 3.4	f
\N	Real World Value Mapping Storage	\N	1.2.840.10008.5.1.4.1.1.67	PS 3.4	f
\N	VL Endoscopic Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.77.1.1	PS 3.4	f
\N	Video Endoscopic Image Storage	\N	1.2.840.10008.5.1.4.1.1.77.1.1.1	PS 3.4	f
\N	VL Microscopic Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.77.1.2	PS 3.4	f
\N	Video Microscopic Image Storage	\N	1.2.840.10008.5.1.4.1.1.77.1.2.1	PS 3.4	f
\N	VL Slide-Coordinates Microscopic Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.77.1.3	PS 3.4	f
\N	VL Photographic Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.77.1.4	PS 3.4	f
\N	Video Photographic Image Storage	\N	1.2.840.10008.5.1.4.1.1.77.1.4.1	PS 3.4	f
\N	Ophthalmic Photography 8 Bit Image Storage	\N	1.2.840.10008.5.1.4.1.1.77.1.5.1	PS 3.4	f
\N	Ophthalmic Photography 16 Bit Image Storage	\N	1.2.840.10008.5.1.4.1.1.77.1.5.2	PS 3.4	f
\N	Stereometric Relationship Storage	\N	1.2.840.10008.5.1.4.1.1.77.1.5.3	PS 3.4	f
\N	Basic Text SR	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.11	PS 3.4	f
\N	Enhanced SR	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.22	PS 3.4	f
\N	Comprehensive SR	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.33	PS 3.4	f
\N	Procedure Log Storage	\N	1.2.840.10008.5.1.4.1.1.88.40	PS 3.4	f
\N	Mammography CAD SR	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.50	PS 3.4	f
\N	Key Object Selection Document	SR DOCUMENT	1.2.840.10008.5.1.4.1.1.88.59	PS 3.4	f
\N	X-Ray Radiation Dose SR	\N	1.2.840.10008.5.1.4.1.1.88.67	PS 3.4	f
\N	Encapsulated PDF Storage	\N	1.2.840.10008.5.1.4.1.1.104.1	PS 3.4	f
\N	Positron Emission Tomography Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.128	PS 3.4	f
\N	Standalone PET Curve Storage	CURVE	1.2.840.10008.5.1.4.1.1.129	PS 3.4	t
\N	RT Image Storage	IMAGE	1.2.840.10008.5.1.4.1.1.481.1	PS 3.4	f
\N	RT Dose Storage	RT DOSE	1.2.840.10008.5.1.4.1.1.481.2	PS 3.4	f
\N	RT Structure Set Storage	RT STRUCTURE SET	1.2.840.10008.5.1.4.1.1.481.3	PS 3.4	f
\N	RT Beams Treatment Record Storage	RT TREAT RECORD	1.2.840.10008.5.1.4.1.1.481.4	PS 3.4	f
\N	RT Plan Storage	RT PLAN	1.2.840.10008.5.1.4.1.1.481.5	PS 3.4	f
\N	RT Brachy Treatment Record Storage	RT TREAT RECORD	1.2.840.10008.5.1.4.1.1.481.6	PS 3.4	f
\N	RT Treatment Summary Record Storage	RT TREAT RECORD	1.2.840.10008.5.1.4.1.1.481.7	PS 3.4	f
\N	RT Ion Plan Storage	\N	1.2.840.10008.5.1.4.1.1.481.8	PS 3.4	f
\N	RT Ion Beams Treatment Record Storage	\N	1.2.840.10008.5.1.4.1.1.481.9	PS 3.4	f
\N	Patient Root Query/Retrieve Information Model - FIND	\N	1.2.840.10008.5.1.4.1.2.1.1	PS 3.4	f
\N	Patient Root Query/Retrieve Information Model - MOVE	\N	1.2.840.10008.5.1.4.1.2.1.2	PS 3.4	f
\N	Patient Root Query/Retrieve Information Model - GET	\N	1.2.840.10008.5.1.4.1.2.1.3	PS 3.4	f
\N	Study Root Query/Retrieve Information Model - FIND	\N	1.2.840.10008.5.1.4.1.2.2.1	PS 3.4	f
\N	Study Root Query/Retrieve Information Model - MOVE	\N	1.2.840.10008.5.1.4.1.2.2.2	PS 3.4	f
\N	Study Root Query/Retrieve Information Model - GET	\N	1.2.840.10008.5.1.4.1.2.2.3	PS 3.4	f
\N	Patient/Study Only Query/Retrieve Information Model - FIND	\N	1.2.840.10008.5.1.4.1.2.3.1	PS 3.4	t
\N	Patient/Study Only Query/Retrieve Information Model - MOVE	\N	1.2.840.10008.5.1.4.1.2.3.2	PS 3.4	t
\N	Patient/Study Only Query/Retrieve Information Model - GET	\N	1.2.840.10008.5.1.4.1.2.3.3	PS 3.4	t
\N	Modality Worklist Information Model - FIND	\N	1.2.840.10008.5.1.4.31	PS 3.4	f
\N	General Purpose Worklist Information Model - FIND	\N	1.2.840.10008.5.1.4.32.1	PS 3.4	f
\N	General Purpose Scheduled Procedure Step SOP Class	\N	1.2.840.10008.5.1.4.32.2	PS 3.4	f
\N	General Purpose Performed Procedure Step SOP Class	\N	1.2.840.10008.5.1.4.32.3	PS 3.4	f
\N	Instance Availability Notification SOP Class	\N	1.2.840.10008.5.1.4.33	PS 3.4	f
\N	General Relevant Patient Information Query	\N	1.2.840.10008.5.1.4.37.1	PS 3.4	f
\N	Breast Imaging Relevant Patient Information Query	\N	1.2.840.10008.5.1.4.37.2	PS 3.4	f
\N	Cardiac Relevant Patient Information Query	\N	1.2.840.10008.5.1.4.37.3	PS 3.4	f
\N	Hanging Protocol Storage	\N	1.2.840.10008.5.1.4.38.1	PS 3.4	f
\N	Hanging Protocol Information Model - FIND	\N	1.2.840.10008.5.1.4.38.2	PS 3.4	f
\N	Hanging Protocol Information Model - MOVE	\N	1.2.840.10008.5.1.4.38.3	PS 3.4	f
\.


--
-- Data for Name: vr; Type: TABLE DATA; Schema: public; Owner: -
--

COPY vr (vr_code, vr_name, len, fixed, pad_leading, pad_null, pad_trailing, strip_leading, strip_trailing, strip_trailing_null, vr_type) FROM stdin;
UL	Unsigned Long	4	t	f	f	f	f	f	f	ulong
ST	Short Text	1024	f	f	f	t	f	t	f	text
SQ	Sequence	\N	f	f	f	f	f	f	f	seq
IS	Integer String	12	f	t	f	f	t	t	f	text
UT	Unlimited Text	\N	f	f	f	t	f	f	f	text
AT	Attribute Tag	4	t	f	f	f	f	f	f	ushort
OB	Other Byte	\N	f	f	f	f	f	f	f	raw
UI	Unique Identifier	64	f	f	t	f	f	f	t	text
AS	Age String	4	t	f	f	f	f	f	f	text
SS	Signed Short	2	t	f	f	f	f	f	f	sshort
DT	Date Time	26	f	t	f	f	t	t	f	text
SH	Short String	16	f	t	f	f	t	t	f	text
LO	Long String	64	f	t	f	f	t	t	f	text
PN	Person Name	64	f	f	f	t	f	t	f	text
DS	Decimal String	16	f	t	f	f	t	t	f	text
LT	Long Text	10240	f	f	f	t	f	t	f	text
OW	Other Word	\N	f	f	f	f	f	f	f	raw
CS	Code String	16	f	t	f	f	t	t	f	text
TM	Time	16	f	f	f	t	f	t	f	text
AE	Application Entity	16	f	t	f	f	t	t	f	text
UN	Unknown	\N	f	f	f	f	f	f	f	raw
SL	Signed Long	4	t	f	f	f	f	f	f	slong
DA	Date	10	f	f	f	f	f	f	f	text
OF	Other Float String	\N	f	f	f	f	f	f	f	raw
US	Unsigned Short	2	t	f	f	f	f	f	f	ushort
OT	Other	\N	f	f	f	f	f	f	f	raw
FL	Floating Point Single	4	t	f	f	f	f	f	f	float
FD	Floating Point Double	8	t	f	f	f	f	f	f	double
\.


--
-- Data for Name: xfr_stx; Type: TABLE DATA; Schema: public; Owner: -
--

COPY xfr_stx (xfr_stx_uid, ref, encap, deflated, vax, explicit, short_len, std, retired, name, default_for, doc) FROM stdin;
1.2.826.0.1.3680043.2.494.1.1	f	f	f	f	f	f	f	f	Implicit VR Big Endian		
1.2.840.10008.1.2	f	f	f	t	f	f	t	f	Implicit VR Little Endian	DICOM	PS 3.5
1.2.840.10008.1.2.1	f	f	f	t	t	t	t	f	Explicit VR Little Endian		PS 3.5
1.2.840.10008.1.2.1.99	f	f	t	t	t	t	t	f	Deflated Explicit VR Little Endian		PS 3.5
1.2.840.10008.1.2.2	f	f	f	f	t	t	t	f	Explicit VR Big Endian		PS 3.5
1.2.840.10008.1.2.4.50	f	t	f	t	t	t	t	f	JPEG Baseline (Process 1)	Lossy JPEG 8 Bit Image Compression	PS 3.5
1.2.840.10008.1.2.4.51	f	t	f	t	t	t	t	f	JPEG Extended (Process 2 & 4)	Lossy JPEG 12 Bit Image Compression (Process 4 only)	PS 3.5
1.2.840.10008.1.2.4.52	f	t	f	t	t	t	t	t	JPEG Extended (Process 3 & 5)		PS 3.5
1.2.840.10008.1.2.4.53	f	t	f	t	t	t	t	t	JPEG Spectral Selection, Non-hierarchical (Process 6 & 8)		PS 3.5
1.2.840.10008.1.2.4.54	f	t	f	t	t	t	t	t	JPEG Spectral Selection, Non-hierarchical (Process 7 & 9)		PS 3.5
1.2.840.10008.1.2.4.55	f	t	f	t	t	t	t	t	JPEG Full Progression, Non-hierarchical (Process 10 & 12)		PS 3.5
1.2.840.10008.1.2.4.56	f	t	f	t	t	t	t	t	JPEG Full Progression, Non-hierarchical (Process 13)		PS 3.5
1.2.840.10008.1.2.4.57	f	t	f	t	t	t	t	f	JPEG Lossless, Non-hierarchical (Process 14)		PS 3.5
1.2.840.10008.1.2.4.58	f	t	f	t	t	t	t	t	JPEG Lossless, Non-hierarchical (Process 15)		PS 3.5
1.2.840.10008.1.2.4.59	f	t	f	t	t	t	t	t	JPEG Extended, Hierarchical (Process 16 & 18)		PS 3.5
1.2.840.10008.1.2.4.60	f	t	f	t	t	t	t	t	JPEG Extended, Hierarchical (Process 17 & 19)		PS 3.5
1.2.840.10008.1.2.4.61	f	t	f	t	t	t	t	t	JPEG Spectral Selection, Hierarchical (Process 20 & 22)		PS 3.5
1.2.840.10008.1.2.4.62	f	t	f	t	t	t	t	t	JPEG Spectral Selection, Hierarchical (Process 21 & 23)		PS 3.5
1.2.840.10008.1.2.4.63	f	t	f	t	t	t	t	t	JPEG Full Progression, Hierarchical (Process 24 & 26)		PS 3.5
1.2.840.10008.1.2.4.64	f	t	f	t	t	t	t	t	JPEG Full Progression, Hierarchical (Process 25 & 27)		PS 3.5
1.2.840.10008.1.2.4.65	f	t	f	t	t	t	t	t	JPEG Lossless, Hierarchical (Process 28)		PS 3.5
1.2.840.10008.1.2.4.66	f	t	f	t	t	t	t	t	JPEG Lossless, Hierarchical (Process 29)		PS 3.5
1.2.840.10008.1.2.4.70	f	t	f	t	t	t	t	f	JPEG Lossless, Non-hierachchial, 1st Order Prediction (Process 14 [Selection Value 1])	Lossless JPEG Image Compression	PS 3.5
1.2.840.10008.1.2.4.80	f	t	f	t	t	t	t	f	JPEG-LS Lossless Image Compression		PS 3.5
1.2.840.10008.1.2.4.81	f	t	f	t	t	t	t	f	JPEG-LS Lossy (Near-Lossless) Image Compression		PS 3.5
1.2.840.10008.1.2.4.90	f	t	f	t	t	t	t	f	JPEG 2000 Image Compression (Lossless Only)		PS 3.5
1.2.840.10008.1.2.4.91	f	t	f	t	t	t	t	f	JPEG 2000 Image Compression		PS 3.5
1.2.840.10008.1.2.4.92	f	t	f	t	t	t	t	f	JPEG 2000 Part 2 Multi-component Image Compression (Lossless Only)		PS 3.5
1.2.840.10008.1.2.4.93	f	t	f	t	t	t	t	f	JPEG 2000 Part 2 Multi-component Image Compression		PS 3.5
1.2.840.10008.1.2.4.94	t	f	f	t	t	t	t	f	JPIP Referenced		PS 3.5
1.2.840.10008.1.2.4.95	t	f	t	t	t	t	t	f	JPIP Referenced Deflate		PS 3.5
1.2.840.10008.1.2.5	f	t	f	t	t	t	t	f	RLE Lossless		PS 3.5
1.2.840.10008.1.2.4.100	f	t	f	t	t	t	t	f	MPEG2 Main Profile @ Main Level		PS 3.5
1.3.6.1.4.1.22213.1.147	f	f	f	t	t	f	f	f	Explicit VR Little Endian with Long Lengths	\N	Posda
\.

--
-- PostgreSQL database dump complete
--

