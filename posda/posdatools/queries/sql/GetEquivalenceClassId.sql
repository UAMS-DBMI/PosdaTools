-- Name: GetEquivalenceClassId
-- Schema: posda_files
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'equivalence_classes']
-- Description: Get current value of EquivalenceClassId Sequence
-- 

select currval('image_equivalence_class_image_equivalence_class_id_seq') as id