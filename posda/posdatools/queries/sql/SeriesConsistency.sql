-- Name: SeriesConsistency
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'count', 'modality', 'series_number', 'laterality', 'series_date', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'consistency', 'series_consistency']
-- Description: Check a Series for Consistency
-- 

select distinct
  series_instance_uid, modality, series_number, laterality, series_date,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments,
  count(*)
from
  file_series natural join ctp_file
where series_instance_uid = ? and visibility is null
group by
  series_instance_uid, modality, series_number, laterality, series_date,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments
