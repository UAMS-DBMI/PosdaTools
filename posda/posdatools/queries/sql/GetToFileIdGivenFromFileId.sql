-- Name: GetToFileIdGivenFromFileId
-- Schema: posda_files
-- Columns: ['to_file_id']
-- Args: ['from_file_id']
-- Tags: ['edit_status']
-- Description: Get List of visible patients with CTP data

select file_id as to_file_id from file where digest in (
select to_file_digest as digest from dicom_edit_compare where from_file_digest in
(select digest as from_file_digest from file where file_id = ?))