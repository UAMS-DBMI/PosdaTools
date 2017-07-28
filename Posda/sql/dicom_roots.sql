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
-- Name: collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE collection (
    collection_id integer NOT NULL,
    collection_code text
);


--
-- Name: collection_collection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collection_collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_collection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collection_collection_id_seq OWNED BY collection.collection_id;


--
-- Name: site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE site (
    site_id integer NOT NULL,
    site_code text
);


--
-- Name: site_site_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE site_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE site_site_id_seq OWNED BY site.site_id;


--
-- Name: submission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE submission (
    submission_id integer NOT NULL,
    collection_id integer NOT NULL,
    site_id integer NOT NULL,
    collection_name text,
    site_name text,
    body_part_entered text,
    patient_id_prefix text,
    access_type text,
    date_inc text,
    extra text
);


--
-- Name: submission_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE submission_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE submission_submission_id_seq OWNED BY submission.submission_id;


--
-- Name: submissionevent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE submissionevent (
    submission_id integer NOT NULL,
    event_type text,
    occurance_date_time timestamp with time zone,
    reporting_user text,
    comment text
);


--
-- Name: collection_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection ALTER COLUMN collection_id SET DEFAULT nextval('collection_collection_id_seq'::regclass);


--
-- Name: site_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY site ALTER COLUMN site_id SET DEFAULT nextval('site_site_id_seq'::regclass);


--
-- Name: submission_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission ALTER COLUMN submission_id SET DEFAULT nextval('submission_submission_id_seq'::regclass);


--
-- Name: collection_collection_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection
    ADD CONSTRAINT collection_collection_code_key UNIQUE (collection_code);


--
-- Name: site_site_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY site
    ADD CONSTRAINT site_site_code_key UNIQUE (site_code);


--
-- PostgreSQL database dump complete
--

