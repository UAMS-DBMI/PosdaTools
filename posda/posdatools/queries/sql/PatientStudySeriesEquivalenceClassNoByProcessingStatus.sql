-- Name: PatientStudySeriesEquivalenceClassNoByProcessingStatus
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'equivalence_class_number', 'count']
-- Args: ['processing_status']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review']
-- Description: Find Series with more than n equivalence class

select 
  distinct patient_id, study_instance_uid, series_instance_uid, equivalence_class_number, count(*) 
from 
  image_equivalence_class natural join image_equivalence_class_input_image natural join
  file_study natural join file_series natural join file_patient
where
  processing_status = ?
group by patient_id, study_instance_uid, series_instance_uid, equivalence_class_number
order by patient_id, study_instance_uid, series_instance_uid, equivalence_class_number