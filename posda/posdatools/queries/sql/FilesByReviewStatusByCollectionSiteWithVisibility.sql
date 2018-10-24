-- Name: FilesByReviewStatusByCollectionSiteWithVisibility
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'visibility']
-- Args: ['collection', 'site', 'status']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get visual review status report by series for Collection, Site

select
  distinct
  file_id,
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  sop_instance_uid,
  file_id,
  visibility
from
  image_equivalence_class_input_image
  join ctp_file using(file_id)
  join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
where 
  image_equivalence_class_id in (
    select
      image_equivalence_class_id 
    from
      image_equivalence_class 
      join file_series using(series_instance_uid)
      join ctp_file using(file_id)
    where 
      project_name = ? and site_name = ?
      and review_status = ?
)