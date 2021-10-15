-- Name: GetConversionInfoForConvertedNifti
-- Schema: posda_files
-- Columns: ['nifti_file_from_series_id', 'series_instance_uid', 'for_uid', 'modality', 'dicom_file_type', 'iop', 'first_ipp', 'last_ipp', 'nifti_json_file_id', 'nifti_base_file_name', 'specified_gantry_tilt', 'computed_gantry_tilt', 'conversion_time', 'num_sops']
-- Args: ['nifti_file_id']
-- Tags: ['nifti']
-- Description: Get Series, For, and num_sops for a nifti converted from a series
-- 

select
  nifti_file_from_series_id, nffs.series_instance_uid, for_uid, nffs.modality, dicom_file_type,
  iop, first_ipp, last_ipp, nifti_json_file_id, nifti_base_file_name, specified_gantry_tilt,
  computed_gantry_tilt, conversion_time,
  count(distinct sop_instance_uid) as num_sops
from
  nifti_file_from_series nffs, file_series fs natural join file_for ff natural join file_sop_common fsc
where
  nifti_file_id = ? and
  nffs.series_instance_uid = fs.series_instance_uid
group by
   nifti_file_from_series_id, nffs.series_instance_uid, for_uid, nffs.modality, dicom_file_type,
  iop, first_ipp, last_ipp, nifti_json_file_id, nifti_base_file_name, specified_gantry_tilt,
  computed_gantry_tilt, conversion_time