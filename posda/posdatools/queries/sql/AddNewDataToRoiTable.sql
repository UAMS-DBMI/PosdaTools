-- Name: AddNewDataToRoiTable
-- Schema: posda_files
-- Columns: []
-- Args: ['max_x', 'max_y', 'max_z', 'min_x', 'min_y', 'min_z', 'roi_interpreted_type', 'roi_obser_desc', 'roi_obser_label', 'roi_id']
-- Tags: ['NotInteractive', 'used_in_processing_structure_set_linkages']
-- Description: Get the file_storage root for newly created files

update roi set
  max_x = ?,
  max_y = ?,
  max_z = ?,
  min_x = ?,
  min_y = ?,
  min_z = ?,
  roi_interpreted_type = ?,
  roi_obser_desc = ?,
  roi_obser_label = ?
where
  roi_id = ?