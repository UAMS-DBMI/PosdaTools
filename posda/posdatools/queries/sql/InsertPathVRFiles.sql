-- Name: InsertActivityTimepointFile
-- Schema: posda_queries
-- Columns: []
-- Args: ['pathology_visual_review_instance_id', 'svsfile_id', 'preview_file_id']
-- Tags: ['visual_review']
-- Description: Create entries for the VR thumbnails for a Pathlogy SVS VR
--
--

insert into pathology_visual_review_files values (?,?,?)
