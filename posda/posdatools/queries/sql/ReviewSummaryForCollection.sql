-- Name: ReviewSummaryForCollection
-- Schema: posda_files
-- Columns: ['collection', 'site', 'dicom_file_type', 'modality', 'visibility', 'review_status', 'num_series']
-- Args: ['collection']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events']
-- Description: Get visual review status report by series for Collection, Site

select 
  distinct project_name as collection,
  site_name as site,
  dicom_file_type,
  modality,
  coalesce(visibility, 'visable') as visiblity,
  review_status,
  count(distinct series_instance_uid) as num_series 
from
  image_equivalence_class natural join file_series
  natural join ctp_file natural join dicom_file
where
  project_name = ? 
group by project_name, site, dicom_file_type, modality, visibility, review_status;