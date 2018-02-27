-- Name: GetVisualReviewInstanceId
-- Schema: posda_files
-- Columns: ['id']
-- Args: []
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review']
-- Description: Get Id of Visual Review Instance

select currval('visual_review_instance_visual_review_instance_id_seq') as id