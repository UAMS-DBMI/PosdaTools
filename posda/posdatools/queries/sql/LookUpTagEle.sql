-- Name: LookUpTagEle
-- Schema: dicom_dd
-- Columns: ['tag', 'name', 'keyword', 'vr', 'vm', 'is_retired', 'comments']
-- Args: ['tag']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get tag from name or keyword

select
  tag, name, keyword, vr, vm, is_retired, comments
from 
  dicom_element
where
  tag = ?