-- Name: SummaryOfKnownNiftiFiles
-- Schema: posda_files
-- Columns: ['activity_id', 'activity_timepoint_id', 'file_id', 'file_type', 'size', 'bitpix', 'datatype', 'rows', 'cols', 'slices', 'vols']
-- Args: []
-- Tags: ['Nifti']
-- Description: Get rendered slices for nifti file
-- 

select 
  activity_id, activity_timepoint_id, file_id, file_type,
  size, bitpix, datatype, dim1 as rows, dim2 as cols, dim3 as slices, dim4 as vols
from
  file natural join file_nifti natural join 
  activity_timepoint_file natural join activity_timepoint
order by
  activity_id, activity_timepoint_id, file_id