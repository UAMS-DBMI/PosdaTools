-- Name: ShowImportsBySopInstance
-- Schema: posda_files
-- Columns: ['file_id', 'import_time', 'import_type', 'import_comment']
-- Args: ['sop_instance_uid']
-- Tags: ['show_hidden']
-- Description: Show All Hide Events by Collection, Site

select 
  file_id, import_time, import_comment 
from 
  import_event natural join file_import 
where file_id in (
  select file_id from file_sop_common where sop_instance_uid = ?
)
order by import_time