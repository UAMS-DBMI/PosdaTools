-- Name: DoAnyPrivateTagsNeedDispositions
-- Schema: posda_phi_simple
-- Columns: ['element_seen_id', 'element_sig_pattern', 'vr', 'tag_name']
-- Args: []
-- Tags: ['PrivateDispositions']
-- Description: List of private tags needing disposition
-- 

select 
  distinct element_seen_id, element_sig_pattern, vr, tag_name
from 
  element_seen
where
  is_private and private_disposition is null
