-- Name: PosdaTotalsWithDateRangeWithHidden
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files']
-- Args: ['start_time', 'end_time']
-- Tags: []
-- Description: Get posda totals by date range
-- 

select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
           natural join file_import natural join import_event
        where
          import_time >= ? and
          import_time < ? 
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
