-- Name: ViewPathologyVisualReviewInstances
-- Schema: posda_files
-- Columns: ['pathology_visual_review_instance_id','activity_creation_id','scheduler']
-- Args: []
-- Tags: ['visual_review']
-- Description: View all visual review instance for a pathology collection activities
--

select
  pathology_visual_review_instance_id,
  activity_creation_id,
  scheduler
from
  pathology_visual_review_instance
  order by pathology_visual_review_instance desc
