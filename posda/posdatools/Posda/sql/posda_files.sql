--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.10 (Ubuntu 10.10-0ubuntu0.18.04.1)

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
SET xmloption = content;
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
    when_closed timestamp with time zone,
    third_party_analysis_url text
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
    dismissed_by text,
    manual_update boolean
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
-- Name: button_popularity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.button_popularity (
    processname text NOT NULL,
    created timestamp without time zone NOT NULL
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
-- Name: dedup_dicom_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dedup_dicom_file (
    file_id integer,
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
    has_no_roi_linkages boolean
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
-- Name: dicom_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dicom_file (
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
    has_no_roi_linkages boolean
);


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
-- Name: file_ct_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_ct_image (
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
-- Name: file_dose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_dose (
    rt_dose_id integer NOT NULL,
    file_id integer NOT NULL
);


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
-- Name: file_equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_equipment (
    file_id integer NOT NULL,
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
    pixel_pad integer
);


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
-- Name: file_for; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_for (
    file_id integer NOT NULL,
    for_uid text,
    position_ref_indicator text
);


--
-- Name: file_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_image (
    file_id integer NOT NULL,
    image_id integer NOT NULL,
    content_date date,
    content_time time without time zone
);


--
-- Name: file_image_geometry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_image_geometry (
    file_id integer NOT NULL,
    image_geometry_id integer NOT NULL
);


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
-- Name: file_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_meta (
    file_id integer NOT NULL,
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
    private_info text
);


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
-- Name: file_patient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_patient (
    file_id integer NOT NULL,
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
    patient_age text
);


--
-- Name: file_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_plan (
    plan_id integer NOT NULL,
    file_id integer NOT NULL
);


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
-- Name: file_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_series (
    file_id integer NOT NULL,
    modality text NOT NULL,
    series_instance_uid text NOT NULL,
    series_number integer,
    laterality text,
    series_date date,
    series_time time without time zone,
    performing_phys text,
    protocol_name text,
    series_description text,
    operators_name text,
    body_part_examined text,
    patient_position text,
    smallest_pixel_value integer,
    largest_pixel_value integer,
    performed_procedure_step_id text,
    performed_procedure_step_start_date date,
    performed_procedure_step_start_time time without time zone,
    performed_procedure_step_desc text,
    performed_procedure_step_comments text,
    date_fixed boolean
);


--
-- Name: file_slope_intercept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_slope_intercept (
    file_id integer NOT NULL,
    slope_intercept_id integer NOT NULL
);


--
-- Name: file_sop_common; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_sop_common (
    file_id integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL,
    specific_character_set text,
    creation_date date,
    creation_time time without time zone,
    creator_uid text,
    related_general_sop_class text,
    original_specialized_sop_class text,
    offset_from_utc integer,
    instance_number text,
    instance_status text,
    auth_date_time time with time zone,
    auth_comment text,
    auth_cert_num text
);


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
-- Name: file_structure_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_structure_set (
    file_id integer NOT NULL,
    structure_set_id integer NOT NULL,
    instance_number text
);


--
-- Name: file_study; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_study (
    file_id integer NOT NULL,
    study_instance_uid text NOT NULL,
    study_date date,
    study_time time without time zone,
    referring_phy_name text,
    study_id text,
    accession_number text,
    study_description text,
    phys_of_record text,
    phys_reading text,
    admitting_diag text
);


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
-- Name: files_without_location; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.files_without_location AS
 SELECT a.file_id,
    a.digest,
    a.size,
    a.is_dicom_file,
    a.file_type,
    a.processing_priority,
    a.ready_to_process
   FROM (public.file a
     LEFT JOIN public.file_location b ON ((a.file_id = b.file_id)))
  WHERE (b.file_id IS NULL)
  WITH NO DATA;


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
-- Name: image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image (
    image_id integer NOT NULL,
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
    col_spacing double precision
);


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
-- Name: image_geometry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_geometry (
    image_geometry_id integer NOT NULL,
    image_id integer NOT NULL,
    iop text,
    ipp text,
    for_uid text,
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
    pos_z double precision
);


--
-- Name: image_geometry_image_geometry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.image_geometry_image_geometry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_geometry_image_geometry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.image_geometry_image_geometry_id_seq OWNED BY public.image_geometry.image_geometry_id;


--
-- Name: image_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.image_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.image_image_id_seq OWNED BY public.image.image_id;


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
-- Name: plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan (
    plan_id integer NOT NULL,
    plan_label text NOT NULL,
    plan_name text,
    plan_description text,
    instance_number integer,
    operators_name text,
    rt_plan_date date,
    rt_plan_time time without time zone,
    rt_treatment_protocols text,
    plan_intent text,
    treatment_sites text,
    rt_plan_geometry text NOT NULL,
    ss_referenced_from_plan text
);


--
-- Name: plan_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plan_plan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plan_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plan_plan_id_seq OWNED BY public.plan.plan_id;


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
-- Name: public_copy_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_copy_status (
    subprocess_invocation_id integer NOT NULL,
    file_id integer NOT NULL,
    success boolean,
    error_message text
);


--
-- Name: TABLE public_copy_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.public_copy_status IS 'Store the status of attempts to copy files to public';


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
-- Name: rt_dose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dose (
    rt_dose_id integer NOT NULL,
    rt_dose_units text,
    rt_dose_type text,
    rt_dose_instance_number text,
    rt_dose_comment text,
    rt_dose_normalization_point text,
    rt_dose_summation_type text,
    rt_dose_referenced_plan_class text,
    rt_dose_referenced_plan_uid text,
    rt_dose_tissue_heterogeneity text
);


--
-- Name: rt_dose_gfov; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dose_gfov (
    rt_dose_id integer NOT NULL,
    rt_gfov_index integer NOT NULL,
    gfov_offset double precision
);


--
-- Name: rt_dose_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dose_image (
    rt_dose_id integer NOT NULL,
    image_id integer NOT NULL,
    rt_dose_grid_frame_offset_vector text,
    rt_dose_grid_scaling double precision,
    rt_dose_max_slice_spacing double precision,
    rt_dose_min_slice_spacing double precision
);


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
-- Name: rt_dose_rt_dose_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rt_dose_rt_dose_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_dose_rt_dose_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rt_dose_rt_dose_id_seq OWNED BY public.rt_dose.rt_dose_id;


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
-- Name: rt_dvh_rt_dose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_dvh_rt_dose (
    rt_dose_id integer NOT NULL,
    rt_dvh_id integer NOT NULL
);


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
-- Name: rt_plan_respiratory_motion_comp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_plan_respiratory_motion_comp (
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    sequence_index integer NOT NULL,
    respiratory_motion_comp_technique text,
    respiratory_signal_source text,
    respiratory_motion_com_tech_desc text,
    respiratory_signal_source_id text
);


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
-- Name: rt_prescription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_prescription (
    rt_prescription_id integer NOT NULL,
    plan_id integer NOT NULL,
    rt_prescription_description text
);


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
-- Name: rt_prescription_rt_prescription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rt_prescription_rt_prescription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_prescription_rt_prescription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rt_prescription_rt_prescription_id_seq OWNED BY public.rt_prescription.rt_prescription_id;


--
-- Name: site_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_codes (
    site_name text NOT NULL,
    site_code text NOT NULL
);


--
-- Name: slope_intercept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slope_intercept (
    slope_intercept_id integer NOT NULL,
    slope text NOT NULL,
    intercept text NOT NULL,
    si_units text,
    slopef double precision,
    interceptf double precision
);


--
-- Name: slope_intercept_slope_intercept_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slope_intercept_slope_intercept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slope_intercept_slope_intercept_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slope_intercept_slope_intercept_id_seq OWNED BY public.slope_intercept.slope_intercept_id;


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
-- Name: image image_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image ALTER COLUMN image_id SET DEFAULT nextval('public.image_image_id_seq'::regclass);


--
-- Name: image_equivalence_class image_equivalence_class_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_equivalence_class ALTER COLUMN image_equivalence_class_id SET DEFAULT nextval('public.image_equivalence_class_image_equivalence_class_id_seq'::regclass);


--
-- Name: image_geometry image_geometry_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_geometry ALTER COLUMN image_geometry_id SET DEFAULT nextval('public.image_geometry_image_geometry_id_seq'::regclass);


--
-- Name: import_event import_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_event ALTER COLUMN import_event_id SET DEFAULT nextval('public.import_event_import_event_id_seq'::regclass);


--
-- Name: plan plan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan ALTER COLUMN plan_id SET DEFAULT nextval('public.plan_plan_id_seq'::regclass);


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
-- Name: rt_dose rt_dose_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_dose ALTER COLUMN rt_dose_id SET DEFAULT nextval('public.rt_dose_rt_dose_id_seq'::regclass);


--
-- Name: rt_dvh rt_dvh_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_dvh ALTER COLUMN rt_dvh_id SET DEFAULT nextval('public.rt_dvh_rt_dvh_id_seq'::regclass);


--
-- Name: rt_dvh_dvh rt_dvh_dvh_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_dvh_dvh ALTER COLUMN rt_dvh_dvh_id SET DEFAULT nextval('public.rt_dvh_dvh_rt_dvh_dvh_id_seq'::regclass);


--
-- Name: rt_prescription rt_prescription_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_prescription ALTER COLUMN rt_prescription_id SET DEFAULT nextval('public.rt_prescription_rt_prescription_id_seq'::regclass);


--
-- Name: slope_intercept slope_intercept_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slope_intercept ALTER COLUMN slope_intercept_id SET DEFAULT nextval('public.slope_intercept_slope_intercept_id_seq'::regclass);


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
-- Name: file_ct_image file_ct_image__new_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_ct_image
    ADD CONSTRAINT file_ct_image__new_pkey PRIMARY KEY (file_id);


--
-- Name: file_equipment file_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_equipment
    ADD CONSTRAINT file_equipment_pkey PRIMARY KEY (file_id);


--
-- Name: file_for file_for_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_for
    ADD CONSTRAINT file_for_pkey PRIMARY KEY (file_id);


--
-- Name: file_meta file_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_meta
    ADD CONSTRAINT file_meta_pkey PRIMARY KEY (file_id);


--
-- Name: file_mr file_mr_file_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_mr
    ADD CONSTRAINT file_mr_file_id_key UNIQUE (file_id);


--
-- Name: file_patient file_patient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_patient
    ADD CONSTRAINT file_patient_pkey PRIMARY KEY (file_id);


--
-- Name: file_pt_image file_pt_image_file_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_pt_image
    ADD CONSTRAINT file_pt_image_file_id_key UNIQUE (file_id);


--
-- Name: file_series file_series_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_series
    ADD CONSTRAINT file_series_pkey PRIMARY KEY (file_id);


--
-- Name: file_sop_common file_sop_common_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_sop_common
    ADD CONSTRAINT file_sop_common_pkey PRIMARY KEY (file_id);


--
-- Name: file_study file_study_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_study
    ADD CONSTRAINT file_study_pkey PRIMARY KEY (file_id);


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
-- Name: public_copy_status public_copy_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_copy_status
    ADD CONSTRAINT public_copy_status_pkey PRIMARY KEY (subprocess_invocation_id, file_id);


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
-- Name: subprocess_invocation subprocess_invocation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subprocess_invocation
    ADD CONSTRAINT subprocess_invocation_pkey PRIMARY KEY (subprocess_invocation_id);


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
-- Name: dicom_file_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_file_file_id_index ON public.dicom_file USING btree (file_id);


--
-- Name: dicom_file_send_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_file_send_idx ON public.dicom_file_send USING btree (dicom_send_event_id);


--
-- Name: dicom_process_errors_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_process_errors_file_id_idx ON public.dicom_process_errors USING btree (file_id);


--
-- Name: dicom_send_event_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dicom_send_event_pk ON public.dicom_send_event USING btree (dicom_send_event_id);


--
-- Name: file_ct_image_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_ct_image_file_id_index ON public.file_ct_image__old USING btree (file_id);


--
-- Name: file_digest_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_digest_index ON public.file USING btree (digest);


--
-- Name: file_dose_file_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_dose_file_idx ON public.file_dose USING btree (file_id);


--
-- Name: file_dose_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_dose_idx ON public.file_dose USING btree (rt_dose_id);


--
-- Name: file_ele_ref_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_ele_ref_pk ON public.file_ele_ref USING btree (file_ele_ref_id);


--
-- Name: file_equipment_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_equipment_file_id_idx ON public.file_equipment USING btree (file_id);


--
-- Name: file_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_file_id_idx ON public.file USING btree (file_id);


--
-- Name: file_for_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_for_file_id_idx ON public.file_for USING btree (file_id);


--
-- Name: file_image_geometry_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_image_geometry_file_id_idx ON public.file_image_geometry USING btree (file_id);


--
-- Name: file_image_geometry_image_geometry_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_image_geometry_image_geometry_id_idx ON public.file_image_geometry USING btree (image_geometry_id);


--
-- Name: file_image_main_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_image_main_idx ON public.file_image USING btree (file_id, image_id);


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
-- Name: file_patient_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_patient_file_id_index ON public.file_patient USING btree (file_id);


--
-- Name: file_patient_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_patient_patient_id_index ON public.file_patient USING btree (patient_id);


--
-- Name: file_plan_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_plan_file_id_idx ON public.file_plan USING btree (file_id);


--
-- Name: file_plan_plan_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_plan_plan_id_idx ON public.file_plan USING btree (plan_id);


--
-- Name: file_roi_image_linkage_linked_sop_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_roi_image_linkage_linked_sop_idx ON public.file_roi_image_linkage USING btree (linked_sop_instance_uid);


--
-- Name: file_series_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_series_file_id_index ON public.file_series USING btree (file_id);


--
-- Name: file_series_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_series_uid_idx ON public.file_series USING btree (series_instance_uid);


--
-- Name: file_slope_intercept_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_slope_intercept_file_id_idx ON public.file_slope_intercept USING btree (file_id);


--
-- Name: file_slope_intercept_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_slope_intercept_id_idx ON public.file_slope_intercept USING btree (slope_intercept_id);


--
-- Name: file_sop_common_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_sop_common_file_id_idx ON public.file_sop_common USING btree (file_id);


--
-- Name: file_sop_common_sop_instance_uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_sop_common_sop_instance_uid_index ON public.file_sop_common USING btree (sop_instance_uid);


--
-- Name: file_storage_root_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_storage_root_pk ON public.file_storage_root USING btree (file_storage_root_id);


--
-- Name: file_structure_set_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_structure_set_idx ON public.file_structure_set USING btree (file_id, structure_set_id);


--
-- Name: file_study_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_study_file_id_index ON public.file_study USING btree (file_id);


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
-- Name: image_geometry_image_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_geometry_image_id_index ON public.image_geometry USING btree (image_id);


--
-- Name: image_geometry_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX image_geometry_pk ON public.image_geometry USING btree (image_geometry_id);


--
-- Name: image_image_id_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX image_image_id_pk ON public.image USING btree (image_id);


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
-- Name: plan_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plan_pk ON public.plan USING btree (plan_id);


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
-- Name: rt_dose_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_dose_image_idx ON public.rt_dose_image USING btree (rt_dose_id);


--
-- Name: rt_dose_image_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_dose_image_image_idx ON public.rt_dose_image USING btree (image_id);


--
-- Name: rt_dose_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rt_dose_pk ON public.rt_dose USING btree (rt_dose_id);


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
-- Name: rt_prescription_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rt_prescription_pk ON public.rt_prescription USING btree (rt_prescription_id);


--
-- Name: rt_prescription_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_prescription_plan_idx ON public.rt_prescription USING btree (plan_id);


--
-- Name: slope_intercept_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX slope_intercept_pk ON public.slope_intercept USING btree (slope_intercept_id);


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
-- Name: unique_pixel_date_image; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unique_pixel_date_image ON public.image USING btree (unique_pixel_data_id);


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
-- Name: public_copy_status public_copy_status_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_copy_status
    ADD CONSTRAINT public_copy_status_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(file_id);


--
-- Name: public_copy_status public_copy_status_subprocess_invocation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_copy_status
    ADD CONSTRAINT public_copy_status_subprocess_invocation_id_fkey FOREIGN KEY (subprocess_invocation_id) REFERENCES public.subprocess_invocation(subprocess_invocation_id);


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

