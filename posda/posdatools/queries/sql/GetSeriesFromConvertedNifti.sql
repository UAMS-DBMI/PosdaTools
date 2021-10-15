-- Name: GetSeriesFromConvertedNifti
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['nifti_file_id']
-- Tags: ['nifti']
-- Description: Get a report on defaced nifti files
-- 

select 
  series_instance_uid
from 
  nifti_file_from_series
where
 nifti_file_id = ?