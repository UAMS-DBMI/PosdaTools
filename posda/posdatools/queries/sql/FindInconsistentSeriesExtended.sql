-- Name: FindInconsistentSeriesExtended
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['collection']
-- Tags: ['consistency', 'find_series']
-- Description: Find Inconsistent Series Extended to include image type
-- 

select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    image_type, count(*)
  from
    file_series natural join ctp_file
    left join file_image using(file_id)
    left join image using(image_id)
  where
    project_name = ?
  group by
    series_instance_uid, image_type,
    modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
