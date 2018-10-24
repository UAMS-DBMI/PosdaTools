-- Name: GetFileIdVisibilityByPatientId
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['patient_id']
-- Tags: ['ImageEdit', 'edit_files']
-- Description: Get File id and visibility for all files in a series

select distinct file_id, visibility
from file_patient natural left join ctp_file
where patient_id = ?