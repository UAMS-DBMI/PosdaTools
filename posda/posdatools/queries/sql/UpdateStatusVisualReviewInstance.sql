-- Name: UpdateStatusVisualReviewInstance
-- Schema: posda_files
-- Columns: []
-- Args: ['visual_review_num_series_done', 'visual_review_num_equiv_class', 'visual_review_instance_id']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review']
-- Description: Get Id of Visual Review Instance

update visual_review_instance set
  visual_review_num_series_done = ?,
  visual_review_num_equiv_class = ?
where
  visual_review_instance_id = ?