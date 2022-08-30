-- Name: PathologyReviewCountByActivityTimepoint
-- Schema: posda_files
-- Columns: ['path_file_id', 'num_reviews', 'num_reviewers','num_bad']
-- Args: ['activity_timepoint_id']
-- Tags: ['pathology', 'visual_review']
-- Description: Get a summmary on Pathology the visual review status for a Timepoint
--

--
select path_file_id, num_reviews, num_reviewers, num_bad
from
activity_timepoint b
natural join activity_timepoint_file atf
join
(select
  path_file_id,  count(b.good_status) as num_reviews ,count( distinct b.reviewing_user) as num_reviewers,  count(b.good_status) filter (where not good_status) as num_bad
from pathology_visual_review_files a  natural left join pathology_visual_review_status b
natural join pathology_visual_review_instance c
group by a.path_file_id,activity_creation_id) as rev_counts on atf.file_id = rev_counts.path_file_id
where activity_timepoint_id = ?
