-- Name: FindInconsistentSeriesWithSubjectAndStudy
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['collection']
-- Tags: ['consistency', 'find_series', 'series_consistency']
-- Description: Find Inconsistent Series
-- 

select distinct patient_id, study_instance_uid, series_instance_uid
from file_patient natural join file_study natural join file_series
where series_instance_uid in (
select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
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
  where
    project_name = ? and visibility is null
  group by
    series_instance_uid, modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
)