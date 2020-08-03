-- Name: GetVisualReviewByActivityIdLatest
-- Schema: posda_files
-- Columns: ['visual_review_instance_id']
-- Args: ['activity_id']
-- Tags: ['visual_review']
-- Description:  Get the Visual Review Instance Ids for an Activity
--

select 
  max(visual_review_instance_id) as visual_review_instance_id
from
  activity_task_status join visual_review_instance using(subprocess_invocation_id)
where activity_id = ?