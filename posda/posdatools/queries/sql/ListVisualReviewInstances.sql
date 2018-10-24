-- Name: ListVisualReviewInstances
-- Schema: posda_files
-- Columns: ['visual_review_instance_id', 'visual_review_reason', 'visual_review_scheduler', 'visual_review_num_series', 'when_visual_review_scheduled', 'visual_review_num_series_done', 'visual_review_num_equiv_class', 'when_visual_review_sched_complete']
-- Args: []
-- Tags: ['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow']
-- Description: Get a list of files which are hidden by series id and visual review id

select
  visual_review_instance_id, visual_review_reason,
  visual_review_scheduler,
  visual_review_num_series,
  when_visual_review_scheduled, 
  visual_review_num_series_done,
  visual_review_num_equiv_class,
  when_visual_review_sched_complete
from visual_review_instance