-- Name: VisibleDicomFilesByCollection
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'file_id']
-- Args: ['collection']
-- Tags: ['ad_hoc queries']
-- Description: Visible DICOM files by collection
-- 

select
  distinct sop_instance_uid, max(file_id) as file_id
from
  ctp_file natural join file_sop_common
where
  project_name = ? and visibility is null
group by sop_instance_uid