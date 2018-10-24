-- Name: DistinctSeriesByCollectionLikePublic
-- Schema: public
-- Columns: ['series_instance_uid', 'modality', 'num_images']
-- Args: ['collection_like']
-- Tags: ['by_collection', 'find_series', 'public']
-- Description: Get Series in A Collection
-- 

select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project like ?
group by series_instance_uid, modality