-- Name: SeriesVisualReviewResultsExtendedByCollectionSiteStatus
-- Schema: posda_files
-- Columns: ['collection', 'site', 'series_instance_uid', 'patient_id', 'dicom_file_type', 'modality', 'review_status', 'num_files', 'equivalence_class_number']
-- Args: ['project_name', 'site_name', 'status']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get visual review status report by series for Collection, Site

select 
  distinct 
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  equivalence_class_number,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join
  file_patient natural join
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status = ?
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  equivalence_class_number
order by
  series_instance_uid