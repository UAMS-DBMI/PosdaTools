-- Name: InsertPublicDisposition
-- Schema: posda_phi
-- Columns: []
-- Args: ['element_signature_id', 'sop_class_uid', 'name', 'disposition']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Insert a public disposition

insert into public_disposition(
  element_signature_id, sop_class_uid, name, disposition
) values (
  ?, ?, ?, ?
)

