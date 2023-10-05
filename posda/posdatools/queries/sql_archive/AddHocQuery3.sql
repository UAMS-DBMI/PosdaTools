-- Name: AddHocQuery3
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'body_part_examined', 'num_files']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'bills_ad_hoc_scripts']
-- Description: Add a filter to a tab

select distinct series_instance_uid, body_part_examined, count(distinct file_id) as num_files from file_series where file_id in (
select distinct file_id from import_event natural join file_import natural left join ctp_file where import_event_id in (9535631, 9543872, 9535664)) group by series_instance_uid, body_part_examined
