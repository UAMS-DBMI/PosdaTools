-- Name: DistinctSeriesWithPatientIdStudyDescSeriesDescSeriesInstanceUidByCollectionPublic
-- Schema: public
-- Columns: ['patient_id', 'study_desc', 'study_date', 'series_instance_uid', 'series_desc', 'modality', 'batchnum', 'num_sops']
-- Args: ['project_name']
-- Tags: ['by_collection', 'find_series', 'public', 'series_search']
-- Description: Get Series in A Collection
-- 

select distinct
  i.patient_id,
  st.study_desc,
  st.study_date,
  s.series_instance_uid,
  s.series_desc, 
  s.modality,
  s.batchnum, count(distinct sop_instance_uid) as num_sops
from
  general_image i,
  study st,
  general_series s,
  trial_data_provenance tdp
where
  i.study_pk_id = st.study_pk_id and
  i.general_series_pk_id = s.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
group by
  patient_id, study_desc, study_date,
   series_instance_uid, series_desc, modality, batchnum
