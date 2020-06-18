-- Name: GetListOfAllTagsEverSeen
-- Schema: posda_phi_simple
-- Columns: ['element_sig_pattern', 'vr', 'tag_name', 'private_disposition']
-- Args: []
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get List of all tags ever seen in Posda PHI scans, with VR and name
--

select
  element_sig_pattern,
  vr,
  tag_name,
  private_disposition
from
  element_seen
order by element_sig_pattern, vr