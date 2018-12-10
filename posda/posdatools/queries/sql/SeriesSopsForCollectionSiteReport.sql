-- Name: SeriesSopsForCollectionSiteReport
-- Schema: posda_files
-- Columns: ['collection', 'site', 'num_subjects', 'num_series', 'num_images']
-- Args: []
-- Tags: ['AllCollections', 'q_stats']
-- Description: Get a list of collections and sites
-- 

select 
  distinct project_name as collection, site_name as site, count(distinct patient_id) as num_subjects,
  count(distinct series_instance_uid) as num_series, count(distinct sop_instance_uid) as num_images
from
  ctp_file natural join file_patient natural join file_series natural join file_sop_common natural join file_image
where visibility is null
group by collection, site
order by num_images desc