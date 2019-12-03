-- Name: SetActivityThirdPartyUrl
-- Schema: posda_queries
-- Columns: []
-- Args: ['third_party_analysis_url', 'activity_id']
-- Tags: ['activity_timepoint_support', 'activity_support']
-- Description: Set the third_party_analysis_url in activity_table


update activity set
  third_party_analysis_url = ?
where
  activity_id = ?