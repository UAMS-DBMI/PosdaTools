-- Name: GetVisualReviewInstanceInfo
-- Schema: posda_files
-- Columns: ['visual_review_reason']
-- Args: ['visual_review_instance_id']
-- Tags: ['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow']
-- Description: Get a list of Series By Visual Review Id and Status
-- 

select 
  visual_review_reason
from
  visual_review_instance
where
  visual_review_instance_id = ?