--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.5 (Ubuntu 10.5-0ubuntu0.18.04)

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
-- Name: background_buttons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_buttons (
    background_button_id integer NOT NULL,
    operation_name text,
    object_class text,
    button_text text,
    tags text[]
);


--
-- Name: background_buttons_background_button_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.background_buttons_background_button_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: background_buttons_background_button_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.background_buttons_background_button_id_seq OWNED BY public.background_buttons.background_button_id;


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
    process_error text
);


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
-- Name: chained_query; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chained_query (
    chained_query_id integer NOT NULL,
    from_query text NOT NULL,
    to_query text NOT NULL,
    caption text
);


--
-- Name: chained_query_chained_query_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chained_query_chained_query_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chained_query_chained_query_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chained_query_chained_query_id_seq OWNED BY public.chained_query.chained_query_id;


--
-- Name: chained_query_cols_to_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chained_query_cols_to_params (
    chained_query_id integer NOT NULL,
    from_column_name text NOT NULL,
    to_parameter_name text NOT NULL
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
-- Name: dicom_module_to_posda_table; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_module_to_posda_table (
    dicom_module_name text,
    create_row_query text,
    table_name text
);


--
-- Name: dicom_tag_parm_column_table; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_tag_parm_column_table (
    tag text,
    tag_cannonical_name text,
    posda_table_name text,
    column_name text
);


--
-- Name: popup_buttons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.popup_buttons (
    popup_button_id integer NOT NULL,
    name text,
    object_class text,
    btn_col text,
    is_full_table boolean,
    btn_name text
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
-- Name: popup_buttons_popup_button_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.popup_buttons_popup_button_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: popup_buttons_popup_button_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.popup_buttons_popup_button_id_seq1 OWNED BY public.popup_buttons.popup_button_id;


--
-- Name: queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.queries (
    name text,
    query text,
    args text[],
    columns text[],
    tags text[],
    schema text,
    description text
);


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
-- Name: query_tabs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.query_tabs (
    query_tab_name text,
    query_tab_description text,
    defines_dropdown boolean,
    sort_order integer,
    defines_search_engine boolean
);


--
-- Name: query_tabs_query_tag_filter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.query_tabs_query_tag_filter (
    query_tab_name text NOT NULL,
    filter_name text NOT NULL,
    sort_order integer NOT NULL
);


--
-- Name: query_tag_filter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.query_tag_filter (
    filter_name text,
    tags_enabled text[]
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
-- Name: role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role (
    role_name text NOT NULL
);


--
-- Name: role_tabs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_tabs (
    role_name text,
    query_tab_name text,
    sort_order integer
);


--
-- Name: spreadsheet_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spreadsheet_operation (
    operation_name text NOT NULL,
    command_line text,
    operation_type text,
    input_line_format text,
    tags text[]
);


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
    operation_name text
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
-- Name: tag_preparation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_preparation (
    tag_cannonical_name text,
    preparation_description text
);


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
-- Name: activity activity_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity ALTER COLUMN activity_id SET DEFAULT nextval('public.activity_activity_id_seq'::regclass);


--
-- Name: activity_timepoint activity_timepoint_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_timepoint ALTER COLUMN activity_timepoint_id SET DEFAULT nextval('public.activity_timepoint_activity_timepoint_id_seq'::regclass);


--
-- Name: background_buttons background_button_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_buttons ALTER COLUMN background_button_id SET DEFAULT nextval('public.background_buttons_background_button_id_seq'::regclass);


--
-- Name: background_subprocess background_subprocess_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess ALTER COLUMN background_subprocess_id SET DEFAULT nextval('public.background_subprocess_background_subprocess_id_seq'::regclass);


--
-- Name: background_subprocess_report background_subprocess_report_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess_report ALTER COLUMN background_subprocess_report_id SET DEFAULT nextval('public.background_subprocess_report_background_subprocess_report_i_seq'::regclass);


--
-- Name: chained_query chained_query_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chained_query ALTER COLUMN chained_query_id SET DEFAULT nextval('public.chained_query_chained_query_id_seq'::regclass);


--
-- Name: popup_buttons popup_button_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.popup_buttons ALTER COLUMN popup_button_id SET DEFAULT nextval('public.popup_buttons_popup_button_id_seq1'::regclass);


--
-- Name: query_invoked_by_dbif query_invoked_by_dbif_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_invoked_by_dbif ALTER COLUMN query_invoked_by_dbif_id SET DEFAULT nextval('public.query_invoked_by_dbif_query_invoked_by_dbif_id_seq'::regclass);


--
-- Name: report_inserted report_inserted_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_inserted ALTER COLUMN report_inserted_id SET DEFAULT nextval('public.report_inserted_report_inserted_id_seq'::regclass);


--
-- Name: spreadsheet_uploaded spreadsheet_uploaded_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spreadsheet_uploaded ALTER COLUMN spreadsheet_uploaded_id SET DEFAULT nextval('public.spreadsheet_uploaded_spreadsheet_uploaded_id_seq'::regclass);


--
-- Name: subprocess_invocation subprocess_invocation_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subprocess_invocation ALTER COLUMN subprocess_invocation_id SET DEFAULT nextval('public.subprocess_invocation_subprocess_invocation_id_seq'::regclass);


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
-- Name: background_buttons background_buttons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_buttons
    ADD CONSTRAINT background_buttons_pkey PRIMARY KEY (background_button_id);


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
-- Name: background_subprocess_report background_subprocess_report_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess_report
    ADD CONSTRAINT background_subprocess_report_uniq UNIQUE (background_subprocess_id, file_id);


--
-- Name: popup_buttons popup_buttons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.popup_buttons
    ADD CONSTRAINT popup_buttons_pkey PRIMARY KEY (popup_button_id);


--
-- Name: query_tabs query_tabs_query_tab_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_tabs
    ADD CONSTRAINT query_tabs_query_tab_name_key UNIQUE (query_tab_name);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_name);


--
-- Name: spreadsheet_operation spreadsheet_operation_operation_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spreadsheet_operation
    ADD CONSTRAINT spreadsheet_operation_operation_name_key UNIQUE (operation_name);


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
-- Name: queries_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX queries_name_index ON public.queries USING btree (name);


--
-- Name: query_by_user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX query_by_user_index ON public.query_invoked_by_dbif USING btree (invoking_user);


--
-- Name: role_tabs_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX role_tabs_uidx ON public.role_tabs USING btree (role_name, query_tab_name);


--
-- Name: background_subprocess_report background_subprocess_report_background_subprocess_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_subprocess_report
    ADD CONSTRAINT background_subprocess_report_background_subprocess_id_fkey FOREIGN KEY (background_subprocess_id) REFERENCES public.background_subprocess(background_subprocess_id);


--
-- Name: role_tabs role_tabs_query_tab_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_tabs
    ADD CONSTRAINT role_tabs_query_tab_name_fkey FOREIGN KEY (query_tab_name) REFERENCES public.query_tabs(query_tab_name);


--
-- Name: role_tabs role_tabs_role_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_tabs
    ADD CONSTRAINT role_tabs_role_name_fkey FOREIGN KEY (role_name) REFERENCES public.role(role_name);


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


--
-- PostgreSQL database dump complete
--

