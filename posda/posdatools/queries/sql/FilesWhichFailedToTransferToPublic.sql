-- Name: FilesWhichFailedToTransferToPublic
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['public_copy_status']
-- Description: Get the list of files which failed to transfer to nbia from public_copy_status
--

select file_id from public_copy_status where
subprocess_invocation_id = ? and not success