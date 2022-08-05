-- Name: InsertPathVRFiles
-- Schema: posda_files
-- Columns: []
-- Args: ['pathology_visual_review_instance_id', 'path_file_id']
-- Tags: ['pathology','visual_review']
-- Description: Create entries for the VR thumbnails for a Pathlogy SVS VR
--
--

insert into pathology_visual_review_files values (?,?) on conflict (path_file_id) do update set pathology_visual_review_instance_id = Excluded.pathology_visual_review_instance_id;
