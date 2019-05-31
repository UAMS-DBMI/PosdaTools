-- Name: CollectionSiteFromTp
-- Schema: posda_queries
-- Columns: ['collection_name', 'site_name']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoint_support']
-- Description: Get the collection and site from a TP

select distinct
    project_name as collection_name,
    site_name
from
    activity_timepoint_file
    natural join ctp_file
where
    activity_timepoint_id = ?
