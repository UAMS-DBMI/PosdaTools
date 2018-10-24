-- Name: DistinctSeriesByImportEventByPatLike
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'num_files']
-- Args: ['patient_id_like']
-- Tags: ['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event']
-- Description: Get Series in A Collection
-- 

select
  distinct series_instance_uid, count(distinct file_id) as num_files
from (
  select distinct series_instance_uid, file_id 
  from file_series 
  where file_id in (
    select
      distinct file_id from file_import where import_event_id in (select import_event_id from (
        select
          distinct import_event_id, import_time,  import_type, count(distinct file_id) as num_files
        from
          import_event natural join file_import natural join file_patient
        where
          import_type = 'multi file import' and
          patient_id like ?
         group by import_event_id, import_time, import_type
       ) as foo
    )
  )
)as foo
group by series_instance_uid
