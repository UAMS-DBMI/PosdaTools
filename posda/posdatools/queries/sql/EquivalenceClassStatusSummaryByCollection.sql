-- Name: EquivalenceClassStatusSummaryByCollection
-- Schema: posda_files
-- Columns: ['collection', 'processing_status', 'review_status', 'count']
-- Args: ['collection']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review']
-- Description: Find Series with more than n equivalence class

select
  distinct project_name as collection,
  processing_status,
  review_status, count(distinct image_equivalence_class_id)
from
  image_equivalence_class join file_series using(series_instance_uid) join ctp_file using(file_id)
where project_name = ?
group by collection, processing_status, review_status