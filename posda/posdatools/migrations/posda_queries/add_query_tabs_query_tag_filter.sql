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
-- Name: query_tabs_query_tag_filter; Type: TABLE; Schema: public; Owner: posda; Tablespace: 
--

CREATE TABLE query_tabs_query_tag_filter (
    query_tab_name text NOT NULL,
    filter_name text NOT NULL,
    sort_order integer NOT NULL
);

--
-- Data for Name: query_tabs_query_tag_filter; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY query_tabs_query_tag_filter (query_tab_name, filter_name, sort_order) FROM stdin;
legacy	.Show No Tags	1
legacy	.Unlimited	2
legacy	counts_patient_status	3
legacy	dicom_batch_file_editing	4
legacy	downloads_by_date	5
legacy	duplicate_sop_evaluation	6
legacy	duplicate_sop_resolution	7
legacy	linkage_check	8
legacy	manage_posda_backlog	9
legacy	monthly_report_queries	10
legacy	phi_review	11
legacy	review_roles	12
legacy	send_data_via_dicom	13
legacy	view_posda_backlog	14
legacy	visual_review_scheduling	15
legacy	visual_review_tracking_processing	16
count_check	view_posda_backlog	1
count_check	downloads_by_date	2
count_check	counts_patient_status	3
scripting	used_in_simple_phi	1
scripting	used_in_file_import_into_posda	2
scripting	used_in_import_edited_files	3
scripting	used_in_reconcile_tag_names	4
scripting	used_processing_stucture_set_linkages	5
curation	duplicate_sop_evaluation	1
curation	duplicate_sop_resolution	2
curation	linkage_check	3
curation	consistency_check	4
legacy	consistency_check	2
legacy	.Unlimited	1
legacy	.Show No Tags	0
\.


--
-- PostgreSQL database dump complete
--

