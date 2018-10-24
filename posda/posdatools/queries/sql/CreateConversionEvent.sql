-- Name: CreateConversionEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['who_invoked_conversion', 'conversion_program']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

insert into conversion_event(
  time_of_conversion, who_invoked_conversion, conversion_program
) values (
  now(), ?, ?
)
