-- Name: ValueSeenByElementSeen
-- Schema: posda_phi_simple
-- Columns: ['value']
-- Args: ['element_sig_pattern']
-- Tags: ['tag_usage', 'simple_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

select value from value_seen where value_seen_id in (
  select  value_seen_id
  from element_value_occurance
where
    element_seen_id in (
      select element_seen_id
      from
        element_seen
      where
        element_sig_pattern = ?
    )
)