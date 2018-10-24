-- Name: ImportIntoFileSeries
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'modality', 'series_instance_uid', 'series_number', 'laterality', 'series_date', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments']
-- Tags: ['reimport_queries']
-- Description: Get file path from id

insert into file_series
  (file_id, modality, series_instance_uid,
   series_number, laterality, series_date,
   series_time, performing_phys, protocol_name,
   series_description, operators_name, body_part_examined,
   patient_position, smallest_pixel_value, largest_pixel_value,
   performed_procedure_step_id, performed_procedure_step_start_date,
       performed_procedure_step_start_time,
   performed_procedure_step_desc, performed_procedure_step_comments)
values
  (?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?)
