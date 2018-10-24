-- Name: ListOpenActivities
-- Schema: posda_queries
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created']
-- Args: []
-- Tags: ['AllCollections', 'queries', 'activities']
-- Description: Get a list of available queries

select
  activity_id,
  brief_description,
  when_created,
  who_created
from
  activity
where when_closed is null
order by activity_id desc