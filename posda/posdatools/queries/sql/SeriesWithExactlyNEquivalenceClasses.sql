-- Name: SeriesWithExactlyNEquivalenceClasses
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'count']
-- Args: ['count']
-- Tags: ['find_series', 'equivalence_classes', 'consistency']
-- Description: Find Series with exactly n equivalence classes

select series_instance_uid, count from (
select distinct series_instance_uid, count(*) from image_equivalence_class group by series_instance_uid) as foo where count = ?