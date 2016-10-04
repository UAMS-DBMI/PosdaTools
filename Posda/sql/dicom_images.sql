
-- 
-- Copyright 2008, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 

--
-- Name: association; Type: TABLE
--

CREATE TABLE association (
    association_id serial NOT NULL,
    called_ae_title text,
    calling_ae_title text,
    start_time timestamp with time zone,
    duration integer,
    originating_ip_addr text,
    processing text,
    session_info_file text
);
CREATE TABLE association_errors (
    association_id integer NOT NULL,
    error_type text,
    error_line text
);
CREATE TABLE association_pc (
    association_pc_id serial NOT NULL,
    association_id integer NOT NULL,
    abstract_syntax_uid text,
    accepted boolean NOT null,
    not_accepted_reason integer,
    accepted_ts text
);
CREATE TABLE association_pc_proposed_ts (
    association_pc_id integer NOT NULL,
    proposed_ts_uid text NOT NULL
);
CREATE TABLE association_file (
    association_id integer NOT NULL,
    file_id integer NOT NULL,
    file_path text NOT NULL,
    assoc_sop_class text NOT NULL,
    assoc_sop_inst text NOT NULL,
    assoc_xfr_stx text NOT NULL,
    assoc_path text NOT NULL
);
CREATE TABLE association_import (
    association_id integer NOT NULL,
    import_event_id integer NOT NULL
);
    

--
-- Name: import_event; Type: TABLE
--

CREATE TABLE import_event (
    import_event_id serial NOT NULL,
    import_type text,
    importing_user text,
    originating_ip_addr text,
    import_comment text,
    import_time timestamp with time zone,
    remote_file text,
    volume_name text
);

CREATE TABLE submission(
    import_event_id integer NOT NULL,
    institution text,
    year int,
    month_i int,
    month text
);


create table dicom_send_event
(
  dicom_send_event_id serial not null,
  destination_host text not null,
  destination_port text not null,
  called_ae text not null,
  calling_ae text not null,
  send_started timestamp with time zone,
  send_ended timestamp with time zone,
  number_of_files integer,
  invoking_user text,
  reason_for_send text 
);
create table dicom_file_send(
  dicom_send_event_id integer not null,
  file_id integer not null,
  status text
);

--
-- Name: file_import; Type: TABLE
--

CREATE TABLE file_import (
    import_event_id integer NOT NULL,
    file_id integer NOT NULL,
    rel_path text,
    rel_dir text,
    file_name text
);

--
-- Name: file; Type: TABLE
--

CREATE TABLE file (
    file_id serial NOT NULL,
    digest text NOT NULL,
    size integer,
    is_dicom_file boolean,
    file_type text,
    processing_priority integer,
    ready_to_process boolean
);

--
-- Name: dicom_file; Type: TABLE
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


CREATE TABLE ctp_file (
    file_id integer NOT NULL,
    project_name text,
    trial_name text,
    site_name text,
    site_id text,
    visibility text
);

CREATE TABLE file_visibility_change(
    file_id integer NOT NULL,
    user_name text NOT NULL,
    time_of_change timestamp with time zone,
    prior_visibility text,
    new_visibility text,
    reason_for text
);

--
-- Name: dicom_file_errors; Type: TABLE
--

CREATE TABLE dicom_file_errors (
    file_id integer NOT NULL,
    error_msg text
);

--
-- Name: dicom_process_errors; Type: TABLE
--

CREATE TABLE dicom_process_errors (
    file_id integer NOT NULL,
    error_msg text
);

--
-- Name: file_location; Type: TABLE
--

CREATE TABLE file_location (
    file_id integer NOT NULL,
    file_storage_root_id integer NOT NULL,
    rel_path text NOT NULL,
    is_home text
);

--
-- Name: file_storage_root; Type: TABLE
--

CREATE TABLE file_storage_root (
    file_storage_root_id serial NOT NULL,
    root_path text,
    current boolean
);

--  DICOM DIR Stuff starts here.  First, it must have meta header
--  (Not all files with meta header are DICOMDIR)
--
-- Name: file_meta; Type: TABLE
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

--  If it is a DICOMDIR, it goes here, and records in the tables below
--
-- Name: dicom_dir; Type: TABLE
--

CREATE TABLE dicom_dir (
    file_id integer NOT NULL,
    fs_id text,
    fs_desc text,
    spec_char_set_of_desc text
);

--  All DICOMDIR records go into this table
--
-- Name: dicom_dir_rec; Type: TABLE
--

CREATE TABLE dicom_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id serial NOT NULL,
    is_root boolean,
    is_active boolean,
    child_of integer,
    offset_in_file integer,
    length_in_file integer,
    rec_type text
);

--
-- Name: dicom_patient_dir_rec; Type: TABLE
--

CREATE TABLE dicom_patient_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_patient_spec_char_set text,
    patients_name text,
    patient_id text
);

--
-- Name: dicom_study_dir_rec; Type: TABLE
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
-- Name: dicom_series_dir_rec; Type: TABLE
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
-- Name: dicom_image_dir_rec; Type: TABLE
--

CREATE TABLE dicom_image_dir_rec (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    dicom_image_spec_char_set text,
    instance_number integer
);

--
-- Name: dicom_rt_dose_dir_rec; Type: TABLE
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
-- Name: dicom_rt_structure_set_dir_rec; Type: TABLE
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
-- Name: dicom_rt_plan_dir_rec; Type: TABLE
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
-- Name: dicom_rt_treatment_rec_dir_rec; Type: TABLE
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
-- Name: dicom_icon_image; Type: TABLE
--

CREATE TABLE dicom_icon_image (
    file_id integer NOT NULL,
    dicom_dir_rec_id integer NOT NULL,
    image_id integer NOT NULL
);

--
-- Name: image; Type: TABLE
--

CREATE TABLE image (
    image_id serial NOT NULL,
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
    row_spacing float,
    col_spacing float
);

CREATE TABLE image_frame_offset (
    image_id integer NOT NULL,
    frame_index integer,
    frame_offset text
);

--
-- Name: image_geometry; Type: TABLE
--

CREATE TABLE image_geometry (
    image_geometry_id serial NOT NULL,
    image_id integer NOT NULL,
    iop text,
    ipp text,
    for_uid text,
    normalized_iop text,
    iop_error text,
    row_x float,
    row_y float,
    row_z float,
    col_x float,
    col_y float,
    col_z float,
    pos_x float,
    pos_y float,
    pos_z float
);

--
-- Name: file_image_geometry; Type: TABLE
--

CREATE TABLE file_image_geometry (
    file_id integer NOT NULL,
    image_geometry_id integer NOT NULL
);

--
-- Name: unique_pixel_data; Type: TABLE
--

CREATE TABLE unique_pixel_data (
    unique_pixel_data_id serial NOT NULL,
    digest text NOT NULL,
    size integer
);

--
-- Name: pixel_location; Type: TABLE
--

CREATE TABLE pixel_location (
    unique_pixel_data_id integer NOT NULL,
    file_id integer NOT NULL,
    file_offset integer NOT NULL
);

--
-- Name: file_sop_common; Type: TABLE
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
-- Name: file_image; Type: TABLE
--

CREATE TABLE file_image (
    file_id integer NOT NULL,
    image_id integer NOT NULL,
    content_date date,
    content_time time without time zone
);

--
-- Name: file_for; Type: TABLE
--

CREATE TABLE file_for (
    file_id integer NOT NULL,
    for_uid text,
    position_ref_indicator text
);

--
-- Name: file_patient; Type: TABLE
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
-- Name: file_study; Type: TABLE
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

CREATE TABLE file_import_study (
    file_import_study_id serial NOT NULL,
    file_id int NOT NULL,
    import_event_id int NOT NULL,
    study_instance_uid text NOT NULL
);

--
-- Name: file_series; Type: TABLE
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
    performed_procedure_step_comments text
);

CREATE TABLE file_import_series (
    file_import_series_id serial NOT NULL,
    file_id int NOT NULL,
    import_event_id int NOT NULL,
    series_instance_uid text NOT NULL,
    modality text NOT NULL
);
CREATE TABLE import_ct_series(
    import_event_id int NOT NULL,
    series_instance_uid text NOT NULL,
    series_type text,
    patient_position text,
    is_axial boolean,
    consistent_series_geometry boolean,
    normalized_iop text,
    number_of_slices int,
    avg_slice_spacing float,
    max_slice_spacing float,
    min_slice_spacing float,
    minimum_z float,
    maximum_z float,
    total_file_size bigint,
    max_file_size int,
    min_file_size int,
    avg_file_size float,
    processing_errors text
);

--
-- Name: file_equipment; Type: TABLE
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
-- Name: file_ele_ref; Type: TABLE
--

CREATE TABLE file_ele_ref (
    file_ele_ref_id serial NOT NULL,
    file_id integer,
    ele_sig text
);

--
-- Name: file_ele_ref_text_value; Type: TABLE
--

CREATE TABLE file_ele_ref_text_value (
    file_ele_ref_id integer NOT NULL,
    text_value text
);

--
-- Name: file_structure_set; Type: TABLE
--

CREATE TABLE file_ct_image (
    file_id integer NOT NULL,
    kvp text NOT NULL,
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
-- Name: file_structure_set; Type: TABLE
--

CREATE TABLE file_structure_set (
    file_id integer NOT NULL,
    structure_set_id integer NOT NULL,
    instance_number text
);

--
-- Name: structure_set; Type: TABLE
--

CREATE TABLE structure_set (
    structure_set_id serial NOT NULL,
    ss_label text,
    ss_description text,
    ss_date date,
    ss_time time without time zone,
    ss_name text
);

--
-- Name: ss_for; Type: TABLE
--

CREATE TABLE ss_for (
    ss_for_id serial NOT NULL,
    structure_set_id integer NOT NULL,
    for_uid text NOT NULL
);

--
-- Name: for_registration; Type: TABLE
--

CREATE TABLE for_registration (
    ss_for_id integer NOT NULL,
    from_for_uid text NOT NULL,
    xform_type text,
    xform text,
    xform_comment text
);

--
-- Name: ss_volume; Type: TABLE
--

CREATE TABLE ss_volume (
    ss_for_id integer NOT NULL,
    study_instance_uid text NOT NULL,
    series_instance_uid text NOT NULL,
    sop_class text NOT NULL,
    sop_instance text NOT NULL
);

--
-- Name: roi; Type: TABLE
--

CREATE TABLE roi (
    roi_id serial NOT NULL,
    structure_set_id integer NOT NULL,
    for_uid text NOT NULL,
    roi_num integer NOT NULL,
    roi_name text,
    roi_description text,
    roi_volume text,
    gen_alg text,
    gen_desc text,
    roi_color text
);

--
-- Name: roi_contour; Type: TABLE
--

CREATE TABLE roi_contour (
    roi_contour_id serial NOT NULL,
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
-- Name: contour_image; Type: TABLE
--

CREATE TABLE contour_image (
    roi_contour_id integer NOT NULL,
    sop_class text NOT NULL,
    sop_instance text NOT NULL,
    frame_number integer
);

--
-- Name: roi_observation; Type: TABLE
--

CREATE TABLE roi_observation (
    roi_observation_id serial NOT NULL,
    roi_id integer NOT NULL,
    roi_obs_num integer,
    observation_label text,
    observation_description text,
    interpreted_type text,
    interpreter text,
    material_id text
);

--
-- Name: roi_obs_related_roi; Type: TABLE
--

CREATE TABLE roi_related_roi (
    roi_id integer NOT NULL,
    related_roi_id integer NOT NULL,
    relationship text
);

--
-- Name: related_roi_observations; Type: TABLE
--

CREATE TABLE related_roi_observations (
    roi_observation_id integer NOT NULL,
    related_roi_observation_num integer NOT NULL
);

--
-- Name: roi_physical_properties; Type: TABLE
--

CREATE TABLE roi_physical_properties (
    roi_phyical_properties_id serial NOT NULL,
    roi_observation_id integer NOT NULL,
    property text,
    property_value text
);

CREATE TABLE roi_elemental_composition (
    roi_phyical_properties_id integer NOT NULL,
    roi_elemental_composition_atomic_number text,
    roi_elemental_composition_atomic_mass_fraction text
);


--
-- Name: window_level; Type: TABLE
--

CREATE TABLE window_level (
    window_level_id serial NOT NULL,
    window_width text NOT NULL,
    window_center text NOT NULL,
    win_lev_desc text
);

--
-- Name: image_window_level; Type: TABLE
--

CREATE TABLE image_window_level (
    window_level_id integer NOT NULL,
    image_id integer NOT NULL
);

--
-- Name: file_win_lev; Type: TABLE
--

CREATE TABLE file_win_lev (
    file_id integer NOT NULL,
    window_level_id integer NOT NULL,
    wl_index integer NOT NULL
);

--
-- Name: slope_intercept; Type: TABLE
--

CREATE TABLE slope_intercept (
    slope_intercept_id serial NOT NULL,
    slope text NOT NULL,
    intercept text NOT NULL,
    si_units text,
    slopef  float,
    interceptf float
);

--
-- Name: image_slope_intercept; Type: TABLE
--

CREATE TABLE image_slope_intercept (
    image_id integer NOT NULL,
    slope_intercept_id integer NOT NULL
);

--
-- Name: file_slope_intercept; Type: TABLE
--

CREATE TABLE file_slope_intercept (
    file_id integer NOT NULL,
    slope_intercept_id integer NOT NULL
);

--
-- Name: plan; Type: TABLE
--

CREATE TABLE plan (
    plan_id serial NOT NULL,
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
-- Name: file_plan; Type: TABLE
--

CREATE TABLE file_plan (
    plan_id integer NOT NULL,
    file_id integer NOT NULL
);

--
-- Name: plan_related_dose; Type: TABLE
--

CREATE TABLE dose_referenced_from_plan (
    plan_id integer NOT NULL,
    dose_sop_instance_uid text
);

--
-- Name: plan_related_plans; Type: TABLE
--

CREATE TABLE plan_related_plans (
    plan_id integer NOT NULL,
    related_plan_instance_uid text,
    plan_relationship text
);

--
-- Name: rt_prescription; Type: TABLE
--

CREATE TABLE rt_prescription (
    rt_prescription_id serial NOT NULL,
    plan_id integer NOT NULL,
    rt_prescription_description text
);

--
-- Name: rt_prescription_dose_ref; Type: TABLE
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
-- Name: rt_beam_tolerance_table; Type: TABLE
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
    table_top_roll_angle_tolerance  text,
    table_top_vert_pos_tolerance text,
    table_top_log_pos_tolerance text,
    table_top_lat_pos_tolerance text
);

--
-- Name: rt_beam_limit_dev_tolerance; Type: TABLE
--

CREATE TABLE rt_beam_limit_dev_tolerance (
    plan_id integer NOT NULL,
    tolerance_table_number integer NOT NULL,
    beam_limit_dev_type text,
    beam_limit_dev_pos_tolerance text
);

--
-- Name: rt_plan_patient_setup; Type: TABLE
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
-- Name: rt_plan_setup_image; Type: TABLE
--

CREATE TABLE rt_plan_setup_image (
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    setup_image_comment text,
    image_sop_class_uid text,
    image_sop_instance_uid text
);

--
-- Name: rt_plan_setup_fixation_device; Type: TABLE
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
-- Name: rt_plan_shielding_device; Type: TABLE
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
-- Name: rt_plan_setup_device; Type: TABLE
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

CREATE TABLE rt_plan_respiratory_motion_comp(
    plan_id integer NOT NULL,
    patient_setup_num integer NOT NULL,
    sequence_index integer NOT NULL,
    respiratory_motion_comp_technique text,
    respiratory_signal_source text,
    respiratory_motion_com_tech_desc text,
    respiratory_signal_source_id text
);

CREATE TABLE rt_plan_fraction_group(
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
CREATE TABLE fraction_related_dose(
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);
CREATE TABLE fraction_reference_dose(
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
CREATE TABLE fraction_reference_beam(
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
CREATE TABLE fraction_reference_brachy(
    plan_id integer NOT NULL,
    fraction_group_number integer NOT NULL,
    brachy_application_setup_number integer NOT NULL,
    brachy_application_setup_dose_specification_point text,
    brachy_application_setup_dose text
);
CREATE TABLE rt_beam(
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
CREATE TABLE beam_limiting_device(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    bld_type text NOT NULL,
    source_to_bld_distance text,
    number_of_leaf_jaw_pairs integer NOT NULL,
    leaf_position_boundries text
);
CREATE TABLE image_referenced_from_beam(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL,
    reference_image_number text NOT NULL,
    start_cum_meterset_weight text,
    end_cum_meterset_weight text
);
CREATE TABLE planned_verification_images(
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
CREATE TABLE dose_referenced_from_beam(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);
CREATE TABLE beam_wedge(
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
CREATE TABLE beam_compensator(
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
CREATE TABLE beam_bolus(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    referenced_roi_number integer NOT NULL,
    bolus_id text,
    bolus_accessory_code text,
    bolus_description text
);
CREATE TABLE beam_block(
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
CREATE TABLE beam_applicator(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    applicator_id text NOT NULL,
    applicator_accessory_code text,
    applicator_type text,
    applicator_description text
);
CREATE TABLE beam_general_accessory(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    general_accessory_number integer NOT NULL,
    general_accessory_id text NOT NULL,
    general_accessory_description text,
    general_accessory_type text,
    general_accessory_code text
);
CREATE TABLE beam_control_point(
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
CREATE TABLE control_point_reference_dose(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    referenced_dose_reference_number integer NOT NULL,
    cumulative_dose_ref_coefficent text
);
CREATE TABLE control_point_dose_reference(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    sop_class_uid text NOT NULL,
    sop_instance_uid text NOT NULL
);
CREATE TABLE control_point_wedge_position(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    wedge_number integer NOT NULL,
    wedge_position text NOT NULL
);
CREATE TABLE control_point_bld_position(
    plan_id integer NOT NULL,
    beam_number integer NOT NULL,
    control_point_index integer NOT NULL,
    bld_type text NOT NULL,
    leaf_jaw_positions text NOT NULL
);
--
--  To be populated by Posda::DB::Modules::RTDose
--
CREATE TABLE rt_dose(
    rt_dose_id SERIAL NOT NULL,
    rt_dose_units TEXT,
    rt_dose_type TEXT,
    rt_dose_instance_number TEXT,
    rt_dose_comment TEXT,
    rt_dose_normalization_point TEXT,
    rt_dose_summation_type TEXT,
    rt_dose_referenced_plan_class TEXT,
    rt_dose_referenced_plan_uid TEXT,
    rt_dose_tissue_heterogeneity TEXT
);
CREATE TABLE rt_dose_image(
    rt_dose_id INT NOT NULL,
    image_id INT NOT NULL,
    rt_dose_grid_frame_offset_vector TEXT,
    rt_dose_grid_scaling FLOAT,
    rt_dose_max_slice_spacing FLOAT,
    rt_dose_min_slice_spacing FLOAT
);
CREATE TABLE rt_dose_gfov (
    rt_dose_id INT NOT NULL,
    rt_gfov_index INT NOT NULL,
    gfov_offset FLOAT
);
CREATE TABLE rt_dose_ref_beam(
    rt_dose_id INT NOT NULL,
    rt_dose_frac_group_number INT NOT NULL,
    rt_dose_beam_number INT NOT NULL,
    rt_dose_cp_start INT,
    rt_dose_cp_stop INT
);
CREATE TABLE rt_dose_ref_brachy(
    rt_dose_id INT NOT NULL,
    rt_dose_ref_bracy_setup_number INT NOT NULL
);
CREATE TABLE file_dose(
    rt_dose_id INT NOT NULL,
    file_id INT NOT NULL
);
--
--  To be populated by Posda::DB::Modules::RTDvh
--
CREATE TABLE rt_dvh(
    rt_dvh_id SERIAL NOT NULL,
    rt_dvh_source TEXT NOT NULL,
    rt_dvh_referenced_ss_class TEXT,
    rt_dvh_referenced_ss_uid TEXT,
    rt_dvh_normalization_point TEXT,
    rt_dvh_normalization_value TEXT
);
CREATE TABLE rt_dvh_dvh(
    rt_dvh_dvh_id SERIAL NOT NULL,
    rt_dvh_id INT NOT NULL,
    rt_dvh_dvh_type TEXT,
    rt_dvh_dvh_roi_alt_name TEXT,
    rt_dvh_dvh_roi_alt_desc TEXT,
    rt_dvh_dvh_plan_id TEXT,
    rt_dvh_dvh_plan_desc TEXT,
    rt_dvh_dvh_arm integer,
    rt_dvh_dvh_prescription double precision,
    rt_dvh_dvh_specified_heterogeneity TEXT,
    rt_dvh_dvh_dose_summation_id TEXT,
    rt_dvh_dvh_dose_manufacturer TEXT,
    rt_dvh_dvh_dose_model_name TEXT,
    rt_dvh_dvh_referenced_dose_grid_class TEXT,
    rt_dvh_dvh_referenced_dose_grid_uid TEXT,
    rt_dvh_dvh_dose_units TEXT,
    rt_dvh_dvh_dose_type TEXT,
    rt_dvh_dvh_dose_scaling TEXT,
    rt_dvh_dvh_dose_volume_units TEXT,
    rt_dvh_dvh_dose_number_of_bins TEXT,
    rt_dvh_dvh_minimum_dose FLOAT,
    rt_dvh_dvh_maximum_dose FLOAT,
    rt_dvh_dvh_mean_dose FLOAT,
    rt_dvh_dvh_text_data text
);
CREATE TABLE rt_dvh_dvh_data(
    rt_dvh_dvh_id INT NOT NULL,
    rt_dvh_dvh_index INT NOT NULL,
    rt_dvh_dvh_data FLOAT
);
CREATE TABLE rt_dvh_dvh_roi(
    rt_dvh_dvh_id INT NOT NULL,
    rt_dvh_dvh_ref_roi_number INT,
    rt_dvh_dvh_roi_cont_type TEXT
);
CREATE TABLE rt_dvh_rt_dose(
    rt_dose_id INT NOT NULL,
    rt_dvh_id INT NOT NULL
);
CREATE TABLE rt_dvh_dvh_dose_bins(
    rt_dvh_dvh_id integer NOT NULL,
    bin_dose_cgy double precision NOT NULL,
    cum_percent_vol double precision NOT NULL,
    cum_cm3_vol double precision NOT NULL,
    cum_percent_prescription_dose double precision
);
CREATE TABLE rt_dvh_protocol_case_roi(
    rt_dvh_dvh_id integer NOT NULL,
    roi_construct_name text,
    protocol text,
    case_no text,
    ss_file_id integer,
    dose_file_id integer
);
CREATE TABLE rt_dvh_available_rois (
    rt_dvh_dvh_id integer NOT NULL,
    available_rois TEXT
);
