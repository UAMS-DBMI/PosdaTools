-- Name: WhereFileSitsExt
-- Schema: posda_files
-- Columns: ['collection', 'site', 'visibility', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_type', 'path', 'earliest_import_day', 'latest_import_day']
-- Args: ['file_id']
-- Tags: ['posda_files', 'sops', 'BySopInstance', 'by_file']
-- Description: Get Collection, Site, Patient, Study Hierarchy in which SOP resides
-- 

select distinct
    project_name as collection,
    site_name as site,
    visibility,
    patient_id,
    study_instance_uid,
    series_instance_uid,
    sop_instance_uid,
    sop_class_uid,
    modality,
    dicom_file_type,
    root_path || '/' || file_location.rel_path as path,
    date_trunc('day', min(coalesce(file_import_time, import_time))) as earliest_import_day,
    date_trunc('day', max(coalesce(file_import_time, import_time))) as latest_import_day
from
    dicom_file
    natural join file_patient
    natural join file_study
    natural join file_series
    natural join file_sop_common
    natural join file_import
	natural join import_event
    natural left join ctp_file
    join file_location using (file_id)
    natural join file_storage_root
where
    file_id = ?
group by
    project_name,
    site_name,
    visibility,
    patient_id,
    study_instance_uid,
    series_instance_uid,
    sop_instance_uid,
    sop_class_uid,
    modality,
    dicom_file_type,
    path
