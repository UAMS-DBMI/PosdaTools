-- Name: NiftiReviewCountByActivity
-- Schema: posda_files
-- Columns: ['nifti_file_id', 'num_reviews', 'num_reviewers','num_bad','most_recent_timepoint_containing']
-- Args: ['activity_creation_id']
-- Tags: ['nifti', 'visual_review']
-- Description: Get a summmary of Nifti visual review status by activity
--

--
select
  nifti_file_id, count(b.good_status) as num_reviews,
  count(distinct b.reviewing_user) as num_reviewers,  
  count(b.good_status) filter (where not good_status) as num_bad,  
  most_recent_timepoint_containing
from nifti_visual_review_files a  
natural left join nifti_visual_review_status b
natural join nifti_visual_review_instance c
join (select file_id, max(e.activity_timepoint_id) as most_recent_timepoint_containing 
    from activity d
    join activity_timepoint e 
    on d.activity_id = e.activity_id
    join activity_timepoint_file f 
    on e.activity_timepoint_id = f.activity_timepoint_id
group by file_id) as latestAT 
on a.nifti_file_id = latestAT.file_id
where activity_creation_id = ?
group by a.nifti_file_id, most_recent_timepoint_containing
order by most_recent_timepoint_containing desc
