-- Name: SopNickname
-- Schema: posda_nicknames
-- Columns: ['project_name', 'site_name', 'subj_id', 'sop_nickname', 'modality', 'has_modality_conflict']
-- Args: ['sop_instance_uid']
-- Tags: []
-- Description: Get a nickname, etc for a particular SOP Instance  uid
-- 

select
  project_name, site_name, subj_id, sop_nickname, modality,
  has_modality_conflict
from
  sop_nickname
where
  sop_instance_uid = ?
