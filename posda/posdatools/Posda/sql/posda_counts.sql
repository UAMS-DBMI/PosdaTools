--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.6 (Ubuntu 10.6-0ubuntu0.18.04.1)

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: count_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.count_report (
    count_report_id integer NOT NULL,
    at timestamp with time zone
);


--
-- Name: count_report_count_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.count_report_count_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: count_report_count_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.count_report_count_report_id_seq OWNED BY public.count_report.count_report_id;


--
-- Name: totals_by_collection_site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.totals_by_collection_site (
    count_report_id integer NOT NULL,
    collection_name text,
    site_name text,
    num_subjects integer,
    num_studies integer,
    num_series integer,
    num_sops integer
);


--
-- Name: count_report count_report_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.count_report ALTER COLUMN count_report_id SET DEFAULT nextval('public.count_report_count_report_id_seq'::regclass);


--
-- PostgreSQL database dump complete
--

