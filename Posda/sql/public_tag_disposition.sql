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

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: public_tag_disposition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public_tag_disposition (
    tag_name text,
    name text,
    disposition text
);


--
-- Name: public_tag_disposition_tag_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public_tag_disposition
    ADD CONSTRAINT public_tag_disposition_tag_name_key UNIQUE (tag_name);


--
-- PostgreSQL database dump complete
--

