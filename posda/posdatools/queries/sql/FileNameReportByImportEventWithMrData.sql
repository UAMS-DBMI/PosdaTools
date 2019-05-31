-- Name: FileNameReportByImportEventWithMrData
-- Schema: posda_files
-- Columns: ['file_id', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'series_description', 'dicom_file_type', 'file_name', 'mr_scanning_seq', 'mr_scanning_var', 'mr_scan_options', 'mr_acq_type', 'mr_slice_thickness', 'mr_repetition_time', 'mr_echo_time', 'mr_magnetic_field_strength', 'mr_spacing_between_slices', 'mr_echo_train_length', 'mr_software_version', 'mr_flip_angle']
-- Args: ['import_event_id']
-- Tags: ['import_events']
-- Description: List of values seen in scan by ElementSignature with VR and count
-- 

select
  file_id, patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, series_description, dicom_file_type, file_name,
  mr_scanning_seq, mr_scanning_var, mr_scan_options,
  mr_acq_type, mr_slice_thickness, mr_repetition_time,
  mr_echo_time, mr_magnetic_field_strength, mr_spacing_between_slices,
  mr_echo_train_length, mr_software_version, mr_flip_angle
from
  file_import natural join file_patient natural join file_series natural join
  file_study natural join dicom_file natural left join file_mr
where
  import_event_id = ?
order by file_name