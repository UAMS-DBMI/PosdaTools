-- Name: SimpleSeriesCountsByCollectioin
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files', 'num_bytes']
-- Args: ['collection']
-- Tags: ['counts', 'count_queries']
-- Description: Counts query by Collection like pattern
-- 

select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  count(distinct file_id)as num_files,
  sum(size) as num_bytes
from
  ctp_file natural join
  file natural join
  dicom_file natural join
  file_patient natural join
  file_series
where
  visibility is null and
  project_name = ?
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality