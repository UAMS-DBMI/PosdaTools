-- Name: GetRowsColsSlicesAndVolsByNiftiFileId
-- Schema: posda_files
-- Columns: ['rows', 'cols', 'slices', 'vols']
-- Args: ['file_id']
-- Tags: ['nifti']
-- Description: Get row in file_nifti table from file_id
-- 

select
  dim1 as rows, dim2 as cols,
  dim3 as slices, dim4 as vols
from file_nifti
where file_id = ?
