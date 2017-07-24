-- Name: CreateEquivalenceInputClass
-- Schema: posda_files
-- Columns: []
-- Args: ['image_equivlence_class_id', 'file_id']
-- Tags: ['consistency', 'equivalence_classes', 'NotInteractive']
-- Description: For building series equivalence classes

insert into image_equivalence_class_input_image(
  image_equivalence_class_id,  file_id
) values (
  ?, ?
)
