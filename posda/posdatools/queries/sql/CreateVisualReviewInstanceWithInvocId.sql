-- Name: CreateVisualReviewInstanceWithInvocId
-- Schema: posda_files
-- Columns: []
-- Args: ['invocation_id', 'visual_review_reason', 'visual_review_scheduler', 'visual_review_num_series']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review']
-- Description: Create a visual review instance, with a suprocess_invocation_id

insert into visual_review_instance(
  subprocess_invocation_id,
  visual_review_reason,
  visual_review_scheduler,
  visual_review_num_series,
  when_visual_review_scheduled
) values (
  ?, ?, ?, ?, now()
)
