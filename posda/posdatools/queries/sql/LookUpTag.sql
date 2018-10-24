-- Name: LookUpTag
-- Schema: dicom_dd
-- Columns: ['tag', 'name', 'keyword', 'vr', 'vm', 'is_retired', 'comments']
-- Args: ['name', 'keyword']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get tag from name or keyword

select
  tag, name, keyword, vr, vm, is_retired, comments
from 
  dicom_element
where
  name = ? or
  keyword = ?