-- Name: SeriesConsistencyExtended
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'count', 'dicom_file_type', 'modality', 'laterality', 'series_number', 'series_date', 'image_type', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments', 'iop', 'pixel_rows', 'pixel_columns']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'consistency']
-- Description: Check a Series for Consistency (including Image Type)
-- 

select distinct
  series_instance_uid, modality, series_number, laterality, series_date, dicom_file_type,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments, image_type,
  iop, pixel_rows, pixel_columns,
  count(*)
from
  file_series natural join ctp_file natural join dicom_file
  left join file_image using(file_id)
  left join image using (image_id)
  left join image_geometry using (image_id)
where series_instance_uid = ? and visibility is null
group by
  series_instance_uid, dicom_file_type, modality, series_number, laterality,
  series_date, image_type, iop, pixel_rows, pixel_columns,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments
