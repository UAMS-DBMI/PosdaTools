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

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: count_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE count_report (
    count_report_id integer NOT NULL,
    at timestamp with time zone
);


--
-- Name: count_report_count_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE count_report_count_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: count_report_count_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE count_report_count_report_id_seq OWNED BY count_report.count_report_id;


--
-- Name: totals_by_collection_site; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: count_report_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY count_report ALTER COLUMN count_report_id SET DEFAULT nextval('count_report_count_report_id_seq'::regclass);


--
-- PostgreSQL database dump complete
--

