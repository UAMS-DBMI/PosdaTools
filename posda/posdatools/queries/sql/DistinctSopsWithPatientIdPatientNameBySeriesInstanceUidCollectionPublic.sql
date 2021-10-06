-- Name: DistinctSopsWithPatientIdPatientNameBySeriesInstanceUidCollectionPublic
-- Schema: public
-- Columns: ['patient_id', 'study_desc', 'study_date', 'sop_instance_uid', 'series_desc', 'modality', 'batchnum']
-- Args: ['project_name', 'series_instance_uid']
-- Tags: ['by_collection', 'find_series', 'public', 'series_search']
-- Description: Get Series in A Collection
-- 

select distinct
  i.patient_id,
  st.study_desc,
  st.study_date,
  i.sop_instance_uid,
  s.series_desc, 
  s.modality,
  s.batchnum
from
  general_image i,
  study st,
  general_series s,
  trial_data_provenance tdp
where
  i.study_pk_id = st.study_pk_id and
  i.general_series_pk_id = s.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and s.series_instance_uid = ?
