-- Name: SopReportForVisualReviewInstance
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'sop_instance_uid', 'modality', 'file_id', 'activity_timepoint_id']
-- Args: ['visual_review_instance_id']
-- Tags: ['visual_review']
-- Description: Get all files in a visual_review_instance
--

select
  patient_id, series_instance_uid, sop_instance_uid, modality, file_id, 
  max(activity_timepoint_id) as activity_timepoint_id
from
  file_sop_common natural join file_series natural join
  file_patient natural join
  activity_timepoint_file natural join activity_timepoint
where sop_instance_uid in (
  select sop_instance_uid from file_sop_common
  where file_id in (
    select 
      file_id
    from
      image_equivalence_class_input_image
    where
      image_equivalence_class_id in (
        select image_equivalence_class_id 
        from image_equivalence_class
        where visual_review_instance_id = ?
      )
   )
)
group by patient_id, series_instance_uid, sop_instance_uid, modality, file_id
order by patient_id, series_instance_uid, sop_instance_uid, activity_timepoint_id desc