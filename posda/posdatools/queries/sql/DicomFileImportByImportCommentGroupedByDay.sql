-- Name: DicomFileImportByImportCommentGroupedByDay
-- Schema: posda_files
-- Columns: ['day', 'num_files']
-- Args: ['import_comment']
-- Tags: []
-- Description:  Get Daily Summary of number of files imported from specific DICOM calling AE title
--

select date_trunc as day, count as num_files from (
select 
  distinct(date_trunc('day', import_time)),
  count(distinct file_id)
from
  import_event natural join file_import
where 
  import_comment = ?
group by date_trunc
) as foo