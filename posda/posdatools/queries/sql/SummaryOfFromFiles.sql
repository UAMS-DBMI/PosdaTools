-- Name: SummaryOfFromFiles
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_date', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'visibility', 'num_sops', 'num_files']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility
-- 
-- NB: Normally there should be no file_id (i.e. file has not been imported)

select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_date,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  visibility,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  ctp_file natural join
  file_patient natural join
  file_sop_common natural join
  file_study natural join
  file_series natural join
  dicom_file
where file_id in (
  select
    file_id 
  from
    file f, dicom_edit_compare dec 
  where
    f.digest = dec.from_file_digest and dec.subprocess_invocation_id = ?
  )
group by collection, site, patient_id, study_date, study_instance_uid, series_instance_uid, 
  dicom_file_type, modality, visibility
order by collection, site, patient_id, study_date, study_instance_uid, modality