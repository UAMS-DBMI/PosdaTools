-- Name: GetActivityInfo
-- Schema: posda_queries
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed']
-- Args: ['activity_id']
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries

select
  activity_id, brief_description, when_created, who_created, when_closed
from 
  activity
where
  activity_id = ?

