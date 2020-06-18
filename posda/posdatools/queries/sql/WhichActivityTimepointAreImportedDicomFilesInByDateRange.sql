-- Name: WhichActivityTimepointAreImportedDicomFilesInByDateRange
-- Schema: posda_files
-- Columns: ['activity_timepoint_id', 'num_files']
-- Args: ['from', 'to', 'import_comment']
-- Tags: []
-- Description:  Get activity timepoints for files imported from specific DICOM calling AE title by date range
--

select 
  distinct coalesce(activity_timepoint_id, 0) as activity_timepoint_id, count(distinct file_id) as num_files
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
group by activity_timepoint_id