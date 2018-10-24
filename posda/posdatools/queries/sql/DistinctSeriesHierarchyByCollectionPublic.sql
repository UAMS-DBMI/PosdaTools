-- Name: DistinctSeriesHierarchyByCollectionPublic
-- Schema: public
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'num_images']
-- Args: ['project_name']
-- Tags: ['by_collection', 'find_series', 'public', 'series_search']
-- Description: Get Series in A Collection
-- 

select
  distinct i. patient_id, i.study_instance_uid, s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
group by patient_id, study_instance_uid, series_instance_uid, modality