-- Name: AddAnExportDestination
-- Schema: posda_files
-- Columns: []
-- Args: ['destination_name', 'protocol', 'base_url']
-- Tags: ['export_event']
-- Description: Add an export destination
--

insert into export_destination(
  export_destination_name, protocol, base_url
) values (
  ?, ?, ?
)