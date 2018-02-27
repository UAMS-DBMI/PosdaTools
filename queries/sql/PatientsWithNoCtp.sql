-- Name: PatientsWithNoCtp
-- Schema: posda_files
-- Columns: ['patient_id', 'num_series', 'num_files']
-- Args: []
-- Tags: ['adding_ctp', 'find_patients', 'no_ctp_patients']
-- Description: Get Series in A Collection
-- 

select
  distinct patient_id,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files,
  min(import_time) as first_import,
  max(import_time) as last_import
from
  file_patient sc natural join file_series
  natural join file_import natural join import_event
where
  not exists (select file_id from ctp_file c where sc.file_id = c.file_id)
group by patient_id;