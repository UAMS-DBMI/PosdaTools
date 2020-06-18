-- Name: GetFileDispositionsRowId
-- Schema: posda_files
-- Columns: ['export_file_dispositions_params_id']
-- Args: []
-- Tags: ['export_event']
-- Description:  return id of newly created export_file_dispositions_row 
--

select currval('export_file_dispositions_para_export_file_dispositions_para_seq') 
as export_file_dispositions_params_id
