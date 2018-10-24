-- Name: GetSeriesVisibilityCountsBySeriesAndVisualReviewId
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'visibility', 'modality', 'num_files']
-- Args: ['visual_review_instance_id', 'series_instance_uid']
-- Tags: ['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow']
-- Description: Get a list of files which are hidden by series id and visual review id

select
  distinct series_instance_uid, coalesce(visibility, '<undef>'), modality,
  count(distinct file_id) as num_files
from file_series natural join ctp_file
where file_id in (
  select
    file_id
  from
    image_equivalence_class natural join image_equivalence_class_input_image
  where
    visual_review_instance_id = ? and series_instance_uid = ?
)
group by series_instance_uid, visibility, modality