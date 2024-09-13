-- Name: CreateNiftiVisualReviewInstance
-- Schema: posda_files
-- Columns: ['nifti_visual_review_instance_id']
-- Args: ['activity_id', 'scheduler']
-- Tags: ['visual_review']
-- Description: Create a visual review instance for a nifti collection activity
-- 

--

insert into nifti_visual_review_instance(
  activity_id,
  scheduler,
  scheduled
) values (
  ?, ?, now())
  returning nifti_visual_review_instance_id;
