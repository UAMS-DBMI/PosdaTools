-- Name: GetOpenActivitiesThirdParty
-- Schema: posda_queries
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed', 'third_party_analysis_url']
-- Args: []
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries
--

select
  activity_id, brief_description, when_created, who_created, when_closed, third_party_analysis_url
from activity
where when_closed is null

