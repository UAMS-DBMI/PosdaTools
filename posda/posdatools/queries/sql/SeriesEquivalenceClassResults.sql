-- Name: SeriesEquivalenceClassResults
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'equivalence_class_number', 'review_status', 'files_in_class']
-- Args: ['project_name', 'status']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get visual review status report by series for Collection, Site

select
  distinct series_instance_uid,
  equivalence_class_number, 
  review_status,
  count(distinct file_id) as files_in_class
from
  image_equivalence_class
  natural join image_equivalence_class_input_image
where series_instance_uid in (
  select 
    distinct series_instance_uid
  from
    ctp_file
    natural join file_series 
    join image_equivalence_class using(series_instance_uid) 
  where project_name = ? and review_status = ?
) group by
   series_instance_uid,
   equivalence_class_number,
   review_status
order by series_instance_uid, equivalence_class_number