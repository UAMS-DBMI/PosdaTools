-- Name: DistinctSeriesBySubject
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'modality', 'count']
-- Args: ['subject_id', 'project_name', 'site_name']
-- Tags: ['by_subject', 'find_series']
-- Description: Get Series in A Collection, Site, Subject
-- 

select distinct series_instance_uid, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id
 from file_series natural join file_sop_common
   natural join file_patient natural join ctp_file
where
  patient_id = ? and project_name = ? 
  and site_name = ? and visibility is null)
as foo
group by series_instance_uid, sop_instance_uid, modality)
as foo
group by series_instance_uid, modality
