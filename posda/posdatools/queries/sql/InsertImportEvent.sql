-- Name: InsertImportEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['time_tag']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Create an import_event

  insert into import_event(
    import_type, import_time
  ) values (
    'Processing Backlog', ?
  )