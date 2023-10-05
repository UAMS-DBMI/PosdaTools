-- Name: GetVisibleDupSopsOfFileByFileId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['file_id']
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get all visible files with the same sop_instance_uid as the file specified by file_id
-- 
-- Note: may include original file_id (if not hidden)
--

select
  file_id
from
  file_sop_common natural left join ctp_file
where sop_instance_uid = (
  select sop_instance_uid from file_sop_common where file_id = ?
)