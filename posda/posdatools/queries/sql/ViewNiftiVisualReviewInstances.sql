-- Name: ViewNiftiVisualReviewInstances
-- Schema: posda_files
-- Columns: ['nifti_visual_review_instance_id','activity_id','scheduler']
-- Args: ['activity_id']
-- Tags: ['nifti','visual_review']
-- Description: View all visual review instance for a nifti collection activities
--

select
  nifti_visual_review_instance_id,
  activity_id,
  scheduler
from
  nifti_visual_review_instance
  where activity_id = ?
  order by nifti_visual_review_instance desc
