-- Name: GetApparentlyUnsupportedSopClasses
-- Schema: posda_files
-- Columns: ['dicom_file_type', 'sop_class_uid', 'num_files', 'last', 'first']
-- Args: []
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Find files with no file series by dicom_file_type and sop_class_uid
--

select 
  distinct dicom_file_type, sop_class_uid, count(*) as num_files, max(file_id) as last, min(file_id) as first
from 
  dicom_file natural join file_sop_common
where file_id in (
  select file_id 
  from dicom_file df
  where not exists (
    select file_id from file_series s where s.file_id = df.file_id
  )
)
group by dicom_file_type, sop_class_uid