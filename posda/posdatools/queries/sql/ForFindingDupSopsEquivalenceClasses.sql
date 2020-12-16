-- Name: ForFindingDupSopsEquivalenceClasses
-- Schema: posda_files
-- Columns: ['equiv_class', 'sop_index', 'cmp_index', 'from_file_id', 'to_file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['dup_sops']
-- Description: A query for creating SOP comparison equivalence classes for dup sops in a timepoint
-- 

select 
  equiv_class, sop_index, cmp_index, from_file_id, to_file_id
from dup_sops_comparison
where subprocess_invocation_id = ?
order by equiv_class, sop_index, cmp_index
