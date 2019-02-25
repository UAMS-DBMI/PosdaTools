-- Name: InsertManifestRow
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'cm_index', 'cm_collection', 'cm_site', 'cm_patient_id', 'cm_study_date', 'cm_series_instance_uid', 'cm_study_description', 'cm_series_description', 'cm_modality', '']
-- Tags: ['activity_timepoint_support', 'manifests']
-- Description: Create An Activity Timepoint
-- 
-- 

insert into ctp_manifest_row(
 file_id,
 cm_index,
 cm_collection,
 cm_site,
 cm_patient_id,
 cm_study_date,
 cm_series_instance_uid,
 cm_study_description,
 cm_series_description,
 cm_modality,
 cm_num_files ) values(
 ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
)