-- Name: FilesInSeriesForSend
-- Schema: posda_files
-- Columns: ['file_id', 'path', 'xfer_syntax', 'sop_class_uid', 'data_set_size', 'data_set_start', 'sop_instance_uid', 'digest']
-- Args: ['series_instance_uid']
-- Tags: ['SeriesSendEvent', 'by_series', 'find_files', 'for_send']
-- Description: Get everything you need to negotiate a presentation_context
-- for all files in a series
-- 

select
  distinct file_id, root_path || '/' || rel_path as path, xfer_syntax, sop_class_uid,
  data_set_size, data_set_start, sop_instance_uid, digest
from
  file_location natural join file_storage_root
  natural join dicom_file natural join ctp_file
  natural join file_sop_common natural join file_series
  natural join file_meta natural join file
where
  series_instance_uid = ? and visibility is null
