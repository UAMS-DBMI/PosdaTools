-- Name: ExportDestinationInfo
-- Schema: posda_files
-- Columns: ['protocol', 'base_url', 'configuration']
-- Args: ['export_destination_name']
-- Tags: ['export_event']
-- Description:  get information about an export destination by name
--

select
  protocol,
  base_url,
  configuration
from 
  export_destination
where
  export_destination_name = ?