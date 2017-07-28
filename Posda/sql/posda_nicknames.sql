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
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


SET search_path = db_version, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: version; Type: TABLE; Schema: db_version; Owner: -
--

CREATE TABLE version (
    version integer
);


SET search_path = public, pg_catalog;

--
-- Name: file_nickname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_nickname (
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

CREATE TABLE for_nickname (
    project_name text,
    site_name text,
    subj_id text,
    for_nickname text,
    for_instance_uid text
);


--
-- Name: nickname_sequence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE nickname_sequence (
    project_name text,
    site_name text,
    subj_id text,
    nickname_type text,
    next_value integer
);


--
-- Name: series_nickname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE series_nickname (
    project_name text,
    site_name text,
    subj_id text,
    series_nickname text,
    series_instance_uid text
);


--
-- Name: sop_nickname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sop_nickname (
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

CREATE TABLE study_nickname (
    project_name text,
    site_name text,
    subj_id text,
    study_nickname text,
    study_instance_uid text
);


--
-- Name: file_nickname_file_digest_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_nickname
    ADD CONSTRAINT file_nickname_file_digest_key UNIQUE (file_digest);


--
-- Name: file_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_nickname_lookup ON file_nickname USING btree (project_name, site_name, subj_id, sop_instance_uid);


--
-- Name: for_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX for_nickname_lookup ON for_nickname USING btree (project_name, site_name, subj_id, for_nickname);


--
-- Name: for_nickname_lookup_by_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX for_nickname_lookup_by_uid ON for_nickname USING btree (project_name, site_name, subj_id, for_instance_uid);


--
-- Name: series_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX series_nickname_lookup ON series_nickname USING btree (project_name, site_name, subj_id, series_nickname);


--
-- Name: series_nickname_lookup_by_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX series_nickname_lookup_by_uid ON series_nickname USING btree (project_name, site_name, subj_id, series_instance_uid);


--
-- Name: sop_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sop_nickname_lookup ON sop_nickname USING btree (project_name, site_name, subj_id, sop_nickname);


--
-- Name: sop_nickname_lookup_by_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sop_nickname_lookup_by_uid ON sop_nickname USING btree (project_name, site_name, subj_id, sop_instance_uid);


--
-- Name: study_nickname_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX study_nickname_lookup ON study_nickname USING btree (project_name, site_name, subj_id, study_nickname);


--
-- Name: study_nickname_lookup_by_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX study_nickname_lookup_by_uid ON study_nickname USING btree (project_name, site_name, subj_id, study_instance_uid);


--
-- PostgreSQL database dump complete
--

