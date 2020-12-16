-- Name: ForInsertingDupSopsEquivalenceClasses
-- Schema: posda_files
-- Columns: []
-- Args: ['equiv_class', 'subprocess_invocation_id', 'sop_index']
-- Tags: ['dup_sops']
-- Description: A query for adding equiv_class for Dup SOP comparisons in a timepoint
-- 

update dup_sops_comparison
  set equiv_class = ?
where
  subprocess_invocation_id = ? and
  sop_index = ?