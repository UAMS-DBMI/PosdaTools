-- Name: DistinctSeriesByCollectionExceptModality
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'modality', 'count']
-- Args: ['project_name', 'modality']
-- Tags: ['by_collection', 'find_series']
-- Description: Get Series in A Collection with modality other than specified
-- 

select distinct series_instance_uid, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id
 from file_series natural join file_sop_common
   natural join ctp_file
where
  project_name = ? and modality != ?)
as foo
group by series_instance_uid, sop_instance_uid, modality)
as foo
group by series_instance_uid, modality
