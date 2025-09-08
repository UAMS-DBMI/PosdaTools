-- Name: GetSegsAndLinkedFORsAfterCheck
-- Schema: posda_files
-- Columns: ['seg_id', 'file_id', 'file_for']
-- Args: ['activity_id']
-- Tags: ['Segmentation']
-- Description: Get FOR UID and File ID for files linked to SEGs in activity

select seg_id, file_id, ff.for_uid as file_for from file_seg_image_linkage
natural join activity_timepoint_file atf
natural join activity_timepoint at2
natural join file_for ff
where activity_timepoint_id = (
            select max(activity_timepoint_id) as activity_timepoint_id
            from activity_timepoint
            where activity_id = $1
          );
