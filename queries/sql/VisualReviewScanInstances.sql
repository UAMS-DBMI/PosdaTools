-- Name: VisualReviewScanInstances
-- Schema: posda_files
-- Columns: ['id', 'reason', 'who_by', 'num_series', 'when_scheduled', 'num_done', 'num_equiv', 'sched_finish_time']
-- Args: []
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_status']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select 
  visual_review_instance_id as id, visual_review_reason as reason,
  visual_review_scheduler as who_by, visual_review_num_series as num_series,
  when_visual_review_scheduled as when_scheduled,
  visual_review_num_series_done as num_done,
  visual_review_num_equiv_class as num_equiv,
  when_visual_review_sched_complete as sched_finish_time
from visual_review_instance
  order by when_scheduled