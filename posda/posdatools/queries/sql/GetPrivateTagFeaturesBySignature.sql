-- Name: GetPrivateTagFeaturesBySignature
-- Schema: posda_private_tag
-- Columns: ['name', 'vr', 'disposition']
-- Args: ['signature']
-- Tags: ['DispositionReport', 'NotInteractive']
-- Description: Get the relevant features of a private tag by signature
-- Used in DispositionReport.pl - not for interactive use
-- 

select
  pt_consensus_name as name,
  pt_consensus_vr as vr,
  pt_consensus_disposition as disposition
from pt
where pt_signature = ?
