-- Name: DistinctSeriesByPatient
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'patient_id', 'num_files', 'num_sops']
-- Args: ['patient_id']
-- Tags: ['find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi', 'dciodvfy', 'series_selection', 'ctp_details']
-- Description: Get Series in for a patient
-- 

select distinct series_instance_uid, patient_id, count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops
from
  file_series natural join file_patient natural join file_sop_common
  natural left join ctp_file
where
  patient_id = ? and visibility is null
group by series_instance_uid, patient_id

