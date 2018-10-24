-- Name: ListHiddenFilesByCollectionPatient
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id', 'old_visibility']
-- Args: ['collection', 'patient_id']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'old_visibility']
-- Description: Show Received before date by collection, site

select
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id,
  visibility as old_visibility
from
  ctp_file natural join
  file_patient natural join
  file_series
where
  visibility is not null and
  project_name = ? and
  patient_id = ?