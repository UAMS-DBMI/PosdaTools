-- Name: WhatDaysHaveDicomImportsWhichAreNotInActivityTimepointBySourceAndDateRange
-- Schema: posda_files
-- Columns: ['import_time', 'num_files']
-- Args: ['grouping', 'from', 'to', 'import_comment']
-- Tags: []
-- Description:  Get activity timepoints for files imported from specific DICOM calling AE title by date range
--

select distinct date_trunc as import_time, count(file_id) as num_files from (
select 
  distinct date_trunc(?, import_time), file_id
  from file_import natural join import_event where file_id in (
select 
  distinct file_id
from (
  select 
    distinct coalesce(activity_timepoint_id, 0) as activity_timepoint_id, file_id
  from 
    file_import natural left join activity_timepoint_file
  where file_id in (
    select
      file_id
    from
       file_import natural join import_event
    where 
      import_time >= ? and import_time < ? and import_comment = ?
  )
) as foo
where activity_timepoint_id = 0
) 
) as foo
group by import_time

