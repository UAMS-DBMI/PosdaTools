--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


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
-- Name: adverse_file_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE adverse_file_event (
    adverse_file_event_id integer NOT NULL,
    file_id integer NOT NULL,
    event_description text,
    when_occured timestamp with time zone
);


--
-- Name: adverse_file_event_adverse_file_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE adverse_file_event_adverse_file_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: adverse_file_event_adverse_file_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE adverse_file_event_adverse_file_event_id_seq OWNED BY adverse_file_event.adverse_file_event_id;


--
-- Name: association; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE association (
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

CREATE SEQUENCE association_association_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: association_association_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE association_association_id_seq OWNED BY association.association_id;


--
-- Name: association_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE association_errors (
    association_id integer NOT NULL,
    error_type text,
    error_line text
);


--
-- Name: association_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE association_file (
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

CREATE TABLE association_import (
    association_id integer NOT NULL,
    import_event_id integer NOT NULL
);


--
-- Name: association_pc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE association_pc (
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

CREATE SEQUENCE association_pc_association_pc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: association_pc_association_pc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE association_pc_association_pc_id_seq OWNED BY association_pc.association_pc_id;


--
-- Name: association_pc_proposed_ts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE association_pc_proposed_ts (
    association_pc_id integer NOT NULL,
    proposed_ts_uid text NOT NULL
);


--
-- Name: beam_applicator; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE beam_applicator (
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

CREATE TABLE beam_block (
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

CREATE TABLE beam_bolus (
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

CREATE TABLE beam_compensator (
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

CREATE TABLE beam_control_point (
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

CREATE TABLE beam_general_accessory (
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

CREATE TABLE beam_limiting_device (
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

CREATE TABLE beam_wedge (
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
-- Name: contour_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contour_image (
    roi_contour_id integer NOT NULL,
    sop_class text NOT NULL,
    sop_instance text NOT NULL,
    frame_number integer
);


--
-- Name: control_point_bld_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE control_point_bld_position (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    bld_type text NOT NULL,
    leaf_jaw_positions text NOT NULL
);


--
-- Name: control_point_dose_reference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE control_point_dose_reference (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);


--
-- Name: control_point_reference_dose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE control_point_reference_dose (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    referenced_dose_reference_number integer NOT NULL,
    cumulative_dose_ref_coefficent text
);


--
-- Name: control_point_wedge_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE control_point_wedge_position (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    wedge_number integer NOT NULL,
    wedge_position text NOT NULL
);


--
-- Name: copy_from_public; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE copy_from_public (
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

CREATE SEQUENCE copy_from_public_copy_from_public_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: copy_from_public_copy_from_public_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE copy_from_public_copy_from_public_id_seq OWNED BY copy_from_public.copy_from_public_id;


--
-- Name: ctp_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ctp_file (
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

CREATE TABLE ctp_file_new (
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

CREATE TABLE ctp_filex (
    file_id integer,
    project_name text,
    trial_name text,
    site_name text,
    site_id text,
    visibility text
);


--
-- Name: ctp_upload_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ctp_upload_event (
    file_id integer NOT NULL,
    rcv_timestamp timestamp with time zone NOT NULL
);


--
-- Name: dicom_dir; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_dir (
    file_id integer NOT NULL,
    fs_id text,
    fs_desc text,
    spec_char_set_of_desc text
);


--
-- Name: dicom_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_dir_rec (
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

CREATE SEQUENCE dicom_dir_rec_dicom_dir_rec_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dicom_dir_rec_dicom_dir_rec_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dicom_dir_rec_dicom_dir_rec_id_seq OWNED BY dicom_dir_rec.dicom_dir_rec_id;


--
-- Name: dicom_edit_compare; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_edit_compare (
    from_file_digest text NOT NULL,
    to_file_digest text NOT NULL,
    short_report_file_id integer NOT NULL,
    long_report_file_id integer NOT NULL,
    to_file_path text,
    subprocess_invocation_id integer NOT NULL
);


--
-- Name: dicom_edit_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_edit_event (
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

CREATE TABLE dicom_edit_event_adverse_file_event (
    dicom_edit_event_id integer NOT NULL,
    adverse_file_event_id integer NOT NULL
);


--
-- Name: dicom_edit_event_dicom_edit_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dicom_edit_event_dicom_edit_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dicom_edit_event_dicom_edit_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dicom_edit_event_dicom_edit_event_id_seq OWNED BY dicom_edit_event.dicom_edit_event_id;


--
-- Name: dicom_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_file (
    file_id integer NOT NULL,
    dataset_digest text,
    xfr_stx text,
    has_meta boolean,
    is_dicom_dir boolean,
    has_sop_common boolean,
    dicom_file_type text
);


--
-- Name: dicom_file_edit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_file_edit (
    dicom_edit_event_id integer NOT NULL,
    from_file_digest text NOT NULL,
    to_file_digest text NOT NULL
);


--
-- Name: dicom_file_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_file_errors (
    file_id integer NOT NULL,
    error_msg text
);


--
-- Name: dicom_file_send; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_file_send (
    dicom_send_event_id integer NOT NULL,
    file_path text,
    status text,
    file_id_sent integer
);


--
-- Name: dicom_icon_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_icon_image (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    image_id integer NOT NULL
);


--
-- Name: dicom_image_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_image_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_image_spec_char_set text,
    instance_number integer
);


--
-- Name: dicom_patient_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_patient_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_patient_spec_char_set text,
    patients_name text,
    patient_id text
);


--
-- Name: dicom_process_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_process_errors (
    file_id integer NOT NULL,
    error_msg text
);


--
-- Name: dicom_rt_dose_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_rt_dose_dir_rec (
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

CREATE TABLE dicom_rt_plan_dir_rec (
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

CREATE TABLE dicom_rt_structure_set_dir_rec (
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

CREATE TABLE dicom_rt_treatment_rec_dir_rec (
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

CREATE TABLE dicom_send_event (
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

CREATE SEQUENCE dicom_send_event_dicom_send_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dicom_send_event_dicom_send_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dicom_send_event_dicom_send_event_id_seq OWNED BY dicom_send_event.dicom_send_event_id;


--
-- Name: dicom_series_dir_rec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dicom_series_dir_rec (
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

CREATE TABLE dicom_study_dir_rec (
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

CREATE TABLE distinguished_pixel_digest_pixel_value (
    pixel_digest text NOT NULL,
    pixel_value integer NOT NULL,
    num_occurances integer NOT NULL
);


--
-- Name: distinguished_pixel_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE distinguished_pixel_digests (
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

CREATE TABLE dose_referenced_from_beam (
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);


--
-- Name: dose_referenced_from_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dose_referenced_from_plan (
    plan_id integer NOT NULL,
    dose_sop_instance_uid text
);


--
-- Name: downloadable_dir; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE downloadable_dir (
    downloadable_dir_id integer NOT NULL,
    security_hash text NOT NULL,
    creation_date timestamp without time zone NOT NULL,
    path text NOT NULL
);


--
-- Name: downloadable_dir_downloadable_dir_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE downloadable_dir_downloadable_dir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloadable_dir_downloadable_dir_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE downloadable_dir_downloadable_dir_id_seq OWNED BY downloadable_dir.downloadable_dir_id;


--
-- Name: downloadable_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE downloadable_file (
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

CREATE SEQUENCE downloadable_file_downloadable_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloadable_file_downloadable_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE downloadable_file_downloadable_file_id_seq OWNED BY downloadable_file.downloadable_file_id;


--
-- Name: file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file (
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

CREATE TABLE file_copy_from_public (
    copy_from_public_id integer NOT NULL,
    sop_instance_uid text,
    replace_file_id integer,
    inserted_file_id integer,
    copy_file_path text
);


--
-- Name: file_ct_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_ct_image (
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

CREATE TABLE file_ct_image__old (
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

CREATE TABLE file_dose (
    rt_dose_id integer NOT NULL,
    file_id integer NOT NULL
);


--
-- Name: file_ele_ref; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_ele_ref (
    file_ele_ref_id integer NOT NULL,
    file_id integer,
    ele_sig text
);


--
-- Name: file_ele_ref_file_ele_ref_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_ele_ref_file_ele_ref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_ele_ref_file_ele_ref_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_ele_ref_file_ele_ref_id_seq OWNED BY file_ele_ref.file_ele_ref_id;


--
-- Name: file_ele_ref_text_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_ele_ref_text_value (
    file_ele_ref_id integer NOT NULL,
    text_value text
);


--
-- Name: file_equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_equipment (
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

CREATE SEQUENCE file_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_file_id_seq OWNED BY file.file_id;


--
-- Name: file_for; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_for (
    file_id integer NOT NULL,
    for_uid text,
    position_ref_indicator text
);


--
-- Name: file_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_image (
    file_id integer NOT NULL,
    image_id integer NOT NULL,
    content_date date,
    content_time time without time zone
);


--
-- Name: file_image_geometry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_image_geometry (
    file_id integer NOT NULL,
    image_geometry_id integer NOT NULL
);


--
-- Name: file_import; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_import (
    import_event_id integer NOT NULL,
    file_id integer NOT NULL,
    rel_path text,
    rel_dir text,
    file_name text
);


--
-- Name: file_import_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_import_series (
    file_import_series_id integer NOT NULL,
    file_id integer NOT NULL,
    import_event_id integer NOT NULL,
    series_instance_uid text NOT NULL,
    modality text NOT NULL
);


--
-- Name: file_import_series_file_import_series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_import_series_file_import_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_import_series_file_import_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_import_series_file_import_series_id_seq OWNED BY file_import_series.file_import_series_id;


--
-- Name: file_import_study; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_import_study (
    file_import_study_id integer NOT NULL,
    file_id integer NOT NULL,
    import_event_id integer NOT NULL,
    study_instance_uid text NOT NULL
);


--
-- Name: file_import_study_file_import_study_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_import_study_file_import_study_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_import_study_file_import_study_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_import_study_file_import_study_id_seq OWNED BY file_import_study.file_import_study_id;


--
-- Name: file_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_location (
    file_id integer NOT NULL,
    file_storage_root_id integer NOT NULL,
    rel_path text NOT NULL,
    is_home text
);


--
-- Name: file_locationx; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_locationx (
    file_id integer,
    file_storage_root_id integer,
    rel_path text,
    is_home text
);


--
-- Name: file_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_meta (
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
-- Name: file_patient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_patient (
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
    comments text
);


--
-- Name: file_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_plan (
    plan_id integer NOT NULL,
    file_id integer NOT NULL
);


--
-- Name: file_pt_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_pt_image (
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

CREATE TABLE file_roi_image_linkage (
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

CREATE TABLE file_series (
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

CREATE TABLE file_slope_intercept (
    file_id integer NOT NULL,
    slope_intercept_id integer NOT NULL
);


--
-- Name: file_sop_common; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_sop_common (
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

CREATE TABLE file_storage_root (
    file_storage_root_id integer NOT NULL,
    root_path text,
    current boolean,
    storage_class text
);


--
-- Name: file_storage_root_file_storage_root_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_storage_root_file_storage_root_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_storage_root_file_storage_root_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_storage_root_file_storage_root_id_seq OWNED BY file_storage_root.file_storage_root_id;


--
-- Name: file_structure_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_structure_set (
    file_id integer NOT NULL,
    structure_set_id integer NOT NULL,
    instance_number text
);


--
-- Name: file_study; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_study (
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

CREATE TABLE file_visibility_change (
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

CREATE TABLE file_win_lev (
    file_id integer NOT NULL,
    window_level_id integer NOT NULL,
    wl_index integer NOT NULL
);


--
-- Name: for_registration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE for_registration (
    ss_for_id integer NOT NULL,
    from_for_uid text NOT NULL,
    xform_type text,
    xform text,
    xform_comment text
);


--
-- Name: foreign_keys_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW foreign_keys_view AS
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

CREATE TABLE fraction_reference_beam (
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

CREATE TABLE fraction_reference_brachy (
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    brachy_application_setup_number integer NOT NULL,
    brachy_application_setup_dose_specification_point text,
    brachy_application_setup_dose text
);


--
-- Name: fraction_reference_dose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fraction_reference_dose (
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

CREATE TABLE fraction_related_dose (
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);


--
-- Name: image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image (
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

CREATE TABLE image_equivalence_class (
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

CREATE SEQUENCE image_equivalence_class_image_equivalence_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_equivalence_class_image_equivalence_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE image_equivalence_class_image_equivalence_class_id_seq OWNED BY image_equivalence_class.image_equivalence_class_id;


--
-- Name: image_equivalence_class_input_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image_equivalence_class_input_image (
    image_equivalence_class_id integer NOT NULL,
    file_id integer NOT NULL
);


--
-- Name: image_equivalence_class_out_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image_equivalence_class_out_image (
    image_equivalence_class_id integer NOT NULL,
    projection_type text NOT NULL,
    file_id integer NOT NULL
);


--
-- Name: image_frame_offset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image_frame_offset (
    image_id integer NOT NULL,
    frame_index integer,
    frame_offset text
);


--
-- Name: image_geometry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image_geometry (
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

CREATE SEQUENCE image_geometry_image_geometry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_geometry_image_geometry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE image_geometry_image_geometry_id_seq OWNED BY image_geometry.image_geometry_id;


--
-- Name: image_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE image_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE image_image_id_seq OWNED BY image.image_id;


--
-- Name: image_referenced_from_beam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image_referenced_from_beam (
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

CREATE TABLE image_slope_intercept (
    image_id integer NOT NULL,
    slope_intercept_id integer NOT NULL
);


--
-- Name: image_window_level; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image_window_level (
    window_level_id integer NOT NULL,
    image_id integer NOT NULL
);


--
-- Name: import_control; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE import_control (
    status text,
    processor_pid integer,
    idle_seconds integer,
    pending_change_request text,
    files_per_round integer
);


--
-- Name: import_ct_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE import_ct_series (
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
-- Name: import_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE import_event (
    import_event_id integer NOT NULL,
    import_type text,
    importing_user text,
    originating_ip_addr text,
    import_comment text,
    import_time timestamp with time zone,
    remote_file text,
    volume_name text
);


--
-- Name: import_event_import_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE import_event_import_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_event_import_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE import_event_import_event_id_seq OWNED BY import_event.import_event_id;


--
-- Name: log_iec_hide; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE log_iec_hide (
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

CREATE TABLE missing_files (
    file_path character varying(200),
    missing character varying(3)
);


--
-- Name: missing_from_db; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE missing_from_db (
    file_path character varying(200),
    missing character varying(3)
);


--
-- Name: missing_from_fs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE missing_from_fs (
    filename text,
    is_dicom_file boolean,
    file_type text
);


--
-- Name: patient_import_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE patient_import_status (
    patient_id text NOT NULL,
    patient_import_status text
);


--
-- Name: patient_import_status_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE patient_import_status_change (
    patient_id text NOT NULL,
    when_pat_stat_changed timestamp with time zone,
    old_pat_status text,
    new_pat_status text,
    pat_stat_change_who text,
    pat_stat_change_why text
);


--
-- Name: pixel_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pixel_location (
    unique_pixel_data_id integer NOT NULL,
    file_id integer NOT NULL,
    file_offset integer NOT NULL
);


--
-- Name: plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE plan (
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

CREATE SEQUENCE plan_plan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plan_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE plan_plan_id_seq OWNED BY plan.plan_id;


--
-- Name: plan_related_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE plan_related_plans (
    plan_id integer NOT NULL,
    related_plan_instance_uid text,
    plan_relationship text
);


--
-- Name: planned_verification_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE planned_verification_images (
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
-- Name: posda_public_compare; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE posda_public_compare (
    background_subprocess_id integer NOT NULL,
    sop_instance_uid text NOT NULL,
    from_file_id integer NOT NULL,
    short_report_file_id integer NOT NULL,
    long_report_file_id integer NOT NULL,
    to_file_path text NOT NULL
);


--
-- Name: related_roi_observations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE related_roi_observations (
    roi_observation_id integer NOT NULL,
    related_roi_observation_num integer NOT NULL
);


--
-- Name: roi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roi (
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

CREATE TABLE roi_contour (
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

CREATE SEQUENCE roi_contour_roi_contour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roi_contour_roi_contour_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roi_contour_roi_contour_id_seq OWNED BY roi_contour.roi_contour_id;


--
-- Name: roi_elemental_composition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roi_elemental_composition (
    roi_phyical_properties_id integer NOT NULL,
    roi_elemental_composition_atomic_number text,
    roi_elemental_composition_atomic_mass_fraction text
);


--
-- Name: roi_observation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roi_observation (
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

CREATE SEQUENCE roi_observation_roi_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roi_observation_roi_observation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roi_observation_roi_observation_id_seq OWNED BY roi_observation.roi_observation_id;


--
-- Name: roi_physical_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roi_physical_properties (
    roi_phyical_properties_id integer NOT NULL,
    roi_observation_id integer NOT NULL,
    property text,
    property_value text
);


--
-- Name: roi_physical_properties_roi_phyical_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roi_physical_properties_roi_phyical_properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roi_physical_properties_roi_phyical_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roi_physical_properties_roi_phyical_properties_id_seq OWNED BY roi_physical_properties.roi_phyical_properties_id;


--
-- Name: roi_related_roi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roi_related_roi (
    roi_id integer NOT NULL,
    related_roi_id integer NOT NULL,
    relationship text
);


--
-- Name: roi_roi_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roi_roi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roi_roi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roi_roi_id_seq OWNED BY roi.roi_id;


--
-- Name: rt_beam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_beam (
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

CREATE TABLE rt_beam_limit_dev_tolerance (
    plan_id integer NOT NULL,
    tolerance_table_number integer NOT NULL,
    beam_limit_dev_type text,
    beam_limit_dev_pos_tolerance text
);


--
-- Name: rt_beam_tolerance_table; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_beam_tolerance_table (
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

CREATE TABLE rt_dose (
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

CREATE TABLE rt_dose_gfov (
    rt_dose_id integer NOT NULL,
    rt_gfov_index integer NOT NULL,
    gfov_offset double precision
);


--
-- Name: rt_dose_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_dose_image (
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

CREATE TABLE rt_dose_ref_beam (
    rt_dose_id integer NOT NULL,
    rt_dose_frac_group_number integer NOT NULL,
    rt_dose_beam_number integer NOT NULL,
    rt_dose_cp_start integer,
    rt_dose_cp_stop integer
);


--
-- Name: rt_dose_ref_brachy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_dose_ref_brachy (
    rt_dose_id integer NOT NULL,
    rt_dose_ref_bracy_setup_number integer NOT NULL
);


--
-- Name: rt_dose_rt_dose_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rt_dose_rt_dose_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_dose_rt_dose_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rt_dose_rt_dose_id_seq OWNED BY rt_dose.rt_dose_id;


--
-- Name: rt_dvh; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_dvh (
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

CREATE TABLE rt_dvh_available_rois (
    rt_dvh_dvh_id integer NOT NULL,
    available_rois text
);


--
-- Name: rt_dvh_dvh; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_dvh_dvh (
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

CREATE TABLE rt_dvh_dvh_data (
    rt_dvh_dvh_id integer NOT NULL,
    rt_dvh_dvh_index integer NOT NULL,
    rt_dvh_dvh_data double precision
);


--
-- Name: rt_dvh_dvh_dose_bins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_dvh_dvh_dose_bins (
    rt_dvh_dvh_id integer NOT NULL,
    bin_dose_cgy double precision NOT NULL,
    cum_percent_vol double precision NOT NULL,
    cum_cm3_vol double precision NOT NULL,
    cum_percent_prescription_dose double precision
);


--
-- Name: rt_dvh_dvh_roi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_dvh_dvh_roi (
    rt_dvh_dvh_id integer NOT NULL,
    rt_dvh_dvh_ref_roi_number integer,
    rt_dvh_dvh_roi_cont_type text
);


--
-- Name: rt_dvh_dvh_rt_dvh_dvh_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rt_dvh_dvh_rt_dvh_dvh_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_dvh_dvh_rt_dvh_dvh_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rt_dvh_dvh_rt_dvh_dvh_id_seq OWNED BY rt_dvh_dvh.rt_dvh_dvh_id;


--
-- Name: rt_dvh_protocol_case_roi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_dvh_protocol_case_roi (
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

CREATE TABLE rt_dvh_rt_dose (
    rt_dose_id integer NOT NULL,
    rt_dvh_id integer NOT NULL
);


--
-- Name: rt_dvh_rt_dvh_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rt_dvh_rt_dvh_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_dvh_rt_dvh_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rt_dvh_rt_dvh_id_seq OWNED BY rt_dvh.rt_dvh_id;


--
-- Name: rt_plan_fraction_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_plan_fraction_group (
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

CREATE TABLE rt_plan_patient_setup (
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

CREATE TABLE rt_plan_respiratory_motion_comp (
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

CREATE TABLE rt_plan_setup_device (
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

CREATE TABLE rt_plan_setup_fixation_device (
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

CREATE TABLE rt_plan_setup_image (
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    setup_image_comment text,
    image_sop_class_uid text,
    image_sop_instance_uid text
);


--
-- Name: rt_plan_setup_shielding_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_plan_setup_shielding_device (
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

CREATE TABLE rt_prescription (
    rt_prescription_id integer NOT NULL,
    plan_id integer NOT NULL,
    rt_prescription_description text
);


--
-- Name: rt_prescription_dose_ref; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rt_prescription_dose_ref (
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

CREATE SEQUENCE rt_prescription_rt_prescription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_prescription_rt_prescription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rt_prescription_rt_prescription_id_seq OWNED BY rt_prescription.rt_prescription_id;


--
-- Name: slope_intercept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE slope_intercept (
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

CREATE SEQUENCE slope_intercept_slope_intercept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slope_intercept_slope_intercept_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slope_intercept_slope_intercept_id_seq OWNED BY slope_intercept.slope_intercept_id;


--
-- Name: ss_for; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ss_for (
    ss_for_id integer NOT NULL,
    structure_set_id integer NOT NULL,
    for_uid text NOT NULL
);


--
-- Name: ss_for_ss_for_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ss_for_ss_for_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ss_for_ss_for_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ss_for_ss_for_id_seq OWNED BY ss_for.ss_for_id;


--
-- Name: ss_volume; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ss_volume (
    ss_for_id integer NOT NULL,
    study_instance_uid text NOT NULL,
    series_instance_uid text NOT NULL,
    sop_class text NOT NULL,
    sop_instance text NOT NULL
);


--
-- Name: structure_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE structure_set (
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

CREATE SEQUENCE structure_set_structure_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: structure_set_structure_set_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE structure_set_structure_set_id_seq OWNED BY structure_set.structure_set_id;


--
-- Name: submission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE submission (
    import_event_id integer NOT NULL,
    institution text,
    year integer,
    month_i integer,
    month text
);


--
-- Name: unique_pixel_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE unique_pixel_data (
    unique_pixel_data_id integer NOT NULL,
    digest text NOT NULL,
    size integer
);


--
-- Name: unique_pixel_data_unique_pixel_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unique_pixel_data_unique_pixel_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unique_pixel_data_unique_pixel_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unique_pixel_data_unique_pixel_data_id_seq OWNED BY unique_pixel_data.unique_pixel_data_id;


--
-- Name: visual_review_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE visual_review_instance (
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

CREATE SEQUENCE visual_review_instance_visual_review_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visual_review_instance_visual_review_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE visual_review_instance_visual_review_instance_id_seq OWNED BY visual_review_instance.visual_review_instance_id;


--
-- Name: window_level; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE window_level (
    window_level_id integer NOT NULL,
    window_width text NOT NULL,
    window_center text NOT NULL,
    win_lev_desc text
);


--
-- Name: window_level_window_level_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE window_level_window_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: window_level_window_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE window_level_window_level_id_seq OWNED BY window_level.window_level_id;


SET search_path = quasar, pg_catalog;

--
-- Name: kirk_series; Type: TABLE; Schema: quasar; Owner: -
--

CREATE TABLE kirk_series (
    series_instance_uid text NOT NULL
);


--
-- Name: sops; Type: TABLE; Schema: quasar; Owner: -
--

CREATE TABLE sops (
    sop_instance_uid text NOT NULL
);


--
-- Name: sops_and_ids; Type: TABLE; Schema: quasar; Owner: -
--

CREATE TABLE sops_and_ids (
    sop_instance_uid text NOT NULL,
    patient_id text
);


--
-- Name: temp; Type: TABLE; Schema: quasar; Owner: -
--

CREATE TABLE temp (
    file_id integer
);


SET search_path = public, pg_catalog;

--
-- Name: adverse_file_event adverse_file_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY adverse_file_event ALTER COLUMN adverse_file_event_id SET DEFAULT nextval('adverse_file_event_adverse_file_event_id_seq'::regclass);


--
-- Name: association association_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY association ALTER COLUMN association_id SET DEFAULT nextval('association_association_id_seq'::regclass);


--
-- Name: association_pc association_pc_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY association_pc ALTER COLUMN association_pc_id SET DEFAULT nextval('association_pc_association_pc_id_seq'::regclass);


--
-- Name: copy_from_public copy_from_public_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY copy_from_public ALTER COLUMN copy_from_public_id SET DEFAULT nextval('copy_from_public_copy_from_public_id_seq'::regclass);


--
-- Name: dicom_dir_rec dicom_dir_rec_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dicom_dir_rec ALTER COLUMN dicom_dir_rec_id SET DEFAULT nextval('dicom_dir_rec_dicom_dir_rec_id_seq'::regclass);


--
-- Name: dicom_edit_event dicom_edit_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dicom_edit_event ALTER COLUMN dicom_edit_event_id SET DEFAULT nextval('dicom_edit_event_dicom_edit_event_id_seq'::regclass);


--
-- Name: dicom_send_event dicom_send_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dicom_send_event ALTER COLUMN dicom_send_event_id SET DEFAULT nextval('dicom_send_event_dicom_send_event_id_seq'::regclass);


--
-- Name: downloadable_dir downloadable_dir_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloadable_dir ALTER COLUMN downloadable_dir_id SET DEFAULT nextval('downloadable_dir_downloadable_dir_id_seq'::regclass);


--
-- Name: downloadable_file downloadable_file_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloadable_file ALTER COLUMN downloadable_file_id SET DEFAULT nextval('downloadable_file_downloadable_file_id_seq'::regclass);


--
-- Name: file file_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file ALTER COLUMN file_id SET DEFAULT nextval('file_file_id_seq'::regclass);


--
-- Name: file_ele_ref file_ele_ref_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_ele_ref ALTER COLUMN file_ele_ref_id SET DEFAULT nextval('file_ele_ref_file_ele_ref_id_seq'::regclass);


--
-- Name: file_import_series file_import_series_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_import_series ALTER COLUMN file_import_series_id SET DEFAULT nextval('file_import_series_file_import_series_id_seq'::regclass);


--
-- Name: file_import_study file_import_study_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_import_study ALTER COLUMN file_import_study_id SET DEFAULT nextval('file_import_study_file_import_study_id_seq'::regclass);


--
-- Name: file_storage_root file_storage_root_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_storage_root ALTER COLUMN file_storage_root_id SET DEFAULT nextval('file_storage_root_file_storage_root_id_seq'::regclass);


--
-- Name: image image_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY image ALTER COLUMN image_id SET DEFAULT nextval('image_image_id_seq'::regclass);


--
-- Name: image_equivalence_class image_equivalence_class_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_equivalence_class ALTER COLUMN image_equivalence_class_id SET DEFAULT nextval('image_equivalence_class_image_equivalence_class_id_seq'::regclass);


--
-- Name: image_geometry image_geometry_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_geometry ALTER COLUMN image_geometry_id SET DEFAULT nextval('image_geometry_image_geometry_id_seq'::regclass);


--
-- Name: import_event import_event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY import_event ALTER COLUMN import_event_id SET DEFAULT nextval('import_event_import_event_id_seq'::regclass);


--
-- Name: plan plan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY plan ALTER COLUMN plan_id SET DEFAULT nextval('plan_plan_id_seq'::regclass);


--
-- Name: roi roi_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roi ALTER COLUMN roi_id SET DEFAULT nextval('roi_roi_id_seq'::regclass);


--
-- Name: roi_contour roi_contour_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roi_contour ALTER COLUMN roi_contour_id SET DEFAULT nextval('roi_contour_roi_contour_id_seq'::regclass);


--
-- Name: roi_observation roi_observation_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roi_observation ALTER COLUMN roi_observation_id SET DEFAULT nextval('roi_observation_roi_observation_id_seq'::regclass);


--
-- Name: roi_physical_properties roi_phyical_properties_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roi_physical_properties ALTER COLUMN roi_phyical_properties_id SET DEFAULT nextval('roi_physical_properties_roi_phyical_properties_id_seq'::regclass);


--
-- Name: rt_dose rt_dose_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rt_dose ALTER COLUMN rt_dose_id SET DEFAULT nextval('rt_dose_rt_dose_id_seq'::regclass);


--
-- Name: rt_dvh rt_dvh_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rt_dvh ALTER COLUMN rt_dvh_id SET DEFAULT nextval('rt_dvh_rt_dvh_id_seq'::regclass);


--
-- Name: rt_dvh_dvh rt_dvh_dvh_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rt_dvh_dvh ALTER COLUMN rt_dvh_dvh_id SET DEFAULT nextval('rt_dvh_dvh_rt_dvh_dvh_id_seq'::regclass);


--
-- Name: rt_prescription rt_prescription_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rt_prescription ALTER COLUMN rt_prescription_id SET DEFAULT nextval('rt_prescription_rt_prescription_id_seq'::regclass);


--
-- Name: slope_intercept slope_intercept_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY slope_intercept ALTER COLUMN slope_intercept_id SET DEFAULT nextval('slope_intercept_slope_intercept_id_seq'::regclass);


--
-- Name: ss_for ss_for_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ss_for ALTER COLUMN ss_for_id SET DEFAULT nextval('ss_for_ss_for_id_seq'::regclass);


--
-- Name: structure_set structure_set_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY structure_set ALTER COLUMN structure_set_id SET DEFAULT nextval('structure_set_structure_set_id_seq'::regclass);


--
-- Name: unique_pixel_data unique_pixel_data_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unique_pixel_data ALTER COLUMN unique_pixel_data_id SET DEFAULT nextval('unique_pixel_data_unique_pixel_data_id_seq'::regclass);


--
-- Name: visual_review_instance visual_review_instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY visual_review_instance ALTER COLUMN visual_review_instance_id SET DEFAULT nextval('visual_review_instance_visual_review_instance_id_seq'::regclass);


--
-- Name: window_level window_level_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY window_level ALTER COLUMN window_level_id SET DEFAULT nextval('window_level_window_level_id_seq'::regclass);


--
-- Name: ctp_file_new ctp_file_new_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ctp_file_new
    ADD CONSTRAINT ctp_file_new_pkey PRIMARY KEY (file_id);


--
-- Name: ctp_file ctp_file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ctp_file
    ADD CONSTRAINT ctp_file_pkey PRIMARY KEY (file_id);


--
-- Name: distinguished_pixel_digests distinguished_pixel_digests_pixel_digest_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distinguished_pixel_digests
    ADD CONSTRAINT distinguished_pixel_digests_pixel_digest_key UNIQUE (pixel_digest);


--
-- Name: downloadable_dir downloadable_dir_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloadable_dir
    ADD CONSTRAINT downloadable_dir_pkey PRIMARY KEY (downloadable_dir_id);


--
-- Name: downloadable_file downloadable_file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloadable_file
    ADD CONSTRAINT downloadable_file_pkey PRIMARY KEY (downloadable_file_id);


--
-- Name: file_ct_image file_ct_image__new_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_ct_image
    ADD CONSTRAINT file_ct_image__new_pkey PRIMARY KEY (file_id);


--
-- Name: file_equipment file_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_equipment
    ADD CONSTRAINT file_equipment_pkey PRIMARY KEY (file_id);


--
-- Name: file_for file_for_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_for
    ADD CONSTRAINT file_for_pkey PRIMARY KEY (file_id);


--
-- Name: file_meta file_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_meta
    ADD CONSTRAINT file_meta_pkey PRIMARY KEY (file_id);


--
-- Name: file_patient file_patient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_patient
    ADD CONSTRAINT file_patient_pkey PRIMARY KEY (file_id);


--
-- Name: file_pt_image file_pt_image_file_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_pt_image
    ADD CONSTRAINT file_pt_image_file_id_key UNIQUE (file_id);


--
-- Name: file_series file_series_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_series
    ADD CONSTRAINT file_series_pkey PRIMARY KEY (file_id);


--
-- Name: file_sop_common file_sop_common_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_sop_common
    ADD CONSTRAINT file_sop_common_pkey PRIMARY KEY (file_id);


--
-- Name: file_study file_study_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_study
    ADD CONSTRAINT file_study_pkey PRIMARY KEY (file_id);


--
-- Name: image_equivalence_class_input_image image_equivalence_class_input_image_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_equivalence_class_input_image
    ADD CONSTRAINT image_equivalence_class_input_image_uniq UNIQUE (image_equivalence_class_id, file_id);


--
-- Name: patient_import_status patient_import_status_patient_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY patient_import_status
    ADD CONSTRAINT patient_import_status_patient_id_key UNIQUE (patient_id);


SET search_path = quasar, pg_catalog;

--
-- Name: kirk_series kirk_series_pkey; Type: CONSTRAINT; Schema: quasar; Owner: -
--

ALTER TABLE ONLY kirk_series
    ADD CONSTRAINT kirk_series_pkey PRIMARY KEY (series_instance_uid);


--
-- Name: sops_and_ids sops_and_ids_pkey; Type: CONSTRAINT; Schema: quasar; Owner: -
--

ALTER TABLE ONLY sops_and_ids
    ADD CONSTRAINT sops_and_ids_pkey PRIMARY KEY (sop_instance_uid);


--
-- Name: sops sops_pkey; Type: CONSTRAINT; Schema: quasar; Owner: -
--

ALTER TABLE ONLY sops
    ADD CONSTRAINT sops_pkey PRIMARY KEY (sop_instance_uid);


SET search_path = public, pg_catalog;

--
-- Name: assocation_import_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assocation_import_event_id_idx ON association_import USING btree (import_event_id);


--
-- Name: assocation_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assocation_import_id ON association_import USING btree (association_id);


--
-- Name: association_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX association_pk ON association USING btree (association_id);


--
-- Name: beam_applicator_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX beam_applicator_plan_idx ON beam_applicator USING btree (plan_id, beam_number, applicator_id);


--
-- Name: beam_block_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX beam_block_idx ON beam_block USING btree (plan_id, beam_number, block_number);


--
-- Name: beam_control_point_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX beam_control_point_idx ON beam_control_point USING btree (plan_id, beam_number, control_point_index);


--
-- Name: beam_limiting_device_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX beam_limiting_device_idx ON beam_limiting_device USING btree (plan_id, beam_number);


--
-- Name: contour_image_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contour_image_id_idx ON contour_image USING btree (roi_contour_id);


--
-- Name: control_point_bld_position_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX control_point_bld_position_idx ON control_point_bld_position USING btree (plan_id, beam_number, control_point_index);


--
-- Name: ctp_file_all_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_file_all_idx ON ctp_file_new USING btree (file_id, project_name, site_name);


--
-- Name: ctp_file_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_file_file_id_index ON ctp_file USING btree (file_id);


--
-- Name: ctp_file_project_site_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_file_project_site_idx ON ctp_file_new USING btree (project_name, site_name);


--
-- Name: ctp_proj_site_file_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_proj_site_file_index ON ctp_file USING btree (file_id, project_name, site_name);


--
-- Name: ctp_proj_site_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ctp_proj_site_index ON ctp_file USING btree (project_name, site_name);


--
-- Name: ctp_upload_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ctp_upload_index ON ctp_upload_event USING btree (file_id, rcv_timestamp);


--
-- Name: dec_from_file_dig_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dec_from_file_dig_index ON dicom_edit_compare USING btree (from_file_digest);


--
-- Name: dec_to_file_dig_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dec_to_file_dig_index ON dicom_edit_compare USING btree (to_file_digest);


--
-- Name: dicom_edit_compare_subprocess_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_edit_compare_subprocess_index ON dicom_edit_compare USING btree (subprocess_invocation_id);


--
-- Name: dicom_file_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_file_file_id_index ON dicom_file USING btree (file_id);


--
-- Name: dicom_file_send_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_file_send_idx ON dicom_file_send USING btree (dicom_send_event_id);


--
-- Name: dicom_process_errors_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dicom_process_errors_file_id_idx ON dicom_process_errors USING btree (file_id);


--
-- Name: dicom_send_event_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dicom_send_event_pk ON dicom_send_event USING btree (dicom_send_event_id);


--
-- Name: file_ct_image_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_ct_image_file_id_index ON file_ct_image__old USING btree (file_id);


--
-- Name: file_digest_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_digest_index ON file USING btree (digest);


--
-- Name: file_dose_file_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_dose_file_idx ON file_dose USING btree (file_id);


--
-- Name: file_dose_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_dose_idx ON file_dose USING btree (rt_dose_id);


--
-- Name: file_ele_ref_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_ele_ref_pk ON file_ele_ref USING btree (file_ele_ref_id);


--
-- Name: file_equipment_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_equipment_file_id_idx ON file_equipment USING btree (file_id);


--
-- Name: file_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_file_id_idx ON file USING btree (file_id);


--
-- Name: file_for_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_for_file_id_idx ON file_for USING btree (file_id);


--
-- Name: file_image_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_image_file_id_index ON file_image USING btree (file_id);


--
-- Name: file_image_geometry_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_image_geometry_file_id_idx ON file_image_geometry USING btree (file_id);


--
-- Name: file_image_geometry_image_geometry_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_image_geometry_image_geometry_id_idx ON file_image_geometry USING btree (image_geometry_id);


--
-- Name: file_image_image_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_image_image_id_idx ON file_image USING btree (image_id);


--
-- Name: file_import_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_import_file_id_idx ON file_import USING btree (file_id);


--
-- Name: file_import_import_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_import_import_event_id_idx ON file_import USING btree (import_event_id);


--
-- Name: file_import_series_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_import_series_file_id_idx ON file_import_series USING btree (file_id);


--
-- Name: file_import_series_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_import_series_pk ON file_import_series USING btree (file_import_series_id);


--
-- Name: file_location_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_location_file_id_idx ON file_location USING btree (file_id);


--
-- Name: file_meta_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_meta_file_id_idx ON file_meta USING btree (file_id);


--
-- Name: file_patient_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_patient_file_id_index ON file_patient USING btree (file_id);


--
-- Name: file_patient_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_patient_patient_id_index ON file_patient USING btree (patient_id);


--
-- Name: file_plan_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_plan_file_id_idx ON file_plan USING btree (file_id);


--
-- Name: file_plan_plan_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_plan_plan_id_idx ON file_plan USING btree (plan_id);


--
-- Name: file_series_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_series_file_id_index ON file_series USING btree (file_id);


--
-- Name: file_series_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_series_uid_idx ON file_series USING btree (series_instance_uid);


--
-- Name: file_slope_intercept_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_slope_intercept_file_id_idx ON file_slope_intercept USING btree (file_id);


--
-- Name: file_slope_intercept_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_slope_intercept_id_idx ON file_slope_intercept USING btree (slope_intercept_id);


--
-- Name: file_sop_common_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_sop_common_file_id_idx ON file_sop_common USING btree (file_id);


--
-- Name: file_sop_common_sop_instance_uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_sop_common_sop_instance_uid_index ON file_sop_common USING btree (sop_instance_uid);


--
-- Name: file_storage_root_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_storage_root_pk ON file_storage_root USING btree (file_storage_root_id);


--
-- Name: file_structure_set_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_structure_set_idx ON file_structure_set USING btree (file_id, structure_set_id);


--
-- Name: file_study_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_study_file_id_index ON file_study USING btree (file_id);


--
-- Name: file_visibility_change_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_visibility_change_idx ON file_visibility_change USING btree (file_id);


--
-- Name: file_win_lev_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_win_lev_file_id_idx ON file_win_lev USING btree (file_id);


--
-- Name: file_win_level_wl_index_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_win_level_wl_index_idx ON file_win_lev USING btree (wl_index);


--
-- Name: fraction_reference_beam_beam_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fraction_reference_beam_beam_number ON fraction_reference_beam USING btree (beam_number);


--
-- Name: fraction_reference_beam_fraction_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fraction_reference_beam_fraction_idx ON fraction_reference_beam USING btree (fraction_group_number);


--
-- Name: fraction_reference_beam_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fraction_reference_beam_plan_idx ON fraction_reference_beam USING btree (plan_id);


--
-- Name: image_equivalence_class_input_image_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_input_image_file_id_idx ON image_equivalence_class_input_image USING btree (file_id);


--
-- Name: image_equivalence_class_input_image_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_input_image_id_idx ON image_equivalence_class_input_image USING btree (image_equivalence_class_id);


--
-- Name: image_equivalence_class_out_image_file_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_out_image_file_idx ON image_equivalence_class_out_image USING btree (file_id);


--
-- Name: image_equivalence_class_out_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_equivalence_class_out_image_idx ON image_equivalence_class_out_image USING btree (image_equivalence_class_id);


--
-- Name: image_equivalence_class_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX image_equivalence_class_pk ON image_equivalence_class USING btree (image_equivalence_class_id);


--
-- Name: image_geometry_image_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_geometry_image_id_index ON image_geometry USING btree (image_id);


--
-- Name: image_geometry_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX image_geometry_pk ON image_geometry USING btree (image_geometry_id);


--
-- Name: image_image_id_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX image_image_id_pk ON image USING btree (image_id);


--
-- Name: image_slope_intercept_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_slope_intercept_image_idx ON image_slope_intercept USING btree (image_id);


--
-- Name: image_slope_intercept_slope_intercept_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_slope_intercept_slope_intercept_idx ON image_slope_intercept USING btree (slope_intercept_id);


--
-- Name: image_window_level_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_window_level_image_idx ON image_window_level USING btree (image_id);


--
-- Name: image_window_level_window_level_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX image_window_level_window_level_idx ON image_window_level USING btree (window_level_id);


--
-- Name: import_event_import_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX import_event_import_event_id_idx ON import_event USING btree (import_event_id);


--
-- Name: import_event_import_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX import_event_import_time_idx ON import_event USING btree (import_time);


--
-- Name: pixel_location_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pixel_location_file_id_idx ON pixel_location USING btree (file_id);


--
-- Name: pixel_location_unique_pixel_data_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pixel_location_unique_pixel_data_id_idx ON pixel_location USING btree (unique_pixel_data_id);


--
-- Name: plan_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plan_pk ON plan USING btree (plan_id);


--
-- Name: roi_contour_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roi_contour_idx ON roi_contour USING btree (roi_id);


--
-- Name: roi_contour_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roi_contour_pk ON roi_contour USING btree (roi_contour_id);


--
-- Name: roi_observation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roi_observation_id_idx ON roi_observation USING btree (roi_id);


--
-- Name: roi_observation_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roi_observation_pk ON roi_observation USING btree (roi_observation_id);


--
-- Name: roi_physical_properties_observation_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roi_physical_properties_observation_idx ON roi_physical_properties USING btree (roi_observation_id);


--
-- Name: roi_physical_properties_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roi_physical_properties_pk ON roi_physical_properties USING btree (roi_phyical_properties_id);


--
-- Name: roi_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roi_pk ON roi USING btree (roi_id);


--
-- Name: roi_structure_set_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roi_structure_set_idx ON roi USING btree (structure_set_id);


--
-- Name: rt_beam_number_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_beam_number_idx ON rt_beam USING btree (beam_number);


--
-- Name: rt_beam_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_beam_plan_idx ON rt_beam USING btree (plan_id);


--
-- Name: rt_beam_tolerance_table_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_beam_tolerance_table_plan_idx ON rt_beam_tolerance_table USING btree (plan_id);


--
-- Name: rt_beam_tolerance_table_table_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_beam_tolerance_table_table_idx ON rt_beam_tolerance_table USING btree (tolerance_table_number);


--
-- Name: rt_dose_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_dose_image_idx ON rt_dose_image USING btree (rt_dose_id);


--
-- Name: rt_dose_image_image_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_dose_image_image_idx ON rt_dose_image USING btree (image_id);


--
-- Name: rt_dose_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rt_dose_pk ON rt_dose USING btree (rt_dose_id);


--
-- Name: rt_dvh_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rt_dvh_pk ON rt_dvh USING btree (rt_dvh_id);


--
-- Name: rt_plan_fraction_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_plan_fraction_group_idx ON rt_plan_fraction_group USING btree (plan_id);


--
-- Name: rt_plan_patient_setup_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_plan_patient_setup_plan_idx ON rt_plan_patient_setup USING btree (plan_id);


--
-- Name: rt_prescription_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rt_prescription_pk ON rt_prescription USING btree (rt_prescription_id);


--
-- Name: rt_prescription_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rt_prescription_plan_idx ON rt_prescription USING btree (plan_id);


--
-- Name: slope_intercept_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX slope_intercept_pk ON slope_intercept USING btree (slope_intercept_id);


--
-- Name: ss_for_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ss_for_pk ON ss_for USING btree (ss_for_id);


--
-- Name: ss_volume_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ss_volume_id_idx ON ss_volume USING btree (ss_for_id);


--
-- Name: structure_set_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX structure_set_pk ON structure_set USING btree (structure_set_id);


--
-- Name: unique_pixel_data_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unique_pixel_data_digest ON unique_pixel_data USING btree (digest);


--
-- Name: unique_pixel_data_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_pixel_data_pk ON unique_pixel_data USING btree (unique_pixel_data_id);


--
-- Name: unique_pixel_date_image; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unique_pixel_date_image ON image USING btree (unique_pixel_data_id);


--
-- Name: window_level_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX window_level_pk ON window_level USING btree (window_level_id);


--
-- Name: downloadable_file downloadable_file_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloadable_file
    ADD CONSTRAINT downloadable_file_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id);


--
-- PostgreSQL database dump complete
--

