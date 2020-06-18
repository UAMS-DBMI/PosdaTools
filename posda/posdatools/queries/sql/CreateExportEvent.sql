-- Name: CreateExportEvent
-- Schema: posda_files
-- Columns: ['export_event_id']
-- Args: ['submitter_type', 'subprocess_invocation_id', 'export_destination']
-- Tags: ['export_event']
-- Description:  Creates an export event
--

insert into export_event (
  submitter_type, subprocess_invocation_id, export_destination_name, creation_time, request_pending
) values (
  ?, ?, ?, now(), false
)
returning export_event_id