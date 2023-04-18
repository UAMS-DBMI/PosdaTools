-- Name: DicomFilesInSeriesByStudyDate
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['series_instance_uid', 'study_date']
-- Tags: ['queries']
-- Description: Counts query by Collection, Site
-- 

select
  file_id
from
  file_series natural join file_study natural join ctp_file
where
  series_instance_uid = ? and
  study_date = ?