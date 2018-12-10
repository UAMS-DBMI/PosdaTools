-- Name: ConflictingDispositions
-- Schema: posda_phi_simple
-- Columns: ['element_sig_pattern', 'vr', 'tag_name', 'private_disposition']
-- Args: []
-- Tags: ['tag_usage', 'simple_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

select
  element_sig_pattern, vr, tag_name, private_disposition
 from 
  element_seen 
where element_sig_pattern in (
  select 
    distinct element_sig_pattern 
  from (
    select 
      distinct element_sig_pattern, count(distinct private_disposition) 
    from element_seen 
    group by element_sig_pattern 
    order by count desc
  ) as foo 
  where count > 1
) order by element_sig_pattern;