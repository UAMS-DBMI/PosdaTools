-- Name: NewSopsReceivedBetweenDates
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'first_loaded', 'last_loaded']
-- Args: ['start_time', 'end_time']
-- Tags: ['receive_reports']
-- Description: Series received between dates with sops without duplicates
-- 

select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
          where import_time > ? and import_time < ?
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads = 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
