-- Name: GetSeriesForNumSopsForConvertedNifti
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'for_uid', 'num_sops']
-- Args: ['nifti_file_id']
-- Tags: ['nifti']
-- Description: Get Series, For, and num_sops for a nifti converted from a series
-- 

select
  distinct series_instance_uid, for_uid, count(distinct sop_instance_uid) as num_sops
from
  file_series natural join file_for natural join file_sop_common
where
  series_instance_uid in (
    select series_instance_uid from nifti_file_from_series where nifti_file_id = ?
  )
group by series_instance_uid, for_uid;