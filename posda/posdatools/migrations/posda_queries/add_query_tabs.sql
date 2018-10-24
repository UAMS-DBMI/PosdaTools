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
-- Name: query_tabs; Type: TABLE; Schema: public; Owner: posda; Tablespace: 
--

CREATE TABLE query_tabs (
    query_tab_name text,
    query_tab_description text,
    defines_dropdown boolean,
    sort_order integer,
    defines_search_engine boolean
);



--
-- Data for Name: query_tabs; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY query_tabs (query_tab_name, query_tab_description, defines_dropdown, sort_order, defines_search_engine) FROM stdin;
legacy	compatable with old interface	t	99	f
count_check	for checking counts	t	10	f
curation	queries used in curation	t	20	f
scripting	queries used in scripts	t	50	f
\.


--
-- Name: query_tabs_query_tab_name_key; Type: CONSTRAINT; Schema: public; Owner: posda; Tablespace: 
--

ALTER TABLE ONLY query_tabs
    ADD CONSTRAINT query_tabs_query_tab_name_key UNIQUE (query_tab_name);


--
-- PostgreSQL database dump complete
--

