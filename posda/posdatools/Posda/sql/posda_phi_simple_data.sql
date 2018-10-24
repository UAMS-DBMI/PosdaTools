--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: element_seen; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.element_seen (element_seen_id, element_sig_pattern, vr, is_private, tag_name, private_disposition) FROM stdin;
3224	(300a,0010)[<0>](300a,0021)	DS	f	Dose Reference Sequence:Constraint Weight	\N
3231	(300a,0070)[<0>](300c,0050)[<1>](300a,0026)	DS	f	Fraction Group Sequence:Referenced Dose Reference Sequence:Target Prescription Dose	\N
3217	(300a,0180)[<0>](300a,01b4)[<1>](300a,01b8)	SH	f	Patient Setup Sequence:Setup Device Sequence:Setup Device Label	\N
3234	(300c,0080)[<0>](0008,1155)	UI	f	Referenced Dose Sequence:Referenced SOP Instance UID	\N
3218	(300a,0180)[<0>](300a,01b4)	SQ	f	Patient Setup Sequence:Setup Device Sequence	\N
3225	(300a,0010)[<0>](300a,002a)	DS	f	Dose Reference Sequence:Organ at Risk Full-volume Dose	\N
5516	(2005,"Philips MR Imaging DD 002",32)[<0>](2005,"Philips MR Imaging DD 002",40)	LO	t	Blob Data Object Array:Version String	d
3215	(3004,0006)	LO	f	Dose Comment	\N
3228	(300a,0010)[<0>](300a,002c)	DS	f	Dose Reference Sequence:Organ at Risk Maximum Dose	\N
415	(0019,"GEMS_ACQU_01",c2)	SS	t	SATLocationR	k
2183	(0040,0321)	SQ	f	Film Consumption Sequence	\N
3227	(300a,0010)[<0>](300a,002d)	DS	f	Dose Reference Sequence:Organ at Risk Overdose Volume Fraction	\N
3221	(300a,000e)	ST	f	Prescription Description	\N
4929	(5001,"ELSCINT1",92)	CS	t	Unknown	d
4882	(0053,"GEHC_CT_ADVAPP_001",20)	OB	t	Shuttle Flag	k
4803	(0045,"GEMS_HELIOS_01",02)	OB	t	Macro width at ISO Center	k
3229	(300a,0010)[<0>](300a,0025)	DS	f	Dose Reference Sequence:Target Minimum Dose	\N
3842	(0029,"",16)	UN	t	Unknown	d
4895	(0137,"NetRAAD",02)	UN	t	Unknown	d
1715	(0018,9346)	SQ	f	CTDI Phantom Type Code Sequence	\N
1712	(0018,1143)	DS	f	Scan Arc	\N
51	(0018,0050)	DS	f	Slice Thickness	\N
43	(0018,0080)	DS	f	Repetition Time	\N
117	(0028,0010)	US	f	Rows	\N
9	(0008,1110)	SQ	f	Referenced Study Sequence	\N
4	(0008,0050)	SH	f	Accession Number	\N
129	(0018,1044)	DS	f	Contrast/Bolus Total Dose	\N
124	(0008,0012)	DA	f	Instance Creation Date	\N
78	(0018,0022)	CS	f	Scan Options	\N
52	(0018,0087)	DS	f	Magnetic Field Strength	\N
32	(0018,0089)	IS	f	Number of Phase Encoding Steps	\N
46	(0018,0095)	DS	f	Pixel Bandwidth	\N
40	(0028,1050)	DS	f	Window Center	\N
126	(0008,0021)	DA	f	Series Date	\N
10	(0012,0064)	SQ	f	De-identification Method Code Sequence	\N
103	(0008,1140)[<0>](0008,1155)	UI	f	Referenced Image Sequence:Referenced SOP Instance UID	\N
3	(0012,0064)[<0>](0008,0100)	SH	f	De-identification Method Code Sequence:Code Value	\N
45	(0018,0084)	DS	f	Imaging Frequency	\N
79	(0018,1315)	CS	f	Variable Flip Angle Flag	\N
29	(0018,0091)	IS	f	Echo Train Length	\N
25	(0040,0254)	LO	f	Performed Procedure Step Description	\N
22	(0008,1090)	LO	f	Manufacturer's Model Name	\N
84	(0018,0015)	CS	f	Body Part Examined	\N
94	(0008,0032)	TM	f	Acquisition Time	\N
111	(0028,0102)	US	f	High Bit	\N
30	(0018,0086)	IS	f	Echo Number(s)	\N
20	(0008,0070)	LO	f	Manufacturer	\N
113	(0018,1310)	US	f	Acquisition Matrix	\N
109	(0020,000e)	UI	f	Series Instance UID	\N
2	(0020,0010)	SH	f	Study ID	\N
90	(0032,000c)	CS	f	Study Priority ID	\N
107	(0020,000d)	UI	f	Study Instance UID	\N
100	(0010,1010)	AS	f	Patient's Age	\N
86	(0018,0020)	CS	f	Scanning Sequence	\N
35	(0020,0032)	DS	f	Image Position (Patient)	\N
36	(0018,1314)	DS	f	Flip Angle	\N
26	(0010,0020)	LO	f	Patient ID	\N
34	(0010,0010)	PN	f	Patient's Name	\N
88	(0008,0060)	CS	f	Modality	\N
93	(0028,0004)	CS	f	Photometric Interpretation	\N
49	(0018,0093)	DS	f	Percent Sampling	\N
54	(0018,1316)	DS	f	SAR	\N
55	(0018,0083)	DS	f	Number of Averages	\N
50	(0018,1318)	DS	f	dB/dt	\N
121	(0040,0244)	DA	f	Performed Procedure Step Start Date	\N
13	(0012,0064)[<0>](0008,0104)	LO	f	De-identification Method Code Sequence:Code Meaning	\N
3216	(00e1,"ELSCINT1",64)	UN	t	Unknown	d
2843	(01f1,"ELSCINT1",01)	OB	t	Acquisition Type	d
1179	(5008,3000)	UN	f	Curve Data	\N
3222	(300a,0010)[<0>](3006,0084)	IS	f	Dose Reference Sequence:Referenced ROI Number	\N
3220	(300c,0080)	SQ	f	Referenced Dose Sequence	\N
4796	(0009,"GEMS_IDEN_01",e3)	OB	t	EquipmentUID	h
3232	(300a,0180)[<0>](300a,01b4)[<1>](300a,01b6)	CS	f	Patient Setup Sequence:Setup Device Sequence:Setup Device Type	\N
5501	(0010,2292)	LO	f	Patient Breed Description	\N
5364	(0071,"BLACKFORD",04)[<0>](0008,0050)	SH	t	Unknown:Accession Number	d
3223	(300a,0070)[<0>](300c,0050)[<1>](300c,0051)	IS	f	Fraction Group Sequence:Referenced Dose Reference Sequence:Referenced Dose Reference Number	\N
3230	(300a,0180)[<0>](300a,01b4)[<1>](300a,01bc)	DS	f	Patient Setup Sequence:Setup Device Sequence:Setup Device Parameter	\N
4860	(0021,"GEMS_RELA_01",93)	OB	t	BiopsyRefLocation	k
3233	(300c,0080)[<0>](0008,1150)	UI	f	Referenced Dose Sequence:Referenced SOP Class UID	\N
3226	(300a,0010)[<0>](300a,0028)	DS	f	Dose Reference Sequence:Target Underdose Volume Fraction	\N
4909	(7005,"TOSHIBA_MEC_CT3",06)	SH	t	Cardiac Reconstruction Mode	k
5496	(0040,a525)	SQ	f	Identical Documents Sequence	\N
5500	(0040,a730)[<0>](0008,1199)[<1>](0008,1160)	IS	f	Content Sequence:Referenced SOP Sequence:Referenced Frame Number	\N
4858	(0045,"GEMS_HELIOS_01",0d)	OB	t	Z tracking Flag	k
4949	(0031,"AGFA CD BURNING ATTRIBUTES 1.0",01)	UN	t	Unknown	d
5498	(0040,a730)[<0>](0008,1199)[<1>](0008,1199)	SQ	f	Content Sequence:Referenced SOP Sequence:Referenced SOP Sequence	\N
4872	(0045,"GEMS_HELIOS_01",0e)	OB	t	Mean Z error	k
5506	(0040,a525)[<0>](0008,1115)[<1>](0020,000e)	UI	f	Identical Documents Sequence:Referenced Series Sequence:Series Instance UID	\N
3251	(300a,0070)[<0>](300a,007b)	LT	f	Fraction Group Sequence:Fraction Pattern	\N
3262	(3006,0039)[<0>](3006,0040)[<1>](3006,0045)	DS	f	ROI Contour Sequence:Contour Sequence:Contour Offset Vector	\N
5705	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",44)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Near Clip Plane	k
87	(0012,0062)	CS	f	Patient Identity Removed	\N
2872	(00e1,"ELSCINT1",07)	IS	t	Unknown	d
4804	(0053,"GEHC_CT_ADVAPP_001",40)	OB	t	Iterative Recon Annotation	d
4810	(0019,"GEMS_ACQU_01",47)	OB	t	ViewCompressionFactor	k
3244	(300a,00b0)[<0>](300d,"TOMO_HA_01",60)	UN	t	Beam Sequence:Unknown	d
836	(0020,0020)	CS	f	Patient Orientation	\N
5389	(0071,"BLACKFORD",04)[<0>](0008,0090)	PN	t	Unknown:Referring Physician's Name	d
4193	(0043,"dcm4che/archive",45)	SL	t	Unknown	d
4910	(0045,"GEMS_HELIOS_01",56)	OB	t	Unknown	d
2202	(0020,0105)	IS	f	Number of Temporal Positions	\N
2212	(0008,1111)[<0>](0020,0013)	IS	f	Referenced Performed Procedure Step Sequence:Instance Number	\N
2208	(0020,0100)	IS	f	Temporal Position Identifier	\N
5508	(0040,a730)[<0>](0008,1199)[<1>](0062,000b)	US	f	Content Sequence:Referenced SOP Sequence:Referenced Segment Number	\N
1430	(0018,a001)[<0>](0008,1010)	SH	f	Contributing Equipment Sequence:Station Name	\N
5507	(0040,a730)[<0>](0008,1199)[<1>](0008,1199)[<2>](0008,1150)	UI	f	Content Sequence:Referenced SOP Sequence:Referenced SOP Sequence:Referenced SOP Class UID	\N
5352	(0077,"TERARECON AQUARIUS",10)	UN	t	Original Series/Study UID	d
4057	(0019,"",0f)	SH	t	Unknown	d
3245	(300a,0010)[<0>](300d,"TOMO_HA_01",1b)	UN	t	Dose Reference Sequence:Unknown	d
3254	(300a,00b0)[<0>](300a,0111)[<1>](300a,0144)	FL	f	Beam Sequence:Control Point Sequence:Table Top Roll Angle	\N
4924	(5001,"ELSCINT1",9f)	LO	t	Unknown	d
4870	(0027,"GEMS_IMAG_01",1f)	OB	t	VmaClip	k
3835	(0019,"",b3)	UN	t	Unknown	d
4795	(0053,"GEHC_CT_ADVAPP_001",60)	OB	t	Recon Flip RotateA nno	k
1298	(0008,9121)	SQ	f	Referenced Raw Data Sequence	\N
4830	(0045,"GEMS_HELIOS_01",16)	OB	t	Number Views 2B	k
4842	(0027,"GEMS_IMAG_01",35)	OB	t	PlaneType	k
3269	(0051,"GEMS_CT_VES_01",01)[<0>](0008,0050)	SH	t	CTVESequence:Accession Number	d
91	(0032,000a)	CS	f	Study Status ID	\N
3238	(300d,"TOMO_HA_01",14)	UN	t	Unknown	d
4706	(300a,03a0)[<0>](300b,"IMPAC",11)	UN	t	Ion Tolerance Table Sequence:Unknown	d
4784	(0043,"GEMS_PARM_01",12)	OB	t	XrayChain	k
147	(0018,1048)	CS	f	Contrast/Bolus Ingredient	\N
3255	(300a,00b0)[<0>](300a,0111)[<1>](300a,0140)	FL	f	Beam Sequence:Control Point Sequence:Table Top Pitch Angle	\N
203	(0018,0060)	DS	f	KVP	\N
162	(0018,1210)	SH	f	Convolution Kernel	\N
150	(0008,2112)[<0>](0008,1155)	UI	f	Source Image Sequence:Referenced SOP Instance UID	\N
1742	(0018,9318)	FD	f	Reconstruction Target Center (Patient)	\N
1732	(0018,9346)[<0>](0008,0104)	LO	f	CTDI Phantom Type Code Sequence:Code Meaning	\N
1743	(0018,9313)	FD	f	Data Collection Center (Patient)	\N
1740	(0018,9352)	CS	f	Calcium Scoring Mass Factor Device	\N
1731	(0018,9346)[<0>](0008,0102)	SH	f	CTDI Phantom Type Code Sequence:Coding Scheme Designator	\N
1730	(0018,9346)[<0>](0008,0100)	SH	f	CTDI Phantom Type Code Sequence:Code Value	\N
151	(0008,2112)[<0>](0008,1150)	UI	f	Source Image Sequence:Referenced SOP Class UID	\N
4794	(0053,"GEHC_CT_ADVAPP_001",66)	OB	t	Image Browser Annotation	d
207	(0018,1120)	DS	f	Gantry/Detector Tilt	\N
220	(0018,1140)	CS	f	Rotation Direction	\N
4900	(0045,"GEMS_HELIOS_01",52)	CS	t	Unknown	d
180	(0008,0090)	PN	f	Referring Physician's Name	\N
4827	(0019,"GEMS_ACQU_01",25)	OB	t	MidScanFlag	k
3270	(0051,"GEMS_CT_VES_01",01)[<0>](0040,1001)	SH	t	CTVESequence:Requested Procedure ID	d
173	(0018,1150)	IS	f	Exposure Time	\N
191	(0018,1100)	DS	f	Reconstruction Diameter	\N
4931	(5001,"ELSCINT1",b4)	CS	t	Unknown	d
204	(0018,1190)	DS	f	Focal Spot(s)	\N
1462	(0020,0200)	UI	f	Synchronization Frame of Reference UID	\N
3252	(300a,00b0)[<0>](300a,0111)[<1>](300a,0142)	CS	f	Beam Sequence:Control Point Sequence:Table Top Pitch Rotation Direction	\N
334	(0018,9306)	FD	f	Single Collimation Width	\N
3264	(300c,0002)[<0>](300a,0055)	CS	f	Referenced RT Plan Sequence:RT Plan Relationship	\N
3272	(300a,00b0)[<0>](300a,00d1)	SQ	f	Beam Sequence:Wedge Sequence	\N
4912	(0053,"GEHC_CT_ADVAPP_001",68)	OB	t	Row Number Anotation Flag	d
3249	(3006,0006)	ST	f	Structure Set Description	\N
3253	(300a,00b0)[<0>](300a,0111)[<1>](300a,0146)	CS	f	Beam Sequence:Control Point Sequence:Table Top Roll Rotation Direction	\N
3263	(3006,0039)[<0>](3006,0040)[<1>](3006,0044)	DS	f	ROI Contour Sequence:Contour Sequence:Contour Slab Thickness	\N
3250	(300a,0070)[<0>](300a,007a)	IS	f	Fraction Group Sequence:Repeat Fraction Cycle Length	\N
2875	(0040,a120)	DT	f	DateTime	\N
3219	(300a,0070)[<0>](300c,0050)	SQ	f	Fraction Group Sequence:Referenced Dose Reference Sequence	\N
3273	(300a,00b0)[<0>](300a,0111)[<1>](300a,0116)	SQ	f	Beam Sequence:Control Point Sequence:Wedge Position Sequence	\N
3503	(0018,7026)	DS	f	Detector Active Dimension(s)	\N
3500	(0018,7052)	DS	f	Filter Thickness Minimum	\N
3487	(0028,3010)[<0>](0028,3002)	SS	f	VOI LUT Sequence:LUT Descriptor	\N
3499	(0018,7054)	DS	f	Filter Thickness Maximum	\N
3501	(0018,7032)	DS	f	Field of View Rotation	\N
3481	(0018,1720)	IS	f	Vertices of the Polygonal Collimator	\N
3493	(0018,7030)	DS	f	Field of View Origin	\N
3279	(300a,00b0)[<0>](300a,00d1)[<1>](300a,00d3)	CS	f	Beam Sequence:Wedge Sequence:Wedge Type	\N
102	(0020,0052)	UI	f	Frame of Reference UID	\N
548	(0018,9321)[<0>](0018,9345)	FD	f	CT Exposure Sequence:CTDIvol	\N
82	(0008,0008)	CS	f	Image Type	\N
3283	(3004,0008)	DS	f	Normalization Point	\N
5	(0012,0064)[<0>](0008,0102)	SH	f	De-identification Method Code Sequence:Coding Scheme Designator	\N
5380	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)[<2>](3006,00c8)	LO	t	Unknown:Registration Sequence:Matrix Registration Sequence:Frame of Reference Transformation Comment	d
4896	(0137,"NetRAAD",40)	UN	t	Unknown	d
4936	(5001,"ELSCINT1",a6)	US	t	Unknown	d
3843	(0019,"",b8)	UN	t	Unknown	d
3278	(300a,00b0)[<0>](300a,00d1)[<1>](300a,00d8)	DS	f	Beam Sequence:Wedge Sequence:Wedge Orientation	\N
4881	(0053,"GEHC_CT_ADVAPP_001",61)	OB	t	High Resolution Flag	k
4708	(300a,03a2)[<0>](300b,"IMPAC",0e)	UN	t	Ion Beam Sequence:Unknown	d
3280	(300a,00b0)[<0>](300a,0111)[<1>](300a,0116)[<2>](300a,0118)	CS	f	Beam Sequence:Control Point Sequence:Wedge Position Sequence:Wedge Position	\N
4749	(00e1,"ELSCINT1",40)	CS	t	Image Label	d
3277	(300a,00b0)[<0>](300a,00d1)[<1>](300a,00d6)	DS	f	Beam Sequence:Wedge Sequence:Wedge Factor	\N
4802	(0009,"GEMS_IDEN_01",01)	OB	t	FullFidelity	k
4735	(01e1,"ELSCINT1",21)	ST	t	Unknown	d
3826	(0033,"",0e)	UN	t	Unknown	d
4822	(0021,"GEMS_RELA_01",91)	OB	t	BiopsyPosition	k
5503	(0040,a525)[<0>](0008,1115)[<1>](0008,1199)[<2>](0008,1150)	UI	f	Identical Documents Sequence:Referenced Series Sequence:Referenced SOP Sequence:Referenced SOP Class UID	\N
3282	(300a,00b0)[<0>](300c,00b0)[<1>](3006,0084)	IS	f	Beam Sequence:Referenced Bolus Sequence:Referenced ROI Number	\N
4833	(0043,"GEMS_PARM_01",16)	OB	t	NumberOfOverranges	k
4903	(0045,"GEMS_HELIOS_01",50)	FD	t	Unknown	d
5538	(07a3,"ELSCINT1",14)	UN	t	Unknown	d
1748	(0032,1040)	DA	f	Study Arrival Date	\N
1746	(0008,4000)	LT	f	Identifying Comments	\N
1747	(0032,1041)	TM	f	Study Arrival Time	\N
366	(0008,1032)	SQ	f	Procedure Code Sequence	\N
329	(0028,1054)	LO	f	Rescale Type	\N
337	(0018,9307)	FD	f	Total Collimation Width	\N
386	(0018,1090)	IS	f	Cardiac Number of Images	\N
3276	(300a,00b0)[<0>](300a,0111)[<1>](300a,0116)[<2>](300c,00c0)	IS	f	Beam Sequence:Control Point Sequence:Wedge Position Sequence:Referenced Wedge Number	\N
4920	(5001,"ELSCINT1",90)	ST	t	Unknown	d
3509	(0018,7062)	LT	f	Exposure Control Mode Description	\N
3830	(0019,"",cc)	UN	t	Unknown	d
387	(0018,1088)	IS	f	Heart Rate	\N
3511	(0018,1166)	CS	f	Grid	\N
3510	(0018,7024)	CS	f	Detector Active Shape	\N
4753	(300a,00b0)[<0>](4001,"RAYSEARCHLABS 2.0",01)	UN	t	Beam Sequence:Unknown	d
336	(0018,9309)	FD	f	Table Speed	\N
691	(0009,"GEMS_PETD_01",99)	LO	t	Blnk Cal ID	d
327	(0018,1170)	IS	f	Generator Power	\N
1451	(0009,"GEIIS",68)	UN	t	Unknown	d
4815	(0043,"GEMS_PARM_01",44)	OB	t	DASOutputSource	k
4926	(5001,"ELSCINT1",a3)	LO	t	Unknown	d
3301	(300a,00b0)[<0>](300a,00d1)[<1>](300a,00d4)	SH	f	Beam Sequence:Wedge Sequence:Wedge ID	\N
3275	(300a,00b0)[<0>](300a,00d1)[<1>](300a,00d2)	IS	f	Beam Sequence:Wedge Sequence:Wedge Number	\N
4867	(0045,"GEMS_HELIOS_01",0c)	OB	t	Number of Views shifted	k
4782	(0053,"GEHC_CT_ADVAPP_001",65)	OB	t	Shutter Mode Percent	k
3281	(300a,00b0)[<0>](300c,00b0)	SQ	f	Beam Sequence:Referenced Bolus Sequence	\N
4829	(0027,"GEMS_IMAG_01",1c)	OB	t	VmaMamp	k
3274	(300a,00b0)[<0>](300a,00d1)[<1>](300a,00d5)	IS	f	Beam Sequence:Wedge Sequence:Wedge Angle	\N
5505	(0040,a525)[<0>](0020,000d)	UI	f	Identical Documents Sequence:Study Instance UID	\N
333	(0018,9311)	FD	f	Spiral Pitch Factor	\N
5497	(0040,a525)[<0>](0008,1115)	SQ	f	Identical Documents Sequence:Referenced Series Sequence	\N
4840	(0009,"GEMS_IDEN_01",27)	OB	t	ImageActualDate	d
4928	(5001,"ELSCINT1",a2)	CS	t	Unknown	d
4741	(01f7,"ELSCINT1",86)	UN	t	Unknown	d
4785	(0043,"GEMS_PARM_01",1e)	OB	t	DeltaStartTime	k
4834	(0045,"GEMS_HELIOS_01",14)	OB	t	Number of Views 1A	k
5504	(0040,a525)[<0>](0008,1115)[<1>](0008,1199)[<2>](0008,1155)	UI	f	Identical Documents Sequence:Referenced Series Sequence:Referenced SOP Sequence:Referenced SOP Instance UID	\N
5509	(3006,0080)[<0>](300a,00e1)	SH	f	RT ROI Observations Sequence:Material ID	\N
5511	(0018,1191)	CS	f	Anode Target Material	\N
4852	(0027,"GEMS_IMAG_01",46)	OB	t	NormalACoord	k
5499	(0040,a525)[<0>](0008,1115)[<1>](0008,1199)	SQ	f	Identical Documents Sequence:Referenced Series Sequence:Referenced SOP Sequence	\N
5502	(0040,a730)[<0>](0008,1199)[<1>](0008,1199)[<2>](0008,1155)	UI	f	Content Sequence:Referenced SOP Sequence:Referenced SOP Sequence:Referenced SOP Instance UID	\N
4841	(0027,"GEMS_IMAG_01",10)	OB	t	ScoutType	k
5546	(0054,0071)	US	f	Number of Time Slots	\N
5510	(07a1,"ELSCINT1",87)	LT	t	Unknown	d
4828	(0045,"GEMS_HELIOS_01",10)	OB	t	Start View 2A	k
4818	(0021,"GEMS_RELA_01",92)	OB	t	BiopsyTLocation	k
5547	(0054,0061)	US	f	Number of R-R Intervals	\N
5539	(07a5,"ELSCINT1",54)	UN	t	Unknown	d
5535	(0009,"GEMS_PETD_01",f6)	UN	t	Unknown	d
5536	(0015,"GEMS_PETD_01",3d)	UN	t	PET Sharp IR Flag	d
5537	(07a1,"ELSCINT1",a7)	UN	t	Unknown	d
4950	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",1e)	UN	t	Unknown	d
1586	(0023,"GEMS_STDY_01",7d)	SS	t	IndicatesIfStudyHasCompleteInfo	k
161	(0021,"GEMS_RELA_01",05)	SH	t	GenesisVersionNow	k
2850	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",18)	OB	t	Unknown:Unknown	d
4845	(0045,"GEMS_HELIOS_01",22)	OB	t	PeristalticFlag	k
2964	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
4885	(0045,"GEMS_HELIOS_01",01)	OB	t	Number of Macro Rows in Detector	k
5766	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",37)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Graphic Is Visible Flag	k
5706	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",48)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Projection Type	k
5824	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",56)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Renderer DirectionalLight TwoSide Usage Flag	k
5600	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence	k
4748	(300a,03a2)[<0>](300a,03a8)[<1>](300b,"IMPAC",17)	UN	t	Ion Beam Sequence:Ion Control Point Sequence:Unknown	d
4129	(0019,"",27)	UN	t	Unknown	d
4787	(0053,"GEHC_CT_ADVAPP_001",42)	OB	t	Iterative Recon Configuration	k
4044	(0051,"",0c)	LO	t	Unknown	d
4040	(0051,"",0b)	LO	t	Unknown	d
3143	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",92)	OB	t	Unknown:Unknown	d
455	(0018,1250)	SH	f	Receive Coil Name	\N
544	(0010,2110)	LO	f	Allergies	\N
4740	(01e1,"ELSCINT1",19)	UN	t	Unknown	d
4811	(0045,"GEMS_HELIOS_01",17)	OB	t	Start View 1B	d
4023	(0043,"",2c)	UN	t	Unknown	d
4703	(300b,"IMPAC",08)	UN	t	Unknown	d
4853	(0045,"GEMS_HELIOS_01",09)	OB	t	Sigma Row number	k
2588	(0040,1003)	SH	f	Requested Procedure Priority	\N
2586	(0018,5101)	CS	f	View Position	\N
2304	(0008,1111)[<0>](0008,0014)	UI	f	Referenced Performed Procedure Step Sequence:Instance Creator UID	\N
2124	(300a,000a)	CS	f	Plan Intent	\N
2110	(0038,0016)	LO	f	Route of Admissions	\N
2123	(300a,00b0)[<0>](300a,0111)[<1>](300a,012e)	DS	f	Beam Sequence:Control Point Sequence:Surface Entry Point	\N
2122	(300a,000b)	LO	f	Treatment Sites	\N
4886	(0019,"GEMS_ACQU_01",04)	OB	t	CellSpacing	k
2955	(0009,"FDMS 1.0",92)	OB	t	KanjiDepartmentName	d
4934	(5001,"ELSCINT1",c5)	CS	t	Unknown	d
4821	(0045,"GEMS_HELIOS_01",11)	OB	t	Number of Views 2A	k
4183	(0043,"dcm4che/archive",21)	SS	t	Unknown	d
4025	(0019,"SIEMENS MR HEADER",0a)	US	t	Number of Images in Mosaic	d
1775	(0018,1074)	DS	f	Radionuclide Total Dose	\N
4925	(5001,"ELSCINT1",a7)	LO	t	Unknown	d
777	(0009,"GEMS_PETD_01",06)	SL	t	Patient Type	d
546	(0010,4000)	LT	f	Patient Comments	\N
532	(0018,0082)	DS	f	Inversion Time	\N
542	(0010,2000)	LO	f	Medical Alerts	\N
550	(0018,9321)[<0>](0018,9330)	FD	f	CT Exposure Sequence:X-Ray Tube Current in mA	\N
549	(0018,9345)	FD	f	CTDIvol	\N
539	(0008,3010)	UI	f	Irradiation Event UID	\N
538	(0008,1032)[<0>](0008,0104)	LO	f	Procedure Code Sequence:Code Meaning	\N
2113	(01e1,"ELSCINT1",41)	OW	t	Unknown	d
4941	(00e1,"ELSCINT1",84)	OB	t	Unknown	d
3241	(300a,0010)[<0>](300d,"TOMO_HA_01",17)	UN	t	Dose Reference Sequence:Unknown	d
4875	(0021,"GEMS_RELA_01",35)	OB	t	SeriesFromWhichPrescribed	d
553	(0018,9321)[<0>](0018,9332)	FD	f	CT Exposure Sequence:Exposure in mAs	\N
2378	(2001,"Philips Imaging DD 001",8a)	DS	t	Sampling Percent	k
4916	(0045,"GEMS_HELIOS_01",53)	OB	t	Unknown	d
4820	(0043,"GEMS_PARM_01",2b)	OB	t	PrivateScanOptions	d
4839	(0045,"GEMS_HELIOS_01",21)	OB	t	Iterbone Flag	k
4948	(0031,"KONICA1.0",ff)	UN	t	Private Data Sequence	d
4813	(0019,"GEMS_ACQU_01",52)	OB	t	ReconPostProcessingFlag	k
4836	(0019,"GEMS_ACQU_01",2c)	OB	t	NumberOfTriggers	k
4850	(0027,"GEMS_IMAG_01",45)	OB	t	NormalRCoord	k
4861	(0043,"GEMS_PARM_01",41)	OB	t	DegreeOfRotation	k
3513	(0018,7034)	CS	f	Field of View Horizontal Flip	\N
4902	(0045,"GEMS_HELIOS_01",54)	FD	t	Unknown	d
3518	(0018,7050)	CS	f	Filter Material	\N
3514	(0018,7000)	CS	f	Detector Conditions Nominal Flag	\N
4798	(0043,"GEMS_PARM_01",64)	OB	t	Image Filter	k
4814	(0021,"GEMS_RELA_01",03)	OB	t	SeriesFromWhichPrescribed	d
4816	(0027,"GEMS_IMAG_01",1e)	OB	t	VmaMod	k
4831	(0045,"GEMS_HELIOS_01",15)	OB	t	Start View 2B	k
4927	(5001,"ELSCINT1",9c)	LO	t	Unknown	d
4705	(300a,03a0)[<0>](300b,"IMPAC",01)	UN	t	Ion Tolerance Table Sequence:Unknown	d
3515	(0011,"GEMS_GDXE_FALCON_04",04)	CS	t	Acquisition Type	d
5530	(0009,"GEMS_PETD_01",f4)	UN	t	Unknown	d
5527	(0009,"GEMS_PETD_01",f5)	UN	t	Unknown	d
5524	(0095,"SIENET",fa)	UN	t	Unknown	d
5523	(0095,"SIENET",04)	UL	t	FolderReportedStatus	d
5532	(0009,"GEMS_PETD_01",f9)	UN	t	Unknown	d
5526	(0009,"GEMS_PETD_01",f2)	UN	t	PET tracerInjection_UID	d
5525	(0095,"SIENET",0c)	SL	t	Unknown	d
5598	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",cf)	SQ	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Image Sequence	k
4876	(0045,"GEMS_HELIOS_01",12)	OB	t	Start View 1A	k
4937	(5001,"ELSCINT1",a8)	US	t	Unknown	d
4915	(0045,"GEMS_HELIOS_01",50)	OB	t	Unknown	d
5543	(f215,"PB group A",18)	UN	t	Unknown	d
5541	(07a3,"ELSCINT1",17)	UN	t	Unknown	d
1120	(0009,"GEMS_PETD_01",7a)	SH	t	Image Set Software Version	k
2986	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",74)	OB	t	Unknown:Unknown	d
3154	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",90)	OB	t	Unknown:Unknown	d
4864	(0045,"GEMS_HELIOS_01",0b)	OB	t	Maximum Offset Value	k
3204	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
4869	(0043,"GEMS_PARM_01",26)	OB	t	NoViewsRefChannelsBlocked	k
4736	(01f1,"ELSCINT1",39)	LO	t	Unknown	d
4724	(300a,03a2)[<0>](4001,"RAYSEARCHLABS 2.0",01)	UN	t	Ion Beam Sequence:Unknown	d
2342	(0008,0100)	SH	f	Code Value	\N
2355	(0008,0104)	LO	f	Code Meaning	\N
2591	(0018,4000)	LT	f	Acquisition Comments	\N
2352	(0008,0102)	SH	f	Coding Scheme Designator	\N
4817	(0019,"GEMS_ACQU_01",43)	OB	t	TotalSegmentsRequested	k
4742	(01e1,"ELSCINT1",1b)	UN	t	Unknown	d
4797	(0045,"GEMS_HELIOS_01",3b)	OB	t	NoiseReductionImageFilterDesc	k
4709	(300a,03a2)[<0>](300b,"IMPAC",04)	UN	t	Ion Beam Sequence:Unknown	d
4884	(0053,"GEHC_CT_ADVAPP_001",67)	OB	t	Overlapped Recon Flag	k
4745	(300a,03a2)[<0>](300b,"IMPAC",02)	FL	t	Ion Beam Sequence:Unknown	d
590	(0018,1242)	IS	f	Actual Frame Duration	\N
577	(0054,0016)	SQ	f	Radiopharmaceutical Information Sequence	\N
582	(0018,0074)	IS	f	Acquisition Start Condition Data	\N
566	(300c,0002)[<0>](0008,1150)	UI	f	Referenced RT Plan Sequence:Referenced SOP Class UID	\N
676	(0054,0414)[<0>](0008,0104)	LO	f	Patient Gantry Relationship Code Sequence:Code Meaning	\N
565	(300c,0002)[<0>](0008,1155)	UI	f	Referenced RT Plan Sequence:Referenced SOP Instance UID	\N
664	(0054,1103)	LO	f	Reconstruction Method	\N
654	(0054,0412)[<0>](0008,0100)	SH	f	Patient Orientation Modifier Code Sequence:Code Value	\N
586	(0054,1310)	IS	f	Primary (Prompts) Counts Accumulated	\N
575	(0054,0414)	SQ	f	Patient Gantry Relationship Code Sequence	\N
555	(0008,0014)	UI	f	Instance Creator UID	\N
589	(0054,1202)	IS	f	Transverse Mash	\N
552	(0018,9321)[<0>](0018,9324)	FD	f	CT Exposure Sequence:Estimated Dose Saving	\N
659	(0054,0412)[<0>](0008,0102)	SH	f	Patient Orientation Modifier Code Sequence:Coding Scheme Designator	\N
561	(3004,0002)	CS	f	Dose Units	\N
581	(0018,1149)	IS	f	Field of View Dimension(s)	\N
556	(300c,0002)	SQ	f	Referenced RT Plan Sequence	\N
650	(0054,0016)[<0>](0018,1079)	DT	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Stop DateTime	\N
587	(0018,0075)	IS	f	Acquisition Termination Condition Data	\N
652	(0054,0016)[<0>](0054,0304)[<1>](0008,0100)	SH	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Code Sequence:Code Value	\N
682	(0054,0412)[<0>](0008,0104)	LO	f	Patient Orientation Modifier Code Sequence:Code Meaning	\N
663	(0054,0410)[<0>](0008,0100)	SH	f	Patient Orientation Code Sequence:Code Value	\N
554	(0010,21c0)	US	f	Pregnancy Status	\N
678	(0054,0016)[<0>](0054,0304)[<1>](0008,0104)	LO	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Code Sequence:Code Meaning	\N
715	(0054,0016)[<0>](0018,1076)	DS	f	Radiopharmaceutical Information Sequence:Radionuclide Positron Fraction	\N
5544	(01f3,"ELSCINT1",11)		t	Unknown	d
4786	(0027,"GEMS_IMAG_01",44)	OB	t	CenterSCoordOfPlaneImage	k
5542	(f215,"PB group A",17)	UN	t	Unknown	d
1448	(0009,"GEMS_IDEN_01",e4)	UN	t	Unknown	d
706	(0054,0016)[<0>](0018,1071)	DS	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Volume	\N
4206	(5653,"",14)[<0>](5653,"",11)	OB	t	Unknown:Unknown	d
4838	(0045,"GEMS_HELIOS_01",32)	OB	t	TemporalResolution	k
123	(0008,0020)	DA	f	Study Date	\N
4783	(0019,"GEMS_ACQU_01",24)	OB	t	MidScanTime	k
819	(0020,0060)	CS	f	Laterality	\N
4801	(0043,"GEMS_PARM_01",31)	OB	t	RACoordOfTargetReconCentre	k
4704	(300a,03a2)[<0>](300a,0420)[<1>](3291,"Varian Medical Systems VISION 3291",00)	UN	t	Ion Beam Sequence:General Accessory Sequence:Unknown	d
4788	(0019,"GEMS_ACQU_01",03)	OB	t	CellNumberAtTheta	k
4862	(0043,"GEMS_PARM_01",40)	OB	t	TriggerOnPosition	k
5533	(0009,"GEMS_PETD_01",f3)	UN	t	Unknown	d
4744	(300a,03a2)[<0>](300b,"IMPAC",0e)	FL	t	Ion Beam Sequence:Unknown	d
4808	(0043,"GEMS_PARM_01",45)	OB	t	DASAdInput	k
4890	(0137,"NetRAAD",0e)	UN	t	Unknown	d
5534	(0009,"GEMS_PETD_01",f1)	UN	t	PET prompt gamma	d
5540	(07a5,"ELSCINT1",98)	UN	t	Unknown	d
4914	(0045,"GEMS_HELIOS_01",54)	OB	t	Unknown	d
4844	(0045,"GEMS_HELIOS_01",0a)	OB	t	Minimum DAS value	k
4887	(0019,"GEMS_ACQU_01",27)	OB	t	GantryPeriod	k
5545	(01f3,"ELSCINT1",01)		t	Unknown	d
5582	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0070,0404)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Referenced Spatial Registration Sequence	k
4901	(0045,"GEMS_HELIOS_01",55)	CS	t	Unknown	d
5826	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",66)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Segmentation Display Color	k
684	(0009,"GEMS_PETD_01",0e)	LO	t	Scan Ready	o
3567	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",01)	CS	t	Presentation State Sequence:Unknown	d
3562	(200b,"Philips RAD Imaging DD 097",89)	LT	t	Unknown	d
3569	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",75)	CS	t	Presentation State Sequence:Unknown	d
3568	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)[<2>](0070,0004)	CS	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence:Anchor Point Annotation Units	d
3564	(200b,"Philips RAD Imaging DD 097",a0)	LT	t	Unknown	d
3561	(200b,"Philips RAD Imaging DD 097",60)	LT	t	Unknown	d
5391	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0071,"BLACKFORD",02)[<2>](0020,0032)	DS	t	Unknown:Unknown:Unknown:Image Position (Patient)	d
4194	(0043,"dcm4che/archive",44)	SL	t	Unknown	d
3703	(0021,"Siemens: Thorax/Multix FD Post Processing",03)	FL	t	Unknown	d
5174	(2001,"Philips Imaging DD 001",11)	OB	t	DiffusionEchoTime	k
697	(0009,"GEMS_PETD_01",0d)	LO	t	Scan Date Time	o
660	(0009,"GEMS_PETD_01",15)	SH	t	Landmark Abbrev	k
767	(0009,"GEMS_PETD_01",19)	SL	t	Scan Mode	k
751	(0009,"GEMS_PETD_01",27)	SL	t	Theta Compression	k
1122	(0009,"GEMS_PETD_01",0c)	SH	t	Scan Software Version	k
3918	(0009,"",e7)	UN	t	Unknown	d
1819	(0028,1056)	CS	f	VOI LUT Function	\N
1809	(0018,9302)	CS	f	Acquisition Type	\N
717	(0054,1322)	DS	f	Dose Calibration Factor	\N
1825	(0040,030e)[<0>](0020,0011)	IS	f	Exposure Dose Sequence:Series Number	\N
1824	(0040,030e)[<0>](0018,1302)	IS	f	Exposure Dose Sequence:Scan Length	\N
1808	(0018,1141)	DS	f	Angular Position	\N
807	(0040,0012)	LO	f	Pre-Medication	\N
805	(0008,2111)	ST	f	Derivation Description	\N
708	(0018,1063)	DS	f	Frame Time	\N
718	(0054,1002)	CS	f	Counts Source	\N
726	(0018,1147)	CS	f	Field of View Shape	\N
724	(0018,0073)	CS	f	Acquisition Start Condition	\N
713	(0054,0016)[<0>](0018,1074)	DS	f	Radiopharmaceutical Information Sequence:Radionuclide Total Dose	\N
704	(0054,1321)	DS	f	Decay Factor	\N
806	(0008,002a)	DT	f	Acquisition DateTime	\N
703	(0054,1324)	DS	f	Dead Time Factor	\N
719	(0028,0051)	CS	f	Corrected Image	\N
714	(0054,0016)[<0>](0018,1075)	DS	f	Radiopharmaceutical Information Sequence:Radionuclide Half Life	\N
4835	(0043,"GEMS_PARM_01",10)	OB	t	WindowValue	k
4943	(01f1,"ELSCINT1",31)	CS	t	Unknown	d
4944	(0040,030e)[<0>](00e1,"ELSCINT1",37)	DS	t	Exposure Dose Sequence:Total Dose Savings	k
4823	(0027,"GEMS_IMAG_01",43)	OB	t	CenterACoordOfPlaneImage	k
4922	(5001,"ELSCINT1",9d)	FL	t	Unknown	d
4935	(5001,"ELSCINT1",a4)	US	t	Unknown	d
1856	(0040,030e)[<0>](0018,115a)	CS	f	Exposure Dose Sequence:Radiation Mode	\N
2454	(0040,0260)[<0>](0008,010b)	CS	f	Performed Protocol Code Sequence:Context Group Extension Flag	\N
2447	(0008,1032)[<0>](0008,010b)	CS	f	Procedure Code Sequence:Context Group Extension Flag	\N
4908	(01f1,"ELSCINT1",40)	CS	t	Unknown	d
3566	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)[<2>](0070,0015)	CS	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence:Anchor Point Visibility	d
3563	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",a0)	LT	t	Presentation State Sequence:Unknown	d
3565	(200b,"Philips RAD Imaging DD 097",88)	CS	t	Unknown	d
4918	(0053,"GEHC_CT_ADVAPP_001",6b)	OB	t	Unknown	d
5531	(0015,"GEMS_PETD_01",3e)	UN	t	PET Scatter Limit	d
1063	(300a,00b0)[<0>](300a,00f4)[<1>](300a,0106)	DS	f	Beam Sequence:Block Sequence:Block Data	\N
1060	(300a,0004)	ST	f	RT Plan Description	\N
5528	(0009,"GEMS_PETD_01",f7)	UN	t	Unknown	d
5529	(0009,"GEMS_PETD_01",f8)	UN	t	Unknown	d
4812	(0021,"GEMS_RELA_01",36)	OB	t	ImageFromWhichPrescribed	d
4932	(5001,"ELSCINT1",a5)	CS	t	Unknown	d
4792	(0009,"GEMS_IDEN_01",04)	OB	t	ProductId	d
3210	(2010,0140)	CS	f	Trim	\N
4874	(0019,"GEMS_ACQU_01",42)	OB	t	SegmentNumber	k
4951	(0031,"AGFA CD BURNING ATTRIBUTES 1.0",00)	UN	t	Unknown	d
3571	(200b,"Philips RAD Imaging DD 001",52)	CS	t	Unknown	d
3570	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0002)	CS	t	Presentation State Sequence:Graphic Annotation Sequence:Graphic Layer	d
3315	(0040,a730)[<0>](0040,a168)[<1>](0008,0102)	SH	f	Content Sequence:Concept Code Sequence:Coding Scheme Designator	\N
3319	(0040,a043)[<0>](0008,0102)	SH	f	Concept Name Code Sequence:Coding Scheme Designator	\N
3320	(0040,a730)[<0>](0040,a043)[<1>](0008,0102)	SH	f	Content Sequence:Concept Name Code Sequence:Coding Scheme Designator	\N
3316	(0040,a043)[<0>](0008,0100)	SH	f	Concept Name Code Sequence:Code Value	\N
3314	(0040,a730)[<0>](0040,a168)[<1>](0008,0100)	SH	f	Content Sequence:Concept Code Sequence:Code Value	\N
3318	(0040,a730)[<0>](0040,a043)[<1>](0008,0100)	SH	f	Content Sequence:Concept Name Code Sequence:Code Value	\N
937	(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)[<3>](0008,1150)	UI	f	Referenced Frame of Reference Sequence:RT Referenced Study Sequence:RT Referenced Series Sequence:Contour Image Sequence:Referenced SOP Class UID	\N
769	(0009,"GEMS_PETD_01",7e)	SL	t	Image Set Type	k
1858	(0040,030e)[<0>](0018,9324)	FD	f	Exposure Dose Sequence:Estimated Dose Saving	\N
926	(3006,0020)[<0>](3006,0036)	CS	f	Structure Set ROI Sequence:ROI Generation Algorithm	\N
946	(300c,0060)	SQ	f	Referenced Structure Set Sequence	\N
876	(0010,2180)	SH	f	Occupation	\N
875	(0010,2160)	SH	f	Ethnic Group	\N
924	(3006,0039)[<0>](3006,0040)[<1>](3006,0042)	CS	f	ROI Contour Sequence:Contour Sequence:Contour Geometric Type	\N
1867	(0018,9352)	FL	f	Calcium Scoring Mass Factor Device	\N
922	(3006,0080)[<0>](3006,00b0)[<1>](3006,00b4)	DS	f	RT ROI Observations Sequence:ROI Physical Properties Sequence:ROI Physical Property Value	\N
1843	(0040,030e)[<0>](0008,002a)	DT	f	Exposure Dose Sequence:Acquisition DateTime	\N
1872	(0008,0041)	LO	f	Data Set Subtype	\N
1848	(0040,030e)[<0>](0018,1160)	SH	f	Exposure Dose Sequence:Filter Type	\N
905	(3006,0020)	SQ	f	Structure Set ROI Sequence	\N
929	(3006,0009)	TM	f	Structure Set Time	\N
950	(300a,00b0)[<0>](300a,0111)[<1>](300a,011a)	SQ	f	Beam Sequence:Control Point Sequence:Beam Limiting Device Position Sequence	\N
917	(3006,0080)[<0>](3006,0084)	IS	f	RT ROI Observations Sequence:Referenced ROI Number	\N
919	(3006,0039)[<0>](3006,002a)	IS	f	ROI Contour Sequence:ROI Display Color	\N
1851	(0040,030e)[<0>](0008,103e)	LO	f	Exposure Dose Sequence:Series Description	\N
1852	(0040,030e)[<0>](0020,1041)	DS	f	Exposure Dose Sequence:Slice Location	\N
1874	(0008,0040)	US	f	Data Set Type	\N
1857	(0040,030e)[<0>](0018,7050)	CS	f	Exposure Dose Sequence:Filter Material	\N
891	(0032,1064)[<0>](0008,0100)	SH	f	Requested Procedure Code Sequence:Code Value	\N
930	(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)[<3>](0008,1155)	UI	f	Referenced Frame of Reference Sequence:RT Referenced Study Sequence:RT Referenced Series Sequence:Contour Image Sequence:Referenced SOP Instance UID	\N
923	(3006,0020)[<0>](3006,002c)	DS	f	Structure Set ROI Sequence:ROI Volume	\N
935	(3006,0010)[<0>](3006,0012)[<1>](0008,1150)	UI	f	Referenced Frame of Reference Sequence:RT Referenced Study Sequence:Referenced SOP Class UID	\N
906	(3006,0010)[<0>](3006,0012)[<1>](3006,0014)	SQ	f	Referenced Frame of Reference Sequence:RT Referenced Study Sequence:RT Referenced Series Sequence	\N
925	(300e,0002)	CS	f	Approval Status	\N
902	(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)	SQ	f	Referenced Frame of Reference Sequence:RT Referenced Study Sequence:RT Referenced Series Sequence:Contour Image Sequence	\N
899	(0018,1201)	TM	f	Time of Last Calibration	\N
916	(3006,0020)[<0>](3006,0022)	IS	f	Structure Set ROI Sequence:ROI Number	\N
913	(3006,0004)	LO	f	Structure Set Name	\N
907	(3006,0010)	SQ	f	Referenced Frame of Reference Sequence	\N
989	(300a,00b0)[<0>](300a,0111)[<1>](300a,0129)	DS	f	Beam Sequence:Control Point Sequence:Table Top Longitudinal Position	\N
964	(300a,00b0)[<0>](300c,006a)	IS	f	Beam Sequence:Referenced Patient Setup Number	\N
1058	(300a,00b0)[<0>](300a,00f4)	SQ	f	Beam Sequence:Block Sequence	\N
1009	(300a,0006)	DA	f	RT Plan Date	\N
991	(300a,00b0)[<0>](300a,0111)[<1>](300a,012a)	DS	f	Beam Sequence:Control Point Sequence:Table Top Lateral Position	\N
1061	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00fc)	IS	f	Beam Sequence:Block Sequence:Block Number	\N
2592	(0018,1600)	CS	f	Shutter Shape	\N
4933	(5001,"ELSCINT1",a0)	CS	t	Unknown	d
3212	(2010,0040)	CS	f	Film Orientation	\N
1464	(3006,0024)	UI	f	Referenced Frame of Reference UID	\N
551	(0018,9321)[<0>](0018,9328)	FD	f	CT Exposure Sequence:Exposure Time in ms	\N
725	(0018,0071)	CS	f	Acquisition Termination Condition	\N
1411	(0088,0200)[<0>](0028,1202)	OW	f	Icon Image Sequence:Green Palette Color Lookup Table Data	\N
1311	(0008,1250)[<0>](0020,000e)	UI	f	Related Series Sequence:Series Instance UID	\N
1889	(0040,9096)	SQ	f	Real World Value Mapping Sequence	\N
1893	(0040,9096)[<0>](0040,08ea)[<1>](0008,0102)	SH	f	Real World Value Mapping Sequence:Measurement Units Code Sequence:Coding Scheme Designator	\N
1209	(6000,0050)	SS	f	Overlay Origin	\N
1890	(0070,0403)	FL	f	Relative Opacity	\N
1891	(0040,9096)[<0>](0040,9211)	SS	f	Real World Value Mapping Sequence:Real World Value Last Value Mapped	\N
1887	(0008,1140)[<0>](0040,a170)	SQ	f	Referenced Image Sequence:Purpose of Reference Code Sequence	\N
1892	(0040,9096)[<0>](0040,9216)	SS	f	Real World Value Mapping Sequence:Real World Value First Value Mapped	\N
1002	(300a,00b0)[<0>](300a,0111)[<1>](300a,0126)	CS	f	Beam Sequence:Control Point Sequence:Table Top Eccentric Rotation Direction	\N
958	(300a,00b0)[<0>](300a,00c0)	IS	f	Beam Sequence:Beam Number	\N
965	(300a,0070)[<0>](300a,0071)	IS	f	Fraction Group Sequence:Fraction Group Number	\N
1004	(300a,00b0)[<0>](300a,0111)[<1>](300a,0121)	CS	f	Beam Sequence:Control Point Sequence:Beam Limiting Device Rotation Direction	\N
960	(300a,0070)[<0>](300c,0004)[<1>](300c,0006)	IS	f	Fraction Group Sequence:Referenced Beam Sequence:Referenced Beam Number	\N
999	(300a,0180)[<0>](0018,5100)	CS	f	Patient Setup Sequence:Patient Position	\N
969	(300a,00b0)[<0>](300a,00ed)	IS	f	Beam Sequence:Number of Boli	\N
961	(300a,0040)[<0>](300a,0042)	IS	f	Tolerance Table Sequence:Tolerance Table Number	\N
971	(300a,0070)[<0>](300a,00a0)	IS	f	Fraction Group Sequence:Number of Brachy Application Setups	\N
979	(300a,00b0)[<0>](300a,0111)[<1>](300a,011e)	DS	f	Beam Sequence:Control Point Sequence:Gantry Angle	\N
1005	(300a,00b0)[<0>](300a,00b3)	CS	f	Beam Sequence:Primary Dosimeter Unit	\N
974	(300a,00b0)[<0>](300a,0111)[<1>](300a,011a)[<2>](300a,011c)	DS	f	Beam Sequence:Control Point Sequence:Beam Limiting Device Position Sequence:Leaf/Jaw Positions	\N
970	(300a,00b0)[<0>](300a,00d0)	IS	f	Beam Sequence:Number of Wedges	\N
3213	(0018,1508)	CS	f	Positioner Type	\N
4892	(0137,"NetRAAD",0d)	UN	t	Unknown	d
4170	(0029,"SIEMENS CSA REPORT",15)	US	t	SR Variant	d
1003	(300a,00b0)[<0>](300a,0111)[<1>](300a,011f)	CS	f	Beam Sequence:Control Point Sequence:Gantry Rotation Direction	\N
957	(300a,00b0)[<0>](300a,0111)[<1>](300a,0112)	IS	f	Beam Sequence:Control Point Sequence:Control Point Index	\N
968	(300a,00b0)[<0>](300a,00f0)	IS	f	Beam Sequence:Number of Blocks	\N
997	(300a,00b0)[<0>](300a,00ce)	CS	f	Beam Sequence:Treatment Delivery Type	\N
962	(300a,00b0)[<0>](300a,0110)	IS	f	Beam Sequence:Number of Control Points	\N
1055	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00e1)	SH	f	Beam Sequence:Block Sequence:Material ID	\N
1006	(300a,0007)	TM	f	RT Plan Time	\N
1057	(300a,00b0)[<0>](300a,0107)[<1>](300a,0108)	SH	f	Beam Sequence:Applicator Sequence:Applicator ID	\N
951	(300a,0040)	SQ	f	Tolerance Table Sequence	\N
985	(300a,00b0)[<0>](300a,0111)[<1>](300a,012c)	DS	f	Beam Sequence:Control Point Sequence:Isocenter Position	\N
990	(300a,00b0)[<0>](300a,0111)[<1>](300a,0128)	DS	f	Beam Sequence:Control Point Sequence:Table Top Vertical Position	\N
966	(300a,00b0)[<0>](300a,00b6)[<1>](300a,00bc)	IS	f	Beam Sequence:Beam Limiting Device Sequence:Number of Leaf/Jaw Pairs	\N
981	(300a,0070)[<0>](300c,0004)[<1>](300a,0084)	DS	f	Fraction Group Sequence:Referenced Beam Sequence:Beam Dose	\N
1881	(0010,21d0)	DA	f	Last Menstrual Date	\N
1888	(0040,9096)[<0>](0040,08ea)	SQ	f	Real World Value Mapping Sequence:Measurement Units Code Sequence	\N
1079	(0032,1050)	DA	f	Study Completion Date	\N
1417	(0088,0200)[<0>](0028,0100)	US	f	Icon Image Sequence:Bits Allocated	\N
1149	(0010,21a0)	CS	f	Smoking Status	\N
723	(0054,1100)	CS	f	Randoms Correction Method	\N
559	(3004,000c)	DS	f	Grid Frame Offset Vector	\N
1166	(5000,0022)	UN	f	Curve Description	\N
1183	(5008,0005)	UN	f	Curve Dimensions	\N
1001	(300a,00b0)[<0>](300a,0111)[<1>](300a,0123)	CS	f	Beam Sequence:Control Point Sequence:Patient Support Rotation Direction	\N
665	(0054,1105)	LO	f	Scatter Correction Method	\N
1899	(0040,9096)[<0>](0028,3003)	LO	f	Real World Value Mapping Sequence:LUT Explanation	\N
1894	(0008,1140)[<0>](0040,a170)[<1>](0008,0100)	SH	f	Referenced Image Sequence:Purpose of Reference Code Sequence:Code Value	\N
1896	(0040,9096)[<0>](0040,08ea)[<1>](0008,0100)	SH	f	Real World Value Mapping Sequence:Measurement Units Code Sequence:Code Value	\N
1443	(0018,a001)[<0>](0008,1090)	LO	f	Contributing Equipment Sequence:Manufacturer's Model Name	\N
1172	(0008,0061)	CS	f	Modalities in Study	\N
56	(7fe0,0010)	OW	f	Pixel Data	\N
1059	(300a,00b0)[<0>](300a,0107)	SQ	f	Beam Sequence:Applicator Sequence	\N
1103	(0020,9056)	SH	f	Stack ID	\N
1167	(0028,0034)	IS	f	Pixel Aspect Ratio	\N
1109	(0040,0260)[<0>](0008,0102)	SH	f	Performed Protocol Code Sequence:Coding Scheme Designator	\N
1897	(0008,1140)[<0>](0040,a170)[<1>](0008,0102)	SH	f	Referenced Image Sequence:Purpose of Reference Code Sequence:Coding Scheme Designator	\N
1077	(0032,1001)	TM	f	Scheduled Study Start Time	\N
1110	(0040,0260)[<0>](0008,0100)	SH	f	Performed Protocol Code Sequence:Code Value	\N
1101	(0020,9057)	UL	f	In-Stack Position Number	\N
1066	(300a,00b0)[<0>](300a,00f4)[<1>](300a,0100)	DS	f	Beam Sequence:Block Sequence:Block Thickness	\N
1895	(0040,9096)[<0>](0040,08ea)[<1>](0008,0103)	SH	f	Real World Value Mapping Sequence:Measurement Units Code Sequence:Coding Scheme Version	\N
1111	(0040,0260)	SQ	f	Performed Protocol Code Sequence	\N
1898	(0040,9096)[<0>](0040,9210)	SH	f	Real World Value Mapping Sequence:LUT Label	\N
1900	(0040,9096)[<0>](0040,08ea)[<1>](0008,0104)	LO	f	Real World Value Mapping Sequence:Measurement Units Code Sequence:Code Meaning	\N
1068	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00fa)	CS	f	Beam Sequence:Block Sequence:Block Divergence	\N
4781	(0019,"GEMS_ACQU_01",18)	OB	t	FirstScanRAS	k
1241	(0040,0555)[<0>](0040,a168)[<1>](0008,0100)	SH	f	Acquisition Context Sequence:Concept Code Sequence:Code Value	\N
1236	(0040,0555)[<0>](0040,a043)	SQ	f	Acquisition Context Sequence:Concept Name Code Sequence	\N
986	(300a,00b0)[<0>](300a,0111)[<1>](300a,0122)	DS	f	Beam Sequence:Control Point Sequence:Patient Support Angle	\N
928	(3006,0080)[<0>](3006,00b0)[<1>](3006,00b2)	CS	f	RT ROI Observations Sequence:ROI Physical Properties Sequence:ROI Physical Property	\N
1231	(6000,0100)	US	f	Overlay Bits Allocated	\N
1201	(500a,0022)	UN	f	Curve Description	\N
1227	(6000,0040)	CS	f	Overlay Type	\N
1202	(5008,0022)	UN	f	Curve Description	\N
1239	(0028,0109)	SS	f	Largest Pixel Value in Series	\N
1323	(0054,0016)[<0>](0054,0302)[<1>](0008,0102)	SH	f	Radiopharmaceutical Information Sequence:Administration Route Code Sequence:Coding Scheme Designator	\N
1197	(5002,0020)	UN	f	Type of Data	\N
533	(0008,1032)[<0>](0008,0100)	SH	f	Procedure Code Sequence:Code Value	\N
1249	(0018,1071)	DS	f	Radiopharmaceutical Volume	\N
588	(0054,1201)	IS	f	Axial Mash	\N
973	(300a,0070)[<0>](300a,0080)	IS	f	Fraction Group Sequence:Number of Beams	\N
911	(3006,0039)[<0>](3006,0040)[<1>](3006,0016)	SQ	f	ROI Contour Sequence:Contour Sequence:Contour Image Sequence	\N
727	(0054,0202)	CS	f	Type of Detector Motion	\N
711	(0054,0013)[<0>](0054,0015)	DS	f	Energy Window Range Sequence:Energy Window Upper Limit	\N
893	(0008,1032)[<0>](0008,0102)	SH	f	Procedure Code Sequence:Coding Scheme Designator	\N
903	(3006,0010)[<0>](3006,0012)	SQ	f	Referenced Frame of Reference Sequence:RT Referenced Study Sequence	\N
2549	(0018,9089)	FD	f	Diffusion Gradient Orientation	\N
1064	(300a,00b0)[<0>](300a,00f4)[<1>](300a,0102)	DS	f	Beam Sequence:Block Sequence:Block Transmission	\N
661	(0054,0414)[<0>](0008,0100)	SH	f	Patient Gantry Relationship Code Sequence:Code Value	\N
2555	(0018,9073)	FD	f	Acquisition Duration	\N
2548	(0018,9087)	FD	f	Diffusion b-value	\N
2559	(0040,0251)	TM	f	Performed Procedure Step End Time	\N
2556	(0008,1111)[<0>](0008,0013)	TM	f	Referenced Performed Procedure Step Sequence:Instance Creation Time	\N
4855	(0043,"GEMS_PARM_01",42)	OB	t	DASTriggerSource	k
3590	(0019,"SIEMENS CT VA0  COAD",b1)	UN	t	Unknown	d
4945	(0040,030e)[<0>](01e1,"ELSCINT1",26)	CS	t	Exposure Dose Sequence:Phantom Type	k
938	(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1150)	UI	f	ROI Contour Sequence:Contour Sequence:Contour Image Sequence:Referenced SOP Class UID	\N
96	(0008,0013)	TM	f	Instance Creation Time	\N
16	(0032,1030)	LO	f	Reason for Study	\N
1923	(0018,1022)	SH	f	Video Image Format Acquired	\N
332	(0018,9305)	FD	f	Revolution Time	\N
1215	(0012,0050)	LO	f	Clinical Trial Time Point ID	\N
1242	(0040,0555)[<0>](0040,a043)[<1>](0008,0102)	SH	f	Acquisition Context Sequence:Concept Name Code Sequence:Coding Scheme Designator	\N
1312	(0008,1111)[<0>](0008,1155)	UI	f	Referenced Performed Procedure Step Sequence:Referenced SOP Instance UID	\N
1220	(0008,0080)	LO	f	Institution Name	\N
1211	(0018,1018)	LO	f	Secondary Capture Device Manufacturer's Model Name	\N
1237	(0040,0555)[<0>](0040,a168)	SQ	f	Acquisition Context Sequence:Concept Code Sequence	\N
1240	(0040,0555)[<0>](0040,a043)[<1>](0008,0100)	SH	f	Acquisition Context Sequence:Concept Name Code Sequence:Code Value	\N
1309	(0008,1111)[<0>](0008,1150)	UI	f	Referenced Performed Procedure Step Sequence:Referenced SOP Class UID	\N
1229	(6000,0011)	US	f	Overlay Columns	\N
4921	(5001,"ELSCINT1",93)	UL	t	Unknown	d
4805	(0019,"GEMS_ACQU_01",1a)	OB	t	LastScanRAS	k
4917	(0045,"GEMS_HELIOS_01",51)	OB	t	Unknown	d
4847	(0019,"GEMS_ACQU_01",02)	OB	t	NumberOfCellsInDetector	k
3838	(0019,"",e2)	UN	t	Unknown	d
4899	(0045,"GEMS_HELIOS_01",56)	LO	t	Unknown	d
2857	(01f3,"ELSCINT1",01)[<0>](01f3,"ELSCINT1",04)	OB	t	Unknown:Unknown	d
1151	(0020,0062)	CS	f	Image Laterality	\N
4809	(0045,"GEMS_HELIOS_01",18)	OB	t	Number of Views 1B	k
1568	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",64)	UN	t	Unknown	d
4825	(0027,"GEMS_IMAG_01",51)	OB	t	TableEndLocation	k
4871	(0045,"GEMS_HELIOS_01",07)	OB	t	Z smoothing Factor	k
4913	(0045,"GEMS_HELIOS_01",52)	OB	t	Unknown	d
254	(0019,"GEMS_ACQU_01",5f)	SL	t	IncrementBetweenChannels	k
4137	(5653,"",15)	UN	t	Unknown	d
2599	(0040,0008)[<0>](0008,0100)	SH	f	Scheduled Protocol Code Sequence:Code Value	\N
2600	(0040,0008)[<0>](0008,0102)	SH	f	Scheduled Protocol Code Sequence:Coding Scheme Designator	\N
2601	(0040,0008)[<0>](0008,0104)	LO	f	Scheduled Protocol Code Sequence:Code Meaning	\N
1337	(0054,0016)[<0>](0054,0300)[<1>](0008,010f)	CS	f	Radiopharmaceutical Information Sequence:Radionuclide Code Sequence:Context Identifier	\N
1339	(0054,0414)[<0>](0008,0105)	CS	f	Patient Gantry Relationship Code Sequence:Mapping Resource	\N
1392	(0008,1032)[<0>](0008,0103)	SH	f	Procedure Code Sequence:Coding Scheme Version	\N
683	(0054,0016)[<0>](0054,0300)[<1>](0008,0104)	LO	f	Radiopharmaceutical Information Sequence:Radionuclide Code Sequence:Code Meaning	\N
1325	(0008,1250)[<0>](0040,a170)[<1>](0008,0104)	LO	f	Related Series Sequence:Purpose of Reference Code Sequence:Code Meaning	\N
1432	(0018,a001)[<0>](0040,a170)[<1>](0008,0100)	SH	f	Contributing Equipment Sequence:Purpose of Reference Code Sequence:Code Value	\N
1153	(0018,1081)	IS	f	Low R-R Value	\N
531	(0032,4000)	LT	f	Study Comments	\N
98	(0040,0245)	TM	f	Performed Procedure Step Start Time	\N
980	(300a,00b0)[<0>](300a,0111)[<1>](300a,0115)	DS	f	Beam Sequence:Control Point Sequence:Dose Rate Set	\N
6	(0018,0024)	SH	f	Sequence Name	\N
19	(0018,1020)	LO	f	Software Version(s)	\N
904	(3006,0080)	SQ	f	RT ROI Observations Sequence	\N
1341	(0054,0410)[<0>](0008,0105)	CS	f	Patient Orientation Code Sequence:Mapping Resource	\N
1343	(0054,0410)[<0>](0008,010f)	CS	f	Patient Orientation Code Sequence:Context Identifier	\N
1334	(0054,0016)[<0>](0054,0300)[<1>](0008,0106)	DT	f	Radiopharmaceutical Information Sequence:Radionuclide Code Sequence:Context Group Version	\N
1336	(0054,0414)[<0>](0008,010f)	CS	f	Patient Gantry Relationship Code Sequence:Context Identifier	\N
1444	(0028,0301)	CS	f	Burned In Annotation	\N
1967	(5000,0103)	US	f	Data Value Representation	\N
1974	(0018,6011)[<0>](0018,601a)	UL	f	Sequence of Ultrasound Regions:Region Location Min Y0	\N
1972	(0018,6011)[<0>](0018,601c)	UL	f	Sequence of Ultrasound Regions:Region Location Max X1	\N
1961	(2100,0050)	TM	f	Creation Time	\N
1985	(0018,6011)[<0>](0018,602a)	FD	f	Sequence of Ultrasound Regions:Reference Pixel Physical Value Y	\N
1966	(5000,0005)	US	f	Curve Dimensions	\N
1947	(5000,3000)	OB	f	Curve Data	\N
1984	(0018,6031)	CS	f	Transducer Type	\N
1971	(0018,6011)	SQ	f	Sequence of Ultrasound Regions	\N
1980	(0008,2120)	SH	f	Stage Name	\N
1978	(0008,2124)	IS	f	Number of Stages	\N
1982	(0040,0007)	LO	f	Scheduled Procedure Step Description	\N
1976	(0018,6011)[<0>](0018,6016)	UL	f	Sequence of Ultrasound Regions:Region Flags	\N
1981	(0040,0009)	SH	f	Scheduled Procedure Step ID	\N
1957	(5000,0020)	CS	f	Type of Data	\N
1965	(5000,0010)	US	f	Number of Points	\N
1970	(2100,0040)	DA	f	Creation Date	\N
1973	(0018,6011)[<0>](0018,6018)	UL	f	Sequence of Ultrasound Regions:Region Location Min X0	\N
1979	(0008,2122)	IS	f	Stage Number	\N
1987	(0018,6011)[<0>](0018,602c)	FD	f	Sequence of Ultrasound Regions:Physical Delta X	\N
1977	(0008,212a)	IS	f	Number of Views in Stage	\N
1986	(0018,6011)[<0>](0018,602e)	FD	f	Sequence of Ultrasound Regions:Physical Delta Y	\N
1975	(0018,6011)[<0>](0018,601e)	UL	f	Sequence of Ultrasound Regions:Region Location Max Y1	\N
1983	(0018,5010)	LO	f	Transducer Data	\N
1468	(0008,9215)	SQ	f	Derivation Code Sequence	\N
488	(0043,"GEMS_PARM_01",0b)	DS	t	PeakRateOfChangeOfGradientField	k
5163	(0008,1111)[<0>](2005,"Philips MR Imaging DD 005",06)	OB	t	Referenced Performed Procedure Step Sequence:Number of PS Specific Character Sets	k
3329	(0040,a043)[<0>](0008,0104)	LO	f	Concept Name Code Sequence:Code Meaning	\N
910	(3006,0080)[<0>](3006,00b0)	SQ	f	RT ROI Observations Sequence:ROI Physical Properties Sequence	\N
39	(0020,1041)	DS	f	Slice Location	\N
4849	(0043,"GEMS_PARM_01",4e)	OB	t	DurationOfXrayOn	k
669	(0009,"GEMS_PETD_01",37)	LO	t	Batch Description	k
4859	(0027,"GEMS_IMAG_01",47)	OB	t	NormalSCoord	k
3616	(0019,"SIEMENS MR HEADER",16)	UN	t	Time After Start	k
2919	(2010,0010)	ST	f	Image Display Format	\N
221	(0023,"GEMS_STDY_01",70)	FD	t	StartTimeSecsInFirstAxial	k
728	(0018,1181)	CS	f	Collimator Type	\N
1204	(0012,0051)	ST	f	Clinical Trial Time Point Description	\N
1171	(0020,1209)	IS	f	Number of Series Related Instances	\N
172	(0018,1151)	IS	f	X-Ray Tube Current	\N
115	(0028,0106)	US	f	Smallest Image Pixel Value	\N
645	(0028,0106)	SS	f	Smallest Image Pixel Value	\N
701	(0054,0410)[<0>](0008,0104)	LO	f	Patient Orientation Code Sequence:Code Meaning	\N
988	(300a,00b0)[<0>](300a,00b4)	DS	f	Beam Sequence:Source-Axis Distance	\N
956	(300a,00b0)[<0>](0008,0070)	LO	f	Beam Sequence:Manufacturer	\N
1410	(0088,0200)[<0>](0028,1203)	OW	f	Icon Image Sequence:Blue Palette Color Lookup Table Data	\N
1321	(0008,1250)[<0>](0040,a170)[<1>](0008,0100)	SH	f	Related Series Sequence:Purpose of Reference Code Sequence:Code Value	\N
1191	(500a,0103)	UN	f	Data Value Representation	\N
1461	(3006,00c2)	UI	f	Related Frame of Reference UID	\N
1324	(0008,1250)[<0>](0040,a170)[<1>](0008,0102)	SH	f	Related Series Sequence:Purpose of Reference Code Sequence:Coding Scheme Designator	\N
1253	(0008,1120)	SQ	f	Referenced Patient Sequence	\N
1032	(0040,0004)	DA	f	Scheduled Procedure Step End Date	\N
1096	(0018,9324)	FD	f	Estimated Dose Saving	\N
1175	(5006,0022)	UN	f	Curve Description	\N
1463	(0008,1155)	UI	f	Referenced SOP Instance UID	\N
1223	(0018,1200)	DS	f	Date of Last Calibration	\N
199	(0018,1130)	DS	f	Table Height	\N
112	(0028,0002)	US	f	Samples per Pixel	\N
975	(300a,00b0)[<0>](300a,00b6)[<1>](300a,00be)	DS	f	Beam Sequence:Beam Limiting Device Sequence:Leaf Position Boundaries	\N
702	(0054,1323)	DS	f	Scatter Fraction Factor	\N
920	(3006,0080)[<0>](3006,00a6)	PN	f	RT ROI Observations Sequence:ROI Interpreter	\N
912	(3006,0020)[<0>](3006,0026)	LO	f	Structure Set ROI Sequence:ROI Name	\N
149	(0008,2112)	SQ	f	Source Image Sequence	\N
1210	(0008,1010)	SH	f	Station Name	\N
983	(300a,00b0)[<0>](300a,0111)[<1>](300a,0125)	DS	f	Beam Sequence:Control Point Sequence:Table Top Eccentric Angle	\N
122	(0008,0022)	DA	f	Acquisition Date	\N
808	(0032,1070)	LO	f	Requested Contrast Agent	\N
707	(0054,1210)	DS	f	Coincidence Window Width	\N
1065	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00f6)	DS	f	Beam Sequence:Block Sequence:Source to Block Tray Distance	\N
1150	(0018,1121)	DS	f	Gantry/Detector Slew	\N
651	(0054,0016)[<0>](0018,1078)	DT	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Start DateTime	\N
1469	(0008,9215)[<0>](0008,0100)	SH	f	Derivation Code Sequence:Code Value	\N
2622	(0040,9096)[<0>](0040,9210)	SS	f	Real World Value Mapping Sequence:LUT Label	\N
978	(300a,00b0)[<0>](300a,00b6)[<1>](300a,00ba)	DS	f	Beam Sequence:Beam Limiting Device Sequence:Source to Beam Limiting Device Distance	\N
101	(0008,0018)	UI	f	SOP Instance UID	\N
4940	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",7f)	UN	t	Unknown	d
778	(0009,"GEMS_PETD_01",34)	SL	t	Triggers Acquired	k
541	(0038,0050)	LO	f	Special Needs	\N
583	(0054,1311)	IS	f	Secondary Counts Accumulated	\N
2846	(01f1,"ELSCINT1",27)	OB	t	Rotation Time	d
174	(0020,1002)	IS	f	Images in Acquisition	\N
1260	(0008,1120)[<0>](0008,1150)	UI	f	Referenced Patient Sequence:Referenced SOP Class UID	\N
1436	(0018,a001)[<0>](0040,a170)[<1>](0008,0104)	LO	f	Contributing Equipment Sequence:Purpose of Reference Code Sequence:Code Meaning	\N
1439	(0018,a001)[<0>](0008,0080)	LO	f	Contributing Equipment Sequence:Institution Name	\N
1106	(0029,"SIEMENS MEDCOM HEADER",33)	UL	t	PMTFInformation3	d
1302	(0054,0016)[<0>](0054,0302)	SQ	f	Radiopharmaceutical Information Sequence:Administration Route Code Sequence	\N
3613	(0051,"SIEMENS MR HEADER",19)	UN	t	Unknown	d
1433	(0018,a001)[<0>](0040,a170)	SQ	f	Contributing Equipment Sequence:Purpose of Reference Code Sequence	\N
4893	(0137,"NetRAAD",30)	UN	t	Unknown	d
634	(0009,"GEMS_PETD_01",cd)	FL	t	vqc_y_axis_trans	k
4907	(0053,"GEHC_CT_ADVAPP_001",6f)	UN	t	Unknown	d
3615	(0051,"SIEMENS MR HEADER",13)	UN	t	Positive PCS Directions	d
1182	(5002,0103)	UN	f	Data Value Representation	\N
1421	(0088,0200)[<0>](0028,0102)	US	f	Icon Image Sequence:High Bit	\N
1413	(0088,0200)[<0>](0028,0004)	CS	f	Icon Image Sequence:Photometric Interpretation	\N
1342	(0054,0016)[<0>](0054,0300)[<1>](0008,0105)	CS	f	Radiopharmaceutical Information Sequence:Radionuclide Code Sequence:Mapping Resource	\N
972	(300a,0070)[<0>](300a,0078)	IS	f	Fraction Group Sequence:Number of Fractions Planned	\N
120	(0010,0030)	DA	f	Patient's Birth Date	\N
3611	(0019,"SIEMENS MR HEADER",12)	UN	t	Table Position Origin	k
3612	(0019,"SIEMENS MR HEADER",13)	UN	t	Ima Abs Table Position	k
3618	(0051,"SIEMENS MR HEADER",15)	UN	t	Unknown	d
3614	(0019,"SIEMENS MR HEADER",0b)	UN	t	Slice Measurement Duration	k
3335	(0040,a730)[<0>](0040,a040)	CS	f	Content Sequence:Value Type	\N
3338	(0040,a040)	CS	f	Value Type	\N
3336	(0040,a050)	CS	f	Continuity Of Content	\N
3331	(0040,a730)[<0>](0040,a168)[<1>](0008,0104)	LO	f	Content Sequence:Concept Code Sequence:Code Meaning	\N
3334	(0040,a504)[<0>](0040,db00)	CS	f	Content Template Sequence:Template Identifier	\N
3345	(0040,a032)	DT	f	Observation DateTime	\N
3333	(0040,a730)[<0>](0040,a010)	CS	f	Content Sequence:Relationship Type	\N
1116	(0054,0410)[<0>](0054,0412)[<1>](0008,0102)	SH	f	Patient Orientation Code Sequence:Patient Orientation Modifier Code Sequence:Coding Scheme Designator	\N
1212	(0018,1019)	LO	f	Secondary Capture Device Software Versions	\N
947	(300a,0180)	SQ	f	Patient Setup Sequence	\N
1067	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00f8)	CS	f	Beam Sequence:Block Sequence:Block Type	\N
655	(0054,0410)[<0>](0008,0102)	SH	f	Patient Orientation Code Sequence:Coding Scheme Designator	\N
545	(0020,4000)	LT	f	Image Comments	\N
908	(3006,0039)	SQ	f	ROI Contour Sequence	\N
1307	(0008,1250)[<0>](0020,000d)	UI	f	Related Series Sequence:Study Instance UID	\N
1023	(0040,0005)	TM	f	Scheduled Procedure Step End Time	\N
1000	(300a,00b0)[<0>](300a,00c4)	CS	f	Beam Sequence:Beam Type	\N
944	(300a,00b0)[<0>](300a,00b6)	SQ	f	Beam Sequence:Beam Limiting Device Sequence	\N
116	(0028,0100)	US	f	Bits Allocated	\N
2661	(0040,2001)	LO	f	Reason for the Imaging Service Request	\N
952	(300a,00b0)	SQ	f	Beam Sequence	\N
2662	(0040,1002)	LO	f	Reason for the Requested Procedure	\N
2666	(0040,1400)	LT	f	Requested Procedure Comments	\N
2667	(0040,2400)	LT	f	Imaging Service Request Comments	\N
5551	(2005,"Philips MR Imaging DD 006",57)	UN	t	Unknown	d
193	(0028,1052)	DS	f	Rescale Intercept	\N
914	(3006,0039)[<0>](3006,0040)[<1>](3006,0046)	IS	f	ROI Contour Sequence:Contour Sequence:Number of Contour Points	\N
1228	(0018,1014)	TM	f	Time of Secondary Capture	\N
954	(300a,0003)	LO	f	RT Plan Name	\N
1222	(0008,1070)	PN	f	Operators' Name	\N
953	(300a,00b0)[<0>](300a,00c2)	LO	f	Beam Sequence:Beam Name	\N
5548	(00e1,"ELSCINT1",e3)	US	t	Unknown	d
105	(0008,1140)[<0>](0008,1150)	UI	f	Referenced Image Sequence:Referenced SOP Class UID	\N
1460	(0040,a124)	UI	f	UID	\N
1300	(0008,1250)	SQ	f	Related Series Sequence	\N
1196	(500a,0020)	UN	f	Type of Data	\N
898	(0018,1046)	DS	f	Contrast Flow Rate	\N
1181	(500a,0010)	UN	f	Number of Points	\N
1174	(5002,0022)	UN	f	Curve Description	\N
1219	(6000,0022)	LO	f	Overlay Description	\N
1419	(0088,0200)[<0>](0028,0010)	US	f	Icon Image Sequence:Rows	\N
1405	(0088,0140)	UI	f	Storage Media File-set UID	\N
558	(0028,0009)	AT	f	Frame Increment Pointer	\N
712	(0054,0013)[<0>](0054,0014)	DS	f	Energy Window Range Sequence:Energy Window Lower Limit	\N
705	(0054,1300)	DS	f	Frame Reference Time	\N
496	(0020,0110)	DS	f	Temporal Resolution	\N
4955	(0013,"CTP",51)	UN	t	Year of Diagnosis	k
5552	(2005,"Philips MR Imaging DD 006",63)	UN	t	Unknown	d
948	(300a,0070)	SQ	f	Fraction Group Sequence	\N
996	(300a,000c)	CS	f	RT Plan Geometry	\N
3617	(0029,"MITRA MARKUP 1.0",02)	UN	t	Markup3	d
5549	(2005,"Philips MR Imaging DD 006",62)	UN	t	Unknown	d
963	(300a,0180)[<0>](300a,0182)	IS	f	Patient Setup Sequence:Patient Setup Number	\N
901	(3006,0002)	SH	f	Structure Set Label	\N
1178	(5002,0010)	UN	f	Number of Points	\N
933	(3006,0020)[<0>](3006,0024)	UI	f	Structure Set ROI Sequence:Referenced Frame of Reference UID	\N
939	(3006,0008)	DA	f	Structure Set Date	\N
41	(0010,1030)	DS	f	Patient's Weight	\N
171	(0018,1152)	IS	f	Exposure	\N
895	(0032,1064)[<0>](0008,0104)	LO	f	Requested Procedure Code Sequence:Code Meaning	\N
959	(300a,00b0)[<0>](300c,00a0)	IS	f	Beam Sequence:Referenced Tolerance Table Number	\N
48	(0010,1020)	DS	f	Patient's Size	\N
1301	(0008,1111)	SQ	f	Referenced Performed Procedure Step Sequence	\N
190	(0018,1110)	DS	f	Distance Source to Detector	\N
106	(0008,1110)[<0>](0008,1155)	UI	f	Referenced Study Sequence:Referenced SOP Instance UID	\N
949	(300a,00b0)[<0>](300a,0111)	SQ	f	Beam Sequence:Control Point Sequence	\N
1008	(300c,0060)[<0>](0008,1150)	UI	f	Referenced Structure Set Sequence:Referenced SOP Class UID	\N
656	(0054,0016)[<0>](0054,0304)[<1>](0008,0102)	SH	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Code Sequence:Coding Scheme Designator	\N
127	(0018,0010)	LO	f	Contrast/Bolus Agent	\N
2705	(0040,2005)	TM	f	Issue Time of Imaging Service Request	\N
2713	(0040,2004)	DA	f	Issue Date of Imaging Service Request	\N
2686	(0040,0252)	CS	f	Performed Procedure Step Status	\N
4954	(0013,"CTP",51)	LO	t	Year of Diagnosis	k
3623	(0029,"MITRA MARKUP 1.0",08)	UN	t	Markup9	d
1193	(5006,0005)	UN	f	Curve Dimensions	\N
1195	(5008,0010)	UN	f	Number of Points	\N
1322	(0054,0016)[<0>](0054,0302)[<1>](0008,0100)	SH	f	Radiopharmaceutical Information Sequence:Administration Route Code Sequence:Code Value	\N
1326	(0054,0016)[<0>](0054,0302)[<1>](0008,0104)	LO	f	Radiopharmaceutical Information Sequence:Administration Route Code Sequence:Code Meaning	\N
2722	(0008,1111)[<0>](0008,0005)	CS	f	Referenced Performed Procedure Step Sequence:Specific Character Set	\N
3624	(0029,"MITRA MARKUP 1.0",09)	UN	t	Markup10	d
987	(300a,00b0)[<0>](300a,0111)[<1>](300a,0120)	DS	f	Beam Sequence:Control Point Sequence:Beam Limiting Device Angle	\N
3628	(0029,"MITRA MARKUP 1.0",06)	UN	t	Markup7	d
110	(0028,0107)	US	f	Largest Image Pixel Value	\N
3625	(0029,"MITRA MARKUP 1.0",04)	UN	t	Markup5	d
3626	(0029,"MITRA MARKUP 1.0",0a)	UN	t	Unknown	d
2863	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",13)	OB	t	Unknown:Unknown	d
3627	(0029,"MITRA MARKUP 1.0",07)	UN	t	Markup8	d
3362	(0070,0060)[<0>](0070,0068)	LO	f	Graphic Layer Sequence:Graphic Layer Description	\N
3354	(0018,a002)	DT	f	Contribution DateTime	\N
3356	(0040,a170)[<0>](0008,0102)	SH	f	Purpose of Reference Code Sequence:Coding Scheme Designator	\N
3355	(0040,a170)[<0>](0008,0100)	SH	f	Purpose of Reference Code Sequence:Code Value	\N
3350	(0018,9327)	FD	f	Table Position	\N
1427	(0088,0200)[<0>](0028,1103)	US	f	Icon Image Sequence:Blue Palette Color Lookup Table Descriptor	\N
639	(0028,0107)	SS	f	Largest Image Pixel Value	\N
5553	(2005,"Philips MR Imaging DD 006",64)	UN	t	Unknown	d
92	(0018,0023)	CS	f	MR Acquisition Type	\N
33	(0020,0011)	IS	f	Series Number	\N
1408	(0088,0200)[<0>](0028,1103)	SS	f	Icon Image Sequence:Blue Palette Color Lookup Table Descriptor	\N
1232	(6000,0051)	US	f	Image Frame Origin	\N
1192	(500a,3000)	UN	f	Curve Data	\N
1230	(6000,0010)	US	f	Overlay Rows	\N
1415	(0088,0200)[<0>](0028,0103)	US	f	Icon Image Sequence:Pixel Representation	\N
1104	(0040,0255)	LO	f	Performed Procedure Type Description	\N
2721	(0018,2010)	DS	f	Nominal Scanned Pixel Spacing	\N
5554	(2005,"Philips MR Imaging DD 006",86)	UN	t	Unknown	d
1434	(0018,a001)	SQ	f	Contributing Equipment Sequence	\N
5556	(2005,"Philips MR Imaging DD 006",76)	UN	t	Unknown	d
673	(0054,1101)	LO	f	Attenuation Correction Method	\N
4169	(0029,"SIEMENS CSA REPORT",17)	UI	t	SC SOP Instance UID	d
5555	(2005,"Philips MR Imaging DD 006",83)	UN	t	Unknown	d
5557	(2005,"Philips MR Imaging DD 006",81)	UN	t	Unknown	d
4299	(0009,"Unnamed Private Block - 77",70)	UT	t	Unknown	d
1189	(5002,0005)	UN	f	Curve Dimensions	\N
710	(0054,1320)	DS	f	Slice Sensitivity Factor	\N
1458	(0054,1004)	CS	f	Reprojection Method	\N
733	(0054,0016)[<0>](0018,1072)	TM	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Start Time	\N
931	(3006,0010)[<0>](3006,0012)[<1>](0008,1155)	UI	f	Referenced Frame of Reference Sequence:RT Referenced Study Sequence:Referenced SOP Instance UID	\N
85	(0010,0040)	CS	f	Patient's Sex	\N
982	(300a,0070)[<0>](300c,0004)[<1>](300a,0086)	DS	f	Fraction Group Sequence:Referenced Beam Sequence:Beam Meterset	\N
877	(0054,0400)	SH	f	Image ID	\N
1238	(0040,0555)	SQ	f	Acquisition Context Sequence	\N
578	(0054,0410)	SQ	f	Patient Orientation Code Sequence	\N
557	(0028,0008)	IS	f	Number of Frames	\N
1007	(300c,0060)[<0>](0008,1155)	UI	f	Referenced Structure Set Sequence:Referenced SOP Instance UID	\N
53	(0018,0088)	DS	f	Spacing Between Slices	\N
995	(300a,00b0)[<0>](300a,0111)[<1>](300a,011a)[<2>](300a,00b8)	CS	f	Beam Sequence:Control Point Sequence:Beam Limiting Device Position Sequence:RT Beam Limiting Device Type	\N
992	(300a,00b0)[<0>](300a,010e)	DS	f	Beam Sequence:Final Cumulative Meterset Weight	\N
21	(0012,0063)	LO	f	De-identification Method	\N
585	(0018,1083)	IS	f	Intervals Acquired	\N
219	(0010,21b0)	LT	f	Additional Patient History	\N
1234	(0028,0006)	US	f	Planar Configuration	\N
993	(300a,00b0)[<0>](300a,0111)[<1>](300a,0114)	DS	f	Beam Sequence:Control Point Sequence:Nominal Beam Energy	\N
984	(300a,0070)[<0>](300c,0004)[<1>](300a,0082)	DS	f	Fraction Group Sequence:Referenced Beam Sequence:Beam Dose Specification Point	\N
909	(3006,0039)[<0>](3006,0040)	SQ	f	ROI Contour Sequence:Contour Sequence	\N
563	(3004,0004)	CS	f	Dose Type	\N
2154	(0010,1000)	LO	f	Other Patient IDs	\N
2745	(0008,2112)[<0>](0040,a170)[<1>](0008,0102)	SH	f	Source Image Sequence:Purpose of Reference Code Sequence:Coding Scheme Designator	\N
2747	(0028,2112)	DS	f	Lossy Image Compression Ratio	\N
2145	(0012,0031)	LO	f	Clinical Trial Site Name	\N
822	(0018,9321)[<0>](0018,9323)	CS	f	CT Exposure Sequence:Exposure Modulation Type	\N
1333	(0054,0410)[<0>](0054,0412)[<1>](0008,0106)	DT	f	Patient Orientation Code Sequence:Patient Orientation Modifier Code Sequence:Context Group Version	\N
564	(3004,000a)	CS	f	Dose Summation Type	\N
24	(0032,1060)	LO	f	Requested Procedure Description	\N
894	(0032,1064)	SQ	f	Requested Procedure Code Sequence	\N
1188	(5004,3000)	UN	f	Curve Data	\N
1119	(0054,0410)[<0>](0054,0412)[<1>](0008,0100)	SH	f	Patient Orientation Code Sequence:Patient Orientation Modifier Code Sequence:Code Value	\N
732	(0054,0016)[<0>](0018,1073)	TM	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Stop Time	\N
14	(0018,1030)	LO	f	Protocol Name	\N
38	(0028,1051)	DS	f	Window Width	\N
709	(0018,1060)	DS	f	Trigger Time	\N
17	(0028,1055)	LO	f	Window Center & Width Explanation	\N
1332	(0054,0410)[<0>](0008,0106)	DT	f	Patient Orientation Code Sequence:Context Group Version	\N
735	(0054,0081)	US	f	Number of Slices	\N
1216	(0018,1016)	LO	f	Secondary Capture Device Manufacturer	\N
44	(0018,0094)	DS	f	Percent Phase Field of View	\N
934	(3006,0010)[<0>](0020,0052)	UI	f	Referenced Frame of Reference Sequence:Frame of Reference UID	\N
3494	(0011,"GEMS_GDXE_FALCON_04",35)	DS	t	Uncompensated Detector Exposure	d
3498	(0011,"GEMS_GDXE_FALCON_04",19)	DS	t	Film Speed Selection	d
3480	(0045,"GEMS_FALCON_03",69)	IS	t	Collimator Rotation	d
1812	(7005,"TOSHIBA_MEC_CT3",1c)	LO	t	Contrast/Bolus Agent for Series Record	k
3482	(0045,"GEMS_FALCON_03",63)	IS	t	User Window Width	d
3363	(0070,0041)	CS	f	Image Horizontal Flip	\N
3376	(0018,1260)	SH	f	Plate Type	\N
3379	(0018,1411)	DS	f	Exposure Index	\N
3365	(0070,0042)	US	f	Image Rotation	\N
3377	(0028,3010)[<0>](0028,3003)	LO	f	VOI LUT Sequence:LUT Explanation	\N
3371	(0028,3010)	SQ	f	VOI LUT Sequence	\N
3366	(0018,1622)	US	f	Shutter Presentation Value	\N
3364	(0070,0060)[<0>](0070,0066)	US	f	Graphic Layer Sequence:Graphic Layer Recommended Display Grayscale Value	\N
3378	(0018,1413)	DS	f	Deviation Index	\N
3477	(0011,"GEMS_GDXE_FALCON_04",31)	IS	t	Detected Field of View	d
3478	(0011,"GEMS_GDXE_FALCON_04",32)	IS	t	Adjusted Field of View	d
653	(0054,0016)[<0>](0054,0300)[<1>](0008,0100)	SH	f	Radiopharmaceutical Information Sequence:Radionuclide Code Sequence:Code Value	\N
15	(0008,1030)	LO	f	Study Description	\N
1112	(0054,0410)[<0>](0054,0412)	SQ	f	Patient Orientation Code Sequence:Patient Orientation Modifier Code Sequence	\N
1177	(5006,0010)	UN	f	Number of Points	\N
1198	(5008,0020)	UN	f	Type of Data	\N
457	(0018,1000)	LO	f	Device Serial Number	\N
1207	(6000,0015)	IS	f	Number of Frames in Overlay	\N
1420	(0088,0200)[<0>](0028,0002)	US	f	Icon Image Sequence:Samples per Pixel	\N
1416	(0088,0200)[<0>](0028,0101)	US	f	Icon Image Sequence:Bits Stored	\N
695	(0054,1104)	LO	f	Detector Lines of Response Used	\N
572	(0054,0412)	SQ	f	Patient Orientation Modifier Code Sequence	\N
1235	(0018,1012)	DA	f	Date of Secondary Capture	\N
1338	(0054,0410)[<0>](0054,0412)[<1>](0008,010f)	CS	f	Patient Orientation Code Sequence:Patient Orientation Modifier Code Sequence:Context Identifier	\N
217	(0018,0090)	DS	f	Data Collection Diameter	\N
1078	(0032,1000)	DA	f	Scheduled Study Start Date	\N
2155	(0010,0021)	LO	f	Issuer of Patient ID	\N
2149	(0012,0020)	LO	f	Clinical Trial Protocol ID	\N
2743	(0008,2112)[<0>](0040,a170)[<1>](0008,0106)	DT	f	Source Image Sequence:Purpose of Reference Code Sequence:Context Group Version	\N
2159	(0032,1032)	PN	f	Requesting Physician	\N
2150	(0012,0040)	LO	f	Clinical Trial Subject ID	\N
2744	(0008,2112)[<0>](0040,a170)[<1>](0008,0100)	SH	f	Source Image Sequence:Purpose of Reference Code Sequence:Code Value	\N
2153	(0040,0253)	SH	f	Performed Procedure Step ID	\N
2146	(0012,0030)	LO	f	Clinical Trial Site ID	\N
2148	(0012,0010)	LO	f	Clinical Trial Sponsor Name	\N
2147	(0012,0021)	LO	f	Clinical Trial Protocol Name	\N
1176	(5004,0010)	UN	f	Number of Points	\N
1199	(5006,0020)	UN	f	Type of Data	\N
1184	(5006,3000)	UN	f	Curve Data	\N
1438	(0018,a001)[<0>](0008,1040)	LO	f	Contributing Equipment Sequence:Institutional Department Name	\N
1190	(500a,0005)	UN	f	Curve Dimensions	\N
1310	(0008,9121)[<0>](0008,1150)	UI	f	Referenced Raw Data Sequence:Referenced SOP Class UID	\N
1233	(6000,0102)	US	f	Overlay Bit Position	\N
80	(0018,0025)	CS	f	Angio Flag	\N
1148	(0008,1080)	LO	f	Admitting Diagnoses Description	\N
2742	(0008,9215)[<0>](0008,0106)	DT	f	Derivation Code Sequence:Context Group Version	\N
2741	(0008,2112)[<0>](0040,a170)	SQ	f	Source Image Sequence:Purpose of Reference Code Sequence	\N
42	(0020,0037)	DS	f	Image Orientation (Patient)	\N
37	(0018,0081)	DS	f	Echo Time	\N
2156	(0008,1060)	PN	f	Name of Physician(s) Reading Study	\N
5561	(2005,"Philips MR Imaging DD 006",85)	UN	t	Unknown	d
1299	(0008,1250)[<0>](0040,a170)	SQ	f	Related Series Sequence:Purpose of Reference Code Sequence	\N
574	(0054,0016)[<0>](0054,0304)	SQ	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Code Sequence	\N
99	(0008,0031)	TM	f	Series Time	\N
942	(300a,0002)	SH	f	RT Plan Label	\N
1471	(0008,9215)[<0>](0008,0104)	LO	f	Derivation Code Sequence:Code Meaning	\N
4002	(0019,"",9c)	UN	t	Unknown	d
615	(0009,"GEMS_PETD_01",8f)	FL	t	BP Filter Cutoff	k
1440	(0018,a001)[<0>](0008,0070)	LO	f	Contributing Equipment Sequence:Manufacturer	\N
1250	(0018,1072)	TM	f	Radiopharmaceutical Start Time	\N
1447	(0008,0054)	AE	f	Retrieve AE Title	\N
335	(0018,9310)	FD	f	Table Feed per Rotation	\N
130	(0018,1049)	DS	f	Contrast/Bolus Ingredient Concentration	\N
1139	(0054,0101)	US	f	Number of Time Slices	\N
1076	(0032,1051)	TM	f	Study Completion Time	\N
1989	(0018,6011)[<0>](0018,6012)	US	f	Sequence of Ultrasound Regions:Region Spatial Format	\N
1459	(0010,0032)	TM	f	Patient's Birth Time	\N
2755	(0040,a043)	SQ	f	Concept Name Code Sequence	\N
2748	(0008,9215)[<0>](0008,010b)	CS	f	Derivation Code Sequence:Context Group Extension Flag	\N
2754	(0008,2112)[<0>](0040,a170)[<1>](0008,0105)	CS	f	Source Image Sequence:Purpose of Reference Code Sequence:Mapping Resource	\N
1418	(0088,0200)[<0>](0028,0011)	US	f	Icon Image Sequence:Columns	\N
1425	(0088,0200)[<0>](0028,1101)	US	f	Icon Image Sequence:Red Palette Color Lookup Table Descriptor	\N
1406	(0088,0200)[<0>](0028,1101)	SS	f	Icon Image Sequence:Red Palette Color Lookup Table Descriptor	\N
897	(0018,1047)	DS	f	Contrast Flow Duration	\N
1165	(5000,0103)	UN	f	Data Value Representation	\N
2751	(0008,2112)[<0>](0040,a170)[<1>](0008,010f)	CS	f	Source Image Sequence:Purpose of Reference Code Sequence:Context Identifier	\N
1163	(5000,0005)	UN	f	Curve Dimensions	\N
2752	(0028,2114)	CS	f	Lossy Image Compression Method	\N
2760	(0042,0011)	OB	f	Encapsulated Document	\N
1169	(0028,1102)	OW	f	Green Palette Color Lookup Table Descriptor	\N
955	(300a,00b0)[<0>](0008,0080)	LO	f	Beam Sequence:Institution Name	\N
1399	(0088,0200)	SQ	f	Icon Image Sequence	\N
1170	(0028,1101)	OW	f	Red Palette Color Lookup Table Descriptor	\N
1168	(0028,1103)	OW	f	Blue Palette Color Lookup Table Descriptor	\N
1917	(0028,1202)	OW	f	Green Palette Color Lookup Table Data	\N
547	(0018,9323)	CS	f	Exposure Modulation Type	\N
1370	(01f7,"ELSCINT1",15)	OW	t	Unknown	d
562	(3004,0014)	CS	f	Tissue Heterogeneity Correction	\N
1297	(0010,1040)	LO	f	Patient's Address	\N
3927	(0043,"",8a)	UN	t	Unknown	d
3504	(0045,"GEMS_FALCON_03",67)	DS	t	VOI LUT Assymmetry Parameter Beta	d
3383	(0028,0300)	CS	f	Quality Control Image	\N
3386	(0008,2112)[<0>](0028,135a)	CS	f	Source Image Sequence:Spatial Locations Preserved	\N
3388	(0018,1402)	CS	f	Cassette Orientation	\N
3381	(0018,1412)	DS	f	Target Exposure Index	\N
3517	(0011,"GEMS_GDXE_FALCON_04",44)	CS	t	Receptor Type	d
5563	(2005,"Philips MR Imaging DD 006",87)	UN	t	Unknown	d
918	(3006,0039)[<0>](3006,0084)	IS	f	ROI Contour Sequence:Referenced ROI Number	\N
1160	(0054,1220)	CS	f	Secondary Counts Type	\N
197	(0018,1111)	DS	f	Distance Source to Patient	\N
4053	(0033,"",04)	CS	t	Unknown	d
1069	(300a,00b0)[<0>](300a,0107)[<1>](300a,0109)	CS	f	Beam Sequence:Applicator Sequence:Applicator Type	\N
729	(0028,2110)	CS	f	Lossy Image Compression	\N
1162	(5000,0020)	UN	f	Type of Data	\N
1161	(5000,0010)	UN	f	Number of Points	\N
1908	(0018,1023)	LO	f	Digital Image Format Acquired	\N
1904	(0008,0041)	CS	f	Data Set Subtype	\N
1915	(0028,1203)	OW	f	Blue Palette Color Lookup Table Data	\N
1992	(0018,6011)[<0>](0018,6026)	US	f	Sequence of Ultrasound Regions:Physical Units Y Direction	\N
1916	(0028,1201)	OW	f	Red Palette Color Lookup Table Data	\N
1922	(0018,1043)	TM	f	Contrast/Bolus Stop Time	\N
1993	(0018,6011)[<0>](0018,6022)	SL	f	Sequence of Ultrasound Regions:Reference Pixel Y0	\N
1919	(0028,1102)	US	f	Green Palette Color Lookup Table Descriptor	\N
1990	(0018,6011)[<0>](0018,6014)	US	f	Sequence of Ultrasound Regions:Region Data Type	\N
1994	(0018,6011)[<0>](0018,6020)	SL	f	Sequence of Ultrasound Regions:Reference Pixel X0	\N
1910	(0040,1008)	ST	f	Confidentiality Code	\N
1920	(0028,1101)	US	f	Red Palette Color Lookup Table Descriptor	\N
1991	(0018,6011)[<0>](0018,6024)	US	f	Sequence of Ultrasound Regions:Physical Units X Direction	\N
1988	(0018,6011)[<0>](0018,6028)	FD	f	Sequence of Ultrasound Regions:Reference Pixel Physical Value X	\N
1921	(0018,1042)	TM	f	Contrast/Bolus Start Time	\N
1918	(0028,1103)	US	f	Blue Palette Color Lookup Table Descriptor	\N
932	(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1155)	UI	f	ROI Contour Sequence:Contour Sequence:Contour Image Sequence:Referenced SOP Instance UID	\N
540	(0018,9321)	SQ	f	CT Exposure Sequence	\N
4968	(2001,"Philips Imaging DD 001",9f)	US	t	Pixel Processing Kernel Size	k
5565	(2005,"Philips MR Imaging DD 006",73)	UN	t	Unknown	d
5566	(2005,"Philips MR Imaging DD 006",82)	UN	t	Unknown	d
1422	(0009,"GEMS_PETD_01",d2)	UI	t	image_set_id	d
97	(0008,0033)	TM	f	Content Time	\N
1246	(0018,0031)	LO	f	Radiopharmaceutical	\N
1024	(0040,0003)	TM	f	Scheduled Procedure Step Start Time	\N
543	(0038,0500)	LO	f	Patient State	\N
463	(0018,1050)	DS	f	Spatial Resolution	\N
967	(300a,00b0)[<0>](300a,00e0)	IS	f	Beam Sequence:Number of Compensators	\N
576	(0054,0013)	SQ	f	Energy Window Range Sequence	\N
81	(0018,1312)	CS	f	In-plane Phase Encoding Direction	\N
943	(300a,00b0)[<0>](300a,00c3)	ST	f	Beam Sequence:Beam Description	\N
3531	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",78)	IS	t	Presentation State Sequence:Unknown	d
976	(300a,00b0)[<0>](300a,0111)[<1>](300a,0134)	DS	f	Beam Sequence:Control Point Sequence:Cumulative Meterset Weight	\N
1186	(5004,0005)	UN	f	Curve Dimensions	\N
1412	(0088,0200)[<0>](0028,1201)	OW	f	Icon Image Sequence:Red Palette Color Lookup Table Data	\N
1180	(5002,3000)	UN	f	Curve Data	\N
1213	(0018,1010)	LO	f	Secondary Capture Device ID	\N
1187	(5008,0103)	UN	f	Data Value Representation	\N
1194	(5006,0103)	UN	f	Data Value Representation	\N
1224	(6000,3000)	OW	f	Overlay Data	\N
1261	(0008,1120)[<0>](0008,1155)	UI	f	Referenced Patient Sequence:Referenced SOP Instance UID	\N
1133	(0054,0410)[<0>](0054,0412)[<1>](0008,0104)	LO	f	Patient Orientation Code Sequence:Patient Orientation Modifier Code Sequence:Code Meaning	\N
7	(0018,1251)	SH	f	Transmit Coil Name	\N
721	(0054,1102)	CS	f	Decay Correction	\N
3532	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",7d)	IS	t	Presentation State Sequence:Unknown	d
104	(0008,0016)	UI	f	SOP Class UID	\N
118	(0028,0011)	US	f	Columns	\N
1470	(0008,9215)[<0>](0008,0102)	SH	f	Derivation Code Sequence:Coding Scheme Designator	\N
573	(0054,0016)[<0>](0054,0300)	SQ	f	Radiopharmaceutical Information Sequence:Radionuclide Code Sequence	\N
1340	(0054,0410)[<0>](0054,0412)[<1>](0008,0105)	CS	f	Patient Orientation Code Sequence:Patient Orientation Modifier Code Sequence:Mapping Resource	\N
1327	(0054,0016)[<0>](0018,1070)	LO	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Route	\N
1152	(0018,1082)	IS	f	High R-R Value	\N
2016	(3004,0050)[<0>](3004,0002)	CS	f	DVH Sequence:Dose Units	\N
2019	(3004,0050)[<0>](3004,0004)	CS	f	DVH Sequence:Dose Type	\N
1998	(3006,0080)[<0>](3006,0086)	SQ	f	RT ROI Observations Sequence:RT ROI Identification Code Sequence	\N
2008	(3004,0050)	SQ	f	DVH Sequence	\N
2000	(300e,0005)	TM	f	Review Time	\N
3526	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)[<2>](0070,0006)	ST	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence:Unformatted Text Value	d
3528	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",54)	ST	t	Presentation State Sequence:Unknown	d
3390	(0018,1403)	CS	f	Cassette Size	\N
3401	(0040,a370)[<0>](0008,1110)	SQ	f	Referenced Request Sequence:Referenced Study Sequence	\N
3395	(0040,a370)[<0>](0032,1064)[<1>](0008,0100)	SH	f	Referenced Request Sequence:Requested Procedure Code Sequence:Code Value	\N
3393	(0028,3010)[<0>](0028,3002)	US	f	VOI LUT Sequence:LUT Descriptor	\N
3400	(0040,a370)[<0>](0040,1001)	SH	f	Referenced Request Sequence:Requested Procedure ID	\N
3403	(0040,a370)[<0>](0032,1064)	SQ	f	Referenced Request Sequence:Requested Procedure Code Sequence	\N
3391	(0010,2203)	CS	f	Patient's Sex Neutered	\N
3533	(200b,"Philips RAD Imaging DD 001",05)	IS	t	Unknown	d
2007	(3004,0050)[<0>](3004,0060)	SQ	f	DVH Sequence:DVH Referenced ROI Sequence	\N
1308	(0008,9121)[<0>](0008,1155)	UI	f	Referenced Raw Data Sequence:Referenced SOP Instance UID	\N
2013	(3004,0050)[<0>](3004,0070)	DS	f	DVH Sequence:DVH Minimum Dose	\N
1997	(3006,0080)[<0>](3006,0086)[<1>](0008,0102)	SH	f	RT ROI Observations Sequence:RT ROI Identification Code Sequence:Coding Scheme Designator	\N
2015	(3004,0050)[<0>](3004,0052)	DS	f	DVH Sequence:DVH Dose Scaling	\N
2011	(3004,0050)[<0>](3004,0072)	DS	f	DVH Sequence:DVH Maximum Dose	\N
1995	(3006,0080)[<0>](3006,0085)	SH	f	RT ROI Observations Sequence:ROI Observation Label	\N
1164	(5000,3000)	UN	f	Curve Data	\N
584	(0018,1084)	IS	f	Intervals Rejected	\N
560	(3004,000e)	DS	f	Dose Grid Scaling	\N
1335	(0054,1200)	DS	f	Axial Acceptance	\N
1331	(0054,0414)[<0>](0008,0106)	DT	f	Patient Gantry Relationship Code Sequence:Context Group Version	\N
5567	(2005,"Philips MR Imaging DD 006",71)	UN	t	Unknown	d
945	(300a,0070)[<0>](300c,0004)	SQ	f	Fraction Group Sequence:Referenced Beam Sequence	\N
4059	(0051,"",12)	SH	t	Unknown	d
4056	(0029,"",20)	OB	t	Unknown	d
108	(0008,1110)[<0>](0008,1150)	UI	f	Referenced Study Sequence:Referenced SOP Class UID	\N
95	(0008,0030)	TM	f	Study Time	\N
927	(3006,0080)[<0>](3006,00a4)	CS	f	RT ROI Observations Sequence:RT ROI Interpreted Type	\N
12	(0020,1040)	LO	f	Position Reference Indicator	\N
11	(0040,0280)	ST	f	Comments on the Performed Procedure Step	\N
921	(3006,0039)[<0>](3006,0040)[<1>](3006,0050)	DS	f	ROI Contour Sequence:Contour Sequence:Contour Data	\N
936	(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](0020,000e)	UI	f	Referenced Frame of Reference Sequence:RT Referenced Study Sequence:RT Referenced Series Sequence:Series Instance UID	\N
1244	(0040,0555)[<0>](0040,a168)[<1>](0008,0104)	LO	f	Acquisition Context Sequence:Concept Code Sequence:Code Meaning	\N
1173	(5004,0022)	UN	f	Curve Description	\N
1431	(0018,a001)[<0>](0040,a170)[<1>](0008,0102)	SH	f	Contributing Equipment Sequence:Purpose of Reference Code Sequence:Coding Scheme Designator	\N
2043	(0064,0002)[<0>](0064,0005)	SQ	f	Deformable Registration Sequence:Deformable Registration Grid Sequence	\N
1442	(0018,a001)[<0>](0018,1000)	LO	f	Contributing Equipment Sequence:Device Serial Number	\N
2038	(0008,1200)[<0>](0008,1115)	SQ	f	Studies Containing Other Referenced Instances Sequence:Referenced Series Sequence	\N
2044	(0064,0002)[<0>](0070,0309)	SQ	f	Deformable Registration Sequence:Matrix Registration Sequence	\N
1185	(5004,0103)	UN	f	Data Value Representation	\N
2022	(3006,0020)[<0>](3006,0028)	ST	f	Structure Set ROI Sequence:ROI Description	\N
1426	(0088,0200)[<0>](0028,1102)	US	f	Icon Image Sequence:Green Palette Color Lookup Table Descriptor	\N
1407	(0088,0200)[<0>](0028,1102)	SS	f	Icon Image Sequence:Green Palette Color Lookup Table Descriptor	\N
2069	(0064,0002)[<0>](0008,1140)[<1>](0008,1150)	UI	f	Deformable Registration Sequence:Referenced Image Sequence:Referenced SOP Class UID	\N
2049	(0064,0002)[<0>](0008,1140)	SQ	f	Deformable Registration Sequence:Referenced Image Sequence	\N
1033	(0040,0002)	DA	f	Scheduled Procedure Step Start Date	\N
2039	(0064,0002)[<0>](0064,0010)	SQ	f	Deformable Registration Sequence:Post Deformation Matrix Registration Sequence	\N
1435	(0018,a001)[<0>](0008,0081)	ST	f	Contributing Equipment Sequence:Institution Address	\N
1409	(0088,0200)[<0>](7fe0,0010)	OW	f	Icon Image Sequence:Pixel Data	\N
2066	(0064,0002)[<0>](0064,0003)	UI	f	Deformable Registration Sequence:Source Frame of Reference UID	\N
2024	(3006,0080)[<0>](0008,0005)	CS	f	RT ROI Observations Sequence:Specific Character Set	\N
89	(0018,5100)	CS	f	Patient Position	\N
128	(0018,1041)	DS	f	Contrast/Bolus Volume	\N
164	(0018,1160)	SH	f	Filter Type	\N
2052	(0064,0002)[<0>](0064,0005)[<1>](0020,0032)	DS	f	Deformable Registration Sequence:Deformable Registration Grid Sequence:Image Position (Patient)	\N
1062	(300a,00b0)[<0>](300a,00f4)[<1>](300a,0104)	IS	f	Beam Sequence:Block Sequence:Block Number of Points	\N
657	(0054,0016)[<0>](0054,0300)[<1>](0008,0102)	SH	f	Radiopharmaceutical Information Sequence:Radionuclide Code Sequence:Coding Scheme Designator	\N
1200	(5004,0020)	UN	f	Type of Data	\N
2046	(0008,1115)[<0>](0008,114a)	SQ	f	Referenced Series Sequence:Referenced Instance Sequence	\N
18	(0008,103e)	LO	f	Series Description	\N
114	(0028,0103)	US	f	Pixel Representation	\N
8	(0008,1140)	SQ	f	Referenced Image Sequence	\N
2042	(0008,1200)	SQ	f	Studies Containing Other Referenced Instances Sequence	\N
2057	(0064,0002)[<0>](0064,0005)[<1>](0064,0009)	OF	f	Deformable Registration Sequence:Deformable Registration Grid Sequence:Vector Grid Data	\N
2036	(0064,0002)[<0>](0070,0309)[<1>](0070,030d)[<2>](0008,0100)	SH	f	Deformable Registration Sequence:Matrix Registration Sequence:Registration Type Code Sequence:Code Value	\N
2025	(3006,0020)[<0>](0008,0005)	CS	f	Structure Set ROI Sequence:Specific Character Set	\N
2055	(0064,0002)[<0>](0064,000f)[<1>](3006,00c6)	DS	f	Deformable Registration Sequence:Pre Deformation Matrix Registration Sequence:Frame of Reference Transformation Matrix	\N
2041	(0064,0002)[<0>](0070,0309)[<1>](0070,030a)	SQ	f	Deformable Registration Sequence:Matrix Registration Sequence:Matrix Sequence	\N
2040	(0064,0002)	SQ	f	Deformable Registration Sequence	\N
2021	(3006,0080)[<0>](3006,0088)	ST	f	RT ROI Observations Sequence:ROI Observation Description	\N
2047	(0064,0002)[<0>](0070,0309)[<1>](0070,030d)	SQ	f	Deformable Registration Sequence:Matrix Registration Sequence:Registration Type Code Sequence	\N
3410	(0008,2218)	SQ	f	Anatomic Region Sequence	\N
941	(300a,00b0)[<0>](300a,00b2)	SH	f	Beam Sequence:Treatment Machine Name	\N
202	(0028,1053)	DS	f	Rescale Slope	\N
1056	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00f5)	SH	f	Beam Sequence:Block Sequence:Block Tray ID	\N
3411	(0054,0220)	SQ	f	View Code Sequence	\N
4970	(2005,"Philips MR Imaging DD 004",71)		t	Series SP Mix	k
3537	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)[<2>](0070,0014)	FL	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence:Anchor Point	d
369	(0028,0120)	US	f	Pixel Padding Value	\N
276	(0028,0120)	SS	f	Pixel Padding Value	\N
31	(0020,0012)	IS	f	Acquisition Number	\N
1243	(0040,0555)[<0>](0040,a168)[<1>](0008,0102)	SH	f	Acquisition Context Sequence:Concept Code Sequence:Coding Scheme Designator	\N
83	(0018,0021)	CS	f	Sequence Variant	\N
977	(300a,00b0)[<0>](300a,0111)[<1>](300a,0130)	DS	f	Beam Sequence:Control Point Sequence:Source to Surface Distance	\N
28	(0020,0013)	IS	f	Instance Number	\N
994	(300a,00b0)[<0>](300a,00b6)[<1>](300a,00b8)	CS	f	Beam Sequence:Beam Limiting Device Sequence:RT Beam Limiting Device Type	\N
76	(0008,0005)	CS	f	Specific Character Set	\N
1441	(0018,a001)[<0>](0018,1020)	LO	f	Contributing Equipment Sequence:Software Version(s)	\N
1080	(0008,9123)	UI	f	Creator-Version UID	\N
385	(0018,1094)	IS	f	Trigger Window	\N
1	(0018,0085)	SH	f	Imaged Nucleus	\N
679	(0054,0016)[<0>](0018,0031)	LO	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical	\N
940	(300a,0040)[<0>](300a,0043)	SH	f	Tolerance Table Sequence:Tolerance Table Label	\N
125	(0008,0023)	DA	f	Content Date	\N
77	(0028,0303)	CS	f	Longitudinal Temporal Information Modified	\N
119	(0028,0101)	US	f	Bits Stored	\N
998	(300a,00b0)[<0>](300a,00c6)	CS	f	Beam Sequence:Radiation Type	\N
658	(0054,0414)[<0>](0008,0102)	SH	f	Patient Gantry Relationship Code Sequence:Coding Scheme Designator	\N
1225	(0008,0064)	CS	f	Conversion Type	\N
900	(0018,1200)	DA	f	Date of Last Calibration	\N
892	(0032,1064)[<0>](0008,0102)	SH	f	Requested Procedure Code Sequence:Coding Scheme Designator	\N
720	(0054,1001)	CS	f	Units	\N
178	(0018,1040)	LO	f	Contrast/Bolus Route	\N
722	(0054,1000)	CS	f	Series Type	\N
1245	(0040,0555)[<0>](0040,a043)[<1>](0008,0104)	LO	f	Acquisition Context Sequence:Concept Name Code Sequence:Code Meaning	\N
47	(0028,0030)	DS	f	Pixel Spacing	\N
5371	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)[<2>](0070,030d)	SQ	t	Unknown:Registration Sequence:Matrix Registration Sequence:Registration Type Code Sequence	d
915	(3006,0080)[<0>](3006,0082)	IS	f	RT ROI Observations Sequence:Observation Number	\N
5570	(2005,"Philips MR Imaging DD 005",52)	UN	t	Original Series Instance UID	h
734	(0054,1330)	US	f	Image Index	\N
2092	(300a,0010)[<0>](300a,0026)	DS	f	Dose Reference Sequence:Target Prescription Dose	\N
2097	(300a,0010)[<0>](300a,0014)	CS	f	Dose Reference Sequence:Dose Reference Structure Type	\N
2093	(300a,0010)[<0>](300a,0023)	DS	f	Dose Reference Sequence:Delivery Maximum Dose	\N
2083	(300a,0010)[<0>](300a,0012)	IS	f	Dose Reference Sequence:Dose Reference Number	\N
2080	(300a,00b0)[<0>](300a,0111)[<1>](300c,0050)[<2>](300c,0051)	IS	f	Beam Sequence:Control Point Sequence:Referenced Dose Reference Sequence:Referenced Dose Reference Number	\N
2099	(300a,00b0)[<0>](3002,0050)[<1>](3002,0051)	CS	f	Beam Sequence:Primary Fluence Mode Sequence:Fluence Mode	\N
2088	(300a,0040)[<0>](300a,0048)[<1>](300a,004a)	DS	f	Tolerance Table Sequence:Beam Limiting Device Tolerance Sequence:Beam Limiting Device Position Tolerance	\N
2098	(300a,0180)[<0>](300a,01b0)	CS	f	Patient Setup Sequence:Setup Technique	\N
2082	(300a,00b0)[<0>](300c,0042)[<1>](300a,00c8)	IS	f	Beam Sequence:Referenced Reference Image Sequence:Reference Image Number	\N
2076	(300a,00b0)[<0>](300a,0111)[<1>](300c,0050)	SQ	f	Beam Sequence:Control Point Sequence:Referenced Dose Reference Sequence	\N
2101	(300a,0010)[<0>](300a,0013)	UI	f	Dose Reference Sequence:Dose Reference UID	\N
2096	(300a,0010)[<0>](300a,0020)	CS	f	Dose Reference Sequence:Dose Reference Type	\N
2085	(300a,0040)[<0>](300a,004c)	DS	f	Tolerance Table Sequence:Patient Support Angle Tolerance	\N
2086	(300a,0040)[<0>](300a,0044)	DS	f	Tolerance Table Sequence:Gantry Angle Tolerance	\N
2079	(300a,0010)[<0>](300a,0016)	LO	f	Dose Reference Sequence:Dose Reference Description	\N
2078	(300a,00b0)[<0>](0008,1090)	LO	f	Beam Sequence:Manufacturer's Model Name	\N
2081	(300a,0070)[<0>](300a,0079)	IS	f	Fraction Group Sequence:Number of Fraction Pattern Digits Per Day	\N
2091	(300a,0010)[<0>](300a,0027)	DS	f	Dose Reference Sequence:Target Maximum Dose	\N
2073	(300a,0010)	SQ	f	Dose Reference Sequence	\N
2077	(300a,0180)[<0>](300a,01b2)	ST	f	Patient Setup Sequence:Setup Technique Description	\N
2102	(300a,00b0)[<0>](300c,0042)[<1>](0008,1150)	UI	f	Beam Sequence:Referenced Reference Image Sequence:Referenced SOP Class UID	\N
2094	(300a,0040)[<0>](300a,0051)	DS	f	Tolerance Table Sequence:Table Top Vertical Position Tolerance	\N
5573	(2005,"Philips MR Imaging DD 006",72)	UN	t	Unknown	d
5572	(2005,"Philips MR Imaging DD 006",66)	UN	t	Unknown	d
2948	(0018,1400)	LO	f	Acquisition Device Processing Description	\N
3545	(200b,"Philips RAD Imaging DD 001",27)	DT	t	Unknown	d
2056	(0064,0002)[<0>](0064,0010)[<1>](3006,00c6)	DS	f	Deformable Registration Sequence:Post Deformation Matrix Registration Sequence:Frame of Reference Transformation Matrix	\N
2001	(300e,0004)	DA	f	Review Date	\N
3550	(200b,"Philips RAD Imaging DD 001",4c)	SH	t	Unknown	d
3544	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",02)	SS	t	Presentation State Sequence:Unknown	d
2874	(0020,1206)	IS	f	Number of Study Related Series	\N
3549	(2001,"Philips Imaging DD 001",6e)	SH	t	Series Type	d
5569	(2005,"Philips MR Imaging DD 006",75)	UN	t	Unknown	d
3419	(0028,1041)	SS	f	Pixel Intensity Relationship Sign	\N
3415	(0018,7010)	IS	f	Exposures on Detector Since Last Calibration	\N
3422	(0054,0220)[<0>](0008,0100)	SH	f	View Code Sequence:Code Value	\N
3551	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",82)	LO	t	Presentation State Sequence:Unknown	d
3416	(0018,1702)	IS	f	Collimator Left Vertical Edge	\N
5576	(2005,"Philips MR Imaging DD 006",59)	UN	t	Unknown	d
3808	(0029,"",60)	UN	t	Unknown	d
3540	(200b,"Philips RAD Imaging DD 097",9f)[<0>](0008,0018)	UI	t	Unknown:SOP Instance UID	d
5575	(0018,1320)	UN	f	B1rms	\N
2018	(3004,0050)[<0>](3004,0001)	CS	f	DVH Sequence:DVH Type	\N
2023	(3006,0039)[<0>](3006,0040)[<1>](3006,0048)	IS	f	ROI Contour Sequence:Contour Sequence:Contour Number	\N
2060	(0064,0002)[<0>](0064,0010)[<1>](0070,030c)	CS	f	Deformable Registration Sequence:Post Deformation Matrix Registration Sequence:Frame of Reference Transformation Matrix Type	\N
2012	(3004,0050)[<0>](3004,0074)	DS	f	DVH Sequence:DVH Mean Dose	\N
5579	(2005,"Philips MR Imaging DD 006",54)	UN	t	Unknown	d
5577	(2005,"Philips MR Imaging DD 006",55)	UN	t	Unknown	d
5578	(2005,"Philips MR Imaging DD 006",56)	UN	t	Unknown	d
2017	(3004,0050)[<0>](3004,0054)	CS	f	DVH Sequence:DVH Volume Units	\N
5430	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0064,0005)[<2>](0020,0037)	DS	t	Unknown:Deformable Registration Sequence:Deformable Registration Grid Sequence:Image Orientation (Patient)	d
5580	(2005,"Philips MR Imaging DD 006",61)	UN	t	Unknown	d
5581	(2005,"Philips MR Imaging DD 006",58)	UN	t	Unknown	d
1282	(0009,"GEMS_IDEN_01",68)	UN	t	Unknown	d
2949	(0018,6000)	DS	f	Sensitivity	\N
5431	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0064,0005)[<2>](0064,0009)	OF	t	Unknown:Deformable Registration Sequence:Deformable Registration Grid Sequence:Vector Grid Data	d
3653	(0011,"GEMS_GDXE_FALCON_04",72)	UN	t	Unknown	d
2068	(0008,1200)[<0>](0008,1115)[<1>](0008,114a)[<2>](0008,1150)	UI	f	Studies Containing Other Referenced Instances Sequence:Referenced Series Sequence:Referenced Instance Sequence:Referenced SOP Class UID	\N
2051	(0064,0002)[<0>](0070,0309)[<1>](0070,030d)[<2>](0008,0104)	LO	f	Deformable Registration Sequence:Matrix Registration Sequence:Registration Type Code Sequence:Code Meaning	\N
1486	(3002,0022)	DS	f	Radiation Machine SAD	\N
1487	(0040,030e)[<0>](0018,9346)	SQ	f	Exposure Dose Sequence:CTDI Phantom Type Code Sequence	\N
1488	(0040,030e)[<0>](0018,0060)	DS	f	Exposure Dose Sequence:KVP	\N
1492	(0070,005a)[<0>](0008,1140)[<1>](0008,1150)	UI	f	Displayed Area Selection Sequence:Referenced Image Sequence:Referenced SOP Class UID	\N
1496	(300a,0125)	DS	f	Table Top Eccentric Angle	\N
1497	(0070,0060)[<0>](0070,0002)	CS	f	Graphic Layer Sequence:Graphic Layer	\N
1498	(3002,0026)	DS	f	RT Image SID	\N
2084	(300a,00b0)[<0>](300a,0111)[<1>](300c,0050)[<2>](300a,010c)	DS	f	Beam Sequence:Control Point Sequence:Referenced Dose Reference Sequence:Cumulative Dose Reference Coefficient	\N
308	(0019,"GEMS_ACQU_01",71)	SS	t	SetIfFatqEstimatesWereUsed	k
2869	(01f3,"ELSCINT1",17)	OB	t	Unknown	d
1504	(0040,030e)[<0>](0018,9346)[<1>](0008,0100)	SH	f	Exposure Dose Sequence:CTDI Phantom Type Code Sequence:Code Value	\N
1506	(0070,005a)[<0>](0008,1140)[<1>](0008,1155)	UI	f	Displayed Area Selection Sequence:Referenced Image Sequence:Referenced SOP Instance UID	\N
1507	(0040,030e)[<0>](0018,9302)	CS	f	Exposure Dose Sequence:Acquisition Type	\N
1508	(0028,3110)[<0>](0008,1140)	SQ	f	Softcopy VOI LUT Sequence:Referenced Image Sequence	\N
1511	(0040,030e)[<0>](0018,9346)[<1>](0008,0104)	LO	f	Exposure Dose Sequence:CTDI Phantom Type Code Sequence:Code Meaning	\N
1512	(0040,030e)[<0>](0018,9307)	FD	f	Exposure Dose Sequence:Total Collimation Width	\N
1513	(0028,3110)[<0>](0028,1050)	DS	f	Softcopy VOI LUT Sequence:Window Center	\N
1517	(3002,0012)	DS	f	RT Image Position	\N
1518	(300c,0002)[<0>](300c,0020)[<1>](300c,0004)	SQ	f	Referenced RT Plan Sequence:Referenced Fraction Group Sequence:Referenced Beam Sequence	\N
1521	(300a,0120)	DS	f	Beam Limiting Device Angle	\N
1526	(3002,000e)	DS	f	X-Ray Image Receptor Angle	\N
1528	(300a,0122)	DS	f	Patient Support Angle	\N
1533	(0008,1115)[<0>](0020,000e)	UI	f	Referenced Series Sequence:Series Instance UID	\N
1537	(0008,1115)[<0>](0008,1140)[<1>](0008,1150)	UI	f	Referenced Series Sequence:Referenced Image Sequence:Referenced SOP Class UID	\N
1538	(300c,0002)[<0>](300c,0020)	SQ	f	Referenced RT Plan Sequence:Referenced Fraction Group Sequence	\N
1539	(0070,0082)	DA	f	Presentation Creation Date	\N
1542	(0070,005a)[<0>](0070,0101)	DS	f	Displayed Area Selection Sequence:Presentation Pixel Spacing	\N
1546	(0028,3110)	SQ	f	Softcopy VOI LUT Sequence	\N
1547	(3002,000c)	CS	f	RT Image Plane	\N
1549	(0040,0555)[<0>](0008,0102)	SH	f	Acquisition Context Sequence:Coding Scheme Designator	\N
1552	(0070,005a)	SQ	f	Displayed Area Selection Sequence	\N
1553	(3002,0002)	SH	f	RT Image Label	\N
1554	(0040,030e)[<0>](0018,9306)	FD	f	Exposure Dose Sequence:Single Collimation Width	\N
1556	(0040,0555)[<0>](0008,0100)	SH	f	Acquisition Context Sequence:Code Value	\N
1558	(0040,0260)[<0>](0008,0103)	SH	f	Performed Protocol Code Sequence:Coding Scheme Version	\N
1563	(0020,1208)	IS	f	Number of Study Related Instances	\N
1565	(0040,0310)	ST	f	Comments on Radiation Dose	\N
1570	(0070,0081)	LO	f	Content Description	\N
1573	(300a,011e)	DS	f	Gantry Angle	\N
1582	(0040,030e)[<0>](0018,9311)	FD	f	Exposure Dose Sequence:Spiral Pitch Factor	\N
1996	(3006,0080)[<0>](3006,0086)[<1>](0008,0100)	SH	f	RT ROI Observations Sequence:RT ROI Identification Code Sequence:Code Value	\N
2089	(300a,0040)[<0>](300a,0053)	DS	f	Tolerance Table Sequence:Table Top Lateral Position Tolerance	\N
3426	(0054,0220)[<0>](0008,0102)	SH	f	View Code Sequence:Coding Scheme Designator	\N
3437	(0018,7014)	DS	f	Detector Active Time	\N
3575	(200b,"Philips RAD Imaging DD 001",2e)	UN	t	Unknown	d
3430	(0018,702b)	LO	f	Detector Manufacturer's Model Name	\N
3425	(0008,2218)[<0>](0008,0102)	SH	f	Anatomic Region Sequence:Coding Scheme Designator	\N
3428	(0018,702a)	LO	f	Detector Manufacturer Name	\N
3586	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",0c)	LO	t	Unknown	d
3573	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",72)	FD	t	Presentation State Sequence:Unknown	d
3924	(0021,"",82)	UN	t	Unknown	d
835	(01f7,"ELSCINT1",95)	UN	t	Unknown	d
2947	(0018,1401)	LO	f	Acquisition Device Processing Code	\N
2896	(00e1,"ELSCINT1",39)[<0>](0008,1032)[<1>](0008,0100)	SH	t	Unknown:Procedure Code Sequence:Code Value	d
1999	(3006,0080)[<0>](3006,0086)[<1>](0008,0104)	LO	f	RT ROI Observations Sequence:RT ROI Identification Code Sequence:Code Meaning	\N
2062	(0064,0002)[<0>](0008,1140)[<1>](0008,1155)	UI	f	Deformable Registration Sequence:Referenced Image Sequence:Referenced SOP Instance UID	\N
2059	(0064,0002)[<0>](0070,0309)[<1>](0070,030a)[<2>](0070,030c)	CS	f	Deformable Registration Sequence:Matrix Registration Sequence:Matrix Sequence:Frame of Reference Transformation Matrix Type	\N
1588	(0040,0301)	US	f	Total Number of Exposures	\N
1590	(0040,030e)[<0>](0018,9346)[<1>](0008,0102)	SH	f	Exposure Dose Sequence:CTDI Phantom Type Code Sequence:Coding Scheme Designator	\N
1592	(0070,0084)	PN	f	Content Creator's Name	\N
2950	(0018,1164)	DS	f	Imager Pixel Spacing	\N
2830	(01f7,"ELSCINT1",74)	OB	t	Unknown	d
3214	(2010,0100)	CS	f	Border Density	\N
1596	(0040,0555)[<0>](0008,0104)	LO	f	Acquisition Context Sequence:Code Meaning	\N
3111	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",34)	OB	t	Unknown:Unknown	d
2014	(3004,0050)[<0>](3004,0058)	DS	f	DVH Sequence:DVH Data	\N
1600	(300c,0002)[<0>](300c,0020)[<1>](300c,0022)	IS	f	Referenced RT Plan Sequence:Referenced Fraction Group Sequence:Referenced Fraction Group Number	\N
1601	(3002,0020)	SH	f	Radiation Machine Name	\N
1603	(0070,0083)	TM	f	Presentation Creation Time	\N
1605	(300c,0006)	IS	f	Referenced Beam Number	\N
1608	(0040,030e)[<0>](0018,8151)	DS	f	Exposure Dose Sequence:X-Ray Tube Current in ÂµA	\N
1611	(7fe0,0010)	OB	f	Pixel Data	\N
1612	(0070,005a)[<0>](0070,0100)	CS	f	Displayed Area Selection Sequence:Presentation Size Mode	\N
1613	(0028,3110)[<0>](0028,1051)	DS	f	Softcopy VOI LUT Sequence:Window Width	\N
1619	(0070,0060)[<0>](0070,0062)	IS	f	Graphic Layer Sequence:Graphic Layer Order	\N
1623	(0028,3110)[<0>](0008,1140)[<1>](0008,1155)	UI	f	Softcopy VOI LUT Sequence:Referenced Image Sequence:Referenced SOP Instance UID	\N
1625	(3002,0024)	DS	f	Radiation Machine SSD	\N
1626	(0040,030e)[<0>](0018,0015)	CS	f	Exposure Dose Sequence:Body Part Examined	\N
1629	(0070,005a)[<0>](0008,1140)	SQ	f	Displayed Area Selection Sequence:Referenced Image Sequence	\N
1632	(0018,9321)[<0>](0018,9445)	FD	f	CT Exposure Sequence:<undef>	\N
1637	(3002,0011)	DS	f	Image Plane Pixel Spacing	\N
1638	(0070,0080)	CS	f	Content Label	\N
1641	(0070,005a)[<0>](0070,0103)	FL	f	Displayed Area Selection Sequence:Presentation Pixel Magnification Ratio	\N
1642	(2050,0020)	CS	f	Presentation LUT Shape	\N
1643	(300a,00b0)[<0>](300a,00f2)	DS	f	Beam Sequence:Total Block Tray Factor	\N
1646	(300c,0002)[<0>](300c,0020)[<1>](300c,0004)[<2>](300c,0006)	IS	f	Referenced RT Plan Sequence:Referenced Fraction Group Sequence:Referenced Beam Sequence:Referenced Beam Number	\N
1656	(0040,2017)	LO	f	Filler Order Number / Imaging Service Request	\N
1657	(0070,005a)[<0>](0070,0053)	SL	f	Displayed Area Selection Sequence:Displayed Area Bottom Right Hand Corner	\N
1658	(0040,030e)[<0>](0018,9345)	FD	f	Exposure Dose Sequence:CTDIvol	\N
1660	(0070,005a)[<0>](0070,0052)	SL	f	Displayed Area Selection Sequence:Displayed Area Top Left Hand Corner	\N
1662	(0028,3110)[<0>](0008,1140)[<1>](0008,1150)	UI	f	Softcopy VOI LUT Sequence:Referenced Image Sequence:Referenced SOP Class UID	\N
2075	(300a,0040)[<0>](300a,0048)	SQ	f	Tolerance Table Sequence:Beam Limiting Device Tolerance Sequence	\N
1667	(0040,030e)	SQ	f	Exposure Dose Sequence	\N
1669	(300a,00b3)	CS	f	Primary Dosimeter Unit	\N
2053	(0064,0002)[<0>](0064,0005)[<1>](0020,0037)	DS	f	Deformable Registration Sequence:Deformable Registration Grid Sequence:Image Orientation (Patient)	\N
2054	(0064,0002)[<0>](0070,0309)[<1>](0070,030a)[<2>](3006,00c6)	DS	f	Deformable Registration Sequence:Matrix Registration Sequence:Matrix Sequence:Frame of Reference Transformation Matrix	\N
2009	(3004,0050)[<0>](3004,0056)	IS	f	DVH Sequence:DVH Number of Bins	\N
2095	(300a,0040)[<0>](300a,0048)[<1>](300a,00b8)	CS	f	Tolerance Table Sequence:Beam Limiting Device Tolerance Sequence:RT Beam Limiting Device Type	\N
2010	(3004,0050)[<0>](3004,0060)[<1>](3006,0084)	IS	f	DVH Sequence:DVH Referenced ROI Sequence:Referenced ROI Number	\N
2074	(300a,00b0)[<0>](300c,0042)	SQ	f	Beam Sequence:Referenced Reference Image Sequence	\N
1673	(0008,1115)[<0>](0008,1140)[<1>](0008,1155)	UI	f	Referenced Series Sequence:Referenced Image Sequence:Referenced SOP Instance UID	\N
1677	(0008,1115)[<0>](0008,1140)	SQ	f	Referenced Series Sequence:Referenced Image Sequence	\N
1678	(0040,030e)[<0>](0018,1150)	IS	f	Exposure Dose Sequence:Exposure Time	\N
1680	(0070,0060)	SQ	f	Graphic Layer Sequence	\N
3446	(0008,2218)[<0>](0008,0105)	CS	f	Anatomic Region Sequence:Mapping Resource	\N
3438	(0018,7006)	LT	f	Detector Description	\N
3451	(0040,0303)	US	f	Exposed Area	\N
4325	(0008,9206)	CS	f	Volumetric Properties	\N
4993	(0028,3003)	LO	f	LUT Explanation	\N
4996	(0018,9036)	CS	f	Partial Fourier Direction	\N
3601	(0019,"SIEMENS MR HEADER",17)	UN	t	Slice Resolution	k
3602	(0019,"SIEMENS MR HEADER",09)	UN	t	Unknown	d
3593	(0051,"SIEMENS MR HEADER",0a)	UN	t	Unknown	d
4317	(0032,1064)[<0>](0008,0103)	SH	f	Requested Procedure Code Sequence:Coding Scheme Version	\N
3609	(0051,"SIEMENS MR HEADER",12)	UN	t	Unknown	d
3620	(0019,"SIEMENS MR HEADER",0c)	UN	t	B Value	k
3596	(0051,"SIEMENS MR HEADER",0e)	UN	t	Unknown	d
3608	(0051,"SIEMENS MR HEADER",11)	UN	t	Unknown	d
4989	(0028,9001)	UL	f	Data Point Rows	\N
4999	(0018,9016)	CS	f	Spoiling	\N
4995	(0008,9205)	CS	f	Pixel Presentation	\N
4992	(0018,9005)	SH	f	Pulse Sequence Name	\N
4997	(0018,9033)	CS	f	Segmented k-Space Traversal	\N
4994	(0018,9094)	CS	f	Coverage of k-Space	\N
3622	(0029,"MITRA MARKUP 1.0",03)	UN	t	Markup4	d
1685	(3002,000d)	DS	f	X-Ray Image Receptor Translation	\N
1389	(01f7,"ELSCINT1",74)	OW	t	Unknown	d
1688	(0008,1115)	SQ	f	Referenced Series Sequence	\N
2995	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
1695	(0040,0260)[<0>](0008,0104)	LO	f	Performed Protocol Code Sequence:Code Meaning	\N
2048	(0008,1200)[<0>](0008,1115)[<1>](0008,114a)	SQ	f	Studies Containing Other Referenced Instances Sequence:Referenced Series Sequence:Referenced Instance Sequence	\N
2067	(0008,1115)[<0>](0008,114a)[<1>](0008,1150)	UI	f	Referenced Series Sequence:Referenced Instance Sequence:Referenced SOP Class UID	\N
2072	(300a,00b0)[<0>](3002,0050)	SQ	f	Beam Sequence:Primary Fluence Mode Sequence	\N
2070	(0008,1200)[<0>](0008,1115)[<1>](0020,000e)	UI	f	Studies Containing Other Referenced Instances Sequence:Referenced Series Sequence:Series Instance UID	\N
1903	(0040,9096)[<0>](0040,9224)	FD	f	Real World Value Mapping Sequence:Real World Value Intercept	\N
2064	(0008,1115)[<0>](0008,114a)[<1>](0008,1155)	UI	f	Referenced Series Sequence:Referenced Instance Sequence:Referenced SOP Instance UID	\N
2087	(300a,0040)[<0>](300a,0046)	DS	f	Tolerance Table Sequence:Beam Limiting Device Angle Tolerance	\N
2063	(0008,1200)[<0>](0008,1115)[<1>](0008,114a)[<2>](0008,1155)	UI	f	Studies Containing Other Referenced Instances Sequence:Referenced Series Sequence:Referenced Instance Sequence:Referenced SOP Instance UID	\N
1902	(0040,9096)[<0>](0040,9225)	FD	f	Real World Value Mapping Sequence:Real World Value Slope	\N
1901	(0008,1140)[<0>](0040,a170)[<1>](0008,0104)	LO	f	Referenced Image Sequence:Purpose of Reference Code Sequence:Code Meaning	\N
5587	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",9a)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Referenced Frames Sequence	k
2045	(0064,0002)[<0>](0064,000f)	SQ	f	Deformable Registration Sequence:Pre Deformation Matrix Registration Sequence	\N
3211	(2010,0030)	CS	f	Annotation Display Format ID	\N
5676	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",93)[<4>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",94)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Evaluation Sequence:Measurement Evaluation Value	k
27	(0013,"CTP",10)	LO	t	Project Name	k
2061	(0064,0002)[<0>](0064,0005)[<1>](0064,0008)	FD	f	Deformable Registration Sequence:Deformable Registration Grid Sequence:Grid Resolution	\N
886	(0043,"GEMS_PARM_01",91)	DS	t	SAR Value	k
3113	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",72)	OB	t	Unknown:Unknown	d
3803	(0033,"",0c)	UN	t	Unknown	d
3800	(0033,"",04)	UN	t	Unknown	d
3784	(0043,"GEMS_PARM_01",a5)	UN	t	Duration of the label or control pulse	d
5393	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0071,"BLACKFORD",02)[<2>](0028,0030)	DS	t	Unknown:Unknown:Unknown:Pixel Spacing	d
4328	(0018,1411)	CS	f	Exposure Index	\N
4545	(0043,"GEMS_PARM_01",b1)	UN	t	Unknown	d
5349	(0077,"TERARECON AQUARIUS",98)	UN	t	Unknown	d
2065	(0008,1200)[<0>](0020,000d)	UI	f	Studies Containing Other Referenced Instances Sequence:Study Instance UID	\N
2090	(300a,0040)[<0>](300a,0052)	DS	f	Tolerance Table Sequence:Table Top Longitudinal Position Tolerance	\N
2020	(3004,0050)[<0>](3004,0060)[<1>](3004,0062)	CS	f	DVH Sequence:DVH Referenced ROI Sequence:DVH ROI Contribution Type	\N
2058	(0064,0002)[<0>](0064,000f)[<1>](0070,030c)	CS	f	Deformable Registration Sequence:Pre Deformation Matrix Registration Sequence:Frame of Reference Transformation Matrix Type	\N
2100	(300a,00b0)[<0>](300c,0042)[<1>](0008,1155)	UI	f	Beam Sequence:Referenced Reference Image Sequence:Referenced SOP Instance UID	\N
2050	(0064,0002)[<0>](0064,0005)[<1>](0064,0007)	UL	f	Deformable Registration Sequence:Deformable Registration Grid Sequence:Grid Dimensions	\N
2037	(0064,0002)[<0>](0070,0309)[<1>](0070,030d)[<2>](0008,0102)	SH	f	Deformable Registration Sequence:Matrix Registration Sequence:Registration Type Code Sequence:Coding Scheme Designator	\N
5013	(0018,9026)	CS	f	Spectrally Selected Excitation	\N
5003	(0018,9081)	CS	f	Partial Fourier	\N
5014	(0018,9008)	CS	f	Echo Pulse Sequence	\N
5006	(0018,9011)	CS	f	Multiple Spin Echo	\N
5004	(0018,9012)	CS	f	Multi-planar Excitation	\N
5009	(0018,9059)	CS	f	De-coupling	\N
5011	(0018,9021)	CS	f	T2 Preparation	\N
3472	(0040,a730)[<0>](0040,a730)[<1>](0040,a050)	CS	f	Content Sequence:Content Sequence:Continuity Of Content	\N
3470	(0040,a493)	CS	f	Verification Flag	\N
3467	(0040,a730)[<0>](0040,a730)[<1>](0040,a010)	CS	f	Content Sequence:Content Sequence:Relationship Type	\N
4334	(0018,8151)	DS	f	X-Ray Tube Current in ÂµA	\N
4329	(0018,1413)	CS	f	Deviation Index	\N
3463	(0040,a730)[<0>](0040,a730)[<1>](0040,a043)[<2>](0008,0104)	LO	f	Content Sequence:Content Sequence:Concept Name Code Sequence:Code Meaning	\N
3468	(0040,a730)[<0>](0040,a050)	CS	f	Content Sequence:Continuity Of Content	\N
3455	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a043)[<3>](0008,0100)	SH	f	Content Sequence:Content Sequence:Content Sequence:Concept Name Code Sequence:Code Value	\N
4330	(0018,1412)	CS	f	Target Exposure Index	\N
5000	(0018,9034)	CS	f	Rectilinear Phase Encode Reordering	\N
5001	(0018,9014)	CS	f	Phase Contrast	\N
4332	(0018,5021)	LO	f	Postprocessing Function	\N
5005	(0018,9024)	CS	f	Saturation Recovery	\N
4333	(0018,8150)	DS	f	Exposure Time in ÂµS	\N
4331	(0018,5020)	LO	f	Processing Function	\N
4505	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",03)	UN	t	Unknown	d
3303	(0019,"SIEMENS CT VA0  COAD",b0)	OB	t	Feed per Rotation	k
3304	(0019,"SIEMENS CT VA0  COAD",92)	OB	t	OsteoRegressionLineSlope	k
253	(0043,"GEMS_PARM_01",44)	SL	t	DASOutputSource	k
5414	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0071,"BLACKFORD",02)[<2>](0028,0011)	US	t	Unknown:Unknown:Unknown:Columns	d
3305	(0019,"SIEMENS CT VA0  COAD",90)	OB	t	OsteoOffset	k
3813	(0051,"",19)	UN	t	Unknown	d
5386	(0071,"BLACKFORD",04)[<0>](0020,0011)	IS	t	Unknown:Series Number	d
3306	(0019,"SIEMENS CT VA0  COAD",96)	OB	t	OsteoPhantomNumber	k
3821	(0051,"",0a)	UN	t	Unknown	d
3307	(0019,"SIEMENS CT VA0  COAD",93)	OB	t	OsteoRegressionLineIntercept	k
3308	(0035,"AGFA STUDY COMMENTS 1.0",00)	LT	t	Unknown	d
3309	(0021,"SIEMENS MED",11)	OB	t	Target	k
3819	(0019,"",0f)	UN	t	Unknown	d
3311	(0029,"MITRA PRESENTATION 1.0",12)	CS	t	Unknown	d
3312	(0029,"MITRA PRESENTATION 1.0",10)	CS	t	Unknown	d
5591	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",b5)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Evaluation Text Position Sequence	k
5388	(0071,"BLACKFORD",04)[<0>](0010,0010)	PN	t	Unknown:Patient's Name	d
3313	(0029,"MITRA PRESENTATION 1.0",11)	CS	t	Unknown	d
5589	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence	K
3352	(0035,"AGFA KOSD 1.0",01)	UN	t	Unknown	d
3369	(0029,"MITRA PRESENTATION 1.0",10)	UN	t	Unknown	d
3370	(0029,"MITRA PRESENTATION 1.0",11)	UN	t	Unknown	d
3373	(0019,"Agfa ADC NX",fa)	IS	t	Unknown	d
3374	(0019,"Agfa ADC NX",fb)	FL	t	Unknown	d
3375	(0019,"Agfa ADC NX",21)	FL	t	Unknown	d
3380	(0019,"Agfa ADC NX",f6)	DS	t	Plate Sensitivity	k
3382	(0019,"Agfa ADC NX",f7)	DS	t	Plate Erasability	k
3384	(0019,"Agfa ADC NX",fd)	CS	t	Unknown	d
3385	(0019,"Agfa ADC NX",28)	CS	t	Unknown	d
3387	(0019,"Agfa ADC NX",07)	CS	t	Unknown	d
3389	(0019,"Agfa ADC NX",fe)	CS	t	Unknown	d
3394	(0035,"AGFA STUDY COMMENTS 1.0",00)	UN	t	Unknown	d
3409	(0029,"MITRA MARKUP 1.0",05)	UN	t	Markup6	d
3512	(0018,7060)	CS	f	Exposure Control Mode	\N
5590	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)	SQ	t	Advanced Presentation Sequence	k
5683	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",93)[<4>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",95)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Evaluation Sequence:Measurement Evaluation ID	k
437	(0043,"GEMS_PARM_01",04)	SS	t	GradientOffsetInZ	k
3822	(0051,"",0b)	UN	t	Unknown	d
363	(0045,"GEMS_HELIOS_01",21)	SS	t	Iterbone Flag	k
2813	(01f7,"ELSCINT1",11)	OB	t	Unknown	d
472	(0019,"GEMS_ACQU_01",aa)	DS	t	UserData	d
3884	(0021,"",59)	UN	t	Unknown	d
3816	(0051,"",08)	UN	t	Unknown	d
3322	(0040,a730)[<0>](0008,1199)	SQ	f	Content Sequence:Referenced SOP Sequence	\N
3440	(0028,1040)	CS	f	Pixel Intensity Relationship	\N
3423	(0018,700a)	SH	f	Detector ID	\N
3404	(0040,a370)[<0>](0032,1060)	LO	f	Referenced Request Sequence:Requested Procedure Description	\N
3421	(0008,2218)[<0>](0008,0106)	DT	f	Anatomic Region Sequence:Context Group Version	\N
3405	(0040,a370)[<0>](0032,1064)[<1>](0008,0104)	LO	f	Referenced Request Sequence:Requested Procedure Code Sequence:Code Meaning	\N
3392	(0028,3010)[<0>](0028,3006)	US	f	VOI LUT Sequence:LUT Data	\N
3397	(0040,a370)[<0>](0040,2017)	SH	f	Referenced Request Sequence:Filler Order Number / Imaging Service Request	\N
3341	(0040,a730)[<0>](0008,1199)[<1>](0008,1155)	UI	f	Content Sequence:Referenced SOP Sequence:Referenced SOP Instance UID	\N
3337	(0040,a504)[<0>](0008,0105)	CS	f	Content Template Sequence:Mapping Resource	\N
3435	(0040,8302)	DS	f	Entrance Dose in mGy	\N
3427	(0008,2218)[<0>](0008,0104)	LO	f	Anatomic Region Sequence:Code Meaning	\N
3402	(0040,a370)	SQ	f	Referenced Request Sequence	\N
3439	(0018,7008)	LT	f	Detector Mode	\N
3396	(0040,a370)[<0>](0032,1064)[<1>](0008,0102)	SH	f	Referenced Request Sequence:Requested Procedure Code Sequence:Coding Scheme Designator	\N
3406	(0040,a370)[<0>](0008,1110)[<1>](0008,0016)	UI	f	Referenced Request Sequence:Referenced Study Sequence:SOP Class UID	\N
3429	(0054,0220)[<0>](0008,0104)	LO	f	View Code Sequence:Code Meaning	\N
3323	(0040,a730)[<0>](0040,a043)	SQ	f	Content Sequence:Concept Name Code Sequence	\N
3469	(0040,a730)[<0>](0040,a730)[<1>](0040,a040)	CS	f	Content Sequence:Content Sequence:Value Type	\N
3339	(0040,a730)[<0>](0008,1199)[<1>](0008,1150)	UI	f	Content Sequence:Referenced SOP Sequence:Referenced SOP Class UID	\N
3360	(0070,005a)[<0>](0070,0102)	IS	f	Displayed Area Selection Sequence:Presentation Pixel Aspect Ratio	\N
3344	(0040,a375)[<0>](0020,000d)	UI	f	Current Requested Procedure Evidence Sequence:Study Instance UID	\N
5019	(0018,9174)	CS	f	Applicable Safety Standard Agency	\N
5015	(0018,9200)	CS	f	MR Spectroscopy Acquisition Type	\N
5024	(0018,9027)	CS	f	Spatial Pre-saturation	\N
5026	(0018,9028)	CS	f	Tagging	\N
5017	(0018,9078)	CS	f	Parallel Acquisition Technique	\N
5028	(0018,9020)	CS	f	Magnetization Transfer	\N
5016	(0018,9180)	CS	f	Gradient Output Type	\N
5020	(0018,9179)	CS	f	Specific Absorption Rate Definition	\N
3473	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a040)	CS	f	Content Sequence:Content Sequence:Content Sequence:Value Type	\N
5416	(0071,"BLACKFORD",04)[<0>](0010,0030)	DA	t	Unknown:Patient's Birth Date	d
3310	(0029,"MITRA PRESENTATION 1.0",13)	CS	t	Unknown	d
3332	(0035,"AGFA KOSD 1.0",03)	LT	t	Unknown	d
3346	(0029,"MITRA PRESENTATION 1.0",03)	IS	t	Invert	k
3417	(0018,1706)	IS	f	Collimator Upper Horizontal Edge	\N
3449	(0018,1700)	CS	f	Collimator Shape	\N
3399	(0040,a370)[<0>](0008,0050)	SH	f	Referenced Request Sequence:Accession Number	\N
3361	(0028,3110)[<0>](0028,1055)	LO	f	Softcopy VOI LUT Sequence:Window Center & Width Explanation	\N
3433	(0018,7022)	DS	f	Detector Element Spacing	\N
3408	(0040,a370)[<0>](0008,1110)[<1>](0008,0018)	UI	f	Referenced Request Sequence:Referenced Study Sequence:SOP Instance UID	\N
3436	(0018,701a)	DS	f	Detector Binning	\N
3343	(0040,a375)[<0>](0008,1115)[<1>](0020,000e)	UI	f	Current Requested Procedure Evidence Sequence:Referenced Series Sequence:Series Instance UID	\N
3444	(0018,113a)	CS	f	Table Type	\N
3414	(0018,1405)	IS	f	Relative X-Ray Exposure	\N
3326	(0040,a730)[<0>](0040,a168)	SQ	f	Content Sequence:Concept Code Sequence	\N
3324	(0040,a375)[<0>](0008,1115)[<1>](0008,1199)	SQ	f	Current Requested Procedure Evidence Sequence:Referenced Series Sequence:Referenced SOP Sequence	\N
3460	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)	SQ	f	Content Sequence:Content Sequence:Content Sequence	\N
3454	(0040,a730)[<0>](0040,a730)[<1>](0040,a043)[<2>](0008,0100)	SH	f	Content Sequence:Content Sequence:Concept Name Code Sequence:Code Value	\N
3328	(0040,a375)[<0>](0008,1115)	SQ	f	Current Requested Procedure Evidence Sequence:Referenced Series Sequence	\N
3443	(0018,7005)	CS	f	Detector Configuration	\N
3441	(0008,0068)	CS	f	Presentation Intent Type	\N
3447	(0054,0220)[<0>](0008,0105)	CS	f	View Code Sequence:Mapping Resource	\N
3321	(0040,a375)	SQ	f	Current Requested Procedure Evidence Sequence	\N
3456	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a043)[<3>](0008,0102)	SH	f	Content Sequence:Content Sequence:Content Sequence:Concept Name Code Sequence:Coding Scheme Designator	\N
3461	(0040,a730)[<0>](0040,a730)[<1>](0040,a043)	SQ	f	Content Sequence:Content Sequence:Concept Name Code Sequence	\N
3418	(0018,1153)	IS	f	Exposure in ÂµAs	\N
3358	(0070,005a)[<0>](0008,1140)[<1>](0008,1160)	IS	f	Displayed Area Selection Sequence:Referenced Image Sequence:Referenced Frame Number	\N
3327	(0040,a504)	SQ	f	Content Template Sequence	\N
3330	(0040,a730)[<0>](0040,a043)[<1>](0008,0104)	LO	f	Content Sequence:Concept Name Code Sequence:Code Meaning	\N
3459	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a043)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Concept Name Code Sequence	\N
3424	(0008,2218)[<0>](0008,0100)	SH	f	Anatomic Region Sequence:Code Value	\N
3432	(0018,7001)	DS	f	Detector Temperature	\N
3340	(0040,a375)[<0>](0008,1115)[<1>](0008,1199)[<2>](0008,1150)	UI	f	Current Requested Procedure Evidence Sequence:Referenced Series Sequence:Referenced SOP Sequence:Referenced SOP Class UID	\N
3466	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a010)	CS	f	Content Sequence:Content Sequence:Content Sequence:Relationship Type	\N
3453	(0018,700c)	DA	f	Date of Last Detector Calibration	\N
3442	(0018,7004)	CS	f	Detector Type	\N
3342	(0040,a375)[<0>](0008,1115)[<1>](0008,1199)[<2>](0008,1155)	UI	f	Current Requested Procedure Evidence Sequence:Referenced Series Sequence:Referenced SOP Sequence:Referenced SOP Instance UID	\N
3452	(0040,0302)	US	f	Entrance Dose	\N
3398	(0040,a370)[<0>](0040,2016)	SH	f	Referenced Request Sequence:Placer Order Number / Imaging Service Request	\N
3548	(200b,"Philips RAD Imaging DD 001",48)	SH	t	Unknown	d
3347	(0029,"MITRA PRESENTATION 1.0",01)	LO	t	Window Width	k
3367	(0029,"MITRA PRESENTATION 1.0",13)	UN	t	Unknown	d
3368	(0029,"MITRA PRESENTATION 1.0",12)	UN	t	Unknown	d
3372	(0019,"Agfa ADC NX",fc)	IS	t	Unknown	d
3348	(0029,"MITRA PRESENTATION 1.0",02)	LO	t	Window Centre	k
3553	(200b,"Philips RAD Imaging DD 001",11)	LO	t	Unknown	d
3605	(0019,"SIEMENS MR HEADER",08)	UN	t	Unknown	d
3530	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",85)	IS	t	Presentation State Sequence:Unknown	d
3542	(200b,"Philips RAD Imaging DD 097",7e)	UI	t	Unknown	d
3491	(0045,"GEMS_FALCON_03",55)	DS	t	A_Coefficients used in Multiresolution Algorithm	d
3520	(0011,"GEMS_GDXE_FALCON_04",10)	SL	t	Total Exposures	d
3543	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",65)	SS	t	Presentation State Sequence:Unknown	d
3572	(200b,"Philips RAD Imaging DD 001",2c)	TM	t	Unknown	d
3521	(0011,"GEMS_GDXE_FALCON_04",40)	SL	t	Pasting Overlap	d
3524	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)	SQ	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence	d
3594	(0019,"SIEMENS MR HEADER",18)	UN	t	Real Dwell Time	k
3560	(200b,"Philips RAD Imaging DD 097",63)	LT	t	Unknown	d
3492	(0011,"GEMS_GDXE_FALCON_04",33)	DS	t	Detector Exposure Index	d
3600	(0019,"SIEMENS MR HEADER",0f)	UN	t	Gradient Mode	k
5037	(0018,9182)	FD	f	Gradient Output	\N
5041	(0020,9254)	FD	f	Respiratory Interval Time	\N
5042	(0018,9091)	FD	f	Velocity Encoding Minimum Value	\N
5030	(0018,9171)	CS	f	Respiratory Signal Source	\N
5034	(0018,9168)	FD	f	Parallel Reduction Factor Second In-plane	\N
5031	(0018,9037)	CS	f	Cardiac Synchronization Technique	\N
5033	(0018,9032)	CS	f	Geometry of k-Space Traversal	\N
5029	(0018,9172)	CS	f	Bulk Motion Compensation Technique	\N
4350	(01f1,"ELSCINT1",56)	LO	t	Unknown	d
3317	(0035,"AGFA KOSD 1.0",00)	SH	t	Unknown	d
3413	(0018,1704)	IS	f	Collimator Right Vertical Edge	\N
3445	(0054,0220)[<0>](0008,010f)	CS	f	View Code Sequence:Context Identifier	\N
3458	(0040,a730)[<0>](0040,a730)	SQ	f	Content Sequence:Content Sequence	\N
3353	(0040,a170)	SQ	f	Purpose of Reference Code Sequence	\N
5594	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)	SQ	t	Advanced Presentation Sequence:Presentation State Sequence	k
3457	(0040,a730)[<0>](0040,a730)[<1>](0040,a043)[<2>](0008,0102)	SH	f	Content Sequence:Content Sequence:Concept Name Code Sequence:Coding Scheme Designator	\N
3431	(0018,115e)	DS	f	Image and Fluoroscopy Area Dose Product	\N
3420	(0054,0220)[<0>](0008,0106)	DT	f	View Code Sequence:Context Group Version	\N
3325	(0040,a730)	SQ	f	Content Sequence	\N
3359	(0008,1115)[<0>](0008,1140)[<1>](0008,1160)	IS	f	Referenced Series Sequence:Referenced Image Sequence:Referenced Frame Number	\N
3434	(0018,7020)	DS	f	Detector Element Physical Size	\N
3475	(0040,a730)[<0>](0040,a730)[<1>](0040,a124)	UI	f	Content Sequence:Content Sequence:UID	\N
3448	(0008,2218)[<0>](0008,010f)	CS	f	Anatomic Region Sequence:Context Identifier	\N
3357	(0028,3110)[<0>](0008,1140)[<1>](0008,1160)	IS	f	Softcopy VOI LUT Sequence:Referenced Image Sequence:Referenced Frame Number	\N
3462	(0040,a372)	SQ	f	Performed Procedure Code Sequence	\N
3474	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a124)	UI	f	Content Sequence:Content Sequence:Content Sequence:UID	\N
3351	(0018,9303)	FD	f	Tube Angle	\N
3476	(0040,2016)	LO	f	Placer Order Number / Imaging Service Request	\N
3407	(0040,a370)[<0>](0020,000d)	UI	f	Referenced Request Sequence:Study Instance UID	\N
3450	(0018,700e)	TM	f	Time of Last Detector Calibration	\N
3465	(0040,a730)[<0>](0040,a730)[<1>](0040,a160)	UT	f	Content Sequence:Content Sequence:Text Value	\N
3349	(0018,9334)	CS	f	Fluoroscopy Flag	\N
3464	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a043)[<3>](0008,0104)	LO	f	Content Sequence:Content Sequence:Content Sequence:Concept Name Code Sequence:Code Meaning	\N
3412	(0018,1708)	IS	f	Collimator Lower Horizontal Edge	\N
3471	(0040,a491)	CS	f	Completion Flag	\N
5595	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence	k
5588	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",93)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Evaluation Sequence	k
4343	(01f1,"ELSCINT1",0f)	CS	t	Unknown	d
4347	(01f7,"ELSCINT1",95)	OW	t	Unknown	d
3022	(0029,"FDMS 1.0",50)	OB	t	DataCompressionCode	d
3000	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
4339	(00e1,"ELSCINT1",36)	CS	t	Unknown	d
4341	(00e1,"ELSCINT1",c4)	DS	t	Unknown	d
4348	(01f7,"ELSCINT1",97)	OW	t	Unknown	d
3576	(200b,"Philips RAD Imaging DD 001",30)	UN	t	Unknown	d
3489	(0011,"GEMS_GDXE_FALCON_04",42)	LO	t	View IP	d
3497	(0011,"GEMS_GDXE_FALCON_04",15)	DS	t	Detector ARC Gain	d
4367	(0015,"GEMS_PETD_01",1f)	UL	t	PET Recon Parameters Exists	k
3523	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)	SQ	t	Presentation State Sequence:Graphic Annotation Sequence	d
3536	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)[<2>](0070,0010)	FL	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence:Bounding Box Top Left Hand Corner	d
3597	(0051,"SIEMENS MR HEADER",0f)	UN	t	Coil String	d
3519	(0011,"GEMS_GDXE_FALCON_04",17)	UN	t	Override Mode	d
3483	(0011,"GEMS_GDXE_FALCON_04",13)	UI	t	SPS UID	d
3541	(200b,"Philips RAD Imaging DD 001",42)	UI	t	Unknown	d
3589	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",13)	PN	t	Unknown	d
3582	(200b,"Philips RAD Imaging DD 001",01)	US	t	Unknown	d
3607	(0051,"SIEMENS MR HEADER",17)	UN	t	Unknown	d
3547	(200b,"Philips RAD Imaging DD 001",41)	SH	t	Unknown	d
3508	(7fdf,"GEMS_GDXE_ATHENAV2_INTERNAL_USE",11)	LT	t	Pixel Data References (temporary)	d
3578	(200b,"Philips RAD Imaging DD 001",2f)	UN	t	Unknown	d
3595	(0051,"SIEMENS MR HEADER",16)	UN	t	Unknown	d
3535	(200b,"Philips RAD Imaging DD 097",7a)	IS	t	Unknown	d
3581	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",7c)	US	t	Presentation State Sequence:Unknown	d
3588	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",19)	PN	t	Unknown	d
3505	(0011,"GEMS_GDXE_FALCON_04",16)	LT	t	Processing Debug Info	d
3539	(200b,"Philips RAD Imaging DD 097",9f)[<0>](0008,0016)	UI	t	Unknown:SOP Class UID	d
3603	(0051,"SIEMENS MR HEADER",09)	UN	t	CSA Image Header Version	d
3490	(0011,"GEMS_GDXE_FALCON_04",37)	DS	t	DEI Lower & Upper Limit Values	d
3610	(0019,"SIEMENS MR HEADER",15)	UN	t	Slice Position PCS	k
3621	(0019,"SIEMENS MR HEADER",28)	UN	t	Bandwidth per Pixel Phase Encode	k
4486	(0043,"GEMS_PARM_01",68)	US	t	XT Correction Indicator	k
5048	(0018,9240)	US	f	RF Echo Train Length	\N
5045	(0018,9231)	US	f	MR Acquisition Phase Encoding Steps in-plane	\N
5049	(0018,9058)	US	f	MR Acquisition Frequency Encoding Steps	\N
5046	(0018,9093)	US	f	Number of k-Space Trajectories	\N
5047	(0018,9241)	US	f	Gradient Echo Train Length	\N
4315	(0137,"NetRAAD",02)	SH	t	Unknown	d
1357	(01f1,"ELSCINT1",4a)	SH	t	Unknown	d
3814	(0051,"",17)	UN	t	Unknown	d
302	(0043,"GEMS_PARM_01",21)	SS	t	CorrectedAfterglowTerms	k
5426	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0070,030d)[<2>](0008,0100)	SH	t	Unknown:Deformable Registration Sequence:Registration Type Code Sequence:Code Value	d
4320	(0137,"NetRAAD",40)	CS	t	Unknown	d
3035	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",33)	OB	t	Unknown:Unknown	d
4316	(0137,"NetRAAD",01)	SH	t	Unknown	d
2844	(01f1,"ELSCINT1",4a)	OB	t	Unknown	d
3656	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",aa)	SQ	t	Presentation State Sequence:Unknown	d
4366	(07a1,"ELSCINT1",02)	UN	t	Unknown	d
3484	(0011,"GEMS_GDXE_FALCON_04",05)	UI	t	Acquisition UID	d
3495	(0011,"GEMS_GDXE_FALCON_04",34)	DS	t	Compensated Detector Exposure	d
3496	(0011,"GEMS_GDXE_FALCON_04",36)	DS	t	Median Anatomy Count Value	d
3580	(200b,"Philips RAD Imaging DD 001",02)	US	t	Unknown	d
3585	(200b,"Philips RAD Imaging DD 001",47)	DA	t	Unknown	d
3525	(200b,"Philips RAD Imaging DD 097",9f)	SQ	t	Unknown	d
3486	(7fdf,"GEMS_GDXE_ATHENAV2_INTERNAL_USE",20)	SS	t	Auto Push Tag	d
3488	(0011,"GEMS_GDXE_FALCON_04",46)	LO	t	Unknown	d
3592	(0051,"SIEMENS MR HEADER",0b)	UN	t	Acquisition Matrix Text	d
3606	(0051,"SIEMENS MR HEADER",08)	UN	t	CSA Image Header Type	d
3516	(7fdf,"GEMS_GDXE_ATHENAV2_INTERNAL_USE",25)	CS	t	PPS Status	d
3556	(200b,"Philips RAD Imaging DD 001",00)	PN	t	Unknown	d
3538	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)[<2>](0070,0011)	FL	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence:Bounding Box Bottom Right Hand Corner	d
3546	(200b,"Philips RAD Imaging DD 001",4f)	DT	t	Unknown	d
3522	(0011,"GEMS_GDXE_FALCON_04",09)	SL	t	Non-Digital Exposures	d
3552	(200b,"Philips RAD Imaging DD 001",3b)	LO	t	Unknown	d
3599	(0051,"SIEMENS MR HEADER",0c)	UN	t	Unknown	d
3584	(200b,"Philips RAD Imaging DD 001",2b)	DA	t	Unknown	d
3502	(0011,"GEMS_GDXE_FALCON_04",47)	DS	t	Unknown	d
3587	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",16)	PN	t	Unknown	d
3591	(0051,"SIEMENS MR HEADER",0d)	UN	t	Unknown	d
3506	(7fdf,"GEMS_GDXE_ATHENAV2_INTERNAL_USE",10)	LT	t	Pixel Data References	d
3485	(0011,"GEMS_GDXE_FALCON_04",03)	UI	t	Processed Series UID	d
3583	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",7b)	US	t	Presentation State Sequence:Unknown	d
3598	(0019,"SIEMENS MR HEADER",11)	UN	t	Flow Compensation	k
3604	(0019,"SIEMENS MR HEADER",14)	UN	t	Ima Rel Table Position	k
4400	(5200,9230)[<0>](0008,9124)[<1>](0008,9215)[<2>](0008,0102)	SH	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Derivation Code Sequence:Coding Scheme Designator	\N
4407	(5200,9229)[<0>](0028,9110)[<1>](0018,0088)	DS	f	Shared Functional Groups Sequence:Pixel Measures Sequence:Spacing Between Slices	\N
4406	(0012,0071)	LO	f	Clinical Trial Series ID	\N
4410	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a300)[<4>](0040,08ea)[<5>](0008,0100)	SH	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Measurement Units Code Sequence:Code Value	\N
4399	(5200,9230)[<0>](0008,9124)[<1>](0008,9215)[<2>](0008,0100)	SH	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Derivation Code Sequence:Code Value	\N
4408	(0062,0002)[<0>](0062,000d)	US	f	Segment Sequence:Recommended Display CIELab Value	\N
4412	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a168)[<3>](0008,0100)	SH	f	Content Sequence:Content Sequence:Content Sequence:Concept Code Sequence:Code Value	\N
4404	(5200,9230)[<0>](0008,9124)[<1>](0008,2112)[<2>](0040,a170)[<3>](0008,0104)	LO	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Purpose of Reference Code Sequence:Code Meaning	\N
4391	(5200,9230)[<0>](0062,000a)	SQ	f	Per-frame Functional Groups Sequence:Segment Identification Sequence	\N
4395	(5200,9230)[<0>](0008,9124)[<1>](0008,2112)[<2>](0040,a170)	SQ	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Purpose of Reference Code Sequence	\N
4398	(5200,9230)[<0>](0008,9124)[<1>](0008,2112)[<2>](0040,a170)[<3>](0008,0100)	SH	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Purpose of Reference Code Sequence:Code Value	\N
4401	(5200,9230)[<0>](0008,9124)[<1>](0008,2112)[<2>](0040,a170)[<3>](0008,0102)	SH	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Purpose of Reference Code Sequence:Coding Scheme Designator	\N
4403	(5200,9230)[<0>](0008,9124)[<1>](0008,9215)[<2>](0008,0104)	LO	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Derivation Code Sequence:Code Meaning	\N
4402	(0020,9222)[<0>](0020,9421)	LO	f	Dimension Index Sequence:Dimension Description Label	\N
4397	(5200,9230)[<0>](0008,9124)[<1>](0008,2112)[<2>](0008,1150)	UI	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Referenced SOP Class UID	\N
4351	(0040,1008)	LO	f	Confidentiality Code	\N
4413	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a043)[<4>](0008,0100)	SH	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Concept Name Code Sequence:Code Value	\N
4393	(5200,9230)[<0>](0008,9124)	SQ	f	Per-frame Functional Groups Sequence:Derivation Image Sequence	\N
4411	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a300)[<3>](0040,08ea)[<4>](0008,0100)	SH	f	Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Measurement Units Code Sequence:Code Value	\N
4405	(0012,0060)	LO	f	Clinical Trial Coordinating Center Name	\N
4394	(5200,9230)[<0>](0008,9124)[<1>](0008,2112)	SQ	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence	\N
4386	(0015,"GEMS_PETD_01",3c)	US	t	Recon Matrix Size	k
5063	(2005,"Philips MR Imaging DD 004",71)	OB	t	Series SP Mix	k
5412	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0008,1140)[<2>](0008,1150)	UI	t	Unknown:Unknown:Referenced Image Sequence:Referenced SOP Class UID	d
5422	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0070,030d)	SQ	t	Unknown:Deformable Registration Sequence:Registration Type Code Sequence	d
5382	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)[<2>](0070,030d)[<3>](0008,0104)	LO	t	Unknown:Registration Sequence:Matrix Registration Sequence:Registration Type Code Sequence:Code Meaning	d
5408	(0071,"BLACKFORD",04)[<0>](0020,0052)	UI	t	Unknown:Frame of Reference UID	d
5410	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0020,000e)	UI	t	Unknown:Unknown:Series Instance UID	d
5450	(0021,"SIEMENS MED",20)	US	t	ROIMask	d
4423	(0040,a730)[<0>](0040,a504)	SQ	f	Content Sequence:Content Template Sequence	\N
4415	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a168)[<3>](0008,0102)	SH	f	Content Sequence:Content Sequence:Content Sequence:Concept Code Sequence:Coding Scheme Designator	\N
4422	(0040,a073)	SQ	f	Verifying Observer Sequence	\N
4428	(0040,a730)[<0>](0040,a730)[<1>](0040,a504)	SQ	f	Content Sequence:Content Sequence:Content Template Sequence	\N
4429	(0040,a073)[<0>](0040,a088)	SQ	f	Verifying Observer Sequence:Verifying Observer Identification Code Sequence	\N
5603	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,3110)[<2>](0008,1140)	SQ	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Sequence:Referenced Image Sequence	k
5602	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5e)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Slice Spacing Sequence	k
5601	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)	SQ	t	Advanced Presentation Sequence:Time Point Sequence	k
2977	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",63)	OB	t	Unknown:Unknown	d
601	(0009,"GEMS_PETD_01",a2)	FL	t	Axial Spacing	k
3092	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",61)	OB	t	Unknown:Unknown	d
67	(0019,"SIEMENS MR HEADER",18)	OB	t	Real Dwell Time	k
238	(0027,"GEMS_IMAG_01",43)	FL	t	CenterACoordOfPlaneImage	k
5069	(2005,"Philips MR Imaging DD 001",80)	OB	t	Series PlanScan	k
3005	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3299	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0028,0010)	US	t	Unknown:Unknown:Rows	d
3009	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
2905	(00e1,"ELSCINT1",39)[<0>](0040,0275)[<1>](0040,0008)[<2>](0008,0104)	LO	t	Unknown:Request Attributes Sequence:Scheduled Protocol Code Sequence:Code Meaning	d
4203	(5653,"",17)	OB	t	Unknown	d
1591	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",68)	UN	t	Unknown	d
3119	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",53)	OB	t	Unknown:Unknown	d
5192	(2005,"Philips MR Imaging DD 004",45)	OB	t	Spectro Echo Acquisition	k
5070	(2005,"Philips MR Imaging DD 001",84)	OB	t	Series Reference	k
4119	(2001,"Philips Imaging DD 129",00)[<0>](0028,3006)	OW	t	Presentation State Sequence:LUT Data	d
5314	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",5a)	FL	t	Series Volume:Volume Offcentre AP	k
3769	(0079,"Unnamed Private Block - 10",13)	DS	t	Unknown	d
2939	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",70)	SQ	t	Unknown:Unknown	d
5338	(0015,"GEMS_PETD_01",34)	UN	t	Emission Random Flag	k
5206	(2005,"Philips MR Imaging DD 005",0b)	OB	t	Rescale Type Original	k
5071	(2001,"Philips Imaging DD 001",81)	OB	t	NumberOfDynamicScans	k
3558	(200b,"Philips RAD Imaging DD 001",29)	DS	t	Unknown	d
4425	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a300)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence	\N
4482	(0043,"GEMS_PARM_01",63)	SH	t	Raw Data ID	d
4416	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a300)[<4>](0040,08ea)[<5>](0008,0102)	SH	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Measurement Units Code Sequence:Coding Scheme Designator	\N
3527	(200b,"Philips RAD Imaging DD 097",00)	ST	t	Unknown	d
3479	(0045,"GEMS_FALCON_03",62)	IS	t	User Window Center	d
3579	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",a1)	UN	t	Presentation State Sequence:Unknown	d
3577	(200b,"Philips RAD Imaging DD 097",b7)	UN	t	Unknown	d
3529	(200b,"Philips RAD Imaging DD 001",2a)	UL	t	Unknown	d
3554	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)[<2>](2001,"Philips Imaging DD 001",6d)	LO	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence:Text Font	d
3555	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",81)	LO	t	Presentation State Sequence:Unknown	d
3559	(200b,"Philips RAD Imaging DD 001",28)	DS	t	Unknown	d
3574	(200b,"Philips RAD Imaging DD 097",b9)	UN	t	Unknown	d
3507	(0011,"GEMS_GDXE_FALCON_04",12)	LT	t	Patient Size String	d
3557	(200b,"Philips RAD Imaging DD 097",90)	DS	t	Unknown	d
3534	(200b,"Philips RAD Imaging DD 097",79)	IS	t	Unknown	d
3619	(0019,"SIEMENS MR HEADER",0d)	UN	t	Diffusion Directionality	k
4418	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a168)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Concept Code Sequence	\N
4424	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a300)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence	\N
4518	(5001,"vRad PACS",54)	UN	t	Unknown	d
4477	(1111,"2.16.840.1.114330.1.1.1.1",11)	SL	t	Unknown	d
5606	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0008,1115)[<2>](0008,1140)	SQ	t	Advanced Presentation Sequence:Presentation State Sequence:Referenced Series Sequence:Referenced Image Sequence	k
5616	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",9a)[<4>](0028,0008)	IS	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Referenced Frames Sequence:Number of Frames	k
5609	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0008,1140)[<3>](0008,1160)	IS	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Referenced Image Sequence:Referenced Frame Number	k
5617	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0070,0103)	FL	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Presentation Pixel Magnification Ratio	k
5370	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)[<2>](0070,030a)	SQ	t	Unknown:Registration Sequence:Matrix Registration Sequence:Matrix Sequence	d
5611	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",9a)[<4>](0008,1160)	IS	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Referenced Frames Sequence:Referenced Frame Number	k
5615	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",9a)[<3>](0028,0008)	IS	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Referenced Frames Sequence:Number of Frames	k
5605	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,3110)	SQ	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Sequence	k
5346	(0077,"TERARECON AQUARIUS",50)	UN	t	First Binary Data	d
5608	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",9a)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Referenced Frames Sequence	k
5423	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0064,0005)[<2>](0064,0007)	UL	t	Unknown:Deformable Registration Sequence:Deformable Registration Grid Sequence:Grid Dimensions	d
5620	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0008,1140)[<3>](0008,1155)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Referenced Image Sequence:Referenced SOP Instance UID	h
5113	(2005,"Philips MR Imaging DD 001",25)	OB	t	Number of Volumes	k
5612	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0020,0013)	IS	t	Advanced Presentation Sequence:Presentation State Sequence:Instance Number	k
5610	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,3110)[<2>](0008,1140)[<3>](0008,1160)	IS	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Sequence:Referenced Image Sequence:Referenced Frame Number	k
5362	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)[<2>](0070,030d)[<3>](0008,0102)	SH	t	Unknown:Registration Sequence:Matrix Registration Sequence:Registration Type Code Sequence:Coding Scheme Designator	D
5619	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,3110)[<2>](0008,1140)[<3>](0008,1155)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Sequence:Referenced Image Sequence:Referenced SOP Instance UID	h
5613	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",9a)[<3>](0008,1160)	IS	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Referenced Frames Sequence:Referenced Frame Number	k
5618	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0008,1115)[<2>](0008,1140)[<3>](0008,1155)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:Referenced Series Sequence:Referenced Image Sequence:Referenced SOP Instance UID	h
461	(0019,"GEMS_ACQU_01",84)	DS	t	PeakSAR	k
210	(0029,"GEMS_IMPS_01",05)	DS	t	LowerRangeOfPixels	k
1659	(0019,"SIEMENS MR HEADER",11)	SH	t	Flow Compensation	k
3139	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
5098	(2005,"Philips MR Imaging DD 001",86)	OB	t	Number of Geometry	k
3145	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",70)	OB	t	Unknown:Unknown	d
1445	(7053,"Philips PET Private Group",09)	DS	t	Activity Concentration Scale Factor	k
5109	(2005,"Philips MR Imaging DD 003",52)	OB	t	Number of Study Patient Contrast Allergies	k
3024	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
5087	(2001,"Philips Imaging DD 001",13)	OB	t	EPIFactor	k
1290	(0029,"SIEMENS MEDCOM HEADER",40)[<0>](0029,"SIEMENS MEDCOM HEADER",44)	OB	t	ApplicationHeaderSequence:ApplicationHeaderInfo	na
2886	(00e1,"ELSCINT1",39)[<0>](0008,1110)[<1>](0008,1155)	UI	t	Unknown:Referenced Study Sequence:Referenced SOP Instance UID	d
3117	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",42)	OB	t	Unknown:Unknown	d
3287	(300a,00b0)[<0>](3243,"Varian Medical Systems VISION 3243",09)	UN	t	Beam Sequence:Unknown	d
1818	(00e1,"ELSCINT1",14)	CS	t	Unknown	d
5642	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,3110)[<2>](0028,1051)	DS	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Sequence:Window Width	k
5639	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,0084)	PN	t	Advanced Presentation Sequence:Presentation State Sequence:Content Creator's Name	d
5638	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0070,0084)	PN	t	Advanced Presentation Sequence:Content Creator's Name	d
5627	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",cf)[<3>](0020,000d)	UI	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Image Sequence:Study Instance UID	h
5636	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",93)[<4>](0008,0104)	LO	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Evaluation Sequence:Code Meaning	k
5635	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0018,9525)	LO	t	Advanced Presentation Sequence:Application Version	k
5641	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,1053)	DS	t	Advanced Presentation Sequence:Presentation State Sequence:Rescale Slope	k
5626	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0020,000d)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:Study Instance UID	h
5628	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0008,0016)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:SOP Class UID	k
5633	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,0081)	LO	t	Advanced Presentation Sequence:Presentation State Sequence:Content Description	d
5637	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,1054)	LO	t	Advanced Presentation Sequence:Presentation State Sequence:Rescale Type	k
5168	(2001,"Philips Imaging DD 001",14)	OB	t	NumberOfEchoes	k
5465	(01f7,"ELSCINT1",92)	UN	t	Unknown	d
4037	(0051,"",09)	LO	t	Unknown	d
5640	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,3110)[<2>](0028,1050)	DS	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Sequence:Window Center	k
5467	(01f1,"ELSCINT1",56)	UN	t	Unknown	d
4873	(0023,"GEMS_STDY_01",70)	OB	t	StartTimeSecsInFirstAxial	oi
5629	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0008,1115)[<2>](0020,000e)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:Referenced Series Sequence:Series Instance UID	h
5630	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",cf)[<3>](0008,1115)[<4>](0020,000e)	UI	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Image Sequence:Referenced Series Sequence:Series Instance UID	h
5624	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0008,1140)[<3>](0008,1150)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Referenced Image Sequence:Referenced SOP Class UID	k
2598	(0040,0008)[<0>](0008,0103)	SH	f	Scheduled Protocol Code Sequence:Coding Scheme Version	\N
2581	(0008,1111)[<0>](0008,0012)	DA	f	Referenced Performed Procedure Step Sequence:Instance Creation Date	\N
1640	(0047,"GEMS_3DSTATE_001",eb)	DS	t	Unknown	d
2756	(0042,0013)	SQ	f	Source Instance Sequence	\N
2757	(0042,0010)	ST	f	Document Title	\N
2940	(0023,"FDMS 1.0",10)	SQ	t	Unknown	d
431	(0019,"GEMS_ACQU_01",a1)	SS	t	ExtremityCoilFlag	k
5468	(01f1,"ELSCINT1",0f)	UN	t	Unknown	d
788	(0009,"GEMS_PETD_01",64)	SL	t	file_exists	d
5464	(00e1,"ELSCINT1",c4)	UN	t	Unknown	d
2944	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",10)	SQ	t	Unknown:Unknown	d
3247	(300a,0010)[<0>](300d,"TOMO_HA_01",10)	UN	t	Dose Reference Sequence:Unknown	d
5298	(2005,"Philips MR Imaging DD 005",91)	UN	t	Original Modality LUT Sequence	d
5469	(00e1,"ELSCINT1",46)	UN	t	Unknown	d
5167	(2005,"Philips MR Imaging DD 001",20)	OB	t	NumberOfChemicalShifts	k
5140	(2005,"Philips MR Imaging DD 005",02)	OB	t	Unknown	d
1483	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",30)	UN	t	Unknown	d
3176	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
1476	(0009,"Unnamed Private Block - 10",3b)	UN	t	Unknown	d
2855	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",14)	OB	t	Unknown:Unknown	d
5452	(0018,9360)	SQ	f	CT Additional X-Ray Source Sequence	\N
5463	(0028,6010)	US	f	Representative Frame Number	\N
5459	(0018,9360)[<0>](0018,7050)	CS	f	CT Additional X-Ray Source Sequence:Filter Material	\N
5462	(0008,0103)	SH	f	Coding Scheme Version	\N
5455	(0018,9360)[<0>](0018,1160)	SH	f	CT Additional X-Ray Source Sequence:Filter Type	\N
5460	(0018,9360)[<0>](0018,9332)	FD	f	CT Additional X-Ray Source Sequence:Exposure in mAs	\N
5461	(0018,9360)[<0>](0018,9330)	FD	f	CT Additional X-Ray Source Sequence:X-Ray Tube Current in mA	\N
5454	(0018,9360)[<0>](0018,9353)	FL	f	CT Additional X-Ray Source Sequence:Energy Weighting Factor	\N
5453	(0018,9353)	FL	f	Energy Weighting Factor	\N
5456	(0018,9360)[<0>](0018,0060)	DS	f	CT Additional X-Ray Source Sequence:KVP	\N
5457	(0018,9360)[<0>](0018,0090)	DS	f	CT Additional X-Ray Source Sequence:Data Collection Diameter	\N
5646	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5e)[<2>](0072,0510)	CS	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Slice Spacing Sequence:Reformatting Operation Type	k
5458	(0018,9360)[<0>](0018,1190)	DS	f	CT Additional X-Ray Source Sequence:Focal Spot(s)	\N
5665	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",19)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Auto Navigation Realtime Flag	k
5183	(2005,"Philips MR Imaging DD 003",01)	OB	t	Number of Film Consumption	k
4984	(2005,"Philips MR Imaging DD 005",0e)[<0>](0008,0014)	UI	t	Private Shared Sequence:Instance Creator UID	na
5649	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,0041)	CS	t	Advanced Presentation Sequence:Presentation State Sequence:Image Horizontal Flip	k
5652	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](2050,0020)	CS	t	Advanced Presentation Sequence:Presentation State Sequence:Presentation LUT Shape	k
5662	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",18)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Auto Navigation Strategy	k
2750	(0008,9215)[<0>](0008,010f)	CS	f	Derivation Code Sequence:Context Identifier	\N
5658	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0028,0011)	US	t	Advanced Presentation Sequence:Columns	k
2749	(0008,2112)[<0>](0040,a170)[<1>](0008,010b)	CS	f	Source Image Sequence:Purpose of Reference Code Sequence:Context Group Extension Flag	\N
5645	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0072,0510)	CS	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Reformatting Operation Type	k
2782	(0053,"GEHC_CT_ADVAPP_001",63)	CS	t	Image Position Patient Setting	k
5655	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,0083)	TM	t	Advanced Presentation Sequence:Presentation State Sequence:Presentation Creation Time	k
371	(0053,"GEHC_CT_ADVAPP_001",62)	SH	t	Respiratory Flag	k
5651	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,0080)	CS	t	Advanced Presentation Sequence:Presentation State Sequence:Content Label	k
5657	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,0042)	US	t	Advanced Presentation Sequence:Presentation State Sequence:Image Rotation	k
5654	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0008,0033)	TM	t	Advanced Presentation Sequence:Presentation State Sequence:Content Time	k
796	(0009,"GEMS_PETD_01",16)	SL	t	Patient Position	k
5656	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0028,0010)	US	t	Advanced Presentation Sequence:Rows	k
5650	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0070,0100)	CS	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Presentation Size Mode	k
1644	(0043,"GEMS_PARM_01",62)	SH	t	Unknown	d
5644	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,1052)	DS	t	Advanced Presentation Sequence:Presentation State Sequence:Rescale Intercept	k
441	(0019,"GEMS_ACQU_01",c1)	SS	t	SurfaceCoilIntensityCorrectionFlag	k
5660	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",86)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Parallel Epiped	k
5647	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0072,0510)	CS	t	Advanced Presentation Sequence:Presentation Module Sequence:Reformatting Operation Type	k
66	(0019,"SIEMENS MR HEADER",0f)	OB	t	Gradient Mode	k
783	(0009,"GEMS_PETD_01",17)	SL	t	Scan Perspective	k
194	(0019,"GEMS_ACQU_01",19)	DS	t	FirstScanLocation	k
2946	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",30)	SQ	t	Unknown:Unknown	d
3120	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",80)	OB	t	Unknown:Unknown	d
4180	(0043,"dcm4che/archive",41)	FL	t	Unknown	d
2906	(00e1,"ELSCINT1",39)[<0>](0032,1064)[<1>](0008,0104)	LO	t	Unknown:Requested Procedure Code Sequence:Code Meaning	d
2758	(0042,0012)	LO	f	MIME Type of Encapsulated Document	\N
2597	(0040,0008)	SQ	f	Scheduled Protocol Code Sequence	\N
5179	(7fd1,"GEIIS",10)	OB	t	Compression Type	d
1624	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",55)	UN	t	Unknown	d
4149	(5653,"Vital Images SW 3.4",14)[<0>](5653,"Vital Images SW 3.4",12)	OB	t	Saved Workflow File Sequence:Saved Workflow File Data	d
4231	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 004",89)[<1>](2005,"Philips MR Imaging DD 004",83)	UN	t	Presentation State Sequence:Viewing Protocol:Sort Attributes	d
628	(0009,"GEMS_PETD_01",ab)	FL	t	bp_center_x	k
3058	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",60)	OB	t	Unknown:Unknown	d
5212	(2005,"Philips MR Imaging DD 001",2c)	OB	t	Phase Encode Reordering	k
5316	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",5d)	CS	t	Series Volume:Volume Type	k
617	(0009,"GEMS_PETD_01",bf)	FL	t	AC BP Filt Cutoff	k
5668	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",32)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Type	k
5666	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",49)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Field of View	k
5671	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",53)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Material	k
520	(0021,"GEMS_RELA_01",58)	SL	t	IntegerSlop	k
5053	(2005,"Philips MR Imaging DD 001",0f)	OB	t	Window Center	k
3240	(300a,00b0)[<0>](300d,"TOMO_HA_01",80)	UN	t	Beam Sequence:Unknown	d
5667	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",49)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Field of View	k
3196	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
5669	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",4c)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Image Minimum Height	k
5203	(2005,"Philips MR Imaging DD 001",6e)	OB	t	Scanning Sequence	k
5673	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",1a)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Unknown	d
5292	(2001,"Philips Imaging DD 129",00)[<0>](0070,005a)[<1>](0070,0101)	DS	t	Presentation State Sequence:Displayed Area Selection Sequence:Presentation Pixel Spacing	k
388	(0043,"GEMS_PARM_01",34)	IS	t	OffsetFrequency	k
5196	(2005,"Philips MR Imaging DD 004",98)	OB	t	Mobiview Enabled	k
5672	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a8)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Presentation Module Type	k
1617	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",59)	UN	t	Unknown	d
3723	(0021,"Siemens: Thorax/Multix FD Post Processing",05)	SS	t	Unknown	d
5258	(2001,"Philips Imaging DD 001",86)	OB	t	Number of Phase Encoding Steps	k
3160	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
2759	(0028,0a04)	LO	f	Pixel Spacing Calibration Description	\N
4959	(2005,"Philips MR Imaging DD 003",81)	UI	t	Default Image UID	d
303	(0019,"GEMS_ACQU_01",58)	SS	t	CTBoneNumber	k
2582	(0040,0250)	DA	f	Performed Procedure Step End Date	\N
2746	(0008,2112)[<0>](0040,a170)[<1>](0008,0104)	LO	f	Source Image Sequence:Purpose of Reference Code Sequence:Code Meaning	\N
2753	(0008,9215)[<0>](0008,0105)	CS	f	Derivation Code Sequence:Mapping Resource	\N
3011	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
1344	(0009,"GEMS_PETD_01",82)	UI	t	Color Map ID	d
5245	(2005,"Philips MR Imaging DD 005",4f)	OB	t	Volume Select	k
5232	(2005,"Philips MR Imaging DD 001",3b)	OB	t	Time Reversed Steady State	k
5224	(2005,"Philips MR Imaging DD 001",12)	OB	t	Cardiac Gating	k
2888	(00e1,"ELSCINT1",39)[<0>](0008,1111)[<1>](0008,1150)	UI	t	Unknown:Referenced Performed Procedure Step Sequence:Referenced SOP Class UID	d
5234	(2005,"Philips MR Imaging DD 001",28)	OB	t	Partial Fourier Frequency	k
5237	(2005,"Philips MR Imaging DD 005",35)	OB	t	Spectro Examcard	k
5248	(2005,"Philips MR Imaging DD 001",27)	OB	t	Package Mode	k
5096	(2005,"Philips MR Imaging DD 001",1a)	OB	t	Label Syntax	k
2983	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
3641	(0011,"GEMS_GDXE_FALCON_04",66)	UN	t	Unknown	d
1043	(0053,"GEHC_CT_ADVAPP_001",71)	UN	t	MultiEnergyScanType	k
5288	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 129",00)		t	Presentation State Sequence:Presentation State Sequence	na
5254	(2005,"Philips MR Imaging DD 005",1b)	OB	t	Version Number Deleted Images	k
3740	(0021,"Siemens: Thorax/Multix FD Post Processing",14)	US	t	Anatomic Correct View	d
764	(0009,"GEMS_PETD_01",4d)	SL	t	Emission Present	k
3662	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](0070,0008)[<2>](2001,"Philips Imaging DD 001",c1)	LO	t	Presentation State Sequence:Graphic Annotation Sequence:Text Object Sequence:Linear Modality GL Transform	d
4235	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 004",89)[<1>](2005,"Philips MR Imaging DD 004",87)	UN	t	Presentation State Sequence:Viewing Protocol:Display Layout Number of Columns	d
5305	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 004",89)		t	Presentation State Sequence:Viewing Protocol	na
4675	(300a,03a2)[<0>](300a,0308)	CS	f	Ion Beam Sequence:Scan Mode	\N
5486	(07a1,"ELSCINT1",92)	ST	t	Unknown	d
743	(0009,"GEMS_PETD_01",25)	SL	t	Axial Acceptance	k
5674	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5d)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",45)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Thickness Sequence:Camera Thickness	k
5680	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",9a)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",38)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Referenced Frames Sequence:Referenced Syngo UID	d
5681	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",fd)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Application Type ID	d
5678	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",b5)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",f0)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Evaluation Text Position Sequence:Unknown	k
5487	(07a1,"ELSCINT1",9b)	ST	t	Unknown	d
5481	(07a3,"ELSCINT1",f2)	CS	t	Unknown	d
5677	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5f)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Sampling Distance	k
5074	(2005,"Philips MR Imaging DD 005",12)	OB	t	Diffusion B Value Number	k
636	(0009,"GEMS_PETD_01",8d)	FL	t	Attenuation Coefficient	k
5675	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",60)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Initial Sampling Distance	k
5266	(2005,"Philips MR Imaging DD 001",2a)	OB	t	Patient Reference ID	k
5283	(2005,"Philips MR Imaging DD 001",3d)	OB	t	Number of RR Interval Ranges	k
5472	(0099,"SIENET",02)	SL	t	DataObjectAttributes	d
3201	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
1372	(01f7,"ELSCINT1",18)	OW	t	Unknown	d
5315	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",5e)	CS	t	Series Volume:Volume View Axis	k
3140	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",41)	OB	t	Unknown:Unknown	d
1679	(0051,"SIEMENS MR HEADER",09)	LO	t	CSA Image Header Version	k
72	(0051,"SIEMENS MR HEADER",09)	OB	t	CSA Image Header Version	k
5274	(2001,"Philips Imaging DD 001",63)	OB	t	ExaminationSource	d
5488	(07a1,"ELSCINT1",8c)	ST	t	Unknown	d
5303	(2001,"Philips Imaging DD 002",76)	UN	t	Unknown	d
5477	(3711,"A.L.I. Technologies, Inc.",0e)	CS	t	Anonymization Status	d
4981	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 005",91)	SQ	t	Presentation State Sequence:Original Modality LUT Sequence	d
5107	(0009,"GEIIS",10)	OB	t	GE Private Image Thumbnail Sequence	d
5269	(2005,"Philips MR Imaging DD 001",1e)	OB	t	MIPProtocol	k
5485	(07a3,"ELSCINT1",f5)	LO	t	Unknown	d
1275	(0009,"GEIIS",10)[<0>](0028,0002)	US	t	GE Private Image Thumbnail Sequence:Samples per Pixel	na
5263	(2005,"Philips MR Imaging DD 001",2d)	OB	t	NumberOfStackSlices	k
4983	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,0018)	UI	t	Private Per-Frame Sequence:SOP Instance UID	na
2892	(00e1,"ELSCINT1",39)[<0>](0040,0275)[<1>](0040,0008)[<2>](0008,0102)	SH	t	Unknown:Request Attributes Sequence:Scheduled Protocol Code Sequence:Coding Scheme Designator	d
1484	(0019,"SIEMENS MR HEADER",08)	CS	t	Unknown	d
535	(0053,"GEHC_CT_ADVAPP_001",40)	SH	t	Iterative Recon Annotation	k
2999	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
4233	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 004",89)[<1>](2005,"Philips MR Imaging DD 004",85)	UN	t	Presentation State Sequence:Viewing Protocol:Image Display Direction	d
5060	(2005,"Philips MR Imaging DD 004",42)	OB	t	Signal Type	k
3202	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
5123	(2005,"Philips MR Imaging DD 004",39)	OB	t	Search Interval for Peaks	k
5494	(07a3,"ELSCINT1",f3)	CS	t	Unknown	d
5466	(01f1,"ELSCINT1",54)	UN	t	Unknown	d
3691	(0040,030e)[<0>](01e1,"ELSCINT1",26)	UN	t	Exposure Dose Sequence:Phantom Type	d
522	(0029,"GEMS_IMPS_01",18)	SL	t	UpperRangeOfPixels	k
2966	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
3768	(0079,"Unnamed Private Block - 10",0a)	DS	t	Unknown	d
1584	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",20)	UN	t	Unknown	d
5492	(07a3,"ELSCINT1",f7)	LO	t	Unknown	d
4031	(0019,"SIEMENS MR HEADER",0e)	UN	t	Diffusion Gradient Direction	d
5478	(07a3,"ELSCINT1",fb)	DT	t	Unknown	d
5301	(0070,0060)[<0>](0070,0401)	US	f	Graphic Layer Sequence:Graphic Layer Recommended Display CIELab Value	\N
5482	(0032,1064)[<0>](0008,010f)	CS	f	Requested Procedure Code Sequence:Context Identifier	\N
5483	(0008,1032)[<0>](0008,010f)	CS	f	Procedure Code Sequence:Context Identifier	\N
5471	(0008,0040)	SS	f	Data Set Type	\N
5470	(0012,0042)	LO	f	Clinical Trial Subject Reading ID	\N
5473	(0040,1001)	SH	f	Requested Procedure ID	\N
5302	(0070,0060)[<0>](0070,0067)	US	f	Graphic Layer Sequence:Graphic Layer Recommended Display RGB Value	\N
599	(0009,"GEMS_PETD_01",cc)	FL	t	vqc_x_axis_tilt	k
1375	(01f7,"ELSCINT1",11)	OW	t	Unknown	d
3192	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
750	(0009,"GEMS_PETD_01",73)	SL	t	frame_valid	k
3028	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3289	(3773,"Unnamed Private Block - 01",31)	SQ	t	Unknown	d
4223	(0011,"ULTRAVISUAL_TAG_SET1",12)	UN	t	Unknown	d
4039	(0019,"",09)	LO	t	Unknown	d
3789	(0019,"",09)	UN	t	Unknown	d
5056	(2005,"Philips MR Imaging DD 005",13)	OB	t	Gradient Orientation Number	k
3130	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
2907	(00e1,"ELSCINT1",39)[<0>](0040,0260)[<1>](0008,0104)	LO	t	Unknown:Performed Protocol Code Sequence:Code Meaning	d
5238	(2005,"Philips MR Imaging DD 001",16)	OB	t	Flow Compensation	k
5312	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",5c)	FL	t	Series Volume:Volume Offcentre RL	k
5522	(2005,"Philips MR Imaging DD 002",32)[<0>](2005,"Philips MR Imaging DD 002",43)	SL	t	Blob Data Object Array:Actual Blob Size	d
5519	(2005,"Philips MR Imaging DD 002",32)[<0>](2005,"Philips MR Imaging DD 002",47)	CS	t	Blob Data Object Array:Blob Flag	d
5518	(2005,"Philips MR Imaging DD 002",32)[<0>](2005,"Philips MR Imaging DD 002",44)	OW	t	Blob Data Object Array:Blob Data	d
5521	(0018,9169)	CS	f	Cardiac Beat Rejection Technique	\N
5513	(2005,"Philips MR Imaging DD 002",32)[<0>](2005,"Philips MR Imaging DD 002",37)	LO	t	Blob Data Object Array:Blob Name	d
5520	(0018,9085)	CS	f	Cardiac Signal Source	\N
5515	(2005,"Philips MR Imaging DD 002",32)[<0>](2005,"Philips MR Imaging DD 002",41)	LO	t	Blob Data Object Array:Comment String	d
5514	(2005,"Philips MR Imaging DD 002",32)[<0>](2005,"Philips MR Imaging DD 002",38)	LO	t	Blob Data Object Array:Application Name	d
5517	(2005,"Philips MR Imaging DD 002",32)[<0>](2005,"Philips MR Imaging DD 002",39)	LO	t	Blob Data Object Array:Type Name	d
5512	(2005,"Philips MR Imaging DD 002",32)	SQ	t	Blob Data Object Array	d
1821	(01f3,"ELSCINT1",01)	SQ	t	Unknown	d
5686	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5a)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Is Camera Required Flag	k
5116	(2005,"Philips MR Imaging DD 005",06)	OB	t	Number of PS Specific Character Sets	k
5141	(2001,"Philips Imaging DD 001",1a)	OB	t	PCVelocity	k
5685	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5c)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Directional Light Usage Flag	k
5684	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",85)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Rotation Center Usage Flag	k
5687	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",17)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Line-Z-Blend Flag	k
5688	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",51)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Thickness Usage Flag	k
5286	(2005,"Philips MR Imaging DD 001",60)	OB	t	Study Sequence Number	k
856	(0017,"GEMS_PETD_01",04)	DT	t	cal_datetime	o
5335	(0015,"GEMS_PETD_01",1f)	UN	t	PET Recon Parameters Exists	k
5323	(0015,"GEMS_PETD_01",32)	UN	t	Normalization Flag	k
5325	(0015,"GEMS_PETD_01",36)	UN	t	Unknown	d
5337	(0015,"GEMS_PETD_01",1d)	UN	t	Phase Matched Series	k
5330	(0015,"GEMS_PETD_01",37)	UN	t	Unknown	d
2126	(0009,"GEMS_GENIE_1",01)	SH	t	Unknown	d
3919	(0019,"",ae)	UN	t	Unknown	d
871	(0009,"GEMS_PETD_01",9d)	SL	t	Radial Filter 3D	k
647	(0009,"GEMS_PETD_01",9d)	SS	t	Radial Filter 3D	k
1387	(01f7,"ELSCINT1",2b)	OW	t	Unknown	d
2827	(01f7,"ELSCINT1",2b)	OB	t	Unknown	d
3631	(0045,"GEMS_FALCON_03",72)	IS	t	Collimator Width	d
347	(0021,"GEMS_RELA_01",36)	SS	t	ImageFromWhichPrescribed	k
4440	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a040)	CS	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Value Type	\N
5036	(0018,9181)	FD	f	Specific Absorption Rate Value	\N
4991	(0040,9210)	SH	f	LUT Label	\N
5343	(300a,0070)[<0>](300c,006a)	IS	f	Fraction Group Sequence:Referenced Patient Setup Number	\N
5318	(0008,1115)[<0>](0008,0054)	AE	f	Referenced Series Sequence:Retrieve AE Title	\N
5317	(0018,9183)	CS	f	Flow Compensation Direction	\N
4448	(0040,a730)[<0>](0040,a730)[<1>](0040,a504)[<2>](0008,0118)	UI	f	Content Sequence:Content Sequence:Content Template Sequence:Mapping Resource UID	\N
4435	(0040,a073)[<0>](0040,a075)	PN	f	Verifying Observer Sequence:Verifying Observer Name	\N
4436	(0040,a730)[<0>](0040,a123)	PN	f	Content Sequence:Person Name	\N
4433	(0040,a073)[<0>](0040,a027)	LO	f	Verifying Observer Sequence:Verifying Organization	\N
3633	(0018,704c)	DS	f	Grid Focal Distance	\N
4432	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a300)[<3>](0040,08ea)[<4>](0008,0104)	LO	f	Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Measurement Units Code Sequence:Code Meaning	\N
4445	(0040,a730)[<0>](0040,a504)[<1>](0008,0105)	CS	f	Content Sequence:Content Template Sequence:Mapping Resource	\N
4437	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a160)	UT	f	Content Sequence:Content Sequence:Content Sequence:Text Value	\N
4444	(0040,a730)[<0>](0040,a730)[<1>](0040,a504)[<2>](0008,0105)	CS	f	Content Sequence:Content Sequence:Content Template Sequence:Mapping Resource	\N
4443	(0040,a730)[<0>](0040,a504)[<1>](0040,db00)	CS	f	Content Sequence:Content Template Sequence:Template Identifier	\N
4969	(2005,"Philips MR Imaging DD 003",34)	SL	t	Number of Image Per Series Ref	k
4980	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 005",90)	SQ	t	Presentation State Sequence:Original VOI LUT Sequence	d
4979	(2005,"Philips MR Imaging DD 001",84)		t	Series Reference	k
5689	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",8a)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Rotation Axis Usage Flag	k
5692	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5b)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Do Depth Test Flag 	k
5040	(0018,9090)	FD	f	Velocity Encoding Direction	\N
5691	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",8a)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Rotation Axis Usage Flag	k
5690	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",85)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Rotation Center Usage Flag	k
4986	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,0013)	TM	t	Private Per-Frame Sequence:Instance Creation Time	na
5075	(2001,"Philips Imaging DD 001",88)	OB	t	Number of Averages	k
5215	(2005,"Philips MR Imaging DD 001",3c)	OB	t	Tilt Optimized Nonsaturated Excitation	k
5002	(0018,9101)	CS	f	Frequency Correction	\N
5097	(2005,"Philips MR Imaging DD 003",45)	OB	t	Number of Software Version	k
201	(0019,"GEMS_ACQU_01",04)	DS	t	CellSpacing	k
424	(0019,"GEMS_ACQU_01",90)	SS	t	PauseInterval	k
261	(0019,"GEMS_ACQU_01",2c)	SL	t	NumberOfTriggers	k
849	(0009,"GEMS_PETD_01",ad)	UI	t	trans_frame_id	h
1454	(0009,"GEIIS",0d)	UN	t	Unknown	d
384	(0043,"GEMS_PARM_01",60)	IS	t	Unknown	d
389	(0027,"GEMS_IMAG_01",62)	FL	t	NumberOfExcitations	k
1595	(0029,"MITRA OBJECT DOCUMENT 1.0",00)	LO	t	IMPAX Object Document	d
3970	(0009,"",e3)	UN	t	Unknown	d
470	(0019,"GEMS_ACQU_01",91)	DS	t	PulseTime	k
3659	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",aa)[<1>](0008,0018)	UI	t	Presentation State Sequence:Unknown:SOP Instance UID	d
5008	(0018,9199)	CS	f	Water Referenced Phase Correction	\N
5027	(0008,9207)	CS	f	Volume Based Calculation Technique	\N
5035	(0018,9155)	FD	f	Parallel Reduction Factor out-of-plane	\N
5043	(0018,9035)	FD	f	Tag Thickness	\N
4990	(0028,9002)	UL	f	Data Point Columns	\N
5023	(0018,9170)	CS	f	Respiratory Motion Compensation Technique	\N
4460	(0028,1102)	SS	f	Green Palette Color Lookup Table Descriptor	\N
3657	(0040,0320)	SQ	f	Billing Procedure Step Sequence	\N
4449	(0040,a730)[<0>](0040,a504)[<1>](0008,0118)	UI	f	Content Sequence:Content Template Sequence:Mapping Resource UID	\N
4452	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a121)	DA	f	Content Sequence:Content Sequence:Content Sequence:Date	\N
4458	(0012,0064)[<0>](0008,0103)	SH	f	De-identification Method Code Sequence:Coding Scheme Version	\N
4457	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a168)[<4>](0008,0104)	LO	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Concept Code Sequence:Code Meaning	\N
4456	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a168)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Concept Code Sequence	\N
4453	(0040,a073)[<0>](0040,a030)	DT	f	Verifying Observer Sequence:Verification DateTime	\N
4451	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0008,1199)[<3>](0062,000b)	US	f	Content Sequence:Content Sequence:Content Sequence:Referenced SOP Sequence:Referenced Segment Number	\N
4450	(0040,a504)[<0>](0008,0118)	UI	f	Content Template Sequence:Mapping Resource UID	\N
4461	(0028,1101)	SS	f	Red Palette Color Lookup Table Descriptor	\N
4459	(0028,1103)	SS	f	Blue Palette Color Lookup Table Descriptor	\N
5695	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",4b)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Image Maximum Height	k
5697	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",b5)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",09)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Evaluation Text Position Sequence:Measurement UID	h
5693	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3d)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Line Show Center Flag	k
3142	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",81)	OB	t	Unknown:Unknown	d
3149	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",34)	OB	t	Unknown:Unknown	d
5108	(2005,"Philips MR Imaging DD 004",82)	OB	t	Number of Procedure Codes	k
255	(0043,"GEMS_PARM_01",48)	SL	t	DASRegXm	k
2984	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
815	(01f1,"ELSCINT1",26)	DS	t	Pitch	k
2976	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",63)	OB	t	Unknown:Unknown	d
3692	(0040,030e)[<0>](01e3,"ELSCINT1",04)	UN	t	Exposure Dose Sequence:Unknown	d
1292	(0029,"SIEMENS MEDCOM HEADER",40)[<0>](0029,"SIEMENS MEDCOM HEADER",43)	LO	t	ApplicationHeaderSequence:ApplicationHeaderVersion	na
4318	(0137,"NetRAAD",20)	LO	t	Unknown	d
5025	(0018,9025)	CS	f	Spectrally Selected Suppression	\N
4198	(0043,"GEMS_PARM_01",7f)	DS	t	Reserved	d
3681	(0040,030e)[<0>](0018,0010)	LO	f	Exposure Dose Sequence:Contrast/Bolus Agent	\N
5012	(0018,9018)	CS	f	Echo Planar Pulse Sequence	\N
5038	(0018,9053)	FD	f	Chemical Shift Reference	\N
3677	(0040,030e)[<0>](0040,0310)	ST	f	Exposure Dose Sequence:Comments on Radiation Dose	\N
3685	(0040,030e)[<0>](0018,9330)	FD	f	Exposure Dose Sequence:X-Ray Tube Current in mA	\N
4479	(0038,0030)	DA	f	Discharge Date	\N
3682	(0040,030e)[<0>](0018,1030)	LO	f	Exposure Dose Sequence:Protocol Name	\N
4471	(4008,0212)	CS	f	Interpretation Status ID	\N
3679	(0040,030e)[<0>](0018,1151)	IS	f	Exposure Dose Sequence:X-Ray Tube Current	\N
3678	(0040,030e)[<0>](0018,1152)	IS	f	Exposure Dose Sequence:Exposure	\N
4462	(3006,0020)[<0>](3006,0038)	LO	f	Structure Set ROI Sequence:ROI Generation Description	\N
3686	(0040,030e)[<0>](0018,9073)	FD	f	Exposure Dose Sequence:Acquisition Duration	\N
4470	(4008,0210)	CS	f	Interpretation Type ID	\N
4465	(0020,0019)	IS	f	Item Number	\N
3680	(0040,030e)[<0>](0008,3010)	UI	f	Exposure Dose Sequence:Irradiation Event UID	\N
3861	(0019,"",b6)	UN	t	Unknown	d
497	(0019,"GEMS_ACQU_01",df)	DS	t	UserData	d
5278	(2005,"Philips MR Imaging DD 005",15)	OB	t	Number of Diffusion Gradient Orientations	k
5262	(2005,"Philips MR Imaging DD 004",92)	OB	t	Geolink ID	k
5698	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",08)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",09)	UN	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Measurement Sequence:Measurement UID	h
5699	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",b5)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",b7)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Evaluation Text Position Sequence:Measurement Evaluation Text Position Vector	k
2967	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
3709	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",0d)	FL	t	Harmonization Gain	d
2780	(0020,9128)	UL	f	Temporal Position Index	\N
3710	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",15)	SS	t	Unknown	d
4998	(0018,9051)	CS	f	Transmit Coil Type	\N
3712	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",0e)	SS	t	Edge Enhancement Kernel	d
766	(0009,"GEMS_PETD_01",20)	SL	t	Collect Count Rate	k
3711	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",11)	SS	t	Unknown	d
873	(0009,"GEMS_PETD_01",c1)	SL	t	AC Img Smooth	k
646	(0009,"GEMS_PETD_01",c1)	SS	t	AC Img Smooth	k
5344	(300a,00b0)[<0>](300a,00b6)[<1>](300a,011c)	DS	f	Beam Sequence:Beam Limiting Device Sequence:Leaf/Jaw Positions	\N
1359	(01f1,"ELSCINT1",47)	SH	t	Unknown	d
2845	(01f1,"ELSCINT1",47)	OB	t	Unknown	d
1384	(01f7,"ELSCINT1",70)	OW	t	Unknown	d
2824	(01f7,"ELSCINT1",70)	OB	t	Unknown	d
5484	(07a3,"ELSCINT1",fa)	DT	t	Unknown	d
4088	(700d,"TOSHIBA_MEC_MR3",02)	DS	t	Orientation Vector	d
5220	(2005,"Philips MR Imaging DD 001",26)	OB	t	Over Sampling Phase	k
3904	(0043,"",98)	UN	t	Unknown	d
3260	(0029,"INTELERAD MEDICAL SYSTEMS",21)	US	t	HistogramPercentileLabels	d
5207	(2005,"Philips MR Imaging DD 001",39)	OB	t	Steady State	k
3856	(0029,"",26)	UN	t	Unknown	d
3047	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",73)	OB	t	Unknown:Unknown	d
1218	(0013,"CTP",11)	LO	t	Trial Name	k
675	(0009,"GEMS_PETD_01",3b)	LO	t	Administered Date Time	o
860	(0009,"GEMS_PETD_01",3b)	DT	t	Administered Date Time	o
264	(0043,"GEMS_PARM_01",1f)	SL	t	MaxOverrangesInAView	k
870	(0009,"GEMS_PETD_01",b3)	SL	t	IR Num Subsets	k
2735	(0008,1111)[<0>](2005,"Philips MR Imaging DD 005",04)	SS	t	Referenced Performed Procedure Step Sequence:Unknown	k
2332	(0008,1111)[<0>](2005,"Philips MR Imaging DD 005",06)	SS	t	Referenced Performed Procedure Step Sequence:Number of PS Specific Character Sets	k
2606	(0009,"EMAGEON JPEG2K INFO",00)[<0>](0023,"Unnamed Private Block - 20",13)	IS	t	Unknown:Unknown	na
2605	(0009,"EMAGEON JPEG2K INFO",00)[<0>](0023,"Unnamed Private Block - 20",15)[<1>](0023,"Unnamed Private Block - 20",16)	IS	t	Unknown:Unknown:Unknown	na
2170	(0009,"GEIIS",10)[<0>](0028,0006)	US	t	GE Private Image Thumbnail Sequence:Planar Configuration	k
1287	(0009,"GEMS_GENIE_1",46)	UN	t	Unknown	d
3770	(0079,"Unnamed Private Block - 10",14)	DS	t	Unknown	d
3850	(0021,"",57)	UN	t	Unknown	d
5115	(2005,"Philips MR Imaging DD 005",4a)	OB	t	Data Window Duration	k
5309	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",57)	FL	t	Series Volume:Volume FOV AP	k
5021	(0020,9072)	CS	f	Frame Laterality	\N
5044	(0018,9069)	FD	f	Parallel Reduction Factor In-plane	\N
5345	(300a,0070)[<0>](300a,00c6)	CS	f	Fraction Group Sequence:Radiation Type	\N
5007	(0018,9022)	CS	f	Blood Signal Nulling	\N
1878	(0009,"EMAGEON STUDY HOME",00)	UN	t	Unknown	d
4380	(0015,"GEMS_PETD_01",31)	UL	t	Recon Algorithm	k
1876	(0009,"EMAGEON STUDY HOME",01)	UN	t	Unknown	d
2169	(0009,"GEIIS",10)[<0>](0028,0120)	SS	t	GE Private Image Thumbnail Sequence:Pixel Padding Value	k
2761	(0009,"IMBIO JSON REPORT CONTENTS",00)	UN	t	Unknown	d
5702	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",01)	UN	t	Advanced Presentation Sequence:Presentation Type	k
1697	(0013,"CTP",20)	LO	t	Unknown	d
2589	(0019,"SIEMENS DLR.01",90)	LO	t	PLAOfSecondaryDestination	k
3855	(0019,"",81)	UN	t	Unknown	d
3088	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",32)	OB	t	Unknown:Unknown	d
233	(0021,"GEMS_RELA_01",92)	FL	t	BiopsyTLocation	k
5213	(2005,"Philips MR Imaging DD 001",36)	OB	t	StackType	k
1293	(0029,"SIEMENS MEDCOM HEADER",40)[<0>](0029,"SIEMENS MEDCOM HEADER",42)	LO	t	ApplicationHeaderSequence:ApplicationHeaderID	na
2961	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",15)	OB	t	Unknown:Unknown	d
4364	(07a3,"ELSCINT1",5c)	UN	t	Unknown	d
4463	(2111,"Viztek OPALRAD PrivateGroup",10)	UT	t	Unknown	d
4387	(0015,"GEMS_PETD_01",25)	SL	t	BP3d Filter OrderU	k
5032	(0018,9029)	CS	f	Oversampling Phase	\N
5018	(0018,9017)	CS	f	Steady State Pulse Sequence	\N
2777	(0029,"MITRA PRESENTATION 1.0",02)	UN	t	Window Centre	k
2776	(0029,"MITRA PRESENTATION 1.0",03)	LO	t	Invert	k
2766	(0031,"AGFA PACS Archive Mirroring 1.0",00)	LT	t	Unknown	d
2624	(0051,"GEMS_FUNCTOOL_01",01)	UN	t	Group Name	k
2587	(0013,"CTP",50)	UN	t	Year of Study	d
1882	(0073,"STENTOR",04)	ST	t	Unknown	d
2629	(0051,"GEMS_FUNCTOOL_01",02)	UN	t	Function Name	k
2262	(2001,"Philips Imaging DD 001",09)	FL	t	Image Prepulse Delay	k
1879	(0097,"SIENET",03)	UN	t	Unknown	d
2626	(0051,"GEMS_FUNCTOOL_01",04)	UN	t	Scale	k
2218	(2001,"Philips Imaging DD 001",02)	IS	t	ChemicalShiftNumberMR	k
2288	(2001,"Philips Imaging DD 001",03)	FL	t	DiffusionB-Factor	k
2500	(2001,"Philips Imaging DD 001",07)	CS	t	ImageTypeEDES	k
2480	(2001,"Philips Imaging DD 001",0c)	CS	t	Arrhythmia Rejection	k
2631	(0051,"GEMS_FUNCTOOL_01",05)	UN	t	Parameter Count	k
2627	(0051,"GEMS_FUNCTOOL_01",06)	UN	t	Parameters	k
2628	(0051,"GEMS_FUNCTOOL_01",07)	UN	t	Version	k
2633	(0051,"GEMS_FUNCTOOL_01",08)	UN	t	Color Ramp Index	k
2625	(0051,"GEMS_FUNCTOOL_01",0b)	UN	t	B-Value	k
2483	(2001,"Philips Imaging DD 001",0e)	CS	t	Cardiac Cycled	k
2280	(2001,"Philips Imaging DD 001",11)	FL	t	DiffusionEchoTime	k
2461	(2001,"Philips Imaging DD 001",12)	CS	t	DynamicSeries	k
2572	(2001,"Philips Imaging DD 001",13)	SL	t	EPIFactor	k
2335	(2001,"Philips Imaging DD 001",16)	SS	t	NumberOfPCDirections	k
2569	(2001,"Philips Imaging DD 001",17)	SL	t	NumberOfPhasesMR	k
2580	(2001,"Philips Imaging DD 001",18)	SL	t	NumberOfSlicesMR	k
4358	(07a3,"ELSCINT1",b9)	UN	t	Unknown	d
4363	(07a5,"ELSCINT1",ae)	UN	t	Unknown	d
3728	(0018,1180)	SH	f	Collimator/grid Name	\N
4476	(1111,"2.16.840.1.114330.1.1.1.1",23)	FD	t	Unknown	d
4372	(0015,"GEMS_PETD_01",26)	UL	t	BP3d Filter FlagV	k
4488	(0043,"GEMS_PARM_01",6b)	US	t	L-MDK Correction Indicator	k
4496	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",91)	LO	t	Object Action Sequence:Software Title	d
4382	(0015,"GEMS_PETD_01",21)	FL	t	IR Loop Filter Ratio	k
4052	(0031,"",00)	CS	t	Unknown	d
3820	(0031,"",00)	UN	t	Unknown	d
5204	(2001,"Philips Imaging DD 001",18)	OB	t	NumberOfSlicesMR	k
4524	(0040,0275)[<0>](0020,000d)	UI	f	Request Attributes Sequence:Study Instance UID	\N
4060	(0051,"",15)	SH	t	Unknown	d
3824	(0051,"",15)	UN	t	Unknown	d
3787	(0051,"",09)	UN	t	Unknown	d
4521	(0040,0275)[<0>](0008,1110)	SQ	f	Request Attributes Sequence:Referenced Study Sequence	\N
5039	(0020,9255)	FD	f	Nominal Respiratory Trigger Delay Time	\N
3742	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",02)	US	t	Unknown	d
5704	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",44)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Near Clip Plane	k
5703	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",15)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Auto Navigation Frame Rate	k
3750	(0021,"Siemens: Thorax/Multix FD Post Processing",09)	SL	t	Auto Window Center	d
3863	(0043,"",89)	UN	t	Unknown	d
3873	(0025,"",11)	UN	t	Unknown	d
3868	(0021,"",37)	UN	t	Unknown	d
3046	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",72)	OB	t	Unknown:Unknown	d
3090	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",61)	OB	t	Unknown:Unknown	d
3094	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",51)	OB	t	Unknown:Unknown	d
5118	(2005,"Philips MR Imaging DD 004",26)	OB	t	Spectro B0 Echo Top Position	k
5222	(2005,"Philips MR Imaging DD 005",3b)	OB	t	Is Coil Survey	k
3807	(0051,"",0f)	UN	t	Unknown	d
5332	(0015,"GEMS_PETD_01",20)	UN	t	First Packet Number	d
3748	(0019,"Siemens: Thorax/Multix FD Lab Settings",08)	US	t	Ortho Step Distance	d
4209	(5653,"",15)[<0>](0020,0032)	DS	t	Unknown:Image Position (Patient)	d
1021	(7005,"TOSHIBA_MEC_CT3",09)	LO	t	Number of Detector rows to Reconstruct	k
5300	(0008,1115)[<0>](2001,"Philips Imaging DD 001",c1)	LO	t	Referenced Series Sequence:Linear Modality GL Transform	d
3735	(0021,"Siemens: Thorax/Multix FD Post Processing",0e)	US	t	Dose Control Value	d
1880	(0099,"SIENET",05)	SL	t	Unknown	d
3897	(0043,"",37)	UN	t	Unknown	d
5133	(2005,"Philips MR Imaging DD 003",53)	OB	t	Number of Study Patient Medical Alerts	k
5010	(0018,9015)	CS	f	Time of Flight Contrast	\N
5022	(0018,9077)	CS	f	Parallel Acquisition	\N
1855	(01f7,"ELSCINT1",73)	OW	t	Unknown	d
1935	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",80)	US	t	Unknown:Unknown	d
1937	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a1,"ELSCINT1",78)	SL	t	Unknown:Unknown:Unknown	d
2455	(2001,"Philips Imaging DD 001",19)	CS	t	PartialMatrixScanned	k
2259	(2001,"Philips Imaging DD 001",1b)	FL	t	PrepulseDelay	k
2421	(2001,"Philips Imaging DD 001",1c)	CS	t	PrepulseType	k
2205	(2001,"Philips Imaging DD 001",1d)	IS	t	ReconstructionNumberMR	k
1877	(0013,"CTP",20)	UN	t	Unknown	d
4536	(0040,0275)[<0>](0032,1060)	LO	f	Request Attributes Sequence:Requested Procedure Description	\N
4527	(0040,0275)[<0>](0032,1064)[<1>](0008,0102)	SH	f	Request Attributes Sequence:Requested Procedure Code Sequence:Coding Scheme Designator	\N
4538	(0008,1050)	PN	f	Performing Physician's Name	\N
4537	(0010,1080)	LO	f	Military Rank	\N
4532	(0040,0275)[<0>](0032,1064)[<1>](0008,0100)	SH	f	Request Attributes Sequence:Requested Procedure Code Sequence:Code Value	\N
4519	(0040,0275)	SQ	f	Request Attributes Sequence	\N
4530	(0040,0275)[<0>](0040,0008)[<1>](0008,0100)	SH	f	Request Attributes Sequence:Scheduled Protocol Code Sequence:Code Value	\N
3206	(0019,"FDMS 1.0",40)	OB	t	ImageProcessingType	d
3719	(0021,"Siemens: Thorax/Multix FD Post Processing",0b)	SS	t	Filter ID	d
4541	(0088,0200)[<0>](0028,1101)	OW	f	Icon Image Sequence:Red Palette Color Lookup Table Descriptor	\N
3763	(0010,1001)	PN	f	Other Patient Names	\N
4359	(07a1,"ELSCINT1",58)	UN	t	Unknown	d
4478	(1111,"2.16.840.1.114330.1.1.1.1",13)	SL	t	Unknown	d
4502	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",08)	OB	t	Unknown	d
3135	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",a1)	OB	t	Unknown:Unknown	d
5164	(2005,"Philips MR Imaging DD 005",28)	OB	t	Number of Label Types	k
4474	(1111,"2.16.840.1.114330.1.1.1.1",12)	FD	t	Unknown	d
4512	(5001,"vRad PACS",73)	UN	t	Unknown	d
4371	(0015,"GEMS_PETD_01",34)	UL	t	Emission Random Flag	k
4517	(5001,"vRad PACS",55)	UN	t	Unknown	d
4487	(0043,"GEMS_PARM_01",69)	US	t	Q-cal Correction Indicator	k
4492	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",a1)	ST	t	Object Action Sequence:Object Action	d
4501	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",a2)	DA	t	Object Action Sequence:Object Action Date	d
4511	(0095,"SIENET",0c)	UL	t	Unknown	d
1664	(00e1,"ELSCINT1",39)		t	Unknown	d
2880	(00e1,"ELSCINT1",39)	SQ	t	Unknown	d
3136	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",a3)	OB	t	Unknown:Unknown	d
2864	(01f3,"ELSCINT1",01)[<0>](01f3,"ELSCINT1",03)	OB	t	Unknown:Unknown	d
2994	(0029,"FDMS 1.0",30)	OB	t	ExtendedReadingSizeValue	d
286	(0043,"GEMS_PARM_01",14)	SS	t	CalibrationParameters	k
3827	(0027,"",30)	UN	t	Unknown	d
2877	(00e1,"ELSCINT1",39)[<0>](0008,1110)	SQ	t	Unknown:Referenced Study Sequence	d
1708	(0051,"GEMS_FUNCTOOL_01",03)	SL	t	Bias	k
4370	(0015,"GEMS_PETD_01",32)	UL	t	Normalization Flag	k
3780	(0040,9096)[<0>](0040,9211)	US	f	Real World Value Mapping Sequence:Real World Value Last Value Mapped	\N
3781	(0040,9096)[<0>](0040,9216)	US	f	Real World Value Mapping Sequence:Real World Value First Value Mapped	\N
5257	(2005,"Philips MR Imaging DD 005",1c)	OB	t	Version Number Deleted Spectra	k
4507	(0009,"HMC - CT - ID",01)	OB	t	Image ID Information Patient Comment	d
4974	(2005,"Philips MR Imaging DD 001",9e)		t	Series Geometry	k
4540	(0088,0200)[<0>](7fe0,0010)	OB	f	Icon Image Sequence:Pixel Data	\N
5066	(2005,"Philips MR Imaging DD 001",9e)	OB	t	Series Geometry	k
2736	(2001,"Philips Imaging DD 002",6b)	LO	t	Unknown	d
2653	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 005",36)	UI	t	Series Reference:Referenced Series Instance UID	h
2182	(2005,"Philips MR Imaging DD 001",85)	SQ	t	Series Volume	k
2689	(2005,"Philips MR Imaging DD 001",9f)	CS	t	SeriesSpectral Selective Excitation Pulse	k
2285	(2005,"Philips MR Imaging DD 001",a0)	FL	t	Dynamic Scan Begin Time	k
2519	(2005,"Philips MR Imaging DD 001",a9)	CS	t	Geometry Correction	k
2291	(2005,"Philips MR Imaging DD 001",b1)	FL	t	Diffusion Direction AP	k
2709	(2005,"Philips MR Imaging DD 002",34)	UN	t	Series Transaction UID	d
2738	(2005,"Philips MR Imaging DD 002",34)	LT	t	Series Transaction UID	d
2192	(2005,"Philips MR Imaging DD 002",99)	UL	t	Number of Request Excerpts	k
2199	(2005,"Philips MR Imaging DD 003",01)	UL	t	Number of Film Consumption	k
2331	(2005,"Philips MR Imaging DD 003",49)	SS	t	Number of Series Operators Name	d
2336	(2005,"Philips MR Imaging DD 003",51)	SS	t	Number of Study Admitting Diagnostic Description	k
2310	(2005,"Philips MR Imaging DD 003",52)	SS	t	Number of Study Patient Contrast Allergies	k
2313	(2005,"Philips MR Imaging DD 003",53)	SS	t	Number of Study Patient Medical Alerts	k
4483	(0043,"GEMS_PARM_01",6e)	SH	t	Auto mA Mode	k
4369	(0015,"GEMS_PETD_01",29)	UL	t	Decay Flag	k
4481	(0043,"GEMS_PARM_01",6c)	IS	t	Detector Row	k
3773	(0040,0006)	PN	f	Scheduled Performing Physician's Name	\N
4542	(0088,0200)[<0>](0028,1102)	OW	f	Icon Image Sequence:Green Palette Color Lookup Table Descriptor	\N
3772	(0008,1040)	LO	f	Institutional Department Name	\N
4539	(0008,0081)	ST	f	Institution Address	\N
3756	(0008,0201)	SH	f	Timezone Offset From UTC	\N
4543	(0088,0200)[<0>](0028,1103)	OW	f	Icon Image Sequence:Blue Palette Color Lookup Table Descriptor	\N
3775	(0040,0241)	AE	f	Performed Station AE Title	\N
4506	(0019,"SIEMENS CT VA0  COAD",b1)	LO	t	Unknown	d
4504	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",02)	OB	t	Unknown	d
4494	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",92)	SH	t	Object Action Sequence:Software Version	d
4353	(07a5,"ELSCINT1",56)	UN	t	Unknown	d
4368	(0015,"GEMS_PETD_01",33)	UL	t	Emission Deadtime Flag	k
4355	(07a1,"ELSCINT1",98)	UN	t	Unknown	d
4361	(07a5,"ELSCINT1",69)	UN	t	Unknown	d
4378	(0015,"GEMS_PETD_01",2e)	UL	t	Image filter 3d flag	k
4468	(1111,"2.16.840.1.114330.1.1.1.1",19)	SS	t	Unknown	d
4490	(2111,"Viztek OPALRAD PrivateGroup",10)	UN	t	Unknown	d
4514	(5001,"vRad PACS",71)	UN	t	Unknown	d
4467	(1111,"2.16.840.1.114330.1.1.1.1",01)	UT	t	Unknown	d
4384	(0015,"GEMS_PETD_01",27)	FL	t	BP3d Filter OrderV	k
4480	(07a1,"ELSCINT1",36)	AE	t	Unknown	d
284	(0019,"GEMS_ACQU_01",11)	SS	t	SeriesContrast	k
2138	(0009,"GEMS_GENIE_1",41)	SL	t	PatientFlags	d
5707	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",48)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Projection Type	k
3184	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",96)	OB	t	Unknown:Unknown	d
5137	(2005,"Philips MR Imaging DD 005",03)	OB	t	Number of SPS Codes	k
1524	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",5c)	UN	t	Unknown	d
3881	(0019,"",c8)	UN	t	Unknown	d
399	(0019,"GEMS_ACQU_01",98)	SS	t	CenterFrequencyMethod	k
3073	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
3905	(0043,"",08)	UN	t	Unknown	d
3285	(01f7,"ELSCINT1",93)	UN	t	Unknown	d
3291	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0028,0030)	DS	t	Unknown:Unknown:Pixel Spacing	d
4063	(0051,"",0a)	LO	t	Unknown	d
1072	(0019,"SIEMENS CT VA0  COAD",93)	DS	t	OsteoRegressionLineIntercept	k
1266	(0009,"GEIIS",10)[<0>](0028,1051)	DS	t	GE Private Image Thumbnail Sequence:Window Width	na
5089	(2005,"Philips MR Imaging DD 001",29)	OB	t	PartialFourierPhase	k
3882	(0019,"",90)	UN	t	Unknown	d
3191	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
5191	(2001,"Philips Imaging DD 001",1f)	OB	t	RespirationSync	k
3239	(300a,0010)[<0>](300d,"TOMO_HA_01",16)	UN	t	Dose Reference Sequence:Unknown	d
396	(0019,"GEMS_ACQU_01",8a)	SS	t	ActualReceiveGainAnalog	k
352	(0045,"GEMS_HELIOS_01",22)	SS	t	PeristalticFlag	k
3065	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",52)	OB	t	Unknown:Unknown	d
3894	(0043,"",90)	UN	t	Unknown	d
4390	(0015,"GEMS_PETD_01",1d)	SL	t	Phase Matched Series	k
307	(0019,"GEMS_ACQU_01",15)	SS	t	StartNumberForEnhancedScans	k
5093	(2005,"Philips MR Imaging DD 001",15)	OB	t	Fat Saturation	k
1280	(0009,"GEMS_IDEN_01",05)	UN	t	Unknown	d
1314	(00e1,"ELSCINT1",c2)	UI	t	Unknown	d
3672	(2001,"Philips Imaging DD 002",6d)	UN	t	Unknown	d
3025	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
879	(0043,"GEMS_PARM_01",97)	LO	t	Image Filtering Parameters	k
3061	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",90)	OB	t	Unknown:Unknown	d
421	(0019,"GEMS_ACQU_01",88)	SS	t	ImagesPerCardiacCycle	k
3636	(0011,"GEMS_GDXE_FALCON_04",76)	UN	t	Unknown	d
3645	(0011,"GEMS_GDXE_FALCON_04",65)	UN	t	Unknown	d
1279	(0009,"GEMS_IDEN_01",3b)	UN	t	Unknown	d
1559	(0025,"GEMS_SERS_01",18)	SL	t	NumberOfImagesArchived	k
528	(0021,"GEMS_RELA_01",59)	SL	t	IntegerSlop	k
1221	(0013,"CTP",12)	LO	t	Site Name	k
4547	(0054,0016)[<0>](0054,0304)[<1>](0008,0106)	DT	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Code Sequence:Context Group Version	\N
4550	(0008,1250)[<0>](0040,a170)[<1>](0008,0105)	CS	f	Related Series Sequence:Purpose of Reference Code Sequence:Mapping Resource	\N
4559	(0008,3001)[<0>](0008,0018)	UI	f	Alternate Representation Sequence:SOP Instance UID	\N
4557	(0008,3001)	SQ	f	Alternate Representation Sequence	\N
4560	(0008,3001)[<0>](0020,000e)	UI	f	Alternate Representation Sequence:Series Instance UID	\N
4472	(1111,"2.16.840.1.114330.1.1.1.1",10)	FD	t	Unknown	d
4485	(0043,"GEMS_PARM_01",6a)	US	t	AV Correction Indicator	k
3939	(0019,"",d7)	UN	t	Unknown	d
2603	(0009,"EMAGEON JPEG2K INFO",00)	SQ	t	Unknown	d
2602	(0009,"EMAGEON JPEG2K INFO",00)[<0>](0023,"Unnamed Private Block - 20",15)	SQ	t	Unknown:Unknown	na
1811	(0009,"GEIIS",10)[<0>](7fe0,0010)	OB	t	GE Private Image Thumbnail Sequence:Pixel Data	na
2795	(07a1,"ELSCINT1",10)	OB	t	Unknown	d
3938	(0043,"",0c)	UN	t	Unknown	d
3935	(0025,"",14)	UN	t	Unknown	d
4503	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",06)	OB	t	Unknown	d
397	(0019,"GEMS_ACQU_01",94)	SS	t	TransmitGain	k
3053	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
3157	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
2140	(0009,"GEMS_GENIE_1",11)	SL	t	StudyFlags	d
3937	(0043,"",34)	UN	t	Unknown	d
4029	(0029,"",10)	CS	t	Unknown	d
2943	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",40)	SQ	t	Unknown:Unknown	d
1452	(0019,"Unnamed Private Block - 10",04)	UN	t	Unknown	d
3811	(0029,"",10)	UN	t	Unknown	d
779	(0009,"GEMS_PETD_01",c3)	SL	t	Scatter Method	k
3702	(0021,"Siemens: Thorax/Multix FD Post Processing",07)	FL	t	Unknown	d
3121	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",41)	OB	t	Unknown:Unknown	d
3630	(0045,"GEMS_FALCON_03",73)	IS	t	Collimator Height	d
3977	(0043,"",38)	UN	t	Unknown	d
1029	(7005,"TOSHIBA_MEC_CT3",13)	US	t	Expert Plan Number	k
513	(0021,"GEMS_RELA_01",51)	DS	t	RotationFromSourceXRot	k
3026	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
1579	(0025,"GEMS_SERS_01",19)	SL	t	LastImageNumberUsed	k
1854	(00e1,"ELSCINT1",21)	DS	t	DLP Total	k
1788	(00e1,"ELSCINT1",24)	CS	t	Unknown	d
1013	(7005,"TOSHIBA_MEC_CT3",0b)	SH	t	Filter	k
155	(0009,"GEMS_IDEN_01",30)	SH	t	ServiceId	d
810	(01f1,"ELSCINT1",0c)	DS	t	Scanner Relative Center	k
1784	(00e1,"ELSCINT1",25)	CS	t	Unknown	d
1820	(01f3,"ELSCINT1",11)	SQ	t	Unknown	d
2802	(01f1,"ELSCINT1",0c)	OB	t	Scanner Relative Center	d
1361	(07a1,"ELSCINT1",10)	LO	t	Unknown	d
1835	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",16)	FL	t	Unknown:Unknown	d
1839	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",19)	FL	t	Unknown:Unknown	d
1841	(01f3,"ELSCINT1",12)	SS	t	Unknown	d
2326	(2005,"Philips MR Imaging DD 004",57)	SS	t	Spectro Spectral BW	k
1789	(07a1,"ELSCINT1",47)	CS	t	Unknown	d
1934	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a1,"ELSCINT1",7a)	US	t	Unknown:Unknown:Unknown	d
1776	(07a3,"ELSCINT1",62)[<0>](07a3,"ELSCINT1",61)	LT	t	Unknown:Unknown	d
1953	(07a3,"ELSCINT1",80)[<0>](0070,0101)	DS	t	Unknown:Presentation Pixel Spacing	d
1912	(07a3,"ELSCINT1",8f)	CS	t	Unknown	d
1738	(07a3,"ELSCINT1",b9)	CS	t	Unknown	d
1733	(07a3,"ELSCINT1",bb)	CS	t	Unknown	d
1750	(07a3,"ELSCINT1",c0)	SQ	t	Unknown	d
1779	(07a3,"ELSCINT1",c0)[<0>](07a3,"ELSCINT1",c3)	CS	t	Unknown:Unknown	d
1761	(07a3,"ELSCINT1",c0)[<0>](07a3,"ELSCINT1",c5)	LO	t	Unknown:Unknown	d
1758	(07a3,"ELSCINT1",c6)[<0>](07a3,"ELSCINT1",c1)	LO	t	Unknown:Unknown	d
2403	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9018)	CS	t	Private Per-Frame Sequence:Echo Planar Pulse Sequence	na
2698	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9019)	FD	t	Private Per-Frame Sequence:Tag Angle First Axis	na
2396	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9051)	CS	t	Private Per-Frame Sequence:Transmit Coil Type	na
2289	(2005,"Philips MR Imaging DD 005",43)	FL	t	Active Implantable Medical Device dbDt Limit	k
2720	(4453,"DR Systems, Inc.",0c)[<0>](0008,1115)[<1>](0020,000e)	UI	t	Original Instance UID Sequence:Referenced Series Sequence:Series Instance UID	na
2718	(4453,"DR Systems, Inc.",0c)[<0>](0020,000d)	UI	t	Original Instance UID Sequence:Study Instance UID	na
1016	(7005,"TOSHIBA_MEC_CT3",12)	SH	t	Position (supine or prone)	k
2921	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",50)	SQ	t	Unknown:Unknown	d
4509	(0019,"SET WINDOW",00)	SH	t	Set Window Image Filter	d
1051	(0053,"GEHC_CT_ADVAPP_001",7b)	UN	t	MultiEnergyNoiseReduced	k
1745	(0009,"EMAGEON STUDY HOME",00)	LO	t	Unknown	d
1744	(0009,"EMAGEON STUDY HOME",01)	LO	t	Unknown	d
2168	(0009,"GEIIS",12)	IS	t	Unknown	d
2165	(7fd1,"GEIIS",50)	UL	t	Subband Columns	k
236	(0027,"GEMS_IMAG_01",45)	FL	t	NormalRCoord	k
1396	(3711,"A.L.I. Technologies, Inc.",0c)	UI	t	Original Study UID	h
3699	(0021,"Siemens: Thorax/Multix FD Post Processing",0c)	FL	t	Unknown	d
3141	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",70)	OB	t	Unknown:Unknown	d
4000	(0019,"",1e)	UN	t	Unknown	d
1681	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",66)	UN	t	Unknown	d
5281	(2005,"Philips MR Imaging DD 005",1a)	OB	t	Fat Saturation Technique	k
4011	(0019,"",a1)	UN	t	Unknown	d
2134	(0011,"GEMS_GENIE_1",45)	FD	t	ThresholdWidth	d
1551	(07a1,"ELSCINT1",85)	UL	t	Unknown	d
1140	(0009,"GEMS_PETD_01",76)	SL	t	compression	k
2859	(01f3,"ELSCINT1",23)	OB	t	Unknown	d
4555	(0043,"GEMS_PARM_01",b3)	UN	t	Unknown	d
4561	(0071,"SIEMENS MED PT",22)	DT	t	Decay Correction DateTime	o
731	(0009,"GEMS_PETD_01",72)	FD	t	total_delays	d
888	(0043,"GEMS_PARM_01",96)	CS	t	Content Qualification	k
5710	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",4d)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Parallel Shift Interval MM	k
3181	(0009,"FDMS 1.0",90)	OB	t	DistributionCode	d
2611	(0023,"GEMS_STDY_01",80)[<0>](0032,1064)	SQ	t	Has MPPS Related Tags:Requested Procedure Code Sequence	d
2613	(0023,"GEMS_STDY_01",80)[<0>](0032,1064)[<1>](0008,0100)	SH	t	Has MPPS Related Tags:Requested Procedure Code Sequence:Code Value	d
2612	(0023,"GEMS_STDY_01",80)[<0>](0032,1064)[<1>](0008,0102)	SH	t	Has MPPS Related Tags:Requested Procedure Code Sequence:Coding Scheme Designator	d
3841	(0043,"",1c)	UN	t	Unknown	d
2890	(00e1,"ELSCINT1",39)[<0>](0008,1032)[<1>](0008,0102)	SH	t	Unknown:Procedure Code Sequence:Coding Scheme Designator	d
3997	(0043,"",0e)	UN	t	Unknown	d
1627	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",5b)	UN	t	Unknown	d
1647	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",63)	UN	t	Unknown	d
2619	(0023,"GEMS_STDY_01",80)[<0>](0040,0255)	LO	t	Has MPPS Related Tags:Performed Procedure Type Description	d
2616	(0023,"GEMS_STDY_01",80)[<0>](0040,2016)	LO	t	Has MPPS Related Tags:Placer Order Number / Imaging Service Request	d
2617	(0023,"GEMS_STDY_01",80)[<0>](0040,2017)	LO	t	Has MPPS Related Tags:Filler Order Number / Imaging Service Request	d
228	(0027,"GEMS_IMAG_01",47)	FL	t	NormalSCoord	k
5712	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a6)	UN	t	Advanced Presentation Sequence:Presentation Version Identifier	k
250	(0025,"GEMS_SERS_01",07)	SL	t	ImagesInSeries	k
3987	(0029,"",34)	UN	t	Unknown	d
3989	(0019,"",1a)	UN	t	Unknown	d
3988	(0019,"",8a)	UN	t	Unknown	d
2778	(0029,"MITRA PRESENTATION 1.0",01)	UN	t	Window Width	k
2594	(0029,"SIEMENS MED DISPLAY",10)	US	t	RowsOfSubmatrix	k
2593	(0029,"SIEMENS MED DISPLAY",11)	US	t	ColumnsOfSubmatrix	k
2595	(0029,"SIEMENS MED DISPLAY",50)	US	t	OriginOfSubmatrix	k
2767	(0031,"AGFA PACS Archive Mirroring 1.0",01)	LT	t	Unknown	d
1853	(0040,030e)[<0>](00e1,"ELSCINT1",21)	DS	t	Exposure Dose Sequence:DLP Total	k
1714	(01f1,"ELSCINT1",30)	US	t	Unknown	d
1739	(07a1,"ELSCINT1",40)	CS	t	Unknown	d
1394	(0903,"GEIIS PACS",12)	US	t	Confidential Flag	k
3895	(0043,"",2a)	UN	t	Unknown	d
3737	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",0b)	US	t	Unknown	d
2691	(2001,"Philips Imaging DD 001",04)	CS	t	DiffusionDirection	k
2678	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",4d)	CS	t	Series Reference:Referenced Image Type	k
2534	(2005,"Philips MR Imaging DD 004",35)	CS	t	Physical Quantity Spatial	k
2327	(2005,"Philips MR Imaging DD 004",39)	SS	t	Search Interval for Peaks	k
2417	(2005,"Philips MR Imaging DD 004",64)	CS	t	Volume Selection	k
2329	(2005,"Philips MR Imaging DD 004",70)	SS	t	Number Mixes Spectro	k
2171	(2005,"Philips MR Imaging DD 005",02)	SQ	t	Unknown	d
2381	(2005,"Philips MR Imaging DD 005",09)	DS	t	Rescale Intercept Original	k
2184	(2005,"Philips MR Imaging DD 005",0e)	SQ	t	Private Shared Sequence	d
2392	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9036)	CS	t	Private Per-Frame Sequence:Partial Fourier Direction	na
2398	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9077)	CS	t	Private Per-Frame Sequence:Parallel Acquisition	na
2358	(2005,"Philips MR Imaging DD 005",0f)[<0>](0028,3003)	LO	t	Private Per-Frame Sequence:LUT Explanation	na
2774	(2005,"Philips MR Imaging DD 005",1e)	UL	t	LUT1 Offset	k
1813	(7005,"TOSHIBA_MEC_CT3",1f)	LO	t	Volume Number	d
4558	(07a5,"ELSCINT1",ae)	IS	t	Unknown	d
4516	(5001,"vRad PACS",53)	UN	t	Unknown	d
4556	(07a1,"ELSCINT1",c0)	ST	t	Unknown	d
4365	(07a1,"ELSCINT1",5d)	UN	t	Unknown	d
4544	(0043,"GEMS_PARM_01",aa)	UN	t	Unknown	d
1474	(0009,"Unnamed Private Block - 10",0d)	UN	t	Unknown	d
2665	(0040,9096)[<0>](2001,"Philips Imaging DD 001",c1)	LO	t	Real World Value Mapping Sequence:Linear Modality GL Transform	k
687	(0019,"GEMS_PETD_01",04)	LO	t	cal_datetime	o
5077	(2005,"Philips MR Imaging DD 005",2a)	OB	t	Exam Print Status	k
2979	(0009,"FDMS 1.0",10)	OB	t	ExposureUnitTypeCode	d
3067	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",33)	OB	t	Unknown:Unknown	d
5716	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",aa)	UN	t	Advanced Presentation Sequence:LUT Inverted Flag	k
291	(0019,"GEMS_ACQU_01",41)	SS	t	ComputeType	k
1548	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",1c)	PN	t	Unknown	d
5717	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",57)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer PWL TransferFunction Sequence	k
5294	(2001,"Philips Imaging DD 001",52)	UI	t	Image Presentation State UID	d
5304	(0070,005a)[<0>](0008,1140)[<1>](2001,"Philips Imaging DD 001",c1)	LO	t	Displayed Area Selection Sequence:Referenced Image Sequence:Linear Modality GL Transform	d
3302	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",1c)	UN	t	Unknown	d
1702	(0051,"GEMS_FUNCTOOL_01",02)	LO	t	Function Name	k
1698	(0051,"GEMS_FUNCTOOL_01",04)	FL	t	Scale	k
1706	(0051,"GEMS_FUNCTOOL_01",05)	SL	t	Parameter Count	k
817	(00e1,"ELSCINT1",23)	DS	t	Presentation Relative Part	k
854	(0019,"GEMS_PETD_01",04)	DT	t	cal_datetime	o
1520	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",50)	UN	t	Unknown	d
2788	(00e1,"ELSCINT1",23)	OB	t	Presentation Relative Part	d
1705	(0051,"GEMS_FUNCTOOL_01",06)	LT	t	Parameters	k
3293	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0054,0081)	US	t	Unknown:Unknown:Number of Slices	d
1699	(0051,"GEMS_FUNCTOOL_01",0b)	FL	t	B-Value	k
2992	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",83)	OB	t	Unknown:Unknown	d
508	(0021,"GEMS_RELA_01",82)	DS	t	AutoWindowLevelBeta	k
416	(0043,"GEMS_PARM_01",09)	SS	t	RespiratoryTriggerPoint	k
3886	(0019,"",b4)	UN	t	Unknown	d
4096	(0019,"SIEMENS MR HEADER",29)	FD	t	Mosaic Ref Acq Times	d
3878	(0027,"",33)	UN	t	Unknown	d
3906	(0025,"",1b)	UN	t	Unknown	d
241	(0043,"GEMS_PARM_01",4e)	FL	t	DurationOfXrayOn	k
1810	(0053,"GEHC_CT_ADVAPP_001",66)	LO	t	Image Browser Annotation	k
281	(0043,"GEMS_PARM_01",12)	SS	t	XrayChain	k
361	(0045,"GEMS_HELIOS_01",08)	SS	t	View Weighting Mode	k
266	(0027,"GEMS_IMAG_01",1e)	SL	t	VmaMod	k
5272	(2005,"Philips MR Imaging DD 004",28)	OB	t	Spectro Data Origin	k
4024	(0051,"",11)	UN	t	Unknown	d
1792	(07a3,"ELSCINT1",c0)[<0>](07a3,"ELSCINT1",c2)	CS	t	Unknown:Unknown	d
2275	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",6d)	FL	t	Unknown:Slab FOV FH	na
2264	(2005,"Philips MR Imaging DD 001",b2)	FL	t	Diffusion Direction FH	k
2191	(2005,"Philips MR Imaging DD 003",13)	UL	t	Number of Codes	k
2282	(2005,"Philips MR Imaging DD 004",61)	FL	t	Spectro Vertical Window	k
2226	(2005,"Philips MR Imaging DD 004",81)	IS	t	ScanoGram Survey Number of Images	k
2198	(2005,"Philips MR Imaging DD 005",0f)[<0>](0028,9002)	UL	t	Private Per-Frame Sequence:Data Point Columns	na
2210	(2005,"Philips MR Imaging DD 005",13)	IS	t	Gradient Orientation Number	k
2272	(2005,"Philips MR Imaging DD 005",42)	FL	t	Active Implantable Medical Device B1 RMS Limit	k
2263	(2005,"Philips MR Imaging DD 005",47)	FL	t	Power Optimization	k
2276	(2005,"Philips MR Imaging DD 005",4a)	FL	t	Data Window Duration	k
2287	(2005,"Philips MR Imaging DD 005",4b)	FL	t	Mixing Time	k
2029	(3241,"Varian Medical Systems VISION 3241",05)	UN	t	Unknown	d
1092	(0053,"GEHC_CT_ADVAPP_001",01)	UN	t	MultiEnergyNoiseRedBlendingFact	k
4116	(0019,"SIEMENS MR HEADER",29)	UN	t	Mosaic Ref Acq Times	d
1536	(0019,"SIEMENS MR HEADER",29)	OB	t	Mosaic Ref Acq Times	d
328	(0045,"GEMS_HELIOS_01",3b)	LO	t	NoiseReductionImageFilterDesc	k
4379	(0015,"GEMS_PETD_01",38)	UL	t	Unknown	d
4360	(07a5,"ELSCINT1",c8)	UN	t	Unknown	d
4417	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a300)[<3>](0040,08ea)[<4>](0008,0102)	SH	f	Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Measurement Units Code Sequence:Coding Scheme Designator	\N
4251	(5200,9229)[<0>](0028,9110)	SQ	f	Shared Functional Groups Sequence:Pixel Measures Sequence	\N
4373	(0015,"GEMS_PETD_01",35)	UL	t	Blank Scan Flag	k
4513	(5001,"vRad PACS",77)	UN	t	Unknown	d
2590	(0019,"SIEMENS SIENET",01)	DS	t	Unknown	d
313	(0025,"GEMS_SERS_01",11)	SS	t	NumberOfAcquisitions	k
1095	(7005,"TOSHIBA_MEC_CT3",0a)	DS	t	Table Speed in mm/rot	k
3701	(0021,"Siemens: Thorax/Multix FD Post Processing",02)	FL	t	Unknown	d
5173	(2005,"Philips MR Imaging DD 004",63)	OB	t	Spectrum Pitch	k
1942	(01f1,"ELSCINT1",31)	UN	t	Unknown	d
1941	(01f1,"ELSCINT1",36)	CS	t	Unknown	d
1940	(01f1,"ELSCINT1",37)	DS	t	Unknown	d
1939	(01f1,"ELSCINT1",38)	LO	t	Unknown	d
3726	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",12)	SS	t	Unknown	d
3001	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
5228	(2005,"Philips MR Imaging DD 005",3f)	OB	t	Active Implantable Medical Device Limits Applied	k
4988	(2005,"Philips MR Imaging DD 002",32)		t	Blob Data Object Array	d
864	(0009,"GEMS_PETD_01",c6)	SL	t	seg_qc_parm	k
3734	(0019,"Siemens: Thorax/Multix FD Lab Settings",06)	FD	t	Table Object Distance	d
4278	(5200,9229)[<0>](0008,9124)[<1>](0008,9215)[<2>](0008,0102)	SH	f	Shared Functional Groups Sequence:Derivation Image Sequence:Derivation Code Sequence:Coding Scheme Designator	\N
1840	(01f3,"ELSCINT1",01)[<0>](01f3,"ELSCINT1",02)	SS	t	Unknown:Unknown	d
2118	(0053,"GEHC_CT_ADVAPP_001",6b)	IS	t	Unknown	d
1011	(0053,"GEHC_CT_ADVAPP_001",6b)	UN	t	Unknown	d
1828	(01f3,"ELSCINT1",01)[<0>](01f3,"ELSCINT1",03)	FL	t	Unknown:Unknown	d
5172	(2005,"Philips MR Imaging DD 004",31)	OB	t	Number of Spectra Acquired	k
1842	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",12)	SS	t	Unknown:Unknown	d
3148	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",30)	OB	t	Unknown:Unknown	d
1831	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",14)	FL	t	Unknown:Unknown	d
1859	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",15)	US	t	Unknown:Unknown	d
2931	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",70)	SQ	t	Unknown:Unknown	d
1834	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",17)	FL	t	Unknown:Unknown	d
1846	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",18)	SH	t	Unknown:Unknown	d
443	(0043,"GEMS_PARM_01",06)	SS	t	NumberOfEPIShots	k
1826	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",24)	IS	t	Unknown:Unknown	d
642	(0009,"GEMS_PETD_01",b6)	SS	t	IR Loop Filter	k
1829	(01f3,"ELSCINT1",13)	FL	t	Unknown	d
1833	(01f3,"ELSCINT1",14)	FL	t	Unknown	d
1845	(01f3,"ELSCINT1",18)	SH	t	Unknown	d
1861	(01f3,"ELSCINT1",23)	US	t	Unknown	d
1827	(01f3,"ELSCINT1",24)	IS	t	Unknown	d
1844	(07a1,"ELSCINT1",70)	SH	t	Unknown	d
1930	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a1,"ELSCINT1",7b)	LT	t	Unknown:Unknown:Unknown	d
1928	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a1,"ELSCINT1",7c)	UL	t	Unknown:Unknown:Unknown	d
1924	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a1,"ELSCINT1",7e)	SQ	t	Unknown:Unknown:Unknown	d
1927	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a3,"ELSCINT1",41)	UL	t	Unknown:Unknown:Unknown	d
1753	(07a3,"ELSCINT1",62)	SQ	t	Unknown	d
1791	(07a3,"ELSCINT1",cb)[<0>](07a3,"ELSCINT1",c2)	CS	t	Unknown:Unknown	d
2359	(2005,"Philips MR Imaging DD 004",97)	LO	t	Anatomic Region Code Value	k
1936	(07a1,"ELSCINT1",82)[<0>](07a3,"ELSCINT1",28)	US	t	Unknown:Unknown	d
2334	(2001,"Philips Imaging DD 001",0f)	SS	t	Cardiac Gate Width	k
2315	(2001,"Philips Imaging DD 001",15)	SS	t	NumberOfLocations	k
2340	(2001,"Philips Imaging DD 001",5f)[<0>](2001,"Philips Imaging DD 001",2d)	SS	t	StackSequence:StackNumberOfSlices	k
2350	(2001,"Philips Imaging DD 001",8b)	SH	t	Transmitting Coil	k
2300	(2001,"Philips Imaging DD 129",00)[<0>](0008,0018)	UI	t	Presentation State Sequence:SOP Instance UID	na
2308	(2001,"Philips Imaging DD 129",00)[<0>](0008,1115)[<1>](0008,1140)[<2>](0008,1150)	UI	t	Presentation State Sequence:Referenced Series Sequence:Referenced Image Sequence:Referenced SOP Class UID	na
2316	(2005,"Philips MR Imaging DD 001",1d)	SS	t	Measurement Scan Resolution	k
2356	(2005,"Philips MR Imaging DD 005",02)[<0>](0008,0104)	LO	t	Unknown:Code Meaning	na
2301	(2005,"Philips MR Imaging DD 005",02)[<0>](0008,010d)	UI	t	Unknown:Context Group Extension Creator UID	na
2354	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9041)	LO	t	Private Per-Frame Sequence:Receive Coil Manufacturer Name	na
446	(0019,"GEMS_ACQU_01",cf)	SS	t	PrescanStatus	k
2861	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",17)	OB	t	Unknown:Unknown	d
4146	(0019,"",0a)	US	t	Unknown	d
5178	(2005,"Philips MR Imaging DD 005",43)	OB	t	Active Implantable Medical Device dbDt Limit	k
5150	(2005,"Philips MR Imaging DD 005",41)	OB	t	Active Implantable Medical Device Whole Body SAR Limit	k
5062	(2005,"Philips MR Imaging DD 001",6f)	OB	t	Acquisition Type	k
4957	(2005,"Philips MR Imaging DD 005",02)		t	Unknown	d
1672	(07a1,"ELSCINT1",50)	US	t	Unknown	d
2809	(01f7,"ELSCINT1",2c)	OB	t	Unknown	d
2803	(01f1,"ELSCINT1",08)	OB	t	Acquisition Length	d
4150	(5653,"Vital Images SW 3.4",19)	UI	t	Volume Study Instance UID	d
4528	(0040,0275)[<0>](0008,0050)	SH	f	Request Attributes Sequence:Accession Number	\N
4265	(0020,9222)[<0>](0020,9167)	AT	f	Dimension Index Sequence:Functional Group Pointer	\N
4442	(0040,a730)[<0>](0040,a730)[<1>](0040,a504)[<2>](0040,db00)	CS	f	Content Sequence:Content Sequence:Content Template Sequence:Template Identifier	\N
4280	(0062,0002)[<0>](0008,2218)[<1>](0008,0102)	SH	f	Segment Sequence:Anatomic Region Sequence:Coding Scheme Designator	\N
3893	(0019,"",f2)	UN	t	Unknown	d
319	(0043,"GEMS_PARM_01",19)	SS	t	NumberOfBBHChainsToBlend	k
4050	(0051,"",08)	CS	t	Unknown	d
5321	(0015,"GEMS_PETD_01",24)	UN	t	BP3d Filter CutoffU	k
5326	(0015,"GEMS_PETD_01",35)	UN	t	Blank Scan Flag	k
1860	(01f3,"ELSCINT1",15)	US	t	Unknown	d
1836	(01f3,"ELSCINT1",16)	FL	t	Unknown	d
1838	(01f3,"ELSCINT1",19)	FL	t	Unknown	d
5336	(0015,"GEMS_PETD_01",25)	UN	t	BP3d Filter OrderU	k
322	(0043,"GEMS_PARM_01",15)	SS	t	TotalOutputViews	k
1932	(07a1,"ELSCINT1",82)[<0>](07a3,"ELSCINT1",29)	US	t	Unknown:Unknown	d
1734	(07a1,"ELSCINT1",98)	CS	t	Unknown	d
1727	(07a1,"ELSCINT1",a7)	SH	t	Unknown	d
1868	(07a1,"ELSCINT1",c2)	ST	t	Unknown	d
1755	(07a1,"ELSCINT1",d0)	LO	t	Unknown	d
1948	(07a3,"ELSCINT1",04)[<0>](0008,0018)	UI	t	Unknown:SOP Instance UID	d
3898	(0019,"",7f)	UN	t	Unknown	d
195	(0019,"GEMS_ACQU_01",1b)	DS	t	LastScanLocation	k
1951	(07a3,"ELSCINT1",04)[<0>](0020,000e)	UI	t	Unknown:Series Instance UID	d
1963	(07a3,"ELSCINT1",04)[<0>](0028,0010)	US	t	Unknown:Rows	d
1962	(07a3,"ELSCINT1",04)[<0>](0028,0011)	US	t	Unknown:Columns	d
1950	(07a3,"ELSCINT1",04)[<0>](07a3,"ELSCINT1",08)	UI	t	Unknown:Unknown	d
1886	(07a3,"ELSCINT1",04)[<0>](07a3,"ELSCINT1",0d)	DS	t	Unknown:Unknown	d
1949	(07a3,"ELSCINT1",04)[<0>](07a3,"ELSCINT1",67)	UI	t	Unknown:Unknown	d
1945	(07a3,"ELSCINT1",04)[<0>](07a3,"ELSCINT1",b8)	IS	t	Unknown:Unknown	d
1729	(07a3,"ELSCINT1",13)	SH	t	Unknown	d
1719	(07a3,"ELSCINT1",14)	ST	t	Unknown	d
1823	(07a3,"ELSCINT1",15)	ST	t	Unknown	d
1847	(07a3,"ELSCINT1",17)	SH	t	Unknown	d
1722	(07a3,"ELSCINT1",18)	ST	t	Unknown	d
1720	(07a3,"ELSCINT1",1b)	ST	t	Unknown	d
4510	(0019,"SET WINDOW",01)	US	t	Set Window Magnification Power	d
4270	(5200,9229)[<0>](0008,9124)[<1>](0008,2112)[<2>](0008,1150)	UI	f	Shared Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Referenced SOP Class UID	\N
4447	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0008,1199)[<3>](0008,1150)	UI	f	Content Sequence:Content Sequence:Content Sequence:Referenced SOP Sequence:Referenced SOP Class UID	\N
1724	(07a3,"ELSCINT1",1c)	ST	t	Unknown	d
1725	(07a3,"ELSCINT1",1d)	ST	t	Unknown	d
1721	(07a3,"ELSCINT1",1e)	ST	t	Unknown	d
1723	(07a3,"ELSCINT1",1f)	ST	t	Unknown	d
1822	(07a3,"ELSCINT1",22)	ST	t	Unknown	d
1717	(07a3,"ELSCINT1",23)	ST	t	Unknown	d
1865	(07a3,"ELSCINT1",24)	ST	t	Unknown	d
4275	(5200,9229)[<0>](0008,9124)[<1>](0008,9215)[<2>](0008,0100)	SH	f	Shared Functional Groups Sequence:Derivation Image Sequence:Derivation Code Sequence:Code Value	\N
4298	(0040,a372)[<0>](0008,0103)	SH	f	Performed Procedure Code Sequence:Coding Scheme Version	\N
1969	(07a3,"ELSCINT1",80)[<0>](0070,0052)	SL	t	Unknown:Displayed Area Top Left Hand Corner	d
1960	(07a3,"ELSCINT1",26)	CS	t	Unknown	d
1774	(07a3,"ELSCINT1",43)	DS	t	Unknown	d
1968	(07a3,"ELSCINT1",80)[<0>](0070,0053)	SL	t	Unknown:Displayed Area Bottom Right Hand Corner	d
1944	(07a3,"ELSCINT1",b6)	IS	t	Unknown	d
1796	(07a3,"ELSCINT1",c0)[<0>](07a3,"ELSCINT1",c8)	AE	t	Unknown:Unknown	d
1786	(07a3,"ELSCINT1",c0)[<0>](07a3,"ELSCINT1",c9)	CS	t	Unknown:Unknown	d
1752	(07a3,"ELSCINT1",c6)	SQ	t	Unknown	d
2506	(2005,"Philips MR Imaging DD 001",a1)	CS	t	SyncraScanType	k
1794	(07a3,"ELSCINT1",c6)[<0>](07a3,"ELSCINT1",c2)	CS	t	Unknown:Unknown	d
1778	(07a3,"ELSCINT1",c6)[<0>](07a3,"ELSCINT1",c3)	CS	t	Unknown:Unknown	d
2467	(2005,"Philips MR Imaging DD 001",38)	CS	t	Spoiled	k
2452	(2005,"Philips MR Imaging DD 001",a2)	CS	t	Is COCA	k
2426	(2005,"Philips MR Imaging DD 004",27)	CS	t	Spectro Complex Component	k
2432	(2005,"Philips MR Imaging DD 004",42)	CS	t	Signal Type	k
2401	(2005,"Philips MR Imaging DD 004",96)	CS	t	Flow Images Present	k
2457	(2005,"Philips MR Imaging DD 005",02)[<0>](0008,010b)	CS	t	Unknown:Context Group Extension Flag	na
2425	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,9208)	CS	t	Private Per-Frame Sequence:Complex Image Component	na
2377	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,1041)	DS	t	Private Per-Frame Sequence:Contrast/Bolus Volume	na
2415	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9021)	CS	t	Private Per-Frame Sequence:T2 Preparation	na
2410	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9022)	CS	t	Private Per-Frame Sequence:Blood Signal Nulling	na
2409	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9024)	CS	t	Private Per-Frame Sequence:Saturation Recovery	na
2424	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9064)	CS	t	Private Per-Frame Sequence:k-space Filtering	na
2438	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9147)	CS	t	Private Per-Frame Sequence:Diffusion Anisotropy Type	na
2434	(2005,"Philips MR Imaging DD 005",16)	CS	t	Plan Mode	k
2479	(2005,"Philips MR Imaging DD 005",35)	CS	t	Spectro Examcard	k
4439	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a300)[<3>](0040,a30a)	DS	f	Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Numeric Value	\N
4497	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",a3)	TM	t	Object Action Sequence:Object Action Time	d
4158	(0028,041b)	UN	f	<undef>	\N
823	(01f1,"ELSCINT1",04)	CS	t	Angular Sampling Density	k
4388	(0015,"GEMS_PETD_01",28)	SL	t	BP3d Filter CutoffV	k
4475	(1111,"2.16.840.1.114330.1.1.1.1",24)	FD	t	Unknown	d
4163	(0040,a370)[<0>](0040,2017)	LO	f	Referenced Request Sequence:Filler Order Number / Imaging Service Request	\N
440	(0043,"GEMS_PARM_01",2f)	SS	t	RawDataType	k
1704	(0043,"GEMS_PARM_01",95)	DS	t	Prescan Reuse String	k
1701	(0051,"GEMS_FUNCTOOL_01",01)	LO	t	Group Name	k
1713	(01f1,"ELSCINT1",28)	DS	t	Table Increment	k
789	(0009,"GEMS_PETD_01",c0)	SL	t	AC BP Filt Order	k
1711	(01f1,"ELSCINT1",33)	DS	t	Cycle Time	k
1716	(07a1,"ELSCINT1",02)	UL	t	Unknown	d
1728	(07a1,"ELSCINT1",42)	SH	t	Unknown	d
1741	(07a1,"ELSCINT1",58)	CS	t	Unknown	d
1735	(07a1,"ELSCINT1",5f)	CS	t	Unknown	d
1849	(07a1,"ELSCINT1",71)	SH	t	Unknown	d
5331	(0015,"GEMS_PETD_01",29)	UN	t	Decay Flag	k
4100	(0028,1201)	US	f	Red Palette Color Lookup Table Data	\N
5152	(2001,"Philips Imaging DD 001",01)	OB	t	ChemicalShift	k
4086	(0028,0108)	SS	f	Smallest Pixel Value in Series	\N
4419	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a300)[<3>](0040,08ea)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Measurement Units Code Sequence	\N
4533	(0040,0275)[<0>](0040,0007)	LO	f	Request Attributes Sequence:Scheduled Procedure Step Description	\N
4120	(0008,9007)	CS	f	Frame Type	\N
5138	(0903,"GEIIS PACS",12)	OB	t	Confidential Flag	k
4534	(0040,0275)[<0>](0032,1064)[<1>](0008,0104)	LO	f	Request Attributes Sequence:Requested Procedure Code Sequence:Code Meaning	\N
262	(0029,"GEMS_IMPS_01",07)	SL	t	LowerRangeOfPixels	k
4141	(0028,1199)	UI	f	Palette Color Lookup Table UID	\N
2798	(01f1,"ELSCINT1",04)	OB	t	Angular Sampling Density	d
4245	(0062,0002)[<0>](0008,2218)	SQ	f	Segment Sequence:Anatomic Region Sequence	\N
4529	(0040,0275)[<0>](0040,0009)	SH	f	Request Attributes Sequence:Scheduled Procedure Step ID	\N
4549	(0008,1250)[<0>](0040,a170)[<1>](0008,010f)	CS	f	Related Series Sequence:Purpose of Reference Code Sequence:Context Identifier	\N
4420	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a043)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Concept Name Code Sequence	\N
4260	(5200,9230)[<0>](0020,9111)	SQ	f	Per-frame Functional Groups Sequence:Frame Content Sequence	\N
4274	(5200,9230)[<0>](0020,9111)[<1>](0020,9056)	SH	f	Per-frame Functional Groups Sequence:Frame Content Sequence:Stack ID	\N
4531	(0040,0275)[<0>](0040,1001)	SH	f	Request Attributes Sequence:Requested Procedure ID	\N
4161	(0040,a370)[<0>](0008,1111)	SQ	f	Referenced Request Sequence:Referenced Performed Procedure Step Sequence	\N
4264	(5200,9229)[<0>](0008,9124)[<1>](0008,2112)[<2>](0008,1160)	IS	f	Shared Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Referenced Frame Number	\N
4286	(5200,9229)[<0>](0008,9124)[<1>](0008,2112)[<2>](0040,a170)[<3>](0008,0104)	LO	f	Shared Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Purpose of Reference Code Sequence:Code Meaning	\N
4535	(0040,0275)[<0>](0040,0008)[<1>](0008,0104)	LO	f	Request Attributes Sequence:Scheduled Protocol Code Sequence:Code Meaning	\N
4104	(0032,1031)	SQ	f	Requesting Physician Identification Sequence	\N
4257	(5200,9230)[<0>](0020,9113)	SQ	f	Per-frame Functional Groups Sequence:Plane Position Sequence	\N
4548	(0008,1250)[<0>](0040,a170)[<1>](0008,0106)	DT	f	Related Series Sequence:Purpose of Reference Code Sequence:Context Group Version	\N
4106	(0040,a123)	PN	f	Person Name	\N
4159	(0028,041c)	UN	f	<undef>	\N
1760	(07a1,"ELSCINT1",75)	LO	t	Unknown	d
1925	(07a1,"ELSCINT1",82)	SQ	t	Unknown	d
1926	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)	SQ	t	Unknown:Unknown	d
1929	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a1,"ELSCINT1",79)	SS	t	Unknown:Unknown:Unknown	d
1933	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a1,"ELSCINT1",7d)	US	t	Unknown:Unknown:Unknown	d
1736	(07a1,"ELSCINT1",88)	CS	t	Unknown	d
1911	(07a3,"ELSCINT1",5c)	ST	t	Unknown	d
1783	(07a3,"ELSCINT1",65)	CS	t	Unknown	d
2538	(2005,"Philips MR Imaging DD 004",34)	CS	t	Physical Quantity for Chemical Shift	k
2512	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,9207)	CS	t	Private Per-Frame Sequence:Volume Based Calculation Technique	na
2509	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9017)	CS	t	Private Per-Frame Sequence:Steady State Pulse Sequence	na
2554	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9035)	FD	t	Private Per-Frame Sequence:Tag Thickness	na
2560	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9240)	US	t	Private Per-Frame Sequence:RF Echo Train Length	na
2565	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9241)	US	t	Private Per-Frame Sequence:Gradient Echo Train Length	na
2527	(2005,"Philips MR Imaging DD 005",2b)	CS	t	Exam Export Status	k
4107	(31bc,e638)	UN	f	<undef>	\N
4108	(0038,0020)	DA	f	Admitting Date	\N
4099	(0028,1203)	US	f	Blue Palette Color Lookup Table Data	\N
4166	(0018,9402)	FL	f	Distance Source to Isocenter	\N
4105	(300a,0182)	IS	f	Patient Setup Number	\N
4160	(0040,a372)[<0>](0008,0100)	SH	f	Performed Procedure Code Sequence:Code Value	\N
3741	(0021,"Siemens: Thorax/Multix FD Post Processing",0f)	US	t	Unknown	d
4484	(0043,"GEMS_PARM_01",66)	US	t	Helical Correction Indicator	k
4414	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a043)[<4>](0008,0102)	SH	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Concept Name Code Sequence:Coding Scheme Designator	\N
2785	(0009,"GEMS_PETD_01",89)	FL	t	Window Level Min	k
3020	(50f1,"FDMS 1.0",20)	OB	t	Image Processing Modification Flag	d
2712	(0008,1111)[<0>](2005,"Philips MR Imaging DD 005",04)	UN	t	Referenced Performed Procedure Step Sequence:Unknown	k
2608	(0009,"EMAGEON JPEG2K INFO",00)[<0>](0023,"Unnamed Private Block - 20",15)[<1>](0023,"Unnamed Private Block - 20",18)	FL	t	Unknown:Unknown:Unknown	na
2604	(0009,"EMAGEON JPEG2K INFO",00)[<0>](0023,"Unnamed Private Block - 20",15)[<1>](0023,"Unnamed Private Block - 20",19)	IS	t	Unknown:Unknown:Unknown	na
1870	(0009,"SPI RELEASE 1",15)	LO	t	SPIImageUID	d
2779	(0009,"Unnamed Private Block - 10",00)	UN	t	Unknown	d
1873	(0011,"SPI RELEASE 1",10)	LO	t	Organ	k
2610	(0023,"GEMS_STDY_01",80)	SQ	t	Has MPPS Related Tags	d
4446	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0008,1199)[<3>](0008,1155)	UI	f	Content Sequence:Content Sequence:Content Sequence:Referenced SOP Sequence:Referenced SOP Instance UID	\N
2764	(0029,"MITRA MARKUP 1.0",00)	LO	t	Markup1	d
1909	(0043,"GEMS_PARM_01",88)	UI	t	PURE Acquisition Calibration Series UID	h
2634	(0043,"GEMS_PARM_01",99)	LO	t	Extended Options	k
2632	(0051,"GEMS_FUNCTOOL_01",03)	UN	t	Bias	k
2623	(0051,"GEMS_FUNCTOOL_01",09)	UN	t	Window Width	k
1875	(0091,"SIENET",20)	UN	t	RIS Patient Name	d
1871	(0095,"SIENET",01)	LO	t	ExaminationFolderID	d
1914	(01f1,"ELSCINT1",43)	LO	t	Unknown	d
1837	(01f3,"ELSCINT1",17)	FL	t	Unknown	d
1816	(07a1,"ELSCINT1",5d)	DT	t	Unknown	d
1938	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",78)	SL	t	Unknown:Unknown	d
1885	(07a3,"ELSCINT1",04)	SQ	t	Unknown	d
1863	(07a3,"ELSCINT1",19)	ST	t	Unknown	d
1864	(07a3,"ELSCINT1",1a)	ST	t	Unknown	d
1806	(07a3,"ELSCINT1",b4)	US	t	Unknown	d
1770	(07a3,"ELSCINT1",c6)[<0>](07a3,"ELSCINT1",c4)	LO	t	Unknown:Unknown	d
1764	(07a3,"ELSCINT1",c6)[<0>](07a3,"ELSCINT1",c5)	LO	t	Unknown:Unknown	d
1583	(0019,"SIEMENS MR HEADER",14)	IS	t	Ima Rel Table Position	k
4520	(0040,0275)[<0>](0032,1064)	SQ	f	Request Attributes Sequence:Requested Procedure Code Sequence	\N
1799	(07a3,"ELSCINT1",c6)[<0>](07a3,"ELSCINT1",c8)	AE	t	Unknown:Unknown	d
1787	(07a3,"ELSCINT1",c6)[<0>](07a3,"ELSCINT1",c9)	CS	t	Unknown:Unknown	d
1749	(07a3,"ELSCINT1",ca)	SQ	t	Unknown	d
1759	(07a3,"ELSCINT1",ca)[<0>](07a3,"ELSCINT1",c1)	LO	t	Unknown:Unknown	d
1793	(07a3,"ELSCINT1",ca)[<0>](07a3,"ELSCINT1",c2)	CS	t	Unknown:Unknown	d
1781	(07a3,"ELSCINT1",ca)[<0>](07a3,"ELSCINT1",c3)	CS	t	Unknown:Unknown	d
1769	(07a3,"ELSCINT1",ca)[<0>](07a3,"ELSCINT1",c4)	LO	t	Unknown:Unknown	d
1763	(07a3,"ELSCINT1",ca)[<0>](07a3,"ELSCINT1",c5)	LO	t	Unknown:Unknown	d
1798	(07a3,"ELSCINT1",ca)[<0>](07a3,"ELSCINT1",c8)	AE	t	Unknown:Unknown	d
1782	(07a3,"ELSCINT1",ca)[<0>](07a3,"ELSCINT1",c9)	CS	t	Unknown:Unknown	d
1765	(07a3,"ELSCINT1",ca)[<0>](07a3,"ELSCINT1",cc)	LO	t	Unknown:Unknown	d
1751	(07a3,"ELSCINT1",cb)	SQ	t	Unknown	d
4438	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a300)[<4>](0040,a30a)	DS	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Numeric Value	\N
1756	(07a3,"ELSCINT1",cb)[<0>](07a3,"ELSCINT1",c1)	LO	t	Unknown:Unknown	d
1780	(07a3,"ELSCINT1",cb)[<0>](07a3,"ELSCINT1",c3)	CS	t	Unknown:Unknown	d
1771	(07a3,"ELSCINT1",cb)[<0>](07a3,"ELSCINT1",c4)	LO	t	Unknown:Unknown	d
1762	(07a3,"ELSCINT1",cb)[<0>](07a3,"ELSCINT1",c5)	LO	t	Unknown:Unknown	d
1797	(07a3,"ELSCINT1",cb)[<0>](07a3,"ELSCINT1",c8)	AE	t	Unknown:Unknown	d
1785	(07a3,"ELSCINT1",cb)[<0>](07a3,"ELSCINT1",c9)	CS	t	Unknown:Unknown	d
1754	(07a3,"ELSCINT1",ce)	SQ	t	Unknown	d
1795	(07a3,"ELSCINT1",ce)[<0>](0028,0004)	CS	t	Unknown:Photometric Interpretation	d
1800	(07a3,"ELSCINT1",ce)[<0>](0028,0010)	US	t	Unknown:Rows	d
1801	(07a3,"ELSCINT1",ce)[<0>](0028,0011)	US	t	Unknown:Columns	d
1773	(07a3,"ELSCINT1",ce)[<0>](0028,0034)	IS	t	Unknown:Pixel Aspect Ratio	d
1804	(07a3,"ELSCINT1",ce)[<0>](0028,0100)	US	t	Unknown:Bits Allocated	d
1777	(07a3,"ELSCINT1",ce)[<0>](7fe0,0010)	OB	t	Unknown:Pixel Data	d
1726	(07a5,"ELSCINT1",54)	DT	t	Unknown	d
2637	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",65)	IS	t	Series Reference:Reference Reconstruction Number	k
2670	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",68)	CS	t	Series Reference:Reference Type	k
2656	(2005,"Philips MR Imaging DD 003",56)	SS	t	Number of SC Software Versions	k
2664	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9050)	LO	t	Private Per-Frame Sequence:Transmit Coil Manufacturer Name	na
2674	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9094)	CS	t	Private Per-Frame Sequence:Coverage of k-Space	na
2701	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9602)	FD	t	Private Per-Frame Sequence:Diffusion b-value XX	na
2651	(2005,"Philips MR Imaging DD 005",2e)	FL	t	dBdt	k
2729	(2005,"Philips MR Imaging DD 006",58)	FL	t	Unknown	d
2026	(3006,0080)[<0>](3773,"MIM Software Inc.",05)	UN	t	RT ROI Observations Sequence:Unknown	d
2028	(3241,"Varian Medical Systems VISION 3241",00)	UN	t	Unknown	d
2034	(3241,"Varian Medical Systems VISION 3241",06)	UN	t	Unknown	d
2071	(3773,"Unnamed Private Block - 01",30)	UN	t	Unknown	d
2615	(4453,"DR Systems, Inc.",00)	LO	t	Exam ?	d
4268	(0020,9221)[<0>](0020,9164)	UI	f	Dimension Organization Sequence:Dimension Organization UID	\N
2607	(0009,"EMAGEON JPEG2K INFO",00)[<0>](0023,"Unnamed Private Block - 20",15)[<1>](0023,"Unnamed Private Block - 20",17)	FL	t	Unknown:Unknown:Unknown	na
4220	(0011,"ULTRAVISUAL_TAG_SET1",1a)	UN	t	Unknown	d
2609	(0009,"EMAGEON JPEG2K INFO",01)	DT	t	Unknown	d
1587	(0025,"GEMS_SERS_01",14)	SL	t	IndicatesNumberOfUpdatesToHeader	k
2765	(0029,"MITRA MARKUP 1.0",01)	LO	t	Markup2	d
2762	(0029,"MITRA OBJECT DOCUMENT 1.0",00)	OB	t	IMPAX Object Document	d
2630	(0051,"GEMS_FUNCTOOL_01",0a)	UN	t	Window Level	k
1737	(07a5,"ELSCINT1",56)	CS	t	Unknown	d
1850	(07a5,"ELSCINT1",62)	LO	t	Unknown	d
1790	(07a5,"ELSCINT1",63)	CS	t	Unknown	d
3697	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",06)	FL	t	Unknown	d
4269	(0020,9222)[<0>](0020,9164)	UI	f	Dimension Index Sequence:Dimension Organization UID	\N
4362	(07a1,"ELSCINT1",42)	UN	t	Unknown	d
4277	(5200,9229)[<0>](0008,9124)[<1>](0008,2112)[<2>](0040,a170)[<3>](0008,0102)	SH	f	Shared Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Purpose of Reference Code Sequence:Coding Scheme Designator	\N
5202	(2005,"Philips MR Imaging DD 001",c0)	OB	t	Scan Sequence	k
4455	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a168)[<4>](0008,0100)	SH	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Concept Code Sequence:Code Value	\N
3776	(0043,"GEMS_PARM_01",aa)	LO	t	Unknown	d
5105	(2001,"Philips Imaging DD 001",17)	OB	t	NumberOfPhasesMR	k
4421	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a300)[<4>](0040,08ea)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Measurement Units Code Sequence	\N
4276	(0062,0002)[<0>](0062,000f)[<1>](0008,0100)	SH	f	Segment Sequence:Segmented Property Type Code Sequence:Code Value	\N
3097	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",91)	OB	t	Unknown:Unknown	d
609	(0009,"GEMS_PETD_01",b9)	FL	t	Response Filt Param	k
1817	(07a5,"ELSCINT1",69)	LO	t	Unknown	d
4261	(5200,9229)[<0>](0008,9124)[<1>](0008,9215)	SQ	f	Shared Functional Groups Sequence:Derivation Image Sequence:Derivation Code Sequence	\N
3920	(0019,"",8f)	UN	t	Unknown	d
3922	(0021,"",35)	UN	t	Unknown	d
3917	(0009,"",02)	UN	t	Unknown	d
4229	(0018,9117)[<0>](0018,9087)	FD	f	MR Diffusion Sequence:Diffusion b-value	\N
1718	(07a5,"ELSCINT1",98)	ST	t	Unknown	d
1913	(07a5,"ELSCINT1",c8)	CS	t	Unknown	d
1884	(1001,"Philips Imaging DD 001",12)	UN	t	Unknown	d
2267	(2001,"Philips Imaging DD 001",01)	FL	t	ChemicalShift	k
2484	(2001,"Philips Imaging DD 001",06)	CS	t	ImageEnhanced	k
2204	(2001,"Philips Imaging DD 001",08)	IS	t	PhaseNumber	k
2200	(2001,"Philips Imaging DD 001",0a)	IS	t	SliceNumberMR	k
4236	(0018,a001)[<0>](0008,0081)	LO	f	Contributing Equipment Sequence:Institution Address	\N
4228	(0018,9117)[<0>](0018,9075)	CS	f	MR Diffusion Sequence:Diffusion Directionality	\N
4227	(0018,9117)	SQ	f	MR Diffusion Sequence	\N
5271	(2001,"Philips Imaging DD 001",25)	OB	t	EchoTimeDisplayMR	k
4526	(0040,0275)[<0>](0040,0008)[<1>](0008,0102)	SH	f	Request Attributes Sequence:Scheduled Protocol Code Sequence:Coding Scheme Designator	\N
2531	(2001,"Philips Imaging DD 001",0b)	CS	t	SliceOrientation	k
2422	(2001,"Philips Imaging DD 001",10)	CS	t	Cardiac Sync	k
2571	(2001,"Philips Imaging DD 001",14)	SL	t	NumberOfEchoes	k
2257	(2001,"Philips Imaging DD 001",1a)	FL	t	PCVelocity	k
2681	(2001,"Philips Imaging DD 001",1e)	CS	t	Reformat Accuracy	k
2187	(2005,"Philips MR Imaging DD 001",9e)	SQ	t	Series Geometry	k
2338	(2005,"Philips MR Imaging DD 003",45)	SS	t	Number of Software Version	k
2458	(2005,"Philips MR Imaging DD 004",25)	CS	t	Spectro SI B0 Correction	k
2404	(2005,"Philips MR Imaging DD 004",45)	CS	t	Spectro Echo Acquisition	k
2318	(2005,"Philips MR Imaging DD 005",06)	SS	t	Number of PS Specific Character Sets	k
2305	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,9123)	UI	t	Private Per-Frame Sequence:Creator-Version UID	na
2399	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9012)	CS	t	Private Per-Frame Sequence:Multi-planar Excitation	na
2514	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9020)	CS	t	Private Per-Frame Sequence:Magnetization Transfer	na
2521	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9028)	CS	t	Private Per-Frame Sequence:Tagging	na
2497	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9029)	CS	t	Private Per-Frame Sequence:Oversampling Phase	na
2540	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9032)	CS	t	Private Per-Frame Sequence:Geometry of k-Space Traversal	na
2490	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9033)	CS	t	Private Per-Frame Sequence:Segmented k-Space Traversal	na
2687	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9062)	CS	t	Private Per-Frame Sequence:De-coupling Method	na
4552	(0054,0016)[<0>](0054,0304)[<1>](0008,010f)	CS	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Code Sequence:Context Identifier	\N
4434	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a300)[<4>](0040,08ea)[<5>](0008,0104)	LO	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Measured Value Sequence:Measurement Units Code Sequence:Code Meaning	\N
75	(0019,"SIEMENS MR HEADER",14)	OB	t	Ima Rel Table Position	k
4525	(0040,0275)[<0>](0008,1110)[<1>](0008,1150)	UI	f	Request Attributes Sequence:Referenced Study Sequence:Referenced SOP Class UID	\N
4101	(0028,1202)	US	f	Green Palette Color Lookup Table Data	\N
4551	(0054,0016)[<0>](0054,0304)[<1>](0008,0105)	CS	f	Radiopharmaceutical Information Sequence:Radiopharmaceutical Code Sequence:Mapping Resource	\N
3963	(0009,"",31)	UN	t	Unknown	d
273	(0029,"GEMS_IMPS_01",04)	SL	t	LowerRangeOfPixels	k
1905	(0008,1111)[<0>](2001,"Philips Imaging DD 001",c1)	LO	t	Referenced Performed Procedure Step Sequence:Linear Modality GL Transform	k
4084	(700d,"TOSHIBA_MEC_MR3",08)	OB	t	Original Data	d
2925	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",10)	SQ	t	Unknown:Unknown	d
1572	(3109,"Applicare/RadWorks/Version 5.0",0a)	DA	t	Receive Date	d
1700	(0043,"GEMS_PARM_01",98)	UI	t	ASSET Acquisition Calibration Series UID	h
1703	(0051,"GEMS_FUNCTOOL_01",07)	LO	t	Version	k
1709	(0051,"GEMS_FUNCTOOL_01",08)	SL	t	Color Ramp Index	k
1707	(0051,"GEMS_FUNCTOOL_01",09)	SL	t	Window Width	k
1710	(0051,"GEMS_FUNCTOOL_01",0a)	SL	t	Window Level	k
1906	(0054,0016)[<0>](2001,"Philips Imaging DD 001",c1)	LO	t	Radiopharmaceutical Information Sequence:Linear Modality GL Transform	k
5200	(2005,"Philips MR Imaging DD 004",30)	OB	t	InPlane Transforms	k
1869	(0099,"SIENET",02)	UL	t	DataObjectAttributes	k
1952	(00e1,"ELSCINT1",51)	SH	t	Unknown	d
1832	(01f3,"ELSCINT1",01)[<0>](01f3,"ELSCINT1",04)	FL	t	Unknown:Unknown	d
1830	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",13)	FL	t	Unknown:Unknown	d
1862	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",23)	US	t	Unknown:Unknown	d
1956	(07a1,"ELSCINT1",2b)	CS	t	Unknown	d
1964	(07a1,"ELSCINT1",3d)	US	t	Unknown	d
1931	(07a1,"ELSCINT1",82)[<0>](07a1,"ELSCINT1",81)[<1>](07a1,"ELSCINT1",7e)[<2>](07a1,"ELSCINT1",7f)	FD	t	Unknown:Unknown:Unknown:Unknown	d
1955	(07a3,"ELSCINT1",05)	CS	t	Unknown	d
1959	(07a3,"ELSCINT1",06)	CS	t	Unknown	d
1943	(07a3,"ELSCINT1",80)	SQ	t	Unknown	d
1958	(07a3,"ELSCINT1",80)[<0>](0070,0100)	CS	t	Unknown:Presentation Size Mode	d
1946	(07a3,"ELSCINT1",b5)	IS	t	Unknown	d
1954	(07a3,"ELSCINT1",b7)	LT	t	Unknown	d
1757	(07a3,"ELSCINT1",c0)[<0>](07a3,"ELSCINT1",c1)	LO	t	Unknown:Unknown	d
1772	(07a3,"ELSCINT1",c0)[<0>](07a3,"ELSCINT1",c4)	LO	t	Unknown:Unknown	d
1767	(07a3,"ELSCINT1",c0)[<0>](07a3,"ELSCINT1",cc)	LO	t	Unknown:Unknown	d
1766	(07a3,"ELSCINT1",c6)[<0>](07a3,"ELSCINT1",cc)	LO	t	Unknown:Unknown	d
1768	(07a3,"ELSCINT1",cb)[<0>](07a3,"ELSCINT1",cc)	LO	t	Unknown:Unknown	d
1805	(07a3,"ELSCINT1",ce)[<0>](0028,0002)	US	t	Unknown:Samples per Pixel	d
1803	(07a3,"ELSCINT1",ce)[<0>](0028,0101)	US	t	Unknown:Bits Stored	d
1802	(07a3,"ELSCINT1",ce)[<0>](0028,0102)	US	t	Unknown:High Bit	d
1807	(07a3,"ELSCINT1",ce)[<0>](0028,0103)	US	t	Unknown:Pixel Representation	d
1866	(07a5,"ELSCINT1",59)	IS	t	Unknown	d
2402	(2001,"Philips Imaging DD 001",1f)	CS	t	RespirationSync	k
2363	(2001,"Philips Imaging DD 001",20)	LO	t	Scanning Technique	k
2473	(2001,"Philips Imaging DD 001",21)	CS	t	SPIR	k
2551	(2005,"Philips MR Imaging DD 005",0f)[<0>](0020,9254)	FD	t	Private Per-Frame Sequence:Respiratory Interval Time	na
2639	(2005,"Philips MR Imaging DD 005",10)	IS	t	MF Conv Treat Spectro Mix Number	k
2573	(2005,"Philips MR Imaging DD 005",14)	SL	t	Number of Diffusion B Values	k
2648	(2005,"Philips MR Imaging DD 005",30)	FL	t	Non Proton SAR	k
2470	(2005,"Philips MR Imaging DD 005",3f)	CS	t	Active Implantable Medical Device Limits Applied	k
2650	(2005,"Philips MR Imaging DD 005",48)	FL	t	Coil Q	k
2270	(2005,"Philips MR Imaging DD 005",4c)	FL	t	First Echo Time	k
2460	(2005,"Philips MR Imaging DD 005",4e)	CS	t	Is B1 Series	k
2737	(2005,"Philips MR Imaging DD 006",62)	LT	t	Unknown	d
2104	(300a,0010)[<0>](3267,"Varian Medical Systems VISION 3267",00)	UN	t	Dose Reference Sequence:Unknown	d
2105	(300a,0070)[<0>](300c,0004)[<1>](3249,"Varian Medical Systems VISION 3249",00)	UN	t	Fraction Group Sequence:Referenced Beam Sequence:Unknown	d
2103	(300a,0070)[<0>](300c,0004)[<1>](3249,"Varian Medical Systems VISION 3249",10)	UN	t	Fraction Group Sequence:Referenced Beam Sequence:Unknown	d
2106	(300a,00b0)[<0>](3285,"Varian Medical Systems VISION 3285",00)	UN	t	Beam Sequence:Unknown	d
2032	(3241,"Varian Medical Systems VISION 3241",02)	UN	t	Unknown	d
2031	(3241,"Varian Medical Systems VISION 3241",04)	UN	t	Unknown	d
1610	(07a3,"ELSCINT1",01)	LO	t	Unknown	d
5319	(0015,"GEMS_PETD_01",33)	UN	t	Emission Deadtime Flag	k
4258	(0062,0002)[<0>](0062,000f)	SQ	f	Segment Sequence:Segmented Property Type Code Sequence	\N
4273	(0062,0002)[<0>](0008,2218)[<1>](0008,0100)	SH	f	Segment Sequence:Anatomic Region Sequence:Code Value	\N
4250	(5200,9229)[<0>](0008,9124)	SQ	f	Shared Functional Groups Sequence:Derivation Image Sequence	\N
4255	(0020,9222)	SQ	f	Dimension Index Sequence	\N
4272	(0062,0002)[<0>](0062,0003)[<1>](0008,0100)	SH	f	Segment Sequence:Segmented Property Category Code Sequence:Code Value	\N
4262	(5200,9230)[<0>](0020,9111)[<1>](0020,9057)	UL	f	Per-frame Functional Groups Sequence:Frame Content Sequence:In-Stack Position Number	\N
4244	(0062,0002)[<0>](0062,0006)	ST	f	Segment Sequence:Segment Description	\N
4253	(0062,0002)	SQ	f	Segment Sequence	\N
4256	(5200,9229)[<0>](0020,9116)	SQ	f	Shared Functional Groups Sequence:Plane Orientation Sequence	\N
4246	(5200,9230)	SQ	f	Per-frame Functional Groups Sequence	\N
4263	(5200,9230)[<0>](0020,9111)[<1>](0020,9157)	UL	f	Per-frame Functional Groups Sequence:Frame Content Sequence:Dimension Index Values	\N
4266	(0020,9222)[<0>](0020,9165)	AT	f	Dimension Index Sequence:Dimension Index Pointer	\N
4259	(5200,9229)[<0>](0008,9124)[<1>](0008,2112)	SQ	f	Shared Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence	\N
4248	(0020,9221)	SQ	f	Dimension Organization Sequence	\N
4249	(0062,0002)[<0>](0062,0003)	SQ	f	Segment Sequence:Segmented Property Category Code Sequence	\N
4252	(5200,9229)	SQ	f	Shared Functional Groups Sequence	\N
5329	(0015,"GEMS_PETD_01",30)	UN	t	Emission Scatter Flag	k
5124	(2005,"Philips MR Imaging DD 004",38)	OB	t	Sample Pitch	k
246	(0043,"GEMS_PARM_01",10)	US	t	WindowValue	k
2763	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",16)	OB	t	Unknown	d
2243	(2001,"Philips Imaging DD 001",22)	FL	t	WaterFatShift	k
2366	(2001,"Philips Imaging DD 001",23)	DS	t	FlipAnglePhilips	k
2459	(2001,"Philips Imaging DD 001",24)	CS	t	Series is Interactive	k
2345	(2001,"Philips Imaging DD 001",25)	SH	t	EchoTimeDisplayMR	k
2671	(2001,"Philips Imaging DD 001",4e)	CS	t	Window Smoothing Taste	k
2177	(2001,"Philips Imaging DD 001",5f)	SQ	t	StackSequence	k
2281	(2001,"Philips Imaging DD 001",5f)[<0>](2001,"Philips Imaging DD 001",32)	FL	t	StackSequence:StackRadialAngle	k
2429	(2001,"Philips Imaging DD 001",5f)[<0>](2001,"Philips Imaging DD 001",33)	CS	t	StackSequence:StackRadialAxis	k
2314	(2001,"Philips Imaging DD 001",5f)[<0>](2001,"Philips Imaging DD 001",35)	SS	t	StackSequence:StackSliceNumber	k
2507	(2001,"Philips Imaging DD 001",5f)[<0>](2001,"Philips Imaging DD 001",36)	CS	t	StackSequence:StackType	k
2241	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",71)	FL	t	StackSequence:Stack Angulation AP	k
2244	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",72)	FL	t	StackSequence:Stack Angulation FH	k
2294	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",73)	FL	t	StackSequence:Stack Angulation RL	k
2252	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",74)	FL	t	StackSequence:Stack FOV AP	k
2251	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",75)	FL	t	StackSequence:Stack FOV FH	k
2298	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",76)	FL	t	StackSequence:Stack FOV RL	k
2293	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",78)	FL	t	StackSequence:Stack Offcentre AP	k
2250	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",79)	FL	t	StackSequence:Stack Offcentre FH	k
2297	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",7a)	FL	t	StackSequence:Stack Offcentre RL	k
2390	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",7b)	CS	t	StackSequence:Stack Preparation Direction	k
2245	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",7e)	FL	t	StackSequence:Stack Slice Distance	k
2498	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",81)	CS	t	StackSequence:Stack View Axis	k
3101	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",13)	OB	t	Unknown:Unknown	d
2227	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",a3)	IS	t	StackSequence:Stack Coil ID	k
2213	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",a4)	IS	t	StackSequence:Stack CBB Coil 1	k
2219	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",a5)	IS	t	StackSequence:Stack CBB Coil 2	k
2223	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",a6)	IS	t	StackSequence:Stack Channel Combination Bitmask	k
2522	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 001",a7)	CS	t	StackSequence:Stack Coil Connection	k
2494	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 004",90)	CS	t	StackSequence:Stack Coil Function	k
2322	(2005,"Philips MR Imaging DD 001",86)	SS	t	Number of Geometry	k
2380	(2005,"Philips MR Imaging DD 001",a8)	DS	t	Inversion Time	k
2271	(2005,"Philips MR Imaging DD 001",b0)	FL	t	Diffusion Direction RL	k
2194	(2005,"Philips MR Imaging DD 005",03)	UL	t	Number of SPS Codes	k
2440	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,9007)	CS	t	Private Per-Frame Sequence:Frame Type	na
2391	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,9209)	CS	t	Private Per-Frame Sequence:Acquisition Contrast	na
2353	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9005)	SH	t	Private Per-Frame Sequence:Pulse Sequence Name	na
2491	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9008)	CS	t	Private Per-Frame Sequence:Echo Pulse Sequence	na
2408	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9014)	CS	t	Private Per-Frame Sequence:Phase Contrast	na
2532	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9027)	CS	t	Private Per-Frame Sequence:Spatial Pre-saturation	na
2535	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9034)	CS	t	Private Per-Frame Sequence:Rectilinear Phase Encode Reordering	na
2530	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9043)	CS	t	Private Per-Frame Sequence:Receive Coil Type	na
4283	(0062,0002)[<0>](0062,0009)	LO	f	Segment Sequence:Segment Algorithm Name	\N
4295	(5200,9229)[<0>](0062,000a)[<1>](0062,000b)	US	f	Shared Functional Groups Sequence:Segment Identification Sequence:Referenced Segment Number	\N
4281	(0062,0002)[<0>](0062,0003)[<1>](0008,0102)	SH	f	Segment Sequence:Segmented Property Category Code Sequence:Coding Scheme Designator	\N
4296	(0062,0002)[<0>](0062,0004)	US	f	Segment Sequence:Segment Number	\N
4284	(0062,0002)[<0>](0008,2218)[<1>](0008,0104)	LO	f	Segment Sequence:Anatomic Region Sequence:Code Meaning	\N
4297	(0040,a372)[<0>](0008,0102)	SH	f	Performed Procedure Code Sequence:Coding Scheme Designator	\N
4294	(0062,0001)	CS	f	Segmentation Type	\N
4292	(5200,9229)[<0>](0028,9110)[<1>](0018,0050)	DS	f	Shared Functional Groups Sequence:Pixel Measures Sequence:Slice Thickness	\N
4285	(0062,0002)[<0>](0062,0003)[<1>](0008,0104)	LO	f	Segment Sequence:Segmented Property Category Code Sequence:Code Meaning	\N
4288	(0062,0002)[<0>](0062,000f)[<1>](0008,0104)	LO	f	Segment Sequence:Segmented Property Type Code Sequence:Code Meaning	\N
4293	(0062,0002)[<0>](0062,0008)	CS	f	Segment Sequence:Segment Algorithm Type	\N
4287	(0062,0002)[<0>](0062,0005)	LO	f	Segment Sequence:Segment Label	\N
4279	(0062,0002)[<0>](0062,000f)[<1>](0008,0102)	SH	f	Segment Sequence:Segmented Property Type Code Sequence:Coding Scheme Designator	\N
4289	(5200,9230)[<0>](0020,9113)[<1>](0020,0032)	DS	f	Per-frame Functional Groups Sequence:Plane Position Sequence:Image Position (Patient)	\N
5723	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",42)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Orientation	k
5724	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",46)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera ViewPort Size	k
4309	(0062,0002)[<0>](0062,000f)[<1>](0008,2220)[<2>](0008,0100)	SH	f	Segment Sequence:Segmented Property Type Code Sequence:Anatomic Region Modifier Sequence:Code Value	\N
2237	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 005",3c)	FL	t	StackSequence:Stack Table Position Longitudinal	k
2236	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 005",3d)	FL	t	StackSequence:Stack Table Position Lateral	k
5198	(2001,"Philips Imaging DD 001",1c)	OB	t	PrepulseType	k
662	(0009,"GEMS_PETD_01",3e)	SH	t	Radio Nuclide Name	k
296	(0027,"GEMS_IMAG_01",10)	SS	t	ScoutType	k
2996	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
2151	(0021,"SIEMENS MED ECAT FILE INFO",00)	OB	t	ECAT_Main_Header	d
360	(0045,"GEMS_HELIOS_01",09)	SS	t	Sigma Row number	k
2970	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
489	(0021,"GEMS_RELA_01",83)	DS	t	AutoWindowLevelWindow	k
3014	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3947	(0027,"",60)	UN	t	Unknown	d
3982	(0043,"",03)	UN	t	Unknown	d
3954	(0019,"",93)	UN	t	Unknown	d
1571	(0051,"SIEMENS MR HEADER",17)	SH	t	Unknown	d
2238	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 005",3e)	FL	t	StackSequence:Stack Posterior Coil Position	k
2574	(2001,"Philips Imaging DD 001",60)	SL	t	NumberOfStacks	k
2444	(2001,"Philips Imaging DD 001",61)	CS	t	SeriesTransmitted	k
2488	(2005,"Philips MR Imaging DD 001",c0)	CS	t	Scan Sequence	k
146	(0051,"SIEMENS MR HEADER",17)	OB	t	Unknown	d
2193	(2005,"Philips MR Imaging DD 003",00)	UL	t	Number of SOP Common	k
2710	(2005,"Philips MR Imaging DD 005",04)	UN	t	Unknown	d
2734	(2005,"Philips MR Imaging DD 005",04)	SS	t	Unknown	d
2174	(2005,"Philips MR Imaging DD 005",0f)	SQ	t	Private Per-Frame Sequence	d
2374	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,1049)	DS	t	Private Per-Frame Sequence:Contrast/Bolus Ingredient Concentration	na
2504	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9011)	CS	t	Private Per-Frame Sequence:Multiple Spin Echo	na
2406	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9015)	CS	t	Private Per-Frame Sequence:Time of Flight Contrast	na
2515	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9016)	CS	t	Private Per-Frame Sequence:Spoiling	na
2703	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9030)	FD	t	Private Per-Frame Sequence:Tag Spacing First Dimension	na
2419	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9044)	CS	t	Private Per-Frame Sequence:Quadrature Receive Coil	na
2351	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9047)	SH	t	Private Per-Frame Sequence:Multi-Coil Element Name	na
2672	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9065)	CS	t	Private Per-Frame Sequence:Time Domain Filtering	na
2544	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9069)	FD	t	Private Per-Frame Sequence:Parallel Reduction Factor In-plane	na
2690	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9078)	CS	t	Private Per-Frame Sequence:Parallel Acquisition Technique	na
2400	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9081)	CS	t	Private Per-Frame Sequence:Partial Fourier	na
2552	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9091)	FD	t	Private Per-Frame Sequence:Velocity Encoding Minimum Value	na
2543	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9168)	FD	t	Private Per-Frame Sequence:Parallel Reduction Factor Second In-plane	na
2673	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9169)	CS	t	Private Per-Frame Sequence:Cardiac Beat Rejection Technique	na
2517	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9171)	CS	t	Private Per-Frame Sequence:Respiratory Signal Source	na
2655	(2005,"Philips MR Imaging DD 005",0f)[<0>](0040,9210)	SS	t	Private Per-Frame Sequence:LUT Label	na
3913	(0019,"",bb)	UN	t	Unknown	d
5285	(2005,"Philips MR Imaging DD 004",81)	OB	t	ScanoGram Survey Number of Images	k
2108	(3006,0020)[<0>](3263,"Varian Medical Systems VISION 3263",00)	UN	t	Structure Set ROI Sequence:Unknown	d
4301	(0040,a370)[<0>](0008,1110)[<1>](0008,1155)	UI	f	Referenced Request Sequence:Referenced Study Sequence:Referenced SOP Instance UID	\N
4306	(0008,0202)	LO	f	<undef>	\N
4312	(0062,0002)[<0>](0062,000f)[<1>](0008,2220)[<2>](0008,0104)	LO	f	Segment Sequence:Segmented Property Type Code Sequence:Anatomic Region Modifier Sequence:Code Meaning	\N
4300	(0040,a370)[<0>](0008,1110)[<1>](0008,1150)	UI	f	Referenced Request Sequence:Referenced Study Sequence:Referenced SOP Class UID	\N
4308	(0054,0051)	US	f	Number of Rotations	\N
4383	(0015,"GEMS_PETD_01",24)	FL	t	BP3d Filter CutoffU	k
4310	(0062,0002)[<0>](0062,000f)[<1>](0008,2220)[<2>](0008,0102)	SH	f	Segment Sequence:Segmented Property Type Code Sequence:Anatomic Region Modifier Sequence:Coding Scheme Designator	\N
2596	(0013,"CTP",50)	LO	t	Year of Study	d
4311	(0062,0002)[<0>](0062,000f)[<1>](0008,2220)	SQ	f	Segment Sequence:Segmented Property Type Code Sequence:Anatomic Region Modifier Sequence	\N
4307	(0008,0202)	UN	f	<undef>	\N
4162	(0040,a372)[<0>](0008,0104)	LO	f	Performed Procedure Code Sequence:Code Meaning	\N
3749	(0021,"Siemens: Thorax/Multix FD Post Processing",0a)	SL	t	Auto Window Width	d
5250	(2005,"Philips MR Imaging DD 001",11)	OB	t	Image Type	k
3651	(0011,"GEMS_GDXE_FALCON_04",6b)	UN	t	Unknown	d
1090	(0053,"GEHC_CT_ADVAPP_001",02)	UN	t	MultiEnergyNoiseRedScaleFact	k
4385	(0015,"GEMS_PETD_01",22)	FL	t	IR Loop Filter Correction	k
3209	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",43)	OB	t	Unknown:Unknown	d
1665	(0019,"SIEMENS MR HEADER",13)	SL	t	Ima Abs Table Position	k
64	(0019,"SIEMENS MR HEADER",13)	OB	t	Ima Abs Table Position	k
1457	(0009,"GEIIS",05)	UN	t	Unknown	d
2915	(00e1,"ELSCINT1",39)[<0>](00e1,"ELSCINT1",3b)	IS	t	Unknown:Unknown	d
2991	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",83)	OB	t	Unknown:Unknown	d
2786	(0009,"GEMS_PETD_01",8a)	FL	t	Window Level Max	k
518	(0027,"GEMS_IMAG_01",36)	SL	t	ObliquePlane	k
791	(0009,"GEMS_PETD_01",95)	SL	t	Angle Smooth Param	k
4080	(0051,"SIEMENS MR HEADER",0c)	SH	t	Unknown	d
1690	(0051,"SIEMENS MR HEADER",0c)	LO	t	Unknown	d
134	(0051,"SIEMENS MR HEADER",0c)	OB	t	Unknown	d
4021	(0021,"",5f)	UN	t	Unknown	d
2987	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",74)	OB	t	Unknown:Unknown	d
602	(0009,"GEMS_PETD_01",9a)	FL	t	CAC Edge Threshold	k
5334	(0015,"GEMS_PETD_01",2e)	UN	t	Image filter 3d flag	k
2481	(2001,"Philips Imaging DD 001",62)	CS	t	SeriesCommitted	k
1883	(2001,"Philips Imaging DD 001",63)	CS	t	ExaminationSource	d
2676	(2001,"Philips Imaging DD 001",77)	CS	t	GL Transform Type	k
2652	(2001,"Philips Imaging DD 001",7a)	FL	t	Window Rounding Factor	k
2225	(2001,"Philips Imaging DD 001",7b)	IS	t	AcquisitionNumber	k
2203	(2001,"Philips Imaging DD 001",81)	IS	t	NumberOfDynamicScans	k
2224	(2001,"Philips Imaging DD 001",82)	IS	t	Echo Train Length	k
2372	(2001,"Philips Imaging DD 001",83)	DS	t	Imaging Frequency	k
2367	(2005,"Philips MR Imaging DD 005",0a)	DS	t	Rescale Slope Original	k
2375	(2001,"Philips Imaging DD 001",84)	DS	t	Inversion Time	k
2382	(2001,"Philips Imaging DD 001",85)	DS	t	Magnetic Field Strength	k
2214	(2001,"Philips Imaging DD 001",86)	IS	t	Number of Phase Encoding Steps	k
2362	(2005,"Philips MR Imaging DD 005",0b)	LO	t	Rescale Type Original	k
2389	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,9205)	CS	t	Private Per-Frame Sequence:Pixel Presentation	na
2420	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9009)	CS	t	Private Per-Frame Sequence:Inversion Recovery	na
2511	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9025)	CS	t	Private Per-Frame Sequence:Spectrally Selected Suppression	na
2510	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9037)	CS	t	Private Per-Frame Sequence:Cardiac Synchronization Technique	na
2561	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9058)	US	t	Private Per-Frame Sequence:MR Acquisition Frequency Encoding Steps	na
2190	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9080)	ST	t	Private Per-Frame Sequence:Metabolite Map Description	na
2700	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9087)	FD	t	Private Per-Frame Sequence:Diffusion b-value	na
2546	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9181)	FD	t	Private Per-Frame Sequence:Specific Absorption Rate Value	na
2695	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9603)	FD	t	Private Per-Frame Sequence:Diffusion b-value XY	na
2702	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9605)	FD	t	Private Per-Frame Sequence:Diffusion b-value YY	na
2499	(2005,"Philips MR Imaging DD 005",0f)[<0>](0020,9072)	CS	t	Private Per-Frame Sequence:Frame Laterality	na
2696	(2005,"Philips MR Imaging DD 005",0f)[<0>](0020,9256)	FD	t	Private Per-Frame Sequence:Respiratory Trigger Delay Threshold	na
2679	(2005,"Philips MR Imaging DD 005",0f)[<0>](0028,9108)	CS	t	Private Per-Frame Sequence:Data Representation	na
288	(0019,"GEMS_ACQU_01",70)	SS	t	ValueOfBackProjectionButton	k
419	(0019,"GEMS_ACQU_01",a0)	SS	t	SurfaceCoilType	k
3185	(0029,"FDMS 1.0",20)	OB	t	ImageScanningDirection	d
883	(0043,"GEMS_PARM_01",90)	LO	t	SAR Definition	k
3038	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",40)	OB	t	Unknown:Unknown	d
3857	(0023,"",74)	UN	t	Unknown	d
2866	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",16)	OB	t	Unknown:Unknown	d
1509	(0011,"GEMS_GENIE_1",13)	SL	t	DatasetType	d
301	(0043,"GEMS_PARM_01",1c)	SS	t	GEImageIntegrity	k
5185	(2005,"Philips MR Imaging DD 001",00)	OB	t	Image Angulation AP	k
1351	(00e1,"ELSCINT1",63)	SH	t	Patient Language	d
2834	(00e1,"ELSCINT1",63)	OB	t	Patient Language	d
3187	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",84)	OB	t	Unknown:Unknown	d
170	(0009,"GEMS_IDEN_01",02)	SH	t	SuiteId	k
4012	(0019,"",8d)	UN	t	Unknown	d
3958	(0019,"",a2)	UN	t	Unknown	d
4515	(5001,"vRad PACS",72)	UN	t	Unknown	d
4352	(07a3,"ELSCINT1",bb)	UN	t	Unknown	d
3300	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0028,0011)	US	t	Unknown:Unknown:Columns	d
4396	(5200,9230)[<0>](0008,9124)[<1>](0008,2112)[<2>](0008,1155)	UI	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Referenced SOP Instance UID	\N
4247	(5200,9229)[<0>](0008,9124)[<1>](0008,2112)[<2>](0040,a170)	SQ	f	Shared Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Purpose of Reference Code Sequence	\N
4290	(5200,9229)[<0>](0028,9110)[<1>](0028,0030)	DS	f	Shared Functional Groups Sequence:Pixel Measures Sequence:Pixel Spacing	\N
4357	(07a1,"ELSCINT1",5f)	UN	t	Unknown	d
4426	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0008,1199)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Referenced SOP Sequence	\N
1270	(0009,"GEIIS",10)[<0>](0028,0011)	US	t	GE Private Image Thumbnail Sequence:Columns	na
2930	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",10)	SQ	t	Unknown:Unknown	d
454	(0019,"GEMS_ACQU_01",d3)	SH	t	ProjectionAlgorithm	k
282	(0019,"GEMS_ACQU_01",6a)	SS	t	DependantOnNumberOfViewsProcessed	k
3660	(200b,"Philips RAD Imaging DD 097",96)	SH	t	Unknown	d
1035	(0053,"GEHC_CT_ADVAPP_001",8b)	UN	t	MaterialType#2	k
3265	(3f01,"INTELERAD MEDICAL SYSTEMS",09)	LO	t	Unknown	d
5726	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",35)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Application Number	k
5171	(2005,"Philips MR Imaging DD 004",44)	OB	t	Spectro Display Ranges	k
3743	(0019,"Siemens: Thorax/Multix FD Lab Settings",05)	US	t	Unknown	d
5058	(2001,"Philips Imaging DD 001",07)	OB	t	ImageTypeEDES	k
5231	(2005,"Philips MR Imaging DD 001",37)	OB	t	Is Spectro	k
5333	(0015,"GEMS_PETD_01",21)	UN	t	IR Loop Filter Ratio	k
5252	(2001,"Philips Imaging DD 001",84)	OB	t	Inversion Time	k
5214	(2005,"Philips MR Imaging DD 001",a2)	OB	t	Is COCA	k
3205	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
2349	(2001,"Philips Imaging DD 001",87)	SH	t	Imaged Nucleus	k
2383	(2001,"Philips Imaging DD 001",88)	DS	t	Number of Averages	k
2379	(2001,"Philips Imaging DD 001",89)	DS	t	Phase FOV Percent	k
2636	(2001,"Philips Imaging DD 001",cc)	ST	t	Derivation Description	k
1907	(2001,"Philips Imaging DD 001",de)	UN	t	Unknown	d
2277	(2001,"Philips Imaging DD 001",f1)	FL	t	Prospective Motion Correction	k
2647	(2001,"Philips Imaging DD 001",f2)	FL	t	Retrospective Motion Correction	k
2708	(2001,"Philips Imaging DD 002",6b)	UN	t	Unknown	d
2179	(2001,"Philips Imaging DD 129",00)	SQ	t	Presentation State Sequence	d
2501	(2001,"Philips Imaging DD 129",00)[<0>](0008,0005)	CS	t	Presentation State Sequence:Specific Character Set	na
2583	(2001,"Philips Imaging DD 129",00)[<0>](0008,0012)	DA	t	Presentation State Sequence:Instance Creation Date	na
2557	(2001,"Philips Imaging DD 129",00)[<0>](0008,0013)	TM	t	Presentation State Sequence:Instance Creation Time	na
2309	(2001,"Philips Imaging DD 129",00)[<0>](0008,0014)	UI	t	Presentation State Sequence:Instance Creator UID	na
2307	(2001,"Philips Imaging DD 129",00)[<0>](0008,0016)	UI	t	Presentation State Sequence:SOP Class UID	na
2178	(2001,"Philips Imaging DD 129",00)[<0>](0008,1115)	SQ	t	Presentation State Sequence:Referenced Series Sequence	na
2175	(2001,"Philips Imaging DD 129",00)[<0>](0008,1115)[<1>](0008,1140)	SQ	t	Presentation State Sequence:Referenced Series Sequence:Referenced Image Sequence	na
2303	(2001,"Philips Imaging DD 129",00)[<0>](0008,1115)[<1>](0008,1140)[<2>](0008,1155)	UI	t	Presentation State Sequence:Referenced Series Sequence:Referenced Image Sequence:Referenced SOP Instance UID	na
2306	(2001,"Philips Imaging DD 129",00)[<0>](0008,1115)[<1>](0020,000e)	UI	t	Presentation State Sequence:Referenced Series Sequence:Series Instance UID	na
2564	(2001,"Philips Imaging DD 129",00)[<0>](0018,1622)	US	t	Presentation State Sequence:Shutter Presentation Value	na
2209	(2001,"Philips Imaging DD 129",00)[<0>](0020,0013)	IS	t	Presentation State Sequence:Instance Number	na
2173	(2001,"Philips Imaging DD 129",00)[<0>](0028,3110)	SQ	t	Presentation State Sequence:Softcopy VOI LUT Sequence	na
2371	(2001,"Philips Imaging DD 129",00)[<0>](0028,3110)[<1>](0028,1050)	DS	t	Presentation State Sequence:Softcopy VOI LUT Sequence:Window Center	na
2369	(2001,"Philips Imaging DD 129",00)[<0>](0028,3110)[<1>](0028,1051)	DS	t	Presentation State Sequence:Softcopy VOI LUT Sequence:Window Width	na
2465	(2001,"Philips Imaging DD 129",00)[<0>](0028,3110)[<1>](2001,"Philips Imaging DD 001",53)	CS	t	Presentation State Sequence:Softcopy VOI LUT Sequence:Presentation GL Transform Invert	na
2493	(2001,"Philips Imaging DD 129",00)[<0>](0028,3110)[<1>](2001,"Philips Imaging DD 001",77)	CS	t	Presentation State Sequence:Softcopy VOI LUT Sequence:GL Transform Type	na
2176	(2001,"Philips Imaging DD 129",00)[<0>](0070,005a)	SQ	t	Presentation State Sequence:Displayed Area Selection Sequence	na
2568	(2001,"Philips Imaging DD 129",00)[<0>](0070,005a)[<1>](0070,0052)	SL	t	Presentation State Sequence:Displayed Area Selection Sequence:Displayed Area Top Left Hand Corner	na
2579	(2001,"Philips Imaging DD 129",00)[<0>](0070,005a)[<1>](0070,0053)	SL	t	Presentation State Sequence:Displayed Area Selection Sequence:Displayed Area Bottom Right Hand Corner	na
2502	(2001,"Philips Imaging DD 129",00)[<0>](0070,005a)[<1>](0070,0100)	CS	t	Presentation State Sequence:Displayed Area Selection Sequence:Presentation Size Mode	na
2207	(2001,"Philips Imaging DD 129",00)[<0>](0070,005a)[<1>](0070,0102)	IS	t	Presentation State Sequence:Displayed Area Selection Sequence:Presentation Pixel Aspect Ratio	na
2397	(2001,"Philips Imaging DD 129",00)[<0>](0070,005a)[<1>](2001,"Philips Imaging DD 001",3f)	CS	t	Presentation State Sequence:Displayed Area Selection Sequence:ZoomMode	na
2427	(2001,"Philips Imaging DD 129",00)[<0>](0070,0080)	CS	t	Presentation State Sequence:Content Label	na
2357	(2001,"Philips Imaging DD 129",00)[<0>](0070,0081)	LO	t	Presentation State Sequence:Content Description	na
2657	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,002a)	DT	t	Private Per-Frame Sequence:Acquisition DateTime	na
2360	(2001,"Philips Imaging DD 001",c8)	LO	t	Exam Card Name	d
2706	(2001,"Philips Imaging DD 001",c8)	UN	t	Exam Card Name	d
3907	(0019,"",c9)	UN	t	Unknown	d
2584	(2001,"Philips Imaging DD 129",00)[<0>](0070,0082)	DA	t	Presentation State Sequence:Presentation Creation Date	na
2558	(2001,"Philips Imaging DD 129",00)[<0>](0070,0083)	TM	t	Presentation State Sequence:Presentation Creation Time	na
2365	(2001,"Philips Imaging DD 129",00)[<0>](0070,0084)	PN	t	Presentation State Sequence:Content Creator's Name	na
2456	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",26)	CS	t	Presentation State Sequence:Presentation State Subtraction Active	na
2436	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",67)	CS	t	Presentation State Sequence:Linear Presentation GL Transform Shape Sub	na
2180	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",68)	SQ	t	Presentation State Sequence:Linear Modality GL Transform	na
2376	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",68)[<1>](0028,1052)	DS	t	Presentation State Sequence:Linear Modality GL Transform:Rescale Intercept	na
2373	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",68)[<1>](0028,1053)	DS	t	Presentation State Sequence:Linear Modality GL Transform:Rescale Slope	na
2361	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",68)[<1>](0028,1054)	LO	t	Presentation State Sequence:Linear Modality GL Transform:Rescale Type	na
2492	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",68)[<1>](2001,"Philips Imaging DD 001",77)	CS	t	Presentation State Sequence:Linear Modality GL Transform:GL Transform Type	na
2525	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",77)	CS	t	Presentation State Sequence:GL Transform Type	na
2566	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",9f)	US	t	Presentation State Sequence:Pixel Processing Kernel Size	na
2186	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 129",00)	SQ	t	Presentation State Sequence:Presentation State Sequence	na
2575	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 003",34)	SL	t	Presentation State Sequence:Number of Image Per Series Ref	na
2320	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 003",57)	SS	t	Presentation State Sequence:Number of Running Attributes	na
2302	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 003",81)	UI	t	Presentation State Sequence:Default Image UID	na
2439	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 003",82)	CS	t	Presentation State Sequence:Running Attributes	na
2185	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 004",89)	SQ	t	Presentation State Sequence:Viewing Protocol	na
2330	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 005",06)	SS	t	Presentation State Sequence:Number of PS Specific Character Sets	na
2523	(2001,"Philips Imaging DD 129",00)[<0>](2050,0020)	CS	t	Presentation State Sequence:Presentation LUT Shape	na
2242	(2005,"Philips MR Imaging DD 001",00)	FL	t	Image Angulation AP	k
2240	(2005,"Philips MR Imaging DD 001",01)	FL	t	Image Angulation FH	k
2295	(2005,"Philips MR Imaging DD 001",02)	FL	t	Image Angulation RL	k
2518	(2005,"Philips MR Imaging DD 001",04)	CS	t	Image Display Orientation	k
2231	(2005,"Philips MR Imaging DD 001",08)	FL	t	Image Offcenter AP	k
2234	(2005,"Philips MR Imaging DD 001",09)	FL	t	Image Offcenter FH	k
2232	(2005,"Philips MR Imaging DD 001",0a)	FL	t	Image OffCentre RL	k
2235	(2005,"Philips MR Imaging DD 001",0b)	FL	t	Max FP	k
2290	(2005,"Philips MR Imaging DD 001",0c)	FL	t	Min FP	k
2292	(2005,"Philips MR Imaging DD 001",0d)	FL	t	Scale Intercept	k
2247	(2005,"Philips MR Imaging DD 001",0e)	FL	t	Scale Slope	k
2370	(2005,"Philips MR Imaging DD 001",0f)	DS	t	Window Center	k
2368	(2005,"Philips MR Imaging DD 001",10)	DS	t	Window Width	k
2423	(2005,"Philips MR Imaging DD 001",11)	CS	t	Image Type	k
2466	(2005,"Philips MR Imaging DD 001",12)	CS	t	Cardiac Gating	k
2405	(2005,"Philips MR Imaging DD 001",13)	CS	t	Development Mode	k
2443	(2005,"Philips MR Imaging DD 001",14)	CS	t	Diffusion	k
2451	(2005,"Philips MR Imaging DD 001",15)	CS	t	Fat Saturation	k
2482	(2005,"Philips MR Imaging DD 001",16)	CS	t	Flow Compensation	k
2448	(2005,"Philips MR Imaging DD 001",17)	CS	t	Fourier Interpolation	k
2659	(2005,"Philips MR Imaging DD 001",18)	LO	t	Hardcopy Protocol	k
2476	(2005,"Philips MR Imaging DD 001",19)	CS	t	Inverse Reconstructed	k
2317	(2005,"Philips MR Imaging DD 001",1a)	SS	t	Label Syntax	k
2464	(2005,"Philips MR Imaging DD 001",1b)	CS	t	Magnetization Prepared	k
2446	(2005,"Philips MR Imaging DD 001",1c)	CS	t	Magnetization Transfer Contrast	k
2348	(2005,"Philips MR Imaging DD 001",1e)	SH	t	MIPProtocol	k
2347	(2005,"Philips MR Imaging DD 001",1f)	SH	t	MPRProtocol	k
2578	(2005,"Philips MR Imaging DD 001",20)	SL	t	NumberOfChemicalShifts	k
2311	(2005,"Philips MR Imaging DD 001",21)	SS	t	Number of Mixes	k
2220	(2005,"Philips MR Imaging DD 001",22)	IS	t	Number of References	k
2312	(2005,"Philips MR Imaging DD 001",23)	SS	t	Number of Slabs	k
2333	(2005,"Philips MR Imaging DD 001",25)	SS	t	Number of Volumes	k
2385	(2005,"Philips MR Imaging DD 001",26)	CS	t	Over Sampling Phase	k
2394	(2005,"Philips MR Imaging DD 001",27)	CS	t	Package Mode	k
2477	(2005,"Philips MR Imaging DD 001",28)	CS	t	Partial Fourier Frequency	k
2478	(2005,"Philips MR Imaging DD 001",29)	CS	t	PartialFourierPhase	k
2339	(2005,"Philips MR Imaging DD 001",2b)	SS	t	Percent Scan Complete	k
2449	(2005,"Philips MR Imaging DD 001",2c)	CS	t	Phase Encode Reordering	k
2216	(2005,"Philips MR Imaging DD 001",2d)	IS	t	NumberOfStackSlices	k
2472	(2005,"Philips MR Imaging DD 001",2e)	CS	t	PPG PPU Gating	k
2388	(2005,"Philips MR Imaging DD 001",2f)	CS	t	Spatial Presaturation	k
2299	(2005,"Philips MR Imaging DD 001",30)	FL	t	Repetition Time	k
2462	(2005,"Philips MR Imaging DD 001",31)	CS	t	Respiratory Gating	k
2688	(2005,"Philips MR Imaging DD 001",32)	CS	t	StackRadialAngle	k
2296	(2005,"Philips MR Imaging DD 001",33)	FL	t	StackRadialAxis	k
1203	(0073,"STENTOR",03)	ST	t	Unknown	d
2387	(2005,"Philips MR Imaging DD 001",34)	CS	t	Segmented KSpace	k
2486	(2005,"Philips MR Imaging DD 001",35)	CS	t	StackSliceNumber	k
2450	(2005,"Philips MR Imaging DD 001",36)	CS	t	StackType	k
2474	(2005,"Philips MR Imaging DD 001",37)	CS	t	Is Spectro	k
2442	(2005,"Philips MR Imaging DD 001",39)	CS	t	Steady State	k
2658	(2005,"Philips MR Imaging DD 001",3a)	SH	t	Sub Anatomy	k
2475	(2005,"Philips MR Imaging DD 001",3b)	CS	t	Time Reversed Steady State	k
2453	(2005,"Philips MR Imaging DD 001",3c)	CS	t	Tilt Optimized Nonsaturated Excitation	k
2337	(2005,"Philips MR Imaging DD 001",3d)	SS	t	Number of RR Interval Ranges	k
2576	(2005,"Philips MR Imaging DD 001",3e)	SL	t	RR Intervals Distribution	k
2537	(2005,"Philips MR Imaging DD 001",5f)	CS	t	StackSequence	k
2228	(2005,"Philips MR Imaging DD 001",60)	IS	t	Study Sequence Number	k
2413	(2005,"Philips MR Imaging DD 001",61)	CS	t	Prepulse Type	k
2325	(2005,"Philips MR Imaging DD 001",63)	SS	t	fMRI Status Indication	k
2489	(2005,"Philips MR Imaging DD 001",6e)	CS	t	Scanning Sequence	k
2441	(2005,"Philips MR Imaging DD 001",6f)	CS	t	Acquisition Type	k
2660	(2005,"Philips MR Imaging DD 001",70)	LO	t	Hardcopy Protocol EasyVision	k
2189	(2005,"Philips MR Imaging DD 001",80)	SQ	t	Series PlanScan	k
2677	(2005,"Philips MR Imaging DD 001",81)	CS	t	Stack View Axis	k
2172	(2005,"Philips MR Imaging DD 001",83)	SQ	t	Unknown	d
2258	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",4e)	FL	t	Unknown:Slab FOV RL	na
2239	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",4f)	FL	t	Unknown:Slab Offcentre AP	na
2249	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",50)	FL	t	Unknown:Slab Offcentre FH	na
2230	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",51)	FL	t	Unknown:Slab Offcentre RL	na
2533	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",52)	CS	t	Unknown:Slab Type	na
2430	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",53)	CS	t	Unknown:Slab View Axis	na
2253	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",69)	FL	t	Unknown:Slab Angulation AP	na
2255	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",6a)	FL	t	Unknown:Slab Angulation FH	na
2254	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",6b)	FL	t	Unknown:Slab Angulation RL	na
2233	(2005,"Philips MR Imaging DD 001",83)[<0>](2005,"Philips MR Imaging DD 001",6c)	FL	t	Unknown:Slab FOV AP	na
2188	(2005,"Philips MR Imaging DD 001",84)	SQ	t	Series Reference	k
2638	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",48)	IS	t	Series Reference:Referenced Acquisition Number	k
2643	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",49)	IS	t	Series Reference:Referenced Chemical Shift Number	k
2641	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",4a)	IS	t	Series Reference:Referenced Dynamic Scan Number	k
2640	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",4b)	IS	t	Series Reference:Referenced Echo Number	k
2668	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",4c)	CS	t	Series Reference:Referenced Entity	k
2644	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",64)	IS	t	Series Reference:Reference Phase Number	k
2685	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",66)	CS	t	Series Reference:Reference Scanning Sequence	k
2642	(2005,"Philips MR Imaging DD 001",84)[<0>](2005,"Philips MR Imaging DD 001",67)	IS	t	Series Reference:Reference Slice Number	k
2278	(2005,"Philips MR Imaging DD 004",26)	FL	t	Spectro B0 Echo Top Position	k
2428	(2005,"Philips MR Imaging DD 004",28)	CS	t	Spectro Data Origin	k
2246	(2005,"Philips MR Imaging DD 004",29)	FL	t	Spectro Echo Top Position	k
2487	(2005,"Philips MR Imaging DD 004",30)	CS	t	InPlane Transforms	k
2324	(2005,"Philips MR Imaging DD 004",31)	SS	t	Number of Spectra Acquired	k
2283	(2005,"Philips MR Imaging DD 004",33)	FL	t	Phase Encoding Echo Top Positions	k
2261	(2005,"Philips MR Imaging DD 004",36)	FL	t	Reference Frequency	k
2266	(2005,"Philips MR Imaging DD 004",37)	FL	t	Sample Offset	k
2286	(2005,"Philips MR Imaging DD 004",38)	FL	t	Sample Pitch	k
2395	(2005,"Philips MR Imaging DD 004",40)	CS	t	Signal Domain for Chemical Shift	k
2536	(2005,"Philips MR Imaging DD 004",41)	CS	t	Signal Domain Spatial	k
2386	(2005,"Philips MR Imaging DD 004",43)	CS	t	Spectro Additional Rotations	k
2323	(2005,"Philips MR Imaging DD 004",44)	SS	t	Spectro Display Ranges	k
2524	(2005,"Philips MR Imaging DD 004",46)	CS	t	Spectro Frequency Unit	k
2269	(2005,"Philips MR Imaging DD 004",47)	FL	t	Spectro Gamma	k
2539	(2005,"Philips MR Imaging DD 004",48)	CS	t	Spectro Hidden Line Removal	k
2256	(2005,"Philips MR Imaging DD 004",49)	FL	t	Spectro Horizontal Shift	k
2274	(2005,"Philips MR Imaging DD 004",50)	FL	t	Spectro Horizontal Window	k
2328	(2005,"Philips MR Imaging DD 004",51)	SS	t	Spectro Number of Display Ranges	k
2319	(2005,"Philips MR Imaging DD 004",52)	SS	t	Spectro Number of Echo Pulses	k
2683	(2005,"Philips MR Imaging DD 004",54)	CS	t	Spectro Scan Type	k
2268	(2005,"Philips MR Imaging DD 004",55)	FL	t	Spectro SI CS Intervals	k
2414	(2005,"Philips MR Imaging DD 004",56)	CS	t	Spectro SI Mode	k
2663	(2005,"Philips MR Imaging DD 004",58)	LO	t	Spectro Title Line	k
2248	(2005,"Philips MR Imaging DD 004",59)	FL	t	Spectro Turbo Echo Spacing	k
2273	(2005,"Philips MR Imaging DD 004",60)	FL	t	Spectro Vertical Shift	k
2284	(2005,"Philips MR Imaging DD 004",62)	FL	t	Spectro Offset	k
2279	(2005,"Philips MR Imaging DD 004",63)	FL	t	Spectrum Pitch	k
2181	(2005,"Philips MR Imaging DD 004",71)	SQ	t	Series SP Mix	k
2197	(2005,"Philips MR Imaging DD 004",82)	UL	t	Number of Procedure Codes	k
2364	(2005,"Philips MR Imaging DD 004",91)	PN	t	Patient Name Job In Params	d
2222	(2005,"Philips MR Imaging DD 004",92)	IS	t	Geolink ID	k
2229	(2005,"Philips MR Imaging DD 004",93)	IS	t	Station Number	k
2723	(2005,"Philips MR Imaging DD 004",95)	ST	t	View Procedure String	k
2654	(2005,"Philips MR Imaging DD 004",95)	UI	t	View Procedure String	k
2411	(2005,"Philips MR Imaging DD 004",98)	CS	t	Mobiview Enabled	k
2418	(2005,"Philips MR Imaging DD 004",99)	CS	t	IViewBold Enabled	k
2505	(2005,"Philips MR Imaging DD 005",00)	CS	t	Volume View Enabled	k
2196	(2005,"Philips MR Imaging DD 005",01)	UL	t	Number of Study Reference	k
2341	(2005,"Philips MR Imaging DD 005",02)[<0>](0008,0100)	SH	t	Unknown:Code Value	na
2343	(2005,"Philips MR Imaging DD 005",02)[<0>](0008,0102)	SH	t	Unknown:Coding Scheme Designator	na
2344	(2005,"Philips MR Imaging DD 005",02)[<0>](0008,0103)	SH	t	Unknown:Coding Scheme Version	na
2433	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,9206)	CS	t	Private Per-Frame Sequence:Volumetric Properties	na
2431	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9026)	CS	t	Private Per-Frame Sequence:Spectrally Selected Excitation	na
2503	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9048)	CS	t	Private Per-Frame Sequence:Multi-Coil Element Used	na
2545	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9053)	FD	t	Private Per-Frame Sequence:Chemical Shift Reference	na
2407	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9059)	CS	t	Private Per-Frame Sequence:De-coupling	na
2675	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9060)	CS	t	Private Per-Frame Sequence:De-coupled Nucleus	na
2520	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9075)	CS	t	Private Per-Frame Sequence:Diffusion Directionality	na
2547	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9079)	FD	t	Private Per-Frame Sequence:Inversion Times	na
2680	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9085)	CS	t	Private Per-Frame Sequence:Cardiac Signal Source	na
2694	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9089)	FD	t	Private Per-Frame Sequence:Diffusion Gradient Orientation	na
2550	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9090)	FD	t	Private Per-Frame Sequence:Velocity Encoding Direction	na
2567	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9093)	US	t	Private Per-Frame Sequence:Number of k-Space Trajectories	na
2416	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9101)	CS	t	Private Per-Frame Sequence:Frequency Correction	na
2542	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9155)	FD	t	Private Per-Frame Sequence:Parallel Reduction Factor out-of-plane	na
2513	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9170)	CS	t	Private Per-Frame Sequence:Respiratory Motion Compensation Technique	na
2516	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9172)	CS	t	Private Per-Frame Sequence:Bulk Motion Compensation Technique	na
2495	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9174)	CS	t	Private Per-Frame Sequence:Applicable Safety Standard Agency	na
2635	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9176)	SQ	t	Private Per-Frame Sequence:Operating Mode Sequence	na
2669	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9176)[<1>](0018,9177)	CS	t	Private Per-Frame Sequence:Operating Mode Sequence:Operating Mode Type	na
2692	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9176)[<1>](0018,9178)	CS	t	Private Per-Frame Sequence:Operating Mode Sequence:Operating Mode	na
2496	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9179)	CS	t	Private Per-Frame Sequence:Specific Absorption Rate Definition	na
2485	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9180)	CS	t	Private Per-Frame Sequence:Gradient Output Type	na
2541	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9182)	FD	t	Private Per-Frame Sequence:Gradient Output	na
2585	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9183)	CS	t	Private Per-Frame Sequence:Flow Compensation Direction	na
2412	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9199)	CS	t	Private Per-Frame Sequence:Water Referenced Phase Correction	na
2437	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9200)	CS	t	Private Per-Frame Sequence:MR Spectroscopy Acquisition Type	na
2562	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9231)	US	t	Private Per-Frame Sequence:MR Acquisition Phase Encoding Steps in-plane	na
2563	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9232)	US	t	Private Per-Frame Sequence:MR Acquisition Phase Encoding Steps out-of-plane	na
2704	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9604)	FD	t	Private Per-Frame Sequence:Diffusion b-value XZ	na
2699	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9606)	FD	t	Private Per-Frame Sequence:Diffusion b-value YZ	na
2697	(2005,"Philips MR Imaging DD 005",0f)[<0>](0018,9607)	FD	t	Private Per-Frame Sequence:Diffusion b-value ZZ	na
2553	(2005,"Philips MR Imaging DD 005",0f)[<0>](0020,9255)	FD	t	Private Per-Frame Sequence:Nominal Respiratory Trigger Delay Time	na
2195	(2005,"Philips MR Imaging DD 005",0f)[<0>](0028,9001)	UL	t	Private Per-Frame Sequence:Data Point Rows	na
2682	(2005,"Philips MR Imaging DD 005",0f)[<0>](0028,9003)	CS	t	Private Per-Frame Sequence:Signal Domain Columns	na
2346	(2005,"Philips MR Imaging DD 005",0f)[<0>](0040,9210)	SH	t	Private Per-Frame Sequence:LUT Label	na
2206	(2005,"Philips MR Imaging DD 005",12)	IS	t	Diffusion B Value Number	k
2570	(2005,"Philips MR Imaging DD 005",15)	SL	t	Number of Diffusion Gradient Orientations	k
2393	(2005,"Philips MR Imaging DD 005",18)	CS	t	Operating Mode Type	k
2435	(2005,"Philips MR Imaging DD 005",19)	CS	t	Operating Mode	k
2693	(2005,"Philips MR Imaging DD 005",1a)	CS	t	Fat Saturation Technique	k
2221	(2005,"Philips MR Imaging DD 005",1b)	IS	t	Version Number Deleted Images	k
2211	(2005,"Philips MR Imaging DD 005",1c)	IS	t	Version Number Deleted Spectra	k
2215	(2005,"Philips MR Imaging DD 005",1d)	IS	t	Version Number Deleted Blobsets	k
2768	(2005,"Philips MR Imaging DD 005",1f)	UL	t	LUT1 Range	k
2775	(2005,"Philips MR Imaging DD 005",20)	UL	t	LUT1 Begin Color	k
2769	(2005,"Philips MR Imaging DD 005",21)	UL	t	LUT1 End Color	k
2773	(2005,"Philips MR Imaging DD 005",22)	UL	t	LUT2 Offset	k
2772	(2005,"Philips MR Imaging DD 005",23)	UL	t	LUT2 Range	k
637	(0009,"GEMS_PETD_01",cf)	FL	t	vqc_z_axis_trans	k
593	(0009,"GEMS_PETD_01",b4)	FL	t	IR Recon FOV	k
1581	(0029,"MITRA MARKUP 1.0",03)	OB	t	Markup4	d
3926	(0021,"",5c)	UN	t	Unknown	d
749	(0009,"GEMS_PETD_01",1f)	SL	t	Collect Singles	k
3931	(0021,"",5b)	UN	t	Unknown	d
3099	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",93)	OB	t	Unknown:Unknown	d
1050	(0053,"GEHC_CT_ADVAPP_001",85)	UN	t	CommandedFirstmA	k
481	(0019,"GEMS_ACQU_01",d9)	DS	t	ConcatenatedSAT	k
1265	(0009,"GEIIS",10)[<0>](0028,1053)	DS	t	GE Private Image Thumbnail Sequence:Rescale Slope	na
5091	(2005,"Philips MR Imaging DD 004",43)	OB	t	Spectro Additional Rotations	k
3720	(0021,"Siemens: Thorax/Multix FD Post Processing",15)	SS	t	Auto Window Shift	d
5728	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",21)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Index Auto Navigation Skipping Degree	k
2770	(2005,"Philips MR Imaging DD 005",24)	UL	t	LUT2 Begin Color	k
2771	(2005,"Philips MR Imaging DD 005",25)	UL	t	LUT2 End Color	k
2445	(2005,"Philips MR Imaging DD 005",26)	CS	t	Viewing Hardcopy Only	k
2577	(2005,"Philips MR Imaging DD 005",28)	SL	t	Number of Label Types	k
2739	(2005,"Philips MR Imaging DD 005",29)	CS	t	Label Type	k
2707	(2005,"Philips MR Imaging DD 005",29)	UN	t	Label Type	k
2529	(2005,"Philips MR Imaging DD 005",2a)	CS	t	Exam Print Status	k
2526	(2005,"Philips MR Imaging DD 005",2c)	CS	t	Exam Storage Commit Status	k
2528	(2005,"Philips MR Imaging DD 005",2d)	CS	t	Exam Media Write Status	k
2646	(2005,"Philips MR Imaging DD 005",2f)	FL	t	Proton SAR	k
2649	(2005,"Philips MR Imaging DD 005",31)	FL	t	Local SAR	k
2468	(2005,"Philips MR Imaging DD 005",32)	CS	t	Safety Override Mode	k
2684	(2005,"Philips MR Imaging DD 005",37)	CS	t	Color LUT Type	k
2384	(2005,"Philips MR Imaging DD 005",3a)	LT	t	Data Dictionary Contents Version	k
2463	(2005,"Philips MR Imaging DD 005",3b)	CS	t	Is Coil Survey	k
2260	(2005,"Philips MR Imaging DD 005",40)	FL	t	Active Implantable Medical Device Head SAR Limit	k
2265	(2005,"Philips MR Imaging DD 005",41)	FL	t	Active Implantable Medical Device Whole Body SAR Limit	k
2217	(2005,"Philips MR Imaging DD 005",44)	IS	t	TFE Factor	k
2471	(2005,"Philips MR Imaging DD 005",45)	CS	t	Attenuation Correction	k
2645	(2005,"Philips MR Imaging DD 005",46)	FL	t	FWHM Shim	k
2469	(2005,"Philips MR Imaging DD 005",4d)	CS	t	Is B0 Series	k
2508	(2005,"Philips MR Imaging DD 005",4f)	CS	t	Volume Select	k
2321	(2005,"Philips MR Imaging DD 005",50)	SS	t	Number of Patient Other IDs	k
2733	(2005,"Philips MR Imaging DD 005",92)	FL	t	Unknown	d
2711	(2005,"Philips MR Imaging DD 005",92)	UN	t	Unknown	d
2730	(2005,"Philips MR Imaging DD 006",53)	FL	t	Unknown	d
2728	(2005,"Philips MR Imaging DD 006",54)	FL	t	Unknown	d
2727	(2005,"Philips MR Imaging DD 006",55)	FL	t	Unknown	d
2731	(2005,"Philips MR Imaging DD 006",56)	FL	t	Unknown	d
2740	(2005,"Philips MR Imaging DD 006",57)	CS	t	Unknown	d
2726	(2005,"Philips MR Imaging DD 006",59)	FL	t	Unknown	d
2725	(2005,"Philips MR Imaging DD 006",60)	IS	t	Unknown	d
2732	(2005,"Philips MR Imaging DD 006",61)	FL	t	Unknown	d
2724	(2005,"Philips MR Imaging DD 006",68)	IS	t	Unknown	d
2030	(3253,"Varian Medical Systems VISION 3253",00)	UN	t	Unknown	d
2033	(3253,"Varian Medical Systems VISION 3253",01)	UN	t	Unknown	d
2035	(3253,"Varian Medical Systems VISION 3253",02)	UN	t	Unknown	d
2107	(3287,"Varian Medical Systems VISION 3287",00)	UN	t	Unknown	d
2002	(3773,"MIM Software Inc.",07)	SQ	t	Unknown	d
2005	(3773,"MIM Software Inc.",07)[<0>](0020,000d)	UI	t	Unknown:Study Instance UID	d
2006	(3773,"MIM Software Inc.",07)[<0>](0020,000e)	UI	t	Unknown:Series Instance UID	d
2027	(3773,"MIM Software Inc.",18)	UN	t	Unknown	d
2003	(3773,"Unnamed Private Block - 01",20)	ST	t	Unknown	d
2004	(3773,"Unnamed Private Block - 01",22)	FL	t	Unknown	d
2620	(4453,"DR Systems, Inc.",01)	LO	t	Exam ID	d
5284	(2001,"Philips Imaging DD 001",85)	OB	t	Magnetic Field Strength	k
5094	(2001,"Philips Imaging DD 001",19)	OB	t	PartialMatrixScanned	k
3637	(0011,"GEMS_GDXE_FALCON_04",80)	UN	t	Unknown	d
2618	(4453,"DR Systems, Inc.",02)	LO	t	Image Type	d
2621	(4453,"DR Systems, Inc.",04)	LO	t	File Type	d
2614	(4453,"DR Systems, Inc.",05)	LO	t	File Suffix	d
2715	(4453,"DR Systems, Inc.",0c)	SQ	t	Original Instance UID Sequence	d
2716	(4453,"DR Systems, Inc.",0c)[<0>](0008,1115)	SQ	t	Original Instance UID Sequence:Referenced Series Sequence	d
2714	(4453,"DR Systems, Inc.",0c)[<0>](0008,1115)[<1>](0008,1199)	SQ	t	Original Instance UID Sequence:Referenced Series Sequence:Referenced SOP Sequence	na
2719	(4453,"DR Systems, Inc.",0c)[<0>](0008,1115)[<1>](0008,1199)[<2>](0008,1150)	UI	t	Original Instance UID Sequence:Referenced Series Sequence:Referenced SOP Sequence:Referenced SOP Class UID	na
2717	(4453,"DR Systems, Inc.",0c)[<0>](0008,1115)[<1>](0008,1199)[<2>](0008,1155)	UI	t	Original Instance UID Sequence:Referenced Series Sequence:Referenced SOP Sequence:Referenced SOP Instance UID	na
1814	(7005,"TOSHIBA_MEC_CT3",11)	LT	t	Series Comment	k
1815	(7005,"TOSHIBA_MEC_CT3",15)	US	t	Special Helical Acquisition Number	k
2789	(01f1,"ELSCINT1",43)	OB	t	Unknown	d
3167	(0021,"FDMS 1.0",50)	OB	t	PairProcessingInformation	d
3235	(300a,00b0)[<0>](300a,0111)[<1>](300d,"TOMO_HA_01",a7)	UN	t	Beam Sequence:Control Point Sequence:Unknown	d
5128	(2005,"Philips MR Imaging DD 004",51)	OB	t	Spectro Number of Display Ranges	k
439	(0043,"GEMS_PARM_01",30)	SS	t	RawDataType	d
392	(0027,"GEMS_IMAG_01",60)	FL	t	ImageDimensionX	k
3973	(0019,"",7d)	UN	t	Unknown	d
1048	(0053,"GEHC_CT_ADVAPP_001",7c)	UN	t	MultiEnergyNoiseReducdeMethod	k
5080	(2005,"Philips MR Imaging DD 005",2c)	OB	t	Exam Storage Commit Status	k
1303	(7053,"Philips PET Private Group",03)	ST	t	Original File Name	d
5095	(2005,"Philips MR Imaging DD 005",18)	OB	t	Operating Mode Type	k
5732	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",10)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Line Thickness	k
3981	(0019,"",87)	UN	t	Unknown	d
401	(0019,"GEMS_ACQU_01",c0)	SS	t	SaturationPlanes	k
2932	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",60)	SQ	t	Unknown:Unknown	d
5306	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",54)	FL	t	Series Volume:Volume Angulation AP	k
4008	(0025,"",18)	UN	t	Unknown	d
212	(0019,"GEMS_ACQU_01",75)	DS	t	AvgOfRightRefChannelsOverViews	k
2972	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",94)	OB	t	Unknown:Unknown	d
1123	(0009,"GEMS_PETD_01",04)	SH	t	Patient Software Version	k
744	(0009,"GEMS_PETD_01",8c)	SL	t	Attenuation	k
3158	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",42)	OB	t	Unknown:Unknown	d
4022	(0019,"",88)	UN	t	Unknown	d
2856	(01f3,"ELSCINT1",13)	OB	t	Unknown	d
3831	(0027,"",62)	UN	t	Unknown	d
763	(0009,"GEMS_PETD_01",ea)	SL	t	Unknown	d
1278	(0017,"Unnamed Private Block - 10",04)	UN	t	Unknown	d
382	(0043,"GEMS_PARM_01",35)	UL	t	UserUsageTag	k
5132	(2005,"Philips MR Imaging DD 001",0e)	OB	t	Scale Slope	k
5736	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",46)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera ViewPort Size	k
5733	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",47)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Aspect Ratio	k
5119	(0903,"GEIIS PACS",11)	OB	t	Significant Flag	k
5122	(2005,"Philips MR Imaging DD 004",62)	OB	t	Spectro Offset	k
5738	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a4)	UN	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Unknown	d
5731	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",12)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Line Shadow Y Offset	k
5730	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",17)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Auto Navigation Realtime Speed	k
5735	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",15)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Stipple Pattern	k
5734	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",14)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Auto Navigation Direction	k
2201	(2005,"Philips MR Imaging DD 001",2a)	IS	t	Patient Reference ID	d
4082	(700d,"TOSHIBA_MEC_MR3",07)	OB	t	Image Information	d
5092	(2005,"Philips MR Imaging DD 001",34)	OB	t	Segmented KSpace	k
5059	(2005,"Philips MR Imaging DD 004",46)	OB	t	Spectro Frequency Unit	k
5117	(2005,"Philips MR Imaging DD 004",52)	OB	t	Spectro Number of Echo Pulses	k
869	(0009,"GEMS_PETD_01",c4)	SL	t	Scatter Num Iter	k
638	(0009,"GEMS_PETD_01",c4)	SS	t	Scatter Num Iter	k
2923	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",40)	SQ	t	Unknown:Unknown	d
4282	(5200,9229)[<0>](0008,9124)[<1>](0008,9215)[<2>](0008,0104)	LO	f	Shared Functional Groups Sequence:Derivation Image Sequence:Derivation Code Sequence:Code Meaning	\N
4254	(5200,9229)[<0>](0062,000a)	SQ	f	Shared Functional Groups Sequence:Segment Identification Sequence	\N
4523	(0040,0275)[<0>](0008,1110)[<1>](0008,1155)	UI	f	Request Attributes Sequence:Referenced Study Sequence:Referenced SOP Instance UID	\N
4454	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a168)[<4>](0008,0102)	SH	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Concept Code Sequence:Coding Scheme Designator	\N
2797	(01f1,"ELSCINT1",26)	OB	t	Pitch	d
800	(0009,"GEMS_PETD_01",4e)	SL	t	Lower Axial Acc	k
4985	(2005,"Philips MR Imaging DD 005",0e)[<0>](2005,"Philips MR Imaging DD 005",27)	CS	t	Private Shared Sequence:Unknown	na
2162	(0013,"CTP",26)	LT	t	Unknown	ds
1515	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",53)	UN	t	Unknown	d
5129	(2005,"Philips MR Imaging DD 003",13)	OB	t	Number of Codes	k
623	(0009,"GEMS_PETD_01",eb)	FL	t	Unknown	d
5277	(2001,"Philips Imaging DD 001",0b)	OB	t	SliceOrientation	k
3034	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",52)	OB	t	Unknown:Unknown	d
5744	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",ac)	UN	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Displayed Area Bottom Right Hand Corner Fractional	k
5750	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",b5)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",b6)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Evaluation Text Position Sequence:Measurement Link Evaluation Text Flag	k
5743	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",ad)	UN	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Displayed Area Top Left Hand Corner Fractional	k
222	(0027,"GEMS_IMAG_01",4d)	FL	t	SCoordOfBottomRightCorner	k
4070	(0019,"",15)	FD	t	Unknown	d
5745	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",08)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Line Foreground Color	k
5749	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",b5)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",ff)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Evaluation Text Position Sequence:Unknown	d
5742	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",07)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Line Background Color	k
3798	(0019,"",15)	UN	t	Unknown	d
3851	(0019,"",1b)	UN	t	Unknown	d
5270	(2001,"Philips Imaging DD 001",8b)	OB	t	Transmitting Coil	k
4982	(2005,"Philips MR Imaging DD 005",0e)[<0>](0008,0016)	UI	t	Private Shared Sequence:SOP Class UID	na
3018	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
215	(0019,"GEMS_ACQU_01",1e)	DS	t	DisplayFieldOfView	k
2981	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
5161	(2005,"Philips MR Imaging DD 005",42)	OB	t	Active Implantable Medical Device B1 RMS Limit	k
4015	(0019,"",be)	UN	t	Unknown	d
512	(0043,"GEMS_PARM_01",0c)	DS	t	LimitsInUnitsOfPercent	k
1353	(01f1,"ELSCINT1",4c)	SH	t	Unknown	d
2837	(01f1,"ELSCINT1",4c)	OB	t	Unknown	d
325	(0019,"GEMS_ACQU_01",57)	SS	t	CTWaterNumber	k
1044	(0053,"GEHC_CT_ADVAPP_001",75)	UN	t	MonchromaticEnergy	k
2125	(1099,"TABLE_HEIGHT",99)	CS	t	Unknown	d
1500	(0903,"GEIIS PACS",20)	CS	t	Unknown	d
495	(0019,"GEMS_ACQU_01",b0)	DS	t	UserData	d
2831	(01f7,"ELSCINT1",16)	OB	t	Unknown	d
354	(0045,"GEMS_HELIOS_01",10)	SS	t	Start View 2A	k
232	(0043,"GEMS_PARM_01",4d)	FL	t	StartScanToXrayOnDelay	k
3015	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3062	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",61)	OB	t	Unknown:Unknown	d
569	(0053,"GEHC_CT_ADVAPP_001",65)	IS	t	Shutter Mode Percent	k
2836	(0029,"SECTRA_ImageInfo_01",04)	OB	t	Image info new	d
5260	(2005,"Philips MR Imaging DD 005",1d)	OB	t	Version Number Deleted Blobsets	k
5088	(2001,"Philips Imaging DD 001",21)	OB	t	SPIR	k
5111	(2001,"Philips Imaging DD 001",5f)	OB	t	StackSequence	k
3837	(0043,"",81)	UN	t	Unknown	d
3199	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
5328	(0015,"GEMS_PETD_01",23)	UN	t	BP3d Filter FlagU	k
2137	(0013,"CTP",26)	UN	t	Unknown	d
2889	(00e1,"ELSCINT1",39)[<0>](0032,1064)[<1>](0008,0102)	SH	t	Unknown:Requested Procedure Code Sequence:Coding Scheme Designator	d
5341	(0015,"GEMS_PETD_01",2f)	UN	t	WCC Cal Flag	k
1390	(01f7,"ELSCINT1",16)	OW	t	Unknown	d
5752	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",88)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Min Zoom In Factor	k
853	(0009,"GEMS_PETD_01",0e)	DT	t	Scan Ready	o
3915	(0019,"",b9)	UN	t	Unknown	d
448	(0021,"GEMS_RELA_01",4f)	SS	t	LocationsInAcquisition	k
2876	(00e1,"ELSCINT1",39)[<0>](0040,0260)	SQ	t	Unknown:Performed Protocol Code Sequence	d
5197	(2001,"Philips Imaging DD 001",10)	OB	t	Cardiac Sync	k
5339	(0015,"GEMS_PETD_01",22)	UN	t	IR Loop Filter Correction	k
466	(0019,"GEMS_ACQU_01",87)	DS	t	CardiacRepetition Time	k
1295	(0029,"SIEMENS MEDCOM HEADER",40)[<0>](0029,"SIEMENS MEDCOM HEADER",41)	CS	t	ApplicationHeaderSequence:ApplicationHeaderType	na
688	(0009,"GEMS_PETD_01",39)	LO	t	Measured Date Time	o
858	(0009,"GEMS_PETD_01",39)	DT	t	Measured Date Time	o
2945	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",60)	SQ	t	Unknown:Unknown	d
529	(0021,"GEMS_RELA_01",5a)	SL	t	IntegerSlop	k
1589	(0019,"SIEMENS MR HEADER",18)	IS	t	Real Dwell Time	k
3721	(0021,"Siemens: Thorax/Multix FD Post Processing",01)	SS	t	Unknown	d
2166	(7fd1,"GEIIS",30)	UL	t	Multi-Resolution Levels	k
1108	(0029,"SIEMENS MEDCOM HEADER",34)	CS	t	PMTFInformation4	d
1562	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",34)	UN	t	Unknown	d
1567	(0047,"GEMS_3DSTATE_001",ea)	DS	t	Unknown	d
299	(0027,"GEMS_IMAG_01",20)	SS	t	SmartScanOnOffFlag	k
3174	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
786	(0009,"GEMS_PETD_01",93)	SL	t	Atten Smooth	k
3736	(0021,"Siemens: Thorax/Multix FD Post Processing",08)	US	t	Auto Window Flag	d
792	(0009,"GEMS_PETD_01",1b)	SL	t	Start Condition Data	k
1267	(0009,"GEIIS",10)[<0>](0028,1050)	DS	t	GE Private Image Thumbnail Sequence:Window Center	na
3921	(0043,"",1d)	UN	t	Unknown	d
1366	(01f7,"ELSCINT1",29)	OW	t	Unknown	d
2805	(01f7,"ELSCINT1",29)	OB	t	Unknown	d
3096	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
3755	(0079,"Unnamed Private Block - 10",0d)	SH	t	Unknown	d
668	(0009,"GEMS_PETD_01",14)	LO	t	Landmark Name	k
4319	(0137,"NetRAAD",10)	PN	t	Unknown	d
5076	(2005,"Philips MR Imaging DD 005",2b)	OB	t	Exam Export Status	k
4976	(2005,"Philips MR Imaging DD 001",85)		t	Series Volume	k
200	(0019,"GEMS_ACQU_01",2b)	DS	t	XrayOffPosition	k
3714	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",01)	SS	t	Gamma LUT	d
3995	(0021,"",81)	UN	t	Unknown	d
5067	(2005,"Philips MR Imaging DD 001",85)	OB	t	Series Volume	k
428	(0019,"GEMS_ACQU_01",d7)	SS	t	CardiacPhases	k
1465	(0009,"SECTRA_Ident_01",01)	SH	t	Request number	d
2784	(0009,"SECTRA_Ident_01",01)	LO	t	Request number	d
2847	(0009,"SECTRA_Ident_01",01)	OB	t	Request number	d
776	(0009,"GEMS_PETD_01",94)	SL	t	Atten Smooth Param	k
594	(0009,"GEMS_PETD_01",3f)	FL	t	Half Life	k
1018	(7005,"TOSHIBA_MEC_CT3",20)	UL	t	Local Series Number	k
4179	(0043,"dcm4che/archive",4d)	FL	t	Unknown	d
4145	(0019,"",29)	FD	t	Unknown	d
5756	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",00)	UN	t	Advanced Presentation Sequence:Presentation Name	k
4072	(0019,"",12)	SL	t	Unknown	d
5754	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",80)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Rotation Axis	k
5758	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",78)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Unknown	d
5759	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a0)	UN	t	Advanced Presentation Sequence:Presentation State Sequence:Image Rotation Fractional	k
4174	(0029,"",03)	UN	t	Unknown	d
4089	(700d,"TOSHIBA_MEC_MR3",00)	DS	t	Scale Factor	d
4138	(0043,"GEMS_PARM_01",a5)	IS	t	Duration of the label or control pulse	d
4143	(0019,"",27)	FD	t	Unknown	d
4098	(0019,"SIEMENS MR HEADER",0e)	FD	t	Diffusion Gradient Direction	d
4112	(0077,"",02)	UN	t	Unknown	d
4123	(0019,"",25)	UN	t	Unknown	d
4173	(0029,"",02)	UN	t	Unknown	d
4192	(0043,"dcm4che/archive",43)	SL	t	Unknown	d
4153	(5653,"Vital Images SW 3.4",14)[<0>](5653,"Vital Images SW 3.4",11)	LO	t	Saved Workflow File Sequence:Saved Workflow File Name	d
4144	(0019,"",0e)	FD	t	Unknown	d
4061	(0051,"",0f)	LO	t	Unknown	d
4167	(0029,"SIEMENS CSA REPORT",09)	LO	t	Report Version	d
4083	(700d,"TOSHIBA_MEC_MR3",01)	OB	t	Acquisition Order	d
4062	(0051,"",11)	LO	t	Unknown	d
4081	(700d,"TOSHIBA_MEC_MR3",04)	OB	t	Rotate Information	d
4154	(5653,"Vital Images SW 3.4",15)[<0>](0020,0032)	DS	t	Image Sequence:Image Position (Patient)	d
1115	(0009,"GEMS_PETD_01",86)	FL	t	Zoom	k
2865	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",12)	OB	t	Unknown:Unknown	d
4322	(0023,"GEMS_STDY_01",80)[<0>](0008,1120)	SQ	t	Has MPPS Related Tags:Referenced Patient Sequence	k
503	(0019,"GEMS_ACQU_01",7f)	DS	t	TableDelta	k
2158	(0013,"CTP",14)	LO	t	Visibility	k
3159	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",50)	OB	t	Unknown:Unknown	d
5342	(0015,"GEMS_PETD_01",38)	UN	t	Unknown	d
521	(0021,"GEMS_RELA_01",56)	SL	t	IntegerSlop	k
1306	(7053,"Philips PET Private Group",06)	OB	t	Unknown	d
4126	(0019,"",16)	DS	t	Unknown	d
4177	(0043,"dcm4che/archive",4e)	FL	t	Unknown	d
4189	(0043,"dcm4che/archive",64)	CS	t	Unknown	d
3725	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",16)	SS	t	Unknown	d
2918	(00e1,"ELSCINT1",39)[<0>](0008,1140)[<1>](0008,1150)	UI	t	Unknown:Referenced Image Sequence:Referenced SOP Class UID	d
465	(0021,"GEMS_RELA_01",5d)	DS	t	FloatSlop	k
3675	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",aa)[<1>](200b,"Philips RAD Imaging DD 097",ac)	UN	t	Presentation State Sequence:Unknown:Unknown	d
4304	(0009,"CTP",02)	UN	t	Unknown	d
2796	(01f1,"ELSCINT1",4b)	OB	t	Unknown	d
4216	(0009,"EMAGEON JPEG2K INFO",01)	UN	t	Unknown	d
3796	(0019,"",16)	UN	t	Unknown	d
1137	(0009,"GEMS_PETD_01",12)	LO	t	Manufacturer	k
5434	(0019,"SIEMENS MR VA0  COAD",d9)	IS	t	LinesPerSegment	d
3077	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
3082	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",32)	OB	t	Unknown:Unknown	d
3013	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
3722	(0021,"Siemens: Thorax/Multix FD Post Processing",13)	SS	t	Unknown	d
5433	(0019,"SIEMENS CM VA0  CMS",60)	IS	t	NumberOfDataBytes	d
4441	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a010)	CS	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Relationship Type	\N
468	(0021,"GEMS_RELA_01",84)	DS	t	AutoWindowLevelLevel	k
3248	(300d,"TOMO_HA_01",a9)	UN	t	Unknown	d
383	(0043,"GEMS_PARM_01",39)	IS	t	SlopInteger6ToSlopInteger9	k
3100	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
2960	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",15)	OB	t	Unknown:Unknown	d
3872	(0019,"",9f)	UN	t	Unknown	d
868	(0009,"GEMS_PETD_01",bc)	SL	t	IR Regularize	k
644	(0009,"GEMS_PETD_01",bc)	SS	t	IR Regularize	k
5424	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0064,0003)	UI	t	Unknown:Deformable Registration Sequence:Source Frame of Reference UID	d
5425	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0070,030d)[<2>](0008,0102)	SH	t	Unknown:Deformable Registration Sequence:Registration Type Code Sequence:Coding Scheme Designator	d
802	(0009,"GEMS_PETD_01",55)	SL	t	Lower Energy Limit	k
5135	(2005,"Philips MR Imaging DD 005",4b)	OB	t	Mixing Time	k
3054	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",81)	OB	t	Unknown:Unknown	d
3183	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",96)	OB	t	Unknown:Unknown	d
182	(0019,"GEMS_ACQU_01",2e)	DS	t	AngleOfFirstView	k
5437	(0020,0050)	DS	f	Location	\N
5440	(0020,0030)	DS	f	Image Position	\N
5445	(0028,0060)	CS	f	Compression Code	\N
4267	(5200,9229)[<0>](0008,9124)[<1>](0008,2112)[<2>](0008,1155)	UI	f	Shared Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Referenced SOP Instance UID	\N
4164	(0040,a370)[<0>](0040,2016)	LO	f	Referenced Request Sequence:Placer Order Number / Imaging Service Request	\N
5449	(0028,0200)	US	f	Image Location	\N
4431	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a168)[<3>](0008,0104)	LO	f	Content Sequence:Content Sequence:Content Sequence:Concept Code Sequence:Code Meaning	\N
4546	(0008,1110)[<0>](0008,0005)	CS	f	Referenced Study Sequence:Specific Character Set	\N
4430	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)[<3>](0040,a043)[<4>](0008,0104)	LO	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence:Concept Name Code Sequence:Code Meaning	\N
4392	(5200,9230)[<0>](0008,9124)[<1>](0008,9215)	SQ	f	Per-frame Functional Groups Sequence:Derivation Image Sequence:Derivation Code Sequence	\N
4427	(0040,a730)[<0>](0040,a730)[<1>](0040,a730)[<2>](0040,a730)	SQ	f	Content Sequence:Content Sequence:Content Sequence:Content Sequence	\N
4271	(5200,9229)[<0>](0008,9124)[<1>](0008,2112)[<2>](0040,a170)[<3>](0008,0100)	SH	f	Shared Functional Groups Sequence:Derivation Image Sequence:Source Image Sequence:Purpose of Reference Code Sequence:Code Value	\N
4409	(5200,9230)[<0>](0062,000a)[<1>](0062,000b)	US	f	Per-frame Functional Groups Sequence:Segment Identification Sequence:Referenced Segment Number	\N
4291	(5200,9229)[<0>](0020,9116)[<1>](0020,0037)	DS	f	Shared Functional Groups Sequence:Plane Orientation Sequence:Image Orientation (Patient)	\N
4522	(0040,0275)[<0>](0040,0008)	SQ	f	Request Attributes Sequence:Scheduled Protocol Code Sequence	\N
5436	(0020,0070)	LO	f	Image Geometry Type	\N
5441	(0020,0035)	DS	f	Image Orientation	\N
5448	(0028,0005)	US	f	Image Dimensions	\N
5444	(0028,0040)	CS	f	Image Format	\N
4563	(0008,1048)	PN	f	Physician(s) of Record	\N
4568	(300a,03a2)[<0>](300a,0420)[<1>](300a,0421)	SH	f	Ion Beam Sequence:General Accessory Sequence:General Accessory ID	\N
4376	(0015,"GEMS_PETD_01",30)	UL	t	Emission Scatter Flag	k
4562	(0071,"SIEMENS MED PT",24)	CS	t	Time Slice Duration	k
4473	(1111,"2.16.840.1.114330.1.1.1.1",0f)	FD	t	Unknown	d
4356	(07a1,"ELSCINT1",88)	UN	t	Unknown	d
4466	(1111,"2.16.840.1.114330.1.1.1.1",04)	IS	t	Unknown	d
4469	(1111,"2.16.840.1.114330.1.1.1.1",1f)	SS	t	Unknown	d
4491	(0021,"BRIT Systems, Inc.",a0)	SQ	t	Object Action Sequence	d
4493	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",a6)	SH	t	Object Action Sequence:Local IP Address	d
4495	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",a8)	SH	t	Object Action Sequence:Remote IP Address	d
4498	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",a7)	AE	t	Object Action Sequence:Remote AE Title	d
4381	(0015,"GEMS_PETD_01",2f)	UL	t	WCC Cal Flag	k
4500	(0021,"BRIT Systems, Inc.",a0)[<0>](0021,"BRIT Systems, Inc.",a5)	AE	t	Object Action Sequence:Local AE Title	d
4489	(0043,"GEMS_PARM_01",6d)	US	t	Area Size	k
4375	(0015,"GEMS_PETD_01",23)	UL	t	BP3d Filter FlagU	k
4374	(0015,"GEMS_PETD_01",36)	UL	t	Unknown	d
4354	(07a3,"ELSCINT1",8f)	UN	t	Unknown	d
4464	(1111,"2.16.840.1.114330.1.1.1.1",0e)	UL	t	Unknown	d
4499	(0021,"BRIT Systems, Inc.",90)	AE	t	Original Sender AE Title	d
4508	(0009,"HMC - CT - ID",00)	OB	t	Image ID Information Patient Name ID	d
4377	(0015,"GEMS_PETD_01",37)	UL	t	Unknown	d
4389	(0015,"GEMS_PETD_01",20)	SL	t	First Packet Number	d
4554	(0071,"SIEMENS MED PT",24)	UN	t	Time Slice Duration	d
5376	(0071,"BLACKFORD",04)[<0>](0010,0020)	LO	t	Unknown:Patient ID	d
5405	(0071,"BLACKFORD",04)[<0>](0008,0018)	UI	t	Unknown:SOP Instance UID	d
5347	(0077,"TERARECON AQUARIUS",70)	UN	t	Algorithm ID	d
5379	(0071,"BLACKFORD",04)[<0>](0008,103e)	LO	t	Unknown:Series Description	d
5411	(0071,"BLACKFORD",04)[<0>](0008,9123)	UI	t	Unknown:Creator-Version UID	d
5400	(0071,"BLACKFORD",04)[<0>](0008,0060)	CS	t	Unknown:Modality	d
5387	(0071,"BLACKFORD",04)[<0>](0070,0084)	PN	t	Unknown:Content Creator's Name	d
5765	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",77)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Unknown	d
5360	(0077,"TERARECON AQUARIUS",26)	UN	t	Number of Binary Data	d
5368	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0008,1140)	SQ	t	Unknown:Unknown:Referenced Image Sequence	d
5407	(0071,"BLACKFORD",04)[<0>](0008,0016)	UI	t	Unknown:SOP Class UID	d
5398	(0071,"BLACKFORD",04)[<0>](0070,0080)	CS	t	Unknown:Content Label	d
5369	(0071,"BLACKFORD",04)[<0>](0070,0308)	SQ	t	Unknown:Registration Sequence	d
5356	(0077,"TERARECON AQUARIUS",16)	UN	t	Binary Data Name SCS	d
5764	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",4a)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Image Plane Distance	k
5763	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",4a)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Image Plane Distance	k
5413	(0071,"BLACKFORD",04)[<0>](0020,000d)	UI	t	Unknown:Study Instance UID	d
5375	(0071,"BLACKFORD",04)[<0>](0018,1020)	LO	t	Unknown:Software Version(s)	d
5354	(0077,"TERARECON AQUARIUS",14)	UN	t	Referenced Volume ID	d
5361	(0071,"BLACKFORD",04)[<0>](0020,0010)	SH	t	Unknown:Study ID	d
5401	(0071,"BLACKFORD",04)[<0>](0008,0031)	TM	t	Unknown:Series Time	d
698	(0017,"GEMS_PETD_01",04)	LO	t	cal_datetime	o
5397	(0071,"BLACKFORD",04)[<0>](0020,0060)	CS	t	Unknown:Laterality	d
2129	(0033,"GEMS_GENIE_1",07)	LO	t	Original SOP Instance UID	d
5367	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)	SQ	t	Unknown:Unknown	d
3744	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",19)	US	t	Ortho Subsampling	d
5406	(0071,"BLACKFORD",04)[<0>](0020,000e)	UI	t	Unknown:Series Instance UID	d
5365	(0071,"BLACKFORD",04)	SQ	t	Unknown	d
4553	(0071,"SIEMENS MED PT",22)	UN	t	Decay Correction DateTime	o
5383	(0071,"BLACKFORD",04)[<0>](0008,0070)	LO	t	Unknown:Manufacturer	d
5404	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0008,1140)[<2>](0008,1155)	UI	t	Unknown:Unknown:Referenced Image Sequence:Referenced SOP Instance UID	d
5403	(0071,"BLACKFORD",04)[<0>](0008,0030)	TM	t	Unknown:Study Time	d
5402	(0071,"BLACKFORD",04)[<0>](0008,0033)	TM	t	Unknown:Content Time	d
5381	(0071,"BLACKFORD",04)[<0>](0070,0081)	LO	t	Unknown:Content Description	d
5359	(0077,"TERARECON AQUARIUS",30)	UN	t	Binary Data Size	d
5351	(0077,"TERARECON AQUARIUS",40)	UN	t	Additional Information	d
5384	(0071,"BLACKFORD",04)[<0>](0018,1000)	LO	t	Unknown:Device Serial Number	d
5348	(0077,"TERARECON AQUARIUS",32)	UN	t	Binary Data SubType	d
5395	(0071,"BLACKFORD",04)[<0>](0008,0005)	CS	t	Unknown:Specific Character Set	d
5357	(0077,"TERARECON AQUARIUS",28)	UN	t	Binary Data Type	d
5377	(0071,"BLACKFORD",04)[<0>](0008,1030)	LO	t	Unknown:Study Description	d
5396	(0071,"BLACKFORD",04)[<0>](0010,0040)	CS	t	Unknown:Patient's Sex	d
5373	(0071,"BLACKFORD",04)[<0>](0020,1040)	LO	t	Unknown:Position Reference Indicator	d
5378	(0071,"BLACKFORD",04)[<0>](0010,0021)	LO	t	Unknown:Issuer of Patient ID	d
5353	(0077,"TERARECON AQUARIUS",80)	UN	t	Volume ID	d
5385	(0071,"BLACKFORD",04)[<0>](0020,0013)	IS	t	Unknown:Instance Number	d
5768	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",16)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Line Anti Aliasing	k
5769	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",52)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Threshold	k
412	(0019,"GEMS_ACQU_01",c3)	SS	t	SATLocationL	k
2139	(0009,"GEMS_GENIE_1",21)	SL	t	SeriesFlags	d
5421	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0064,0005)	SQ	t	Unknown:Deformable Registration Sequence:Deformable Registration Grid Sequence	d
3664	(2001,"Philips Imaging DD 129",00)[<0>](0008,1115)[<1>](2001,"Philips Imaging DD 001",c1)	LO	t	Presentation State Sequence:Referenced Series Sequence:Linear Modality GL Transform	d
3777	(0043,"GEMS_PARM_01",a8)	DS	t	Dual Drive Mode, Amplitude Attentuation and Phase Offset	d
4234	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 004",89)[<1>](2005,"Philips MR Imaging DD 004",88)	UN	t	Presentation State Sequence:Viewing Protocol:Display Layout Number of Rows	d
2127	(0011,"GEMS_GENIE_1",10)	LO	t	Unknown	d
351	(0045,"GEMS_HELIOS_01",11)	SS	t	Number of Views 2A	k
4152	(5653,"Vital Images SW 3.4",18)	SH	t	Saved Workflow Mark	d
1628	(0023,"GEMS_STDY_01",74)	SL	t	NumberOfUpdatesToHeader	k
761	(0009,"GEMS_PETD_01",e2)	SL	t	rest_stress	k
3765	(0079,"Unnamed Private Block - 10",15)	DS	t	Unknown	d
5447	(0095,"SIENET",12)	UN	t	Unknown	d
772	(0009,"GEMS_PETD_01",35)	SL	t	Triggers Rejected	k
5432	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0064,0005)[<2>](0064,0008)	FD	t	Unknown:Deformable Registration Sequence:Deformable Registration Grid Sequence:Grid Resolution	d
5428	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0070,030d)[<2>](0008,0104)	LO	t	Unknown:Deformable Registration Sequence:Registration Type Code Sequence:Code Meaning	d
5443	(0021,"SIEMENS MR VA0  GEN",44)	DS	t	CurrentSliceDistanceFactor	d
5143	(2005,"Philips MR Imaging DD 005",50)	OB	t	Number of Patient Other IDs	k
5429	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](0064,0005)[<2>](0020,0032)	DS	t	Unknown:Deformable Registration Sequence:Deformable Registration Grid Sequence:Image Position (Patient)	d
5438	(0019,"SIEMENS MR VA0  GEN",60)	DS	t	FlipAngle	d
5451	(0019,"SIEMENS CM VA0  ACQU",13)	LO	t	SequenceDescription	d
5439	(0019,"SIEMENS MR VA0  COAD",12)	DS	t	MagneticFieldStrength	d
5415	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0071,"BLACKFORD",02)[<2>](0028,0010)	US	t	Unknown:Unknown:Unknown:Rows	d
5418	(0071,"BLACKFORD",04)[<0>](0008,0023)	DA	t	Unknown:Content Date	d
5420	(0071,"BLACKFORD",04)[<0>](0064,0002)	SQ	t	Unknown:Deformable Registration Sequence	d
5446	(0009,"SIEMENS CM VA0  CMS",10)	CS	t	StorageMode	d
5427	(0071,"BLACKFORD",04)[<0>](0064,0002)[<1>](3006,00c8)	LO	t	Unknown:Deformable Registration Sequence:Frame of Reference Transformation Comment	d
5435	(0011,"SIEMENS ISI",0a)	LO	t	CaseID	d
5419	(0071,"BLACKFORD",04)[<0>](0008,0020)	DA	t	Unknown:Study Date	d
5442	(0019,"SIEMENS MR VA0  COAD",d3)	DS	t	FieldOfViewRatio	d
5417	(0071,"BLACKFORD",04)[<0>](0008,0021)	DA	t	Unknown:Series Date	d
5072	(2001,"Philips Imaging DD 001",08)	OB	t	PhaseNumber	k
1544	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",04)	CS	t	Unknown	d
1404	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",04)	OB	t	Unknown	d
1318	(7053,"Philips PET Private Group",16)	SS	t	Unknown	d
359	(0045,"GEMS_HELIOS_01",13)	SS	t	Sigma Mode	k
4578	(300a,03a2)	SQ	f	Ion Beam Sequence	\N
4622	(300a,03a2)[<0>](300a,00e0)	IS	f	Ion Beam Sequence:Number of Compensators	\N
4673	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0142)	CS	f	Ion Beam Sequence:Ion Control Point Sequence:Table Top Pitch Rotation Direction	\N
4646	(300a,03a0)[<0>](300a,0052)	DS	f	Ion Tolerance Table Sequence:Table Top Longitudinal Position Tolerance	\N
4610	(300a,03a2)[<0>](300a,0312)	IS	f	Ion Beam Sequence:Number of Range Shifters	\N
4584	(300a,03a2)[<0>](300a,0342)	SQ	f	Ion Beam Sequence:Range Modulator Sequence	\N
4592	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0370)	SQ	f	Ion Beam Sequence:Ion Control Point Sequence:Lateral Spreading Device Settings Sequence	\N
4583	(300a,03a2)[<0>](300a,0332)	SQ	f	Ion Beam Sequence:Lateral Spreading Device Sequence	\N
4629	(300a,03a2)[<0>](300c,00a0)	IS	f	Ion Beam Sequence:Referenced Tolerance Table Number	\N
4602	(300a,03a2)[<0>](300a,0354)	LO	f	Ion Beam Sequence:Patient Support Accessory Code	\N
4596	(300a,03a2)[<0>](0008,0070)	LO	f	Ion Beam Sequence:Manufacturer	\N
4577	(300a,03a2)[<0>](300a,02ea)	SQ	f	Ion Beam Sequence:Ion Range Compensator Sequence	\N
4667	(300a,03a2)[<0>](300a,0350)	CS	f	Ion Beam Sequence:Patient Support Type	\N
4597	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00f9)	LO	f	Beam Sequence:Block Sequence:Accessory Code	\N
4641	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0129)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Table Top Longitudinal Position	\N
4581	(300a,03a2)[<0>](300a,03a8)[<1>](300c,0050)	SQ	f	Ion Beam Sequence:Ion Control Point Sequence:Referenced Dose Reference Sequence	\N
4650	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0120)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Beam Limiting Device Angle	\N
4619	(300a,03a2)[<0>](300a,0340)	IS	f	Ion Beam Sequence:Number of Range Modulators	\N
4636	(300a,03a2)[<0>](300a,03a6)[<1>](300a,0106)	DS	f	Ion Beam Sequence:Ion Block Sequence:Block Data	\N
4590	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0360)	SQ	f	Ion Beam Sequence:Ion Control Point Sequence:Range Shifter Settings Sequence	\N
4659	(300a,03a2)[<0>](300a,03a6)[<1>](300a,00fa)	CS	f	Ion Beam Sequence:Ion Block Sequence:Block Divergence	\N
4634	(300a,03a2)[<0>](300a,03a8)[<1>](300a,012c)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Isocenter Position	\N
4615	(300a,03a2)[<0>](300a,03a8)[<1>](300c,0050)[<2>](300c,0051)	IS	f	Ion Beam Sequence:Ion Control Point Sequence:Referenced Dose Reference Sequence:Referenced Dose Reference Number	\N
4601	(300a,03a2)[<0>](300a,03a6)[<1>](300a,00fe)	LO	f	Ion Beam Sequence:Ion Block Sequence:Block Name	\N
4645	(300a,03a2)[<0>](300a,03a8)[<1>](300a,012a)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Table Top Lateral Position	\N
4621	(300a,03a2)[<0>](300a,0342)[<1>](300a,0344)	IS	f	Ion Beam Sequence:Range Modulator Sequence:Range Modulator Number	\N
4608	(300a,03a2)[<0>](300a,0332)[<1>](300a,0334)	IS	f	Ion Beam Sequence:Lateral Spreading Device Sequence:Lateral Spreading Device Number	\N
4658	(300a,03a2)[<0>](300a,02ea)[<1>](300a,02e0)	CS	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Divergence	\N
4611	(300a,03a2)[<0>](300a,0330)	IS	f	Ion Beam Sequence:Number of Lateral Spreading Devices	\N
4606	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00e8)	IS	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Columns	\N
4593	(300a,00b0)[<0>](0018,1000)	LO	f	Beam Sequence:Device Serial Number	\N
4571	(300a,03a2)[<0>](300a,0332)[<1>](300a,0336)	SH	f	Ion Beam Sequence:Lateral Spreading Device Sequence:Lateral Spreading Device ID	\N
4617	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00e4)	IS	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Number	\N
4628	(300a,03a0)[<0>](300a,0042)	IS	f	Ion Tolerance Table Sequence:Tolerance Table Number	\N
4631	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00e7)	IS	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Rows	\N
4642	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0134)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Cumulative Meterset Weight	\N
4625	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0112)	IS	f	Ion Beam Sequence:Ion Control Point Sequence:Control Point Index	\N
4595	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0360)[<2>](300a,0362)	LO	f	Ion Beam Sequence:Ion Control Point Sequence:Range Shifter Settings Sequence:Range Shifter Setting	\N
4600	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00fe)	LO	f	Beam Sequence:Block Sequence:Block Name	\N
4618	(300a,03a2)[<0>](300a,00f0)	IS	f	Ion Beam Sequence:Number of Blocks	\N
4582	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0380)	SQ	f	Ion Beam Sequence:Ion Control Point Sequence:Range Modulator Settings Sequence	\N
4647	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0128)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Table Top Vertical Position	\N
4656	(300a,03a2)[<0>](300a,00ce)	CS	f	Ion Beam Sequence:Treatment Delivery Type	\N
4624	(300a,03a2)[<0>](300c,0042)[<1>](300a,00c8)	IS	f	Ion Beam Sequence:Referenced Reference Image Sequence:Reference Image Number	\N
4664	(300a,03a2)[<0>](300a,0342)[<1>](300a,0348)	CS	f	Ion Beam Sequence:Range Modulator Sequence:Range Modulator Type	\N
4607	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0370)[<2>](300c,0102)	IS	f	Ion Beam Sequence:Ion Control Point Sequence:Lateral Spreading Device Settings Sequence:Referenced Lateral Spreading Device Number	\N
4661	(300a,03a2)[<0>](300a,00c4)	CS	f	Ion Beam Sequence:Beam Type	\N
4632	(300a,03a2)[<0>](300a,03a8)[<1>](300a,011e)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Gantry Angle	\N
4603	(300a,00b0)[<0>](0008,1040)	LO	f	Beam Sequence:Institutional Department Name	\N
4670	(300a,03a2)[<0>](300a,03a6)[<1>](300a,00fb)	CS	f	Ion Beam Sequence:Ion Block Sequence:Block Mounting Position	\N
4574	(300a,03a2)[<0>](300a,030c)[<1>](300a,030f)	SH	f	Ion Beam Sequence:Snout Sequence:Snout ID	\N
4666	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0015)	CS	f	Ion Beam Sequence:Ion Control Point Sequence:Nominal Beam Energy Unit	\N
527	(0029,"GEMS_IMPS_01",17)	SL	t	LowerRangeOfPixels	k
5394	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0071,"BLACKFORD",02)[<2>](0020,0037)	DS	t	Unknown:Unknown:Unknown:Image Orientation (Patient)	d
3074	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",60)	OB	t	Unknown:Unknown	d
4684	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0360)[<2>](300a,0366)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Range Shifter Settings Sequence:Range Shifter Water Equivalent Thickness	\N
4685	(300a,03a0)[<0>](300a,004f)	FL	f	Ion Tolerance Table Sequence:Table Top Pitch Angle Tolerance	\N
4755	(300a,03a2)[<0>](300a,0342)[<1>](300a,034c)	SH	f	Ion Beam Sequence:Range Modulator Sequence:Beam Current Modulation ID	\N
4726	(300a,00b0)[<0>](300a,00ca)[<1>](300a,00cc)	LO	f	Beam Sequence:Planned Verification Image Sequence:Imaging Device-Specific Acquisition Parameters	\N
4772	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00ea)	DS	f	Beam Sequence:Compensator Sequence:Compensator Position	\N
4725	(300a,00b0)[<0>](300a,00ca)	SQ	f	Beam Sequence:Planned Verification Image Sequence	\N
4758	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00f9)	LO	f	Ion Beam Sequence:Ion Range Compensator Sequence:Accessory Code	\N
4696	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0370)[<2>](300a,0374)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Lateral Spreading Device Settings Sequence:Isocenter to Lateral Spreading Device Distance	\N
4765	(300a,03a2)[<0>](300a,03a4)[<1>](300a,00bb)	FL	f	Ion Beam Sequence:Ion Beam Limiting Device Sequence:Isocenter to Beam Limiting Device Distance	\N
4768	(300a,00b0)[<0>](300a,00e3)	SQ	f	Beam Sequence:Compensator Sequence	\N
4697	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0380)[<2>](300a,0388)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Range Modulator Settings Sequence:Range Modulator Gating Stop Water Equivalent Thickness	\N
4694	(300a,03a2)[<0>](300a,03a8)[<1>](300a,035a)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Meterset Rate	\N
4713	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0392)	IS	f	Ion Beam Sequence:Ion Control Point Sequence:Number of Scan Spot Positions	\N
4719	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0394)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Scan Spot Position Map	\N
4767	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00e1)	SH	f	Beam Sequence:Compensator Sequence:Material ID	\N
4692	(300a,03a2)[<0>](300a,03a6)[<1>](300a,00f7)	FL	f	Ion Beam Sequence:Ion Block Sequence:Isocenter to Block Tray Distance	\N
4691	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0140)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Table Top Pitch Angle	\N
4686	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0360)[<2>](300a,0364)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Range Shifter Settings Sequence:Isocenter to Range Shifter Distance	\N
4690	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0380)[<2>](300a,0382)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Range Modulator Settings Sequence:Range Modulator Gating Start Value	\N
4756	(300a,03a2)[<0>](300a,03a8)[<1>](300a,011a)	SQ	f	Ion Beam Sequence:Ion Control Point Sequence:Beam Limiting Device Position Sequence	\N
4750	(300a,00b0)[<0>](300a,0111)[<1>](300a,014c)	CS	f	Beam Sequence:Control Point Sequence:Gantry Pitch Rotation Direction	\N
4700	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0380)[<2>](300a,038a)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Range Modulator Settings Sequence:Isocenter to Range Modulator Distance	\N
4687	(300a,03a2)[<0>](300a,03a8)[<1>](300a,014a)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Gantry Pitch Angle	\N
4751	(300a,0070)[<0>](300c,0004)[<1>](300a,0089)	FL	f	Fraction Group Sequence:Referenced Beam Sequence:Beam Dose Point Equivalent Depth	\N
4764	(300a,03a2)[<0>](300a,03a8)[<1>](300a,011a)[<2>](300a,00b8)	CS	f	Ion Beam Sequence:Ion Control Point Sequence:Beam Limiting Device Position Sequence:RT Beam Limiting Device Type	\N
4701	(300a,03a2)[<0>](300c,0042)[<1>](0008,1150)	UI	f	Ion Beam Sequence:Referenced Reference Image Sequence:Referenced SOP Class UID	\N
4773	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00e6)	DS	f	Beam Sequence:Compensator Sequence:Source to Compensator Tray Distance	\N
4757	(300a,03a2)[<0>](300a,03a4)	SQ	f	Ion Beam Sequence:Ion Beam Limiting Device Sequence	\N
4760	(300a,03a2)[<0>](300a,03a4)[<1>](300a,00be)	DS	f	Ion Beam Sequence:Ion Beam Limiting Device Sequence:Leaf Position Boundaries	\N
4728	(300a,00b0)[<0>](300a,00ca)[<1>](3002,000e)	DS	f	Beam Sequence:Planned Verification Image Sequence:X-Ray Image Receptor Angle	\N
4761	(300a,03a2)[<0>](300a,03a8)[<1>](300a,011a)[<2>](300a,011c)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Beam Limiting Device Position Sequence:Leaf/Jaw Positions	\N
4689	(300a,03a2)[<0>](300a,02ea)[<1>](300a,02e5)	FL	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Column Offset	\N
4759	(300a,03a2)[<0>](300a,03a4)[<1>](300a,00bc)	IS	f	Ion Beam Sequence:Ion Beam Limiting Device Sequence:Number of Leaf/Jaw Pairs	\N
4775	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00e9)	DS	f	Beam Sequence:Compensator Sequence:Compensator Pixel Spacing	\N
4688	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0144)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Table Top Roll Angle	\N
4771	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00e4)	IS	f	Beam Sequence:Compensator Sequence:Compensator Number	\N
4733	(300a,0180)[<0>](300a,0410)[<1>](0018,9171)	CS	f	Patient Setup Sequence:Motion Synchronization Sequence:Respiratory Signal Source	\N
4727	(300a,00b0)[<0>](300a,00ca)[<1>](3002,0012)	DS	f	Beam Sequence:Planned Verification Image Sequence:RT Image Position	\N
4730	(300a,00b0)[<0>](300a,00ca)[<1>](3002,000c)	CS	f	Beam Sequence:Planned Verification Image Sequence:RT Image Plane	\N
4716	(300a,0180)[<0>](300a,01d6)	DS	f	Patient Setup Sequence:Table Top Lateral Setup Displacement	\N
4780	(300a,00b0)[<0>](300c,00b0)[<1>](300a,00dc)	SH	f	Beam Sequence:Referenced Bolus Sequence:Bolus ID	\N
4711	(300a,03a2)[<0>](300a,00c3)	ST	f	Ion Beam Sequence:Beam Description	\N
4766	(300a,03a2)[<0>](0008,0080)	LO	f	Ion Beam Sequence:Institution Name	\N
4763	(300a,03a2)[<0>](300a,03a4)[<1>](300a,00b8)	CS	f	Ion Beam Sequence:Ion Beam Limiting Device Sequence:RT Beam Limiting Device Type	\N
4698	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0380)[<2>](300a,0386)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Range Modulator Settings Sequence:Range Modulator Gating Start Water Equivalent Thickness	\N
4142	(0019,"",0c)	IS	t	Unknown	d
3050	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",30)	OB	t	Unknown:Unknown	d
1545	(0019,"SIEMENS MR HEADER",0f)	SH	t	Gradient Mode	k
504	(0019,"GEMS_ACQU_01",b4)	DS	t	UserData	d
214	(0019,"GEMS_ACQU_01",db)	DS	t	BackProjectorCoefficient	k
5223	(2005,"Philips MR Imaging DD 001",1b)	OB	t	Magnetization Prepared	k
3903	(0019,"",ad)	UN	t	Unknown	d
340	(0045,"GEMS_HELIOS_01",0b)	FL	t	Maximum Offset Value	k
5409	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0020,0052)	UI	t	Unknown:Registration Sequence:Frame of Reference UID	d
5366	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)	SQ	t	Unknown:Registration Sequence:Matrix Registration Sequence	d
5372	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0071,"BLACKFORD",02)	SQ	t	Unknown:Unknown:Unknown	d
5363	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)[<2>](0070,030d)[<3>](0008,0100)	SH	t	Unknown:Registration Sequence:Matrix Registration Sequence:Registration Type Code Sequence:Code Value	d
5392	(0071,"BLACKFORD",04)[<0>](0071,"BLACKFORD",01)[<1>](0071,"BLACKFORD",03)	DS	t	Unknown:Unknown:Unknown	d
5390	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)[<2>](0070,030a)[<3>](3006,00c6)	DS	t	Unknown:Registration Sequence:Matrix Registration Sequence:Matrix Sequence:Frame of Reference Transformation Matrix	d
5399	(0071,"BLACKFORD",04)[<0>](0070,0308)[<1>](0070,0309)[<2>](0070,030a)[<3>](0070,030c)	CS	t	Unknown:Registration Sequence:Matrix Registration Sequence:Matrix Sequence:Frame of Reference Transformation Matrix Type	d
5374	(0071,"BLACKFORD",04)[<0>](0008,1090)	LO	t	Unknown:Manufacturer's Model Name	d
5358	(0077,"TERARECON AQUARIUS",90)	UN	t	COF Refinement Level	d
5355	(0077,"TERARECON AQUARIUS",20)	UN	t	Binary Data Name	d
5350	(0077,"TERARECON AQUARIUS",24)	UN	t	Number of Series Instance UID	d
4906	(0010,9910)	PN	f	<undef>	\N
4898	(0010,9910)	UN	f	<undef>	\N
4819	(0027,"GEMS_IMAG_01",42)	OB	t	CenterRCoordOfPlaneImage	k
4779	(300a,00b0)[<0>](3283,"Varian Medical Systems VISION 3283",60)	UN	t	Beam Sequence:Unknown	d
4799	(0053,"GEHC_CT_ADVAPP_001",9d)	OB	t	Unknown	d
4807	(0043,"GEMS_PARM_01",43)	OB	t	DASFpaGain	k
4789	(0019,"GEMS_ACQU_01",2f)	OB	t	TriggerFrequency	k
4806	(0045,"GEMS_HELIOS_01",04)	OB	t	DAS gain	k
4793	(0019,"GEMS_ACQU_01",0f)	OB	t	HorizontalFrameOfReference	d
4800	(0053,"GEHC_CT_ADVAPP_001",64)	OB	t	Shutter Mode	k
4790	(0045,"GEMS_HELIOS_01",06)	OB	t	Table Direction	k
4739	(01e1,"ELSCINT1",1e)	UN	t	Unknown	d
4723	(300a,03a2)[<0>](300b,"RAYSEARCHLABS 1.0",02)	UN	t	Ion Beam Sequence:Unknown	d
4826	(0019,"GEMS_ACQU_01",11)	OB	t	SeriesContrast	k
4754	(3006,0080)[<0>](4001,"RAYSEARCHLABS 2.0",10)	UN	t	RT ROI Observations Sequence:Unknown	d
4738	(01f1,"ELSCINT1",41)	UN	t	Unknown	d
4731	(300a,0070)[<0>](300c,0004)[<1>](3249,"Varian Medical Systems VISION 3249",10)	UI	t	Fraction Group Sequence:Referenced Beam Sequence:Unknown	d
4824	(0045,"GEMS_HELIOS_01",03)	OB	t	DAS type	k
4791	(0053,"GEHC_CT_ADVAPP_001",43)	OB	t	Iterative Recon Level	k
4707	(300a,03a2)[<0>](300b,"IMPAC",02)	UN	t	Ion Beam Sequence:Unknown	d
4746	(300a,03a2)[<0>](300b,"IMPAC",04)	FL	t	Ion Beam Sequence:Unknown	d
4737	(01e1,"ELSCINT1",1c)	UN	t	Unknown	d
2975	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",63)	OB	t	Unknown:Unknown	d
348	(0045,"GEMS_HELIOS_01",03)	SS	t	DAS type	k
2121	(3773,"MIM Software Inc.",0c)	UN	t	Unknown	d
1102	(0043,"GEMS_PARM_01",9a)	IS	t	Rx Stack Identification	k
598	(0009,"GEMS_PETD_01",3c)	FL	t	Post Injected Activity	k
4952	(0008,9215)[<0>](0008,0103)	SH	f	Derivation Code Sequence:Coding Scheme Version	\N
4946	(0018,1261)	LO	f	Phosphor Type	\N
4953	(0018,1080)	CS	f	Beat Rejection Flag	\N
4938	(0008,001b)	UI	f	Original Specialized SOP Class UID	\N
4947	(0018,7065)	DS	f	Phototimer Setting	\N
4942	(0008,1150)	UI	f	Referenced SOP Class UID	\N
4837	(0043,"GEMS_PARM_01",4d)	OB	t	StartScanToXrayOnDelay	k
4832	(0043,"GEMS_PARM_01",1f)	OB	t	MaxOverrangesInAView	k
4897	(0137,"NetRAAD",01)	UN	t	Unknown	d
4856	(0045,"GEMS_HELIOS_01",08)	OB	t	View Weighting Mode	k
4904	(0045,"GEMS_HELIOS_01",51)	FD	t	Unknown	d
4905	(0045,"GEMS_HELIOS_01",53)	FD	t	Unknown	d
4866	(0043,"GEMS_PARM_01",46)	OB	t	DASCalMode	k
4894	(0137,"NetRAAD",10)	UN	t	Unknown	d
4891	(0137,"NetRAAD",20)	UN	t	Unknown	d
4883	(0053,"GEHC_CT_ADVAPP_001",62)	OB	t	Respiratory Flag	k
4034	(0051,"",17)	SH	t	Unknown	d
4857	(0019,"GEMS_ACQU_01",39)	OB	t	ScanFOVType	k
3972	(0043,"",9a)	UN	t	Unknown	d
4868	(0045,"GEMS_HELIOS_01",0f)	OB	t	Z tracking Error	k
1358	(01f1,"ELSCINT1",4b)	SH	t	Unknown	d
4911	(0045,"GEMS_HELIOS_01",55)	OB	t	Unknown	d
4851	(0045,"GEMS_HELIOS_01",13)	OB	t	Sigma Mode	k
4930	(5001,"ELSCINT1",a1)	CS	t	Unknown	d
4919	(0053,"GEHC_CT_ADVAPP_001",6a)	OB	t	Unknown	d
4865	(0027,"GEMS_IMAG_01",20)	OB	t	SmartScanOnOffFlag	k
499	(0019,"GEMS_ACQU_01",b7)	DS	t	UserData	d
4878	(0009,"GEMS_IDEN_01",02)	OB	t	SuiteId	d
3179	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
4877	(0019,"GEMS_ACQU_01",23)	OB	t	TableSpeed	k
4863	(0027,"GEMS_IMAG_01",50)	OB	t	TableStartLocation	k
4888	(0053,"GEHC_CT_ADVAPP_001",41)	OB	t	Iterative Recon Mode	k
342	(0045,"GEMS_HELIOS_01",0f)	FL	t	Z tracking Error	k
4843	(0043,"GEMS_PARM_01",25)	OB	t	ReferenceChannels	k
438	(0027,"GEMS_IMAG_01",32)	SS	t	PulseSequence	k
3180	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
4880	(0019,"GEMS_ACQU_01",2e)	OB	t	AngleOfFirstView	k
4854	(0019,"GEMS_ACQU_01",6a)	OB	t	DependantOnNumberOfViewsProcessed	d
1424	(0009,"GEMS_PETD_01",32)	SL	t	Lower Reject Limit	d
4889	(0019,"SIEMENS CT VA0  COAD",b1)	SH	t	Unknown	d
158	(0029,"GEMS_IMPS_01",08)	SH	t	LowerRangeOfPixels	k
4939	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)	UN	t	Advanced Presentation Sequence	k
4879	(0043,"GEMS_PARM_01",27)	OB	t	ScanPitchRatio	k
793	(0009,"GEMS_PETD_01",ec)	SL	t	Unknown	d
4923	(5001,"ELSCINT1",94)	FL	t	Unknown	d
4848	(0043,"GEMS_PARM_01",21)	OB	t	CorrectedAfterglowTerms	k
4846	(0019,"GEMS_ACQU_01",26)	OB	t	DegreesOfAzimuth	k
1585	(0019,"SIEMENS MR HEADER",0d)	CS	t	Diffusion Directionality	k
69	(0019,"SIEMENS MR HEADER",0d)	OB	t	Diffusion Directionality	k
4566	(300a,03a2)[<0>](300a,0342)[<1>](300a,0346)	SH	f	Ion Beam Sequence:Range Modulator Sequence:Range Modulator ID	\N
4576	(300a,03a2)[<0>](300a,03a6)[<1>](300a,00e1)	SH	f	Ion Beam Sequence:Ion Block Sequence:Material ID	\N
758	(0009,"GEMS_PETD_01",74)	SL	t	validity_info	k
1593	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",65)	UN	t	Unknown	d
3098	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",82)	OB	t	Unknown:Unknown	d
4676	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0121)	CS	f	Ion Beam Sequence:Ion Control Point Sequence:Beam Limiting Device Rotation Direction	\N
4653	(300a,03a0)[<0>](300a,0053)	DS	f	Ion Tolerance Table Sequence:Table Top Lateral Position Tolerance	\N
3655	(200b,"Philips RAD Imaging DD 097",aa)	SQ	t	Unknown	d
4609	(300a,03a2)[<0>](300a,0314)[<1>](300a,0316)	IS	f	Ion Beam Sequence:Range Shifter Sequence:Range Shifter Number	\N
5773	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",47)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Aspect Ratio	k
4572	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00e5)	SH	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator ID	\N
4633	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00ea)	DS	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Position	\N
4616	(300a,03a2)[<0>](300a,00c0)	IS	f	Ion Beam Sequence:Beam Number	\N
4598	(300a,03a2)[<0>](300a,00c2)	LO	f	Ion Beam Sequence:Beam Name	\N
1429	(0009,"GEMS_IDEN_01",5f)	UN	t	Unknown	d
4662	(300a,03a2)[<0>](300a,00b3)	CS	f	Ion Beam Sequence:Primary Dosimeter Unit	\N
4589	(300a,03a2)[<0>](300a,030c)	SQ	f	Ion Beam Sequence:Snout Sequence	\N
4569	(300a,03a0)[<0>](300a,0043)	SH	f	Ion Tolerance Table Sequence:Tolerance Table Label	\N
3644	(0011,"GEMS_GDXE_FALCON_04",64)	UN	t	Unknown	d
474	(0019,"GEMS_ACQU_01",e2)	DS	t	VelocityEncodeScale	k
4599	(300a,00b0)[<0>](300a,0107)[<1>](300a,00f9)	LO	f	Beam Sequence:Applicator Sequence:Accessory Code	\N
4663	(300a,03a2)[<0>](300a,0420)[<1>](300a,0423)	CS	f	Ion Beam Sequence:General Accessory Sequence:General Accessory Type	\N
798	(0009,"GEMS_PETD_01",4f)	SL	t	Upper Axial Acc	k
4963	(2001,"Philips Imaging DD 001",26)	CS	t	Presentation State Subtraction Active	k
1379	(01f7,"ELSCINT1",75)	OW	t	Unknown	d
4669	(300a,03a2)[<0>](300a,02ea)[<1>](300a,02e1)	CS	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Mounting Position	\N
1606	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",12)	UN	t	Unknown	d
4665	(300a,03a2)[<0>](300a,03a6)[<1>](300a,00f8)	CS	f	Ion Beam Sequence:Ion Block Sequence:Block Type	\N
4643	(300a,03a2)[<0>](300a,010e)	DS	f	Ion Beam Sequence:Final Cumulative Meterset Weight	\N
4579	(300a,03a2)[<0>](300a,03a6)	SQ	f	Ion Beam Sequence:Ion Block Sequence	\N
4678	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0123)	CS	f	Ion Beam Sequence:Ion Control Point Sequence:Patient Support Rotation Direction	\N
4564	(300e,0008)	PN	f	Reviewer Name	\N
4722	(300a,0070)[<0>](300c,0004)[<1>](300a,008a)	FL	f	Fraction Group Sequence:Referenced Beam Sequence:Beam Dose Point SSD	\N
4769	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00e8)	IS	f	Beam Sequence:Compensator Sequence:Compensator Columns	\N
2973	(0021,"FDMS 1.0",10)	OB	t	FCRImageID	d
3950	(0027,"",31)	UN	t	Unknown	d
4732	(300a,0180)[<0>](300a,0410)	SQ	f	Patient Setup Sequence:Motion Synchronization Sequence	\N
4594	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0370)[<2>](300a,0372)	LO	f	Ion Beam Sequence:Ion Control Point Sequence:Lateral Spreading Device Settings Sequence:Lateral Spreading Device Setting	\N
5297	(2005,"Philips MR Imaging DD 005",90)	UN	t	Original VOI LUT Sequence	d
1097	(7005,"TOSHIBA_MEC_CT3",22)	UN	t	Reconstruction Interval	k
4654	(300a,03a0)[<0>](300a,0051)	DS	f	Ion Tolerance Table Sequence:Table Top Vertical Position Tolerance	\N
2894	(00e1,"ELSCINT1",39)[<0>](0032,1064)[<1>](0008,0100)	SH	t	Unknown:Requested Procedure Code Sequence:Code Value	d
1346	(0009,"GEMS_PETD_01",a9)	SL	t	other_atts_size	k
487	(0019,"GEMS_ACQU_01",be)	DS	t	ProjectionAngle	k
464	(0019,"GEMS_ACQU_01",93)	DS	t	CenterFrequency	k
5293	(2001,"Philips Imaging DD 129",00)[<0>](0070,0060)[<1>](0070,0002)	CS	t	Presentation State Sequence:Graphic Layer Sequence:Graphic Layer	na
4239	(0077,"NIL_nICE_ATT",01)	FL	t	Unknown	d
4630	(300a,03a2)[<0>](300a,03a6)[<1>](300a,00fc)	IS	f	Ion Beam Sequence:Ion Block Sequence:Block Number	\N
4587	(300a,03a0)	SQ	f	Ion Tolerance Table Sequence	\N
4710	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0390)	SH	f	Ion Beam Sequence:Ion Control Point Sequence:Scan Spot Tune ID	\N
4657	(300a,03a0)[<0>](300a,0048)[<1>](300a,00b8)	CS	f	Ion Tolerance Table Sequence:Beam Limiting Device Tolerance Sequence:RT Beam Limiting Device Type	\N
4762	(300a,0010)[<0>](300a,0018)	DS	f	Dose Reference Sequence:Dose Reference Point Coordinates	\N
4660	(300a,03a2)[<0>](300a,00c6)	CS	f	Ion Beam Sequence:Radiation Type	\N
4680	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0370)[<2>](300a,033c)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Lateral Spreading Device Settings Sequence:Lateral Spreading Device Water Equivalent Thickness	\N
4635	(300a,03a0)[<0>](300a,0048)[<1>](300a,004a)	DS	f	Ion Tolerance Table Sequence:Beam Limiting Device Tolerance Sequence:Beam Limiting Device Position Tolerance	\N
4612	(300a,03a2)[<0>](300c,006a)	IS	f	Ion Beam Sequence:Referenced Patient Setup Number	\N
4774	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00eb)	DS	f	Beam Sequence:Compensator Sequence:Compensator Transmission Data	\N
4672	(300a,03a2)[<0>](300a,0332)[<1>](300a,0338)	CS	f	Ion Beam Sequence:Lateral Spreading Device Sequence:Lateral Spreading Device Type	\N
4747	(300a,03a2)[<0>](300a,02ea)[<1>](300a,02e8)	FL	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Milling Tool Diameter	\N
4718	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0396)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Scan Spot Meterset Weights	\N
4693	(300a,03a2)[<0>](300a,02ea)[<1>](300a,02e4)	FL	f	Ion Beam Sequence:Ion Range Compensator Sequence:Isocenter to Compensator Tray Distance	\N
4712	(300a,0009)	LO	f	Treatment Protocols	\N
4591	(300a,03a2)[<0>](300a,03a8)	SQ	f	Ion Beam Sequence:Ion Control Point Sequence	\N
4637	(300a,03a2)[<0>](300a,03a8)[<1>](300c,0050)[<2>](300a,010c)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Referenced Dose Reference Sequence:Cumulative Dose Reference Coefficient	\N
5799	(2005,"Philips MR Imaging DD 006",81)	CS	t	Unknown	d
4679	(300a,03a2)[<0>](300a,030a)	FL	f	Ion Beam Sequence:Virtual Source-Axis Distances	\N
4655	(300a,03a2)[<0>](300a,03a8)[<1>](300a,014c)	CS	f	Ion Beam Sequence:Ion Control Point Sequence:Gantry Pitch Rotation Direction	\N
4614	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0360)[<2>](300c,0100)	IS	f	Ion Beam Sequence:Ion Control Point Sequence:Range Shifter Settings Sequence:Referenced Range Shifter Number	\N
4729	(300a,00b0)[<0>](300a,00ca)[<1>](3002,0026)	DS	f	Beam Sequence:Planned Verification Image Sequence:RT Image SID	\N
4580	(300a,03a2)[<0>](300a,0314)	SQ	f	Ion Beam Sequence:Range Shifter Sequence	\N
4586	(300a,03a2)[<0>](300a,0420)	SQ	f	Ion Beam Sequence:General Accessory Sequence	\N
4573	(300a,03a2)[<0>](300a,0352)	SH	f	Ion Beam Sequence:Patient Support ID	\N
4681	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0380)[<2>](300a,0384)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Range Modulator Settings Sequence:Range Modulator Gating Stop Value	\N
5795	(2005,"Philips MR Imaging DD 006",63)	CS	t	Unknown	d
4585	(300a,03a0)[<0>](300a,0048)	SQ	f	Ion Tolerance Table Sequence:Beam Limiting Device Tolerance Sequence	\N
5798	(2005,"Philips MR Imaging DD 006",78)	CS	t	Unknown	d
4721	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0398)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Scanning Spot Size	\N
4605	(300a,03a2)[<0>](300a,03a6)[<1>](300a,0104)	IS	f	Ion Beam Sequence:Ion Block Sequence:Block Number of Points	\N
4671	(300a,00b0)[<0>](300a,00f4)[<1>](300a,00fb)	CS	f	Beam Sequence:Block Sequence:Block Mounting Position	\N
4777	(300a,0040)[<0>](300a,0050)	FL	f	Tolerance Table Sequence:Table Top Roll Angle Tolerance	\N
5794	(2005,"Philips MR Imaging DD 006",66)	CS	t	Unknown	d
4717	(300a,0180)[<0>](300a,01d4)	DS	f	Patient Setup Sequence:Table Top Longitudinal Setup Displacement	\N
4575	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00e1)	SH	f	Ion Beam Sequence:Ion Range Compensator Sequence:Material ID	\N
4626	(300a,03a2)[<0>](300a,00d0)	IS	f	Ion Beam Sequence:Number of Wedges	\N
4648	(300a,03a0)[<0>](300a,0044)	DS	f	Ion Tolerance Table Sequence:Gantry Angle Tolerance	\N
4770	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00e7)	IS	f	Beam Sequence:Compensator Sequence:Compensator Rows	\N
4683	(300a,03a0)[<0>](300a,0050)	FL	f	Ion Tolerance Table Sequence:Table Top Roll Angle Tolerance	\N
4776	(300a,00b0)[<0>](300a,00e3)[<1>](300a,00ee)	CS	f	Beam Sequence:Compensator Sequence:Compensator Type	\N
4604	(300a,03a2)[<0>](0008,1090)	LO	f	Ion Beam Sequence:Manufacturer's Model Name	\N
4720	(300a,0070)[<0>](300c,0004)[<1>](300a,0088)	FL	f	Fraction Group Sequence:Referenced Beam Sequence:Beam Dose Point Depth	\N
5791	(2005,"Philips MR Imaging DD 006",83)	LT	t	Unknown	d
4640	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00ec)	DS	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Thickness Data	\N
4752	(300a,00b0)[<0>](300a,0111)[<1>](300a,014a)	FL	f	Beam Sequence:Control Point Sequence:Gantry Pitch Angle	\N
4651	(300a,03a2)[<0>](300a,02ea)[<1>](300a,00e9)	DS	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Pixel Spacing	\N
4695	(300a,03a2)[<0>](300a,03a8)[<1>](300a,030d)	FL	f	Ion Beam Sequence:Ion Control Point Sequence:Snout Position	\N
4743	(300a,03a2)[<0>](0008,1040)	LO	f	Ion Beam Sequence:Institutional Department Name	\N
4620	(300a,03a2)[<0>](300a,0420)[<1>](300a,0424)	IS	f	Ion Beam Sequence:General Accessory Sequence:General Accessory Number	\N
4588	(300a,03a2)[<0>](300c,0042)	SQ	f	Ion Beam Sequence:Referenced Reference Image Sequence	\N
4702	(300a,03a2)[<0>](300c,0042)[<1>](0008,1155)	UI	f	Ion Beam Sequence:Referenced Reference Image Sequence:Referenced SOP Instance UID	\N
4649	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0122)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Patient Support Angle	\N
4677	(300a,03a2)[<0>](300a,03a8)[<1>](300a,011f)	CS	f	Ion Beam Sequence:Ion Control Point Sequence:Gantry Rotation Direction	\N
4668	(300a,03a2)[<0>](300a,0314)[<1>](300a,0320)	CS	f	Ion Beam Sequence:Range Shifter Sequence:Range Shifter Type	\N
4623	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0380)[<2>](300c,0104)	IS	f	Ion Beam Sequence:Ion Control Point Sequence:Range Modulator Settings Sequence:Referenced Range Modulator Number	\N
4682	(300a,03a0)[<0>](300a,004b)	FL	f	Ion Tolerance Table Sequence:Snout Position Tolerance	\N
4639	(300a,03a0)[<0>](300a,0046)	DS	f	Ion Tolerance Table Sequence:Beam Limiting Device Angle Tolerance	\N
4627	(300a,03a2)[<0>](300a,00ed)	IS	f	Ion Beam Sequence:Number of Boli	\N
4638	(300a,03a0)[<0>](300a,004c)	DS	f	Ion Tolerance Table Sequence:Patient Support Angle Tolerance	\N
4674	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0146)	CS	f	Ion Beam Sequence:Ion Control Point Sequence:Table Top Roll Rotation Direction	\N
5783	(2005,"Philips MR Imaging DD 006",71)	IS	t	Unknown	d
5797	(2005,"Philips MR Imaging DD 006",64)	CS	t	Unknown	d
3957	(0019,"",b7)	UN	t	Unknown	d
5781	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 006",67)	IS	t	StackSequence:Unknown	d
5776	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0008,0023)	DA	t	Advanced Presentation Sequence:Presentation State Sequence:Content Date	o
5789	(2005,"Philips MR Imaging DD 006",75)	DS	t	Unknown	d
5786	(2005,"Philips MR Imaging DD 006",85)	DS	t	Unknown	d
5796	(2005,"Philips MR Imaging DD 006",79)	CS	t	Unknown	d
5792	(2005,"Philips MR Imaging DD 006",76)	LT	t	Unknown	d
5784	(2005,"Philips MR Imaging DD 006",72)	FL	t	Unknown	d
5793	(2005,"Philips MR Imaging DD 006",65)	CS	t	Unknown	d
5778	(0018,1138)	DS	f	Table Angle	\N
5782	(2005,"Philips MR Imaging DD 006",82)	IS	t	Unknown	d
5790	(2005,"Philips MR Imaging DD 006",86)	LT	t	Unknown	d
5779	(7005,"TOSHIBA_MEC_CT3",79)	UN	t	Unknown	d
5787	(2005,"Philips MR Imaging DD 006",87)	DS	t	Unknown	d
5780	(2005,"Philips MR Imaging DD 006",73)	IS	t	Unknown	d
5785	(0018,1320)	FL	f	B1rms	\N
4699	(300a,03a2)[<0>](300a,02ea)[<1>](300a,02e7)	FL	f	Ion Beam Sequence:Ion Range Compensator Sequence:Compensator Relative Stopping Power Ratio	\N
4613	(300a,03a2)[<0>](300a,0110)	IS	f	Ion Beam Sequence:Number of Control Points	\N
4714	(300a,03a2)[<0>](300a,03a8)[<1>](300a,039a)	IS	f	Ion Beam Sequence:Ion Control Point Sequence:Number of Paintings	\N
4715	(300a,0180)[<0>](300a,01d2)	DS	f	Patient Setup Sequence:Table Top Vertical Setup Displacement	\N
4734	(300a,0180)[<0>](300a,0410)[<1>](0018,9170)	CS	f	Patient Setup Sequence:Motion Synchronization Sequence:Respiratory Motion Compensation Technique	\N
4644	(300a,03a2)[<0>](300a,03a8)[<1>](300a,0114)	DS	f	Ion Beam Sequence:Ion Control Point Sequence:Nominal Beam Energy	\N
4652	(300a,03a2)[<0>](300a,03a6)[<1>](300a,0100)	DS	f	Ion Beam Sequence:Ion Block Sequence:Block Thickness	\N
4778	(300a,0040)[<0>](300a,004f)	FL	f	Tolerance Table Sequence:Table Top Pitch Angle Tolerance	\N
3818	(0029,"",20)	UN	t	Unknown	d
326	(0019,"GEMS_ACQU_01",6b)	SS	t	FieldOfViewInDetectorCells	k
4567	(300a,03a2)[<0>](300a,00b2)	SH	f	Ion Beam Sequence:Treatment Machine Name	\N
4570	(300a,03a2)[<0>](300a,03a6)[<1>](300a,00f5)	SH	f	Ion Beam Sequence:Ion Block Sequence:Block Tray ID	\N
4565	(300a,03a2)[<0>](300a,0314)[<1>](300a,0318)	SH	f	Ion Beam Sequence:Range Shifter Sequence:Range Shifter ID	\N
740	(0009,"GEMS_PETD_01",d8)	SL	t	frame_number	k
3031	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",93)	OB	t	Unknown:Unknown	d
5085	(2005,"Philips MR Imaging DD 001",5f)	OB	t	StackSequence	k
3298	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0028,0102)	US	t	Unknown:Unknown:High Bit	d
4342	(01f7,"ELSCINT1",91)	OW	t	Unknown	d
2109	(3006,0020)[<0>](3263,"Unnamed Private Block - 10",00)	UN	t	Structure Set ROI Sequence:Unknown	d
5210	(2005,"Philips MR Imaging DD 001",1c)	OB	t	Magnetization Transfer Contrast	k
5809	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",10)[<3>](0020,000e)	UI	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Segmentation Sequence:Series Instance UID	h
1653	(0029,"SIEMENS MEDCOM HEADER",40)		t	ApplicationHeaderSequence	d
1289	(0029,"SIEMENS MEDCOM HEADER",40)	SQ	t	ApplicationHeaderSequence	d
3738	(0021,"Siemens: Thorax/Multix FD Post Processing",10)	US	t	Unknown	d
3993	(0019,"",19)	UN	t	Unknown	d
267	(0043,"GEMS_PARM_01",42)	SL	t	DASTriggerSource	k
5800	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",69)	SQ	t	Presentation State Sequence:Display Shutter	k
5805	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence	k
5803	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",69)[<1>](0018,1600)	CS	t	Presentation State Sequence:Display Shutter:Shutter Shape	k
4103	(0019,"",0c)	UN	t	Unknown	d
4242	(0077,"NIL_CoReg_ATT",04)	SS	t	Unknown	d
1564	(07a1,"ELSCINT1",11)	CS	t	Unknown	d
239	(0027,"GEMS_IMAG_01",51)	FL	t	TableEndLocation	k
737	(0009,"GEMS_PETD_01",a6)	SL	t	slice_number	k
2958	(0009,"FDMS 1.0",04)	OB	t	ImageControlUnit	d
1363	(00e1,"ELSCINT1",61)	LO	t	Protocol File Name	d
2833	(00e1,"ELSCINT1",61)	OB	t	Protocol File Name	d
2115	(7005,"TOSHIBA_MEC_CT3",0d)	CS	t	Organ	d
3975	(0043,"",09)	UN	t	Unknown	d
5255	(2001,"Philips Imaging DD 001",8a)	OB	t	Sampling Percent	k
1135	(0009,"GEMS_PETD_01",c9)	LO	t	ovlp_trans_frm_id	d
1156	(0009,"GEMS_PETD_01",c9)	UI	t	ovlp_trans_frm_id	d
5176	(2005,"Philips MR Imaging DD 004",70)	OB	t	Number Mixes Spectro	k
3297	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0028,0103)	US	t	Unknown:Unknown:Pixel Representation	d
2854	(01f3,"ELSCINT1",15)	OB	t	Unknown	d
1428	(0009,"GEMS_IDEN_01",7b)	UN	t	Unknown	d
3700	(0021,"Siemens: Thorax/Multix FD Post Processing",06)	FL	t	Unknown	d
1271	(0009,"GEIIS",10)[<0>](0028,0010)	US	t	GE Private Image Thumbnail Sequence:Rows	na
3041	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",53)	OB	t	Unknown:Unknown	d
3853	(0025,"",19)	UN	t	Unknown	d
4064	(0029,"",19)	LO	t	Unknown	d
5802	(0018,1620)	IS	f	Vertices of the Polygonal Shutter	\N
3705	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",08)	FL	t	Unknown	d
148	(0029,"SIEMENS MEDCOM HEADER",20)	OB	t	MedComHistoryInformation	d
3673	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",b1)	UN	t	Presentation State Sequence:Unknown	d
3929	(0019,"",c7)	UN	t	Unknown	d
4335	(01f1,"ELSCINT1",54)	IS	t	Unknown	d
23	(0013,"CTP",13)	LO	t	Site ID	k
2161	(3115,"http://www.gemedicalsystems.com/it_solutions/rad_pacs/",01)	UT	t	Unknown	d
3108	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",a1)	OB	t	Unknown:Unknown	d
3952	(0021,"",5a)	UN	t	Unknown	d
4165	(0023,"Unnamed Private Block - 20",80)	UN	t	Unknown	d
2871	(00e1,"ELSCINT1",05)	IS	t	Unknown	d
782	(0009,"GEMS_PETD_01",80)	SL	t	Multi Patient	k
3116	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",71)	OB	t	Unknown:Unknown	d
1634	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",31)	UN	t	Unknown	d
5084	(2005,"Philips MR Imaging DD 004",41)	OB	t	Signal Domain Spatial	k
1319	(7053,"Philips PET Private Group",15)	SS	t	Unknown	d
526	(0019,"GEMS_ACQU_01",92)	SL	t	SliceOffsetOnFrequencyAxis	k
3713	(0021,"Siemens: Thorax/Multix FD Post Processing",11)	SS	t	Unknown	d
3125	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
5050	(2005,"Philips MR Imaging DD 001",0c)	OB	t	Min FP	k
3979	(0029,"",35)	UN	t	Unknown	d
5139	(2005,"Philips MR Imaging DD 001",0d)	OB	t	Scale Intercept	k
3129	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",52)	OB	t	Unknown:Unknown	d
605	(0009,"GEMS_PETD_01",91)	FL	t	BP Filter Center I	k
597	(0009,"GEMS_PETD_01",d6)	FL	t	image_one_loc	k
3166	(0019,"FDMS 1.0",81)	OB	t	ReadingSensitivityCenter	d
5253	(2001,"Philips Imaging DD 001",02)	OB	t	ChemicalShiftNumberMR	k
3998	(0019,"",ba)	UN	t	Unknown	d
2851	(01f3,"ELSCINT1",19)	OB	t	Unknown	d
295	(0029,"GEMS_IMPS_01",0a)	SS	t	LowerRangeOfPixels	k
2997	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
3288	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)	SQ	t	Unknown:Unknown	d
338	(0045,"GEMS_HELIOS_01",07)	FL	t	Z smoothing Factor	k
1522	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",54)	UN	t	Unknown	d
1525	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",33)	UN	t	Unknown	d
1453	(0009,"GEIIS",39)	UN	t	Unknown	d
1126	(0009,"GEMS_PETD_01",08)	SH	t	Exam Compatible Version	k
1296	(0029,"SIEMENS CSA HEADER",08)	CS	t	CSAImageHeaderType	d
137	(0029,"SIEMENS CSA HEADER",08)	OB	t	CSAImageHeaderType	d
1129	(0009,"GEMS_PETD_01",a4)	SH	t	compatible_version	k
1025	(7005,"TOSHIBA_MEC_CT3",16)	UI	t	Volume UID	h
3663	(2001,"Philips Imaging DD 001",c1)	LO	t	Linear Modality GL Transform	d
2953	(0019,"FDMS 1.0",32)	OB	t	KanjiMenuName	d
1414	(0031,"AGFA PACS Archive Mirroring 1.0",00)	CS	t	Unknown	d
477	(0019,"GEMS_ACQU_01",b6)	DS	t	UserData	d
5211	(2005,"Philips MR Imaging DD 001",17)	OB	t	Fourier Interpolation	k
484	(0019,"GEMS_ACQU_01",bd)	DS	t	UserData	d
5156	(2005,"Philips MR Imaging DD 004",55)	OB	t	Spectro SI CS Intervals	k
237	(0027,"GEMS_IMAG_01",46)	FL	t	NormalACoord	k
5259	(2001,"Philips Imaging DD 001",89)	OB	t	Phase FOV Percent	k
2117	(7005,"TOSHIBA_MEC_CT3",41)	UN	t	Row Slice Information	d
3911	(0043,"",06)	UN	t	Unknown	d
3693	(0040,030e)[<0>](01e3,"ELSCINT1",02)	UN	t	Exposure Dose Sequence:Unknown	d
2895	(00e1,"ELSCINT1",39)[<0>](0040,0275)[<1>](0040,0008)[<2>](0008,0100)	SH	t	Unknown:Request Attributes Sequence:Scheduled Protocol Code Sequence:Code Value	d
878	(0043,"GEMS_PARM_01",89)	LO	t	Governing Body, dB/dt, and SAR definition	k
3114	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",53)	OB	t	Unknown:Unknown	d
2926	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",60)	SQ	t	Unknown:Unknown	d
5230	(2005,"Philips MR Imaging DD 001",2e)	OB	t	PPG PPU Gating	k
5190	(2005,"Philips MR Imaging DD 004",56)	OB	t	Spectro SI Mode	k
825	(01f1,"ELSCINT1",02)	CS	t	Focal Spot Resolution	k
2804	(01f1,"ELSCINT1",02)	OB	t	Focal Spot Resolution	d
3793	(0051,"",0c)	UN	t	Unknown	d
480	(0019,"GEMS_ACQU_01",b9)	DS	t	UserData	d
1284	(0009,"GEMS_IDEN_01",0d)	UN	t	Unknown	d
3696	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",09)	FL	t	Unknown	d
3854	(0019,"",8b)	UN	t	Unknown	d
2993	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",83)	OB	t	Unknown:Unknown	d
813	(01f1,"ELSCINT1",27)	DS	t	Rotation Time	k
4213	(0077,"",02)	SS	t	Unknown	d
2163	(7fd1,"GEIIS",60)	UL	t	Subband Bytecounts	k
4010	(0043,"",10)	UN	t	Unknown	d
3030	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",81)	OB	t	Unknown:Unknown	d
2957	(0019,"FDMS 1.0",91)	OB	t	FilmAnnotationCharacterString2	d
2111	(7005,"TOSHIBA_MEC_CT3",43)	UN	t	Volume Vector	d
4182	(0043,"dcm4che/archive",12)	SS	t	Series Pk	d
1283	(0009,"GEMS_IDEN_01",3d)	UN	t	Unknown	d
3648	(0011,"GEMS_GDXE_FALCON_04",69)	UN	t	Unknown	d
1269	(0009,"GEIIS",10)[<0>](0028,0004)	CS	t	GE Private Image Thumbnail Sequence:Photometric Interpretation	na
3032	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
5209	(2005,"Philips MR Imaging DD 005",26)	OB	t	Viewing Hardcopy Only	k
3752	(0031,"AGFA EPR PROCEDURE CODE",01)	SH	t	Unknown	d
3834	(0043,"",82)	UN	t	Unknown	d
1490	(0029,"MITRA MARKUP 1.0",02)	OB	t	Markup3	d
356	(0045,"GEMS_HELIOS_01",17)	SS	t	Start View 1B	k
620	(0009,"GEMS_PETD_01",a1)	FL	t	Axial Start	k
3708	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",05)	FL	t	Unknown	d
775	(0009,"GEMS_PETD_01",6b)	SL	t	acq_delay	k
746	(0009,"GEMS_PETD_01",7d)	SL	t	Image Set Contents	k
3044	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",91)	OB	t	Unknown:Unknown	d
752	(0009,"GEMS_PETD_01",21)	SL	t	Count Rate Period	k
1403	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",0c)	OB	t	Unknown	d
4321	(0137,"NetRAAD",30)	DA	t	Unknown	d
4095	(0019,"",29)	UN	t	Unknown	d
3870	(0009,"",27)	UN	t	Unknown	d
3879	(0019,"",7e)	UN	t	Unknown	d
5240	(2001,"Philips Imaging DD 001",0e)	OB	t	Cardiac Cycled	k
4977	(2001,"Philips Imaging DD 129",00)		t	Presentation State Sequence	d
5299	(2001,"Philips Imaging DD 129",00)	OB	t	Presentation State Sequence	d
536	(0053,"GEHC_CT_ADVAPP_001",41)	SH	t	Iterative Recon Mode	k
4079	(0051,"SIEMENS MR HEADER",0a)	SH	t	Unknown	d
1543	(0051,"SIEMENS MR HEADER",0a)	LO	t	Unknown	d
141	(0051,"SIEMENS MR HEADER",0a)	OB	t	Unknown	d
614	(0009,"GEMS_PETD_01",e6)	FL	t	posterior shift	k
3186	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",84)	OB	t	Unknown:Unknown	d
3195	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
1364	(01f1,"ELSCINT1",49)	DS	t	Unknown	d
2799	(01f1,"ELSCINT1",49)	OB	t	Unknown	d
206	(0019,"GEMS_ACQU_01",72)	DS	t	ZChannelAvgOverViews	k
1481	(0009,"SIEMENS CT VA1 DUMMY",01)	UN	t	Unknown	d
2937	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",80)	SQ	t	Unknown:Unknown	d
225	(0027,"GEMS_IMAG_01",44)	FL	t	CenterSCoordOfPlaneImage	k
350	(0045,"GEMS_HELIOS_01",04)	SS	t	DAS gain	k
5099	(2001,"Philips Imaging DD 001",1b)	OB	t	PrepulseDelay	k
884	(0043,"GEMS_PARM_01",80)	LO	t	Coil ID Data	d
3296	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0028,0002)	US	t	Unknown:Unknown:Samples per Pixel	d
3208	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",43)	OB	t	Unknown:Unknown	d
1028	(7005,"TOSHIBA_MEC_CT3",18)	US	t	Frame Number	k
1599	(7fdf,"ELSCINT1",ff)	SH	t	Unknown	d
290	(0019,"GEMS_ACQU_01",25)	SS	t	MidScanFlag	k
3004	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
1273	(0009,"GEIIS",10)[<0>](0028,0107)	US	t	GE Private Image Thumbnail Sequence:Largest Image Pixel Value	na
2135	(0011,"GEMS_GENIE_1",44)	FD	t	ThresholdCenter	d
1630	(0019,"SIEMENS MR HEADER",0c)	IS	t	B Value	k
71	(0019,"SIEMENS MR HEADER",0c)	OB	t	B Value	k
866	(0009,"GEMS_PETD_01",ba)	SL	t	Post Filter	k
640	(0009,"GEMS_PETD_01",ba)	SS	t	Post Filter	k
2822	(01f7,"ELSCINT1",1e)	OB	t	Unknown	d
3825	(0019,"",12)	UN	t	Unknown	d
1383	(01f7,"ELSCINT1",1e)	OW	t	Unknown	d
4055	(0019,"",14)	IS	t	Unknown	d
3790	(0019,"",14)	UN	t	Unknown	d
671	(0009,"GEMS_PETD_01",97)	LO	t	Trans Scan ID	h
846	(0009,"GEMS_PETD_01",97)	UI	t	Trans Scan ID	h
739	(0009,"GEMS_PETD_01",2b)	SL	t	Scan FOV	k
3991	(0029,"",15)	UN	t	Unknown	d
2954	(0021,"FDMS 1.0",80)	OB	t	EquipmentTypeSpecificInformation	d
5256	(2005,"Philips MR Imaging DD 001",22)	OB	t	Number of References	k
315	(0027,"GEMS_IMAG_01",1d)	SS	t	VmaPhase	k
1670	(0047,"GEMS_3DSTATE_001",e9)	FL	t	Unknown	d
5170	(2001,"Philips Imaging DD 001",f1)	OB	t	Prospective Motion Correction	k
3761	(0079,"Unnamed Private Block - 10",09)	IS	t	Unknown	d
1682	(0073,"STENTOR",04)	UN	t	Unknown	d
784	(0009,"GEMS_PETD_01",23)	SL	t	Delayed Bias	k
5246	(2005,"Philips MR Imaging DD 001",a9)	OB	t	Geometry Correction	k
2910	(00e1,"ELSCINT1",39)[<0>](0008,0090)	PN	t	Unknown:Referring Physician's Name	d
306	(0043,"GEMS_PARM_01",4c)	SS	t	TGGCTriggerMode	k
3650	(0011,"GEMS_GDXE_FALCON_04",60)	UN	t	Unknown	d
2136	(0011,"GEMS_GENIE_1",57)	FD	t	FOV	d
4028	(0029,"",11)	CS	t	Unknown	d
809	(01f1,"ELSCINT1",0d)	DS	t	Rotation Angle	k
2839	(01f1,"ELSCINT1",0d)	OB	t	Rotation Angle	d
3883	(0027,"",41)	UN	t	Unknown	d
467	(0019,"GEMS_ACQU_01",ae)	DS	t	UserData	d
3057	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",40)	OB	t	Unknown:Unknown	d
1535	(0009,"GEMS_IDEN_01",e9)	SL	t	ActualSeriesDataTimeStamp	oi
5155	(2005,"Philips MR Imaging DD 001",33)	OB	t	StackRadialAxis	k
1037	(0053,"GEHC_CT_ADVAPP_001",79)	UN	t	MultiEnergyAcqMethod	k
3706	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",0f)	FL	t	Edge Enhancement Gain	d
5825	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",7c)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Unknown	d
3779	(0051,"GEMS_FUNCTOOL_01",06)	LO	t	Parameters	d
613	(0009,"GEMS_PETD_01",e7)	FL	t	superior shift	k
5822	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",57)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",50)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer PWL TransferFunction Sequence:Renderer Vertex Is Characteristic Flag	k
3083	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",95)	OB	t	Unknown:Unknown	d
5264	(2005,"Philips MR Imaging DD 001",a8)	OB	t	Inversion Time	k
5182	(2005,"Philips MR Imaging DD 001",3e)	OB	t	RR Intervals Distribution	k
5100	(2005,"Philips MR Imaging DD 005",40)	OB	t	Active Implantable Medical Device Head SAR Limit	k
4030	(0029,"",12)	CS	t	Unknown	d
5106	(2005,"Philips MR Imaging DD 001",21)	OB	t	Number of Mixes	k
5247	(2005,"Philips MR Imaging DD 001",04)	OB	t	Image Display Orientation	k
3949	(0025,"",1a)	UN	t	Unknown	d
3669	(200b,"Philips RAD Imaging DD 099",37)	UN	t	Unknown	d
285	(0043,"GEMS_PARM_01",2b)	SS	t	PrivateScanOptions	k
1255	(0009,"GEIIS",10)[<0>](0029,"GEIIS",10)	UL	t	GE Private Image Thumbnail Sequence:Shift Count	na
1388	(01f1,"ELSCINT1",44)	OW	t	Unknown	d
5287	(2005,"Philips MR Imaging DD 004",93)	OB	t	Station Number	k
882	(0043,"GEMS_PARM_01",82)	LO	t	System Configuration Information	d
742	(0009,"GEMS_PETD_01",50)	SL	t	Lower Coinc Limit	k
209	(0029,"GEMS_IMPS_01",06)	DS	t	LowerRangeOfPixels	k
1693	(0019,"SIEMENS MR HEADER",17)	DS	t	Slice Resolution	k
2828	(01f1,"ELSCINT1",44)	OB	t	Unknown	d
58	(0019,"SIEMENS MR HEADER",17)	OB	t	Slice Resolution	k
5236	(2001,"Philips Imaging DD 001",0c)	OB	t	Arrhythmia Rejection	k
2980	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
5102	(2001,"Philips Imaging DD 001",09)	OB	t	Image Prepulse Delay	k
374	(0053,"GEHC_CT_ADVAPP_001",65)	UN	t	Shutter Mode Percent	k
537	(0053,"GEHC_CT_ADVAPP_001",42)	LO	t	Iterative Recon Configuration	k
2119	(0053,"GEHC_CT_ADVAPP_001",6a)	IS	t	Unknown	d
1012	(0053,"GEHC_CT_ADVAPP_001",6a)	UN	t	Unknown	d
3200	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
324	(0021,"GEMS_RELA_01",90)	SS	t	TubeFocalSpotPosition	k
759	(0009,"GEMS_PETD_01",54)	SL	t	Upper Energy Limit	k
1030	(7005,"TOSHIBA_MEC_CT3",17)	US	t	Total Frame Count in the Volume	k
258	(0019,"GEMS_ACQU_01",61)	SL	t	NumberOfViews	k
848	(0009,"GEMS_PETD_01",99)	UI	t	Blnk Cal ID	d
1206	(0073,"STENTOR",02)	ST	t	Unknown	d
432	(0019,"GEMS_ACQU_01",d8)	SS	t	VariableEchoFlag	k
5817	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",57)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",58)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer PWL TransferFunction Sequence:Renderer PWL Vertex Index	k
4240	(0077,"NIL_CoReg_ATT",02)	UI	t	Unknown	d
3091	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",82)	OB	t	Unknown:Unknown	d
3946	(0043,"",01)	UN	t	Unknown	d
5820	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5c)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Renderer Directional Light Usage Flag	k
5815	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",57)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",59)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer PWL TransferFunction Sequence:Renderer PWL Vertex Color	k
5819	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",55)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Renderer DirectionalLight Direction	k
245	(0043,"GEMS_PARM_01",11)	US	t	TotalInputViews	k
4171	(0023,"GEMS_STDY_01",80)[<0>](0032,1064)[<1>](0008,0103)	SH	t	Has MPPS Related Tags:Requested Procedure Code Sequence:Coding Scheme Version	d
1264	(0009,"GEIIS",10)[<0>](0028,1052)	DS	t	GE Private Image Thumbnail Sequence:Rescale Intercept	na
2893	(00e1,"ELSCINT1",39)[<0>](0008,0050)	SH	t	Unknown:Accession Number	d
5158	(2005,"Philips MR Imaging DD 005",4c)	OB	t	First Echo Time	k
1262	(0009,"GEMS_GENIE_1",1e)	UI	t	Unknown	d
5814	(0018,1511)	DS	f	Positioner Secondary Angle	\N
3072	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",70)	OB	t	Unknown:Unknown	d
753	(0009,"GEMS_PETD_01",1a)	SL	t	Start Condition	k
1580	(0047,"GEMS_3DSTATE_001",ed)	CS	t	Unknown	d
3860	(0043,"",2d)	UN	t	Unknown	d
5079	(2005,"Philips MR Imaging DD 005",19)	OB	t	Operating Mode	k
3867	(0043,"",84)	UN	t	Unknown	d
3871	(0027,"",06)	UN	t	Unknown	d
5090	(2005,"Philips MR Imaging DD 001",14)	OB	t	Diffusion	k
4175	(0029,"",01)	UN	t	Unknown	d
5291	(2001,"Philips Imaging DD 129",00)[<0>](0070,0060)[<1>](0070,0062)	IS	t	Presentation State Sequence:Graphic Layer Sequence:Graphic Layer Order	na
2978	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",84)	OB	t	Unknown:Unknown	d
1661	(07a3,"ELSCINT1",34)	SH	t	Unknown	d
5165	(2005,"Philips MR Imaging DD 004",60)	OB	t	Spectro Vertical Shift	k
3640	(0011,"GEMS_GDXE_FALCON_04",7e)	UN	t	Unknown	d
2132	(0009,"GEMS_GENIE_1",40)	PN	t	Unknown	d
2938	(0023,"FDMS 1.0",30)	SQ	t	Unknown	d
1105	(0029,"SIEMENS MEDCOM HEADER",32)	UL	t	PMTFInformation2	d
394	(0027,"GEMS_IMAG_01",61)	FL	t	ImageDimensionY	k
4045	(0033,"",13)	PN	t	Unknown	d
3815	(0033,"",13)	UN	t	Unknown	d
670	(0009,"GEMS_PETD_01",6c)	LO	t	acq_start	o
855	(0009,"GEMS_PETD_01",6c)	DT	t	acq_start	o
1038	(0053,"GEHC_CT_ADVAPP_001",86)	UN	t	CommandedSecondkVp	k
265	(0043,"GEMS_PARM_01",4b)	SL	t	DASXmPattern	k
4971	(2005,"Philips MR Imaging DD 001",83)		t	Unknown	d
5064	(2005,"Philips MR Imaging DD 001",83)	OB	t	Unknown	d
4960	(2005,"Philips MR Imaging DD 003",57)	SS	t	Number of Running Attributes	k
3131	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",60)	OB	t	Unknown:Unknown	d
3642	(0011,"GEMS_GDXE_FALCON_04",7d)	UN	t	Unknown	d
1039	(0053,"GEHC_CT_ADVAPP_001",89)	UN	t	MultiEnergyKVUnitLabel	k
269	(0043,"GEMS_PARM_01",49)	SL	t	DASAutoZero	k
716	(0009,"GEMS_PETD_01",7f)	DS	t	Image Set Reference	k
458	(0043,"GEMS_PARM_01",61)	LO	t	Unknown	d
243	(0043,"GEMS_PARM_01",61)	UI	t	Unknown	d
2985	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",74)	OB	t	Unknown:Unknown	d
626	(0009,"GEMS_PETD_01",c6)	FL	t	seg_qc_parm	k
1616	(0051,"SIEMENS MR HEADER",11)	LO	t	Unknown	d
144	(0051,"SIEMENS MR HEADER",11)	OB	t	Unknown	d
1395	(0903,"GEIIS PACS",11)	US	t	Significant Flag	k
1620	(0009,"GEMS_IDEN_01",31)	SH	t	MobileLocationNumber	d
331	(0043,"GEMS_PARM_01",64)	CS	t	Image Filter	d
1040	(0053,"GEHC_CT_ADVAPP_001",8d)	UN	t	MonoWindowLow	k
341	(0045,"GEMS_HELIOS_01",0a)	FL	t	Minimum DAS value	k
1651	(07a3,"ELSCINT1",03)	CS	t	Unknown	d
3739	(0021,"Siemens: Thorax/Multix FD Post Processing",17)	US	t	System Type	d
832	(01f7,"ELSCINT1",97)	UN	t	Unknown	d
400	(0043,"GEMS_PARM_01",32)	SS	t	RawDataType	k
500	(0021,"GEMS_RELA_01",5f)	DS	t	FloatSlop	k
1687	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",42)	UN	t	Unknown	d
4155	(5653,"Vital Images SW 3.4",15)[<0>](0020,0037)	DS	t	Image Sequence:Image Orientation (Patient)	d
4026	(0023,"GEMS_STDY_01",80)[<0>](0032,1064)[<1>](0008,0104)	LO	t	Has MPPS Related Tags:Requested Procedure Code Sequence:Code Meaning	d
2951	(0009,"FDMS 1.0",80)	OB	t	KanjiHospitalName	d
1251	(0009,"GEMS_PETD_01",e0)	US	t	num_of_time_slices	k
1577	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",52)	UN	t	Unknown	d
4230	(2001,"Philips Imaging DD 129",00)[<0>](0028,3110)[<1>](2001,"Philips Imaging DD 001",c1)	LO	t	Presentation State Sequence:Softcopy VOI LUT Sequence:Linear Modality GL Transform	d
794	(0009,"GEMS_PETD_01",7c)	SL	t	Image Set Source	k
1480	(0009,"Unnamed Private Block - 10",0e)	UN	t	Unknown	d
3086	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",31)	OB	t	Unknown:Unknown	d
2884	(00e1,"ELSCINT1",39)[<0>](0008,1111)[<1>](0008,1155)	UI	t	Unknown:Referenced Performed Procedure Step Sequence:Referenced SOP Instance UID	d
459	(0019,"GEMS_ACQU_01",9c)	LO	t	PulseSequenceName	k
804	(0009,"GEMS_PETD_01",8b)	SL	t	ReconMethod	k
3104	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",73)	OB	t	Unknown:Unknown	d
275	(0043,"GEMS_PARM_01",47)	SL	t	DASCalFrequency	k
169	(0027,"GEMS_IMAG_01",54)	SH	t	RASLetterForScoutStartLoc	k
339	(0045,"GEMS_HELIOS_01",0e)	FL	t	Mean Z error	k
1117	(0009,"GEMS_PETD_01",0b)	SH	t	Scan Compatible Version	k
5835	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",28)	FL	t	Unknown	d
5843	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",55)	SS	t	Unknown	d
5842	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",20)	SS	t	Unknown	d
5844	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",4d)	SS	t	Unknown	d
5837	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",8d)	FL	t	Unknown	d
5839	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",53)	SS	t	Unknown	d
5829	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",54)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Renderer DirectionalLight Color	k
5833	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",8c)	FL	t	Unknown	k
5834	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",29)	FL	t	Unknown	d
5838	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",54)	SS	t	Unknown	d
5840	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",52)	SS	t	Unknown	d
5845	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",49)	SS	t	Unknown	d
5836	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",0d)	FL	t	Unknown	d
5832	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",51)	FL	t	Unknown	d
1649	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",58)	UN	t	Unknown	d
297	(0019,"GEMS_ACQU_01",40)	SS	t	StatReconFlag	k
223	(0027,"GEMS_IMAG_01",4a)	FL	t	SCoordOfTopRightCorner	k
3849	(0043,"",62)	UN	t	Unknown	d
344	(0045,"GEMS_HELIOS_01",32)	FL	t	TemporalResolution	k
2142	(0011,"GEMS_GENIE_1",3f)	SL	t	DatasetFlags	d
1354	(01f1,"ELSCINT1",42)	SH	t	Unknown	d
2838	(01f1,"ELSCINT1",42)	OB	t	Unknown	d
407	(0019,"GEMS_ACQU_01",9f)	SS	t	TransmittingCoil	k
3892	(0043,"",0a)	UN	t	Unknown	d
1380	(01f7,"ELSCINT1",1f)	OW	t	Unknown	d
2818	(01f7,"ELSCINT1",1f)	OB	t	Unknown	d
1557	(0051,"SIEMENS MR HEADER",16)	LO	t	Unknown	d
135	(0051,"SIEMENS MR HEADER",16)	OB	t	Unknown	d
1019	(7005,"TOSHIBA_MEC_CT3",1e)	UL	t	Raw Data Number	k
571	(0053,"GEHC_CT_ADVAPP_001",67)	IS	t	Overlapped Recon Flag	k
377	(0053,"GEHC_CT_ADVAPP_001",67)	UN	t	Overlapped Recon Flag	k
405	(0019,"GEMS_ACQU_01",85)	SS	t	MonitorSAR	k
2853	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",15)	OB	t	Unknown:Unknown	d
469	(0019,"GEMS_ACQU_01",a7)	DS	t	UserData	d
2810	(01f7,"ELSCINT1",18)	OB	t	Unknown	d
690	(0009,"GEMS_PETD_01",9c)	LO	t	Emiss Sub ID	k
847	(0009,"GEMS_PETD_01",9c)	UI	t	Emiss Sub ID	k
629	(0009,"GEMS_PETD_01",ce)	FL	t	vqc_y_axis_swivel	k
5849	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",0c)	SS	t	Unknown	d
5848	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",1f)	SS	t	Unknown	d
5846	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",0a)	SS	t	Unknown	d
3901	(0019,"",97)	UN	t	Unknown	d
3649	(0011,"GEMS_GDXE_FALCON_04",68)	UN	t	Unknown	d
289	(0019,"GEMS_ACQU_01",dd)	SS	t	OverrangeCorrectionUsed	k
828	(00e1,"ELSCINT1",36)	UN	t	Unknown	d
5873	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",1b)	US	t	Unknown	d
5864	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",26)	US	t	Unknown	d
5881	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",25)	US	t	Unknown	d
5882	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",66)	US	t	Unknown	d
5870	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",17)	US	t	Unknown	d
5878	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",1c)	US	t	Image Crop Lower Left	k
5858	(0021,"Siemens: Thorax/Multix FD Post Processing",15)	UN	t	Auto Window Shift	k
5871	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",89)	US	t	Unknown	d
5853	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",4f)	LO	t	Unknown	d
5883	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",8b)	US	t	Unknown	d
5875	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",23)	US	t	Unknown	d
5866	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",1b)	US	t	Image Crop Upper Right	k
5868	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",86)	US	t	Unknown	d
5880	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",16)	US	t	Unknown	d
5860	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",64)	US	t	Unknown	d
5884	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",a0)	US	t	Unknown	d
5859	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",14)	US	t	Unknown	d
5850	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",0f)	LO	t	Unknown	d
5862	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",19)	US	t	Unknown	d
5865	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",1d)	US	t	Image Crop Lower Right	k
5872	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",68)	US	t	Unknown	d
5854	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",5c)	OW	t	Unknown	d
5876	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",24)	US	t	Unknown	d
5851	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",0e)	LO	t	Unknown	d
298	(0021,"GEMS_RELA_01",91)	SS	t	BiopsyPosition	k
4132	(5653,"",18)	UN	t	Unknown	d
4204	(5653,"",18)	OB	t	Unknown	d
3865	(0009,"",30)	UN	t	Unknown	d
3869	(0019,"",9e)	UN	t	Unknown	d
3727	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",13)	SS	t	Unknown	d
5267	(2001,"Philips Imaging DD 001",87)	OB	t	Imaged Nucleus	k
1125	(0009,"GEMS_PETD_01",a5)	SH	t	software_version	k
277	(0021,"GEMS_RELA_01",03)	SS	t	SeriesFromWhichPrescribed	d
2965	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",94)	OB	t	Unknown:Unknown	d
3771	(0079,"Unnamed Private Block - 10",06)	DS	t	Unknown	d
619	(0009,"GEMS_PETD_01",c5)	FL	t	Scatter Parm	k
666	(0009,"GEMS_PETD_01",5d)	LO	t	scan_id	h
841	(0009,"GEMS_PETD_01",5d)	UI	t	scan_id	h
2112	(7005,"TOSHIBA_MEC_CT3",63)	UN	t	CTDIw	d
4121	(2001,"Philips Imaging DD 129",00)[<0>](0028,3002)	US	t	Presentation State Sequence:LUT Descriptor	d
2879	(00e1,"ELSCINT1",39)[<0>](0040,0275)	SQ	t	Unknown:Request Attributes Sequence	d
3138	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
2969	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",42)	OB	t	Unknown:Unknown	d
5856	(0018,115a)	CS	f	Radiation Mode	\N
5855	(0018,1155)	CS	f	Radiation Setting	\N
4965	(2001,"Philips Imaging DD 001",67)	CS	t	Linear Presentation GL Transform Shape Sub	d
4344	(07a3,"ELSCINT1",4d)	ST	t	Unknown	d
3767	(0079,"Unnamed Private Block - 10",0c)	DS	t	Unknown	d
5713	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",8b)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Surface Normal	k
5891	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",8f)	US	t	Unknown	d
5670	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",4c)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Image Minimum Height	k
5874	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",1a)	US	t	Image Crop Upper Left	k
5604	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)	SQ	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence	k
5775	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0070,0052)	SL	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Displayed Area Top Left Hand Corner	k
5885	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",1e)	US	t	Unknown	d
5892	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",1a)	US	t	Unknown	d
2829	(01f1,"ELSCINT1",0a)	OB	t	Edge Enhancement Weight	d
2781	(0053,"GEHC_CT_ADVAPP_001",63)	UN	t	Image Position Patient Setting	k
2998	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3667	(2001,"Philips Imaging DD 129",00)[<0>](200b,"Philips RAD Imaging DD 097",aa)[<1>](200b,"Philips RAD Imaging DD 097",ab)	UN	t	Presentation State Sequence:Unknown:Unknown	d
3661	(2001,"Philips Imaging DD 129",00)[<0>](0008,1115)[<1>](0008,1140)[<2>](2001,"Philips Imaging DD 001",c1)	LO	t	Presentation State Sequence:Referenced Series Sequence:Referenced Image Sequence:Linear Modality GL Transform	d
872	(0009,"GEMS_PETD_01",b6)	SL	t	IR Loop Filter	k
5562	(2001,"Philips Imaging DD 001",5f)[<0>](2005,"Philips MR Imaging DD 006",67)	UN	t	StackSequence:Unknown	d
5890	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",21)	US	t	Unknown	d
5583	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0008,114b)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Referenced Real World Value Mapping Instance Sequence	k
5807	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",57)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Renderer PWL TransferFunction Sequence	k
5889	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",85)	US	t	Unknown	d
4338	(01f1,"ELSCINT1",4e)	SH	t	Unknown	d
5761	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",20)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Index Navigation Current Index	k
5867	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",1c)	US	t	Unknown	d
5622	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,3110)[<2>](0008,1140)[<3>](0008,1150)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Sequence:Referenced Image Sequence:Referenced SOP Class UID	k
5827	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",57)[<4>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",58)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Renderer PWL TransferFunction Sequence:Renderer PWL Vertex Index	k
5664	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0009,"SIEMENS SYNGO INDEX SERVICE",50)	UN	t	Advanced Presentation Sequence:Presentation State Sequence:Hidden Instance	k
5887	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",88)	US	t	Unknown	d
5886	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",27)	US	t	Unknown	d
5888	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",18)	US	t	Unknown	d
1362	(01f1,"ELSCINT1",4e)	LO	t	Unknown	d
889	(0043,"GEMS_PARM_01",8a)	CS	t	Private In-Plane Phase Encoding Direction	k
4168	(0029,"SIEMENS CSA REPORT",08)	CS	t	Report Type	d
3951	(0021,"",83)	UN	t	Unknown	d
4232	(2001,"Philips Imaging DD 129",00)[<0>](2005,"Philips MR Imaging DD 004",89)[<1>](2005,"Philips MR Imaging DD 004",86)	UN	t	Presentation State Sequence:Viewing Protocol:Inset Scanogram	d
3257	(0029,"INTELERAD MEDICAL SYSTEMS",01)	UN	t	ImageCompressionFraction	d
3762	(0079,"Unnamed Private Block - 10",0b)	IS	t	Unknown	d
1635	(07a1,"ELSCINT1",43)	IS	t	Unknown	d
2913	(00e1,"ELSCINT1",39)[<0>](0008,1140)	SQ	t	Unknown:Referenced Image Sequence	d
318	(0021,"GEMS_RELA_01",37)	SS	t	ScreenFormat	d
5564	(2005,"Philips MR Imaging DD 006",74)	UN	t	Unknown	d
2922	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",20)	SQ	t	Unknown:Unknown	d
5801	(2001,"Philips Imaging DD 129",00)[<0>](2001,"Philips Imaging DD 001",69)[<1>](0018,1620)	IS	t	Presentation State Sequence:Display Shutter:Vertices of the Polygonal Shutter	k
5751	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",88)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Min Zoom In Factor	k
5767	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",56)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer DirectionalLight TwoSide Usage Flag	k
5621	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",cf)[<3>](0008,1115)[<4>](0008,1140)[<5>](0008,1155)	UI	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Image Sequence:Referenced Series Sequence:Referenced Image Sequence:Referenced SOP Instance UID	h
680	(0009,"GEMS_PETD_01",5c)	LO	t	frame_id	h
3828	(0019,"",d3)	UN	t	Unknown	d
5788	(2005,"Philips MR Imaging DD 006",74)	DS	t	Unknown	d
5729	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",11)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Line Shadow X Offset	k
5721	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",16)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Auto Navigation Mode	k
5643	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0070,0101)	DS	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Presentation Pixel Spacing	k
5755	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",80)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Rotation Axis	k
5740	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",54)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer DirectionalLight Color	k
5682	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",55)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer DirectionalLight Direction	k
5877	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",87)	US	t	Unknown	d
5746	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",96)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Data Points	k
5847	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",50)	SS	t	Unknown	d
5663	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",8d)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Evaluation DataRole ID	h
5816	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",64)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Segmentation Display Parameter Type	k
5632	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",93)[<4>](0008,0100)	SH	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Evaluation Sequence:Code Value	k
5653	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5e)[<2>](0072,0514)	FD	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Slice Spacing Sequence:Reformatting Interval	k
5857	(0021,"Siemens: Thorax/Multix FD Post Processing",16)	UN	t	Auto Window Expansion	k
5737	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",99)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Data Slice Thickness	k
5725	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",ab)	UN	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Viewing Index	k
3081	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
5722	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",42)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Orientation	k
5727	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",41)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Position	k
5700	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",8e)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Algorithm Type	k
5828	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",62)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Data UID	d
5772	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",13)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Shadow Style	k
5879	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",67)	US	t	Unknown	d
5709	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",84)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Rotation Center	k
5748	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",1c)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Unknown	d
5571	(2005,"Philips MR Imaging DD 006",65)	UN	t	Unknown	d
5558	(2005,"Philips MR Imaging DD 006",68)	UN	t	Unknown	d
5592	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence	k
5806	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",57)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer PWL TransferFunction Sequence	k
5550	(2005,"Philips MR Imaging DD 006",78)	UN	t	Unknown	d
5596	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5d)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Thickness Sequence	k
5818	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",57)[<4>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",59)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Renderer PWL TransferFunction Sequence:Renderer PWL Vertex Color	k
5708	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",84)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Rotation Center	k
5586	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)	SQ	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence	k
5679	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",9a)[<4>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",38)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Referenced Frames Sequence:Referenced Syngo UID	d
5559	(2005,"Philips MR Imaging DD 005",51)	UN	t	Original Series Number	k
5757	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",36)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Application Number Prefix Text	k
5863	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",8a)	US	t	Unknown	d
5841	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",0b)	SS	t	Unknown	d
5715	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",43)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Far Clip Plane	k
3943	(0019,"",95)	UN	t	Unknown	d
4214	(0019,"",98)	UN	t	Unknown	d
780	(0009,"GEMS_PETD_01",22)	SL	t	Delayed Events	k
5568	(2005,"Philips MR Imaging DD 006",60)	UN	t	Unknown	d
3246	(300a,00b0)[<0>](300d,"TOMO_HA_01",40)	UN	t	Beam Sequence:Unknown	d
5813	(0018,1510)	DS	f	Positioner Primary Angle	\N
5560	(2005,"Philips MR Imaging DD 006",79)	UN	t	Unknown	d
5648	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",5d)[<2>](0072,0510)	CS	t	Advanced Presentation Sequence:Presentation Module Sequence:Renderer Thickness Sequence:Reformatting Operation Type	k
5718	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",10)	UN	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Segmentation Sequence	k
5597	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0008,1115)	SQ	t	Advanced Presentation Sequence:Presentation State Sequence:Referenced Series Sequence	k
5585	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",cf)[<3>](0008,1115)[<4>](0008,1140)	SQ	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Image Sequence:Referenced Series Sequence:Referenced Image Sequence	k
5771	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",87)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Max Zoom In Factor	k
5760	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",76)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Unknown	d
5739	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",fb)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Clinical Finding ID	d
5696	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",09)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement UID	h
5808	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",10)	SQ	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Segmentation Sequence	k
5701	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",13)	UN	t	Advanced Presentation Sequence:Navigation Sequence:Navigation Name	k
5831	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",10)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",11)	UN	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Segmentation Sequence:Segmentation UID	D
5774	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0070,0053)	SL	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Displayed Area Bottom Right Hand Corner	k
5770	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",87)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Max Zoom In Factor	k
5574	(2005,"Philips MR Imaging DD 006",53)	UN	t	Unknown	d
5599	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",08)	SQ	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Measurement Sequence	k
5823	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",65)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Segmentation Display Visibility	k
5631	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",91)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",93)[<4>](0008,0102)	SH	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Evaluation DataRole Sequence:Measurement Evaluation Sequence:Coding Scheme Designator	k
5661	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",86)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Parallel Epiped	k
5747	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",14)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Shadow Color	k
3243	(300d,"TOMO_HA_01",a4)	UN	t	Unknown	d
5714	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",43)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Far Clip Plane	k
5741	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",1b)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Unknown	d
5719	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",30)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Application Name	d
5810	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",10)[<3>](0008,0018)	UI	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Segmentation Sequence:SOP Instance UID	h
5584	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",12)	SQ	t	Advanced Presentation Sequence:Navigation Sequence	k
5607	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,005a)[<2>](0008,1140)	SQ	t	Advanced Presentation Sequence:Presentation State Sequence:Displayed Area Selection Sequence:Referenced Image Sequence	k
5852	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",4e)	LO	t	Unknown	d
5634	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0028,3110)[<2>](0028,1055)	LO	t	Advanced Presentation Sequence:Presentation State Sequence:Softcopy VOI LUT Sequence:Window Center & Width Explanation	k
5812	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",10)[<3>](0008,0016)	UI	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Segmentation Sequence:SOP Class UID	k
5720	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",05)	UN	t	Advanced Presentation Sequence:Time Point Sequence:Overlay Image Sequence	k
1154	(0009,"GEMS_PETD_01",58)	UI	t	Blank Cal ID	d
5777	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0070,0082)	DA	t	Advanced Presentation Sequence:Presentation State Sequence:Presentation Creation Date	o
5821	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",67)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Segmentation Display is Selected Flag 	k
5625	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a9)[<1>](0008,1115)[<2>](0008,1140)[<3>](0008,1150)	UI	t	Advanced Presentation Sequence:Presentation State Sequence:Referenced Series Sequence:Referenced Image Sequence:Referenced SOP Class UID	k
5753	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",33)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Measurement Frame of Reference UID	h
5711	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",4d)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Parallel Shift Interval MM	k
5861	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",8e)	US	t	Unknown	d
5869	(0017,"SIEMENS_FLCOMPACT_VA01A_PROC",22)	US	t	Unknown	d
5593	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",cf)[<3>](0008,1115)	SQ	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Image Sequence:Referenced Series Sequence	k
5623	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",cf)[<3>](0008,1115)[<4>](0008,1140)[<5>](0008,1150)	UI	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Image Sequence:Referenced Series Sequence:Referenced Image Sequence:Referenced SOP Class UID	k
5762	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",31)[<2>](0071,"SIEMENS SYNGO OBJECT GRAPHICS",09)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Measurement Data Sequence:Line Type	k
5811	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",10)[<3>](0020,000d)	UI	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Segmentation Sequence:Study Instance UID	h
838	(0009,"GEMS_PETD_01",5c)	UI	t	frame_id	h
525	(0029,"GEMS_IMPS_01",16)	SL	t	LowerRangeOfPixels	k
3178	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
475	(0019,"GEMS_ACQU_01",a8)	DS	t	UserData	d
165	(0043,"GEMS_PARM_01",27)	SH	t	ScanPitchRatio	k
5659	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",41)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Position	k
5830	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",63)[<3>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",53)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence:Segmentation Display Parameter Sequence:Renderer Material	k
5694	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",3f)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",4b)	UN	t	Advanced Presentation Sequence:Presentation Module Sequence:Camera Home Settings Sequence:Camera Image Maximum Height	k
5804	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",a7)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",61)	SQ	t	Advanced Presentation Sequence:Presentation Module Sequence:Segmentation Display Data Sequence	k
5614	(0029,"SIEMENS SYNGO ADVANCED PRESENTATION",02)[<0>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",03)[<1>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",04)[<2>](0029,"SIEMENS SYNGO ADVANCED PRESENTATION",cf)[<3>](0008,1115)[<4>](0008,1140)[<5>](0008,1160)	IS	t	Advanced Presentation Sequence:Time Point Sequence:Base Image Sequence:Image Sequence:Referenced Series Sequence:Referenced Image Sequence:Referenced Frame Number	k
1550	(0013,"CTP",01)	UN	t	Unknown	d
592	(0009,"GEMS_PETD_01",cb)	FL	t	vqc_x_axis_trans	k
501	(0019,"GEMS_ACQU_01",ac)	DS	t	UserData	d
279	(0043,"GEMS_PARM_01",25)	SS	t	ReferenceChannels	k
145	(0019,"SIEMENS MR HEADER",09)	OB	t	Unknown	d
887	(0043,"GEMS_PARM_01",83)	DS	t	Asset R Factors	k
821	(01f1,"ELSCINT1",01)	CS	t	Acquisition Type	k
3976	(0019,"",bc)	UN	t	Unknown	d
168	(0027,"GEMS_IMAG_01",40)	SH	t	RASLetterOfImageLocation	k
4085	(700d,"TOSHIBA_MEC_MR3",09)	SS	t	Original Data Flag	d
3731	(0021,"Siemens: Thorax/Multix FD Post Processing",16)	DS	t	Auto Window Expansion	d
700	(0009,"GEMS_PETD_01",56)	LO	t	Normal Cal ID	h
844	(0009,"GEMS_PETD_01",56)	UI	t	Normal Cal ID	h
3124	(0009,"FDMS 1.0",0c)	OB	t	Film UID	d
4013	(0025,"",06)	UN	t	Unknown	d
248	(0019,"GEMS_ACQU_01",5e)	SL	t	NumberOfChannels1To512	k
153	(0019,"SIEMENS MR HEADER",0e)	OB	t	Diffusion Gradient Direction	k
2152	(0021,"SIEMENS MED ECAT FILE INFO",01)	OB	t	ECAT_Image_Subheader	d
762	(0009,"GEMS_PETD_01",2e)	SL	t	Mask Width	k
3033	(0009,"FDMS 1.0",08)	OB	t	ImageDisplayInformationVersionNo	d
2902	(00e1,"ELSCINT1",39)[<0>](0040,0254)	LO	t	Unknown:Performed Procedure Step Description	d
156	(0029,"GEMS_IMPS_01",09)	SH	t	LowerRangeOfPixels	k
1378	(01f7,"ELSCINT1",2d)	OW	t	Unknown	d
2817	(01f7,"ELSCINT1",2d)	OB	t	Unknown	d
811	(01f1,"ELSCINT1",07)	DS	t	Table Velocity	k
2835	(01f1,"ELSCINT1",07)	OB	t	Table Velocity	d
478	(0021,"GEMS_RELA_01",5e)	DS	t	FloatSlop	k
1329	(0013,"CTP",01)	SQ	t	Unknown	d
1561	(07a1,"ELSCINT1",13)	UL	t	Unknown	d
1569	(0019,"SIEMENS MR HEADER",09)	LO	t	Unknown	d
216	(0043,"GEMS_PARM_01",20)	DS	t	AvgOverrangesAllViews	k
1575	(0051,"SIEMENS MR HEADER",12)	SH	t	Unknown	d
139	(0051,"SIEMENS MR HEADER",12)	OB	t	Unknown	d
3084	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",13)	OB	t	Unknown:Unknown	d
3207	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",43)	OB	t	Unknown:Unknown	d
1291	(0029,"SIEMENS CSA HEADER",10)	OB	t	CSAImageHeaderInfo	d
1127	(0009,"GEMS_PETD_01",79)	SH	t	Image Set Compatible Version	k
803	(0009,"GEMS_PETD_01",2c)	SL	t	Axial FOV	k
208	(0019,"GEMS_ACQU_01",de)	DS	t	DynamicZAlphaValue	k
1226	(0029,"SIEMENS MEDCOM OOG",08)	CS	t	MEDCOMOOGType	d
5476	(0013,"GEMS_PETD_01",01)		t	Unknown	d
5475	(0013,"GEMS_PETD_01",01)	SQ	t	Unknown	d
748	(0009,"GEMS_PETD_01",c7)	SL	t	overlap	k
4004	(0019,"",df)	UN	t	Unknown	d
4243	(0077,"NIL_nICE_ATT",03)	SS	t	Unknown	d
1134	(0009,"GEMS_PETD_01",7b)	LO	t	Image Set Date Time	o
1159	(0009,"GEMS_PETD_01",7b)	DT	t	Image Set Date Time	o
3008	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3010	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3007	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
2794	(01f1,"ELSCINT1",05)	OB	t	Reconstruction Arc	d
3170	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
3236	(300a,0010)[<0>](300d,"TOMO_HA_01",12)	UN	t	Dose Reference Sequence:Unknown	d
4217	(0009,"EMAGEON JPEG2K INFO",00)	UN	t	Unknown	d
1086	(0053,"GEHC_CT_ADVAPP_001",9e)	UN	t	MultiEnergyNumNoiseRedPair	k
4225	(0011,"ULTRAVISUAL_TAG_SET1",18)	UN	t	Unknown	d
4093	(0019,"",0a)	UN	t	Unknown	d
1648	(0019,"SIEMENS MR HEADER",0b)	DS	t	Slice Measurement Duration	k
60	(0019,"SIEMENS MR HEADER",0b)	OB	t	Slice Measurement Duration	k
3133	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",93)	OB	t	Unknown:Unknown	d
2927	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",80)	SQ	t	Unknown:Unknown	d
755	(0009,"GEMS_PETD_01",28)	SL	t	Axial Compression	k
181	(0019,"GEMS_ACQU_01",24)	DS	t	MidScanTime	k
797	(0009,"GEMS_PETD_01",9f)	SL	t	Axial Filter 3D	k
453	(0019,"GEMS_ACQU_01",9d)	SH	t	PulseSequenceDate	o
530	(0019,"GEMS_ACQU_01",9d)	DT	t	PulseSequenceDate	o
3845	(0019,"",d8)	UN	t	Unknown	d
2821	(01f7,"ELSCINT1",31)	OB	t	Unknown	d
1397	(01f7,"ELSCINT1",31)	OW	t	Unknown	d
491	(0021,"GEMS_RELA_01",81)	DS	t	AutoWindowLevelAlpha	k
2887	(00e1,"ELSCINT1",39)[<0>](0020,000d)	UI	t	Unknown:Study Instance UID	d
2909	(00e1,"ELSCINT1",39)[<0>](0008,1032)[<1>](0008,0104)	LO	t	Unknown:Procedure Code Sequence:Code Meaning	d
1352	(01f1,"ELSCINT1",53)	SH	t	Unknown	d
611	(0009,"GEMS_PETD_01",29)	FL	t	Gantry Tilt Angle	k
681	(0009,"GEMS_PETD_01",3d)	LO	t	Post Injected Date Time	o
859	(0009,"GEMS_PETD_01",3d)	DT	t	Post Injected Date Time	o
357	(0045,"GEMS_HELIOS_01",16)	SS	t	Number Views 2B	k
1014	(7005,"TOSHIBA_MEC_CT3",0e)	SH	t	File Type Remarks	k
5235	(2005,"Philips MR Imaging DD 001",2f)	OB	t	Spatial Presaturation	k
1316	(7053,"Philips PET Private Group",18)	SS	t	Unknown	d
2883	(00e1,"ELSCINT1",39)[<0>](0008,1111)	SQ	t	Unknown:Referenced Performed Procedure Step Sequence	d
449	(0019,"GEMS_ACQU_01",96)	SS	t	DigitalReceiverGain	k
3290	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](7fe0,0010)	OB	t	Unknown:Unknown:Pixel Data	d
259	(0019,"GEMS_ACQU_01",02)	SL	t	NumberOfCellsInDetector	k
1391	(00e1,"ELSCINT1",3f)	CS	t	Unknown	d
3896	(0019,"",b1)	UN	t	Unknown	d
4172	(0023,"GEMS_STDY_01",80)	UN	t	Has MPPS Related Tags	d
4139	(0043,"GEMS_PARM_01",a4)	LO	t	Detailed text for ASL labeling technique	d
3783	(0043,"GEMS_PARM_01",a4)	UN	t	Detailed text for ASL labeling technique	d
2808	(01f7,"ELSCINT1",15)	OB	t	Unknown	d
433	(0019,"GEMS_ACQU_01",f2)	SS	t	FastPhases	k
781	(0009,"GEMS_PETD_01",70)	SL	t	actual_stop_cond	k
1124	(0009,"GEMS_PETD_01",09)	SH	t	Exam Software Version	k
534	(0053,"GEHC_CT_ADVAPP_001",43)	SH	t	Iterative Recon Level	k
372	(0053,"GEHC_CT_ADVAPP_001",20)	IS	t	Shuttle Flag	k
1594	(0029,"MITRA PRESENTATION 1.0",00)	CS	t	Rotation	d
1121	(0009,"GEMS_PETD_01",61)	SH	t	software_version	k
234	(0027,"GEMS_IMAG_01",42)	FL	t	CenterRCoordOfPlaneImage	k
3959	(0021,"",5d)	UN	t	Unknown	d
3960	(0019,"",94)	UN	t	Unknown	d
1385	(01f7,"ELSCINT1",1b)	OW	t	Unknown	d
2825	(01f7,"ELSCINT1",1b)	OB	t	Unknown	d
3978	(0043,"",35)	UN	t	Unknown	d
2899	(00e1,"ELSCINT1",39)[<0>](0040,0275)[<1>](0040,0009)	SH	t	Unknown:Request Attributes Sequence:Scheduled Procedure Step ID	d
5280	(2005,"Philips MR Imaging DD 001",a1)	OB	t	SyncraScanType	k
3983	(0043,"",80)	UN	t	Unknown	d
826	(00e1,"ELSCINT1",01)	US	t	Data Dictionary Version	k
2814	(00e1,"ELSCINT1",01)	OB	t	Data Dictionary Version	d
1141	(0009,"GEMS_PETD_01",aa)	SL	t	archived	k
3134	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",40)	OB	t	Unknown:Unknown	d
2900	(00e1,"ELSCINT1",39)[<0>](0040,0260)[<1>](0008,0100)	SH	t	Unknown:Performed Protocol Code Sequence:Code Value	d
381	(0019,"GEMS_ACQU_01",a3)	UL	t	CalibratedFieldStrength	k
1083	(0053,"GEHC_CT_ADVAPP_001",9c)	UN	t	GSIdataVersion	k
827	(01f1,"ELSCINT1",0a)	US	t	Edge Enhancement Weight	k
1668	(07a1,"ELSCINT1",36)	UN	t	Unknown	d
3295	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0028,0101)	US	t	Unknown:Unknown:Bits Stored	d
5261	(2005,"Philips MR Imaging DD 005",09)	OB	t	Rescale Intercept Original	k
1132	(0009,"GEMS_PETD_01",11)	LO	t	Scanner Description	k
1052	(0053,"GEHC_CT_ADVAPP_001",8a)	UN	t	MaterialType#1	k
2968	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",94)	OB	t	Unknown:Unknown	d
3836	(0021,"",84)	UN	t	Unknown	d
188	(0043,"GEMS_PARM_01",18)	DS	t	BBH Coefficients	k
608	(0009,"GEMS_PETD_01",d5)	FL	t	loop_filter_parm	k
304	(0019,"GEMS_ACQU_01",da)	SS	t	ReferenceChannelUsed	k
1053	(0053,"GEHC_CT_ADVAPP_001",73)	UN	t	MultiEnergyImageType	k
5311	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",58)	FL	t	Series Volume:Volume FOV FH	k
176	(0019,"GEMS_ACQU_01",1a)	LO	t	LastScanRAS	k
515	(0021,"GEMS_RELA_01",53)	DS	t	RotationFromSourceZRot	k
1317	(7053,"Philips PET Private Group",17)	SS	t	Unknown	d
494	(0019,"GEMS_ACQU_01",ad)	DS	t	UserData	d
2881	(00e1,"ELSCINT1",39)[<0>](0032,1064)	SQ	t	Unknown:Requested Procedure Code Sequence	d
787	(0009,"GEMS_PETD_01",5a)	SL	t	Derived	k
3051	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
3874	(0019,"",c3)	UN	t	Unknown	d
3880	(0027,"",35)	UN	t	Unknown	d
5490	(07a3,"ELSCINT1",fc)	DT	t	Unknown	d
1527	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",62)	UN	t	Unknown	d
3747	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",18)	US	t	Auto Gain	d
2908	(00e1,"ELSCINT1",39)[<0>](0008,1030)	LO	t	Unknown:Study Description	d
5275	(2005,"Philips MR Imaging DD 001",2b)	OB	t	Percent Scan Complete	k
2130	(0009,"GEMS_GENIE_1",20)	LO	t	Unknown	d
2959	(0029,"FDMS 1.0",34)	OB	t	MagnificationReductionRatio	d
1257	(0009,"GEIIS",10)[<0>](0029,"GEIIS",12)	UL	t	GE Private Image Thumbnail Sequence:Offset	na
1618	(07a1,"ELSCINT1",56)	US	t	Unknown	d
5226	(2005,"Philips MR Imaging DD 005",32)	OB	t	Safety Override Mode	k
630	(0009,"GEMS_PETD_01",38)	FL	t	Tracer Activity	k
1621	(0021,"GEMS_RELA_01",07)	UL	t	SeriesRecordChecksum	d
4190	(0043,"dcm4che/archive",26)	US	t	Unknown	d
1455	(0009,"GEIIS",3b)	UN	t	Unknown	d
309	(0043,"GEMS_PARM_01",16)	SS	t	NumberOfOverranges	k
5195	(2005,"Philips MR Imaging DD 004",64)	OB	t	Volume Selection	k
1348	(01f1,"ELSCINT1",46)	FL	t	Unknown	d
2832	(01f1,"ELSCINT1",46)	OB	t	Unknown	d
1031	(7005,"TOSHIBA_MEC_CT3",1a)	US	t	Frame Sort Order	k
5052	(2005,"Philips MR Imaging DD 001",10)	OB	t	Window Width	k
5147	(2005,"Philips MR Imaging DD 005",47)	OB	t	Power Optimization	k
3990	(0019,"",96)	UN	t	Unknown	d
3745	(0021,"Siemens: Thorax/Multix FD Post Processing",00)	US	t	Unknown	d
5216	(2005,"Philips MR Imaging DD 004",25)	OB	t	Spectro SI B0 Correction	k
3717	(0021,"Siemens: Thorax/Multix FD Post Processing",0d)	SS	t	Unknown	d
311	(0019,"GEMS_ACQU_01",42)	SS	t	SegmentNumber	k
3668	(200b,"Philips RAD Imaging DD 099",36)	UN	t	Unknown	d
3162	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",62)	OB	t	Unknown:Unknown	d
1107	(0029,"SIEMENS MEDCOM HEADER",31)	LO	t	PMTFInformation1	d
5057	(2001,"Philips Imaging DD 001",83)	OB	t	Imaging Frequency	k
5279	(2001,"Philips Imaging DD 001",20)	OB	t	Scanning Technique	k
213	(0019,"GEMS_ACQU_01",73)	DS	t	AvgOfLeftRefChannelsOverViews	k
1493	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",67)	UN	t	Unknown	d
230	(0027,"GEMS_IMAG_01",48)	FL	t	RCoordOfTopRightCorner	k
1087	(0053,"GEHC_CT_ADVAPP_001",03)	UN	t	MultiEnergyMDTransformEnergies	k
312	(0025,"GEMS_SERS_01",06)	SS	t	LastPulseSequenceUsed	k
5061	(2005,"Philips MR Imaging DD 001",09)	OB	t	Image Offcenter FH	k
1365	(01f7,"ELSCINT1",13)	OW	t	Unknown	d
2792	(01f7,"ELSCINT1",13)	OB	t	Unknown	d
3858	(0021,"",56)	UN	t	Unknown	d
218	(0019,"GEMS_ACQU_01",2a)	DS	t	XrayOnPosition	k
5493	(07a1,"ELSCINT1",9a)	LT	t	Unknown	d
1516	(0027,"GEMS_IMAG_01",06)	SL	t	ImageArchiveFlag	d
1401	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",13)	OB	t	Unknown	d
1118	(0009,"GEMS_PETD_01",60)	SH	t	compatible_version	k
3109	(0009,"FDMS 1.0",06)	OB	t	RouteImage UID	d
3956	(0019,"",9d)	UN	t	Unknown	d
600	(0009,"GEMS_PETD_01",d0)	FL	t	vqc_z_axis_roll	k
1205	(0073,"STENTOR",01)	ST	t	Unknown	d
3964	(0019,"",9b)	UN	t	Unknown	d
1248	(0009,"GEMS_PETD_01",5f)	LO	t	patient_id	d
667	(0009,"GEMS_PETD_01",0a)	LO	t	Scan ID	h
842	(0009,"GEMS_PETD_01",0a)	UI	t	Scan ID	h
2820	(01f7,"ELSCINT1",1a)	OB	t	Unknown	d
1382	(01f7,"ELSCINT1",1a)	OW	t	Unknown	d
224	(0027,"GEMS_IMAG_01",41)	FL	t	ImageLocation	k
444	(0043,"GEMS_PARM_01",03)	SS	t	GradientOffsetInY	k
736	(0009,"GEMS_PETD_01",df)	US	t	num_of_slices	k
450	(0019,"GEMS_ACQU_01",8b)	SS	t	ActualReceiveGainDigital	k
1475	(0009,"Unnamed Private Block - 10",39)	UN	t	Unknown	d
3984	(0019,"",92)	UN	t	Unknown	d
1350	(01f7,"ELSCINT1",22)	UI	t	Unknown	d
2787	(01f7,"ELSCINT1",22)	OB	t	Unknown	d
462	(0043,"GEMS_PARM_01",0f)	DS	t	SARAvgHead	k
2914	(00e1,"ELSCINT1",39)[<0>](00e1,"ELSCINT1",3a)	IS	t	Unknown:Unknown	d
568	(0053,"GEHC_CT_ADVAPP_001",9d)	LO	t	Unknown	d
373	(0053,"GEHC_CT_ADVAPP_001",9d)	UN	t	Unknown	d
3137	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",90)	OB	t	Unknown:Unknown	d
1328	(7053,"Philips PET Private Group",05)	LO	t	Worklist Info File Name	d
2974	(0021,"FDMS 1.0",40)	OB	t	ImageNoInTheSet	d
1502	(0011,"GEMS_PATI_01",10)	SS	t	PatientStatus	k
2860	(01f3,"ELSCINT1",14)	OB	t	Unknown	d
1503	(0029,"MITRA MARKUP 1.0",04)	OB	t	Markup5	d
3043	(0009,"FDMS 1.0",05)	OB	t	ImageUID	d
649	(0009,"GEMS_PETD_01",b3)	SS	t	IR Num Subsets	k
186	(0019,"GEMS_ACQU_01",27)	DS	t	GantryPeriod	k
2885	(00e1,"ELSCINT1",39)[<0>](0008,1110)[<1>](0008,1150)	UI	t	Unknown:Referenced Study Sequence:Referenced SOP Class UID	d
423	(0043,"GEMS_PARM_01",01)	SS	t	BitmapOfPrescanOptions	k
5159	(2005,"Philips MR Imaging DD 001",b0)	OB	t	Diffusion Direction RL	k
1402	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",19)	OB	t	Unknown	d
3707	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",03)	FL	t	Unknown	d
1450	(0009,"GEIIS",0e)	UN	t	Unknown	d
3671	(2001,"Philips Imaging DD 129",00)[<0>](0070,0001)[<1>](2001,"Philips Imaging DD 001",cb)	UN	t	Presentation State Sequence:Graphic Annotation Sequence:Unknown	d
1602	(0025,"GEMS_SERS_01",1a)	SH	t	PrimaryReceiverSuiteAndHost	d
616	(0009,"GEMS_PETD_01",b8)	FL	t	IR Loop Filt Param	k
863	(0009,"GEMS_PETD_01",b8)	SL	t	IR Loop Filt Param	k
1609	(0029,"MITRA MARKUP 1.0",01)	OB	t	Markup2	d
4042	(0033,"",0c)	LO	t	Unknown	d
5282	(2005,"Philips MR Imaging DD 005",2d)	OB	t	Exam Media Write Status	k
65	(0019,"SIEMENS MR HEADER",11)	OB	t	Flow Compensation	k
4003	(0019,"",cb)	UN	t	Unknown	d
4006	(0021,"",36)	UN	t	Unknown	d
4018	(0021,"",58)	UN	t	Unknown	d
4019	(0019,"",d2)	UN	t	Unknown	d
1091	(0053,"GEHC_CT_ADVAPP_001",8f)	UN	t	MD1AttenuationCurve	k
5313	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",5b)	FL	t	Series Volume:Volume Offcentre FH	k
3832	(0019,"",aa)	UN	t	Unknown	d
5103	(2005,"Philips MR Imaging DD 001",63)	OB	t	fMRI Status Indication	k
379	(0043,"GEMS_PARM_01",37)	UL	t	UserFillMapLSW	k
157	(0027,"GEMS_IMAG_01",30)	SH	t	ForeignImageRevision	k
621	(0009,"GEMS_PETD_01",92)	FL	t	BP Filter Center P	k
2897	(00e1,"ELSCINT1",39)[<0>](0040,0253)	SH	t	Unknown:Performed Procedure Step ID	d
3188	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
1268	(0009,"GEIIS",10)[<0>](7fe0,0010)	OW	t	GE Private Image Thumbnail Sequence:Pixel Data	na
3634	(0011,"GEMS_GDXE_FALCON_04",11)	LT	t	ROI	d
1277	(0009,"GEIIS",10)[<0>](0028,0100)	US	t	GE Private Image Thumbnail Sequence:Bits Allocated	na
2870	(01f7,"ELSCINT1",73)	OB	t	Unknown	d
1345	(0009,"GEMS_PETD_01",83)	SL	t	Window Level Type	d
5324	(0015,"GEMS_PETD_01",26)	UN	t	BP3d Filter FlagV	k
4305	(0009,"CTP",04)	UN	t	Unknown	d
1614	(0051,"SIEMENS MR HEADER",0d)	SH	t	Unknown	d
132	(0051,"SIEMENS MR HEADER",0d)	OB	t	Unknown	d
1082	(0053,"GEHC_CT_ADVAPP_001",92)	UN	t	MD1intercept	k
435	(0021,"GEMS_RELA_01",50)	SS	t	GraphicallyPrescribed	k
3969	(0043,"",60)	UN	t	Unknown	d
187	(0019,"GEMS_ACQU_01",0f)	DS	t	HorizontalFrameOfReference	k
567	(0053,"GEHC_CT_ADVAPP_001",61)	SH	t	High Resolution Flag	k
376	(0053,"GEHC_CT_ADVAPP_001",61)	UN	t	High Resolution Flag	k
413	(0019,"GEMS_ACQU_01",c4)	SS	t	SATLocationA	k
414	(0019,"GEMS_ACQU_01",c6)	SS	t	SATLocationH	k
3980	(0021,"",53)	UN	t	Unknown	d
1288	(0009,"GEMS_IDEN_01",27)	SL	t	ImageActualDate	oi
1247	(0009,"GEMS_PETD_01",02)	LO	t	Patient ID	d
5151	(2005,"Philips MR Imaging DD 004",37)	OB	t	Sample Offset	k
240	(0027,"GEMS_IMAG_01",49)	FL	t	ACoordOfTopRightCorner	k
4078	(0051,"SIEMENS MR HEADER",0b)	SH	t	Acquisition Matrix Text	d
1655	(0051,"SIEMENS MR HEADER",0b)	LO	t	Acquisition Matrix Text	k
68	(0051,"SIEMENS MR HEADER",0b)	OB	t	Acquisition Matrix Text	k
1142	(0009,"GEMS_PETD_01",85)	SL	t	Flip	k
1026	(7005,"TOSHIBA_MEC_CT3",30)	UN	t	Main Modality in Study	k
3261	(0031,"MITRA LINKED ATTRIBUTES 1.0",20)	IS	t	Unknown	d
1666	(0031,"MITRA LINKED ATTRIBUTES 1.0",20)	LO	t	Unknown	d
1671	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",40)	UN	t	Unknown	d
1674	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",5e)	UN	t	Unknown	d
3151	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",31)	OB	t	Unknown:Unknown	d
738	(0009,"GEMS_PETD_01",52)	SL	t	Coinc Delay Offset	k
4016	(0009,"",04)	UN	t	Unknown	d
4188	(0043,"dcm4che/archive",31)	DS	t	Unknown	d
3757	(0079,"Unnamed Private Block - 10",01)	LO	t	Unknown	d
330	(0045,"GEMS_HELIOS_01",06)	CS	t	Table Direction	k
5177	(2001,"Philips Imaging DD 001",03)	OB	t	DiffusionB-Factor	k
4978	(2005,"Philips MR Imaging DD 001",80)		t	Series PlanScan	k
1036	(0053,"GEHC_CT_ADVAPP_001",7a)	UN	t	MultiEnergyFeatAnnotName	k
3042	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",95)	OB	t	Unknown:Unknown	d
885	(0043,"GEMS_PARM_01",81)	LO	t	GE Coil Name	k
1217	(0029,"SIEMENS MEDCOM OOG",09)	LO	t	MEDCOMOOGVersion	d
2807	(01f7,"ELSCINT1",19)	OB	t	Unknown	d
1369	(01f7,"ELSCINT1",19)	OW	t	Unknown	d
3859	(0043,"",07)	UN	t	Unknown	d
1136	(0009,"GEMS_PETD_01",ca)	LO	t	ovlp_tpulse_frm_id	d
1158	(0009,"GEMS_PETD_01",ca)	UI	t	ovlp_tpulse_frm_id	d
3862	(0019,"",a3)	UN	t	Unknown	d
3876	(0021,"",50)	UN	t	Unknown	d
1523	(0025,"GEMS_SERS_01",17)	SL	t	SeriesCompleteFlag	k
411	(0019,"GEMS_ACQU_01",c5)	SS	t	SATLocationP	k
368	(0043,"GEMS_PARM_01",65)	US	t	Motion Correction Indicator	k
418	(0019,"GEMS_ACQU_01",c9)	SS	t	SATThicknessAP	k
3064	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",51)	OB	t	Unknown:Unknown	d
3070	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",50)	OB	t	Unknown:Unknown	d
1094	(7005,"TOSHIBA_MEC_CT3",07)	DS	t	Reconstruction Center	k
685	(0009,"GEMS_PETD_01",96)	LO	t	Well CounterCal ID	d
839	(0009,"GEMS_PETD_01",96)	UI	t	Well CounterCal ID	d
3912	(0019,"",a7)	UN	t	Unknown	d
3914	(0021,"",52)	UN	t	Unknown	d
4966	(0028,3110)[<0>](2001,"Philips Imaging DD 001",77)	CS	t	Softcopy VOI LUT Sequence:GL Transform Type	d
1020	(7005,"TOSHIBA_MEC_CT3",19)	UL	t	Frame Sort Key	k
3085	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",a2)	OB	t	Unknown:Unknown	d
1256	(7fd1,"GEIIS",10)	UL	t	Compression Type	k
417	(0019,"GEMS_ACQU_01",a4)	SS	t	SATFatWaterBone	k
3930	(0019,"",b5)	UN	t	Unknown	d
3934	(0019,"",b0)	UN	t	Unknown	d
3940	(0043,"",96)	UN	t	Unknown	d
292	(0019,"GEMS_ACQU_01",52)	SS	t	ReconPostProcessingFlag	k
3105	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",32)	OB	t	Unknown:Unknown	d
5112	(2005,"Philips MR Imaging DD 003",00)	OB	t	Number of SOP Common	k
3724	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",0c)	SS	t	Harmonization Kernel	d
1099	(7005,"TOSHIBA_MEC_CT3",21)	UN	t	Decrease in Artifact Filter	k
3193	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
3666	(200b,"Philips RAD Imaging DD 097",aa)[<0>](200b,"Philips RAD Imaging DD 097",ab)	UN	t	Unknown:Unknown	d
4074	(0043,"GEMS_PARM_01",8f)	DS	t	Spectro Parameters	d
3966	(0019,"",ce)	UN	t	Unknown	d
1631	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",60)	UN	t	Unknown	d
1639	(0019,"SIEMENS MR HEADER",16)	DS	t	Time After Start	k
57	(0019,"SIEMENS MR HEADER",16)	OB	t	Time After Start	k
507	(0043,"GEMS_PARM_01",6f)	DS	t	Unknown	d
4111	(0077,"",03)	UN	t	Unknown	d
4212	(0077,"",03)	SS	t	Unknown	d
3152	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",a3)	OB	t	Unknown:Unknown	d
4148	(5653,"Vital Images SW 3.4",15)	SQ	t	Image Sequence	d
1485	(0051,"SIEMENS MR HEADER",08)	CS	t	CSA Image Header Type	k
59	(0051,"SIEMENS MR HEADER",08)	OB	t	CSA Image Header Type	k
3847	(0019,"",a0)	UN	t	Unknown	d
154	(0009,"GEMS_IDEN_01",04)	SH	t	ProductId	k
1449	(0009,"GEIIS",6c)	UN	t	Unknown	d
485	(0043,"GEMS_PARM_01",0e)	DS	t	PSDEstimatedLimitInTeslaPerSecond	k
367	(0043,"GEMS_PARM_01",67)	US	t	IBO Correction Indicator	k
861	(0009,"GEMS_PETD_01",0d)	DT	t	Scan Date Time	o
5320	(0015,"GEMS_PETD_01",28)	UN	t	BP3d Filter CutoffV	k
300	(0019,"GEMS_ACQU_01",14)	SS	t	End NumberForBaseline	k
5121	(2005,"Philips MR Imaging DD 004",33)	OB	t	Phase Encoding Echo Top Positions	k
5126	(2005,"Philips MR Imaging DD 001",30)	OB	t	Repetition Time	k
5127	(2005,"Philips MR Imaging DD 005",01)	OB	t	Number of Study Reference	k
5078	(2005,"Philips MR Imaging DD 004",29)	OB	t	Spectro Echo Top Position	k
3683	(0040,030e)[<0>](01f1,"ELSCINT1",4e)	LO	t	Exposure Dose Sequence:Unknown	d
4130	(0019,"",0e)	UN	t	Unknown	d
1529	(07a1,"ELSCINT1",2a)	CS	t	Unknown	d
1531	(0011,"GEMS_GENIE_1",0a)	SL	t	SeriesType	d
3889	(0019,"",c5)	UN	t	Unknown	d
741	(0009,"GEMS_PETD_01",51)	SL	t	Upper Coinc Limit	k
3002	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3292	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0018,0050)	DS	t	Unknown:Unknown:Slice Thickness	d
3658	(200b,"Philips RAD Imaging DD 097",aa)[<0>](0008,0018)	UI	t	Unknown:SOP Instance UID	d
1088	(0053,"GEHC_CT_ADVAPP_001",9f)	UN	t	MultiEnergyNoiseRedPairString	k
5194	(2005,"Philips MR Imaging DD 004",99)	OB	t	IViewBold Enabled	k
1281	(0009,"GEMS_IDEN_01",0e)	UN	t	Unknown	d
3759	(0079,"Unnamed Private Block - 10",02)	IS	t	Unknown	d
1560	(7fdf,"ELSCINT1",f0)	OB	t	Unknown	d
699	(0009,"GEMS_PETD_01",98)	LO	t	Norm Cal ID	h
843	(0009,"GEMS_PETD_01",98)	UI	t	Norm Cal ID	h
2916	(00e1,"ELSCINT1",39)[<0>](00e1,"ELSCINT1",3e)	IS	t	Unknown:Unknown	d
3908	(0025,"",17)	UN	t	Unknown	d
2929	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",80)	SQ	t	Unknown:Unknown	d
3079	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",95)	OB	t	Unknown:Unknown	d
1477	(0009,"Unnamed Private Block - 10",6c)	UN	t	Unknown	d
2941	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",30)	SQ	t	Unknown:Unknown	d
4238	(0077,"NIL_CoReg_ATT",01)	FL	t	Unknown	d
5201	(2005,"Philips MR Imaging DD 005",3a)	OB	t	Data Dictionary Contents Version	k
3654	(200b,"Philips RAD Imaging DD 001",40)	SH	t	Unknown	d
2116	(7005,"TOSHIBA_MEC_CT3",14)	US	t	Reconstruction ROI Number	d
346	(0045,"GEMS_HELIOS_01",01)	SS	t	Number of Macro Rows in Detector	k
3953	(0043,"",04)	UN	t	Unknown	d
4127	(0019,"",0d)	CS	t	Unknown	d
4102	(0019,"",0d)	UN	t	Unknown	d
3955	(0043,"",61)	UN	t	Unknown	d
3961	(0019,"",cd)	UN	t	Unknown	d
632	(0009,"GEMS_PETD_01",d7)	FL	t	image_index_loc	k
4041	(0051,"",19)	LO	t	Unknown	d
2819	(01f7,"ELSCINT1",1c)	OB	t	Unknown	d
1381	(01f7,"ELSCINT1",1c)	OW	t	Unknown	d
3968	(0027,"",61)	UN	t	Unknown	d
4092	(700d,"TOSHIBA_MEC_MR3",06)	US	t	Image Matrix	d
595	(0009,"GEMS_PETD_01",67)	FL	t	table_z_position	k
2873	(00e1,"ELSCINT1",06)	IS	t	Unknown	d
4157	(5653,"Vital Images SW 3.4",16)	SL	t	Volume Interpolated Slices	d
4140	(0043,"GEMS_PARM_01",a3)	CS	t	ASL Contrast technique	d
3782	(0043,"GEMS_PARM_01",a3)	UN	t	ASL Contrast technique	d
5154	(2005,"Philips MR Imaging DD 004",59)	OB	t	Spectro Turbo Echo Spacing	k
3753	(0043,"dcm4che/archive",14)	AE	t	Calling AE Title	d
1143	(0009,"GEMS_PETD_01",65)	SL	t	patient_entry	d
865	(0009,"GEMS_PETD_01",be)	SL	t	AC BP Filter	k
641	(0009,"GEMS_PETD_01",be)	SS	t	AC BP Filter	k
4195	(0043,"dcm4che/archive",42)	SL	t	Unknown	d
4007	(0025,"",07)	UN	t	Unknown	d
5251	(2005,"Philips MR Imaging DD 005",44)	OB	t	TFE Factor	k
1047	(0053,"GEHC_CT_ADVAPP_001",8c)	UN	t	GSIScanModePreset	k
2912	(00e1,"ELSCINT1",37)	DS	t	Total Dose Savings	d
1100	(7005,"TOSHIBA_MEC_CT3",40)	UN	t	DLP	k
353	(0045,"GEMS_HELIOS_01",18)	SS	t	Number of Views 1B	k
1313	(7053,"Philips PET Private Group",c2)	UI	t	Unknown	d
1494	(0053,"GEHC_CT_ADVAPP_001",66)	UN	t	Image Browser Annotation	k
393	(0019,"GEMS_ACQU_01",5a)	FL	t	AcquisitionDuration	k
3237	(300a,0010)[<0>](300d,"TOMO_HA_01",18)	UN	t	Dose Reference Sequence:Unknown	d
3716	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",00)	SS	t	Raw Image Amplification	d
4345	(07a5,"ELSCINT1",00)	LO	t	Unknown	d
1254	(0009,"GEIIS",10)[<0>](0029,"GEIIS",14)	UL	t	GE Private Image Thumbnail Sequence:Actual Frame Number	na
4134	(5653,"",19)	UN	t	Unknown	d
4207	(5653,"",19)	OB	t	Unknown	d
3019	(0019,"FDMS 1.0",90)	OB	t	FilmAnnotationCharacterString1	d
1305	(7053,"Philips PET Private Group",02)	OB	t	Private Data	d
2852	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",19)	OB	t	Unknown:Unknown	d
1084	(0053,"GEHC_CT_ADVAPP_001",99)	UN	t	MD2slope	k
4047	(0033,"",1c)	PN	t	Unknown	d
3788	(0033,"",1c)	UN	t	Unknown	d
3095	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",34)	OB	t	Unknown:Unknown	d
409	(0019,"GEMS_ACQU_01",7e)	SS	t	NumberOfEchos	k
5082	(2005,"Philips MR Imaging DD 004",97)	OB	t	Anatomic Region Code Value	k
3942	(0023,"",70)	UN	t	Unknown	d
4973	(2001,"Philips Imaging DD 001",5f)		t	StackSequence	k
3016	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
591	(0009,"GEMS_PETD_01",6a)	FL	t	start_location	k
3115	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
820	(01f1,"ELSCINT1",03)	CS	t	Concurrent Slices Generation	k
2791	(01f1,"ELSCINT1",03)	OB	t	Concurrent Slices Generation	d
1093	(7005,"TOSHIBA_MEC_CT3",1d)	UL	t	Reconstruction Number	k
596	(0009,"GEMS_PETD_01",40)	FL	t	Positron Fraction	k
3267	(0051,"GEMS_CT_VES_01",01)	SQ	t	CTVESequence	d
3118	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",31)	OB	t	Unknown:Unknown	d
2157	(0013,"CTP",15)	LO	t	Batch	k
3127	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",30)	OB	t	Unknown:Unknown	d
3128	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",72)	OB	t	Unknown:Unknown	d
3132	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
3161	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
4197	(0043,"dcm4che/archive",46)	SL	t	Unknown	d
3689	(0040,030e)[<0>](01e3,"ELSCINT1",0a)	UN	t	Exposure Dose Sequence:Unknown	d
5205	(2005,"Philips MR Imaging DD 005",16)	OB	t	Plan Mode	k
1015	(7005,"TOSHIBA_MEC_CT3",0f)	SH	t	Direction (head or feet first)	k
227	(0043,"GEMS_PARM_01",40)	FL	t	TriggerOnPosition	k
3809	(0019,"",13)	UN	t	Unknown	d
4071	(0019,"",13)	SL	t	Unknown	d
177	(0021,"GEMS_RELA_01",4a)	LO	t	AnatomicalReferenceForScout	k
1686	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",10)	UN	t	Unknown	d
1128	(0009,"GEMS_PETD_01",03)	SH	t	Patient Compatible Version	k
1085	(0053,"GEHC_CT_ADVAPP_001",93)	UN	t	MD1slope	k
4178	(0043,"dcm4che/archive",40)	FL	t	Unknown	d
4346	(01f7,"ELSCINT1",92)	OW	t	Unknown	d
3833	(0019,"",a8)	UN	t	Unknown	d
5104	(2005,"Philips MR Imaging DD 001",b2)	OB	t	Diffusion Direction FH	k
471	(0019,"GEMS_ACQU_01",7d)	DS	t	SecondEcho	k
3846	(0019,"",84)	UN	t	Unknown	d
3040	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",51)	OB	t	Unknown:Unknown	d
3194	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
3638	(0011,"GEMS_GDXE_FALCON_04",6d)	UN	t	Unknown	d
3012	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
4200	(5653,"",14)	SQ	t	Unknown	d
4135	(5653,"",14)	UN	t	Unknown	d
3017	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
2962	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",15)	OB	t	Unknown:Unknown	d
410	(0019,"GEMS_ACQU_01",c7)	SS	t	SATLocationF	k
4961	(0028,3110)[<0>](2001,"Philips Imaging DD 001",c1)	LO	t	Softcopy VOI LUT Sequence:Linear Modality GL Transform	d
4043	(0051,"",16)	LO	t	Unknown	d
3791	(0051,"",16)	UN	t	Unknown	d
3066	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",92)	OB	t	Unknown:Unknown	d
2934	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",50)	SQ	t	Unknown:Unknown	d
1259	(0043,"GEMS_PARM_01",28)	OB	t	UniqueImageIdentifier	d
3902	(0019,"",b2)	UN	t	Unknown	d
3690	(0040,030e)[<0>](01e3,"ELSCINT1",0c)	UN	t	Exposure Dose Sequence:Unknown	d
4221	(0011,"ULTRAVISUAL_TAG_SET1",1d)	UN	t	Unknown	d
3076	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",a0)	OB	t	Unknown:Unknown	d
498	(0019,"GEMS_ACQU_01",e0)	DS	t	UserData	d
4975	(2005,"Philips MR Imaging DD 005",0f)		t	Private Per-Frame Sequence	d
5175	(2005,"Philips MR Imaging DD 005",0f)	OB	t	Private Per-Frame Sequence	d
3698	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",04)	FL	t	Unknown	d
5227	(2005,"Philips MR Imaging DD 005",4d)	OB	t	Is B0 Series	k
618	(0009,"GEMS_PETD_01",9e)	FL	t	Radial Cutoff 3D	k
460	(0019,"GEMS_ACQU_01",9e)	LO	t	InternalPulseSequenceName	k
833	(01f7,"ELSCINT1",7f)	UN	t	Unknown	d
2114	(01f7,"ELSCINT1",7f)	OW	t	Unknown	d
5184	(2005,"Philips MR Imaging DD 003",51)	OB	t	Number of Study Admitting Diagnostic Description	k
3925	(0043,"",39)	UN	t	Unknown	d
251	(0019,"GEMS_ACQU_01",62)	SL	t	IncrementBetweenViews	k
473	(0019,"GEMS_ACQU_01",bb)	DS	t	UserData	d
519	(0029,"GEMS_IMPS_01",15)	SL	t	LowerRangeOfPixels	k
5217	(2001,"Philips Imaging DD 001",24)	OB	t	Series is Interactive	k
5308	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",55)	FL	t	Series Volume:Volume Angulation FH	k
3962	(0019,"",c0)	UN	t	Unknown	d
693	(0009,"GEMS_PETD_01",ae)	LO	t	tpluse_frame_id	k
850	(0009,"GEMS_PETD_01",ae)	UI	t	tpluse_frame_id	k
1027	(7005,"TOSHIBA_MEC_CT3",24)	UN	t	AcquisitionDateOfNRA	o
3967	(0043,"",0d)	UN	t	Unknown	d
3971	(0043,"",6f)	UN	t	Unknown	d
5233	(2005,"Philips MR Imaging DD 001",19)	OB	t	Inverse Reconstructed	k
2848	(01f3,"ELSCINT1",01)[<0>](01f3,"ELSCINT1",02)	OB	t	Unknown:Unknown	d
476	(0019,"GEMS_ACQU_01",ba)	DS	t	UserData	d
3173	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
2862	(01f3,"ELSCINT1",11)[<0>](01f3,"ELSCINT1",23)	OB	t	Unknown:Unknown	d
1320	(7053,"Philips PET Private Group",14)	SS	t	Unknown	d
1472	(0009,"GEMS_IDEN_01",67)	UN	t	Unknown	d
4326	(0043,"GEMS_PARM_01",9b)	DS	t	NPW factor	d
355	(0045,"GEMS_HELIOS_01",0c)	SS	t	Number of Views shifted	k
1349	(01f1,"ELSCINT1",0e)	FL	t	Unknown	d
4090	(700d,"TOSHIBA_MEC_MR3",05)	DS	t	FOV	d
1692	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",0e)	LT	t	Unknown	d
3284	(0033,"MITRA OBJECT UTF8 ATTRIBUTES 1.0",0e)	OB	t	Unknown	d
1691	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",51)	UN	t	Unknown	d
4017	(0019,"",a4)	UN	t	Unknown	d
1491	(0043,"GEMS_PARM_01",2a)	OB	t	UserDefinedData	d
3203	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
1495	(0073,"STENTOR",06)	LO	t	Unknown	d
1467	(0073,"STENTOR",06)	UN	t	Unknown	d
3172	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
280	(0019,"GEMS_ACQU_01",17)	SS	t	SeriesPlane	k
3670	(200b,"Philips RAD Imaging DD 099",35)	UN	t	Unknown	d
5268	(2005,"Philips MR Imaging DD 001",1f)	OB	t	MPRProtocol	k
1130	(0009,"GEMS_PETD_01",07)	LO	t	Exam ID	h
1155	(0009,"GEMS_PETD_01",07)	UI	t	Exam ID	h
492	(0019,"GEMS_ACQU_01",b8)	DS	t	UserData	d
3171	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
1144	(0009,"GEMS_PETD_01",75)	SL	t	archived	k
5120	(2005,"Philips MR Imaging DD 004",61)	OB	t	Spectro Vertical Window	k
183	(0019,"GEMS_ACQU_01",03)	DS	t	CellNumberAtTheta	k
1042	(0053,"GEHC_CT_ADVAPP_001",7e)	UN	t	MultiEnergyHighLowRatio	k
4314	(0137,"NetRAAD",0e)	UI	t	Unknown	d
3059	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
5193	(2005,"Philips MR Imaging DD 001",13)	OB	t	Development Mode	k
5208	(2001,"Philips Imaging DD 001",61)	OB	t	SeriesTransmitted	k
5146	(2005,"Philips MR Imaging DD 001",1d)	OB	t	Measurement Scan Resolution	k
3688	(0040,030e)[<0>](01e3,"ELSCINT1",01)	UN	t	Exposure Dose Sequence:Unknown	d
3063	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",80)	OB	t	Unknown:Unknown	d
426	(0019,"GEMS_ACQU_01",cc)	SS	t	VelocityEncoding	k
3071	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",91)	OB	t	Unknown:Unknown	d
5162	(2005,"Philips MR Imaging DD 003",49)	OB	t	Number of Series Operators Name	d
4035	(0051,"",13)	SH	t	Unknown	d
3801	(0051,"",13)	UN	t	Unknown	d
672	(0009,"GEMS_PETD_01",57)	LO	t	Normal 2D Cal ID	h
845	(0009,"GEMS_PETD_01",57)	UI	t	Normal 2D Cal ID	h
3899	(0019,"",f9)	UN	t	Unknown	d
4066	(0019,"",0b)	DS	t	Unknown	d
3804	(0019,"",0b)	UN	t	Unknown	d
4067	(0019,"",17)	DS	t	Unknown	d
3806	(0019,"",17)	UN	t	Unknown	d
514	(0021,"GEMS_RELA_01",52)	DS	t	RotationFromSourceYRot	k
3075	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",80)	OB	t	Unknown:Unknown	d
196	(0019,"GEMS_ACQU_01",2f)	DS	t	TriggerFrequency	k
612	(0009,"GEMS_PETD_01",c2)	FL	t	AC Img Smooth Parm	k
3936	(0043,"",83)	UN	t	Unknown	d
3103	(0009,"FDMS 1.0",09)	OB	t	PatientInformationVersionNo	d
745	(0009,"GEMS_PETD_01",db)	SL	t	ir_z_filter_flag	k
4222	(0011,"ULTRAVISUAL_TAG_SET1",08)	UN	t	Unknown	d
310	(0019,"GEMS_ACQU_01",43)	SS	t	TotalSegmentsRequested	k
3112	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",20)	OB	t	Unknown:Unknown	d
5189	(2005,"Philips MR Imaging DD 004",96)	OB	t	Flow Images Present	k
881	(0043,"GEMS_PARM_01",84)	LO	t	Additional Asset Data	k
2904	(00e1,"ELSCINT1",39)[<0>](0032,1060)	LO	t	Unknown:Requested Procedure Description	d
3974	(0019,"",c2)	UN	t	Unknown	d
3198	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
3746	(0021,"Siemens: Thorax/Multix FD Post Processing",04)	US	t	Unknown	d
483	(0043,"GEMS_PARM_01",0d)	DS	t	PSDEstimatedLimit	k
570	(0053,"GEHC_CT_ADVAPP_001",64)	IS	t	Shutter Mode	k
375	(0053,"GEHC_CT_ADVAPP_001",64)	UN	t	Shutter Mode	k
365	(0045,"GEMS_HELIOS_01",0d)	SS	t	Z tracking Flag	k
3259	(0029,"INTELERAD MEDICAL SYSTEMS",22)	US	t	HistogramPercentileValues	d
378	(0027,"GEMS_IMAG_01",33)	UL	t	ImagingOptions	k
1070	(0027,"GEMS_IMAG_01",33)	SL	t	ImagingOptions	k
3146	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",60)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
3150	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",a0)	OB	t	Unknown:Unknown	d
1145	(0009,"GEMS_PETD_01",88)	SL	t	PanY	k
867	(0009,"GEMS_PETD_01",b5)	SL	t	IR Corr Model	k
643	(0009,"GEMS_PETD_01",b5)	SS	t	IR Corr Model	k
633	(0009,"GEMS_PETD_01",66)	FL	t	table_height	k
3695	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",0a)	FL	t	Unknown	d
3190	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
1482	(3109,"Applicare/RadWorks/Version 5.0",08)	LO	t	Receive Origin	d
4131	(5653,"",17)	UN	t	Unknown	d
2924	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",20)	SQ	t	Unknown:Unknown	d
436	(0019,"GEMS_ACQU_01",12)	SS	t	LastPseq	k
1510	(3109,"Applicare/RadWorks/Version 5.0",02)	SH	t	NEW/SEEN Status	d
257	(0027,"GEMS_IMAG_01",1c)	SL	t	VmaMamp	k
2823	(01f7,"ELSCINT1",28)	OB	t	Unknown	d
1519	(01f7,"ELSCINT1",28)	OW	t	Unknown	d
316	(0019,"GEMS_ACQU_01",13)	SS	t	StartNumberForBaseline	k
3286	(01f7,"ELSCINT1",94)	UN	t	Unknown	d
189	(0043,"GEMS_PARM_01",17)	DS	t	IBHImageScaleFactors	k
2141	(0009,"GEMS_GENIE_1",12)	SL	t	StudyType	d
1541	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",21)	UN	t	Unknown	d
5327	(0015,"GEMS_PETD_01",27)	UN	t	BP3d Filter OrderV	k
247	(0019,"GEMS_ACQU_01",60)	SL	t	StartingView	k
3694	(0040,030e)[<0>](01e1,"ELSCINT1",52)	UN	t	Exposure Dose Sequence:Unknown	d
283	(0043,"GEMS_PARM_01",13)	SS	t	ReconKernelParameters	k
1022	(7005,"TOSHIBA_MEC_CT3",08)	DS	t	Detector Slice Thickness in mm	k
3900	(0043,"",33)	UN	t	Unknown	d
320	(0019,"GEMS_ACQU_01",4a)	SS	t	TotalNumberOfRefChannels	k
2806	(01f7,"ELSCINT1",17)	OB	t	Unknown	d
1367	(01f7,"ELSCINT1",17)	OW	t	Unknown	d
3754	(0043,"dcm4che/archive",15)	AE	t	Called AE Title	d
3023	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
343	(0045,"GEMS_HELIOS_01",02)	FL	t	Macro width at ISO Center	k
4114	(0907,"GEIIS",10)	UI	t	Original Study Instance UID	d
4302	(0009,"CTP",06)	UN	t	Unknown	d
5180	(2001,"Philips Imaging DD 001",16)	OB	t	NumberOfPCDirections	k
2988	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",82)	OB	t	Unknown:Unknown	d
3168	(0029,"FDMS 1.0",44)	OB	t	LineDensityCode	d
607	(0009,"GEMS_PETD_01",b7)	FL	t	IR Pre Filt Param	k
3932	(0019,"",ab)	UN	t	Unknown	d
4337	(00e1,"ELSCINT1",46)	OB	t	Unknown	d
5243	(2005,"Philips MR Imaging DD 005",00)	OB	t	Volume View Enabled	k
3647	(0011,"GEMS_GDXE_FALCON_04",67)	UN	t	Unknown	d
689	(0009,"GEMS_PETD_01",68)	LO	t	landmark_datetime	o
852	(0009,"GEMS_PETD_01",68)	DT	t	landmark_datetime	o
5489	(07a1,"ELSCINT1",8d)	ST	t	Unknown	d
1274	(0009,"GEIIS",10)[<0>](0028,0103)	US	t	GE Private Image Thumbnail Sequence:Pixel Representation	na
5290	(2001,"Philips Imaging DD 129",00)[<0>](0070,0060)	SQ	t	Presentation State Sequence:Graphic Layer Sequence	d
456	(0009,"GEMS_IDEN_01",e3)	LO	t	EquipmentUID	h
345	(0009,"GEMS_IDEN_01",e3)	UI	t	EquipmentUID	h
5125	(2005,"Philips MR Imaging DD 001",a0)	OB	t	Dynamic Scan Begin Time	k
1138	(0009,"GEMS_PETD_01",01)	LO	t	Implementation Version Name	k
3751	(0031,"AGFA PACS Archive Mirroring 1.0",01)	SH	t	Unknown	d
1400	(0031,"AGFA PACS Archive Mirroring 1.0",01)	UL	t	Unknown	d
270	(0029,"GEMS_IMPS_01",34)	SL	t	AdvantageCompOverflow	k
185	(0019,"GEMS_ACQU_01",44)	DS	t	InterscanDelay	k
5149	(2001,"Philips Imaging DD 001",22)	OB	t	WaterFatShift	k
4110	(0019,"SIEMENS MR HEADER",25)	FD	t	Unknown	d
4125	(0019,"SIEMENS MR HEADER",25)	UN	t	Unknown	d
479	(0019,"GEMS_ACQU_01",ab)	DS	t	UserData	d
5166	(2001,"Philips Imaging DD 001",60)	OB	t	NumberOfStacks	K
3994	(0021,"",51)	UN	t	Unknown	d
774	(0009,"GEMS_PETD_01",a3)	SL	t	Axial Angles Used	k
4001	(0043,"",91)	UN	t	Unknown	d
3147	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
260	(0019,"GEMS_ACQU_01",4b)	SL	t	DataSizeForScanData	k
624	(0009,"GEMS_PETD_01",bd)	FL	t	IR Regularize Param	k
1456	(0009,"GEIIS",3d)	UN	t	Unknown	d
167	(0027,"GEMS_IMAG_01",55)	SH	t	RASLetterForScoutEndLoc	k
747	(0009,"GEMS_PETD_01",24)	SL	t	Word Size	k
4133	(5653,"",22)	UN	t	Unknown	d
4205	(5653,"",22)	OB	t	Unknown	d
3839	(0019,"",ca)	UN	t	Unknown	d
3003	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3266	(3f01,"INTELERAD MEDICAL SYSTEMS",10)	UN	t	Unknown	d
4324	(0023,"GEMS_STDY_01",80)[<0>](0008,1120)[<1>](0008,1150)	UI	t	Has MPPS Related Tags:Referenced Patient Sequence:Referenced SOP Class UID	k
4046	(0033,"",19)	PN	t	Unknown	d
3799	(0033,"",19)	UN	t	Unknown	d
229	(0027,"GEMS_IMAG_01",4c)	FL	t	ACoordOfBottomRightCorner	k
730	(0009,"GEMS_PETD_01",71)	FD	t	total_prompts	d
3852	(0043,"",32)	UN	t	Unknown	d
1501	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",61)	UN	t	Unknown	d
3027	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
1113	(0009,"GEMS_PETD_01",0f)	ST	t	Scan Description	k
674	(0009,"GEMS_PETD_01",5e)	LO	t	exam_id	h
837	(0009,"GEMS_PETD_01",5e)	UI	t	exam_id	h
2120	(0053,"GEHC_CT_ADVAPP_001",68)	IS	t	Row Number Anotation Flag	d
1010	(0053,"GEHC_CT_ADVAPP_001",68)	UN	t	Row Number Anotation Flag	k
3052	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",a3)	OB	t	Unknown:Unknown	d
362	(0045,"GEMS_HELIOS_01",14)	SS	t	Number of Views 1A	k
1479	(0009,"Unnamed Private Block - 10",05)	UN	t	Unknown	d
294	(0043,"GEMS_PARM_01",4a)	SS	t	StartingChannelOfView	k
3643	(0011,"GEMS_GDXE_FALCON_04",82)	UN	t	Unknown	d
1534	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",36)	UN	t	Unknown	d
420	(0019,"GEMS_ACQU_01",d2)	SS	t	ProjectionAlgorithm	k
1376	(01f7,"ELSCINT1",27)	OW	t	Unknown	d
2815	(01f7,"ELSCINT1",27)	OB	t	Unknown	d
1555	(07a3,"ELSCINT1",55)	SH	t	Unknown	d
1356	(01f1,"ELSCINT1",4d)	SH	t	Unknown	d
2793	(01f1,"ELSCINT1",4d)	OB	t	Unknown	d
3909	(0023,"",7d)	UN	t	Unknown	d
3169	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
1576	(0011,"GEMS_PETD_01",01)		t	Unknown	d
1330	(0011,"GEMS_PETD_01",01)	SQ	t	Unknown	d
3087	(0025,"FDMS 1.0",10)	OB	t	RelativeLightEmissionAmountSk	d
1146	(0009,"GEMS_PETD_01",87)	SL	t	PanX	k
760	(0009,"GEMS_PETD_01",53)	SL	t	Coinc Output Mode	k
364	(0045,"GEMS_HELIOS_01",12)	SS	t	Start View 1A	k
403	(0019,"GEMS_ACQU_01",81)	SS	t	Contiguous	k
1598	(0021,"GEMS_RELA_01",19)	UL	t	AcqReconRecordChecksum	d
4226	(0011,"ULTRAVISUAL_TAG_SET1",10)	UN	t	Unknown	d
4065	(0029,"",09)	LO	t	Unknown	d
3794	(0029,"",09)	UN	t	Unknown	d
3941	(0043,"",88)	UN	t	Unknown	d
2942	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",50)	SQ	t	Unknown:Unknown	d
3107	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",a2)	OB	t	Unknown:Unknown	d
677	(0009,"GEMS_PETD_01",36)	LO	t	Tracer Name	k
4027	(0029,"",13)	CS	t	Unknown	d
370	(0053,"GEHC_CT_ADVAPP_001",60)	SH	t	Recon Flip RotateA nno	k
305	(0019,"GEMS_ACQU_01",16)	SS	t	EndNumberForEnhancedScans	k
1294	(0029,"SIEMENS CSA HEADER",09)	LO	t	CSAImageHeaderVersion	d
142	(0029,"SIEMENS CSA HEADER",09)	OB	t	CSAImageHeaderVersion	d
442	(0019,"GEMS_ACQU_01",cd)	SS	t	ThicknessDisclaimer	k
4211	(0077,"",01)	FL	t	Unknown	d
4113	(0077,"",01)	UN	t	Unknown	d
1636	(0051,"SIEMENS MR HEADER",19)	LO	t	Unknown	d
136	(0051,"SIEMENS MR HEADER",19)	OB	t	Unknown	d
5055	(2005,"Philips MR Imaging DD 004",40)	OB	t	Signal Domain for Chemical Shift	k
198	(0043,"GEMS_PARM_01",31)	DS	t	RACoordOfTargetReconCentre	k
3126	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",41)	OB	t	Unknown:Unknown	d
1393	(0903,"GEIIS PACS",10)	US	t	Reject Image Flag	k
5153	(0903,"GEIIS PACS",10)	OB	t	Reject Image Flag	d
1650	(3109,"Applicare/RadWorks/Version 5.0",0b)	TM	t	Receive Time	d
880	(0043,"GEMS_PARM_01",95)	LO	t	Prescan Reuse String	k
5296	(2001,"Philips Imaging DD 129",01)		t	PresentationStateSequence	d
1049	(0053,"GEHC_CT_ADVAPP_001",87)	UN	t	CommandedSecondmA	k
235	(0021,"GEMS_RELA_01",93)	FL	t	BiopsyRefLocation	k
3175	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
4181	(0043,"dcm4che/archive",2b)	SS	t	Unknown	d
1684	(0051,"SIEMENS MR HEADER",15)	SH	t	Unknown	d
133	(0051,"SIEMENS MR HEADER",15)	OB	t	Unknown	d
256	(0027,"GEMS_IMAG_01",1f)	SL	t	VmaClip	k
4128	(0019,"",28)	FD	t	Unknown	d
4094	(0019,"",28)	UN	t	Unknown	d
5081	(2005,"Philips MR Imaging DD 005",0a)	OB	t	Rescale Slope Original	k
4118	(2001,"Philips Imaging DD 129",00)[<0>](0028,3003)	LO	t	Presentation State Sequence:LUT Explanation	d
5101	(2005,"Philips MR Imaging DD 001",01)	OB	t	Image Angulation FH	k
1466	(0009,"SECTRA_Ident_01",02)	SH	t	Examination number	k
2783	(0009,"SECTRA_Ident_01",02)	LO	t	Examination number	d
2840	(0009,"SECTRA_Ident_01",02)	OB	t	Examination number	d
1131	(0009,"GEMS_PETD_01",c8)	LO	t	ovlp_frm_id	d
1157	(0009,"GEMS_PETD_01",c8)	UI	t	ovlp_frm_id	d
3036	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",21)	OB	t	Unknown:Unknown	d
323	(0019,"GEMS_ACQU_01",47)	SS	t	ViewCompressionFactor	k
4069	(0029,"",18)	CS	t	Unknown	d
3797	(0029,"",18)	UN	t	Unknown	d
4136	(5653,"",16)	UN	t	Unknown	d
4208	(5653,"",16)	OB	t	Unknown	d
5110	(2005,"Philips MR Imaging DD 001",02)	OB	t	Image Angulation RL	k
4958	(2005,"Philips MR Imaging DD 004",89)		t	Viewing Protocol	k
4340	(00e1,"ELSCINT1",02)	SH	t	Unknown	d
829	(00e1,"ELSCINT1",02)	UN	t	Unknown	d
799	(0009,"GEMS_PETD_01",26)	SL	t	Axial Angle 3D	k
272	(0029,"GEMS_IMPS_01",35)	SL	t	AdvantageCompUnderflow	k
2891	(00e1,"ELSCINT1",39)[<0>](0040,0260)[<1>](0008,0102)	SH	t	Unknown:Performed Protocol Code Sequence:Coding Scheme Designator	d
3049	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",50)	OB	t	Unknown:Unknown	d
3866	(0019,"",e0)	UN	t	Unknown	d
5229	(2005,"Philips MR Imaging DD 005",45)	OB	t	Attenuation Correction	k
5130	(2005,"Philips MR Imaging DD 002",99)	OB	t	Number of Request Excerpts	k
5244	(2001,"Philips Imaging DD 001",7b)	OB	t	AcquisitionNumber	k
795	(0009,"GEMS_PETD_01",1d)	SL	t	Sel Stop Condition Data	k
3056	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",21)	OB	t	Unknown:Unknown	d
1073	(0019,"SIEMENS CT VA0  COAD",92)	DS	t	OsteoRegressionLineSlope	k
801	(0009,"GEMS_PETD_01",69)	SL	t	slice_count	k
1098	(7005,"TOSHIBA_MEC_CT3",23)	UN	t	Pitch Factor	k
3887	(0019,"",5a)	UN	t	Unknown	d
406	(0019,"GEMS_ACQU_01",9b)	SS	t	PulseSequenceMode	k
3891	(0019,"",ac)	UN	t	Unknown	d
249	(0043,"GEMS_PARM_01",1a)	SL	t	StartingChannelNumber	k
4303	(0009,"CTP",08)	UN	t	Unknown	d
3652	(0011,"GEMS_GDXE_FALCON_04",71)	UN	t	Unknown	d
627	(0009,"GEMS_PETD_01",a7)	FL	t	total_counts	k
1423	(0009,"GEMS_PETD_01",33)	SL	t	Upper Reject Limit	d
3829	(0043,"",2e)	UN	t	Unknown	d
502	(0019,"GEMS_ACQU_01",bc)	DS	t	UserData	d
756	(0009,"GEMS_PETD_01",1e)	SL	t	Collect Deadtime	k
205	(0019,"GEMS_ACQU_01",76)	DS	t	MaxRightChannelOverViews	k
4187	(0043,"dcm4che/archive",1e)	DS	t	Unknown	d
252	(0043,"GEMS_PARM_01",45)	SL	t	DASAdInput	k
163	(0027,"GEMS_IMAG_01",53)	SH	t	RASLetterForAnteriorPosterior	k
3933	(0029,"",17)	UN	t	Unknown	d
3948	(0019,"",d9)	UN	t	Unknown	d
2982	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
1615	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",5a)	UN	t	Unknown	d
4241	(0077,"NIL_nICE_ATT",02)	SS	t	Unknown	d
524	(0019,"GEMS_ACQU_01",97)	SL	t	BitmapDefiningCVs	k
5054	(2005,"Philips MR Imaging DD 001",0b)	OB	t	Max FP	k
5131	(2005,"Philips MR Imaging DD 001",08)	OB	t	Image Offcenter AP	k
505	(0019,"GEMS_ACQU_01",b5)	DS	t	UserData	d
4049	(0033,"",0e)	LT	t	Unknown	d
5145	(2005,"Philips MR Imaging DD 004",36)	OB	t	Reference Frequency	k
3197	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
5265	(2005,"Philips MR Imaging DD 004",48)	OB	t	Spectro Hidden Line Removal	k
3992	(0043,"",29)	UN	t	Unknown	d
4210	(5653,"",15)[<0>](0020,0037)	DS	t	Unknown:Image Orientation (Patient)	d
3999	(0025,"",10)	UN	t	Unknown	d
4224	(0011,"ULTRAVISUAL_TAG_SET1",1b)	UN	t	Unknown	d
5322	(0015,"GEMS_PETD_01",3c)	UN	t	Recon Matrix Size	k
1371	(01f7,"ELSCINT1",2c)	OW	t	Unknown	d
3635	(0011,"GEMS_GDXE_FALCON_04",81)	UN	t	Unknown	d
4014	(0019,"",a9)	UN	t	Unknown	d
244	(0043,"GEMS_PARM_01",26)	US	t	NoViewsRefChannelsBlocked	k
5181	(2005,"Philips MR Imaging DD 001",b1)	OB	t	Diffusion Direction AP	k
625	(0009,"GEMS_PETD_01",e5)	FL	t	left shift	k
3182	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",96)	OB	t	Unknown:Unknown	d
3029	(50f1,"FDMS 1.0",10)	OB	t	Film Output Format	d
2878	(00e1,"ELSCINT1",39)[<0>](0040,0275)[<1>](0040,0008)	SQ	t	Unknown:Request Attributes Sequence:Scheduled Protocol Code Sequence	d
3732	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",10)	LT	t	Internal Value	d
159	(0021,"GEMS_RELA_01",18)	SH	t	GenesisVersionNow	k
4313	(0137,"NetRAAD",0d)	UI	t	Unknown	d
447	(0043,"GEMS_PARM_01",07)	SS	t	ViewsPerSegment	k
509	(0021,"GEMS_RELA_01",5b)	DS	t	FloatSlop	k
1530	(3109,"Applicare/RadWorks/Version 6.0/Summary",12)	ST	t	Receive Origin Description	d
4051	(0019,"",08)	CS	t	Unknown	d
3786	(0019,"",08)	UN	t	Unknown	d
5144	(2005,"Philips MR Imaging DD 001",0a)	OB	t	Image OffCentre RL	k
3068	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",21)	OB	t	Unknown:Unknown	d
2933	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",40)	SQ	t	Unknown:Unknown	d
5157	(2005,"Philips MR Imaging DD 004",47)	OB	t	Spectro Gamma	k
771	(0009,"GEMS_PETD_01",63)	SL	t	frame_size	d
2143	(0011,"GEMS_GENIE_1",46)	SL	t	InterpolationType	d
5219	(2001,"Philips Imaging DD 001",12)	OB	t	DynamicSeries	k
5218	(2005,"Philips MR Imaging DD 005",4e)	OB	t	Is B1 Series	k
816	(01f1,"ELSCINT1",08)	DS	t	Acquisition Length	k
3729	(0019,"Siemens: Thorax/Multix FD Lab Settings",02)	LO	t	Total Dose Area Product uGy*cm*cm	d
692	(0009,"GEMS_PETD_01",ad)	LO	t	trans_frame_id	h
1075	(0021,"SIEMENS MED",11)	DS	t	Target	k
5073	(2001,"Philips Imaging DD 001",1d)	OB	t	ReconstructionNumberMR	k
493	(0019,"GEMS_ACQU_01",a9)	DS	t	UserData	d
785	(0009,"GEMS_PETD_01",90)	SL	t	BP Filter Order	k
1622	(0043,"GEMS_PARM_01",29)	OB	t	HistogramTables	d
390	(0043,"GEMS_PARM_01",33)	FL	t	NegScanSpacing	k
3006	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a1)	OB	t	Unknown:Unknown:Unknown	d
3632	(0011,"GEMS_GDXE_FALCON_04",06)	DS	t	Image Dose	d
3294	(3773,"Unnamed Private Block - 01",31)[<0>](3773,"Unnamed Private Block - 01",32)[<1>](0028,0100)	US	t	Unknown:Unknown:Bits Allocated	d
5307	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",59)	FL	t	Series Volume:Volume FOV RL	k
4122	(0019,"",26)	UN	t	Unknown	d
3164	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",62)	OB	t	Unknown:Unknown	d
4336	(01f7,"ELSCINT1",9b)	IS	t	Unknown	d
830	(01f7,"ELSCINT1",9b)	UN	t	Unknown	d
4237	(0029,"",00)	UN	t	Unknown	d
3163	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",62)	OB	t	Unknown:Unknown	d
3996	(0043,"",28)	UN	t	Unknown	d
773	(0009,"GEMS_PETD_01",18)	SL	t	Scan Type	k
3021	(0019,"FDMS 1.0",80)	OB	t	ReadingPositionSpecification	d
754	(0009,"GEMS_PETD_01",1c)	SL	t	Sel Stop Condition	k
510	(0019,"GEMS_ACQU_01",b2)	DS	t	UserData	d
516	(0019,"GEMS_ACQU_01",f9)	DS	t	TransmissionGain	k
3730	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",17)	LO	t	Unknown	d
2868	(01f3,"ELSCINT1",12)	OB	t	Unknown	d
4199	(5653,"",15)	SQ	t	Unknown	d
4077	(0051,"SIEMENS MR HEADER",0e)	SH	t	Unknown	d
1694	(0051,"SIEMENS MR HEADER",0e)	LO	t	Unknown	d
131	(0051,"SIEMENS MR HEADER",0e)	OB	t	Unknown	d
5187	(2001,"Philips Imaging DD 001",82)	OB	t	Echo Train Length	k
4020	(0027,"",40)	UN	t	Unknown	d
3156	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
287	(0029,"GEMS_IMPS_01",26)	SS	t	VersionOfHeaderStructure	k
1276	(0009,"GEIIS",10)[<0>](0028,0101)	US	t	GE Private Image Thumbnail Sequence:Bits Stored	na
765	(0009,"GEMS_PETD_01",2a)	SL	t	Collimation	k
1489	(0009,"GEIIS",10)		t	GE Private Image Thumbnail Sequence	d
1252	(0009,"GEIIS",10)	SQ	t	GE Private Image Thumbnail Sequence	d
2128	(0009,"GEMS_GENIE_1",10)	LO	t	Unknown	d
3039	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",a2)	OB	t	Unknown:Unknown	d
395	(0019,"GEMS_ACQU_01",95)	SS	t	AnalogReceiverGain	k
1499	(0029,"SIEMENS CSA HEADER",19)	LO	t	CSASeriesHeaderVersion	d
143	(0029,"SIEMENS CSA HEADER",19)	OB	t	CSASeriesHeaderVersion	d
490	(0019,"GEMS_ACQU_01",b3)	DS	t	UserData	d
293	(0019,"GEMS_ACQU_01",dc)	SS	t	PrimarySpeedCorrectionUsed	k
1505	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",5f)	UN	t	Unknown	d
4201	(5653,"",14)[<0>](5653,"",12)	OB	t	Unknown:Unknown	d
3045	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
1074	(0019,"SIEMENS CT VA0  COAD",90)	DS	t	OsteoOffset	k
1046	(0053,"GEHC_CT_ADVAPP_001",83)	UN	t	AnnotationmA	k
3704	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",07)	FL	t	Unknown	d
3864	(0027,"",10)	UN	t	Unknown	d
5480	(07a5,"ELSCINT1",1c)	LO	t	Unknown	d
5134	(2005,"Philips MR Imaging DD 005",14)	OB	t	Number of Diffusion B Values	k
3877	(0019,"",c6)	UN	t	Unknown	d
3718	(0021,"Siemens: Thorax/Multix FD Post Processing",12)	SS	t	Unknown	d
5142	(2005,"Philips MR Imaging DD 004",49)	OB	t	Spectro Horizontal Shift	k
4202	(5653,"",14)[<0>](5653,"",13)	OB	t	Unknown:Unknown	d
278	(0027,"GEMS_IMAG_01",35)	SS	t	PlaneType	k
603	(0009,"GEMS_PETD_01",9b)	FL	t	CAC Skull Offset	k
1540	(0047,"GEMS_3DSTATE_001",ec)	FL	t	Unknown	d
1377	(01f7,"ELSCINT1",23)	OW	t	Unknown	d
2816	(01f7,"ELSCINT1",23)	OB	t	Unknown	d
408	(0027,"GEMS_IMAG_01",31)	SS	t	ImagingMode	k
2167	(0009,"GEMS_IDEN_01",40)	UN	t	Unknown	d
3774	(2005,"Philips MR Imaging DD 005",55)	FD	t	Velocity Encoding Direction	d
4956	(2005,"Philips MR Imaging DD 005",55)	UN	t	Velocity Encoding Direction	k
5160	(2005,"Philips MR Imaging DD 005",55)	OB	t	Velocity Encoding Direction	k
4147	(5653,"Vital Images SW 3.4",14)	SQ	t	Saved Workflow File Sequence	d
391	(0043,"GEMS_PARM_01",38)	FL	t	User25ToUser48	k
231	(0027,"GEMS_IMAG_01",4b)	FL	t	RCoordOfBottomRightCorner	k
1355	(00e1,"ELSCINT1",40)	SH	t	Image Label	d
2842	(00e1,"ELSCINT1",40)	OB	t	Image Label	d
1147	(0009,"GEMS_PETD_01",77)	SL	t	uncompressed_size	k
1214	(0029,"SIEMENS MEDCOM HEADER2",60)	LO	t	SeriesWorkflowStatus	k
74	(0029,"SIEMENS MEDCOM HEADER2",60)	OB	t	SeriesWorkflowStatus	k
3080	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",20)	OB	t	Unknown:Unknown	d
3165	(0019,"FDMS 1.0",50)	OB	t	EDRMode	d
3687	(0040,030e)[<0>](01e3,"ELSCINT1",09)	UN	t	Exposure Dose Sequence:Unknown	d
4068	(0029,"",08)	CS	t	Unknown	d
3817	(0029,"",08)	UN	t	Unknown	d
1578	(0051,"SIEMENS MR HEADER",13)	SH	t	Positive PCS Directions	k
73	(0051,"SIEMENS MR HEADER",13)	OB	t	Positive PCS Directions	k
896	(0019,"SIEMENS CT VA0  COAD",b0)	DS	t	Feed per Rotation	k
314	(0043,"GEMS_PARM_01",1b)	SS	t	PPScanParameters	k
3923	(0009,"",e9)	UN	t	Unknown	d
3258	(0029,"INTELERAD MEDICAL SYSTEMS",02)	UN	t	ImageQuality	d
3093	(0025,"FDMS 1.0",11)	OB	t	TermOfCorrectionForEachIPTypeSt	d
523	(0021,"GEMS_RELA_01",57)	SL	t	IntegerSlop	k
1304	(7053,"Philips PET Private Group",01)	OB	t	Private Data	d
1437	(00e1,"ELSCINT1",a0)	LO	t	Unknown	d
3944	(0019,"",cf)	UN	t	Unknown	d
1272	(0009,"GEIIS",10)[<0>](0028,0102)	US	t	GE Private Image Thumbnail Sequence:High Bit	na
5114	(2005,"Philips MR Imaging DD 004",50)	OB	t	Spectro Horizontal Window	k
380	(0043,"GEMS_PARM_01",36)	UL	t	UserFillMapMSW	k
5221	(2005,"Philips MR Imaging DD 001",31)	OB	t	Respiratory Gating	k
3684	(0040,030e)[<0>](01f1,"ELSCINT1",27)	DS	t	Exposure Dose Sequence:Rotation Time	d
2963	(50f1,"FDMS 1.0",0a)	OB	t	FNC Parameters	d
3733	(0019,"Siemens: Thorax/Multix FD Lab Settings",07)	FD	t	Table Detector Distance	d
580	(0009,"GEMS_PETD_01",62)	ST	t	where_is_frame	d
1285	(0009,"GEMS_IDEN_01",39)	UN	t	Unknown	d
790	(0009,"GEMS_PETD_01",2d)	SL	t	Event Separation	k
3646	(0011,"GEMS_GDXE_FALCON_04",59)	UN	t	Unknown	d
2903	(00e1,"ELSCINT1",39)[<0>](0040,0275)[<1>](0040,0007)	LO	t	Unknown:Request Attributes Sequence:Scheduled Procedure Step Description	d
1017	(7005,"TOSHIBA_MEC_CT3",1b)	SH	t	Convolution Kernel for Series Record	k
824	(01f1,"ELSCINT1",32)	CS	t	Image View Convention	k
2801	(01f1,"ELSCINT1",32)	OB	t	Image View Convention	d
3985	(0019,"",d5)	UN	t	Unknown	d
3256	(0029,"INTELERAD MEDICAL SYSTEMS",03)	UN	t	ImageBytesTransferred	d
1654	(07a3,"ELSCINT1",9c)	CS	t	Unknown	d
1398	(0009,"GEMS_IDEN_01",37)	UN	t	Unknown	d
404	(0019,"GEMS_ACQU_01",d5)	SS	t	FractionalEcho	k
4327	(0043,"GEMS_PARM_01",b3)	DS	t	Unknown	d
321	(0043,"GEMS_PARM_01",1d)	SS	t	LevelValue	k
4005	(0019,"",af)	UN	t	Unknown	d
1208	(0029,"SIEMENS MEDCOM OOG",10)	OB	t	MEDCOMOOGInfo	d
1689	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",35)	UN	t	Unknown	d
175	(0019,"GEMS_ACQU_01",18)	LO	t	FirstScanRAS	k
3155	(0021,"FDMS 1.0",30)	OB	t	SetNo	d
3674	(200b,"Philips RAD Imaging DD 097",aa)[<0>](200b,"Philips RAD Imaging DD 097",ac)	UN	t	Unknown:Unknown	d
4115	(0019,"SIEMENS MR HEADER",0a)	UN	t	Number of Images in Mosaic	d
1696	(0019,"SIEMENS MR HEADER",0a)	OB	t	Number of Images in Mosaic	d
1286	(0009,"GEMS_IDEN_01",6c)	UN	t	Unknown	d
452	(0043,"GEMS_PARM_01",2d)	SH	t	StringSlopField1	k
138	(0019,"SIEMENS MR HEADER",08)	OB	t	Unknown	d
696	(0009,"GEMS_PETD_01",05)	LO	t	Patient DateTime	o
857	(0009,"GEMS_PETD_01",05)	DT	t	Patient DateTime	o
4048	(0033,"",16)	PN	t	Unknown	d
3805	(0033,"",16)	UN	t	Unknown	d
631	(0009,"GEMS_PETD_01",bb)	FL	t	Post Filter Param	k
3048	(0025,"FDMS 1.0",12)	OB	t	ReadingGainGp	d
211	(0019,"GEMS_ACQU_01",74)	DS	t	MaxLeftChannelOverViews	k
3639	(0011,"GEMS_GDXE_FALCON_04",70)	UN	t	Unknown	d
1514	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",13)	UN	t	Unknown	d
4962	(0028,3110)[<0>](2001,"Philips Imaging DD 001",53)	CS	t	Softcopy VOI LUT Sequence:Presentation GL Transform Invert	d
5136	(2001,"Philips Imaging DD 001",0f)	OB	t	Cardiac Gate Width	k
1347	(01f7,"ELSCINT1",10)	OB	t	Unknown	d
1532	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",56)	UN	t	Unknown	d
4186	(0043,"dcm4che/archive",27)	SH	t	Unknown	d
3060	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",71)	OB	t	Unknown:Unknown	d
3888	(0019,"",91)	UN	t	Unknown	d
4196	(0043,"dcm4che/archive",1f)	SL	t	Unknown	d
2956	(0019,"FDMS 1.0",60)	OB	t	RadiographersCode	d
482	(0019,"GEMS_ACQU_01",b1)	DS	t	UserData	d
1054	(0053,"GEHC_CT_ADVAPP_001",84)	UN	t	CommandedFirstkVp	k
3268	(0051,"GEMS_CT_VES_01",01)[<0>](0020,000d)	UI	t	CTVESequence:Study Instance UID	d
3665	(2001,"Philips Imaging DD 002",6c)	UN	t	Unknown	d
4097	(0019,"SIEMENS MR HEADER",27)	FD	t	B Matrix	d
4117	(0019,"SIEMENS MR HEADER",27)	UN	t	B Matrix	d
152	(0019,"SIEMENS MR HEADER",27)	OB	t	B Matrix	k
4109	(0019,"SIEMENS MR HEADER",26)	FD	t	Unknown	d
4124	(0019,"SIEMENS MR HEADER",26)	UN	t	Unknown	d
434	(0043,"GEMS_PARM_01",08)	SS	t	RespiratoryRateInBPM	k
3810	(0051,"",12)	UN	t	Unknown	d
606	(0009,"GEMS_PETD_01",3a)	FL	t	Pre Inj Volume	k
834	(01e1,"ELSCINT1",41)	UN	t	Unknown	d
874	(0009,"GEMS_PETD_01",b2)	SL	t	IR Num Iterations	k
648	(0009,"GEMS_PETD_01",b2)	SS	t	IR Num Iterations	k
1071	(0019,"SIEMENS CT VA0  COAD",96)	IS	t	OsteoPhantomNumber	k
5199	(2005,"Philips MR Imaging DD 004",27)	OB	t	Spectro Complex Component	k
5186	(2001,"Philips Imaging DD 001",15)	OB	t	NumberOfLocations	k
3928	(0043,"",7d)	UN	t	Unknown	d
3760	(0079,"Unnamed Private Block - 10",17)	IS	t	Unknown	d
4218	(0011,"ULTRAVISUAL_TAG_SET1",11)	UN	t	Unknown	d
2990	(0009,"FDMS 1.0",f0)	OB	t	Blackening Process Flag	d
1263	(0905,"GEIIS",30)	LO	t	Assigning Authority For Patient ID	d
5276	(0905,"GEIIS",30)	OB	t	Assigning Authority For Patient ID	d
1607	(0029,"SIEMENS CSA HEADER",20)	OB	t	CSASeriesHeaderInfo	d
4073	(0043,"GEMS_PARM_01",8d)	DS	t	SAT Band Locations	d
3965	(0043,"",0b)	UN	t	Unknown	d
2989	(0009,"FDMS 1.0",f1)	OB	t	Processing Information Flag	d
1633	(0029,"MITRA MARKUP 1.0",00)	OB	t	Markup1	d
2971	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",80)[<1>](0027,"FDMS 1.0",a0)	OB	t	Unknown:Unknown:Unknown	d
1473	(0009,"Unnamed Private Block - 10",3d)	UN	t	Unknown	d
1368	(01f7,"ELSCINT1",26)	OW	t	Unknown	d
2858	(01f7,"ELSCINT1",26)	OB	t	Unknown	d
5148	(2005,"Philips MR Imaging DD 004",57)	OB	t	Spectro Spectral BW	k
1652	(0051,"SIEMENS MR HEADER",0f)	LO	t	Coil String	k
70	(0051,"SIEMENS MR HEADER",0f)	OB	t	Coil String	k
4156	(5653,"Vital Images SW 3.4",14)[<0>](5653,"Vital Images SW 3.4",13)	SL	t	Saved Workflow File Sequence:Saved Workflow File Length	d
511	(0021,"GEMS_RELA_01",5c)	DS	t	FloatSlop	k
317	(0019,"GEMS_ACQU_01",39)	SS	t	ScanFOVType	k
4323	(0023,"GEMS_STDY_01",80)[<0>](0008,1120)[<1>](0008,1155)	UI	t	Has MPPS Related Tags:Referenced Patient Sequence:Referenced SOP Instance UID	h
3144	(0023,"FDMS 1.0",20)[<0>](0025,"FDMS 1.0",92)	OB	t	Unknown:Unknown	d
2811	(01f7,"ELSCINT1",14)	OB	t	Unknown	d
1373	(01f7,"ELSCINT1",14)	OW	t	Unknown	d
4009	(0043,"",36)	UN	t	Unknown	d
1683	(07a3,"ELSCINT1",99)	CS	t	Unknown	d
4176	(0043,"dcm4che/archive",28)	OB	t	Unknown	d
4076	(0043,"GEMS_PARM_01",8c)	DS	t	Voxel Location	d
635	(0009,"GEMS_PETD_01",dc)	FL	t	ir_z_filter_ratio	k
2936	(0023,"FDMS 1.0",20)	SQ	t	Unknown	d
2917	(00e1,"ELSCINT1",39)[<0>](0008,1140)[<1>](0008,1155)	UI	t	Unknown:Referenced Image Sequence:Referenced SOP Instance UID	d
263	(0043,"GEMS_PARM_01",43)	SL	t	DASFpaGain	k
4219	(0011,"ULTRAVISUAL_TAG_SET1",1c)	UN	t	Unknown	d
610	(0009,"GEMS_PETD_01",ac)	FL	t	bp_center_y	k
3840	(0043,"",30)	UN	t	Unknown	d
2144	(0009,"GEMS_GENIE_1",42)	DA	t	PatientCreationDate	d
2131	(0011,"GEMS_GENIE_1",12)	LO	t	DatasetName	d
425	(0019,"GEMS_ACQU_01",c8)	SS	t	SATThicknessRL	k
3844	(0021,"",4f)	UN	t	Unknown	d
184	(0043,"GEMS_PARM_01",1e)	DS	t	DeltaStartTime	k
4151	(5653,"Vital Images SW 3.4",17)	UI	t	Volume SOP Instance UID	d
3177	(0023,"FDMS 1.0",20)[<0>](0027,"FDMS 1.0",20)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
5340	(0015,"GEMS_PETD_01",31)	UN	t	Recon Algorithm	k
5295	(0008,1115)[<0>](0008,1140)[<1>](2001,"Philips Imaging DD 001",c1)	LO	t	Referenced Series Sequence:Referenced Image Sequence:Linear Modality GL Transform	d
3778	(0051,"GEMS_FUNCTOOL_01",03)	FL	t	Bias	d
5086	(2005,"Philips MR Imaging DD 004",34)	OB	t	Physical Quantity for Chemical Shift	k
1258	(0009,"GEIIS",10)[<0>](7fd1,"GEIIS",10)	UL	t	GE Private Image Thumbnail Sequence:Compression Type	na
2164	(7fd1,"GEIIS",40)	UL	t	Subband Rows	k
4054	(0019,"",18)	IS	t	Unknown	d
3823	(0019,"",18)	UN	t	Unknown	d
3885	(0019,"",c4)	UN	t	Unknown	d
3890	(0019,"",bd)	UN	t	Unknown	d
4058	(0019,"",11)	SH	t	Unknown	d
3792	(0019,"",11)	UN	t	Unknown	d
4972	(2005,"Philips MR Imaging DD 005",0e)		t	Private Shared Sequence	d
5065	(2005,"Philips MR Imaging DD 005",0e)	OB	t	Private Shared Sequence	d
5491	(07a1,"ELSCINT1",97)	SH	t	Unknown	d
2920	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",70)	SQ	t	Unknown:Unknown	d
3916	(0021,"",5e)	UN	t	Unknown	d
2935	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",30)	SQ	t	Unknown:Unknown	d
3629	(0045,"GEMS_FALCON_03",65)	IS	t	Requested Detector Entrance Dose	d
5241	(2001,"Philips Imaging DD 001",06)	OB	t	ImageEnhanced	k
4036	(0051,"",0e)	LO	t	Unknown	d
3785	(0051,"",0e)	UN	t	Unknown	d
604	(0009,"GEMS_PETD_01",e9)	FL	t	acq_bin_dur_percent	k
862	(0009,"GEMS_PETD_01",e9)	SL	t	acq_bin_dur_percent	k
1597	(0009,"GEMS_PETD_01",10)	LO	t	Hospital Name	d
1041	(0053,"GEHC_CT_ADVAPP_001",70)	UN	t	MultiEnergySourceCount	k
1360	(00e1,"ELSCINT1",42)	LO	t	Unknown	d
4091	(700d,"TOSHIBA_MEC_MR3",0c)	UN	t	Unknown	d
1034	(0053,"GEHC_CT_ADVAPP_001",8e)	UN	t	MonoWindoHigh	k
3110	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",13)	OB	t	Unknown:Unknown	d
517	(0019,"GEMS_ACQU_01",a2)	SL	t	RawDataRunNumber	k
5225	(2005,"Philips MR Imaging DD 001",38)	OB	t	Spoiled	k
2911	(00e1,"ELSCINT1",39)[<0>](0032,1032)	PN	t	Unknown:Requesting Physician	d
2898	(00e1,"ELSCINT1",39)[<0>](0040,0275)[<1>](0040,1001)	SH	t	Unknown:Request Attributes Sequence:Requested Procedure ID	d
3122	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",73)	OB	t	Unknown:Unknown	d
506	(0019,"GEMS_ACQU_01",8d)	DS	t	DelayAfterTrigger	k
271	(0025,"GEMS_SERS_01",10)	SL	t	LandmarkCounter	k
422	(0043,"GEMS_PARM_01",02)	SS	t	GradientOffsetInX	k
427	(0019,"GEMS_ACQU_01",cb)	SS	t	PrescribedFlowAxis	k
1114	(0009,"GEMS_PETD_01",84)	FL	t	Rotate	k
2882	(00e1,"ELSCINT1",39)[<0>](0008,1032)	SQ	t	Unknown:Procedure Code Sequence	d
5273	(2001,"Philips Imaging DD 001",23)	OB	t	FlipAnglePhilips	k
3676	(200b,"Philips RAD Imaging DD 097",a4)	UN	t	Unknown	d
192	(0019,"GEMS_ACQU_01",23)	DS	t	TableSpeed	k
4038	(0029,"",60)	LO	t	Unknown	d
1675	(0019,"SIEMENS MR HEADER",12)	SL	t	Table Position Origin	k
63	(0019,"SIEMENS MR HEADER",12)	OB	t	Table Position Origin	k
1676	(0019,"SIEMENS MR HEADER",15)	FD	t	Slice Position PCS	k
62	(0019,"SIEMENS MR HEADER",15)	OB	t	Slice Position PCS	k
274	(0043,"GEMS_PARM_01",46)	SL	t	DASCalMode	k
3812	(0029,"",19)	UN	t	Unknown	d
890	(0043,"GEMS_PARM_01",7d)	US	t	Recon Mode Flag Word	k
4987	(2005,"Philips MR Imaging DD 005",0f)[<0>](0008,0012)	DA	t	Private Per-Frame Sequence:Instance Creation Date	na
3875	(0043,"",2f)	UN	t	Unknown	d
4185	(0043,"dcm4che/archive",16)	SS	t	Instance Updated	d
5239	(2001,"Philips Imaging DD 001",62)	OB	t	SeriesCommitted	k
2849	(01f3,"ELSCINT1",18)	OB	t	Unknown	d
770	(0009,"GEMS_PETD_01",8e)	SL	t	BP Filter	k
3069	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",20)	OB	t	Unknown:Unknown	d
5083	(2005,"Philips MR Imaging DD 004",35)	OB	t	Physical Quantity Spatial	k
3758	(0079,"Unnamed Private Block - 10",07)	LO	t	Unknown	d
430	(0019,"GEMS_ACQU_01",ca)	SS	t	SATThicknessHF	k
3764	(0079,"Unnamed Private Block - 10",04)	DS	t	Unknown	d
4033	(0051,"",0d)	SH	t	Unknown	d
3802	(0051,"",0d)	UN	t	Unknown	d
5479	(07a3,"ELSCINT1",e3)	LO	t	Unknown	d
226	(0043,"GEMS_PARM_01",41)	FL	t	DegreeOfRotation	k
5169	(2005,"Philips MR Imaging DD 001",23)	OB	t	Number of Slabs	k
398	(0019,"GEMS_ACQU_01",ce)	SS	t	PrescanType	k
3910	(0027,"",32)	UN	t	Unknown	d
579	(0009,"GEMS_PETD_01",e4)	ST	t	Unknown	d
1045	(0053,"GEHC_CT_ADVAPP_001",72)	UN	t	MultiEnergyReconType	k
622	(0009,"GEMS_PETD_01",a0)	FL	t	Axial Cutoff 3D	k
3089	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",71)	OB	t	Unknown:Unknown	d
349	(0021,"GEMS_RELA_01",35)	SS	t	SeriesFromWhichPrescribed	d
4184	(0043,"dcm4che/archive",25)	SS	t	Unknown	d
451	(0043,"GEMS_PARM_01",2e)	SH	t	StringSlopField2	k
2952	(0019,"FDMS 1.0",15)	OB	t	KanjiBodyPartForExposure	d
5289	(0028,3110)[<0>](0008,1140)[<1>](2001,"Philips Imaging DD 001",c1)	LO	t	Softcopy VOI LUT Sequence:Referenced Image Sequence:Linear Modality GL Transform	d
3102	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",a1)	OB	t	Unknown:Unknown	d
4191	(0043,"dcm4che/archive",10)	US	t	Patient Pk	d
4087	(700d,"TOSHIBA_MEC_MR3",03)	SS	t	Flip Flag	d
686	(0009,"GEMS_PETD_01",59)	LO	t	WC Cal ID	h
840	(0009,"GEMS_PETD_01",59)	UI	t	WC Cal ID	h
486	(0019,"GEMS_ACQU_01",af)	DS	t	UserData	d
5249	(2001,"Philips Imaging DD 001",04)	OB	t	DiffusionDirection	k
358	(0045,"GEMS_HELIOS_01",15)	SS	t	Start View 2B	k
812	(01f1,"ELSCINT1",05)	DS	t	Reconstruction Arc	k
3123	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",70)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
5051	(2001,"Philips Imaging DD 001",0a)	OB	t	SliceNumberMR	k
1089	(0053,"GEHC_CT_ADVAPP_001",9b)	UN	t	MD2attenuationCurve	k
1645	(0029,"SIEMENS CSA HEADER",18)	CS	t	CSASeriesHeaderType	d
140	(0029,"SIEMENS CSA HEADER",18)	OB	t	CSASeriesHeaderType	d
3986	(0043,"",02)	UN	t	Unknown	d
2928	(0023,"FDMS 1.0",30)[<0>](0027,"FDMS 1.0",20)	SQ	t	Unknown:Unknown	d
268	(0019,"GEMS_ACQU_01",26)	SL	t	DegreesOfAzimuth	k
160	(0009,"GEMS_IDEN_01",e6)	SH	t	GenesisVersionNow	k
3189	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",40)[<1>](0027,"FDMS 1.0",a2)	OB	t	Unknown:Unknown:Unknown	d
179	(0009,"GEMS_IDEN_01",01)	LO	t	FullFidelity	k
757	(0009,"GEMS_PETD_01",6d)	SL	t	acq_duration	k
429	(0019,"GEMS_ACQU_01",8f)	SS	t	SwapPhaseFrequency	k
1663	(0009,"GEMS_IDEN_01",e7)	UL	t	ExamRecordChecksum	d
5242	(2005,"Philips MR Imaging DD 001",35)	OB	t	StackSliceNumber	k
2867	(01f3,"ELSCINT1",16)	OB	t	Unknown	d
4967	(0070,005a)[<0>](2001,"Philips Imaging DD 001",3f)	CS	t	Displayed Area Selection Sequence:ZoomMode	d
3242	(300a,0010)[<0>](300d,"TOMO_HA_01",19)	UN	t	Dose Reference Sequence:Unknown	d
818	(00e1,"ELSCINT1",50)	DS	t	Acquisition Duration	k
2800	(00e1,"ELSCINT1",50)	OB	t	Acquisition Duration	d
3153	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",30)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
2826	(01f7,"ELSCINT1",30)	OB	t	Unknown	d
1386	(01f7,"ELSCINT1",30)	OW	t	Unknown	d
814	(00e1,"ELSCINT1",22)	DS	t	Presentation Relative Center	k
2841	(00e1,"ELSCINT1",22)	OB	t	Presentation Relative Center	d
768	(0009,"GEMS_PETD_01",81)	SL	t	Number of Normals	k
1374	(01f7,"ELSCINT1",25)	OW	t	Unknown	d
2812	(01f7,"ELSCINT1",25)	OB	t	Unknown	d
3037	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",50)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
2901	(00e1,"ELSCINT1",39)[<0>](0020,0010)	SH	t	Unknown:Study ID	d
5188	(2005,"Philips MR Imaging DD 001",61)	OB	t	Prepulse Type	k
3848	(0043,"",97)	UN	t	Unknown	d
3271	(0051,"GEMS_CT_VES_01",01)[<0>](0032,1060)	LO	t	CTVESequence:Requested Procedure Description	d
5310	(2005,"Philips MR Imaging DD 001",85)[<0>](2005,"Philips MR Imaging DD 001",56)	FL	t	Series Volume:Volume Angulation RL	k
1478	(0009,"Unnamed Private Block - 10",68)	UN	t	Unknown	d
2133	(0009,"GEMS_GENIE_1",43)	TM	t	PatientCreationTime	d
3715	(0025,"Siemens: Thorax/Multix FD Raw Image Settings",14)	SS	t	Unknown	d
3055	(0023,"FDMS 1.0",10)[<0>](0027,"FDMS 1.0",10)[<1>](0027,"FDMS 1.0",a3)	OB	t	Unknown:Unknown:Unknown	d
5068	(2005,"Philips MR Imaging DD 004",91)	OB	t	Patient Name Job In Params	d
5474	(0095,"SIENET",12)	LO	t	Unknown	d
1446	(7053,"Philips PET Private Group",00)	DS	t	SUV Factor	k
4075	(0043,"GEMS_PARM_01",8e)	DS	t	Spectro Prescan Values	d
4964	(2005,"Philips MR Imaging DD 003",82)	CS	t	Running Attributes	k
166	(0027,"GEMS_IMAG_01",52)	SH	t	RASLetterForSideOfImage	k
3766	(0079,"Unnamed Private Block - 10",11)	DS	t	Unknown	d
1566	(0025,"GEMS_SERS_01",1b)	OB	t	Protocol Data Block (compressed)	d
402	(0043,"GEMS_PARM_01",0a)	SS	t	TypeOfReceiverUsed	k
242	(0027,"GEMS_IMAG_01",50)	FL	t	TableStartLocation	k
3078	(0023,"FDMS 1.0",30)[<0>](0025,"FDMS 1.0",a0)	OB	t	Unknown:Unknown	d
1315	(7053,"Philips PET Private Group",13)	SS	t	Unknown	d
1574	(0011,"IPKCREP 2Q00+0C  TMIGA ERPVITA EADAT",57)	UN	t	Unknown	d
5495	(07a1,"ELSCINT1",96)	DA	t	Unknown	d
694	(0009,"GEMS_PETD_01",13)	LO	t	FOR Identifier	h
851	(0009,"GEMS_PETD_01",13)	UI	t	FOR Identifier	h
4215	(0043,"",99)	UN	t	Unknown	d
445	(0043,"GEMS_PARM_01",2c)	SS	t	EffectiveEchoSpacing	k
1081	(0053,"GEHC_CT_ADVAPP_001",98)	UN	t	MD2intercept	k
831	(01f7,"ELSCINT1",99)	UN	t	Unknown	d
4349	(01f7,"ELSCINT1",99)	OW	t	Unknown	d
4032	(0031,"",01)	UL	t	Unknown	d
3795	(0031,"",01)	UN	t	Unknown	d
3106	(0023,"FDMS 1.0",10)[<0>](0025,"FDMS 1.0",33)	OB	t	Unknown:Unknown	d
1604	(0019,"SIEMENS MR HEADER",28)	FD	t	Bandwidth per Pixel Phase Encode	k
61	(0019,"SIEMENS MR HEADER",28)	OB	t	Bandwidth per Pixel Phase Encode	k
3945	(0043,"",95)	UN	t	Unknown	d
2790	(7fdf,"ELSCINT1",ff)	OB	t	Unknown	d
\.


--
-- Name: element_seen_element_seen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.element_seen_element_seen_id_seq', 5892, true);


--
-- PostgreSQL database dump complete
--

