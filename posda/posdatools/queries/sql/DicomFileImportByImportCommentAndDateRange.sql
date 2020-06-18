-- Name: DicomFileImportByImportCommentAndDateRange
-- Schema: posda_files
-- Columns: ['date_trunc', 'count']
-- Args: ['grouping', 'from', 'to', 'import_comment']
-- Tags: []
-- Description:  Get Daily Summary of number of files imported from specific DICOM calling AE title
--

select
   distinct(date_trunc(?, import_time)), count(distinct file_id)
from
   file_import natural join import_event
where 
  import_time >= ? and import_time < ? and import_comment = ?
group by date_trunc