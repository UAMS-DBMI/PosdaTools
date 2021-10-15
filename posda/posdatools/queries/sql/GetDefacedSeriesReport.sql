-- Name: GetDefacedSeriesReport
-- Schema: posda_files
-- Columns: ['file_id', 'series_instance_uid', 'num_files']
-- Args: []
-- Tags: ['nifti']
-- Description: Get a report on defaced nifti files
-- 

select distinct 
 nifti_file_id as file_id, series_instance_uid, count(*) as num_files
from 
  dicom_slice_nifti_slice dsns, file_series fs, file_nifti_defacing fnd
where
  fs.file_id = dsns.dicom_file_id and
  fnd.from_nifti_file = dsns.nifti_file_id and
  fnd.to_nifti_file is not null
group by nifti_file_id, series_instance_uid