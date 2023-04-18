-- Name: ForConstructingSeriesEquivalenceClasses
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'modality', 'series_number', 'laterality', 'series_date', 'dicom_file_type', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_desc', 'performed_procedure_step_comments', 'image_type', 'iop', 'pixel_rows', 'pixel_columns', 'file_id', 'ipp']
-- Args: ['series_instance_uid', 'activity_timepoint_id']
-- Tags: ['consistency', 'find_series', 'equivalence_classes']
-- Description: For building series equivalence classes

select distinct
 series_instance_uid, modality, series_number, laterality, series_date, dicom_file_type,
  performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date,
  performed_procedure_step_desc, performed_procedure_step_comments, image_type,
  iop, pixel_rows, pixel_columns,
  file_id,ipp, activity_timepoint_id
from
  file_series natural join ctp_file natural join dicom_file
  left join file_image using(file_id)
  left join image using (image_id)
  left join file_image_geometry using (file_id)
  left join image_geometry using (image_geometry_id)
  left join activity_timepoint_file using (file_id)
  where series_instance_uid = ? and activity_timepoint_id = ?
