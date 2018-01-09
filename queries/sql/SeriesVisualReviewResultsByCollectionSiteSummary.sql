-- Name: SeriesVisualReviewResultsByCollectionSiteSummary
-- Schema: posda_files
-- Columns: ['dicom_file_type', 'modality', 'review_status', 'processing_status', 'num_series', 'num_files']
-- Args: ['project_name', 'site_name']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get visual review status report by series for Collection, Site

select 
  distinct
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and visibility is null
group by
  dicom_file_type,
  modality,
  review_status,
  processing_status
