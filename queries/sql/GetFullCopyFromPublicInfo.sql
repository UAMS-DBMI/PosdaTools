-- Name: GetFullCopyFromPublicInfo
-- Schema: posda_files
-- Columns: ['id', 'who', 'why', 'num_files', 'num_waiting', 'num_copied']
-- Args: ['copy_from_public_id']
-- Tags: ['bills_test', 'copy_from_public', 'public_posda_consistency']
-- Description: Add a filter to a tab

select 
  copy_from_public_id as id, who, why, 
  num_file_rows_populated as num_files, 
  (
    select count(*) as num_waiting 
    from file_copy_from_public fc 
    where fc.copy_from_public_id = copy_from_public.copy_from_public_id and 
       not exists
       (
         select file_id from ctp_file where ctp_file.file_id = fc.replace_file_id and visibility is not null
       )
  ),
  (
    select count(*) as num_copied
    from file_copy_from_public fc
    where fc.copy_from_public_id = copy_from_public.copy_from_public_id and
    fc.inserted_file_id is not null
  )
from
  copy_from_public 
where copy_from_public_id = ?