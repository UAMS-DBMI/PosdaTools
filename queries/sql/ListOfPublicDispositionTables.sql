-- Name: ListOfPublicDispositionTables
-- Schema: posda_phi
-- Columns: ['sop_class_uid', 'name', 'count']
-- Args: []
-- Tags: ['NotInteractive', 'ElementDisposition']
-- Description: Get List of Public Disposition Tables

select
  distinct sop_class_uid, name, count(*)
from
  public_disposition
group by
  sop_class_uid, name
order by
  sop_class_uid, name