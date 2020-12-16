-- Name: InsertDupSopsComparison
-- Schema: posda_files
-- Columns: []
-- Args: ['subprocess_invocation_id', 'sop_index', 'cmp_index', 'from_file_id', 'to_file_id', 'long_report_file_id']
-- Tags: ['dup_sops']
-- Description: Insert a row into dup_sops_comparison
-- 

insert into dup_sops_comparison(
  subprocess_invocation_id,
  sop_index,
  cmp_index,
  from_file_id,
  to_file_id,
  long_report_file_id
) values (
  ?, ?, ?,
  ?, ?, ?
)