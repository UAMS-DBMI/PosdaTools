-- Name: FindingImportEvent
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_time', 'num_files']
-- Args: ['patient_id']
-- Tags: ['ACRIN-NSCLC-FDG-PET Curation']
-- Description: Get the list of files by sop, excluding base series

select
  import_event_id, import_time, count(distinct file_id) as num_files
from import_event natural join file_import
where import_event_id in (
  select distinct import_event_id from import_event natural join file_import
  where file_id in (
    select file_id from file_patient where patient_id = ?
  )
) group by import_event_id, import_time order by import_time desc limit 100