-- Name: SeriesFileCount
-- Schema: posda_files
-- Columns: ['num_files']
-- Args: ['series_instance_uid']
-- Tags: ['by_series_instance_uid', 'posda_files', 'sops']
-- Description: Get Collection, Site, Patient, Study Hierarchy in which series resides
-- 

select
  count(distinct file_id) as num_files
from
  file_series natural join
  ctp_file
where 
    series_instance_uid = ? and visibility is null
