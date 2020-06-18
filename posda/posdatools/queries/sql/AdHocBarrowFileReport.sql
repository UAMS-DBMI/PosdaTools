-- Name: AdHocBarrowFileReport
-- Schema: posda_files
-- Columns: ['file_id', 'original_file_name', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'series_description', 'dicom_file_type', 'file_name', 'instance_number', 'mr_scanning_seq', 'mr_scanning_var', 'mr_scan_options', 'mr_acq_type', 'mr_slice_thickness', 'mr_repetition_time', 'mr_echo_time', 'mr_magnetic_field_strength', 'mr_spacing_between_slices', 'mr_echo_train_length', 'mr_software_version', 'mr_flip_angle']
-- Args: ['activity_timepoint_id']
-- Tags: ['import_events']
-- Description: List of values seen in scan by ElementSignature with VR and count
--

select
  distinct file_id, fi.file_name as original_file_name, instance_number,  patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, series_description, dicom_file_type,
  mr_scanning_seq, mr_scanning_var, mr_scan_options,
  mr_acq_type, mr_slice_thickness, mr_repetition_time,
  mr_echo_time, mr_magnetic_field_strength, mr_spacing_between_slices,
  mr_echo_train_length, mr_software_version, mr_flip_angle
from
  file_patient natural join file_series natural join
  file_study natural join dicom_file natural join
  file_sop_common natural join
  file_mr join file_import fi using(file_id)
where
  file_id in (
    select file_id from activity_timepoint_file where activity_timepoint_id = ?
  )
order by original_file_name