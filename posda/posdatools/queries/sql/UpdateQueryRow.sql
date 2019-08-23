-- Name: UpdateQueryRow
-- Schema: posda_files
-- Columns: []
-- Args: ['query', 'args', 'columns', 'tags', 'schema', 'description', 'name']
-- Tags: ['NotInteractive', 'PatientStatus', 'Update', 'queries']
-- Description: Update a row in the queries table
--

update queries set
  query = ?, args = ?, columns = ?, tags = ?, schema = ?, description = ?
where name = ?
