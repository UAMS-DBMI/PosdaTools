-- Name: GetFilePathPublic
-- Schema: public
-- Columns: ['path']
-- Args: ['sop_instance_uid']
-- Tags: ['AllCollections', 'universal', 'public_posda_consistency']
-- Description: Get path to file by id

select
 dicom_file_uri as path
from
  general_image
where
  sop_instance_uid = ?