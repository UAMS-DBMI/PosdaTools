--
-- PostgreSQL database dump
--

-- Dumped from database version 8.4.20
-- Dumped by pg_dump version 9.5.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET row_security = off;

--
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


SET search_path = db_version, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: version; Type: TABLE; Schema: db_version; Owner: -
--

CREATE TABLE version (
    version integer
);


SET search_path = public, pg_catalog;

--
-- Name: pt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pt (
    pt_id integer NOT NULL,
    pt_signature text NOT NULL,
    pt_short_signature text NOT NULL,
    pt_owner text NOT NULL,
    pt_group text NOT NULL,
    pt_element text NOT NULL,
    pt_is_specific_to_block boolean,
    pt_specific_block text,
    pt_consensus_vr text,
    pt_consensus_vm text,
    pt_consensus_name text,
    pt_consensus_disposition text
);


--
-- Name: pt_dcmtk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pt_dcmtk (
    pt_dcmtk_is_repeating boolean,
    pt_id integer,
    ptrg_id integer,
    pt_dcmtk_signature text,
    pt_dcmtk_vr text,
    pt_dcmtk_vm text,
    pt_dcmtk_name text
);


--
-- Name: pt_dicom3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pt_dicom3 (
    pt_dicom3_is_repeating boolean,
    pt_id integer,
    ptrg_id integer,
    pt_dicom3_tag text,
    pt_dicom3_vr text,
    pt_dicom3_vm text,
    pt_dicom3_name text,
    pt_dicom3_keyword text,
    pt_dicom3_owner text,
    pt_dicom3_vers text,
    pt_dicom3_comment text,
    pt_dicom3_assumption text,
    pt_dicom3_private_block text
);


--
-- Name: pt_gdcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pt_gdcm (
    pt_gdcm_is_repeating boolean,
    pt_id integer,
    ptrg_id integer,
    pt_gdcm_signature text,
    pt_gdcm_vr text,
    pt_gdcm_vm text,
    pt_gdcm_name text
);


--
-- Name: pt_observation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pt_observation (
    pt_id integer NOT NULL,
    pt_obs_observer text,
    pt_obs_value text,
    pt_obs_comment text,
    pt_obs_time timestamp with time zone
);


--
-- Name: pt_pt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pt_pt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pt_pt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pt_pt_id_seq OWNED BY pt.pt_id;


--
-- Name: pt_wustl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pt_wustl (
    pt_id integer,
    pt_wustl_vr text,
    pt_wustl_vm text,
    pt_wustl_vm_second text,
    pt_wustl_name text,
    pt_wustl_name_second text,
    pt_wustl_disposition text,
    pt_wustl_disposition_second text,
    pt_wustl_is_specific_to_block boolean,
    pt_wustl_private_block text,
    pt_wustl_signature text,
    pt_wustl_device_sig text
);


--
-- Name: ptrg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ptrg (
    ptrg_id integer NOT NULL,
    ptrg_signature_masked text NOT NULL,
    ptrg_owner text NOT NULL,
    ptrg_base_grp integer NOT NULL,
    ptrg_grp_mask integer NOT NULL,
    ptrg_grp_ext_mask integer NOT NULL,
    ptrg_grp_ext_shift integer NOT NULL,
    ptrg_element text NOT NULL,
    ptrg_is_specific_to_block boolean,
    ptrg_specific_block text,
    ptrg_consensus_vr text,
    ptrg_consensus_vm text,
    ptrg_consensus_name text,
    ptrg_consensus_disposition text
);


--
-- Name: ptrg_observation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ptrg_observation (
    ptrg_id integer NOT NULL,
    ptrg_obs_observer text,
    ptrg_obs_value text,
    ptrg_obs_comment text,
    ptrg_obs_time timestamp with time zone
);


--
-- Name: ptrg_ptrg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ptrg_ptrg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ptrg_ptrg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ptrg_ptrg_id_seq OWNED BY ptrg.ptrg_id;


--
-- Name: pt_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pt ALTER COLUMN pt_id SET DEFAULT nextval('pt_pt_id_seq'::regclass);


--
-- Name: ptrg_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ptrg ALTER COLUMN ptrg_id SET DEFAULT nextval('ptrg_ptrg_id_seq'::regclass);


--
-- Name: pt_pt_signature_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pt
    ADD CONSTRAINT pt_pt_signature_key UNIQUE (pt_signature);


--
-- Name: ptrg_ptrg_signature_masked_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ptrg
    ADD CONSTRAINT ptrg_ptrg_signature_masked_key UNIQUE (ptrg_signature_masked);


--
-- PostgreSQL database dump complete
--

