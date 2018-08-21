-- Name: GetSopsInSeriesforLGCP
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'file_id', 'for_uid']
-- Args: ['series_instance_uid']
-- Tags: ['Curation of Lung-Fused-CT-Pathology']
-- Description: Get SOP instance uid, file_id, and path for each file in series

select
  sop_instance_uid, file_id, for_uid
from 
  file_series natural join file_for natural join ctp_file
  natural join file_sop_common
where series_instance_uid = ? and visibility is null
