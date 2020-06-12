-- Name: GetFileDispositionsRow
-- Schema: posda_files
-- Columns: ['export_file_dispositions_params_id']
-- Args: ['offset_days', 'uid_root', 'only_modify_group_13']
-- Tags: ['export_event']
-- Description: See if export_file_dispositions_row exists with desired values and return its id
--

select
  export_file_dispositions_params_id
from
  export_file_dispositions_params
where
  offset_days = ? and uid_root = ? and only_modify_group_13 = ?