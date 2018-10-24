-- Name: CreateVisualReviewInstance
-- Schema: posda_files
-- Columns: []
-- Args: ['visual_review_reason', 'visual_review_scheduler', 'visual_review_num_series']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review']
-- Description: Create a visual review instance

insert into visual_review_instance(
  visual_review_reason,
  visual_review_scheduler,
  visual_review_num_series,
  when_visual_review_scheduled
) values (
  ?, ?, ?, now()
)