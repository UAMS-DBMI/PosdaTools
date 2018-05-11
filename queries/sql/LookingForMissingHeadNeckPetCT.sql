-- Name: LookingForMissingHeadNeckPetCT
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'visibility', 'num_files', 'num_uploads', 'num_sops', 'last_load', 'earliest_load']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'bills_ad_hoc_scripts', 'for_tracy']
-- Description: Add a filter to a tab

select distinct series_instance_uid, visibility, count(distinct file_id) as num_files, count(distinct import_event_id) as num_uploads, count(distinct sop_instance_uid) as num_sops
, max(import_time) as last_load, min(import_time) as earliest_load from file_series join ctp_file using(file_id) join file_sop_common using(file_id) join file_import using (file_id) join import_event using(import_event_id)
where project_name = 'Head-Neck-PET-CT' and import_time > '2018-04-01' group by series_instance_uid, visibility;