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
-- Name: app_instance; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_instance (
    app_instance_id integer NOT NULL,
    started_at timestamp with time zone,
    pid integer
);


--
-- Name: app_instance_app_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE app_instance_app_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: app_instance_app_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE app_instance_app_instance_id_seq OWNED BY app_instance.app_instance_id;


--
-- Name: app_measurement; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_measurement (
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
-- Name: app_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_instance ALTER COLUMN app_instance_id SET DEFAULT nextval('app_instance_app_instance_id_seq'::regclass);


--
-- PostgreSQL database dump complete
--

