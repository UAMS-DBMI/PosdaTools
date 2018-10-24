-- Name: EquivalenceClassStatusSummary
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'processing_status', 'count']
-- Args: []
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review']
-- Description: Find Series with more than n equivalence class

select 
  distinct patient_id, study_instance_uid, series_instance_uid,
  processing_status, count(*) 
from 
  image_equivalence_class natural join image_equivalence_class_input_image 
  natural join file_study natural join file_series natural join file_patient
group by 
  patient_id, study_instance_uid, series_instance_uid, processing_status
order by 
  patient_id, study_instance_uid, series_instance_uid, processing_status