-- Name: LikelyGoodSop
-- Schema: posda_files
-- Columns: ['file_id', 'instance_number']
-- Args: ['sop_instance_uid']
-- Tags: ['FileId']
-- Description: Get the file_id of a Sop, trying to guess one that is hopefully good
-- 

with likely_best as (
select
  max(file_id) as file_id
from 
  file_sop_common
where
  sop_instance_uid = ?
)

select file_id, instance_number
from likely_best
natural join file_sop_common
