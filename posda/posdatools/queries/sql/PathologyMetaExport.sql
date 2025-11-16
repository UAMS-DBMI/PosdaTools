-- Name: PathologyMetaExport
-- Schema: posda_files
-- Columns: ['path', 'collectionname', 'studyid','clinicaltrialsubjectid','imageid','fileid','format','modality','protocol','manufacturer','model','xresolution','yresolution','resolutionunit','magnification','mppx','mppy','image_volume_width','image_volume_height','reference_pixel_physical_value_x','reference_pixel_physical_value_y']
-- Args: ['activity_id']
-- Tags: ['pathology', 'export']
-- Description: Get metadata for pathology files in this activity.

select
  root_path || '/' || rel_path as path,
  collection_name as collectionname,
  study_name as studyid,
  clinical_trial_subject_id as clinicaltrialsubjectid,
  image_id as imageid,
  f.file_id as fileid,
  format,
  modality,
  protocol,
  manufacturer,
  model,
  xresolution,
  yresolution,
  resolutionunit,
  magnification,
  mppx,
  mppy,
  image_volume_width,
  image_volume_height,
  reference_pixel_physical_value_x,
  reference_pixel_physical_value_y
from file f
  natural join file_location fl
  natural join file_storage_root fr
  natural join pathology_patient_mapping ppm
  natural join public.pathology_image_meta
where f.file_id in (
  select
  file_id
  from activity_timepoint_file atf
  where activity_timepoint_id in
    (select
      max(activity_timepoint_id)
      from activity_timepoint atp
      where activity_id = ?));
