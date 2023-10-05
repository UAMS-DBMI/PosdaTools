-- Name: GetExistenceClassModalityUniquenessOfReferencedFile
-- Schema: posda_files
-- Columns: ['file_id', 'collection', 'site', 'patient_id', 'sop_class', 'modality', 'sop_class_uid', 'series_instance_uid']
-- Args: ['sop_instance_uid']
-- Tags: ['LinkageChecks', 'used_in_dose_linkage_check', 'used_in_plan_linkage_check']
-- Description: Get Information related to uniqueness, modality, sop_class of a file reference by Sop Instance

select
  distinct file_id,
  project_name as collection,
  site_name as site,
  patient_id,
  dicom_file_type as sop_class,
  modality,
  sop_class_uid,
  series_instance_uid
from
  file_sop_common natural join
  dicom_file natural join
  file_series natural join
  file_patient natural join
  ctp_file 
where
  sop_instance_uid = ?