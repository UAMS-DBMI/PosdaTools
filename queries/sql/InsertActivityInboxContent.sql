-- Name: InsertActivityInboxContent
-- Schema: posda_queries
-- Columns: []
-- Args: ['activity_id', 'user_inbox_content_id']
-- Tags: ['AllCollections', 'queries', 'activities']
-- Description: Get a list of available queries

insert into activity_inbox_content(
 activity_id, user_inbox_content_id
) values (
  ?, ?
)
