-- Name: IsThisOperationOutdated
-- Schema: posda_files
-- Columns: ['outdated']
-- Args: ['operation_name']
-- Tags: []
-- Description: Check if the specificed Operation is outdated
--

select outdated from spreadsheet_operation where operation_name = ?