--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
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

create schema auth;
SET search_path to auth;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth.apps (
    app_id integer NOT NULL,
    app_name text NOT NULL
);


ALTER TABLE auth.apps OWNER TO postgres;

--
-- Name: apps_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth.apps_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.apps_app_id_seq OWNER TO postgres;

--
-- Name: apps_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth.apps_app_id_seq OWNED BY auth.apps.app_id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth.permissions (
    permission_id integer NOT NULL,
    app_id integer,
    permission_name text NOT NULL
);


ALTER TABLE auth.permissions OWNER TO postgres;

--
-- Name: permissions_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth.permissions_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.permissions_permission_id_seq OWNER TO postgres;

--
-- Name: permissions_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth.permissions_permission_id_seq OWNED BY auth.permissions.permission_id;


--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth.user_permissions (
    user_id integer,
    permission_id integer
);


ALTER TABLE auth.user_permissions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth.users (
    user_id integer NOT NULL,
    user_name text NOT NULL,
    full_name text NOT NULL,
    password text
);


ALTER TABLE auth.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth.users_user_id_seq OWNED BY auth.users.user_id;


--
-- Name: apps app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.apps ALTER COLUMN app_id SET DEFAULT nextval('auth.apps_app_id_seq'::regclass);


--
-- Name: permissions permission_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.permissions ALTER COLUMN permission_id SET DEFAULT nextval('auth.permissions_permission_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.users ALTER COLUMN user_id SET DEFAULT nextval('auth.users_user_id_seq'::regclass);


--
-- Data for Name: apps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth.apps (app_id, app_name) FROM stdin;
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


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth.permissions (permission_id, app_id, permission_name) FROM stdin;
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


--
-- Data for Name: user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth.user_permissions (user_id, permission_id) FROM stdin;
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
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth.users (user_id, user_name, full_name, password) FROM stdin;
1	admin	Default Admin Account	aJE5lY8D,2wUueoiymAn8HsfbdAp0kPfTiODV7kpeNUttYTgQGbE
\.


--
-- Name: apps_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth.apps_app_id_seq', 12, true);


--
-- Name: permissions_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth.permissions_permission_id_seq', 49, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth.users_user_id_seq', 2, true);


--
-- Name: apps apps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (app_id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (permission_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_user_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_user_name_key UNIQUE (user_name);


--
-- Name: permissions permissions_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT permissions_app_id_fkey FOREIGN KEY (app_id) REFERENCES auth.apps(app_id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.user_permissions
    ADD CONSTRAINT user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth.permissions(permission_id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth.user_permissions
    ADD CONSTRAINT user_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

