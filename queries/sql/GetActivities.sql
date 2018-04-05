-- Name: GetActivities
-- Schema: posda_queries
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed']
-- Args: ['user']
-- Tags: ['AllCollections', 'queries', 'activities']
-- Description: Get a list of available queries

select
  activity_id, brief_description, when_created, who_created, when_closed
from activity
where who_created = ?
