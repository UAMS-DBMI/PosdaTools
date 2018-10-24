-- Name: CreateEquivalenceClassNew
-- Schema: posda_files
-- Columns: []
-- Args: ['series_instance_uid', 'equivalence_class_number', 'visual_review_instance_id']
-- Tags: ['consistency', 'find_series', 'equivalence_classes', 'NotInteractive']
-- Description: For building series equivalence classes

insert into image_equivalence_class(
  series_instance_uid,
  equivalence_class_number,
  visual_review_instance_id,
  processing_status
) values (
  ?, ?, ?, 'Preparing'
)
