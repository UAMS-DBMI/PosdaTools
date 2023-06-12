-- Name: FindInconsistentSeriesIgnoringTimeCollectionSite
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['consistency', 'find_series', 'series_consistency']
-- Description: Find Inconsistent Series by Collection Site
-- 

select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    count(*)
  from
    file_series natural join ctp_file
  where
    project_name = ? and site_name = ?
  group by
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
