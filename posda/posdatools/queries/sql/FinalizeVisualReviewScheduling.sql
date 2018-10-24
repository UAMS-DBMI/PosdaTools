-- Name: FinalizeVisualReviewScheduling
-- Schema: posda_files
-- Columns: []
-- Args: ['visual_review_instance_id']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review']
-- Description: Get Id of Visual Review Instance

update visual_review_instance set
  when_visual_review_sched_complete = now()
where
  visual_review_instance_id = ?