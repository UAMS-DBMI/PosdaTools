-- Name: CreateActivityTimepoint
-- Schema: posda_queries
-- Columns: []
-- Args: ['actiity_id', 'who_created', 'comment', 'creating_user']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

insert into activity_timepoint(
  activity_id, when_created, who_created, comment, creating_user
) values (
  ?, now(), ?, ?, ?
)
returning activity_timepoint_id
