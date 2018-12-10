-- Name: PatientByImportEventIdVisibleFiles
-- Schema: posda_files
-- Columns: ['patient_id', 'num_files']
-- Args: ['import_event_id']
-- Tags: ['ACRIN-NSCLC-FDG-PET Curation']
-- Description: Get the list of files by sop, excluding base series

select
  distinct patient_id, count(distinct file_id) as num_files
from file_patient
where file_id in (
  select distinct file_id
  from file_import natural join import_event natural left join ctp_file
  where import_event_id = ? and visibility is null
) group by patient_id order by patient_id