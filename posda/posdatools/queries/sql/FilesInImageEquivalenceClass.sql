-- Name: FilesInImageEquivalenceClass
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['image_equivalence_class_id']
-- Tags: ['activity_timepoint', 'series_report']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select file_id from image_equivalence_class_input_image
where image_equivalence_class_id = ?
