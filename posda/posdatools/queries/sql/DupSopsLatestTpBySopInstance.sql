-- Name: DupSopsLatestTpBySopInstance
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality', 'file_id']
-- Args: ['activity_id', 'sop_instance_uid']
-- Tags: ['duplicates', 'Duplicate SOPS']
-- Description: Get Info for a Dup Sop in activity by sop_instance_uid
-- 

select
  distinct series_instance_uid, sop_instance_uid, dicom_file_type, modality,file_id
from
  file_series natural join
  file_sop_common natural join
  dicom_file natural join
  activity_timepoint_file
where
  activity_timepoint_id = (
  select max(activity_timepoint_id) as activity_timepoint_id
  from activity_timepoint where activity_id = ?)
  and sop_instance_uid = ?
