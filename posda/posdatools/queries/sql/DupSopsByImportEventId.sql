-- Name: DupSopsByImportEventId
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'series_instance_uid', 'num_files']
-- Args: ['import_event_id']
-- Tags: ['duplicates', 'dup_sops', 'hide_dup_sops', 'check_dups']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select * from (
  select
    distinct
    sop_instance_uid, series_instance_uid, 
    count(distinct file_id) as num_files
  from
    file_sop_common natural join file_series
    natural left join ctp_file natural join file_import
  where
    visibility is null and import_event_id = ?
  group by sop_instance_uid, series_instance_uid
) as foo where num_files > 1

