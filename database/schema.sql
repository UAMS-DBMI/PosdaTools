CREATE DATABASE dicom_dd WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';

\connect dicom_dd

create table dicom_element(
  tag text unique,
  name text,
  keyword text unique,
  vr text,
  vm text,
  is_retired boolean,
  comments text
);
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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
-- Name: dicom_roots; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE dicom_roots WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect dicom_roots

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
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


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
-- Name: version; Type: TABLE; Schema: db_version; Owner: -
--

CREATE TABLE db_version.version (
    version integer
);


--
-- Name: collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection (
    collection_id integer NOT NULL,
    collection_code text
);


--
-- Name: collection_collection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_collection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_collection_id_seq OWNED BY public.collection.collection_id;


--
-- Name: site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site (
    site_id integer NOT NULL,
    site_code text
);


--
-- Name: site_site_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_site_id_seq OWNED BY public.site.site_id;


--
-- Name: submission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission (
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

CREATE SEQUENCE public.submission_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submission_submission_id_seq OWNED BY public.submission.submission_id;


--
-- Name: submissionevent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissionevent (
    submission_id integer NOT NULL,
    event_type text,
    occurance_date_time timestamp with time zone,
    reporting_user text,
    comment text
);


--
-- Name: collection collection_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection ALTER COLUMN collection_id SET DEFAULT nextval('public.collection_collection_id_seq'::regclass);


--
-- Name: site site_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site ALTER COLUMN site_id SET DEFAULT nextval('public.site_site_id_seq'::regclass);


--
-- Name: submission submission_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission ALTER COLUMN submission_id SET DEFAULT nextval('public.submission_submission_id_seq'::regclass);


--
-- Name: collection collection_collection_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_collection_code_key UNIQUE (collection_code);


--
-- Name: site site_site_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_site_code_key UNIQUE (site_code);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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

CREATE DATABASE posda_appstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


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

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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
-- Name: posda_auth; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE posda_auth WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect posda_auth

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
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


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
-- Name: version; Type: TABLE; Schema: db_version; Owner: -
--

CREATE TABLE db_version.version (
    version integer
);


--
-- Name: apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apps (
    app_id integer NOT NULL,
    app_name text NOT NULL
);


--
-- Name: apps_app_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apps_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apps_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apps_app_id_seq OWNED BY public.apps.app_id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    permission_id integer NOT NULL,
    app_id integer,
    permission_name text NOT NULL
);


--
-- Name: permissions_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_permission_id_seq OWNED BY public.permissions.permission_id;


--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_permissions (
    user_id integer,
    permission_id integer
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    user_name text NOT NULL,
    full_name text NOT NULL,
    password text
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: apps app_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apps ALTER COLUMN app_id SET DEFAULT nextval('public.apps_app_id_seq'::regclass);


--
-- Name: permissions permission_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN permission_id SET DEFAULT nextval('public.permissions_permission_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: apps apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (app_id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (permission_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_user_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_name_key UNIQUE (user_name);


--
-- Name: permissions permissions_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(app_id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(permission_id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

COPY public.apps (app_id, app_name) FROM stdin;
1	UserAdmin
2	PosdaCuration
3	PhiFixer
4	ReviewPhi
5	SubmissionSender
6	CountGetter
7	FileDist
8	DicomProxy
9	DicomProxyAnalysis
10	DbIf
11	Kaleidoscope
12	NewItcTools
\.

SELECT pg_catalog.setval('public.apps_app_id_seq', 12, true);

COPY public.permissions (permission_id, app_id, permission_name) FROM stdin;
1	1	launch
2	2	launch
3	3	launch
4	4	launch
5	5	launch
6	6	launch
7	7	launch
8	8	launch
9	9	launch
10	10	launch
11	1	debug
12	2	debug
13	3	debug
14	4	debug
15	5	debug
16	6	debug
17	7	debug
18	8	debug
19	9	debug
20	10	debug
22	11	launch
23	11	debug
38	10	superuser
44	12	debug
45	12	launch
46	10	curator
47	10	workflow_1
48	10	legacy_bbennett
\.

SELECT pg_catalog.setval('public.permissions_permission_id_seq', 49, true);

COPY public.users (user_id, user_name, full_name, password) FROM stdin;
1	admin	Default Admin Account	aJE5lY8D,2wUueoiymAn8HsfbdAp0kPfTiODV7kpeNUttYTgQGbE
\.

SELECT pg_catalog.setval('public.users_user_id_seq', 2, true);

COPY public.user_permissions (user_id, permission_id) FROM stdin;
1	20
1	1
1	11
1	10
1	22
1	23
1	48
1	47
1	46
\.
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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

CREATE DATABASE posda_backlog WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


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

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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
-- Name: posda_counts; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE posda_counts WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect posda_counts

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

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 11.2

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
-- Name: posda_files; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE posda_files WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect posda_files

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
-- Name: posda_files; Type: DATABASE PROPERTIES; Schema: -; Owner: -
--

ALTER DATABASE posda_files SET search_path TO 'public', 'dbif_config', 'dicom_conv';


\connect posda_files

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
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


--
-- Name: dbif_config; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA dbif_config;


--
-- Name: dicom_conv; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA dicom_conv;


--
-- Name: quasar; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA quasar;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: version; Type: TABLE; Schema: db_version; Owner: -
--

CREATE TABLE db_version.version (
    version integer
);


--
-- Name: background_buttons; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.background_buttons (
    background_button_id integer NOT NULL,
    operation_name text,
    object_class text,
    button_text text,
    tags text[]
);


--
-- Name: background_buttons_background_button_id_seq; Type: SEQUENCE; Schema: dbif_config; Owner: -
--

CREATE SEQUENCE dbif_config.background_buttons_background_button_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: background_buttons_background_button_id_seq; Type: SEQUENCE OWNED BY; Schema: dbif_config; Owner: -
--

ALTER SEQUENCE dbif_config.background_buttons_background_button_id_seq OWNED BY dbif_config.background_buttons.background_button_id;


--
-- Name: chained_query; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.chained_query (
    chained_query_id integer NOT NULL,
    from_query text NOT NULL,
    to_query text NOT NULL,
    caption text
);


--
-- Name: chained_query_chained_query_id_seq; Type: SEQUENCE; Schema: dbif_config; Owner: -
--

CREATE SEQUENCE dbif_config.chained_query_chained_query_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chained_query_chained_query_id_seq; Type: SEQUENCE OWNED BY; Schema: dbif_config; Owner: -
--

ALTER SEQUENCE dbif_config.chained_query_chained_query_id_seq OWNED BY dbif_config.chained_query.chained_query_id;


--
-- Name: chained_query_cols_to_params; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.chained_query_cols_to_params (
    chained_query_id integer NOT NULL,
    from_column_name text NOT NULL,
    to_parameter_name text NOT NULL
);


--
-- Name: popup_buttons; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.popup_buttons (
    popup_button_id integer NOT NULL,
    name text,
    object_class text,
    btn_col text,
    is_full_table boolean,
    btn_name text
);


--
-- Name: popup_buttons_popup_button_id_seq1; Type: SEQUENCE; Schema: dbif_config; Owner: -
--

CREATE SEQUENCE dbif_config.popup_buttons_popup_button_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: popup_buttons_popup_button_id_seq1; Type: SEQUENCE OWNED BY; Schema: dbif_config; Owner: -
--

ALTER SEQUENCE dbif_config.popup_buttons_popup_button_id_seq1 OWNED BY dbif_config.popup_buttons.popup_button_id;


--
-- Name: queries; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.queries (
    name text,
    query text,
    args text[],
    columns text[],
    tags text[],
    schema text,
    description text
);


--
-- Name: query_tabs; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.query_tabs (
    query_tab_name text,
    query_tab_description text,
    defines_dropdown boolean,
    sort_order integer,
    defines_search_engine boolean
);


--
-- Name: query_tabs_query_tag_filter; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.query_tabs_query_tag_filter (
    query_tab_name text NOT NULL,
    filter_name text NOT NULL,
    sort_order integer NOT NULL
);


--
-- Name: query_tag_filter; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.query_tag_filter (
    filter_name text,
    tags_enabled text[]
);


--
-- Name: role; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.role (
    role_name text NOT NULL
);


--
-- Name: role_tabs; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.role_tabs (
    role_name text,
    query_tab_name text,
    sort_order integer
);


--
-- Name: spreadsheet_operation; Type: TABLE; Schema: dbif_config; Owner: -
--

CREATE TABLE dbif_config.spreadsheet_operation (
    operation_name text NOT NULL,
    command_line text,
    operation_type text,
    input_line_format text,
    tags text[],
    can_chain boolean
);


--
-- Name: dicom_module_to_posda_table; Type: TABLE; Schema: dicom_conv; Owner: -
--

CREATE TABLE dicom_conv.dicom_module_to_posda_table (
    dicom_module_name text,
    create_row_query text,
    table_name text
);


--
-- Name: dicom_tag_parm_column_table; Type: TABLE; Schema: dicom_conv; Owner: -
--

CREATE TABLE dicom_conv.dicom_tag_parm_column_table (
    tag text,
    tag_cannonical_name text,
    posda_table_name text,
    column_name text
);


--
-- Name: tag_preparation; Type: TABLE; Schema: dicom_conv; Owner: -
--

CREATE TABLE dicom_conv.tag_preparation (
    tag_cannonical_name text,
    preparation_description text
);


--
-- Name: activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity (
    activity_id integer NOT NULL,
    brief_description text,
    when_created timestamp with time zone,
    who_created text,
    when_closed timestamp with time zone
);


--
-- Name: activity_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_activity_id_seq OWNED BY public.activity.activity_id;


--
-- Name: activity_inbox_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_inbox_content (
    activity_id integer NOT NULL,
    user_inbox_content_id integer NOT NULL
);


--
-- Name: activity_posda_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_posda_file (
    activity_id integer NOT NULL,
    file_id_in_posda integer NOT NULL,
    association_description text
);


--
-- Name: activity_task_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_task_status (
    activity_id integer NOT NULL,
    subprocess_invocation_id integer NOT NULL,
    status_text text,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    last_updated timestamp without time zone,
    expected_remaining_time interval,
    dismissed_time timestamp without time zone,
    dismissed_by text
);


--
-- Name: activity_timepoint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_timepoint (
    activity_timepoint_id integer NOT NULL,
    activity_id integer NOT NULL,
    when_created timestamp without time zone,
    who_created text,
    comment text,
    creating_user text
);


--
-- Name: activity_timepoint_activity_timepoint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_timepoint_activity_timepoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_timepoint_activity_timepoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_timepoint_activity_timepoint_id_seq OWNED BY public.activity_timepoint.activity_timepoint_id;


--
-- Name: activity_timepoint_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_timepoint_file (
    activity_timepoint_id integer NOT NULL,
    file_id integer NOT NULL
);


--
-- Name: adverse_file_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adverse_file_event (
    adverse_file_event_id integer NOT NULL,
    file_id integer NOT NULL,
    event_description text,
    when_occured timestamp with time zone
);


--
-- Name: adverse_file_event_adverse_file_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.adverse_file_event_adverse_file_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: adverse_file_event_adverse_file_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.adverse_file_event_adverse_file_event_id_seq OWNED BY public.adverse_file_event.adverse_file_event_id;


--
-- Name: association; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.association (
    association_id integer NOT NULL,
    called_ae_title text,
    calling_ae_title text,
    start_time timestamp with time zone,
    duration integer,
    originating_ip_addr text,
    processing text,
    session_info_file text
);


--
-- Name: association_association_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.association_association_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: association_association_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.association_association_id_seq OWNED BY public.association.association_id;


--
-- Name: association_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.association_errors (
    association_id integer NOT NULL,
    error_type text,
    error_line text
);


--
-- Name: association_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.association_file (
    association_id integer NOT NULL,
    file_id integer NOT NULL,
    file_path text NOT NULL,
    assoc_sop_class text NOT NULL,
    assoc_sop_inst text NOT NULL,
    assoc_xfr_stx text NOT NULL,
    assoc_path text NOT NULL
);


--
-- Name: association_import; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.association_import (
    association_id integer NOT NULL,
    import_event_id integer NOT NULL
);


--
-- Name: association_pc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.association_pc (
    association_pc_id integer NOT NULL,
    association_id integer NOT NULL,
    abstract_syntax_uid text,
    accepted boolean NOT NULL,
    not_accepted_reason integer,
    accepted_ts text
);


--
-- Name: association_pc_association_pc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.association_pc_association_pc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: association_pc_association_pc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.association_pc_association_pc_id_seq OWNED BY public.association_pc.association_pc_id;


--
-- Name: association_pc_proposed_ts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.association_pc_proposed_ts (
    association_pc_id integer NOT NULL,
    proposed_ts_uid text NOT NULL
);


--
-- Name: background_input_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_input_line (
    background_subprocess_id integer NOT NULL,
    line_number integer,
    line text
);


--
-- Name: background_subprocess; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_subprocess (
    background_subprocess_id integer NOT NULL,
    subprocess_invocation_id integer,
    input_rows_processed integer,
    command_executed text,
    foreground_pid integer,
    background_pid integer,
    when_script_started timestamp with time zone,
    when_background_entered timestamp with time zone,
    when_script_ended timestamp with time zone,
    user_to_notify text,
    process_error text,
    crash text,
    crash_date timestamp without time zone
);


--
-- Name: COLUMN background_subprocess.crash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_subprocess.crash IS 'Text stored if the subprocess crashes';


--
-- Name: background_subprocess_background_subprocess_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.background_subprocess_background_subprocess_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: background_subprocess_background_subprocess_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.background_subprocess_background_subprocess_id_seq OWNED BY public.background_subprocess.background_subprocess_id;


--
-- Name: background_subprocess_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_subprocess_params (
    background_subprocess_id integer NOT NULL,
    param_index integer,
    param_value text
);


--
-- Name: background_subprocess_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_subprocess_report (
    background_subprocess_report_id integer NOT NULL,
    background_subprocess_id integer,
    file_id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: background_subprocess_report_background_subprocess_report_i_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.background_subprocess_report_background_subprocess_report_i_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: background_subprocess_report_background_subprocess_report_i_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.background_subprocess_report_background_subprocess_report_i_seq OWNED BY public.background_subprocess_report.background_subprocess_report_id;


--
-- Name: beam_applicator; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beam_applicator (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    applicator_id text NOT NULL,
    applicator_accessory_code text,
    applicator_type text,
    applicator_description text
);


--
-- Name: beam_block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beam_block (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    block_number integer NOT NULL,
    block_tray_id text,
    block_accessory_code text,
    source_to_block_tray_distance text,
    block_type text,
    block_divergence text,
    block_mounting_position text,
    block_name text,
    material_id text,
    block_thickness text,
    block_transmission text,
    block_number_of_points integer,
    block_data text
);


--
-- Name: beam_bolus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beam_bolus (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    referenced_roi_number integer NOT NULL,
    bolus_id text,
    bolus_accessory_code text,
    bolus_description text
);


--
-- Name: beam_compensator; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beam_compensator (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    compensator_number integer NOT NULL,
    compensator_type text,
    compensator_description text,
    material_id text,
    compensator_id text,
    compensator_accessory_code text,
    source_to_compensator_tray_distance text,
    compensator_divergence text,
    compensator_mounting_position text,
    compensator_rows text,
    compensator_cols text,
    compensator_pixel_spacing text,
    compensator_position text,
    compensator_transmission_data text,
    compensator_thickness_data text,
    source_to_compensator_distance text
);


--
-- Name: beam_control_point; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beam_control_point (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    cumulative_meterset_weight text,
    nominal_beam_energy text,
    dose_rate_set text,
    gantry_angle text,
    gantry_rotation_direction text,
    gantry_pitch_angle text,
    gantry_pitch_rotation_direction text,
    beam_limiting_device_angle text,
    beam_limiting_device_rotation_direction text,
    patient_support_angle text,
    patient_support_rotation_direction text,
    table_top_eccentric_axis_distance text,
    table_top_eccentric_angle text,
    table_top_eccentric_rotation_direction text,
    table_top_pitch_angle text,
    table_top_pitch_rotation_direction text,
    table_top_roll_angle text,
    table_top_roll_rotation_direction text,
    table_top_vertical_position text,
    table_top_longitudinal_position text,
    table_top_lateral_position text,
    isocenter_position text,
    surface_entry_point text,
    source_to_surface_distance text
);


--
-- Name: beam_general_accessory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beam_general_accessory (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    general_accessory_number integer NOT NULL,
    general_accessory_id text NOT NULL,
    general_accessory_description text,
    general_accessory_type text,
    general_accessory_code text
);


--
-- Name: beam_limiting_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beam_limiting_device (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    bld_type text NOT NULL,
    source_to_bld_distance text,
    number_of_leaf_jaw_pairs integer NOT NULL,
    leaf_position_boundries text
);


--
-- Name: beam_wedge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beam_wedge (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    wedge_number integer NOT NULL,
    wedge_type text,
    wedge_id text,
    wedge_accessory_code text,
    wedge_angle text,
    wedge_factor text,
    wedge_orientation text,
    source_to_wedge_tray_distance text
);


--
-- Name: clinical_trial_qualified_patient_id; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clinical_trial_qualified_patient_id (
    collection text,
    site text,
    patient_id text,
    qualified boolean
);


--
-- Name: collection_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_codes (
    collection_name text NOT NULL,
    collection_code text NOT NULL
);


--
-- Name: compare_public_to_posda_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compare_public_to_posda_instance (
    compare_public_to_posda_instance_id integer NOT NULL,
    when_compare_started timestamp without time zone,
    when_compare_completed timestamp without time zone,
    status_of_compare text,
    number_of_sops integer,
    number_compares_completed integer,
    num_failed integer,
    last_updated timestamp without time zone
);


--
-- Name: compare_public_to_posda_insta_compare_public_to_posda_insta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.compare_public_to_posda_insta_compare_public_to_posda_insta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: compare_public_to_posda_insta_compare_public_to_posda_insta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.compare_public_to_posda_insta_compare_public_to_posda_insta_seq OWNED BY public.compare_public_to_posda_instance.compare_public_to_posda_instance_id;


--
-- Name: contour_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contour_image (
    roi_contour_id integer NOT NULL,
    sop_class text NOT NULL,
    sop_instance text NOT NULL,
    frame_number integer
);


--
-- Name: control_point_bld_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_point_bld_position (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    bld_type text NOT NULL,
    leaf_jaw_positions text NOT NULL
);


--
-- Name: control_point_dose_reference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_point_dose_reference (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);


--
-- Name: control_point_reference_dose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_point_reference_dose (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    referenced_dose_reference_number integer NOT NULL,
    cumulative_dose_ref_coefficent text
);


--
-- Name: control_point_wedge_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_point_wedge_position (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    wedge_number integer NOT NULL,
    wedge_position text NOT NULL
);


--
-- Name: conversion_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversion_event (
    conversion_event_id integer NOT NULL,
    time_of_conversion timestamp with time zone,
    who_invoked_conversion text,
    conversion_program text
);


--
-- Name: conversion_event_conversion_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conversion_event_conversion_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversion_event_conversion_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conversion_event_conversion_event_id_seq OWNED BY public.conversion_event.conversion_event_id;


--
-- Name: copy_from_public; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.copy_from_public (
    copy_from_public_id integer NOT NULL,
    when_row_created timestamp without time zone,
    who text,
    why text,
    when_file_rows_populated timestamp without time zone,
    num_file_rows_populated integer,
    status_of_copy text,
    pid_of_running_process integer
);


--
-- Name: copy_from_public_copy_from_public_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.copy_from_public_copy_from_public_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: copy_from_public_copy_from_public_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.copy_from_public_copy_from_public_id_seq OWNED BY public.copy_from_public.copy_from_public_id;


--
-- Name: ctp_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ctp_file (
    file_id integer NOT NULL,
    project_name text,
    trial_name text,
    site_name text,
    site_id text,
    visibility text,
    file_visibility text,
    batch text,
    study_year text
);


--
-- Name: ctp_file_new; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ctp_file_new (
    file_id integer NOT NULL,
    project_name text,
    trial_name text,
    site_name text,
    site_id text,
    visibility text
);


--
-- Name: ctp_filex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ctp_filex (
    file_id integer,
    project_name text,
    trial_name text,
    site_name text,
    site_id text,
    visibility text
);


--
-- Name: ctp_manifest_row; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ctp_manifest_row (
    file_id integer NOT NULL,
    cm_index integer,
    cm_collection text,
    cm_site text,
    cm_patient_id text,
    cm_study_date text,
    cm_series_instance_uid text,
    cm_study_description text,
    cm_series_description text,
    cm_modality text,
    cm_num_files integer
);


--
-- Name: ctp_upload_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ctp_upload_event (
    file_id integer NOT NULL,
    rcv_timestamp timestamp with time zone NOT NULL
);


--
-- Name: dbif_query_args; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dbif_query_args (
    query_invoked_by_dbif_id integer NOT NULL,
    arg_index integer,
    arg_name text,
    arg_value text
);


--
-- Name: dicom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom (
    file_id integer NOT NULL,
    dataset_digest text,
    xfr_stx text,
    has_meta boolean,
    is_dicom_dir boolean,
    has_sop_common boolean,
    dicom_file_type text,
    has_pixel_data boolean,
    pixel_data_digest text,
    pixel_data_offset integer,
    pixel_data_length integer,
    has_no_roi_linkages boolean,
    kvp text,
    scan_options text,
    data_collection_diameter text,
    reconstruction_diameter text,
    dist_source_to_detect text,
    dist_source_to_pat text,
    gantry_tilt text,
    table_height text,
    rotation_dir text,
    exposure_time text,
    xray_tube_current text,
    exposure text,
    filter_type text,
    generator_power text,
    convolution_kernal text,
    table_feed_per_rot text,
    manufacturer text,
    institution_name text,
    institution_addr text,
    station_name text,
    inst_dept_name text,
    manuf_model_name text,
    dev_serial_num text,
    software_versions text,
    spatial_resolution text,
    last_calib_date text,
    last_calib_time text,
    pixel_pad integer,
    for_uid text,
    position_ref_indicator text,
    file_meta integer,
    data_set_size integer,
    data_set_start integer,
    media_storage_sop_class text,
    media_storage_sop_instance text,
    xfer_syntax text,
    imp_class_uid text,
    imp_version_name text,
    source_ae_title text,
    private_info_uid text,
    private_info text,
    patient_name text,
    patient_id text,
    id_issuer text,
    dob date,
    sex text,
    time_ob time without time zone,
    other_ids text,
    other_names text,
    ethnic_group text,
    comments text,
    patient_age text,
    modality text,
    series_instance_uid text,
    series_number integer,
    laterality text,
    series_date date,
    series_time time without time zone,
    performing_phys text,
    protocol_name text,
    series_description text,
    body_part_examined text,
    patient_position text,
    smallest_pixel_value integer,
    largest_pixel_value integer,
    performed_procedure_step_id text,
    performed_procedure_step_start_date date,
    performed_procedure_step_start_time time without time zone,
    performed_procedure_step_desc text,
    performed_procedure_step_comments text,
    date_fixed boolean,
    sop_class_uid text,
    sop_instance_uid text,
    specific_character_set text,
    creation_date date,
    creation_time time without time zone,
    creator_uid text,
    related_general_sop_class text,
    original_specialized_sop_class text,
    offset_from_utc integer,
    instance_status text,
    auth_date_time time with time zone,
    auth_comment text,
    auth_cert_num text,
    structure_set_id integer,
    instance_number text,
    study_instance_uid text,
    study_date date,
    study_time time without time zone,
    referring_phy_name text,
    study_id text,
    accession_number text,
    study_description text,
    phys_of_record text,
    phys_reading text,
    admitting_diag text,
    rt_dose_id integer,
    rt_dose_units text,
    rt_dose_type text,
    rt_dose_instance_number text,
    rt_dose_comment text,
    rt_dose_normalization_point text,
    rt_dose_summation_type text,
    rt_dose_referenced_plan_class text,
    rt_dose_referenced_plan_uid text,
    rt_dose_tissue_heterogeneity text,
    rt_dose_grid_frame_offset_vector text,
    rt_dose_grid_scaling double precision,
    rt_dose_max_slice_spacing double precision,
    rt_dose_min_slice_spacing double precision,
    rt_dvh_id integer,
    plan_id integer,
    plan_label text,
    plan_name text,
    plan_description text,
    operators_name text,
    rt_plan_date date,
    rt_plan_time time without time zone,
    rt_treatment_protocols text,
    plan_intent text,
    treatment_sites text,
    rt_plan_geometry text,
    ss_referenced_from_plan text,
    patient_setup_num integer,
    sequence_index integer,
    respiratory_motion_comp_technique text,
    respiratory_signal_source text,
    respiratory_motion_com_tech_desc text,
    respiratory_signal_source_id text,
    rt_prescription_id integer,
    rt_prescription_description text,
    slope_intercept_id integer,
    slope text,
    intercept text,
    si_units text,
    slopef double precision,
    interceptf double precision,
    image_id integer,
    content_date date,
    content_time time without time zone,
    image_type text,
    samples_per_pixel integer,
    pixel_spacing text,
    photometric_interpretation text,
    pixel_rows integer,
    pixel_columns integer,
    bits_allocated integer,
    bits_stored integer,
    high_bit integer,
    pixel_representation integer,
    planar_configuration integer,
    number_of_frames integer,
    unique_pixel_data_id integer,
    row_spacing double precision,
    col_spacing double precision,
    image_geometry_id integer,
    iop text,
    ipp text,
    normalized_iop text,
    iop_error text,
    row_x double precision,
    row_y double precision,
    row_z double precision,
    col_x double precision,
    col_y double precision,
    col_z double precision,
    pos_x double precision,
    pos_y double precision,
    pos_z double precision,
    source_id bigint,
    hidden boolean
);


--
-- Name: dicom_dir; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_dir (
    file_id integer NOT NULL,
    fs_id text,
    fs_desc text,
    spec_char_set_of_desc text
);


--
-- Name: dicom_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    is_root boolean,
    is_active boolean,
    child_of integer,
    offset_in_file integer,
    length_in_file integer,
    rec_type text
);


--
-- Name: dicom_dir_rec_dicom_dir_rec_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dicom_dir_rec_dicom_dir_rec_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dicom_dir_rec_dicom_dir_rec_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dicom_dir_rec_dicom_dir_rec_id_seq OWNED BY public.dicom_dir_rec.dicom_dir_rec_id;


--
-- Name: dicom_edit_compare; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_edit_compare (
    from_file_digest text NOT NULL,
    to_file_digest text NOT NULL,
    short_report_file_id integer NOT NULL,
    long_report_file_id integer NOT NULL,
    to_file_path text,
    subprocess_invocation_id integer NOT NULL
);


--
-- Name: dicom_edit_compare_disposition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_edit_compare_disposition (
    subprocess_invocation_id integer NOT NULL,
    start_creation_time timestamp without time zone,
    end_creation_time timestamp without time zone,
    number_edits_scheduled integer,
    number_compares_with_diffs integer,
    number_compares_without_diffs integer,
    current_disposition text,
    process_pid text,
    last_updated timestamp without time zone,
    dest_dir text
);


--
-- Name: dicom_edit_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_edit_event (
    dicom_edit_event_id integer NOT NULL,
    edit_desc_file integer,
    time_started timestamp with time zone,
    time_completed timestamp with time zone,
    report_file integer,
    notification_sent text,
    num_files integer,
    edits_done integer,
    process_id integer,
    edit_comment text
);


--
-- Name: dicom_edit_event_adverse_file_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_edit_event_adverse_file_event (
    dicom_edit_event_id integer NOT NULL,
    adverse_file_event_id integer NOT NULL
);


--
-- Name: dicom_edit_event_dicom_edit_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dicom_edit_event_dicom_edit_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dicom_edit_event_dicom_edit_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dicom_edit_event_dicom_edit_event_id_seq OWNED BY public.dicom_edit_event.dicom_edit_event_id;


--
-- Name: dicom_file; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.dicom_file AS
 SELECT dicom.file_id,
    dicom.dataset_digest,
    dicom.xfr_stx,
    dicom.has_meta,
    dicom.is_dicom_dir,
    dicom.has_sop_common,
    dicom.dicom_file_type,
    dicom.has_pixel_data,
    dicom.pixel_data_digest,
    dicom.pixel_data_offset,
    dicom.pixel_data_length,
    dicom.has_no_roi_linkages
   FROM public.dicom;


--
-- Name: dicom_file_edit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_file_edit (
    dicom_edit_event_id integer NOT NULL,
    from_file_digest text NOT NULL,
    to_file_digest text NOT NULL
);


--
-- Name: dicom_file_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_file_errors (
    file_id integer NOT NULL,
    error_msg text
);


--
-- Name: dicom_file_send; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_file_send (
    dicom_send_event_id integer NOT NULL,
    file_path text,
    status text,
    file_id_sent integer
);


--
-- Name: dicom_icon_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_icon_image (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    image_id integer NOT NULL
);


--
-- Name: dicom_image_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_image_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_image_spec_char_set text,
    instance_number integer
);


--
-- Name: dicom_patient_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_patient_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_patient_spec_char_set text,
    patients_name text,
    patient_id text
);


--
-- Name: dicom_process_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_process_errors (
    file_id integer NOT NULL,
    error_msg text
);


--
-- Name: dicom_rt_dose_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_rt_dose_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_rt_dose_spec_char_set text,
    instance_number integer,
    dose_summation_type text,
    dose_comment text
);


--
-- Name: dicom_rt_plan_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_rt_plan_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_rt_plan_spec_char_set text,
    instance_number integer,
    rt_plan_label text,
    rt_plan_date date,
    rt_plan_time time without time zone
);


--
-- Name: dicom_rt_structure_set_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_rt_structure_set_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_rt_structure_set_spec_char_set text,
    instance_number integer,
    structure_set_label text,
    structure_set_date date,
    structure_set_time time without time zone
);


--
-- Name: dicom_rt_treatment_rec_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_rt_treatment_rec_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_rt_treatment_rec_spec_char_set text,
    instance_number integer,
    rt_treatment_rec_date date,
    rt_treatment_rec_time time without time zone
);


--
-- Name: dicom_send_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_send_event (
    dicom_send_event_id integer NOT NULL,
    destination_host text NOT NULL,
    destination_port text NOT NULL,
    called_ae text NOT NULL,
    calling_ae text NOT NULL,
    send_started timestamp with time zone,
    send_ended timestamp with time zone,
    number_of_files integer,
    invoking_user text,
    reason_for_send text,
    is_series_send boolean,
    series_to_send text
);


--
-- Name: dicom_send_event_dicom_send_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dicom_send_event_dicom_send_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dicom_send_event_dicom_send_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dicom_send_event_dicom_send_event_id_seq OWNED BY public.dicom_send_event.dicom_send_event_id;


--
-- Name: dicom_series_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_series_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_series_spec_char_set text,
    modality text,
    series_instance_uid text,
    series_number text
);


--
-- Name: dicom_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_source (
    source_id bigint,
    site_name text,
    project_name text
);


--
-- Name: dicom_study_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_study_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_study_spec_char_set text,
    study_date date,
    study_time time without time zone,
    accession_number text,
    study_description text,
    study_instance_uid text,
    study_id text
);


--
-- Name: distinguished_pixel_digest_pixel_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.distinguished_pixel_digest_pixel_value (
    pixel_digest text NOT NULL,
    pixel_value integer NOT NULL,
    num_occurances integer NOT NULL
);


--
-- Name: distinguished_pixel_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.distinguished_pixel_digests (
    pixel_digest text NOT NULL,
    type_of_pixel_data text,
    sample_per_pixel integer,
    number_of_frames integer,
    pixel_rows integer,
    pixel_columns integer,
    bits_stored integer,
    bits_allocated integer,
    high_bit integer,
    pixel_mask integer,
    num_distinct_pixel_values integer
);


--
-- Name: dose_referenced_from_beam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dose_referenced_from_beam (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);


--
-- Name: dose_referenced_from_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dose_referenced_from_plan (
    plan_id integer NOT NULL,
    dose_sop_instance_uid text
);


--
-- Name: downloadable_dir; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.downloadable_dir (
    downloadable_dir_id integer NOT NULL,
    security_hash text NOT NULL,
    creation_date timestamp without time zone NOT NULL,
    path text NOT NULL
);


--
-- Name: downloadable_dir_downloadable_dir_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.downloadable_dir_downloadable_dir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloadable_dir_downloadable_dir_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.downloadable_dir_downloadable_dir_id_seq OWNED BY public.downloadable_dir.downloadable_dir_id;


--
-- Name: downloadable_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.downloadable_file (
    downloadable_file_id integer NOT NULL,
    file_id integer NOT NULL,
    security_hash text NOT NULL,
    creation_date timestamp without time zone DEFAULT now() NOT NULL,
    valid_until date,
    mime_type text
);


--
-- Name: downloadable_file_downloadable_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.downloadable_file_downloadable_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloadable_file_downloadable_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.downloadable_file_downloadable_file_id_seq OWNED BY public.downloadable_file.downloadable_file_id;


--
-- Name: file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file (
    file_id integer NOT NULL,
    digest text NOT NULL,
    size integer,
    is_dicom_file boolean,
    file_type text,
    processing_priority integer,
    ready_to_process boolean
);


--
-- Name: file_copy_from_public; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_copy_from_public (
    copy_from_public_id integer NOT NULL,
    sop_instance_uid text,
    replace_file_id integer,
    inserted_file_id integer,
    copy_file_path text
);


--
-- Name: file_ct_image; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_ct_image AS
 SELECT dicom.file_id,
    dicom.kvp,
    dicom.instance_number,
    dicom.scan_options,
    dicom.data_collection_diameter,
    dicom.reconstruction_diameter,
    dicom.dist_source_to_detect,
    dicom.dist_source_to_pat,
    dicom.gantry_tilt,
    dicom.table_height,
    dicom.rotation_dir,
    dicom.exposure_time,
    dicom.xray_tube_current,
    dicom.exposure,
    dicom.filter_type,
    dicom.generator_power,
    dicom.convolution_kernal,
    dicom.table_feed_per_rot
   FROM public.dicom;


--
-- Name: file_ct_image__old; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_ct_image__old (
    file_id integer NOT NULL,
    kvp text,
    instance_number text,
    scan_options text,
    data_collection_diameter text,
    reconstruction_diameter text,
    dist_source_to_detect text,
    dist_source_to_pat text,
    gantry_tilt text,
    table_height text,
    rotation_dir text,
    exposure_time text,
    xray_tube_current text,
    exposure text,
    filter_type text,
    generator_power text,
    convolution_kernal text,
    table_feed_per_rot text
);


--
-- Name: file_dose; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_dose AS
 SELECT dicom.rt_dose_id,
    dicom.file_id
   FROM public.dicom;


--
-- Name: file_ele_ref; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_ele_ref (
    file_ele_ref_id integer NOT NULL,
    file_id integer,
    ele_sig text
);


--
-- Name: file_ele_ref_file_ele_ref_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_ele_ref_file_ele_ref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_ele_ref_file_ele_ref_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_ele_ref_file_ele_ref_id_seq OWNED BY public.file_ele_ref.file_ele_ref_id;


--
-- Name: file_ele_ref_text_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_ele_ref_text_value (
    file_ele_ref_id integer NOT NULL,
    text_value text
);


--
-- Name: file_equipment; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_equipment AS
 SELECT dicom.file_id,
    dicom.manufacturer,
    dicom.institution_name,
    dicom.institution_addr,
    dicom.station_name,
    dicom.inst_dept_name,
    dicom.manuf_model_name,
    dicom.dev_serial_num,
    dicom.software_versions,
    dicom.spatial_resolution,
    dicom.last_calib_date,
    dicom.last_calib_time,
    dicom.pixel_pad
   FROM public.dicom;


--
-- Name: file_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_file_id_seq OWNED BY public.file.file_id;


--
-- Name: file_for; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_for AS
 SELECT dicom.file_id,
    dicom.for_uid,
    dicom.position_ref_indicator
   FROM public.dicom;


--
-- Name: file_image; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_image AS
 SELECT dicom.file_id,
    dicom.image_id,
    dicom.content_date,
    dicom.content_time
   FROM public.dicom;


--
-- Name: file_image_geometry; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_image_geometry AS
 SELECT dicom.file_id,
    dicom.image_geometry_id
   FROM public.dicom;


--
-- Name: file_import; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_import (
    import_event_id integer NOT NULL,
    file_id integer NOT NULL,
    rel_path text,
    rel_dir text,
    file_name text,
    file_import_time timestamp with time zone
);


--
-- Name: file_import_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_import_series (
    file_import_series_id integer NOT NULL,
    file_id integer NOT NULL,
    import_event_id integer NOT NULL,
    series_instance_uid text NOT NULL,
    modality text NOT NULL
);


--
-- Name: file_import_series_file_import_series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_import_series_file_import_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_import_series_file_import_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_import_series_file_import_series_id_seq OWNED BY public.file_import_series.file_import_series_id;


--
-- Name: file_import_study; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_import_study (
    file_import_study_id integer NOT NULL,
    file_id integer NOT NULL,
    import_event_id integer NOT NULL,
    study_instance_uid text NOT NULL
);


--
-- Name: file_import_study_file_import_study_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_import_study_file_import_study_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_import_study_file_import_study_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_import_study_file_import_study_id_seq OWNED BY public.file_import_study.file_import_study_id;


--
-- Name: import_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_event (
    import_event_id integer NOT NULL,
    import_type text,
    importing_user text,
    originating_ip_addr text,
    import_comment text,
    import_time timestamp with time zone,
    remote_file text,
    volume_name text,
    import_close_time timestamp with time zone,
    related_id_1 integer,
    related_id_2 integer
);


--
-- Name: file_imports_over_time; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.file_imports_over_time AS
 SELECT count(file.file_id) AS count,
    date_part('month'::text, import_event.import_time) AS importmonth,
    date_part('year'::text, import_event.import_time) AS importyear
   FROM ((public.file
     JOIN public.file_import USING (file_id))
     JOIN public.import_event USING (import_event_id))
  GROUP BY (date_part('year'::text, import_event.import_time)), (date_part('month'::text, import_event.import_time))
  WITH NO DATA;


--
-- Name: file_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_location (
    file_id integer NOT NULL,
    file_storage_root_id integer NOT NULL,
    rel_path text NOT NULL,
    is_home text,
    file_is_present boolean
);


--
-- Name: file_locationx; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_locationx (
    file_id integer,
    file_storage_root_id integer,
    rel_path text,
    is_home text
);


--
-- Name: file_meta; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_meta AS
 SELECT dicom.file_id,
    dicom.file_meta,
    dicom.data_set_size,
    dicom.data_set_start,
    dicom.media_storage_sop_class,
    dicom.media_storage_sop_instance,
    dicom.xfer_syntax,
    dicom.imp_class_uid,
    dicom.imp_version_name,
    dicom.source_ae_title,
    dicom.private_info_uid,
    dicom.private_info
   FROM public.dicom;


--
-- Name: file_mr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_mr (
    file_id integer NOT NULL,
    mr_scanning_seq text,
    mr_scanning_var text,
    mr_scan_options text,
    mr_acq_type text,
    mr_slice_thickness text,
    mr_repetition_time text,
    mr_echo_time text,
    mr_magnetic_field_strength text,
    mr_spacing_between_slices text,
    mr_echo_train_length text,
    mr_software_version text,
    mr_flip_angle text,
    mr_nominal_pixel_spacing text,
    mr_patient_position text,
    mr_acquisition_number text,
    mr_instance_number text,
    mr_smallest_pixel text,
    mr_largest_value text,
    mr_window_center text,
    mr_window_width text,
    mr_rescale_intercept text,
    mr_rescale_slope text,
    mr_rescale_type text
);


--
-- Name: file_patient; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_patient AS
 SELECT dicom.file_id,
    dicom.patient_name,
    dicom.patient_id,
    dicom.id_issuer,
    dicom.dob,
    dicom.sex,
    dicom.time_ob,
    dicom.other_ids,
    dicom.other_names,
    dicom.ethnic_group,
    dicom.comments,
    dicom.patient_age
   FROM public.dicom;


--
-- Name: file_plan; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_plan AS
 SELECT dicom.plan_id,
    dicom.file_id
   FROM public.dicom;


--
-- Name: file_pt_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_pt_image (
    file_id integer NOT NULL,
    pti_trigger_time text,
    pti_frame_time text,
    pti_intervals_acquired text,
    pti_intervals_rejected text,
    pti_reconstruction_diameter text,
    pti_gantry_detector_tilt text,
    pti_table_height text,
    pti_fov_shape text,
    pti_fov_dimensions text,
    pti_collimator_type text,
    pti_convoution_kernal text,
    pti_actual_frame_duration text,
    pti_energy_range_lower_limit text,
    pti_energy_range_upper_limit text,
    pti_radiopharmaceutical text,
    pti_radiopharmaceutical_volume text,
    pti_radiopharmaceutical_start_time text,
    pti_radiopharmaceutical_stop_time text,
    pti_radionuclide_total_dose text,
    pti_radionuclide_half_life text,
    pti_radionuclide_positron_fraction text,
    pti_number_of_slices text,
    pti_number_of_time_slices text,
    pti_type_of_detector_motion text,
    pti_image_id text,
    pti_series_type text,
    pti_units text,
    pti_counts_source text,
    pti_reprojection_method text,
    pti_randoms_correction_method text,
    pti_attenuation_correction_method text,
    pti_decay_correction text,
    pti_reconstruction_method text,
    pti_detector_lines_of_response_used text,
    pti_scatter_correction_method text,
    pti_axial_mash text,
    pti_transverse_mash text,
    pti_coincidence_window_width text,
    pti_secondary_counts_type text,
    pti_frame_reference_time text,
    pti_primary_counts_accumulated text,
    pti_secondary_counts_accumulated text,
    pti_slice_sensitivity_factor text,
    pti_decay_factor text,
    pti_dose_calibration_factor text,
    pti_scatter_fraction_factor text,
    pti_dead_time_factor text,
    pti_image_index text
);


--
-- Name: file_roi_image_linkage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_roi_image_linkage (
    file_id integer NOT NULL,
    roi_id integer NOT NULL,
    linked_sop_instance_uid text NOT NULL,
    linked_sop_class_uid text NOT NULL,
    contour_file_offset integer NOT NULL,
    contour_length integer NOT NULL,
    contour_digest text NOT NULL,
    num_points integer NOT NULL,
    contour_type text NOT NULL
);


--
-- Name: file_series; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_series AS
 SELECT dicom.file_id,
    dicom.modality,
    dicom.series_instance_uid,
    dicom.series_number,
    dicom.laterality,
    dicom.series_date,
    dicom.series_time,
    dicom.performing_phys,
    dicom.protocol_name,
    dicom.series_description,
    dicom.operators_name,
    dicom.body_part_examined,
    dicom.patient_position,
    dicom.smallest_pixel_value,
    dicom.largest_pixel_value,
    dicom.performed_procedure_step_id,
    dicom.performed_procedure_step_start_date,
    dicom.performed_procedure_step_start_time,
    dicom.performed_procedure_step_desc,
    dicom.performed_procedure_step_comments,
    dicom.date_fixed
   FROM public.dicom;


--
-- Name: file_slope_intercept; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_slope_intercept AS
 SELECT dicom.file_id,
    dicom.slope_intercept_id
   FROM public.dicom;


--
-- Name: file_sop_common; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_sop_common AS
 SELECT dicom.file_id,
    dicom.sop_class_uid,
    dicom.sop_instance_uid,
    dicom.specific_character_set,
    dicom.creation_date,
    dicom.creation_time,
    dicom.creator_uid,
    dicom.related_general_sop_class,
    dicom.original_specialized_sop_class,
    dicom.offset_from_utc,
    dicom.instance_number,
    dicom.instance_status,
    dicom.auth_date_time,
    dicom.auth_comment,
    dicom.auth_cert_num
   FROM public.dicom;


--
-- Name: file_storage_root; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_storage_root (
    file_storage_root_id integer NOT NULL,
    root_path text,
    current boolean,
    storage_class text
);


--
-- Name: file_storage_root_file_storage_root_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_storage_root_file_storage_root_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_storage_root_file_storage_root_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_storage_root_file_storage_root_id_seq OWNED BY public.file_storage_root.file_storage_root_id;


--
-- Name: file_structure_set; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_structure_set AS
 SELECT dicom.file_id,
    dicom.structure_set_id,
    dicom.instance_number
   FROM public.dicom;


--
-- Name: file_study; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.file_study AS
 SELECT dicom.file_id,
    dicom.study_instance_uid,
    dicom.study_date,
    dicom.study_time,
    dicom.referring_phy_name,
    dicom.study_id,
    dicom.accession_number,
    dicom.study_description,
    dicom.phys_of_record,
    dicom.phys_reading,
    dicom.admitting_diag
   FROM public.dicom;


--
-- Name: file_visibility_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_visibility_change (
    file_id integer NOT NULL,
    user_name text NOT NULL,
    time_of_change timestamp with time zone,
    prior_visibility text,
    new_visibility text,
    reason_for text
);


--
-- Name: file_win_lev; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_win_lev (
    file_id integer NOT NULL,
    window_level_id integer NOT NULL,
    wl_index integer NOT NULL
);


--
-- Name: files_without_type; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.files_without_type AS
 SELECT file.file_id,
    file.digest,
    file.size,
    file.is_dicom_file,
    file.file_type,
    file.processing_priority,
    file.ready_to_process
   FROM public.file
  WHERE (file.file_type IS NULL)
  WITH NO DATA;

CREATE MATERIALIZED VIEW public.files_without_location AS
SELECT a.*
FROM
	file a
LEFT JOIN
	file_location b
	on a.file_id = b.file_id
WHERE
	b.file_id IS NULL
WITH NO DATA;



--
-- Name: for_registration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.for_registration (
    ss_for_id integer NOT NULL,
    from_for_uid text NOT NULL,
    xform_type text,
    xform text,
    xform_comment text
);


--
-- Name: foreign_keys_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.foreign_keys_view AS
 SELECT tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
   FROM ((information_schema.table_constraints tc
     JOIN information_schema.key_column_usage kcu ON (((tc.constraint_name)::text = (kcu.constraint_name)::text)))
     JOIN information_schema.constraint_column_usage ccu ON (((ccu.constraint_name)::text = (tc.constraint_name)::text)))
  WHERE ((tc.constraint_type)::text = 'FOREIGN KEY'::text);


--
-- Name: fraction_reference_beam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fraction_reference_beam (
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    beam_number integer NOT NULL,
    beam_dose_specification_point text,
    beam_dose text,
    beam_dose_point_depth text,
    beam_dose_point_equivalent_depth text,
    beam_dose_point_ssd text,
    beam_meterset text
);


--
-- Name: fraction_reference_brachy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fraction_reference_brachy (
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    brachy_application_setup_number integer NOT NULL,
    brachy_application_setup_dose_specification_point text,
    brachy_application_setup_dose text
);


--
-- Name: fraction_reference_dose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fraction_reference_dose (
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    dose_reference_number integer NOT NULL,
    constraint_weight text,
    delivery_warning_dose text,
    delivery_maximum_dose text,
    target_minimum_dose text,
    target_prescription_dose text,
    target_maximum_dose text,
    target_underdose_volume_fraction text,
    organ_at_risk_full_volume_dose text,
    organ_at_risk_limit_dose text,
    organ_at_risk_maximum_dose text,
    organ_at_risk_overdose_volume_fraction text
);


--
-- Name: fraction_related_dose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fraction_related_dose (
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);


--
-- Name: image; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.image AS
 SELECT dicom.image_id,
    dicom.image_type,
    dicom.samples_per_pixel,
    dicom.pixel_spacing,
    dicom.photometric_interpretation,
    dicom.pixel_rows,
    dicom.pixel_columns,
    dicom.bits_allocated,
    dicom.bits_stored,
    dicom.high_bit,
    dicom.pixel_representation,
    dicom.planar_configuration,
    dicom.number_of_frames,
    dicom.unique_pixel_data_id,
    dicom.row_spacing,
    dicom.col_spacing
   FROM public.dicom;


--
-- Name: image_equivalence_class; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_equivalence_class (
    image_equivalence_class_id integer NOT NULL,
    series_instance_uid text NOT NULL,
    equivalence_class_number integer,
    processing_status text,
    review_status text,
    update_user text,
    update_date timestamp without time zone,
    hidden boolean DEFAULT false NOT NULL,
    visual_review_instance_id integer
);


--
-- Name: image_equivalence_class_image_equivalence_class_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.image_equivalence_class_image_equivalence_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_equivalence_class_image_equivalence_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.image_equivalence_class_image_equivalence_class_id_seq OWNED BY public.image_equivalence_class.image_equivalence_class_id;


--
-- Name: image_equivalence_class_input_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_equivalence_class_input_image (
    image_equivalence_class_id integer NOT NULL,
    file_id integer NOT NULL
);


--
-- Name: image_equivalence_class_out_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_equivalence_class_out_image (
    image_equivalence_class_id integer NOT NULL,
    projection_type text NOT NULL,
    file_id integer NOT NULL
);


--
-- Name: image_frame_offset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_frame_offset (
    image_id integer NOT NULL,
    frame_index integer,
    frame_offset text
);


--
-- Name: image_geometry; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.image_geometry AS
 SELECT dicom.image_geometry_id,
    dicom.image_id,
    dicom.iop,
    dicom.ipp,
    dicom.for_uid,
    dicom.normalized_iop,
    dicom.iop_error,
    dicom.row_x,
    dicom.row_y,
    dicom.row_z,
    dicom.col_x,
    dicom.col_y,
    dicom.col_z,
    dicom.pos_x,
    dicom.pos_y,
    dicom.pos_z
   FROM public.dicom;


--
-- Name: image_referenced_from_beam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_referenced_from_beam (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL,
    reference_image_number text NOT NULL,
    start_cum_meterset_weight text,
    end_cum_meterset_weight text
);


--
-- Name: image_slope_intercept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_slope_intercept (
    image_id integer NOT NULL,
    slope_intercept_id integer NOT NULL
);


--
-- Name: image_window_level; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_window_level (
    window_level_id integer NOT NULL,
    image_id integer NOT NULL
);


--
-- Name: import_control; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_control (
    status text,
    processor_pid integer,
    idle_seconds integer,
    pending_change_request text,
    files_per_round integer
);


--
-- Name: import_ct_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_ct_series (
    import_event_id integer NOT NULL,
    series_instance_uid text NOT NULL,
    series_type text,
    patient_position text,
    is_axial boolean,
    consistent_series_geometry boolean,
    normalized_iop text,
    number_of_slices integer,
    avg_slice_spacing double precision,
    max_slice_spacing double precision,
    min_slice_spacing double precision,
    minimum_z double precision,
    maximum_z double precision,
    total_file_size bigint,
    max_file_size integer,
    min_file_size integer,
    avg_file_size double precision,
    processing_errors text
);


--
-- Name: import_event_import_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.import_event_import_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_event_import_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.import_event_import_event_id_seq OWNED BY public.import_event.import_event_id;


--
-- Name: log_iec_hide; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log_iec_hide (
    user_name text,
    project text NOT NULL,
    site text NOT NULL,
    patient text,
    hidden boolean,
    date timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: missing_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missing_files (
    file_path character varying(200),
    missing character varying(3)
);


--
-- Name: missing_from_db; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missing_from_db (
    file_path character varying(200),
    missing character varying(3)
);


--
-- Name: missing_from_fs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missing_from_fs (
    filename text,
    is_dicom_file boolean,
    file_type text
);


--
-- Name: non_dicom_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_attachments (
    non_dicom_file_id integer NOT NULL,
    dicom_file_id integer NOT NULL,
    patient_id text NOT NULL,
    manifest_uid text NOT NULL,
    study_instance_uid text NOT NULL,
    series_instance_uid text NOT NULL,
    manifest_date timestamp without time zone NOT NULL,
    version text NOT NULL
);


--
-- Name: non_dicom_conversion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_conversion (
    from_file_id integer NOT NULL,
    to_file_id integer NOT NULL,
    conversion_event_id integer NOT NULL
);


--
-- Name: non_dicom_edit_compare; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_edit_compare (
    from_file_digest text NOT NULL,
    to_file_digest text NOT NULL,
    report_file_id integer NOT NULL,
    to_file_path text,
    subprocess_invocation_id integer NOT NULL
);


--
-- Name: non_dicom_edit_compare_disposition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_edit_compare_disposition (
    subprocess_invocation_id integer NOT NULL,
    start_creation_time timestamp without time zone,
    end_creation_time timestamp without time zone,
    num_edits_scheduled integer,
    num_compares_with_diffs integer,
    num_compares_without_diffs integer,
    current_disposition text,
    process_pid integer,
    last_updated timestamp without time zone,
    dest_dir text
);


--
-- Name: non_dicom_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_file (
    file_id integer NOT NULL,
    file_type text NOT NULL,
    file_sub_type text NOT NULL,
    collection text NOT NULL,
    site text NOT NULL,
    subject text,
    visibility text,
    date_last_categorized timestamp with time zone
);


--
-- Name: non_dicom_file_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_file_change (
    file_id integer NOT NULL,
    file_type text NOT NULL,
    file_sub_type text NOT NULL,
    collection text NOT NULL,
    site text NOT NULL,
    subject text,
    visibility text,
    when_categorized timestamp with time zone,
    when_recategorized timestamp with time zone,
    who_recategorized text,
    why_recategorized text
);


--
-- Name: patient_import_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_import_status (
    patient_id text NOT NULL,
    patient_import_status text
);


--
-- Name: patient_import_status_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_import_status_change (
    patient_id text NOT NULL,
    when_pat_stat_changed timestamp with time zone,
    old_pat_status text,
    new_pat_status text,
    pat_stat_change_who text,
    pat_stat_change_why text
);


--
-- Name: patient_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_mapping (
    from_patient_id text NOT NULL,
    to_patient_id text NOT NULL,
    to_patient_name text NOT NULL,
    collection_name text NOT NULL,
    site_name text NOT NULL,
    batch_number integer,
    diagnosis_date timestamp without time zone,
    baseline_date timestamp without time zone,
    date_shift interval,
    uid_root text,
    site_code integer
);


--
-- Name: pixel_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pixel_location (
    unique_pixel_data_id integer NOT NULL,
    file_id integer NOT NULL,
    file_offset integer NOT NULL
);


--
-- Name: plan; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.plan AS
 SELECT dicom.plan_id,
    dicom.plan_label,
    dicom.plan_name,
    dicom.plan_description,
    dicom.instance_number,
    dicom.operators_name,
    dicom.rt_plan_date,
    dicom.rt_plan_time,
    dicom.rt_treatment_protocols,
    dicom.plan_intent,
    dicom.treatment_sites,
    dicom.rt_plan_geometry,
    dicom.ss_referenced_from_plan
   FROM public.dicom;


--
-- Name: plan_related_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_related_plans (
    plan_id integer NOT NULL,
    related_plan_instance_uid text,
    plan_relationship text
);


--
-- Name: planned_verification_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planned_verification_images (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    start_cum_meterset_weight text,
    meterset_exposure text,
    end_cum_meterset_weight text,
    rt_image_plane text,
    xray_image_receptor_angle text,
    rt_image_orientation text,
    rt_image_position text,
    rt_image_sid text,
    image_device_specific_acquisition_params text,
    referenced_reference_image_number integer
);


--
-- Name: popup_buttons_popup_button_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.popup_buttons_popup_button_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posda_public_compare; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posda_public_compare (
    background_subprocess_id integer NOT NULL,
    sop_instance_uid text NOT NULL,
    from_file_id integer NOT NULL,
    short_report_file_id integer NOT NULL,
    long_report_file_id integer NOT NULL,
    to_file_path text NOT NULL
);


--
-- Name: public_to_posda_file_comparison; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_to_posda_file_comparison (
    public_to_posda_file_comparison_id integer NOT NULL,
    compare_public_to_posda_instance_id integer NOT NULL,
    sop_instance_uid text NOT NULL,
    posda_file_id integer,
    posda_file_path text,
    public_file_path text,
    short_report_file_id integer,
    long_report_file_id integer
);


--
-- Name: public_to_posda_file_comparis_public_to_posda_file_comparis_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.public_to_posda_file_comparis_public_to_posda_file_comparis_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: public_to_posda_file_comparis_public_to_posda_file_comparis_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.public_to_posda_file_comparis_public_to_posda_file_comparis_seq OWNED BY public.public_to_posda_file_comparison.public_to_posda_file_comparison_id;


--
-- Name: query_invoked_by_dbif; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.query_invoked_by_dbif (
    query_invoked_by_dbif_id integer NOT NULL,
    query_name text,
    invoking_user text,
    query_start_time timestamp with time zone,
    query_end_time timestamp with time zone,
    number_of_rows integer
);


--
-- Name: query_invoked_by_dbif_query_invoked_by_dbif_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.query_invoked_by_dbif_query_invoked_by_dbif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: query_invoked_by_dbif_query_invoked_by_dbif_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.query_invoked_by_dbif_query_invoked_by_dbif_id_seq OWNED BY public.query_invoked_by_dbif.query_invoked_by_dbif_id;


--
-- Name: related_roi_observations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.related_roi_observations (
    roi_observation_id integer NOT NULL,
    related_roi_observation_num integer NOT NULL
);


--
-- Name: report_inserted; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_inserted (
    report_inserted_id integer NOT NULL,
    report_file_in_posda integer,
    report_rows_generated integer,
    background_subprocess_id integer
);


--
-- Name: report_inserted_report_inserted_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_inserted_report_inserted_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_inserted_report_inserted_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_inserted_report_inserted_id_seq OWNED BY public.report_inserted.report_inserted_id;


--
-- Name: roi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roi (
    roi_id integer NOT NULL,
    structure_set_id integer NOT NULL,
    for_uid text NOT NULL,
    roi_num integer NOT NULL,
    roi_name text,
    roi_description text,
    roi_volume text,
    gen_alg text,
    gen_desc text,
    roi_color text,
    max_x double precision,
    max_y double precision,
    max_z double precision,
    min_x double precision,
    min_y double precision,
    min_z double precision,
    roi_interpreted_type text,
    roi_obser_desc text,
    roi_obser_label text
);


--
-- Name: roi_contour; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roi_contour (
    roi_contour_id integer NOT NULL,
    roi_id integer NOT NULL,
    contour_num integer,
    geometric_type text,
    slab_thickness text,
    offset_vector text,
    number_of_points integer,
    roi_contour_attachment text,
    contour_data text
);


--
-- Name: roi_contour_roi_contour_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roi_contour_roi_contour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roi_contour_roi_contour_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roi_contour_roi_contour_id_seq OWNED BY public.roi_contour.roi_contour_id;


--
-- Name: roi_elemental_composition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roi_elemental_composition (
    roi_phyical_properties_id integer NOT NULL,
    roi_elemental_composition_atomic_number text,
    roi_elemental_composition_atomic_mass_fraction text
);


--
-- Name: roi_observation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roi_observation (
    roi_observation_id integer NOT NULL,
    roi_id integer NOT NULL,
    roi_obs_num integer,
    observation_label text,
    observation_description text,
    interpreted_type text,
    interpreter text,
    material_id text
);


--
-- Name: roi_observation_roi_observation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roi_observation_roi_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roi_observation_roi_observation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roi_observation_roi_observation_id_seq OWNED BY public.roi_observation.roi_observation_id;


--
-- Name: roi_physical_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roi_physical_properties (
    roi_phyical_properties_id integer NOT NULL,
    roi_observation_id integer NOT NULL,
    property text,
    property_value text
);


--
-- Name: roi_physical_properties_roi_phyical_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roi_physical_properties_roi_phyical_properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roi_physical_properties_roi_phyical_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roi_physical_properties_roi_phyical_properties_id_seq OWNED BY public.roi_physical_properties.roi_phyical_properties_id;


--
-- Name: roi_related_roi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roi_related_roi (
    roi_id integer NOT NULL,
    related_roi_id integer NOT NULL,
    relationship text
);


--
-- Name: roi_roi_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roi_roi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roi_roi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roi_roi_id_seq OWNED BY public.roi.roi_id;


--
-- Name: rt_beam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_beam (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    beam_name text,
    beam_description text,
    beam_type text,
    radiation_type text,
    high_dose_technique text,
    treatement_machine_name text,
    manufacturer text,
    institution_name text,
    institution_address text,
    institution_department_name text,
    manufacturers_model_name text,
    device_serial_number text,
    primary_dosimeter_unit text,
    tolerance_table_number integer,
    source_axis_distance text,
    patient_setup_number integer,
    treatment_delivery_type text,
    number_of_wedges integer,
    number_of_compensators integer,
    total_compensator_tray_factor text,
    number_of_boli integer,
    number_of_blocks integer,
    total_block_tray_factor text,
    final_cumulative_meterset_weight text,
    number_of_control_points integer
);


--
-- Name: rt_beam_limit_dev_tolerance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_beam_limit_dev_tolerance (
    plan_id integer NOT NULL,
    tolerance_table_number integer NOT NULL,
    beam_limit_dev_type text,
    beam_limit_dev_pos_tolerance text
);


--
-- Name: rt_beam_tolerance_table; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_beam_tolerance_table (
    plan_id integer NOT NULL,
    tolerance_table_number integer NOT NULL,
    tolerance_table_label text,
    gantry_angle_tolerance text,
    gantry_angle_pitch_tolerance text,
    beam_limiting_device_angle_tolerance text,
    patient_support_angle_tolerance text,
    table_top_eccentric_angle_tolerance text,
    table_top_pitch_angle_tolerance text,
    table_top_roll_angle_tolerance text,
    table_top_vert_pos_tolerance text,
    table_top_log_pos_tolerance text,
    table_top_lat_pos_tolerance text
);


--
-- Name: rt_dose; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rt_dose AS
 SELECT dicom.rt_dose_id,
    dicom.rt_dose_units,
    dicom.rt_dose_type,
    dicom.rt_dose_instance_number,
    dicom.rt_dose_comment,
    dicom.rt_dose_normalization_point,
    dicom.rt_dose_summation_type,
    dicom.rt_dose_referenced_plan_class,
    dicom.rt_dose_referenced_plan_uid,
    dicom.rt_dose_tissue_heterogeneity
   FROM public.dicom;


--
-- Name: rt_dose_gfov; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dose_gfov (
    rt_dose_id integer NOT NULL,
    rt_gfov_index integer NOT NULL,
    gfov_offset double precision
);


--
-- Name: rt_dose_image; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rt_dose_image AS
 SELECT dicom.rt_dose_id,
    dicom.image_id,
    dicom.rt_dose_grid_frame_offset_vector,
    dicom.rt_dose_grid_scaling,
    dicom.rt_dose_max_slice_spacing,
    dicom.rt_dose_min_slice_spacing
   FROM public.dicom;


--
-- Name: rt_dose_ref_beam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dose_ref_beam (
    rt_dose_id integer NOT NULL,
    rt_dose_frac_group_number integer NOT NULL,
    rt_dose_beam_number integer NOT NULL,
    rt_dose_cp_start integer,
    rt_dose_cp_stop integer
);


--
-- Name: rt_dose_ref_brachy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dose_ref_brachy (
    rt_dose_id integer NOT NULL,
    rt_dose_ref_bracy_setup_number integer NOT NULL
);


--
-- Name: rt_dvh; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dvh (
    rt_dvh_id integer NOT NULL,
    rt_dvh_source text NOT NULL,
    rt_dvh_referenced_ss_class text,
    rt_dvh_referenced_ss_uid text,
    rt_dvh_normalization_point text,
    rt_dvh_normalization_value text
);


--
-- Name: rt_dvh_available_rois; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dvh_available_rois (
    rt_dvh_dvh_id integer NOT NULL,
    available_rois text
);


--
-- Name: rt_dvh_dvh; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dvh_dvh (
    rt_dvh_dvh_id integer NOT NULL,
    rt_dvh_id integer NOT NULL,
    rt_dvh_dvh_type text,
    rt_dvh_dvh_roi_alt_name text,
    rt_dvh_dvh_roi_alt_desc text,
    rt_dvh_dvh_plan_id text,
    rt_dvh_dvh_plan_desc text,
    rt_dvh_dvh_arm integer,
    rt_dvh_dvh_prescription double precision,
    rt_dvh_dvh_specified_heterogeneity text,
    rt_dvh_dvh_dose_summation_id text,
    rt_dvh_dvh_dose_manufacturer text,
    rt_dvh_dvh_dose_model_name text,
    rt_dvh_dvh_referenced_dose_grid_class text,
    rt_dvh_dvh_referenced_dose_grid_uid text,
    rt_dvh_dvh_dose_units text,
    rt_dvh_dvh_dose_type text,
    rt_dvh_dvh_dose_scaling text,
    rt_dvh_dvh_dose_volume_units text,
    rt_dvh_dvh_dose_number_of_bins text,
    rt_dvh_dvh_minimum_dose double precision,
    rt_dvh_dvh_maximum_dose double precision,
    rt_dvh_dvh_mean_dose double precision,
    rt_dvh_dvh_text_data text
);


--
-- Name: rt_dvh_dvh_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dvh_dvh_data (
    rt_dvh_dvh_id integer NOT NULL,
    rt_dvh_dvh_index integer NOT NULL,
    rt_dvh_dvh_data double precision
);


--
-- Name: rt_dvh_dvh_dose_bins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dvh_dvh_dose_bins (
    rt_dvh_dvh_id integer NOT NULL,
    bin_dose_cgy double precision NOT NULL,
    cum_percent_vol double precision NOT NULL,
    cum_cm3_vol double precision NOT NULL,
    cum_percent_prescription_dose double precision
);


--
-- Name: rt_dvh_dvh_roi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dvh_dvh_roi (
    rt_dvh_dvh_id integer NOT NULL,
    rt_dvh_dvh_ref_roi_number integer,
    rt_dvh_dvh_roi_cont_type text
);


--
-- Name: rt_dvh_dvh_rt_dvh_dvh_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rt_dvh_dvh_rt_dvh_dvh_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_dvh_dvh_rt_dvh_dvh_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rt_dvh_dvh_rt_dvh_dvh_id_seq OWNED BY public.rt_dvh_dvh.rt_dvh_dvh_id;


--
-- Name: rt_dvh_protocol_case_roi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dvh_protocol_case_roi (
    rt_dvh_dvh_id integer NOT NULL,
    roi_construct_name text,
    protocol text,
    case_no text,
    ss_file_id integer,
    dose_file_id integer
);


--
-- Name: rt_dvh_rt_dose; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rt_dvh_rt_dose AS
 SELECT dicom.rt_dose_id,
    dicom.rt_dvh_id
   FROM public.dicom;


--
-- Name: rt_dvh_rt_dvh_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rt_dvh_rt_dvh_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_dvh_rt_dvh_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rt_dvh_rt_dvh_id_seq OWNED BY public.rt_dvh.rt_dvh_id;


--
-- Name: rt_plan_fraction_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_plan_fraction_group (
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    fraction_group_descripton text,
    number_of_fractions_planned integer,
    number_of_fraction_digits_per_day integer,
    repeat_fraction_cycle_length integer,
    fraction_pattern text,
    number_of_beams integer,
    number_of_brachy_application_setups integer
);


--
-- Name: rt_plan_patient_setup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_plan_patient_setup (
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    patient_setup_label text,
    patient_position text,
    patient_addl_pos text,
    setup_technique text,
    setup_technique_description text,
    table_top_vert_disp text,
    table_top_long_disp text,
    table_top_lat_disp text
);


--
-- Name: rt_plan_respiratory_motion_comp; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rt_plan_respiratory_motion_comp AS
 SELECT dicom.plan_id,
    dicom.patient_setup_num,
    dicom.sequence_index,
    dicom.respiratory_motion_comp_technique,
    dicom.respiratory_signal_source,
    dicom.respiratory_motion_com_tech_desc,
    dicom.respiratory_signal_source_id
   FROM public.dicom;


--
-- Name: rt_plan_setup_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_plan_setup_device (
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    setup_device_type text NOT NULL,
    setup_device_label text,
    setup_device_description text,
    setup_device_parameter text,
    setup_reference_description text
);


--
-- Name: rt_plan_setup_fixation_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_plan_setup_fixation_device (
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    fixation_device_type text NOT NULL,
    fixaction_device_label text,
    fixation_device_description text,
    fixation_device_position text,
    fixation_device_pitch_angle text,
    fixation_device_roll_angle text,
    fixation_device_accessory_code text
);


--
-- Name: rt_plan_setup_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_plan_setup_image (
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    setup_image_comment text,
    image_sop_class_uid text,
    image_sop_instance_uid text
);


--
-- Name: rt_plan_setup_shielding_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_plan_setup_shielding_device (
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    shielding_device_type text NOT NULL,
    shielding_device_label text,
    shielding_device_description text,
    shielding_device_accessory_code text
);


--
-- Name: rt_prescription; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rt_prescription AS
 SELECT dicom.rt_prescription_id,
    dicom.plan_id,
    dicom.rt_prescription_description
   FROM public.dicom;


--
-- Name: rt_prescription_dose_ref; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_prescription_dose_ref (
    rt_prescription_id integer NOT NULL,
    dose_reference_number integer NOT NULL,
    dose_reference_uid text,
    dose_reference_structure_type text NOT NULL,
    referenced_roi_number integer,
    dose_reference_point text,
    nominal_prior_dose text,
    dose_reference_type text NOT NULL,
    constraint_weight text,
    delivery_warning_dose text,
    delivery_maximum_dose text,
    target_minimum_dose text,
    target_prescription_dose text,
    target_maximum_dose text,
    target_underdose_volume_fraction text,
    organ_at_risk_full_volume_dose text,
    organ_at_risk_limit_dose text,
    organ_at_risk_maximum_dose text,
    organ_at_overdose_volume_fraction text
);


--
-- Name: site_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_codes (
    site_name text NOT NULL,
    site_code text NOT NULL
);


--
-- Name: slope_intercept; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.slope_intercept AS
 SELECT dicom.slope_intercept_id,
    dicom.slope,
    dicom.intercept,
    dicom.si_units,
    dicom.slopef,
    dicom.interceptf
   FROM public.dicom;


--
-- Name: spreadsheet_uploaded; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spreadsheet_uploaded (
    spreadsheet_uploaded_id integer NOT NULL,
    time_uploaded timestamp with time zone,
    is_executable boolean,
    uploading_user text,
    file_id_in_posda integer,
    number_rows integer
);


--
-- Name: spreadsheet_uploaded_spreadsheet_uploaded_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spreadsheet_uploaded_spreadsheet_uploaded_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spreadsheet_uploaded_spreadsheet_uploaded_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spreadsheet_uploaded_spreadsheet_uploaded_id_seq OWNED BY public.spreadsheet_uploaded.spreadsheet_uploaded_id;


--
-- Name: ss_for; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ss_for (
    ss_for_id integer NOT NULL,
    structure_set_id integer NOT NULL,
    for_uid text NOT NULL
);


--
-- Name: ss_for_ss_for_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ss_for_ss_for_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ss_for_ss_for_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ss_for_ss_for_id_seq OWNED BY public.ss_for.ss_for_id;


--
-- Name: ss_volume; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ss_volume (
    ss_for_id integer NOT NULL,
    study_instance_uid text NOT NULL,
    series_instance_uid text NOT NULL,
    sop_class text NOT NULL,
    sop_instance text NOT NULL
);


--
-- Name: structure_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.structure_set (
    structure_set_id integer NOT NULL,
    ss_label text,
    ss_description text,
    ss_date date,
    ss_time time without time zone,
    ss_name text
);


--
-- Name: structure_set_structure_set_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.structure_set_structure_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: structure_set_structure_set_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.structure_set_structure_set_id_seq OWNED BY public.structure_set.structure_set_id;


--
-- Name: submission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission (
    import_event_id integer NOT NULL,
    institution text,
    year integer,
    month_i integer,
    month text
);


--
-- Name: subprocess_invocation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subprocess_invocation (
    subprocess_invocation_id integer NOT NULL,
    from_spreadsheet boolean,
    from_button boolean,
    spreadsheet_uploaded_id integer,
    query_invoked_by_dbif_id integer,
    button_name text,
    command_line text,
    process_pid integer,
    invoking_user text,
    when_invoked timestamp with time zone,
    operation_name text,
    scrash text,
    scrash_date timestamp without time zone
);


--
-- Name: subprocess_invocation_subprocess_invocation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subprocess_invocation_subprocess_invocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subprocess_invocation_subprocess_invocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subprocess_invocation_subprocess_invocation_id_seq OWNED BY public.subprocess_invocation.subprocess_invocation_id;


--
-- Name: subprocess_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subprocess_lines (
    subprocess_invocation_id integer NOT NULL,
    line_number integer NOT NULL,
    line text NOT NULL
);


--
-- Name: unique_pixel_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unique_pixel_data (
    unique_pixel_data_id integer NOT NULL,
    digest text NOT NULL,
    size integer
);


--
-- Name: unique_pixel_data_unique_pixel_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unique_pixel_data_unique_pixel_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unique_pixel_data_unique_pixel_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unique_pixel_data_unique_pixel_data_id_seq OWNED BY public.unique_pixel_data.unique_pixel_data_id;


--
-- Name: user_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_activity (
    user_activity_id integer NOT NULL,
    user_name text NOT NULL,
    description text NOT NULL,
    when_activity_created timestamp with time zone,
    when_activity_closed timestamp with time zone
);


--
-- Name: user_activity_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_activity_messages (
    user_activity_id integer NOT NULL,
    background_subprocess_report_id integer NOT NULL
);


--
-- Name: user_activity_user_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_activity_user_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_activity_user_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_activity_user_activity_id_seq OWNED BY public.user_activity.user_activity_id;


--
-- Name: user_inbox; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_inbox (
    user_inbox_id integer NOT NULL,
    user_name text,
    user_email_addr text
);


--
-- Name: user_inbox_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_inbox_content (
    user_inbox_content_id integer NOT NULL,
    user_inbox_id integer,
    background_subprocess_report_id integer,
    current_status text,
    statuts_note text,
    date_entered timestamp without time zone,
    date_dismissed timestamp without time zone
);


--
-- Name: user_inbox_content_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_inbox_content_operation (
    user_inbox_content_id integer,
    operation_type text,
    when_occurred timestamp without time zone,
    how_invoked text,
    invoking_user text
);


--
-- Name: user_inbox_content_user_inbox_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_inbox_content_user_inbox_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_inbox_content_user_inbox_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_inbox_content_user_inbox_content_id_seq OWNED BY public.user_inbox_content.user_inbox_content_id;


--
-- Name: user_inbox_user_inbox_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_inbox_user_inbox_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_inbox_user_inbox_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_inbox_user_inbox_id_seq OWNED BY public.user_inbox.user_inbox_id;


--
-- Name: user_variable_binding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_variable_binding (
    binding_user text NOT NULL,
    bound_variable_name text NOT NULL,
    bound_value text
);


--
-- Name: visible_file_totals_at_time; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visible_file_totals_at_time (
    time_of_reading timestamp without time zone,
    number_of_visible_dicom_files integer,
    number_of_bytes bigint
);


--
-- Name: visual_review_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visual_review_instance (
    visual_review_instance_id integer NOT NULL,
    subprocess_invocation_id integer,
    visual_review_reason text,
    visual_review_scheduler text,
    visual_review_num_series integer,
    when_visual_review_scheduled timestamp without time zone,
    visual_review_num_series_done integer,
    visual_review_num_equiv_class integer,
    when_visual_review_sched_complete timestamp without time zone
);


--
-- Name: visual_review_instance_visual_review_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visual_review_instance_visual_review_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visual_review_instance_visual_review_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visual_review_instance_visual_review_instance_id_seq OWNED BY public.visual_review_instance.visual_review_instance_id;


--
-- Name: window_level; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.window_level (
    window_level_id integer NOT NULL,
    window_width text NOT NULL,
    window_center text NOT NULL,
    win_lev_desc text
);


--
-- Name: window_level_window_level_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.window_level_window_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: window_level_window_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.window_level_window_level_id_seq OWNED BY public.window_level.window_level_id;


--
-- Name: ldct_all; Type: TABLE; Schema: quasar; Owner: -
--

CREATE TABLE quasar.ldct_all (
    file_id integer,
    file_name text
);


--
-- Name: ldct_and_projection; Type: TABLE; Schema: quasar; Owner: -
--

CREATE TABLE quasar.ldct_and_projection (
    filename text
);


--
-- Name: ldct_missing; Type: TABLE; Schema: quasar; Owner: -
--

CREATE TABLE quasar.ldct_missing (
    filename text,
    import_event_id integer,
    file_id integer,
    rel_path text,
    rel_dir text,
    file_name text,
    file_import_time timestamp with time zone
);


--
-- Name: mvtest; Type: MATERIALIZED VIEW; Schema: quasar; Owner: -
--

CREATE MATERIALIZED VIEW quasar.mvtest AS
 SELECT DISTINCT ctp_file.project_name,
    ctp_file.site_name
   FROM public.ctp_file
  WITH NO DATA;


--
-- Name: phantom_files; Type: TABLE; Schema: quasar; Owner: -
--

CREATE TABLE quasar.phantom_files (
    file_id integer
);


--
-- Name: background_buttons background_button_id; Type: DEFAULT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.background_buttons ALTER COLUMN background_button_id SET DEFAULT nextval('dbif_config.background_buttons_background_button_id_seq'::regclass);


--
-- Name: chained_query chained_query_id; Type: DEFAULT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.chained_query ALTER COLUMN chained_query_id SET DEFAULT nextval('dbif_config.chained_query_chained_query_id_seq'::regclass);


--
-- Name: popup_buttons popup_button_id; Type: DEFAULT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.popup_buttons ALTER COLUMN popup_button_id SET DEFAULT nextval('dbif_config.popup_buttons_popup_button_id_seq1'::regclass);


--
-- Name: activity activity_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity ALTER COLUMN activity_id SET DEFAULT nextval('public.activity_activity_id_seq'::regclass);


--
-- Name: activity_timepoint activity_timepoint_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_timepoint ALTER COLUMN activity_timepoint_id SET DEFAULT nextval('public.activity_timepoint_activity_timepoint_id_seq'::regclass);


--
-- Name: adverse_file_event adverse_file_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adverse_file_event ALTER COLUMN adverse_file_event_id SET DEFAULT nextval('public.adverse_file_event_adverse_file_event_id_seq'::regclass);


--
-- Name: association association_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.association ALTER COLUMN association_id SET DEFAULT nextval('public.association_association_id_seq'::regclass);


--
-- Name: association_pc association_pc_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.association_pc ALTER COLUMN association_pc_id SET DEFAULT nextval('public.association_pc_association_pc_id_seq'::regclass);


--
-- Name: background_subprocess background_subprocess_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess ALTER COLUMN background_subprocess_id SET DEFAULT nextval('public.background_subprocess_background_subprocess_id_seq'::regclass);


--
-- Name: background_subprocess_report background_subprocess_report_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess_report ALTER COLUMN background_subprocess_report_id SET DEFAULT nextval('public.background_subprocess_report_background_subprocess_report_i_seq'::regclass);


--
-- Name: compare_public_to_posda_instance compare_public_to_posda_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compare_public_to_posda_instance ALTER COLUMN compare_public_to_posda_instance_id SET DEFAULT nextval('public.compare_public_to_posda_insta_compare_public_to_posda_insta_seq'::regclass);


--
-- Name: conversion_event conversion_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversion_event ALTER COLUMN conversion_event_id SET DEFAULT nextval('public.conversion_event_conversion_event_id_seq'::regclass);


--
-- Name: copy_from_public copy_from_public_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.copy_from_public ALTER COLUMN copy_from_public_id SET DEFAULT nextval('public.copy_from_public_copy_from_public_id_seq'::regclass);


--
-- Name: dicom_dir_rec dicom_dir_rec_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dicom_dir_rec ALTER COLUMN dicom_dir_rec_id SET DEFAULT nextval('public.dicom_dir_rec_dicom_dir_rec_id_seq'::regclass);


--
-- Name: dicom_edit_event dicom_edit_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dicom_edit_event ALTER COLUMN dicom_edit_event_id SET DEFAULT nextval('public.dicom_edit_event_dicom_edit_event_id_seq'::regclass);


--
-- Name: dicom_send_event dicom_send_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dicom_send_event ALTER COLUMN dicom_send_event_id SET DEFAULT nextval('public.dicom_send_event_dicom_send_event_id_seq'::regclass);


--
-- Name: downloadable_dir downloadable_dir_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_dir ALTER COLUMN downloadable_dir_id SET DEFAULT nextval('public.downloadable_dir_downloadable_dir_id_seq'::regclass);


--
-- Name: downloadable_file downloadable_file_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_file ALTER COLUMN downloadable_file_id SET DEFAULT nextval('public.downloadable_file_downloadable_file_id_seq'::regclass);


--
-- Name: file file_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file ALTER COLUMN file_id SET DEFAULT nextval('public.file_file_id_seq'::regclass);


--
-- Name: file_ele_ref file_ele_ref_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_ele_ref ALTER COLUMN file_ele_ref_id SET DEFAULT nextval('public.file_ele_ref_file_ele_ref_id_seq'::regclass);


--
-- Name: file_import_series file_import_series_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_import_series ALTER COLUMN file_import_series_id SET DEFAULT nextval('public.file_import_series_file_import_series_id_seq'::regclass);


--
-- Name: file_import_study file_import_study_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_import_study ALTER COLUMN file_import_study_id SET DEFAULT nextval('public.file_import_study_file_import_study_id_seq'::regclass);


--
-- Name: file_storage_root file_storage_root_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_storage_root ALTER COLUMN file_storage_root_id SET DEFAULT nextval('public.file_storage_root_file_storage_root_id_seq'::regclass);


--
-- Name: image_equivalence_class image_equivalence_class_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_equivalence_class ALTER COLUMN image_equivalence_class_id SET DEFAULT nextval('public.image_equivalence_class_image_equivalence_class_id_seq'::regclass);


--
-- Name: import_event import_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_event ALTER COLUMN import_event_id SET DEFAULT nextval('public.import_event_import_event_id_seq'::regclass);


--
-- Name: public_to_posda_file_comparison public_to_posda_file_comparison_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_to_posda_file_comparison ALTER COLUMN public_to_posda_file_comparison_id SET DEFAULT nextval('public.public_to_posda_file_comparis_public_to_posda_file_comparis_seq'::regclass);


--
-- Name: query_invoked_by_dbif query_invoked_by_dbif_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_invoked_by_dbif ALTER COLUMN query_invoked_by_dbif_id SET DEFAULT nextval('public.query_invoked_by_dbif_query_invoked_by_dbif_id_seq'::regclass);


--
-- Name: report_inserted report_inserted_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_inserted ALTER COLUMN report_inserted_id SET DEFAULT nextval('public.report_inserted_report_inserted_id_seq'::regclass);


--
-- Name: roi roi_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roi ALTER COLUMN roi_id SET DEFAULT nextval('public.roi_roi_id_seq'::regclass);


--
-- Name: roi_contour roi_contour_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roi_contour ALTER COLUMN roi_contour_id SET DEFAULT nextval('public.roi_contour_roi_contour_id_seq'::regclass);


--
-- Name: roi_observation roi_observation_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roi_observation ALTER COLUMN roi_observation_id SET DEFAULT nextval('public.roi_observation_roi_observation_id_seq'::regclass);


--
-- Name: roi_physical_properties roi_phyical_properties_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roi_physical_properties ALTER COLUMN roi_phyical_properties_id SET DEFAULT nextval('public.roi_physical_properties_roi_phyical_properties_id_seq'::regclass);


--
-- Name: rt_dvh rt_dvh_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_dvh ALTER COLUMN rt_dvh_id SET DEFAULT nextval('public.rt_dvh_rt_dvh_id_seq'::regclass);


--
-- Name: rt_dvh_dvh rt_dvh_dvh_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_dvh_dvh ALTER COLUMN rt_dvh_dvh_id SET DEFAULT nextval('public.rt_dvh_dvh_rt_dvh_dvh_id_seq'::regclass);


--
-- Name: spreadsheet_uploaded spreadsheet_uploaded_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spreadsheet_uploaded ALTER COLUMN spreadsheet_uploaded_id SET DEFAULT nextval('public.spreadsheet_uploaded_spreadsheet_uploaded_id_seq'::regclass);


--
-- Name: ss_for ss_for_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ss_for ALTER COLUMN ss_for_id SET DEFAULT nextval('public.ss_for_ss_for_id_seq'::regclass);


--
-- Name: structure_set structure_set_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structure_set ALTER COLUMN structure_set_id SET DEFAULT nextval('public.structure_set_structure_set_id_seq'::regclass);


--
-- Name: subprocess_invocation subprocess_invocation_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subprocess_invocation ALTER COLUMN subprocess_invocation_id SET DEFAULT nextval('public.subprocess_invocation_subprocess_invocation_id_seq'::regclass);


--
-- Name: unique_pixel_data unique_pixel_data_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unique_pixel_data ALTER COLUMN unique_pixel_data_id SET DEFAULT nextval('public.unique_pixel_data_unique_pixel_data_id_seq'::regclass);


--
-- Name: user_activity user_activity_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activity ALTER COLUMN user_activity_id SET DEFAULT nextval('public.user_activity_user_activity_id_seq'::regclass);


--
-- Name: user_inbox user_inbox_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_inbox ALTER COLUMN user_inbox_id SET DEFAULT nextval('public.user_inbox_user_inbox_id_seq'::regclass);


--
-- Name: user_inbox_content user_inbox_content_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_inbox_content ALTER COLUMN user_inbox_content_id SET DEFAULT nextval('public.user_inbox_content_user_inbox_content_id_seq'::regclass);


--
-- Name: visual_review_instance visual_review_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visual_review_instance ALTER COLUMN visual_review_instance_id SET DEFAULT nextval('public.visual_review_instance_visual_review_instance_id_seq'::regclass);


--
-- Name: window_level window_level_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.window_level ALTER COLUMN window_level_id SET DEFAULT nextval('public.window_level_window_level_id_seq'::regclass);


--
-- Name: background_buttons background_buttons_pkey; Type: CONSTRAINT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.background_buttons
    ADD CONSTRAINT background_buttons_pkey PRIMARY KEY (background_button_id);


--
-- Name: popup_buttons popup_buttons_pkey; Type: CONSTRAINT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.popup_buttons
    ADD CONSTRAINT popup_buttons_pkey PRIMARY KEY (popup_button_id);


--
-- Name: query_tabs query_tabs_query_tab_name_key; Type: CONSTRAINT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.query_tabs
    ADD CONSTRAINT query_tabs_query_tab_name_key UNIQUE (query_tab_name);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_name);


--
-- Name: spreadsheet_operation spreadsheet_operation_operation_name_key; Type: CONSTRAINT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.spreadsheet_operation
    ADD CONSTRAINT spreadsheet_operation_operation_name_key UNIQUE (operation_name);


--
-- Name: background_subprocess background_subprocess_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess
    ADD CONSTRAINT background_subprocess_pkey PRIMARY KEY (background_subprocess_id);


--
-- Name: background_subprocess_report background_subprocess_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess_report
    ADD CONSTRAINT background_subprocess_report_pkey PRIMARY KEY (background_subprocess_report_id);


--
-- Name: collection_codes collection_codes_collection_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_codes
    ADD CONSTRAINT collection_codes_collection_code_key UNIQUE (collection_code);


--
-- Name: collection_codes collection_codes_collection_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_codes
    ADD CONSTRAINT collection_codes_collection_name_key UNIQUE (collection_name);


--
-- Name: ctp_file_new ctp_file_new_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ctp_file_new
    ADD CONSTRAINT ctp_file_new_pkey PRIMARY KEY (file_id);


--
-- Name: ctp_file ctp_file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ctp_file
    ADD CONSTRAINT ctp_file_pkey PRIMARY KEY (file_id);


--
-- Name: dicom_edit_compare_disposition dicom_edit_compare_disposition_subprocess_invocation_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dicom_edit_compare_disposition
    ADD CONSTRAINT dicom_edit_compare_disposition_subprocess_invocation_id_key UNIQUE (subprocess_invocation_id);


--
-- Name: dicom dicom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dicom
    ADD CONSTRAINT dicom_pkey PRIMARY KEY (file_id);


--
-- Name: distinguished_pixel_digests distinguished_pixel_digests_pixel_digest_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.distinguished_pixel_digests
    ADD CONSTRAINT distinguished_pixel_digests_pixel_digest_key UNIQUE (pixel_digest);


--
-- Name: downloadable_dir downloadable_dir_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_dir
    ADD CONSTRAINT downloadable_dir_pkey PRIMARY KEY (downloadable_dir_id);


--
-- Name: downloadable_file downloadable_file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_file
    ADD CONSTRAINT downloadable_file_pkey PRIMARY KEY (downloadable_file_id);


--
-- Name: file_mr file_mr_file_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_mr
    ADD CONSTRAINT file_mr_file_id_key UNIQUE (file_id);


--
-- Name: file_pt_image file_pt_image_file_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_pt_image
    ADD CONSTRAINT file_pt_image_file_id_key UNIQUE (file_id);


--
-- Name: image_equivalence_class_input_image image_equivalence_class_input_image_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_equivalence_class_input_image
    ADD CONSTRAINT image_equivalence_class_input_image_uniq UNIQUE (image_equivalence_class_id, file_id);


--
-- Name: non_dicom_edit_compare_disposition non_dicom_edit_compare_disposition_subprocess_invocation_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_dicom_edit_compare_disposition
    ADD CONSTRAINT non_dicom_edit_compare_disposition_subprocess_invocation_id_key UNIQUE (subprocess_invocation_id);


--
-- Name: patient_import_status patient_import_status_patient_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_import_status
    ADD CONSTRAINT patient_import_status_patient_id_key UNIQUE (patient_id);


--
-- Name: site_codes site_codes_site_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_codes
    ADD CONSTRAINT site_codes_site_code_key UNIQUE (site_code);


--
-- Name: site_codes site_codes_site_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_codes
    ADD CONSTRAINT site_codes_site_name_key UNIQUE (site_name);


--
-- Name: user_inbox_content user_inbox_content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_inbox_content
    ADD CONSTRAINT user_inbox_content_pkey PRIMARY KEY (user_inbox_content_id);


--
-- Name: user_inbox user_inbox_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_inbox
    ADD CONSTRAINT user_inbox_pkey PRIMARY KEY (user_inbox_id);


--
-- Name: user_inbox user_inbox_user_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_inbox
    ADD CONSTRAINT user_inbox_user_name_key UNIQUE (user_name);


--
-- Name: queries_name_index; Type: INDEX; Schema: dbif_config; Owner: -
--

CREATE UNIQUE INDEX queries_name_index ON dbif_config.queries USING btree (name);


--
-- Name: role_tabs_uidx; Type: INDEX; Schema: dbif_config; Owner: -
--

CREATE UNIQUE INDEX role_tabs_uidx ON dbif_config.role_tabs USING btree (role_name, query_tab_name);


--
-- Name: activity_timpepoint_file_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_timpepoint_file_idx ON public.activity_timepoint_file USING btree (activity_timepoint_id, file_id);


--
-- Name: assocation_import_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assocation_import_event_id_idx ON public.association_import USING btree (import_event_id);


--
-- Name: assocation_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assocation_import_id ON public.association_import USING btree (association_id);


--
-- Name: association_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX association_pk ON public.association USING btree (association_id);


--
-- Name: beam_applicator_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX beam_applicator_plan_idx ON public.beam_applicator USING btree (plan_id, beam_number, applicator_id);


--
-- Name: beam_block_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX beam_block_idx ON public.beam_block USING btree (plan_id, beam_number, block_number);


--
-- Name: beam_control_point_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX beam_control_point_idx ON public.beam_control_point USING btree (plan_id, beam_number, control_point_index);


--
-- Name: beam_limiting_device_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX beam_limiting_device_idx ON public.beam_limiting_device USING btree (plan_id, beam_number);


--
-- Name: clinical_trial_qualified_patient_collection_site_patient_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX clinical_trial_qualified_patient_collection_site_patient_id_idx ON public.clinical_trial_qualified_patient_id USING btree (collection, site, patient_id);


--
-- Name: contour_image_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contour_image_id_idx ON public.contour_image USING btree (roi_contour_id);


--
-- Name: contour_image_rev_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contour_image_rev_idx ON public.contour_image USING btree (sop_instance, roi_contour_id);


--
-- Name: control_point_bld_position_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX control_point_bld_position_idx ON public.control_point_bld_position USING btree (plan_id, beam_number, control_point_index);


--
-- Name: ctp_file_all_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_file_all_idx ON public.ctp_file_new USING btree (file_id, project_name, site_name);


--
-- Name: ctp_file_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_file_file_id_index ON public.ctp_file USING btree (file_id);


--
-- Name: ctp_file_project_site_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_file_project_site_idx ON public.ctp_file_new USING btree (project_name, site_name);


--
-- Name: ctp_file_vis_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_file_vis_idx ON public.ctp_file USING btree (visibility);


--
-- Name: ctp_proj_site_file_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_proj_site_file_index ON public.ctp_file USING btree (file_id, project_name, site_name);


--
-- Name: ctp_proj_site_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_proj_site_index ON public.ctp_file USING btree (project_name, site_name);


--
-- Name: ctp_upload_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ctp_upload_index ON public.ctp_upload_event USING btree (file_id, rcv_timestamp);


--
-- Name: dec_from_file_dig_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dec_from_file_dig_index ON public.dicom_edit_compare USING btree (from_file_digest);


--
-- Name: dec_to_file_dig_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dec_to_file_dig_index ON public.dicom_edit_compare USING btree (to_file_digest);


--
-- Name: dicom_edit_compare_subprocess_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_edit_compare_subprocess_index ON public.dicom_edit_compare USING btree (subprocess_invocation_id);


--
-- Name: dicom_file_send_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_file_send_idx ON public.dicom_file_send USING btree (dicom_send_event_id);


--
-- Name: dicom_hidden_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_hidden_idx ON public.dicom USING btree (hidden);


--
-- Name: dicom_process_errors_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_process_errors_file_id_idx ON public.dicom_process_errors USING btree (file_id);


--
-- Name: dicom_send_event_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dicom_send_event_pk ON public.dicom_send_event USING btree (dicom_send_event_id);


--
-- Name: dicom_series_instance_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_series_instance_uid_idx ON public.dicom USING btree (series_instance_uid);


--
-- Name: dicom_sop_instance_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_sop_instance_uid_idx ON public.dicom USING btree (sop_instance_uid);


--
-- Name: dicom_source_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_source_id_idx ON public.dicom USING btree (source_id);


--
-- Name: dicom_source_site_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dicom_source_site_name_idx ON public.dicom_source USING btree (site_name, project_name);


--
-- Name: file_ct_image_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_ct_image_file_id_index ON public.file_ct_image__old USING btree (file_id);


--
-- Name: file_digest_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_digest_index ON public.file USING btree (digest);


--
-- Name: file_ele_ref_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_ele_ref_pk ON public.file_ele_ref USING btree (file_ele_ref_id);


--
-- Name: file_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_file_id_idx ON public.file USING btree (file_id);


--
-- Name: file_import_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_import_file_id_idx ON public.file_import USING btree (file_id);


--
-- Name: file_import_import_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_import_import_event_id_idx ON public.file_import USING btree (import_event_id);


--
-- Name: file_import_import_event_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_import_import_event_index ON public.file_import USING btree (import_event_id);


--
-- Name: file_import_series_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_import_series_file_id_idx ON public.file_import_series USING btree (file_id);


--
-- Name: file_import_series_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_import_series_pk ON public.file_import_series USING btree (file_import_series_id);


--
-- Name: file_location_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_location_file_id_idx ON public.file_location USING btree (file_id);


--
-- Name: file_roi_image_linkage_linked_sop_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_roi_image_linkage_linked_sop_idx ON public.file_roi_image_linkage USING btree (linked_sop_instance_uid);


--
-- Name: file_storage_root_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_storage_root_pk ON public.file_storage_root USING btree (file_storage_root_id);


--
-- Name: file_visibility_change_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_visibility_change_idx ON public.file_visibility_change USING btree (file_id);


--
-- Name: file_win_lev_main_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_win_lev_main_idx ON public.file_win_lev USING btree (file_id, window_level_id, wl_index);


--
-- Name: files_without_type_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX files_without_type_file_id_idx ON public.files_without_type USING btree (file_id);


--
-- Name: fraction_reference_beam_beam_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fraction_reference_beam_beam_number ON public.fraction_reference_beam USING btree (beam_number);


--
-- Name: fraction_reference_beam_fraction_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fraction_reference_beam_fraction_idx ON public.fraction_reference_beam USING btree (fraction_group_number);


--
-- Name: fraction_reference_beam_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fraction_reference_beam_plan_idx ON public.fraction_reference_beam USING btree (plan_id);


--
-- Name: image_equivalence_class_input_image_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_input_image_file_id_idx ON public.image_equivalence_class_input_image USING btree (file_id);


--
-- Name: image_equivalence_class_input_image_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_input_image_id_idx ON public.image_equivalence_class_input_image USING btree (image_equivalence_class_id);


--
-- Name: image_equivalence_class_out_image_file_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_out_image_file_idx ON public.image_equivalence_class_out_image USING btree (file_id);


--
-- Name: image_equivalence_class_out_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_out_image_idx ON public.image_equivalence_class_out_image USING btree (image_equivalence_class_id);


--
-- Name: image_equivalence_class_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX image_equivalence_class_pk ON public.image_equivalence_class USING btree (image_equivalence_class_id);


--
-- Name: image_equivalence_class_vri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_vri ON public.image_equivalence_class USING btree (visual_review_instance_id);


--
-- Name: image_slope_intercept_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_slope_intercept_image_idx ON public.image_slope_intercept USING btree (image_id);


--
-- Name: image_slope_intercept_slope_intercept_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_slope_intercept_slope_intercept_idx ON public.image_slope_intercept USING btree (slope_intercept_id);


--
-- Name: image_window_level_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_window_level_image_idx ON public.image_window_level USING btree (image_id);


--
-- Name: image_window_level_window_level_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_window_level_window_level_idx ON public.image_window_level USING btree (window_level_id);


--
-- Name: import_event_import_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX import_event_import_event_id_idx ON public.import_event USING btree (import_event_id);


--
-- Name: import_event_import_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX import_event_import_time_idx ON public.import_event USING btree (import_time);


--
-- Name: pixel_location_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pixel_location_file_id_idx ON public.pixel_location USING btree (file_id);


--
-- Name: pixel_location_unique_pixel_data_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pixel_location_unique_pixel_data_id_idx ON public.pixel_location USING btree (unique_pixel_data_id);


--
-- Name: query_by_user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX query_by_user_index ON public.query_invoked_by_dbif USING btree (invoking_user);


--
-- Name: queue_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX queue_size ON public.file USING btree (is_dicom_file, ready_to_process, processing_priority);


--
-- Name: roi_contour_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roi_contour_idx ON public.roi_contour USING btree (roi_id);


--
-- Name: roi_contour_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roi_contour_pk ON public.roi_contour USING btree (roi_contour_id);


--
-- Name: roi_observation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roi_observation_id_idx ON public.roi_observation USING btree (roi_id);


--
-- Name: roi_observation_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roi_observation_pk ON public.roi_observation USING btree (roi_observation_id);


--
-- Name: roi_physical_properties_observation_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roi_physical_properties_observation_idx ON public.roi_physical_properties USING btree (roi_observation_id);


--
-- Name: roi_physical_properties_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roi_physical_properties_pk ON public.roi_physical_properties USING btree (roi_phyical_properties_id);


--
-- Name: roi_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roi_pk ON public.roi USING btree (roi_id);


--
-- Name: roi_structure_set_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roi_structure_set_idx ON public.roi USING btree (structure_set_id);


--
-- Name: rt_beam_number_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_beam_number_idx ON public.rt_beam USING btree (beam_number);


--
-- Name: rt_beam_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_beam_plan_idx ON public.rt_beam USING btree (plan_id);


--
-- Name: rt_beam_tolerance_table_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_beam_tolerance_table_plan_idx ON public.rt_beam_tolerance_table USING btree (plan_id);


--
-- Name: rt_beam_tolerance_table_table_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_beam_tolerance_table_table_idx ON public.rt_beam_tolerance_table USING btree (tolerance_table_number);


--
-- Name: rt_dvh_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rt_dvh_pk ON public.rt_dvh USING btree (rt_dvh_id);


--
-- Name: rt_plan_fraction_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_plan_fraction_group_idx ON public.rt_plan_fraction_group USING btree (plan_id);


--
-- Name: rt_plan_patient_setup_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_plan_patient_setup_plan_idx ON public.rt_plan_patient_setup USING btree (plan_id);


--
-- Name: ss_for_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ss_for_pk ON public.ss_for USING btree (ss_for_id);


--
-- Name: ss_volume_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ss_volume_id_idx ON public.ss_volume USING btree (ss_for_id);


--
-- Name: structure_set_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX structure_set_pk ON public.structure_set USING btree (structure_set_id);


--
-- Name: unique_pixel_data_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unique_pixel_data_digest ON public.unique_pixel_data USING btree (digest);


--
-- Name: unique_pixel_data_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_pixel_data_pk ON public.unique_pixel_data USING btree (unique_pixel_data_id);


--
-- Name: user_variable_binding_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_variable_binding_index ON public.user_variable_binding USING btree (binding_user, bound_variable_name);


--
-- Name: window_level_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX window_level_pk ON public.window_level USING btree (window_level_id);


--
-- Name: phantom_files_idx; Type: INDEX; Schema: quasar; Owner: -
--

CREATE INDEX phantom_files_idx ON quasar.phantom_files USING btree (file_id);


--
-- Name: dicom_file dicom_file_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE dicom_file_delete AS
    ON DELETE TO public.dicom_file DO INSTEAD  UPDATE public.dicom_file SET file_id = NULL::integer, dataset_digest = NULL::text, xfr_stx = NULL::text, has_meta = NULL::boolean, is_dicom_dir = NULL::boolean, has_sop_common = NULL::boolean, dicom_file_type = NULL::text, has_pixel_data = NULL::boolean, pixel_data_digest = NULL::text, pixel_data_offset = NULL::integer, pixel_data_length = NULL::integer, has_no_roi_linkages = NULL::boolean
  WHERE (dicom_file.file_id = old.file_id);


--
-- Name: dicom_file dicom_file_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE dicom_file_insert AS
    ON INSERT TO public.dicom_file DO INSTEAD  UPDATE public.dicom_file SET file_id = new.file_id, dataset_digest = new.dataset_digest, xfr_stx = new.xfr_stx, has_meta = new.has_meta, is_dicom_dir = new.is_dicom_dir, has_sop_common = new.has_sop_common, dicom_file_type = new.dicom_file_type, has_pixel_data = new.has_pixel_data, pixel_data_digest = new.pixel_data_digest, pixel_data_offset = new.pixel_data_offset, pixel_data_length = new.pixel_data_length, has_no_roi_linkages = new.has_no_roi_linkages
  WHERE (dicom_file.file_id = new.file_id);


--
-- Name: file_ct_image file_ct_image_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_ct_image_delete AS
    ON DELETE TO public.file_ct_image DO INSTEAD  UPDATE public.file_ct_image SET file_id = NULL::integer, kvp = NULL::text, instance_number = NULL::text, scan_options = NULL::text, data_collection_diameter = NULL::text, reconstruction_diameter = NULL::text, dist_source_to_detect = NULL::text, dist_source_to_pat = NULL::text, gantry_tilt = NULL::text, table_height = NULL::text, rotation_dir = NULL::text, exposure_time = NULL::text, xray_tube_current = NULL::text, exposure = NULL::text, filter_type = NULL::text, generator_power = NULL::text, convolution_kernal = NULL::text, table_feed_per_rot = NULL::text
  WHERE (file_ct_image.file_id = old.file_id);


--
-- Name: file_ct_image file_ct_image_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_ct_image_insert AS
    ON INSERT TO public.file_ct_image DO INSTEAD  UPDATE public.file_ct_image SET file_id = new.file_id, kvp = new.kvp, instance_number = new.instance_number, scan_options = new.scan_options, data_collection_diameter = new.data_collection_diameter, reconstruction_diameter = new.reconstruction_diameter, dist_source_to_detect = new.dist_source_to_detect, dist_source_to_pat = new.dist_source_to_pat, gantry_tilt = new.gantry_tilt, table_height = new.table_height, rotation_dir = new.rotation_dir, exposure_time = new.exposure_time, xray_tube_current = new.xray_tube_current, exposure = new.exposure, filter_type = new.filter_type, generator_power = new.generator_power, convolution_kernal = new.convolution_kernal, table_feed_per_rot = new.table_feed_per_rot
  WHERE (file_ct_image.file_id = new.file_id);


--
-- Name: file_dose file_dose_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_dose_delete AS
    ON DELETE TO public.file_dose DO INSTEAD  UPDATE public.file_dose SET rt_dose_id = NULL::integer, file_id = NULL::integer
  WHERE (file_dose.file_id = old.file_id);


--
-- Name: file_dose file_dose_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_dose_insert AS
    ON INSERT TO public.file_dose DO INSTEAD  UPDATE public.file_dose SET rt_dose_id = new.rt_dose_id, file_id = new.file_id
  WHERE (file_dose.file_id = new.file_id);


--
-- Name: file_equipment file_equipment_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_equipment_delete AS
    ON DELETE TO public.file_equipment DO INSTEAD  UPDATE public.file_equipment SET file_id = NULL::integer, manufacturer = NULL::text, institution_name = NULL::text, institution_addr = NULL::text, station_name = NULL::text, inst_dept_name = NULL::text, manuf_model_name = NULL::text, dev_serial_num = NULL::text, software_versions = NULL::text, spatial_resolution = NULL::text, last_calib_date = NULL::text, last_calib_time = NULL::text, pixel_pad = NULL::integer
  WHERE (file_equipment.file_id = old.file_id);


--
-- Name: file_equipment file_equipment_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_equipment_insert AS
    ON INSERT TO public.file_equipment DO INSTEAD  UPDATE public.file_equipment SET file_id = new.file_id, manufacturer = new.manufacturer, institution_name = new.institution_name, institution_addr = new.institution_addr, station_name = new.station_name, inst_dept_name = new.inst_dept_name, manuf_model_name = new.manuf_model_name, dev_serial_num = new.dev_serial_num, software_versions = new.software_versions, spatial_resolution = new.spatial_resolution, last_calib_date = new.last_calib_date, last_calib_time = new.last_calib_time, pixel_pad = new.pixel_pad
  WHERE (file_equipment.file_id = new.file_id);


--
-- Name: file_for file_for_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_for_delete AS
    ON DELETE TO public.file_for DO INSTEAD  UPDATE public.file_for SET file_id = NULL::integer, for_uid = NULL::text, position_ref_indicator = NULL::text
  WHERE (file_for.file_id = old.file_id);


--
-- Name: file_for file_for_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_for_insert AS
    ON INSERT TO public.file_for DO INSTEAD  UPDATE public.file_for SET file_id = new.file_id, for_uid = new.for_uid, position_ref_indicator = new.position_ref_indicator
  WHERE (file_for.file_id = new.file_id);


--
-- Name: file_image file_image_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_image_delete AS
    ON DELETE TO public.file_image DO INSTEAD  UPDATE public.file_image SET file_id = NULL::integer, image_id = NULL::integer, content_date = NULL::date, content_time = NULL::time without time zone
  WHERE (file_image.file_id = old.file_id);


--
-- Name: file_image_geometry file_image_geometry_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_image_geometry_delete AS
    ON DELETE TO public.file_image_geometry DO INSTEAD  UPDATE public.file_image_geometry SET file_id = NULL::integer, image_geometry_id = NULL::integer
  WHERE (file_image_geometry.file_id = old.file_id);


--
-- Name: file_image_geometry file_image_geometry_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_image_geometry_insert AS
    ON INSERT TO public.file_image_geometry DO INSTEAD  UPDATE public.file_image_geometry SET file_id = new.file_id, image_geometry_id = new.image_geometry_id
  WHERE (file_image_geometry.file_id = new.file_id);


--
-- Name: file_image file_image_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_image_insert AS
    ON INSERT TO public.file_image DO INSTEAD  UPDATE public.file_image SET file_id = new.file_id, image_id = new.image_id, content_date = new.content_date, content_time = new.content_time
  WHERE (file_image.file_id = new.file_id);


--
-- Name: file_meta file_meta_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_meta_delete AS
    ON DELETE TO public.file_meta DO INSTEAD  UPDATE public.file_meta SET file_id = NULL::integer, file_meta = NULL::integer, data_set_size = NULL::integer, data_set_start = NULL::integer, media_storage_sop_class = NULL::text, media_storage_sop_instance = NULL::text, xfer_syntax = NULL::text, imp_class_uid = NULL::text, imp_version_name = NULL::text, source_ae_title = NULL::text, private_info_uid = NULL::text, private_info = NULL::text
  WHERE (file_meta.file_id = old.file_id);


--
-- Name: file_meta file_meta_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_meta_insert AS
    ON INSERT TO public.file_meta DO INSTEAD  UPDATE public.file_meta SET file_id = new.file_id, file_meta = new.file_meta, data_set_size = new.data_set_size, data_set_start = new.data_set_start, media_storage_sop_class = new.media_storage_sop_class, media_storage_sop_instance = new.media_storage_sop_instance, xfer_syntax = new.xfer_syntax, imp_class_uid = new.imp_class_uid, imp_version_name = new.imp_version_name, source_ae_title = new.source_ae_title, private_info_uid = new.private_info_uid, private_info = new.private_info
  WHERE (file_meta.file_id = new.file_id);


--
-- Name: file_patient file_patient_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_patient_delete AS
    ON DELETE TO public.file_patient DO INSTEAD  UPDATE public.file_patient SET file_id = NULL::integer, patient_name = NULL::text, patient_id = NULL::text, id_issuer = NULL::text, dob = NULL::date, sex = NULL::text, time_ob = NULL::time without time zone, other_ids = NULL::text, other_names = NULL::text, ethnic_group = NULL::text, comments = NULL::text, patient_age = NULL::text
  WHERE (file_patient.file_id = old.file_id);


--
-- Name: file_patient file_patient_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_patient_insert AS
    ON INSERT TO public.file_patient DO INSTEAD  UPDATE public.file_patient SET file_id = new.file_id, patient_name = new.patient_name, patient_id = new.patient_id, id_issuer = new.id_issuer, dob = new.dob, sex = new.sex, time_ob = new.time_ob, other_ids = new.other_ids, other_names = new.other_names, ethnic_group = new.ethnic_group, comments = new.comments, patient_age = new.patient_age
  WHERE (file_patient.file_id = new.file_id);


--
-- Name: file_plan file_plan_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_plan_delete AS
    ON DELETE TO public.file_plan DO INSTEAD  UPDATE public.file_plan SET plan_id = NULL::integer, file_id = NULL::integer
  WHERE (file_plan.file_id = old.file_id);


--
-- Name: file_plan file_plan_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_plan_insert AS
    ON INSERT TO public.file_plan DO INSTEAD  UPDATE public.file_plan SET plan_id = new.plan_id, file_id = new.file_id
  WHERE (file_plan.file_id = new.file_id);


--
-- Name: file_series file_series_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_series_delete AS
    ON DELETE TO public.file_series DO INSTEAD  UPDATE public.file_series SET file_id = NULL::integer, modality = NULL::text, series_instance_uid = NULL::text, series_number = NULL::integer, laterality = NULL::text, series_date = NULL::date, series_time = NULL::time without time zone, performing_phys = NULL::text, protocol_name = NULL::text, series_description = NULL::text, operators_name = NULL::text, body_part_examined = NULL::text, patient_position = NULL::text, smallest_pixel_value = NULL::integer, largest_pixel_value = NULL::integer, performed_procedure_step_id = NULL::text, performed_procedure_step_start_date = NULL::date, performed_procedure_step_start_time = NULL::time without time zone, performed_procedure_step_desc = NULL::text, performed_procedure_step_comments = NULL::text, date_fixed = NULL::boolean
  WHERE (file_series.file_id = old.file_id);


--
-- Name: file_series file_series_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_series_insert AS
    ON INSERT TO public.file_series DO INSTEAD  UPDATE public.file_series SET file_id = new.file_id, modality = new.modality, series_instance_uid = new.series_instance_uid, series_number = new.series_number, laterality = new.laterality, series_date = new.series_date, series_time = new.series_time, performing_phys = new.performing_phys, protocol_name = new.protocol_name, series_description = new.series_description, operators_name = new.operators_name, body_part_examined = new.body_part_examined, patient_position = new.patient_position, smallest_pixel_value = new.smallest_pixel_value, largest_pixel_value = new.largest_pixel_value, performed_procedure_step_id = new.performed_procedure_step_id, performed_procedure_step_start_date = new.performed_procedure_step_start_date, performed_procedure_step_start_time = new.performed_procedure_step_start_time, performed_procedure_step_desc = new.performed_procedure_step_desc, performed_procedure_step_comments = new.performed_procedure_step_comments, date_fixed = new.date_fixed
  WHERE (file_series.file_id = new.file_id);


--
-- Name: file_slope_intercept file_slope_intercept_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_slope_intercept_delete AS
    ON DELETE TO public.file_slope_intercept DO INSTEAD  UPDATE public.file_slope_intercept SET file_id = NULL::integer, slope_intercept_id = NULL::integer
  WHERE (file_slope_intercept.file_id = old.file_id);


--
-- Name: file_slope_intercept file_slope_intercept_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_slope_intercept_insert AS
    ON INSERT TO public.file_slope_intercept DO INSTEAD  UPDATE public.file_slope_intercept SET file_id = new.file_id, slope_intercept_id = new.slope_intercept_id
  WHERE (file_slope_intercept.file_id = new.file_id);


--
-- Name: file_sop_common file_sop_common_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_sop_common_delete AS
    ON DELETE TO public.file_sop_common DO INSTEAD  UPDATE public.file_sop_common SET file_id = NULL::integer, sop_class_uid = NULL::text, sop_instance_uid = NULL::text, specific_character_set = NULL::text, creation_date = NULL::date, creation_time = NULL::time without time zone, creator_uid = NULL::text, related_general_sop_class = NULL::text, original_specialized_sop_class = NULL::text, offset_from_utc = NULL::integer, instance_number = NULL::text, instance_status = NULL::text, auth_date_time = NULL::time with time zone, auth_comment = NULL::text, auth_cert_num = NULL::text
  WHERE (file_sop_common.file_id = old.file_id);


--
-- Name: file_sop_common file_sop_common_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_sop_common_insert AS
    ON INSERT TO public.file_sop_common DO INSTEAD  UPDATE public.file_sop_common SET file_id = new.file_id, sop_class_uid = new.sop_class_uid, sop_instance_uid = new.sop_instance_uid, specific_character_set = new.specific_character_set, creation_date = new.creation_date, creation_time = new.creation_time, creator_uid = new.creator_uid, related_general_sop_class = new.related_general_sop_class, original_specialized_sop_class = new.original_specialized_sop_class, offset_from_utc = new.offset_from_utc, instance_number = new.instance_number, instance_status = new.instance_status, auth_date_time = new.auth_date_time, auth_comment = new.auth_comment, auth_cert_num = new.auth_cert_num
  WHERE (file_sop_common.file_id = new.file_id);


--
-- Name: file_structure_set file_structure_set_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_structure_set_delete AS
    ON DELETE TO public.file_structure_set DO INSTEAD  UPDATE public.file_structure_set SET file_id = NULL::integer, structure_set_id = NULL::integer, instance_number = NULL::text
  WHERE (file_structure_set.file_id = old.file_id);


--
-- Name: file_structure_set file_structure_set_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_structure_set_insert AS
    ON INSERT TO public.file_structure_set DO INSTEAD  UPDATE public.file_structure_set SET file_id = new.file_id, structure_set_id = new.structure_set_id, instance_number = new.instance_number
  WHERE (file_structure_set.file_id = new.file_id);


--
-- Name: file_study file_study_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_study_delete AS
    ON DELETE TO public.file_study DO INSTEAD  UPDATE public.file_study SET file_id = NULL::integer, study_instance_uid = NULL::text, study_date = NULL::date, study_time = NULL::time without time zone, referring_phy_name = NULL::text, study_id = NULL::text, accession_number = NULL::text, study_description = NULL::text, phys_of_record = NULL::text, phys_reading = NULL::text, admitting_diag = NULL::text
  WHERE (file_study.file_id = old.file_id);


--
-- Name: file_study file_study_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE file_study_insert AS
    ON INSERT TO public.file_study DO INSTEAD  UPDATE public.file_study SET file_id = new.file_id, study_instance_uid = new.study_instance_uid, study_date = new.study_date, study_time = new.study_time, referring_phy_name = new.referring_phy_name, study_id = new.study_id, accession_number = new.accession_number, study_description = new.study_description, phys_of_record = new.phys_of_record, phys_reading = new.phys_reading, admitting_diag = new.admitting_diag
  WHERE (file_study.file_id = new.file_id);


--
-- Name: image image_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE image_delete AS
    ON DELETE TO public.image DO INSTEAD  UPDATE public.image SET image_id = NULL::integer, image_type = NULL::text, samples_per_pixel = NULL::integer, pixel_spacing = NULL::text, photometric_interpretation = NULL::text, pixel_rows = NULL::integer, pixel_columns = NULL::integer, bits_allocated = NULL::integer, bits_stored = NULL::integer, high_bit = NULL::integer, pixel_representation = NULL::integer, planar_configuration = NULL::integer, number_of_frames = NULL::integer, unique_pixel_data_id = NULL::integer, row_spacing = NULL::double precision, col_spacing = NULL::double precision
  WHERE (image.image_id = old.image_id);


--
-- Name: image_geometry image_geometry_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE image_geometry_delete AS
    ON DELETE TO public.image_geometry DO INSTEAD  UPDATE public.image_geometry SET image_geometry_id = NULL::integer, image_id = NULL::integer, iop = NULL::text, ipp = NULL::text, for_uid = NULL::text, normalized_iop = NULL::text, iop_error = NULL::text, row_x = NULL::double precision, row_y = NULL::double precision, row_z = NULL::double precision, col_x = NULL::double precision, col_y = NULL::double precision, col_z = NULL::double precision, pos_x = NULL::double precision, pos_y = NULL::double precision, pos_z = NULL::double precision
  WHERE (image_geometry.image_geometry_id = old.image_geometry_id);


--
-- Name: image_geometry image_geometry_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE image_geometry_insert AS
    ON INSERT TO public.image_geometry DO INSTEAD  UPDATE public.image_geometry SET image_geometry_id = new.image_geometry_id, image_id = new.image_id, iop = new.iop, ipp = new.ipp, for_uid = new.for_uid, normalized_iop = new.normalized_iop, iop_error = new.iop_error, row_x = new.row_x, row_y = new.row_y, row_z = new.row_z, col_x = new.col_x, col_y = new.col_y, col_z = new.col_z, pos_x = new.pos_x, pos_y = new.pos_y, pos_z = new.pos_z
  WHERE (image_geometry.image_geometry_id = new.image_geometry_id);


--
-- Name: image image_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE image_insert AS
    ON INSERT TO public.image DO INSTEAD  UPDATE public.image SET image_id = new.image_id, image_type = new.image_type, samples_per_pixel = new.samples_per_pixel, pixel_spacing = new.pixel_spacing, photometric_interpretation = new.photometric_interpretation, pixel_rows = new.pixel_rows, pixel_columns = new.pixel_columns, bits_allocated = new.bits_allocated, bits_stored = new.bits_stored, high_bit = new.high_bit, pixel_representation = new.pixel_representation, planar_configuration = new.planar_configuration, number_of_frames = new.number_of_frames, unique_pixel_data_id = new.unique_pixel_data_id, row_spacing = new.row_spacing, col_spacing = new.col_spacing
  WHERE (image.image_id = new.image_id);


--
-- Name: plan plan_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE plan_delete AS
    ON DELETE TO public.plan DO INSTEAD  UPDATE public.plan SET plan_id = NULL::integer, plan_label = NULL::text, plan_name = NULL::text, plan_description = NULL::text, instance_number = NULL::text, operators_name = NULL::text, rt_plan_date = NULL::date, rt_plan_time = NULL::time without time zone, rt_treatment_protocols = NULL::text, plan_intent = NULL::text, treatment_sites = NULL::text, rt_plan_geometry = NULL::text, ss_referenced_from_plan = NULL::text
  WHERE (plan.plan_id = old.plan_id);


--
-- Name: plan plan_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE plan_insert AS
    ON INSERT TO public.plan DO INSTEAD  UPDATE public.plan SET plan_id = new.plan_id, plan_label = new.plan_label, plan_name = new.plan_name, plan_description = new.plan_description, instance_number = new.instance_number, operators_name = new.operators_name, rt_plan_date = new.rt_plan_date, rt_plan_time = new.rt_plan_time, rt_treatment_protocols = new.rt_treatment_protocols, plan_intent = new.plan_intent, treatment_sites = new.treatment_sites, rt_plan_geometry = new.rt_plan_geometry, ss_referenced_from_plan = new.ss_referenced_from_plan
  WHERE (plan.plan_id = new.plan_id);


--
-- Name: rt_dose rt_dose_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_dose_delete AS
    ON DELETE TO public.rt_dose DO INSTEAD  UPDATE public.rt_dose SET rt_dose_id = NULL::integer, rt_dose_units = NULL::text, rt_dose_type = NULL::text, rt_dose_instance_number = NULL::text, rt_dose_comment = NULL::text, rt_dose_normalization_point = NULL::text, rt_dose_summation_type = NULL::text, rt_dose_referenced_plan_class = NULL::text, rt_dose_referenced_plan_uid = NULL::text, rt_dose_tissue_heterogeneity = NULL::text
  WHERE (rt_dose.rt_dose_id = old.rt_dose_id);


--
-- Name: rt_dose_image rt_dose_image_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_dose_image_delete AS
    ON DELETE TO public.rt_dose_image DO INSTEAD  UPDATE public.rt_dose_image SET rt_dose_id = NULL::integer, image_id = NULL::integer, rt_dose_grid_frame_offset_vector = NULL::text, rt_dose_grid_scaling = NULL::double precision, rt_dose_max_slice_spacing = NULL::double precision, rt_dose_min_slice_spacing = NULL::double precision
  WHERE (rt_dose_image.rt_dose_id = old.rt_dose_id);


--
-- Name: rt_dose_image rt_dose_image_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_dose_image_insert AS
    ON INSERT TO public.rt_dose_image DO INSTEAD  UPDATE public.rt_dose_image SET rt_dose_id = new.rt_dose_id, image_id = new.image_id, rt_dose_grid_frame_offset_vector = new.rt_dose_grid_frame_offset_vector, rt_dose_grid_scaling = new.rt_dose_grid_scaling, rt_dose_max_slice_spacing = new.rt_dose_max_slice_spacing, rt_dose_min_slice_spacing = new.rt_dose_min_slice_spacing
  WHERE (rt_dose_image.rt_dose_id = new.rt_dose_id);


--
-- Name: rt_dose rt_dose_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_dose_insert AS
    ON INSERT TO public.rt_dose DO INSTEAD  UPDATE public.rt_dose SET rt_dose_id = new.rt_dose_id, rt_dose_units = new.rt_dose_units, rt_dose_type = new.rt_dose_type, rt_dose_instance_number = new.rt_dose_instance_number, rt_dose_comment = new.rt_dose_comment, rt_dose_normalization_point = new.rt_dose_normalization_point, rt_dose_summation_type = new.rt_dose_summation_type, rt_dose_referenced_plan_class = new.rt_dose_referenced_plan_class, rt_dose_referenced_plan_uid = new.rt_dose_referenced_plan_uid, rt_dose_tissue_heterogeneity = new.rt_dose_tissue_heterogeneity
  WHERE (rt_dose.rt_dose_id = new.rt_dose_id);


--
-- Name: rt_dvh_rt_dose rt_dvh_rt_dose_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_dvh_rt_dose_delete AS
    ON DELETE TO public.rt_dvh_rt_dose DO INSTEAD  UPDATE public.rt_dvh_rt_dose SET rt_dose_id = NULL::integer, rt_dvh_id = NULL::integer
  WHERE (rt_dvh_rt_dose.rt_dose_id = old.rt_dose_id);


--
-- Name: rt_dvh_rt_dose rt_dvh_rt_dose_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_dvh_rt_dose_insert AS
    ON INSERT TO public.rt_dvh_rt_dose DO INSTEAD  UPDATE public.rt_dvh_rt_dose SET rt_dose_id = new.rt_dose_id, rt_dvh_id = new.rt_dvh_id
  WHERE (rt_dvh_rt_dose.rt_dose_id = new.rt_dose_id);


--
-- Name: rt_plan_respiratory_motion_comp rt_plan_respiratory_motion_comp_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_plan_respiratory_motion_comp_delete AS
    ON DELETE TO public.rt_plan_respiratory_motion_comp DO INSTEAD  UPDATE public.rt_plan_respiratory_motion_comp SET plan_id = NULL::integer, patient_setup_num = NULL::integer, sequence_index = NULL::integer, respiratory_motion_comp_technique = NULL::text, respiratory_signal_source = NULL::text, respiratory_motion_com_tech_desc = NULL::text, respiratory_signal_source_id = NULL::text
  WHERE (rt_plan_respiratory_motion_comp.plan_id = old.plan_id);


--
-- Name: rt_plan_respiratory_motion_comp rt_plan_respiratory_motion_comp_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_plan_respiratory_motion_comp_insert AS
    ON INSERT TO public.rt_plan_respiratory_motion_comp DO INSTEAD  UPDATE public.rt_plan_respiratory_motion_comp SET plan_id = new.plan_id, patient_setup_num = new.patient_setup_num, sequence_index = new.sequence_index, respiratory_motion_comp_technique = new.respiratory_motion_comp_technique, respiratory_signal_source = new.respiratory_signal_source, respiratory_motion_com_tech_desc = new.respiratory_motion_com_tech_desc, respiratory_signal_source_id = new.respiratory_signal_source_id
  WHERE (rt_plan_respiratory_motion_comp.plan_id = new.plan_id);


--
-- Name: rt_prescription rt_prescription_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_prescription_delete AS
    ON DELETE TO public.rt_prescription DO INSTEAD  UPDATE public.rt_prescription SET rt_prescription_id = NULL::integer, plan_id = NULL::integer, rt_prescription_description = NULL::text
  WHERE (rt_prescription.plan_id = old.plan_id);


--
-- Name: rt_prescription rt_prescription_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE rt_prescription_insert AS
    ON INSERT TO public.rt_prescription DO INSTEAD  UPDATE public.rt_prescription SET rt_prescription_id = new.rt_prescription_id, plan_id = new.plan_id, rt_prescription_description = new.rt_prescription_description
  WHERE (rt_prescription.plan_id = new.plan_id);


--
-- Name: slope_intercept slope_intercept_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE slope_intercept_delete AS
    ON DELETE TO public.slope_intercept DO INSTEAD  UPDATE public.slope_intercept SET slope_intercept_id = NULL::integer, slope = NULL::text, intercept = NULL::text, si_units = NULL::text, slopef = NULL::double precision, interceptf = NULL::double precision
  WHERE (slope_intercept.slope_intercept_id = old.slope_intercept_id);


--
-- Name: slope_intercept slope_intercept_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE slope_intercept_insert AS
    ON INSERT TO public.slope_intercept DO INSTEAD  UPDATE public.slope_intercept SET slope_intercept_id = new.slope_intercept_id, slope = new.slope, intercept = new.intercept, si_units = new.si_units, slopef = new.slopef, interceptf = new.interceptf
  WHERE (slope_intercept.slope_intercept_id = new.slope_intercept_id);


--
-- Name: role_tabs role_tabs_query_tab_name_fkey; Type: FK CONSTRAINT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.role_tabs
    ADD CONSTRAINT role_tabs_query_tab_name_fkey FOREIGN KEY (query_tab_name) REFERENCES dbif_config.query_tabs(query_tab_name);


--
-- Name: role_tabs role_tabs_role_name_fkey; Type: FK CONSTRAINT; Schema: dbif_config; Owner: -
--

ALTER TABLE ONLY dbif_config.role_tabs
    ADD CONSTRAINT role_tabs_role_name_fkey FOREIGN KEY (role_name) REFERENCES dbif_config.role(role_name);


--
-- Name: background_subprocess_report background_subprocess_report_background_subprocess_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess_report
    ADD CONSTRAINT background_subprocess_report_background_subprocess_id_fkey FOREIGN KEY (background_subprocess_id) REFERENCES public.background_subprocess(background_subprocess_id);


--
-- Name: downloadable_file downloadable_file_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_file
    ADD CONSTRAINT downloadable_file_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(file_id);


--
-- Name: user_inbox_content user_inbox_content_background_subprocess_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_inbox_content
    ADD CONSTRAINT user_inbox_content_background_subprocess_report_id_fkey FOREIGN KEY (background_subprocess_report_id) REFERENCES public.background_subprocess_report(background_subprocess_report_id);


--
-- Name: user_inbox_content_operation user_inbox_content_operation_user_inbox_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_inbox_content_operation
    ADD CONSTRAINT user_inbox_content_operation_user_inbox_content_id_fkey FOREIGN KEY (user_inbox_content_id) REFERENCES public.user_inbox_content(user_inbox_content_id);


--
-- Name: user_inbox_content user_inbox_content_user_inbox_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_inbox_content
    ADD CONSTRAINT user_inbox_content_user_inbox_id_fkey FOREIGN KEY (user_inbox_id) REFERENCES public.user_inbox(user_inbox_id);

create sequence public.image_image_id_seq start 1;
create sequence public.image_geometry_image_geometry_id_seq start 1;
create sequence public.slope_intercept_slope_intercept_id_seq start 1;
create sequence public.plan_plan_id_seq start 1;

--
-- PostgreSQL database dump complete
--
-- This file is for default values that should be set for a new install,
-- but are not part of the UI configuration or queries themselves.
\connect posda_files

COPY user_inbox (user_inbox_id, user_name, user_email_addr) FROM stdin;
1	admin	admin@admin.bogus
\.

SELECT pg_catalog.setval('user_inbox_user_inbox_id_seq', 1, true);
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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
-- Name: posda_nicknames; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE posda_nicknames WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect posda_nicknames

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
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


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
-- Name: version; Type: TABLE; Schema: db_version; Owner: -
--

CREATE TABLE db_version.version (
    version integer
);


--
-- Name: file_nickname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_nickname (
    project_name text,
    site_name text,
    subj_id text,
    sop_instance_uid text,
    sop_nickname_copy text,
    version_number integer,
    file_digest text
);


--
-- Name: for_nickname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.for_nickname (
    project_name text,
    site_name text,
    subj_id text,
    for_nickname text,
    for_instance_uid text
);


--
-- Name: nickname_sequence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nickname_sequence (
    project_name text,
    site_name text,
    subj_id text,
    nickname_type text,
    next_value integer
);


--
-- Name: series_nickname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.series_nickname (
    project_name text,
    site_name text,
    subj_id text,
    series_nickname text,
    series_instance_uid text
);


--
-- Name: sop_nickname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sop_nickname (
    project_name text,
    site_name text,
    subj_id text,
    sop_nickname text,
    modality text,
    has_modality_conflict boolean,
    sop_instance_uid text
);


--
-- Name: study_nickname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_nickname (
    project_name text,
    site_name text,
    subj_id text,
    study_nickname text,
    study_instance_uid text
);


--
-- Name: file_nickname file_nickname_file_digest_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_nickname
    ADD CONSTRAINT file_nickname_file_digest_key UNIQUE (file_digest);


--
-- Name: file_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_nickname_lookup ON public.file_nickname USING btree (project_name, site_name, subj_id, sop_instance_uid);


--
-- Name: for_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX for_nickname_lookup ON public.for_nickname USING btree (project_name, site_name, subj_id, for_nickname);


--
-- Name: for_nickname_lookup_by_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX for_nickname_lookup_by_uid ON public.for_nickname USING btree (project_name, site_name, subj_id, for_instance_uid);


--
-- Name: series_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX series_nickname_lookup ON public.series_nickname USING btree (project_name, site_name, subj_id, series_nickname);


--
-- Name: series_nickname_lookup_by_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX series_nickname_lookup_by_uid ON public.series_nickname USING btree (project_name, site_name, subj_id, series_instance_uid);


--
-- Name: sop_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sop_nickname_lookup ON public.sop_nickname USING btree (project_name, site_name, subj_id, sop_nickname);


--
-- Name: sop_nickname_lookup_by_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sop_nickname_lookup_by_uid ON public.sop_nickname USING btree (project_name, site_name, subj_id, sop_instance_uid);


--
-- Name: study_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX study_nickname_lookup ON public.study_nickname USING btree (project_name, site_name, subj_id, study_nickname);


--
-- Name: study_nickname_lookup_by_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX study_nickname_lookup_by_uid ON public.study_nickname USING btree (project_name, site_name, subj_id, study_instance_uid);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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
-- Name: posda_phi; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE posda_phi WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect posda_phi

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
-- Name: element_signature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.element_signature (
    element_signature_id integer NOT NULL,
    element_signature text NOT NULL,
    is_private boolean NOT NULL,
    vr text NOT NULL,
    private_disposition text,
    name_chain text
);


--
-- Name: element_signature_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.element_signature_change (
    element_signature_id integer NOT NULL,
    when_sig_changed timestamp with time zone,
    who_changed_sig text,
    old_disposition text,
    old_name_chain text,
    new_disposition text,
    new_name_chain text,
    why_sig_changed text
);


--
-- Name: element_signature_element_signature_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.element_signature_element_signature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: element_signature_element_signature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.element_signature_element_signature_id_seq OWNED BY public.element_signature.element_signature_id;


--
-- Name: equipment_signature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment_signature (
    equipment_signature_id integer NOT NULL,
    equipment_signature text NOT NULL
);


--
-- Name: equipment_signature_equipment_signature_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equipment_signature_equipment_signature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_signature_equipment_signature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equipment_signature_equipment_signature_id_seq OWNED BY public.equipment_signature.equipment_signature_id;


--
-- Name: private_disposition_interpretation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.private_disposition_interpretation (
    disposition text,
    meaning text
);


--
-- Name: public_disposition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_disposition (
    element_signature_id integer NOT NULL,
    sop_class_uid text NOT NULL,
    disposition text,
    name text
);


--
-- Name: public_disposition_interpretation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_disposition_interpretation (
    disposition text,
    meaning text
);


--
-- Name: scan_element; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scan_element (
    scan_element_id integer NOT NULL,
    element_signature_id integer NOT NULL,
    series_scan_id integer NOT NULL,
    seen_value_id integer NOT NULL
);


--
-- Name: scan_element_scan_element_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scan_element_scan_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scan_element_scan_element_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scan_element_scan_element_id_seq OWNED BY public.scan_element.scan_element_id;


--
-- Name: scan_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scan_event (
    scan_event_id integer NOT NULL,
    scan_started timestamp with time zone,
    scan_ended timestamp with time zone,
    scan_status text,
    scan_description text,
    num_series_to_scan integer,
    num_series_scanned integer
);


--
-- Name: scan_event_scan_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scan_event_scan_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scan_event_scan_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scan_event_scan_event_id_seq OWNED BY public.scan_event.scan_event_id;


--
-- Name: seen_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seen_value (
    seen_value_id integer NOT NULL,
    value text
);


--
-- Name: seen_value_seen_value_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seen_value_seen_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seen_value_seen_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seen_value_seen_value_id_seq OWNED BY public.seen_value.seen_value_id;


--
-- Name: sequence_index; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sequence_index (
    scan_element_id integer NOT NULL,
    sequence_level integer NOT NULL,
    item_number integer NOT NULL
);


--
-- Name: series_scan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.series_scan (
    series_scan_id integer NOT NULL,
    scan_event_id integer NOT NULL,
    equipment_signature_id integer NOT NULL,
    series_instance_uid text NOT NULL,
    series_scanned_file text,
    series_scan_status text
);


--
-- Name: series_scan_series_scan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.series_scan_series_scan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_scan_series_scan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.series_scan_series_scan_id_seq OWNED BY public.series_scan.series_scan_id;


--
-- Name: element_signature element_signature_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.element_signature ALTER COLUMN element_signature_id SET DEFAULT nextval('public.element_signature_element_signature_id_seq'::regclass);


--
-- Name: equipment_signature equipment_signature_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_signature ALTER COLUMN equipment_signature_id SET DEFAULT nextval('public.equipment_signature_equipment_signature_id_seq'::regclass);


--
-- Name: scan_element scan_element_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_element ALTER COLUMN scan_element_id SET DEFAULT nextval('public.scan_element_scan_element_id_seq'::regclass);


--
-- Name: scan_event scan_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_event ALTER COLUMN scan_event_id SET DEFAULT nextval('public.scan_event_scan_event_id_seq'::regclass);


--
-- Name: seen_value seen_value_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seen_value ALTER COLUMN seen_value_id SET DEFAULT nextval('public.seen_value_seen_value_id_seq'::regclass);


--
-- Name: series_scan series_scan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series_scan ALTER COLUMN series_scan_id SET DEFAULT nextval('public.series_scan_series_scan_id_seq'::regclass);


--
-- Name: private_disposition_interpretation private_disposition_interpretation_disposition_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_disposition_interpretation
    ADD CONSTRAINT private_disposition_interpretation_disposition_key UNIQUE (disposition);


--
-- Name: public_disposition_interpretation public_disposition_interpretation_disposition_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_disposition_interpretation
    ADD CONSTRAINT public_disposition_interpretation_disposition_key UNIQUE (disposition);


--
-- Name: ele_signature_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ele_signature_index ON public.element_signature USING btree (element_signature, vr);


--
-- Name: scan_element_element_signature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scan_element_element_signature_id_index ON public.scan_element USING btree (element_signature_id);


--
-- Name: scan_element_series_scan_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scan_element_series_scan_id_index ON public.scan_element USING btree (series_scan_id);


--
-- Name: series_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX series_index ON public.series_scan USING btree (series_instance_uid, scan_event_id);


--
-- Name: series_scan_equipment_signature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX series_scan_equipment_signature_id_index ON public.series_scan USING btree (equipment_signature_id);


--
-- Name: series_scan_scan_event_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX series_scan_scan_event_id_index ON public.series_scan USING btree (scan_event_id);


--
-- Name: value_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX value_index ON public.seen_value USING btree (value);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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
-- Name: posda_phi_simple; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE posda_phi_simple WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect posda_phi_simple

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
-- Name: dciodvfy_error; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dciodvfy_error (
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

CREATE SEQUENCE public.dciodvfy_error_dciodvfy_error_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dciodvfy_error_dciodvfy_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dciodvfy_error_dciodvfy_error_id_seq OWNED BY public.dciodvfy_error.dciodvfy_error_id;


--
-- Name: dciodvfy_scan_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dciodvfy_scan_instance (
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

CREATE SEQUENCE public.dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq OWNED BY public.dciodvfy_scan_instance.dciodvfy_scan_instance_id;


--
-- Name: dciodvfy_unit_scan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dciodvfy_unit_scan (
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

CREATE SEQUENCE public.dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq OWNED BY public.dciodvfy_unit_scan.dciodvfy_unit_scan_id;


--
-- Name: dciodvfy_unit_scan_error; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dciodvfy_unit_scan_error (
    dciodvfy_scan_instance_id integer NOT NULL,
    dciodvfy_unit_scan_id integer NOT NULL,
    dciodvfy_error_id integer NOT NULL
);


--
-- Name: dciodvfy_unit_scan_warning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dciodvfy_unit_scan_warning (
    dciodvfy_scan_instance_id integer NOT NULL,
    dciodvfy_unit_scan_id integer NOT NULL,
    dciodvfy_warning_id integer NOT NULL
);


--
-- Name: dciodvfy_warning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dciodvfy_warning (
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

CREATE SEQUENCE public.dciodvfy_warning_dciodvfy_warning_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dciodvfy_warning_dciodvfy_warning_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dciodvfy_warning_dciodvfy_warning_id_seq OWNED BY public.dciodvfy_warning.dciodvfy_warning_id;


--
-- Name: element_disposition_changed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.element_disposition_changed (
    element_seen_id integer NOT NULL,
    when_changed timestamp with time zone,
    who_changed text,
    why_changed text,
    new_disposition text
);


--
-- Name: element_seen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.element_seen (
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

CREATE SEQUENCE public.element_seen_element_seen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: element_seen_element_seen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.element_seen_element_seen_id_seq OWNED BY public.element_seen.element_seen_id;


--
-- Name: element_value_occurance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.element_value_occurance (
    element_seen_id integer NOT NULL,
    value_seen_id integer NOT NULL,
    series_scan_instance_id integer NOT NULL,
    phi_scan_instance_id integer NOT NULL
);


--
-- Name: non_dicom_file_scan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_file_scan (
    non_dicom_file_scan_id integer NOT NULL,
    phi_non_dicom_scan_instance_id integer NOT NULL,
    file_type text NOT NULL,
    file_in_posda boolean,
    file_in_wrapped_tgz boolean,
    posda_file_id integer,
    rel_path text,
    sop_instance_uid text
);


--
-- Name: non_dicom_file_scan_non_dicom_file_scan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.non_dicom_file_scan_non_dicom_file_scan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_dicom_file_scan_non_dicom_file_scan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.non_dicom_file_scan_non_dicom_file_scan_id_seq OWNED BY public.non_dicom_file_scan.non_dicom_file_scan_id;


--
-- Name: non_dicom_path_seen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_path_seen (
    non_dicom_path_seen_id integer NOT NULL,
    non_dicom_file_type text,
    non_dicom_path text
);


--
-- Name: non_dicom_path_seen_non_dicom_path_seen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.non_dicom_path_seen_non_dicom_path_seen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_dicom_path_seen_non_dicom_path_seen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.non_dicom_path_seen_non_dicom_path_seen_id_seq OWNED BY public.non_dicom_path_seen.non_dicom_path_seen_id;


--
-- Name: non_dicom_path_value_occurrance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_dicom_path_value_occurrance (
    non_dicom_path_seen_id integer NOT NULL,
    value_seen_id integer NOT NULL,
    non_dicom_file_scan_id integer NOT NULL
);


--
-- Name: phi_non_dicom_scan_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phi_non_dicom_scan_instance (
    phi_non_dicom_scan_instance_id integer NOT NULL,
    pndsi_description text,
    pndsi_start_time timestamp with time zone,
    pndsi_num_files integer,
    pndsi_num_files_scanned integer,
    pndsi_end_time timestamp with time zone,
    pndsi_process_pid integer
);


--
-- Name: phi_non_dicom_scan_instance_phi_non_dicom_scan_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phi_non_dicom_scan_instance_phi_non_dicom_scan_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phi_non_dicom_scan_instance_phi_non_dicom_scan_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phi_non_dicom_scan_instance_phi_non_dicom_scan_instance_id_seq OWNED BY public.phi_non_dicom_scan_instance.phi_non_dicom_scan_instance_id;


--
-- Name: phi_scan_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phi_scan_instance (
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

CREATE SEQUENCE public.phi_scan_instance_phi_scan_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phi_scan_instance_phi_scan_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phi_scan_instance_phi_scan_instance_id_seq OWNED BY public.phi_scan_instance.phi_scan_instance_id;


--
-- Name: series_scan_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.series_scan_instance (
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

CREATE SEQUENCE public.series_scan_instance_series_scan_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_scan_instance_series_scan_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.series_scan_instance_series_scan_instance_id_seq OWNED BY public.series_scan_instance.series_scan_instance_id;


--
-- Name: value_seen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.value_seen (
    value_seen_id integer NOT NULL,
    value text NOT NULL
);


--
-- Name: value_seen_value_seen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.value_seen_value_seen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: value_seen_value_seen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.value_seen_value_seen_id_seq OWNED BY public.value_seen.value_seen_id;


--
-- Name: dciodvfy_error dciodvfy_error_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dciodvfy_error ALTER COLUMN dciodvfy_error_id SET DEFAULT nextval('public.dciodvfy_error_dciodvfy_error_id_seq'::regclass);


--
-- Name: dciodvfy_scan_instance dciodvfy_scan_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dciodvfy_scan_instance ALTER COLUMN dciodvfy_scan_instance_id SET DEFAULT nextval('public.dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq'::regclass);


--
-- Name: dciodvfy_unit_scan dciodvfy_unit_scan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dciodvfy_unit_scan ALTER COLUMN dciodvfy_unit_scan_id SET DEFAULT nextval('public.dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq'::regclass);


--
-- Name: dciodvfy_warning dciodvfy_warning_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dciodvfy_warning ALTER COLUMN dciodvfy_warning_id SET DEFAULT nextval('public.dciodvfy_warning_dciodvfy_warning_id_seq'::regclass);


--
-- Name: element_seen element_seen_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.element_seen ALTER COLUMN element_seen_id SET DEFAULT nextval('public.element_seen_element_seen_id_seq'::regclass);


--
-- Name: non_dicom_file_scan non_dicom_file_scan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_dicom_file_scan ALTER COLUMN non_dicom_file_scan_id SET DEFAULT nextval('public.non_dicom_file_scan_non_dicom_file_scan_id_seq'::regclass);


--
-- Name: non_dicom_path_seen non_dicom_path_seen_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_dicom_path_seen ALTER COLUMN non_dicom_path_seen_id SET DEFAULT nextval('public.non_dicom_path_seen_non_dicom_path_seen_id_seq'::regclass);


--
-- Name: phi_non_dicom_scan_instance phi_non_dicom_scan_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phi_non_dicom_scan_instance ALTER COLUMN phi_non_dicom_scan_instance_id SET DEFAULT nextval('public.phi_non_dicom_scan_instance_phi_non_dicom_scan_instance_id_seq'::regclass);


--
-- Name: phi_scan_instance phi_scan_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phi_scan_instance ALTER COLUMN phi_scan_instance_id SET DEFAULT nextval('public.phi_scan_instance_phi_scan_instance_id_seq'::regclass);


--
-- Name: series_scan_instance series_scan_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series_scan_instance ALTER COLUMN series_scan_instance_id SET DEFAULT nextval('public.series_scan_instance_series_scan_instance_id_seq'::regclass);


--
-- Name: value_seen value_seen_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.value_seen ALTER COLUMN value_seen_id SET DEFAULT nextval('public.value_seen_value_seen_id_seq'::regclass);


--
-- Name: value_seen value_seen_value_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.value_seen
    ADD CONSTRAINT value_seen_value_key UNIQUE (value);


--
-- Name: element_seen_and_value_seen_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX element_seen_and_value_seen_index ON public.element_value_occurance USING btree (element_seen_id, value_seen_id);


--
-- Name: element_seen_vr_pair_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX element_seen_vr_pair_index ON public.element_seen USING btree (element_sig_pattern, vr);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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
-- Name: private_tag_kb; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE private_tag_kb WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect private_tag_kb

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
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


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
-- Name: version; Type: TABLE; Schema: db_version; Owner: -
--

CREATE TABLE db_version.version (
    version integer
);


--
-- Name: pt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pt (
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

CREATE TABLE public.pt_dcmtk (
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

CREATE TABLE public.pt_dicom3 (
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

CREATE TABLE public.pt_gdcm (
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

CREATE TABLE public.pt_observation (
    pt_id integer NOT NULL,
    pt_obs_observer text,
    pt_obs_value text,
    pt_obs_comment text,
    pt_obs_time timestamp with time zone
);


--
-- Name: pt_pt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pt_pt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pt_pt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pt_pt_id_seq OWNED BY public.pt.pt_id;


--
-- Name: pt_wustl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pt_wustl (
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

CREATE TABLE public.ptrg (
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

CREATE TABLE public.ptrg_observation (
    ptrg_id integer NOT NULL,
    ptrg_obs_observer text,
    ptrg_obs_value text,
    ptrg_obs_comment text,
    ptrg_obs_time timestamp with time zone
);


--
-- Name: ptrg_ptrg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ptrg_ptrg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ptrg_ptrg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ptrg_ptrg_id_seq OWNED BY public.ptrg.ptrg_id;


--
-- Name: pt pt_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pt ALTER COLUMN pt_id SET DEFAULT nextval('public.pt_pt_id_seq'::regclass);


--
-- Name: ptrg ptrg_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptrg ALTER COLUMN ptrg_id SET DEFAULT nextval('public.ptrg_ptrg_id_seq'::regclass);


--
-- Name: pt pt_pt_signature_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pt
    ADD CONSTRAINT pt_pt_signature_key UNIQUE (pt_signature);


--
-- Name: ptrg ptrg_ptrg_signature_masked_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptrg
    ADD CONSTRAINT ptrg_ptrg_signature_masked_key UNIQUE (ptrg_signature_masked);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

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
-- Name: public_tag_disposition; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE public_tag_disposition WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect public_tag_disposition

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
-- Name: public_tag_disposition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_tag_disposition (
    tag_name text,
    name text,
    disposition text
);


--
-- Name: public_tag_disposition public_tag_disposition_tag_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_tag_disposition
    ADD CONSTRAINT public_tag_disposition_tag_name_key UNIQUE (tag_name);


--
-- PostgreSQL database dump complete
--

