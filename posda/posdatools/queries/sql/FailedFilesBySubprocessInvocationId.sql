-- Name: FailedFilesBySubprocessInvocationId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['counts']
-- Description: Find ids of failing files in ApplyDispositions
--

select file_id
from public_copy_status
where subprocess_invocation_id = ? and not success