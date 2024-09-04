-- Name: NiftiReviewCountByActivityTimepoint
-- Schema: posda_files
-- Columns: ['nifti_file_id', 'review_status', 'activity_timepoint_id','num_reviewers']
-- Args: ['activity_timepoint_id']
-- Tags: ['nifti', 'visual_review']
-- Description: Get a summmary of Nifti visual review status by timepoint
--

select nvrf.nifti_file_id,
       nvrs.review_status,
       at_files.activity_timepoint_id,
       count(nvrs.reviewing_user) as num_reviewers
from nifti_visual_review_files nvrf
left join nifti_visual_review_status nvrs on nvrs.nifti_file_id = nvrf.nifti_file_id
join (select a.activity_id,
             atp.activity_timepoint_id,
             atpf.file_id
	    from activity a
	    join activity_timepoint atp
	    on atp.activity_id = a.activity_id
	    join activity_timepoint_file atpf
	    on atpf.activity_timepoint_id = atp.activity_timepoint_id) as at_files
on at_files.file_id = nvrf.nifti_file_id        
where at_files.activity_timepoint_id = ?
group by nvrf.nifti_file_id, nvrs.review_status, at_files.activity_timepoint_id
