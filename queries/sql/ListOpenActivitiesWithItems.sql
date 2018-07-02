-- Name: ListOpenActivitiesWithItems
-- Schema: posda_queries
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created', 'num_items']
-- Args: []
-- Tags: ['AllCollections', 'queries', 'activities']
-- Description: Get a list of available queries

select
  distinct activity_id,
  brief_description,
  when_created,
  who_created,
  count(distinct user_inbox_content_id) as num_items
from
  activity natural join activity_inbox_content
where when_closed is null
group by activity_id, brief_description, when_created, who_created
order by activity_id desc