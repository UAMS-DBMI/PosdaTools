-- Name: RoisInStructureSetByFileId
-- Schema: posda_files
-- Columns: ['file_id', 'roi_num', 'roi_name', 'roi_interpreted_type']
-- Args: ['file_id']
-- Tags: ['Test Case based on Soft-tissue-Sarcoma']
-- Description: Find All of the Structure Sets In Soft-tissue-Sarcoma

select file_id, roi_num, roi_name, roi_interpreted_type
from roi natural join file_structure_set where file_id = ?