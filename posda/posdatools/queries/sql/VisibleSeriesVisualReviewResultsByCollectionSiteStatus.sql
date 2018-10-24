-- Name: VisibleSeriesVisualReviewResultsByCollectionSiteStatus
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files']
-- Args: ['project_name', 'site_name', 'status']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get visual review status report by series for Collection, Site

select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status = ?
  and visibility is null
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
order by
  series_instance_uid