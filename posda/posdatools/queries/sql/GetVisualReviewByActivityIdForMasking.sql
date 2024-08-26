-- Name: GetVisualReviewByActivityIdForMasking
-- Schema: posda_files
-- Columns: ['visual_review_instance_id']
-- Args: ['activity_id']
-- Tags: ['visual_review']
-- Description: Get the Visual Review Ids with IECs flagged for Masking for an Activity
--

select distinct(visual_review_instance_id)
from activity_task_status 
join visual_review_instance using(subprocess_invocation_id)
join image_equivalence_class using(visual_review_instance_id)
join masking using(image_equivalence_class_id)
where activity_id = ?
order by visual_review_instance_id asc