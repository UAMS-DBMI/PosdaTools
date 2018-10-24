-- Name: GetPatientInfoById
-- Schema: posda_files
-- Columns: ['file_id', 'modality', 'series_instance_uid', 'series_number', 'laterality', 'series_date', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments', 'performed_procedure_step_comments', 'date_fixed']
-- Args: ['file_id']
-- Tags: ['reimport_queries']
-- Description: Get file path from id

select
  file_id,
  patient_name,
  patient_id,
  id_issuer,
  dob,
  sex,
  time_ob,
  other_ids
  other_name,
  ethnic_group,
  comments
from file_patient
where file_id = ?