-- Name: NiftiReviewCountByActivity
-- Schema: posda_files
-- Columns: ['nifti_file_id', 'review_status', 'latest_timepoint','num_reviewers']
-- Args: ['activity_id']
-- Tags: ['nifti', 'visual_review']
-- Description: Get a summmary of Nifti visual review status by activity
--

select nvrf.nifti_file_id,
       nvrs.review_status,
       latest_timepoint,
       count(nvrs.reviewing_user) as num_reviewers
from nifti_visual_review_files nvrf
left join nifti_visual_review_status nvrs on nvrs.nifti_file_id = nvrf.nifti_file_id
join (select a.activity_id,
             atpf.file_id, 
             max(atp.activity_timepoint_id) as latest_timepoint 
	    from activity a
	    join activity_timepoint atp
	    on atp.activity_id = a.activity_id
	    join activity_timepoint_file atpf
	    on atpf.activity_timepoint_id = atp.activity_timepoint_id
        group by a.activity_id, atpf.file_id) as latestAT 
on latestAT.file_id = nvrf.nifti_file_id        
where latestAT.activity_id = ?
group by nvrf.nifti_file_id, nvrs.review_status, latest_timepoint
