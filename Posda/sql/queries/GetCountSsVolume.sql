-- Name: GetCountSsVolume
-- Schema: posda_files
-- Columns: ['num_links']
-- Args: ['sop_instance_uid']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get Structure Set Volume
-- 
-- 

select count(distinct sop_instance_uid) as num_links from 
(select 
  for_uid, study_instance_uid, series_instance_uid,
  sop_class as sop_class_uid, sop_instance as sop_instance_uid
  from ss_for natural join ss_volume where structure_set_id in (
    select 
      structure_set_id 
    from
      file_structure_set fs, file_sop_common sc
    where
      sc.file_id = fs.file_id and sop_instance_uid = ?
)
) as foo;