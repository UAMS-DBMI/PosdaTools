-- Name: GetLatestFileForSop
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['sop_instance_uid']
-- Tags: ['sop_instance_uid']
-- Description:  Get the latest file_id for a SOP
--

select max(file_id) as file_id
from file_sop_common
where sop_instance_uid = ?