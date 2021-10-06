-- Name: DukeOriginalFilenames
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'series_instance_uid', 'file_name']
-- Args: []
-- Tags: []
-- Description: Get original filenames from Duke DBT Import
-- 

select distinct * from (
	with original_files as (
		select
			file_id, digest
		from
			activity_timepoint_file
			natural join file
		where
			activity_timepoint_id = (
				select max(activity_timepoint_id)
				from activity_timepoint
				where activity_id = 430
			)
	), one_back as (
		select original_files.file_id, file_name
		from original_files
		join dicom_edit_compare on to_file_digest = original_files.digest
		join file on file.digest = dicom_edit_compare.from_file_digest
		join file_import on file_import.file_id = file.file_id
	)

	select sop_instance_uid, series_instance_uid, file_name
	from one_back
	natural join file_sop_common
	natural join file_series
) a
