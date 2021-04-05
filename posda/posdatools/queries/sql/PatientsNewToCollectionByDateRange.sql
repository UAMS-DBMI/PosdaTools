-- Name: PatientsNewToCollectionByDateRange
-- Schema: posda_files
-- Columns: ['collection','site','patient_id','qualified','study_date','num_files','num_sops','earliest_day','latest_day']
-- Args: ['collection_like', 'date_range_start', 'date_range_end', 'earliest_day']
-- Tags: []
-- Description: Find the number of new patients that have come into a collection or set of collections within a date range. Ex: Answer how much new data came in to CPTAC this month

select * from (select
  project_name, site_name, patient_id,  study_date,
  count(distinct file_id) as num_files, count (distinct sop_instance_uid) as num_sops,
  min(date_trunc('day',file_import_time)) as earliest_day, max(date_trunc('day', file_import_time)) as latest_day
from
  file_patient join ctp_file  using(file_id)
  join file_study using(file_id) join file_import using(file_id)
  join file_sop_common using(file_id)
  join import_event using(import_event_id)
where patient_id in (
  select
    distinct patient_id
  from
    file_patient join ctp_file  using(file_id)
    join file_import using(file_id)
    join import_event using(import_event_id)
  where
    project_name like ? and file_import_time > ? and file_import_time < ? and import_event_id = 0
)
group by project_name, site_name, patient_id,  study_date) as foo
where earliest_day < ?
