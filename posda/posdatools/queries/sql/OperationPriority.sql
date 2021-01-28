-- Name: OperationPriority
-- Schema: posda_files
-- Columns: ['worker_priority']
-- Args: ['operation_name']
-- Tags: []
-- Description: Retrieve operation priority
--

select worker_priority from spreadsheet_operation where operation_name = ?
