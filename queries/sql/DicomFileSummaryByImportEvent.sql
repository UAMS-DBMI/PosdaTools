-- Name: DicomFileSummaryByImportEvent
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient', 'study', 'series', 'file_type', 'modality', 'num_sops', 'num_files']
-- Args: ['import_event_id']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: A summary of DICOM files in a particular upload

select
  distinct project_name as collection,
  site_name as site,
  patient_id as patient,
  study_instance_uid as study,
  series_instance_uid as series,
  dicom_file_type as file_type,
  modality,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  dicom_file natural left join
  ctp_file
where file_id in (
  select distinct file_id from import_event natural join file_import where import_event_id = ?
)
group by collection, site, patient, study, series, file_type, modality
order by collection, site, patient, series, file_type
