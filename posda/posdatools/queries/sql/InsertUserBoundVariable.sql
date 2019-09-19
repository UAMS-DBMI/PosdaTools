-- Name: InsertUserBoundVariable
-- Schema: posda_queries
-- Columns: ['user', 'variable', 'binding']
-- Args: ['user', 'variable_name', 'value']
-- Tags: ['AllCollections', 'queries', 'activity_support', 'variabler_binding']
-- Description: Get list of variables with bindings for a user

insert into user_variable_binding(
  binding_user, bound_variable_name, bound_value
) values (
  ?, ?, ?
)
 