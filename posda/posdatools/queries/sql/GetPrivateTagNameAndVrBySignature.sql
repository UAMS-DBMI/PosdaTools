-- Name: GetPrivateTagNameAndVrBySignature
-- Schema: posda_private_tag
-- Columns: ['name', 'vr']
-- Args: ['signature']
-- Tags: ['DispositionReport', 'NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Get the relevant features of a private tag by signature
-- Used in DispositionReport.pl - not for interactive use
-- 

select
  pt_consensus_name as name,
  pt_consensus_vr as vr
from pt
where pt_signature = ?
