-- Name: GetSeriesByVisualReviewIdWithNullStatus
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['visual_review_instance_id']
-- Tags: ['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow']
-- Description: Get a list of Series By Visual Review Id and Status
-- 

select 
  distinct series_instance_uid
from
  image_equivalence_class
where
  visual_review_instance_id = ? and review_status is null