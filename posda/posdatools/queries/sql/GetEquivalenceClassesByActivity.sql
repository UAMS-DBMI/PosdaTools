-- Name: GetEquivalenceClassesByActivity
-- Schema: posda_files
-- Columns: ['visual_review_instance_id', 'series_instance_uid', 'equivalence_class_number', 'projection_type', 'file_id', 'num_files']
-- Args: ['activity_id']
-- Tags: ['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow']
-- Description: ImageEquivalenceClasses for Activity
-- 

select 
  visual_review_instance_id,
  series_instance_uid, 
  equivalence_class_number,
  projection_type,
  o.file_id,
  count(distinct i.file_id) as num_files
from
  image_equivalence_class join
  image_equivalence_class_input_image i
  using (image_equivalence_class_id) join
  image_equivalence_class_out_image o
  using (image_equivalence_class_id)
where visual_review_instance_id in (
  select
    visual_review_instance_id
  from
    visual_review_instance natural join activity_task_status
  where activity_id = ?
)
group by
  visual_review_instance_id, series_instance_uid,
  equivalence_class_number, projection_type, o.file_id