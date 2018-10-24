-- Name: CreateActivity
-- Schema: posda_queries
-- Columns: []
-- Args: ['description', 'user']
-- Tags: ['AllCollections', 'queries', 'activities']
-- Description: Get a list of available queries

insert into activity(brief_description, when_created, who_created) values (
?, now(), ?);