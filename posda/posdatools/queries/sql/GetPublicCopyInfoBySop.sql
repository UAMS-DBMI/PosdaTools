-- Name: GetPublicCopyInfoBySop
-- Schema: public
-- Columns: ['dicom_file_uri', 'project', 'site_name', 'site_id']
-- Args: ['sop_instance_uid']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select dicom_file_uri, tdp.project, dp_site_name as site_name, dp_site_id as site_id
from general_image i, trial_data_provenance tdp 
where tdp.trial_dp_pk_id = i.trial_dp_pk_id and sop_instance_uid = ?