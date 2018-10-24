-- Name: CreateBackgroundReport
-- Schema: posda_queries
-- Columns: None
-- Args: ['background_subprocess_id', 'file_id', 'name']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Create a new entry in background_subprocess_report table

insert into background_subprocess_report(
  background_subprocess_id,
  file_id,
  name
) values (
  ?, ?, ?
)
returning background_subprocess_report_id
