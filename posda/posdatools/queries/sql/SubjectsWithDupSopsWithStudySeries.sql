-- Name: SubjectsWithDupSopsWithStudySeries
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'patient_id', 'count']
-- Args: []
-- Tags: ['pix_data_dups']
-- Description: Find list of series with SOP with conflicting study or series

select 
  distinct project_name, site_name, patient_id, count(distinct file_id)
from
  ctp_file natural join file_sop_common natural join file_patient
where sop_instance_uid in (
  select distinct sop_instance_uid
  from (
    select
      distinct sop_instance_uid, count(*)
    from (
      select
        sop_instance_uid, study_instance_uid, series_instance_uid
      from
        file_sop_common natural join file_series natural join file_study
    )as foo group by sop_instance_uid
  ) as foo where count > 1
)
group by
  project_name, site_name, patient_id
order by 
  project_name, site_name, patient_id, count desc
  