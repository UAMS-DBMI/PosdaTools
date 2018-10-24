-- Name: StudyNickname
-- Schema: posda_nicknames
-- Columns: ['project_name', 'site_name', 'subj_id', 'study_nickname']
-- Args: ['study_instance_uid']
-- Tags: []
-- Description: Get a nickname, etc for a particular study uid
-- 

select
  project_name, site_name, subj_id, study_nickname
from
  study_nickname
where
  study_instance_uid = ?
