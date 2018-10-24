-- Name: ClearPublicDispositions
-- Schema: posda_phi
-- Columns: []
-- Args: ['sop_class_uid', 'name']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Clear all public dispositions for a give sop_class and name

delete from public_disposition where
  sop_class_uid = ? and name = ?

