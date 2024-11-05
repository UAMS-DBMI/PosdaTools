-- Name: InsertPathologyImageDesc
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'layer_id','image_desc']
-- Tags: ['pathology']
-- Description: Insert an image Description record for a file in a pathology collection
--

INSERT INTO pathology_image_description (file_id, layer_id, image_desc)
VALUES (?, ?, ?)
ON CONFLICT (layer_id, file_id)
DO UPDATE SET image_desc = EXCLUDED.image_desc
