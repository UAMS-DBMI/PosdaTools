-- Name: ActivityTimepointsForActivity
-- Schema: posda_queries
-- Columns: ['activity_id', 'activity_created', 'activity_description', 'activity_timepoint_id', 'timepoint_created', 'comment', 'creating_user']
-- Args: ['activity_id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select
  activity_id, a.when_created as activity_created,
  brief_description as activity_description, activity_timepoint_id,
  t.when_created as timepoint_created, 
  comment, creating_user
from
  activity a join activity_timepoint t using(activity_id)
where
  activity_id = ?