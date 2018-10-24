-- Name: DistinctSeriesByCollectionLikePatient
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'modality', 'count']
-- Args: ['project_name', 'patient_id_like']
-- Tags: ['by_collection', 'find_series']
-- Description: Get Series in A Collection
-- 

select distinct patient_id, series_instance_uid, modality, count(*)
from (
select distinct patient_id, series_instance_uid, sop_instance_uid, modality from (
select
   distinct patient_id, series_instance_uid, modality, sop_instance_uid,
   file_id
 from file_series natural join file_sop_common natural join file_patient
   natural join ctp_file
where
  project_name = ? and patient_id like ?
  and visibility is null)
as foo
group by patient_id, series_instance_uid, sop_instance_uid, modality)
as foo
group by patient_id, series_instance_uid, modality
