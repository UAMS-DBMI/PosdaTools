-- Name: InsertIntoFileRoiImageLinkage
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'roi_id', 'linked_sop_instance_uid', 'linked_sop_class_uid', 'contour_file_offset', 'contour_length', 'contour_digest', 'num_points', 'contour_type']
-- Tags: ['NotInteractive', 'used_in_processing_structure_set_linkages']
-- Description: Get the file_storage root for newly created files

insert into file_roi_image_linkage(
  file_id,
  roi_id,
  linked_sop_instance_uid,
  linked_sop_class_uid,
  contour_file_offset,
  contour_length,
  contour_digest,
  num_points,
  contour_type
) values (
  ?, ?, ?, ?, ?, ?, ?, ?, ?
)