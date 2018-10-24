-- Name: SubjectCountsDateRangeSummaryByCollectionSiteDateRange
-- Schema: posda_files
-- Columns: ['patient_id', 'from', 'to', 'num_files', 'num_sops']
-- Args: ['collection', 'site', 'from', 'to']
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
  ctp_file natural join file_patient natural join file_import natural join import_event
  natural join file_sop_common
where
  project_name = ? and site_name = ? and import_time > ? and
  import_time < ?
group by patient_id
order by patient_id