-- Name: RecordElementDispositionChangeSimple
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['id', 'who', 'why', 'disp']
-- Tags: ['tag_usage', 'used_in_phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

insert into element_disposition_changed(
  element_seen_id,
  when_changed,
  who_changed,
  why_changed,
  new_disposition
) values (
  ?, now(), ?, ?, ?)