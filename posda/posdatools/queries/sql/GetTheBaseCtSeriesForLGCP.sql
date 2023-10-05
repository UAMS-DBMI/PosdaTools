-- Name: GetTheBaseCtSeriesForLGCP
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'num_files']
-- Args: []
-- Tags: ['Curation of Lung-Fused-CT-Pathology']
-- Description: Get the list of series which serve as a basis for fixing SOP instance UID's in Lung-Fused-CT-Pathology

select
  patient_id, series_instance_uid, count(distinct file_id) as num_files
from 
  file_series natural join file_patient natural join ctp_file
where series_instance_uid in (
 '1.3.6.1.4.1.14519.5.2.1.5826.1402.983508919695337135620677418685',
 '1.3.6.1.4.1.14519.5.2.1.5826.1402.170224599052836213374813274674',
 '1.3.6.1.4.1.14519.5.2.1.5826.1402.124599233476878991434251967746',
 '1.3.6.1.4.1.14519.5.2.1.5826.1402.122505729234908340647352438768',
 '1.3.6.1.4.1.14519.5.2.1.5826.1402.246380096059125471917249164954',
 '1.3.6.1.4.1.14519.5.2.1.5826.1402.199118463594923165410399883739')
group by patient_id, series_instance_uid