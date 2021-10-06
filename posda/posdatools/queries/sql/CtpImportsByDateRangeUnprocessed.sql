-- Name: CtpImportsByDateRangeUnprocessed
-- Schema: posda_files
-- Columns: ['import_time', 'num_unprocessed_files']
-- Args: ['granularity', 'from', 'to']
-- Tags: ['CTP transfers']
-- Description: Get list of CTP transfers in (i.e. import_event_id = 0
-- by date_range
-- 

select
  date_trunc(?, file_import_time) as import_time, count(distinct file_id) as num_unprocessed_files
from
  file natural join file_import
   where
    file_import_time >= ? and file_import_time < ?
    and import_event_id = 0 and is_dicom_file is null
group by import_time
order by import_time