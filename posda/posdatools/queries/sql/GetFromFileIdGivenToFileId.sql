-- Name: GetFromFileIdGivenToFileId
-- Schema: posda_files
-- Columns: ['from_file_id']
-- Args: ['to_file_id']
-- Tags: ['edit_status']
-- Description: Get List of visible patients with CTP data

select file_id as from_file_id from file where digest = (
select from_file_digest as digest from dicom_edit_compare where to_file_digest = (select digest as to_file_digest from file where file_id = ?))