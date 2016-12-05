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
-- Name: collection_count_per_round; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_count_per_round (
    collection text NOT NULL,
    file_count integer NOT NULL
);


--
-- Name: control_status; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE control_status (
    status text NOT NULL,
    processor_pid text,
    idle_poll_interval interval,
    last_service timestamp without time zone,
    pending_change_request text,
    source_pending_change_request text,
    request_time timestamp without time zone,
    num_files_per_round integer,
    target_queue_size integer
);


--
-- Name: request; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE request (
    request_id integer NOT NULL,
    submitter_id integer NOT NULL,
    received_file_path text,
    copied_file_path text,
    file_copied boolean,
    copy_error boolean,
    copy_path text,
    file_digest text,
    file_in_posda boolean,
    import_error boolean,
    time_received timestamp without time zone,
    time_copied timestamp without time zone,
    time_entered timestamp without time zone,
    size integer
);


--
-- Name: request_error; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE request_error (
    request_id integer NOT NULL,
    error_time timestamp without time zone,
    error_description text
);


--
-- Name: request_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: request_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_request_id_seq OWNED BY request.request_id;


--
-- Name: submitter; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE submitter (
    submitter_id integer NOT NULL,
    collection text NOT NULL,
    site text NOT NULL,
    subj text NOT NULL,
    priority integer
);


--
-- Name: submitter_submitter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE submitter_submitter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: submitter_submitter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE submitter_submitter_id_seq OWNED BY submitter.submitter_id;


--
-- Name: request_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request ALTER COLUMN request_id SET DEFAULT nextval('request_request_id_seq'::regclass);


--
-- Name: submitter_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY submitter ALTER COLUMN submitter_id SET DEFAULT nextval('submitter_submitter_id_seq'::regclass);


--
-- Name: collection_count_per_round_collection_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_count_per_round
    ADD CONSTRAINT collection_count_per_round_collection_key UNIQUE (collection);


--
-- Name: request_lookup; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX request_lookup ON request USING btree (submitter_id, file_in_posda, file_copied, copy_error, import_error);


--
-- Name: submitter_lookup; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX submitter_lookup ON submitter USING btree (collection, site, subj);


--
-- PostgreSQL database dump complete
--

