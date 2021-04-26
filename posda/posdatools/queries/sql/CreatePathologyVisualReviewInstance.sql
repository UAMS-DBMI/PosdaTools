-- Name: CreatePathologyVisualReviewInstance
-- Schema: posda_queries
-- Columns: []
-- Args: ['subprocess_invocation_id', 'activity_creation_id', 'scheduler','num_files']
-- Tags: ['visual_review']
-- Description: Create a visual review instance for a pathology collection activity
--
--

insert into pathology_visual_review_instance(
  subprocess_invocation_id,
  activity_creation_id,
  scheduler,
  num_files,
  scheduled
) values (
  ?, ?, ?, ?, now());
