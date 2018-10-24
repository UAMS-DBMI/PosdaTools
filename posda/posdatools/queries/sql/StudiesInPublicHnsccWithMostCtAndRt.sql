-- Name: StudiesInPublicHnsccWithMostCtAndRt
-- Schema: public
-- Columns: ['patient_id', 'study_instance_uid', 'num_cts']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Name says it all

select
 patient_id, study_instance_uid, num_images as num_cts
from (
  select 
    distinct i.patient_id, t.study_instance_uid,
    s.series_instance_uid, 
    t.study_desc, series_desc, count(*) as num_images
  from 
    general_image i, trial_data_provenance tdp, general_series s, study t
  where
    i.study_pk_id = t.study_pk_id and i.trial_dp_pk_id = tdp.trial_dp_pk_id and 
    i.general_series_pk_id = s.general_series_pk_id and tdp.project = 'HNSCC' and
    modality = 'CT' and t.study_desc = 'RT SIMULATION' 
  group by series_instance_uid
) as foo order by num_images desc