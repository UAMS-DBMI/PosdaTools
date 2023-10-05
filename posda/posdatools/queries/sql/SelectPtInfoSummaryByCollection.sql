-- Name: SelectPtInfoSummaryByCollection
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'radiopharmaceutical', 'total_dose', 'half_life', 'positron_fraction', 'fov_shape', 'fov_dim', 'coll_type', 'recon_diam', 'num_files']
-- Args: ['collection']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description: Gets count of all files which are PET's which haven't been imported into file_pt_image yet.
-- 
-- 

select 
  distinct 
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  pti_radiopharmaceutical as radiopharmaceutical, 
  pti_radionuclide_total_dose as total_dose,
  pti_radionuclide_half_life as half_life,
  pti_radionuclide_positron_fraction as positron_fraction, 
  pti_fov_shape as fov_shape,
  pti_fov_dimensions as fov_dim,
  pti_collimator_type as coll_type,
  pti_reconstruction_diameter as recon_diam, 
  count(*) as num_files
from file_pt_image natural join file_patient natural join file_series natural join ctp_file 
where project_name = ?
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  radiopharmaceutical,
  total_dose,
  half_life,
  positron_fraction,
  fov_shape,
  fov_dim,
  coll_type,
  recon_diam
order by patient_id