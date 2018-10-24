-- Name: SeriesEquivalenceClassNoByProcessingStatus
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'equivalence_class_number', 'count']
-- Args: ['processing_status']
-- Tags: ['find_series', 'equivalence_classes', 'consistency']
-- Description: Find Series with more than n equivalence class

select 
  distinct series_instance_uid, equivalence_class_number, count(*) 
from 
  image_equivalence_class natural join image_equivalence_class_input_image
where
  processing_status = ?
group by series_instance_uid, equivalence_class_number
order by series_instance_uid, equivalence_class_number