--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: dciodvfy_error; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dciodvfy_error (
    dciodvfy_error_id integer NOT NULL,
    error_type text NOT NULL,
    error_tag text,
    error_value text,
    error_subtype text,
    error_module text,
    error_reason text,
    error_index text,
    error_text text
);


--
-- Name: dciodvfy_error_dciodvfy_error_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dciodvfy_error_dciodvfy_error_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dciodvfy_error_dciodvfy_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dciodvfy_error_dciodvfy_error_id_seq OWNED BY dciodvfy_error.dciodvfy_error_id;


--
-- Name: dciodvfy_scan_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dciodvfy_scan_instance (
    dciodvfy_scan_instance_id integer NOT NULL,
    type_of_unit text,
    description_of_scan text,
    number_units integer,
    scanned_so_far integer,
    start_time timestamp with time zone,
    end_time timestamp with time zone
);


--
-- Name: dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq OWNED BY dciodvfy_scan_instance.dciodvfy_scan_instance_id;


--
-- Name: dciodvfy_unit_scan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dciodvfy_unit_scan (
    dciodvfy_unit_scan_id integer NOT NULL,
    type_of_unit text,
    unit_uid text,
    unit_id integer,
    num_file_in_unit integer,
    num_errors_in_unit integer,
    num_warnings_in_unit integer,
    start_time timestamp with time zone,
    end_time timestamp with time zone
);


--
-- Name: dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq OWNED BY dciodvfy_unit_scan.dciodvfy_unit_scan_id;


--
-- Name: dciodvfy_unit_scan_error; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dciodvfy_unit_scan_error (
    dciodvfy_scan_instance_id integer NOT NULL,
    dciodvfy_unit_scan_id integer NOT NULL,
    dciodvfy_error_id integer NOT NULL
);


--
-- Name: dciodvfy_unit_scan_warning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dciodvfy_unit_scan_warning (
    dciodvfy_scan_instance_id integer NOT NULL,
    dciodvfy_unit_scan_id integer NOT NULL,
    dciodvfy_warning_id integer NOT NULL
);


--
-- Name: dciodvfy_warning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dciodvfy_warning (
    dciodvfy_warning_id integer NOT NULL,
    warning_type text NOT NULL,
    warning_tag text,
    warning_desc text,
    warning_iod text,
    warning_comment text,
    warning_value text,
    warning_reason text,
    warning_index text,
    warning_text text
);


--
-- Name: dciodvfy_warning_dciodvfy_warning_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dciodvfy_warning_dciodvfy_warning_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dciodvfy_warning_dciodvfy_warning_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dciodvfy_warning_dciodvfy_warning_id_seq OWNED BY dciodvfy_warning.dciodvfy_warning_id;


--
-- Name: element_disposition_changed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE element_disposition_changed (
    element_seen_id integer NOT NULL,
    when_changed timestamp with time zone,
    who_changed text,
    why_changed text,
    new_disposition text
);


--
-- Name: element_seen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE element_seen (
    element_seen_id integer NOT NULL,
    element_sig_pattern text,
    vr text,
    is_private boolean,
    tag_name text,
    private_disposition text
);


--
-- Name: element_seen_element_seen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE element_seen_element_seen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: element_seen_element_seen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE element_seen_element_seen_id_seq OWNED BY element_seen.element_seen_id;


--
-- Name: element_value_occurance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE element_value_occurance (
    element_seen_id integer NOT NULL,
    value_seen_id integer NOT NULL,
    series_scan_instance_id integer NOT NULL,
    phi_scan_instance_id integer NOT NULL
);


--
-- Name: phi_scan_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE phi_scan_instance (
    phi_scan_instance_id integer NOT NULL,
    description text NOT NULL,
    start_time timestamp with time zone,
    num_series integer,
    num_series_scanned integer,
    end_time timestamp with time zone,
    file_query text
);


--
-- Name: phi_scan_instance_phi_scan_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE phi_scan_instance_phi_scan_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phi_scan_instance_phi_scan_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phi_scan_instance_phi_scan_instance_id_seq OWNED BY phi_scan_instance.phi_scan_instance_id;


--
-- Name: series_scan_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE series_scan_instance (
    series_scan_instance_id integer NOT NULL,
    scan_instance_id integer NOT NULL,
    series_instance_uid text NOT NULL,
    num_files integer,
    start_time timestamp with time zone,
    end_time timestamp with time zone
);


--
-- Name: series_scan_instance_series_scan_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE series_scan_instance_series_scan_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_scan_instance_series_scan_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE series_scan_instance_series_scan_instance_id_seq OWNED BY series_scan_instance.series_scan_instance_id;


--
-- Name: value_seen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE value_seen (
    value_seen_id integer NOT NULL,
    value text NOT NULL
);


--
-- Name: value_seen_value_seen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE value_seen_value_seen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: value_seen_value_seen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE value_seen_value_seen_id_seq OWNED BY value_seen.value_seen_id;


--
-- Name: dciodvfy_error dciodvfy_error_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dciodvfy_error ALTER COLUMN dciodvfy_error_id SET DEFAULT nextval('dciodvfy_error_dciodvfy_error_id_seq'::regclass);


--
-- Name: dciodvfy_scan_instance dciodvfy_scan_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dciodvfy_scan_instance ALTER COLUMN dciodvfy_scan_instance_id SET DEFAULT nextval('dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq'::regclass);


--
-- Name: dciodvfy_unit_scan dciodvfy_unit_scan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dciodvfy_unit_scan ALTER COLUMN dciodvfy_unit_scan_id SET DEFAULT nextval('dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq'::regclass);


--
-- Name: dciodvfy_warning dciodvfy_warning_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dciodvfy_warning ALTER COLUMN dciodvfy_warning_id SET DEFAULT nextval('dciodvfy_warning_dciodvfy_warning_id_seq'::regclass);


--
-- Name: element_seen element_seen_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY element_seen ALTER COLUMN element_seen_id SET DEFAULT nextval('element_seen_element_seen_id_seq'::regclass);


--
-- Name: phi_scan_instance phi_scan_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY phi_scan_instance ALTER COLUMN phi_scan_instance_id SET DEFAULT nextval('phi_scan_instance_phi_scan_instance_id_seq'::regclass);


--
-- Name: series_scan_instance series_scan_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_scan_instance ALTER COLUMN series_scan_instance_id SET DEFAULT nextval('series_scan_instance_series_scan_instance_id_seq'::regclass);


--
-- Name: value_seen value_seen_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY value_seen ALTER COLUMN value_seen_id SET DEFAULT nextval('value_seen_value_seen_id_seq'::regclass);


--
-- Name: value_seen value_seen_value_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY value_seen
    ADD CONSTRAINT value_seen_value_key UNIQUE (value);


--
-- Name: element_seen_and_value_seen_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX element_seen_and_value_seen_index ON element_value_occurance USING btree (element_seen_id, value_seen_id);


--
-- Name: element_seen_vr_pair_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX element_seen_vr_pair_index ON element_seen USING btree (element_sig_pattern, vr);


--
-- PostgreSQL database dump complete
--

