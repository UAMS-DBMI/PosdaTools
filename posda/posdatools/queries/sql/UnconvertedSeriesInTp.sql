-- Name: UnconvertedSeriesInTp
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'series_description', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description:  Report of series which have not been converted to Nifti
-- 

select 
  distinct 
  patient_id, series_instance_uid, series_description,
  dicom_file_type, modality, count(distinct file_id) as num_files
from
  file_series natural join file_patient natural join
  dicom_file natural join activity_timepoint_file
where
  series_instance_uid in (
    select distinct(series_instance_uid)
    from file_series fs natural join activity_timepoint_file atf
    where activity_timepoint_id = ? and not exists (
      select nifti_file_id
      from nifti_file_from_series nffs
      where nffs.series_instance_uid = fs.series_instance_uid
    )
  )
group by patient_id, series_instance_uid, series_description, dicom_file_type, modality