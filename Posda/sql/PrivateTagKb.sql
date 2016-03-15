create table pt(
  pt_id serial,
  pt_signature text unique not null,
  pt_short_signature text not null,
  pt_owner text not null,
  pt_group text not null,
  pt_element text not null,
  pt_is_specific_to_block boolean,
  pt_specific_block text,
  pt_consensus_vr text,
  pt_consensus_vm text,
  pt_consensus_name text,
  pt_consensus_disposition text
);
create table ptrg(
  ptrg_id serial,
  ptrg_signature_masked text unique not null,
  ptrg_owner text not null,
  ptrg_base_grp integer not null,
  ptrg_grp_mask integer not null,
  ptrg_grp_ext_mask integer not null,
  ptrg_grp_ext_shift integer not null,
  ptrg_element text not null,
  ptrg_is_specific_to_block boolean,
  ptrg_specific_block text,
  ptrg_consensus_vr text,
  ptrg_consensus_vm text,
  ptrg_consensus_name text,
  ptrg_consensus_disposition text
);
create table pt_wustl(
  pt_id integer,
  pt_wustl_vr text,
  pt_wustl_vm text,
  pt_wustl_vm_second text,
  pt_wustl_name text,
  pt_wustl_name_second text,
  pt_wustl_disposition text,
  pt_wustl_disposition_second text,
  pt_wustl_is_specific_to_block boolean,
  pt_wustl_private_block text,
  pt_wustl_signature text,
  pt_wustl_device_sig text
);
create table pt_dcmtk(
  pt_dcmtk_is_repeating boolean,
  pt_id integer,
  ptrg_id integer,
  pt_dcmtk_signature text, 
  pt_dcmtk_vr text,
  pt_dcmtk_vm text,
  pt_dcmtk_name text
);
create table pt_dicom3(
  pt_dicom3_is_repeating boolean,
  pt_id integer,
  ptrg_id integer,
  pt_dicom3_tag text,
  pt_dicom3_vr text,
  pt_dicom3_vm text,
  pt_dicom3_name text,
  pt_dicom3_keyword text,
  pt_dicom3_owner text,
  pt_dicom3_vers text,
  pt_dicom3_comment text,
  pt_dicom3_assumption text,
  pt_dicom3_private_block text
);
create table pt_observation(
  pt_id integer not null,
  pt_obs_observer text,
  pt_obs_value text,
  pt_obs_comment text,
  pt_obs_time timestamp with time zone
);
create table ptrg_observation(
  ptrg_id integer not null,
  ptrg_obs_observer text,
  ptrg_obs_value text,
  ptrg_obs_comment text,
  ptrg_obs_time timestamp with time zone
);
