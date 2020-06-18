-- Name: ImportEventsByDateRangeWithCollectionSitePatientId
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_time', 'import_type', 'collection', 'site', 'patient_id', 'num_files']
-- Args: ['from', 'to']
-- Tags: ['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event']
-- Description: Get Series in A Collection
--

select
  distinct import_event_id, import_time,  import_type, 
  project_name as collection,
  site_name as site, patient_id, count(distinct file_id) as num_files
from
  import_event natural join file_import natural join file_patient natural left join ctp_file
where
  import_time > ? and import_time < ?
group by import_event_id, import_time, import_type, collection, site, patient_id