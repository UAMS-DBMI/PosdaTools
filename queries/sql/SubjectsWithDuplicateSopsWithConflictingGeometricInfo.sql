-- Name: SubjectsWithDuplicateSopsWithConflictingGeometricInfo
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'count']
-- Args: []
-- Tags: ['duplicates']
-- Description: Return a count of duplicate SOP Instance UIDs with conflicting Geometric Information by Patient Id, study, series
-- 

select distinct patient_id, study_instance_uid, series_instance_uid, count(*)
from
  file_patient natural join file_sop_common natural join file_series natural join file_study
where sop_instance_uid in (
  select sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
    select 
      distinct sop_instance_uid, iop as image_orientation_patient,
      ipp as image_position_patient,
      pixel_spacing,
      pixel_rows as i_rows,
      pixel_columns as i_columns
    from
      file_sop_common join 
      file_patient using (file_id) join
      file_image using (file_id) join 
      file_series using (file_id) join
      file_study using (file_id) join
      image using (image_id) join
      file_image_geometry using (file_id) join
      image_geometry using (image_geometry_id) 
    ) as foo 
    group by sop_instance_uid
  ) as foo where count > 1
) group by patient_id, study_instance_uid, series_instance_uid