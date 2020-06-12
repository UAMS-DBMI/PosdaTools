-- Name: ExportDestinationInfoByExportId
-- Schema: posda_files
-- Columns: ['export_destination_name', 'destination_import_event_id', 'destination_import_event_closed', 'protocol', 'base_url', 'configuration', 'num_files']
-- Args: ['export_event_id']
-- Tags: ['export_event']
-- Description:  get information about an export destination by name
--

select
  export_destination_name,
  destination_import_event_id,
  destination_import_event_closed,
  protocol,
  base_url,
  configuration,
  (select count(distinct file_id) from file_export f where e.export_event_id = f.export_event_id) as num_files
from 
  export_event e natural join export_destination
where
  export_event_id = ?
