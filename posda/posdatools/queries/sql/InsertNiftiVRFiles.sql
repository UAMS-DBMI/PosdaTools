-- Name: InsertNiftiVRFiles
-- Schema: posda_files
-- Columns: []
-- Args: ['nifti_visual_review_instance_id', 'nifti_file_id']
-- Tags: ['nifti','visual_review']
-- Description: Create entries for the files for a Nifti VR
--
--

insert into nifti_visual_review_files 
values (?,?) 
on conflict (nifti_file_id) do update 
set nifti_visual_review_instance_id = Excluded.nifti_visual_review_instance_id;
