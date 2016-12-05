--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: count_report; Type: TABLE; Schema: public; Owner: posda; Tablespace: 
--

CREATE TABLE count_report (
    count_report_id integer NOT NULL,
    at timestamp with time zone
);


ALTER TABLE public.count_report OWNER TO posda;

--
-- Name: count_report_count_report_id_seq; Type: SEQUENCE; Schema: public; Owner: posda
--

CREATE SEQUENCE count_report_count_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.count_report_count_report_id_seq OWNER TO posda;

--
-- Name: count_report_count_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: posda
--

ALTER SEQUENCE count_report_count_report_id_seq OWNED BY count_report.count_report_id;


--
-- Name: count_report_count_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('count_report_count_report_id_seq', 4, true);


--
-- Name: totals_by_collection_site; Type: TABLE; Schema: public; Owner: posda; Tablespace: 
--

CREATE TABLE totals_by_collection_site (
    count_report_id integer NOT NULL,
    collection_name text,
    site_name text,
    num_subjects integer,
    num_studies integer,
    num_series integer,
    num_sops integer
);


ALTER TABLE public.totals_by_collection_site OWNER TO posda;

--
-- Name: count_report_id; Type: DEFAULT; Schema: public; Owner: posda
--

ALTER TABLE ONLY count_report ALTER COLUMN count_report_id SET DEFAULT nextval('count_report_count_report_id_seq'::regclass);


--
-- Data for Name: count_report; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY count_report (count_report_id, at) FROM stdin;
1	2016-06-27 12:54:27.993502-05
2	2016-06-27 15:28:25.33836-05
3	2016-07-01 15:55:08.763646-05
4	2016-08-08 06:00:23.616536-05
\.


--
-- Data for Name: totals_by_collection_site; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY totals_by_collection_site (count_report_id, collection_name, site_name, num_subjects, num_studies, num_series, num_sops) FROM stdin;
1	Bladder Training	Baylor	5	5	25	2027
1	Bladder Training	MSKCC	1	1	1	1
1	Bladder Training	Sheffield	12	18	61	10675
1	Breast-MG	Stanford	2	8	8	8
1	Breast-MRI-NACT-Pilot	UCSF	64	189	2311	101899
1	CITN-09	EMORY	1	14	72	6788
1	CITN-09	JHU	1	10	59	4607
1	CITN-09	MountSinai	1	10	92	10328
1	CITN-09	SeattleCCA	6	50	356	42593
1	CITN-09	YALE	2	7	25	1722
1	Colorectal-Liver-Metastases	MSKCC	1	1	1	1
1	CTIIP-Preclinical-Animal-Models	UCDavis	14	14	14	118
1	Exceptional-Responders	NCI	14	49	267	26493
1	HNSCC	MDA	215	660	1266	130428
1	IvyGAP	SwedishSeattle	1	2	25	3965
1	LDCT	Beacon	17	30	160	13301
1	LDCT	BOSTONU	2	2	13	1821
1	LDCT	Lahey	267	374	1656	347880
1	LDCT	MiamiBaptist	15	16	109	11085
1	LDCT	Middlesex	11	15	105	14223
1	LDCT	NMCSD	21	43	214	30194
1	NSCLC Radiogenomics	Stanford	157	157	445	118148
1	Pancreas-CT	NIH-CC-LDRR	82	82	82	19328
1	QIN-BRAIN-DSC-MRI	MCWISC	6	6	6	9240
1	Radiomics	MAASTRO	324	324	324	324
1	TCGA-BLCA	Baylor	1	1	9	551
1	TCGA-BLCA	Chicago	21	21	174	15751
1	TCGA-BLCA	MDA	4	7	54	12096
1	TCGA-BLCA	MSKCC	20	22	167	12731
1	TCGA-BLCA	Sheffield	31	45	259	16265
1	TCGA-GBM	CWRU	1	1	1	560
1	TCGA-GBM	DUKE	3	3	8	899
1	TCGA-HNSC	MDA	41	223	1080	146415
1	TCGA-LGG	CWRU	2	2	2	2404
1	TCGA-LGG	HF	2	2	2	1830
1	TCGA-LIHC	AlbertaHS	29	30	331	29887
1	TCGA-LUAD	PrinceCharles1	1	1	1	10
1	TCGA-LUSC	PrinceCharles	1	1	5	260
1	TCGA-LUSC	PrinceCharles1	1	1	1	10
1	TCGA-PRAD	Lahey	1	1	1	1
2	Bladder Training	Baylor	5	5	25	2027
2	Bladder Training	MSKCC	1	1	1	1
2	Bladder Training	Sheffield	12	18	61	10675
2	Breast-MG	Stanford	2	8	8	8
2	Breast-MRI-NACT-Pilot	UCSF	64	189	2311	101899
2	CITN-09	EMORY	1	14	72	6788
2	CITN-09	JHU	1	10	59	4607
2	CITN-09	MountSinai	1	10	92	10328
2	CITN-09	SeattleCCA	6	50	356	42593
2	CITN-09	YALE	2	7	25	1722
2	Colorectal-Liver-Metastases	MSKCC	1	1	1	1
2	CTIIP-Preclinical-Animal-Models	UCDavis	14	14	14	118
2	Exceptional-Responders	NCI	14	49	267	26493
2	HNSCC	MDA	215	660	1266	130428
2	IvyGAP	SwedishSeattle	1	2	25	3965
2	LDCT	Beacon	17	30	160	13301
2	LDCT	BOSTONU	2	2	13	1821
2	LDCT	Lahey	267	374	1656	347880
2	LDCT	MiamiBaptist	15	16	109	11085
2	LDCT	Middlesex	11	15	105	14223
2	LDCT	NMCSD	21	43	214	30194
2	NSCLC Radiogenomics	Stanford	157	157	445	118148
2	Pancreas-CT	NIH-CC-LDRR	82	82	82	19328
2	QIN-BRAIN-DSC-MRI	MCWISC	6	6	6	9240
2	Radiomics	MAASTRO	324	324	324	324
2	TCGA-BLCA	Baylor	1	1	9	551
2	TCGA-BLCA	Chicago	21	21	174	15751
2	TCGA-BLCA	MDA	4	7	54	12096
2	TCGA-BLCA	MSKCC	20	22	167	12731
2	TCGA-BLCA	Sheffield	31	45	259	16265
2	TCGA-GBM	CWRU	1	1	1	560
2	TCGA-GBM	DUKE	3	3	8	899
2	TCGA-HNSC	MDA	41	223	1080	146415
2	TCGA-LGG	CWRU	2	2	2	2404
2	TCGA-LGG	HF	2	2	2	1830
2	TCGA-LIHC	AlbertaHS	29	30	331	29887
2	TCGA-LUAD	PrinceCharles1	1	1	1	10
2	TCGA-LUSC	PrinceCharles	1	1	5	260
2	TCGA-LUSC	PrinceCharles1	1	1	1	10
2	TCGA-PRAD	Lahey	1	1	1	1
3	ACRIN-FLT-Breast	ACRIN	10	73	217	61747
3	Bladder Training		1	1	1	1
3	Bladder Training	Baylor	5	5	25	2027
3	Bladder Training	MSKCC	4	4	23	1120
3	Bladder Training	Sheffield	12	18	61	10675
3	Breast-MG	Stanford	2	8	8	8
3	Breast-MRI-NACT-Pilot	UCSF	64	189	2311	101899
3	CITN-09	EMORY	1	14	72	6788
3	CITN-09	JHU	1	10	59	4607
3	CITN-09	MountSinai	1	10	92	10328
3	CITN-09	SeattleCCA	6	50	356	42593
3	CITN-09	YALE	2	7	25	1722
3	Colorectal-Liver-Metastases	MSKCC	1	1	1	1
3	CTIIP-Preclinical-Animal-Models	UCDavis	14	14	14	118
3	Exceptional-Responders	NCI	14	48	266	26492
3	HNSCC	MDA	215	660	1266	130428
3	IvyGAP	SwedishSeattle	1	8	109	12851
3	LDCT	Beacon	17	30	160	13301
3	LDCT	BOSTONU	2	2	13	1821
3	LDCT	Lahey	267	374	1656	347880
3	LDCT	MiamiBaptist	15	16	109	11085
3	LDCT	Middlesex	11	15	105	14223
3	LDCT	NMCSD	21	43	214	30194
3	NSCLC Radiogenomics	Stanford	157	157	445	118148
3	Pancreas-CT	NIH-CC-LDRR	82	82	82	19328
3	QIN-BRAIN-DSC-MRI	MCWISC	6	6	6	9240
3	Radiomics	MAASTRO	324	324	324	324
3	TCGA-BLCA	Baylor	1	1	9	551
3	TCGA-BLCA	Chicago	21	21	174	15751
3	TCGA-BLCA	MDA	4	7	54	12096
3	TCGA-BLCA	MSKCC	20	22	167	12731
3	TCGA-BLCA	Sheffield	31	45	259	16265
3	TCGA-BLCA	USC	1	1	1	1
3	TCGA-GBM	CWRU	1	1	1	560
3	TCGA-GBM	DUKE	3	3	8	899
3	TCGA-HNSC	MDA	41	223	1080	146415
3	TCGA-LGG	CWRU	2	2	2	2404
3	TCGA-LGG	HF	2	2	2	1830
3	TCGA-LIHC	AlbertaHS	29	30	331	29887
3	TCGA-LUAD	PrinceCharles1	1	1	1	10
3	TCGA-LUSC	PrinceCharles	1	1	5	260
3	TCGA-LUSC	PrinceCharles1	1	1	1	10
3	TCGA-PRAD	Lahey	1	1	1	1
4	ACRIN-FLT-Breast	ACRIN	10	73	219	68793
4	Bladder Training		1	1	1	1
4	Bladder Training	Baylor	5	5	24	2025
4	Bladder Training	MSKCC	5	5	43	4882
4	Bladder Training	Sheffield	12	18	61	10675
4	Breast-MG	Stanford	2	8	8	8
4	Breast-MRI-NACT-Pilot	UCSF	64	189	2689	102277
4	CITN-09	EMORY	1	14	72	6788
4	CITN-09	JHU	1	10	59	4607
4	CITN-09	MountSinai	1	10	92	10328
4	CITN-09	SeattleCCA	6	50	356	42593
4	CITN-09	YALE	2	7	25	1722
4	Colorectal-Liver-Metastases	MSKCC	1	1	1	1
4	CTIIP-Preclinical-Animal-Models	UCDavis	14	14	14	118
4	Exceptional-Responders	NCI	15	52	292	31331
4	HNSCC	MDA	215	700	1752	187225
4	ISPY1	UCSF	162	576	1150	1150
4	IvyGAP	SwedishSeattle	6	147	2227	360993
4	LDCT	Beacon	17	30	160	13301
4	LDCT	BOSTONU	2	2	13	1821
4	LDCT	Lahey	267	374	1656	347880
4	LDCT	MiamiBaptist	15	16	109	11085
4	LDCT	Middlesex	11	15	105	14223
4	LDCT	NMCSD	21	43	214	30194
4	MyelomaTT3PET	UAMS	1	1	1	10
4	NSCLC Radiogenomics	Stanford	156	156	447	119359
4	Pancreas-CT	NIH-CC-LDRR	82	82	82	19328
4	QIN-BRAIN-DSC-MRI	MCWISC	6	6	6	9240
4	Radiomics	MAASTRO	324	324	324	324
4	TCGA-BLCA	Baylor	1	1	9	551
4	TCGA-BLCA	Chicago	21	21	174	15751
4	TCGA-BLCA	MDA	5	8	63	14514
4	TCGA-BLCA	MSKCC	20	22	167	12731
4	TCGA-BLCA	Sheffield	31	45	259	16265
4	TCGA-BLCA	USC	1	1	1	1
4	TCGA-GBM	CWRU	1	1	1	560
4	TCGA-GBM	DUKE	3	3	8	899
4	TCGA-HNSC	MDA	41	223	1080	146429
4	TCGA-LGG	CWRU	2	2	2	2404
4	TCGA-LGG	HF	2	2	2	1830
4	TCGA-LIHC	AlbertaHS	29	30	331	29887
4	TCGA-LUAD	PrinceCharles1	1	1	1	10
4	TCGA-LUSC	PrinceCharles	1	1	5	260
4	TCGA-LUSC	PrinceCharles1	1	1	1	10
4	TCGA-PRAD	Lahey	7	7	141	11567
\.


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

