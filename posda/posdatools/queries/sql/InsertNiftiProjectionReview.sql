-- Name: InsertNiftiProjectionReview
-- Schema: posda_files
-- Columns: []
-- Args: ['nifti_file_id', 'reviewer', 'review_status']
-- Tags: ['nifti']
-- Description: Create row in file_nifti table
-- 

insert into nifti_projection_review(
  nifti_file_id, reviewer, review_status, review_time
) values (                                                                                                                                                                                                                                                                            ?, ?, ?, now());