-- Name: GetOpenActivities
-- Schema: posda_queries
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed']
-- Args: []
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries

select
  activity_id, brief_description, when_created, who_created, when_closed
from activity
where when_closed is null

