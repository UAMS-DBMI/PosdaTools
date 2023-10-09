--
-- PostgreSQL database dump
--

-- Dumped from database version 13.7
-- Dumped by pg_dump version 14.9 (Ubuntu 14.9-0ubuntu0.22.04.1)

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
-- Name: posda_backlog; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE posda_backlog WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\connect posda_backlog

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
-- Name: collection_count_per_round; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_count_per_round (
    collection text NOT NULL,
    file_count integer NOT NULL
);


--
-- Name: control_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_status (
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
-- Name: request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request (
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
    size integer,
    posda_file_id integer
);


--
-- Name: request_error; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_error (
    request_id integer NOT NULL,
    error_time timestamp without time zone,
    error_description text
);


--
-- Name: request_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.request_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.request_request_id_seq OWNED BY public.request.request_id;


--
-- Name: round; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.round (
    round_id integer NOT NULL,
    round_start timestamp without time zone,
    round_end timestamp without time zone,
    round_created timestamp without time zone,
    round_aborted timestamp without time zone,
    wait_count integer,
    process_count integer
);


--
-- Name: round_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.round_collection (
    round_id integer NOT NULL,
    collection text NOT NULL,
    num_entered integer,
    num_failed integer,
    num_dups integer
);


--
-- Name: round_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.round_counts (
    round_id integer NOT NULL,
    collection text NOT NULL,
    num_requests integer,
    priority integer
);


--
-- Name: round_round_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.round_round_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: round_round_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.round_round_id_seq OWNED BY public.round.round_id;


--
-- Name: submitter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submitter (
    submitter_id integer NOT NULL,
    collection text NOT NULL,
    site text NOT NULL,
    subj text NOT NULL,
    priority integer
);


--
-- Name: submitter_submitter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submitter_submitter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submitter_submitter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submitter_submitter_id_seq OWNED BY public.submitter.submitter_id;


--
-- Name: request request_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request ALTER COLUMN request_id SET DEFAULT nextval('public.request_request_id_seq'::regclass);


--
-- Name: round round_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.round ALTER COLUMN round_id SET DEFAULT nextval('public.round_round_id_seq'::regclass);


--
-- Name: submitter submitter_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submitter ALTER COLUMN submitter_id SET DEFAULT nextval('public.submitter_submitter_id_seq'::regclass);


--
-- Name: collection_count_per_round collection_count_per_round_collection_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_count_per_round
    ADD CONSTRAINT collection_count_per_round_collection_key UNIQUE (collection);


--
-- Name: posda_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posda_file_id_index ON public.request USING btree (posda_file_id);


--
-- Name: request_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX request_lookup ON public.request USING btree (submitter_id, file_in_posda, file_copied, copy_error, import_error);


--
-- Name: submitter_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX submitter_lookup ON public.submitter USING btree (collection, site, subj);


--
-- PostgreSQL database dump complete
--

