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
-- Name: queries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE queries (
    name text PRIMARY KEY,
    query text,
    args text[],
    columns text[],
    tags text[],
    schema text,
    description text
);


CREATE TABLE query_tag_filter (
    filter_name text PRIMARY KEY,
    tags_enabled text[]
);


CREATE TABLE spreadsheet_operation (
    operation_name text NOT NULL PRIMARY KEY,
    command_line text,
    operation_type text,
    input_line_format text,
    tags text[]
);
