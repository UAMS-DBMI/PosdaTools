-- Name: GetFilesInStudyWithNullStudyDesc
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['study_instance_uid']
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get files with null study description by study
--

select
  file_id
from file_study natural join ctp_file
where study_instance_uid = ?