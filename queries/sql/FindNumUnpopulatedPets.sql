-- Name: FindNumUnpopulatedPets
-- Schema: posda_files
-- Columns: ['num_unimported_pets']
-- Args: []
-- Tags: ['populate_posda_files', 'bills_test']
-- Description: Gets count of all files which are PET's which haven't been imported into file_pt_image yet.
-- 
-- 

select
  count(distinct file_id) as num_unimported_pets
from file_location natural join file_storage_root
where file_id in
(
  select distinct file_id from dicom_file df
  where dicom_file_type = 'Positron Emission Tomography Image Storage'
  and not exists (select file_id from file_pt_image pti where pti.file_id = df.file_id)
)