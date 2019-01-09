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

