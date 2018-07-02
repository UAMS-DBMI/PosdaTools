-- Name: AreVisibleFilesMarkedAsBadOrUnreviewedInSeries
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'num_files']
-- Args: ['series_instance_uid']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events']
-- Description: Get visual review status report by series for Collection, Site

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  file_patient natural join
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  series_instance_uid = ?
  and visibility is null and 
  review_status != 'Good' and
  review_status != 'PassThrough'
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status