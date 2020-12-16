-- Name: ForMakingDupSopsEquivalenceClasses
-- Schema: posda_files
-- Columns: ['sop_index', 'cmp_index', 'long_report_file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['dup_sops']
-- Description: A query for creating SOP comparison equivalence classes for dup sops in a timepoint
-- 

select sop_index, cmp_index, long_report_file_id from dup_sops_comparison
where subprocess_invocation_id = ?
order by sop_index, cmp_index