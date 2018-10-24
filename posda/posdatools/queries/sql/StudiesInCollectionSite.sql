-- Name: StudiesInCollectionSite
-- Schema: posda_files
-- Columns: ['study_instance_uid']
-- Args: ['project_name', 'site_name']
-- Tags: ['find_studies']
-- Description: Get Studies in A Collection, Site
-- 

select
  distinct study_instance_uid
from
  file_study natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null
