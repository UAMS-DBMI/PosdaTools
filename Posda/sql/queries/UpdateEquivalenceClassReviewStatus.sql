-- Name: UpdateEquivalenceClassReviewStatus
-- Schema: posda_files
-- Columns: []
-- Args: ['processing_status', 'image_equivalence_class_id']
-- Tags: ['consistency', 'find_series', 'equivalence_classes', 'NotInteractive']
-- Description: For building series equivalence classes

update image_equivalence_class
set review_status = ?
where image_equivalence_class_id = ?
