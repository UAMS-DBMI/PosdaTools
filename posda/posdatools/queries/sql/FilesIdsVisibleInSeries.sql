-- Name: FilesIdsVisibleInSeries
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['series_instance_uid']
-- Tags: ['by_series_instance_uid', 'file_ids', 'posda_files']
-- Description: Get Distinct Unhidden Files in Series
-- 

select
  distinct file_id
from
  file_series natural join file_sop_common natural join ctp_file
where
  series_instance_uid = ? and visibility is null
