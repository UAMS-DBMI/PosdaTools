-- Name: GetSubprocessLines
-- Schema: posda_queries
-- Columns: ['line']
-- Args: ['subprocess_invocation_id']
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries

select
  line
from subprocess_lines
where
  subprocess_invocation_id = ?
order by line_number
