-- Name: Sops In Posda By Series
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'sop_instance_uid']
-- Args: ['series_instance_uid']
-- Tags: ['Reconcile Public and Posda for CPTAC']
-- Description: Get the list of files by sop, excluding base series

select 
  distinct project_name as collection, site_name as site, patient_id,
  study_instance_uid, series_instance_uid,
  modality, sop_instance_uid
from
  file_series natural join file_patient natural join ctp_file natural join
  file_sop_common natural join file_study
where file_id in (
  select
    file_id
from
    file_series natural join ctp_file
  where 
    series_instance_uid = ?
  )
