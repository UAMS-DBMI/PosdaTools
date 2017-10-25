-- Name: SeriesVisualReviewResultsByCollectionSiteStatusNotGoodExtended
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files']
-- Args: ['project_name', 'site_name']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get visual review status report by series for Collection, Site

select
  distinct patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  series_modality as modality,
  review_status,
  num_files
from (
select 
  distinct series_instance_uid,
  dicom_file_type,
  modality as series_modality,
  review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status != 'Good'
  and visibility is null
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
) as foo
  join file_series using (series_instance_uid)
  join file_study using (file_id) 
  join file_patient using(file_id)
  join ctp_file using(file_id)
where
  visibility is null
order by patient_id, study_instance_uid, series_instance_uid
