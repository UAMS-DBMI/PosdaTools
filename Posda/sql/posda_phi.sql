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
-- Name: element_signature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE element_signature (
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

CREATE TABLE element_signature_change (
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

CREATE SEQUENCE element_signature_element_signature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: element_signature_element_signature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE element_signature_element_signature_id_seq OWNED BY element_signature.element_signature_id;


--
-- Name: equipment_signature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE equipment_signature (
    equipment_signature_id integer NOT NULL,
    equipment_signature text NOT NULL
);


--
-- Name: equipment_signature_equipment_signature_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE equipment_signature_equipment_signature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_signature_equipment_signature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE equipment_signature_equipment_signature_id_seq OWNED BY equipment_signature.equipment_signature_id;


--
-- Name: private_disposition_interpretation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE private_disposition_interpretation (
    disposition text,
    meaning text
);


--
-- Name: public_disposition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public_disposition (
    element_signature_id integer NOT NULL,
    sop_class_uid text NOT NULL,
    disposition text,
    name text
);


--
-- Name: public_disposition_interpretation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public_disposition_interpretation (
    disposition text,
    meaning text
);


--
-- Name: scan_element; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE scan_element (
    scan_element_id integer NOT NULL,
    element_signature_id integer NOT NULL,
    series_scan_id integer NOT NULL,
    seen_value_id integer NOT NULL
);


--
-- Name: scan_element_scan_element_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scan_element_scan_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scan_element_scan_element_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scan_element_scan_element_id_seq OWNED BY scan_element.scan_element_id;


--
-- Name: scan_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE scan_event (
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

CREATE SEQUENCE scan_event_scan_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scan_event_scan_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scan_event_scan_event_id_seq OWNED BY scan_event.scan_event_id;


--
-- Name: seen_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE seen_value (
    seen_value_id integer NOT NULL,
    value text
);


--
-- Name: seen_value_seen_value_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE seen_value_seen_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seen_value_seen_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE seen_value_seen_value_id_seq OWNED BY seen_value.seen_value_id;


--
-- Name: sequence_index; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sequence_index (
    scan_element_id integer NOT NULL,
    sequence_level integer NOT NULL,
    item_number integer NOT NULL
);


--
-- Name: series_scan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE series_scan (
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

CREATE SEQUENCE series_scan_series_scan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_scan_series_scan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE series_scan_series_scan_id_seq OWNED BY series_scan.series_scan_id;


--
-- Name: element_signature_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY element_signature ALTER COLUMN element_signature_id SET DEFAULT nextval('element_signature_element_signature_id_seq'::regclass);


--
-- Name: equipment_signature_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY equipment_signature ALTER COLUMN equipment_signature_id SET DEFAULT nextval('equipment_signature_equipment_signature_id_seq'::regclass);


--
-- Name: scan_element_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scan_element ALTER COLUMN scan_element_id SET DEFAULT nextval('scan_element_scan_element_id_seq'::regclass);


--
-- Name: scan_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scan_event ALTER COLUMN scan_event_id SET DEFAULT nextval('scan_event_scan_event_id_seq'::regclass);


--
-- Name: seen_value_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY seen_value ALTER COLUMN seen_value_id SET DEFAULT nextval('seen_value_seen_value_id_seq'::regclass);


--
-- Name: series_scan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_scan ALTER COLUMN series_scan_id SET DEFAULT nextval('series_scan_series_scan_id_seq'::regclass);


--
-- Name: private_disposition_interpretation_disposition_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY private_disposition_interpretation
    ADD CONSTRAINT private_disposition_interpretation_disposition_key UNIQUE (disposition);


--
-- Name: public_disposition_interpretation_disposition_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public_disposition_interpretation
    ADD CONSTRAINT public_disposition_interpretation_disposition_key UNIQUE (disposition);


--
-- Name: ele_signature_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ele_signature_index ON element_signature USING btree (element_signature, vr);


--
-- Name: scan_element_element_signature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scan_element_element_signature_id_index ON scan_element USING btree (element_signature_id);


--
-- Name: scan_element_series_scan_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scan_element_series_scan_id_index ON scan_element USING btree (series_scan_id);


--
-- Name: series_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX series_index ON series_scan USING btree (series_instance_uid, scan_event_id);


--
-- Name: series_scan_equipment_signature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX series_scan_equipment_signature_id_index ON series_scan USING btree (equipment_signature_id);


--
-- Name: series_scan_scan_event_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX series_scan_scan_event_id_index ON series_scan USING btree (scan_event_id);


--
-- Name: value_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX value_index ON seen_value USING btree (value);


--
-- PostgreSQL database dump complete
--

