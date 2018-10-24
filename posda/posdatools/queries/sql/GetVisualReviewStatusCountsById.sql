-- Name: GetVisualReviewStatusCountsById
-- Schema: posda_files
-- Columns: ['review_status', 'num_series']
-- Args: ['visual_review_instance_id']
-- Tags: ['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow']
-- Description: Get a list of Series By Visual Review Id and Status
-- 

select 
  distinct review_status, count(distinct series_instance_uid) as num_series
from
  image_equivalence_class
where
  visual_review_instance_id = ?
group by review_status