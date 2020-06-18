-- Name: InsertFileDispositionsRow
-- Schema: posda_files
-- Columns: []
-- Args: ['offset_days', 'uid_root', 'only_modify_group_13']
-- Tags: ['export_event']
-- Description:  Insert export_file_dispositions_row exists
--

insert into export_file_dispositions_params (
  offset_days, uid_root, only_modify_group_13
) values (
  ?, ?, ?
)