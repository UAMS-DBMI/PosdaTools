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
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: quasar
--

CREATE SCHEMA db_version;


ALTER SCHEMA db_version OWNER TO quasar;

SET search_path = db_version, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: version; Type: TABLE; Schema: db_version; Owner: quasar
--

CREATE TABLE version (
    version integer
);


ALTER TABLE version OWNER TO quasar;

SET search_path = public, pg_catalog;

--
-- Name: apps; Type: TABLE; Schema: public; Owner: posda
--

CREATE TABLE apps (
    app_id integer NOT NULL,
    app_name text NOT NULL
);


ALTER TABLE apps OWNER TO posda;

--
-- Name: apps_app_id_seq; Type: SEQUENCE; Schema: public; Owner: posda
--

CREATE SEQUENCE apps_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE apps_app_id_seq OWNER TO posda;

--
-- Name: apps_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: posda
--

ALTER SEQUENCE apps_app_id_seq OWNED BY apps.app_id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: posda
--

CREATE TABLE permissions (
    permission_id integer NOT NULL,
    app_id integer,
    permission_name text NOT NULL
);


ALTER TABLE permissions OWNER TO posda;

--
-- Name: permissions_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: posda
--

CREATE SEQUENCE permissions_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE permissions_permission_id_seq OWNER TO posda;

--
-- Name: permissions_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: posda
--

ALTER SEQUENCE permissions_permission_id_seq OWNED BY permissions.permission_id;


--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: posda
--

CREATE TABLE user_permissions (
    user_id integer,
    permission_id integer
);


ALTER TABLE user_permissions OWNER TO posda;

--
-- Name: users; Type: TABLE; Schema: public; Owner: posda
--

CREATE TABLE users (
    user_id integer NOT NULL,
    user_name text NOT NULL,
    full_name text NOT NULL,
    password text
);


ALTER TABLE users OWNER TO posda;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: posda
--

CREATE SEQUENCE users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_user_id_seq OWNER TO posda;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: posda
--

ALTER SEQUENCE users_user_id_seq OWNED BY users.user_id;


--
-- Name: app_id; Type: DEFAULT; Schema: public; Owner: posda
--

ALTER TABLE ONLY apps ALTER COLUMN app_id SET DEFAULT nextval('apps_app_id_seq'::regclass);


--
-- Name: permission_id; Type: DEFAULT; Schema: public; Owner: posda
--

ALTER TABLE ONLY permissions ALTER COLUMN permission_id SET DEFAULT nextval('permissions_permission_id_seq'::regclass);


--
-- Name: user_id; Type: DEFAULT; Schema: public; Owner: posda
--

ALTER TABLE ONLY users ALTER COLUMN user_id SET DEFAULT nextval('users_user_id_seq'::regclass);


SET search_path = db_version, pg_catalog;

--
-- Data for Name: version; Type: TABLE DATA; Schema: db_version; Owner: quasar
--

COPY version (version) FROM stdin;
0
\.


SET search_path = public, pg_catalog;

--
-- Data for Name: apps; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY apps (app_id, app_name) FROM stdin;
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
11	SeriesProjection
12	NewItcTools
\.


--
-- Name: apps_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('apps_app_id_seq', 12, true);


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY permissions (permission_id, app_id, permission_name) FROM stdin;
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
40	10	count_check
22	11	launch
23	11	debug
38	10	superuser
41	10	curation
42	10	scripting
43	10	legacy
44	12	debug
45	12	launch
46	10	db_admin
\.


--
-- Name: permissions_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('permissions_permission_id_seq', 46, true);


--
-- Data for Name: user_permissions; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY user_permissions (user_id, permission_id) FROM stdin;
2	6
2	22
2	23
2	5
2	2
2	40
2	13
2	1
2	42
2	10
2	41
2	20
2	43
2	38
2	3
2	12
1	41
1	20
1	40
1	1
1	11
1	42
1	10
10	22
10	43
\N	20
\N	2
\N	12
\N	10
10	10
7	6
7	2
7	43
7	10
9	41
9	6
9	22
9	2
9	43
9	10
8	41
8	20
8	6
8	16
8	2
8	43
8	40
8	42
8	12
8	10
3	6
3	16
3	22
3	23
3	40
3	1
3	11
3	45
3	42
3	10
3	41
3	20
3	43
3	46
3	38
3	44
11	2
11	10
4	41
4	20
4	6
4	22
4	2
4	43
4	40
4	46
4	38
4	1
4	4
4	3
4	42
4	10
6	6
6	22
6	23
6	40
6	42
6	10
6	41
6	20
6	43
6	38
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY users (user_id, user_name, full_name, password) FROM stdin;
1	admin	Default Admin Account	aJE5lY8D,2wUueoiymAn8HsfbdAp0kPfTiODV7kpeNUttYTgQGbE
7	shariq		AvwVFLM5,vMRDkcfnuhstqBDhIVLu4Vrid7soxybBMba1UdCwXd4
8	priorf		ZTTYkcLw,7a0qa6BId+PJt15N/8BKKwyPx/qZymAc+PbUiLWUR8A
6	tracyn		QOlYzjoD,yKNlQeHtHuf5R92nC/VBjd3rRZYbgG83qSdYDpGDsu4
3	bbennett		W2oSUYeR,eVYXp9iUOhU4rjivA67LEyCkybexNuLoU4uT62Fst+w
2	quasarj	Quasar Jarosz	JmssXSwo,6LjR/4e7LVqBJFG98SR+e2oG1L0fB23p91ET5PfY4Y4
4	ksmith01		2ewMuHxL,06MQ0iT5me5AH0E814tXzGbFFlYOZgoqrTVTYxmU3JE
9	smberryman		TQrjhGqY,Tnv7aHo0kjwNHdhdQs5xk43Ubf5cNEMmYceEb/F+3cI
10	DCStockton		DrKpVrut,BxS3vHV37LNTN8ZlKJWtdVxLdSIAg5gfwffTlhhNQ1E
11	rddobbins		ogDtl7RI,nn3Gdby/WAPIdiYf18iuH97dNoNJLodqdopja4fHa1Q
\.


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('users_user_id_seq', 11, true);


--
-- Name: apps_pkey; Type: CONSTRAINT; Schema: public; Owner: posda
--

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (app_id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: posda
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (permission_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: posda
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users_user_name_key; Type: CONSTRAINT; Schema: public; Owner: posda
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_user_name_key UNIQUE (user_name);


--
-- Name: permissions_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: posda
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps(app_id) ON DELETE CASCADE;


--
-- Name: user_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: posda
--

ALTER TABLE ONLY user_permissions
    ADD CONSTRAINT user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE;


--
-- Name: user_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: posda
--

ALTER TABLE ONLY user_permissions
    ADD CONSTRAINT user_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

