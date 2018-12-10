-- Name: ListOpenActivitiesOld
-- Schema: posda_queries
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created']
-- Args: []
-- Tags: ['AllCollections', 'queries', 'activity_support']
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