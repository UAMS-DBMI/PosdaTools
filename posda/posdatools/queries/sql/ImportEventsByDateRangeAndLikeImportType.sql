-- Name: ImportEventsByDateRangeAndLikeImportType
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_time', 'import_type', 'collection', 'site', 'patient_id', 'num_files']
-- Args: ['from', 'to', 'like_import_type']
-- Tags: []
-- Description: Get ImportEvents By Date Range
--

select
  distinct import_event_id, import_time,  import_type, 
  project_name as collection,
  site_name as site, patient_id, count(distinct file_id) as num_files
from
  import_event natural join file_import natural join file_patient natural left join ctp_file
where
  import_time > ? and import_time < ? and import_type like ?
group by import_event_id, import_time, import_type, collection, site, patient_id