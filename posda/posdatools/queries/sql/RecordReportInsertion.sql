-- Name: RecordReportInsertion
-- Schema: posda_queries
-- Columns: []
-- Args: ['posda_id_of_report_file', 'rows_in_report', 'background_subprocess_id']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Record the upload of a report file by a background subprocess
-- 
-- used in a background subprocess when a report file is uploaded

insert into report_inserted(
  report_file_in_posda, report_rows_generated, background_subprocess_id
)values(
  ?, ?, ?
)