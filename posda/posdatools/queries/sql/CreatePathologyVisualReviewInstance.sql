-- Name: CreatePathologyVisualReviewInstance
-- Schema: posda_files
-- Columns: ['pathology_visual_review_instance_id']
-- Args: ['activity_creation_id','scheduler']
-- Tags: ['visual_review']
-- Description: Create a visual review instance for a pathology collection activity
--
--

insert into pathology_visual_review_instance(
  activity_creation_id,
  scheduler,
  scheduled
) values (
  ?, ?, now())
  returning pathology_visual_review_instance_id;
