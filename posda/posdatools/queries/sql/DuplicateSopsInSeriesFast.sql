-- Name: DuplicateSopsInSeriesFast
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'num_sops']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'dup_sops', 'ACRIN-FMISO-Brain Duplicate Elimination']
-- Description: List of Actual duplicate SOPs (i.e. different files, same SOP)
-- in a series
-- 

select * from (
  select
    distinct sop_instance_uid, count(*) as num_sops
  from file_sop_common where file_id in (
    select distinct file_id
    from file_series natural join ctp_file 
    where series_instance_uid = ? and visibility is null
  ) group by sop_instance_uid
) as foo where num_sops > 1
