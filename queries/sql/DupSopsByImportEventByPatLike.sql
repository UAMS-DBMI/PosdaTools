-- Name: DupSopsByImportEventByPatLike
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'num_files']
-- Args: ['patient_id_like']
-- Tags: ['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event']
-- Description: Get Series in A Collection
-- 

select
  distinct sop_instance_uid, count(distinct file_id) as num_files
from (
  select distinct sop_instance_uid, file_id 
  from file_sop_common 
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
group by sop_instance_uid
