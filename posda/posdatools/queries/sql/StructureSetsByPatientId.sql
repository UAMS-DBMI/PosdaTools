-- Name: StructureSetsByPatientId
-- Schema: posda_files
-- Columns: ['file_id', 'sop_instance_uid', 'activity_id', 'activity_timepoint_id', 'visibility']
-- Args: ['patient_id']
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Find all RTSTRUCT files with sop_instance_uid, activity and timepoint id, and visibility
-- By patient_id
-- 

select
  distinct file_id, sop_instance_uid, activity_id, activity_timepoint_id, visibility
from
  file_patient natural join file_series
  natural join file_sop_common natural join activity_timepoint
  natural join activity_timepoint_file natural left join ctp_file
where 
patient_id = ? and modality = 'RTSTRUCT'