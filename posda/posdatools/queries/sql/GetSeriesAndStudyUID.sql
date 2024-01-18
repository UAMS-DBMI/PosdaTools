-- Name: GetSeriesAndStudyUID
-- Schema: posda_files
-- Columns: ['study_instance_uid', 'series_instance_uid', 'sop_instance_uid']
-- Args: ['file_id']
-- Tags: []
-- Description:  Get UIDs from file
--

select distinct
  study_instance_uid, series_instance_uid, sop_instance_uid
from
  file_study natural join file_series natural join file_sop_common
 where
 	file_id = ?;
