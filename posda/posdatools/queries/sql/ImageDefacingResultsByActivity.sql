-- Name: ImageDefacingResultsByActivity
-- Schema: posda_files
-- Columns: ['subprocess_invocation_id', 'file_id', 'defaced_file_id', 'three_d', 'face_box', 'defaced', 'success', 'error_code', 'series_instance_uid', 'mapped_to_dicom_files', 'nifti_base_file_name', 'nifti_json_file_id', 'iop', 'first_ipp', 'last_ipp', 'specified_gantry_tilt', 'computed_gantry_tilt', 'num_files_in_series', 'num_files_selected_from_series']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description: List of files not found faces in defacing
-- 

select
 subprocess_invocation_id,
 from_nifti_file as file_id,
 to_nifti_file as defaced_file_id,
 three_d_rendered_face as three_d,
 three_d_rendered_face_box as face_box,
 three_d_rendered_defaced as defaced,
 success,
 error_code,
 series_instance_uid,
 mapped_to_dicom_files,
 nifti_base_file_name,
 nifti_json_file_id,
 nffs.iop,
 first_ipp,
 last_ipp,
 specified_gantry_tilt,
 computed_gantry_tilt,
 num_files_in_series,
 num_files_selected_from_series
from file_nifti_defacing fnd, nifti_file_from_series nffs
where
  fnd.from_nifti_file = nffs.nifti_file_id and
  success is not null and
  subprocess_invocation_id in (
    select
     distinct subprocess_invocation_id
    from
      file_nifti_defacing
    where
      from_nifti_file in (
        select file_id
        from activity_timepoint_file
        where activity_timepoint_id in (
          select activity_timepoint_id
        from activity_timepoint
          where activity_id = ?
        )
    )
)