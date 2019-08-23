-- Name: InsertUserBoundVariable
-- Schema: posda_queries
-- Columns: []
-- Args: ['user', 'variable_name', 'value']
-- Tags: ['AllCollections', 'queries', 'activity_support', 'variabler_binding']
-- Description: Insert a bound variable
--

insert into user_variable_binding(
  binding_user, bound_variable_name, bound_value
) values (
  ?, ?, ?
)
 