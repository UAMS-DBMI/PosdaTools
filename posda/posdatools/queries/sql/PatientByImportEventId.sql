-- Name: PatientByImportEventId
-- Schema: posda_files
-- Columns: ['patient_id', 'visibility', 'num_files']
-- Args: ['import_event_id']
-- Tags: ['ACRIN-NSCLC-FDG-PET Curation']
-- Description: Get the list of files by sop, excluding base series

select
  distinct patient_id, visibility, count(distinct file_id) as num_files
from file_patient natural left join ctp_file
where file_id in (
  select distinct file_id
  from file_import natural join import_event 
  where import_event_id = ?
) group by patient_id, visibility order by patient_id, visibility