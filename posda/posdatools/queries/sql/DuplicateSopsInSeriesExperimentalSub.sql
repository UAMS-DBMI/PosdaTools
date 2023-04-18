-- Name: DuplicateSopsInSeriesExperimentalSub
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'first_f', 'last_f']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'dup_sops', 'ACRIN-FMISO-Brain Duplicate Elimination']
-- Description: List of Actual duplicate SOPs (i.e. different files, same SOP)
-- in a series
-- 

select 
    distinct sop_instance_uid, min(file_id) as first_f, max(file_id) as last_f
  from
     file_series natural join file_sop_common natural join ctp_file
  where
     series_instance_uid = ?
  group by sop_instance_uid