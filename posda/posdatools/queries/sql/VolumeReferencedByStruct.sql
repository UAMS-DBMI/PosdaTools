-- Name: VolumeReferencedByStruct
-- Schema: posda_files
-- Columns: ['for_uid', 'study_instance_uid', 'series_instance_uid', 'num_sops']
-- Args: ['file_id']
-- Tags: ['Test Case based on Soft-tissue-Sarcoma']
-- Description: Find All of the Structure Sets In Soft-tissue-Sarcoma

select 
  distinct for_uid, study_instance_uid, series_instance_uid, count(distinct sop_instance) as num_sops
from
  ss_volume natural join ss_for natural join file_structure_set
where
  file_id = ?
group by
  for_uid, study_instance_uid, series_instance_uid