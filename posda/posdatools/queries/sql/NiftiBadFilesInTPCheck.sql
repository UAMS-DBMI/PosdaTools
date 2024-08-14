-- Name: NiftiBadFilesInTPCheck
-- Schema: posda_files
-- Columns: ['nifti_file_id', 'num_reviews', 'num_reviewers', 'num_bad']
-- Args: ['activity_timepoint_id', 'minimum_review_count', 'minimum_reviewers']
-- Tags: ['nifti', 'visual_review']
-- Description: List review summary for nifti files that were marked bad or have had too few reviews
--

select nifti_file_id, num_reviews, num_reviewers, num_bad
from
activity_timepoint b
natural join activity_timepoint_file atf
join (select nifti_file_id, count(b.good_status) as num_reviews, 
    count(distinct b.reviewing_user) as num_reviewers,  
    count(b.good_status) filter (where not good_status) as num_bad
    from nifti_visual_review_files a 
    natural left join nifti_visual_review_status b
    natural join nifti_visual_review_instance c
    group by a.nifti_file_id,activity_creation_id) as rev_counts 
on atf.file_id = rev_counts.nifti_file_id
where activity_timepoint_id = ? and (num_reviews < ? or num_reviewers < ? or num_bad > 0)
