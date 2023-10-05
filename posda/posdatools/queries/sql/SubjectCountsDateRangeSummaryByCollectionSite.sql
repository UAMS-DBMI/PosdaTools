-- Name: SubjectCountsDateRangeSummaryByCollectionSite
-- Schema: posda_files
-- Columns: ['patient_id', 'from', 'to', 'num_files', 'num_sops']
-- Args: ['collection', 'site']
-- Tags: ['counts', 'for_bill_counts']
-- Description: Counts query by Collection, Site
-- 

select 
  distinct patient_id,
  min(import_time) as from,
  max(import_time) as to,
  count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops
from 
  ctp_file natural join 
  file_sop_common natural join
  file_patient natural join 
  file_import natural join 
  import_event
where
  project_name = ? and site_name = ?
group by patient_id
order by patient_id