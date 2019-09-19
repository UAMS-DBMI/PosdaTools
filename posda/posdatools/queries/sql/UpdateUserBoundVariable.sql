-- Name: UpdateUserBoundVariable
-- Schema: posda_queries
-- Columns: ['user', 'variable', 'binding']
-- Args: ['value', 'user', 'variable_name']
-- Tags: ['AllCollections', 'queries', 'activity_support', 'variabler_binding']
-- Description: Get list of variables with bindings for a user

update user_variable_binding set
  bound_value = ?
where
  binding_user = ?
  and bound_variable_name = ?
 