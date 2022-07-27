--
-- PostgreSQL database dump
--

-- Dumped from database version 13.6
-- Dumped by pg_dump version 13.1 (Ubuntu 13.1-1.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: posda_appstats; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE posda_appstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\connect posda_appstats

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_instance (
    app_instance_id integer NOT NULL,
    started_at timestamp with time zone,
    pid integer
);


--
-- Name: app_instance_app_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_instance_app_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_instance_app_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_instance_app_instance_id_seq OWNED BY public.app_instance.app_instance_id;


--
-- Name: app_measurement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_measurement (
    app_instance_id integer NOT NULL,
    at timestamp with time zone,
    pcpu double precision,
    sz integer,
    vsz bigint,
    num_rcv_sessions integer,
    num_running_apps integer,
    files_in_db_backlog integer,
    dirs_in_receive_backlog integer,
    running_edits_extracts integer,
    queued_edits_extracts integer,
    running_sends integer,
    queued_sends integer,
    running_discards integer,
    num_locks integer,
    num_sessions integer,
    total_transactions integer,
    avg_import_time integer
);


--
-- Name: app_instance app_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_instance ALTER COLUMN app_instance_id SET DEFAULT nextval('public.app_instance_app_instance_id_seq'::regclass);


--
-- PostgreSQL database dump complete
--

