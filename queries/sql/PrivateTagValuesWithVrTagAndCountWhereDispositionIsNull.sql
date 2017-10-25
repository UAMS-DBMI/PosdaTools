-- Name: PrivateTagValuesWithVrTagAndCountWhereDispositionIsNull
-- Schema: posda_phi
-- Columns: ['vr', 'value', 'element_signature', 'private_disposition', 'count']
-- Args: []
-- Tags: ['DispositionReport', 'NotInteractive']
-- Description: Get the disposition of a public tag by signature
-- Used in DispositionReport.pl - not for interactive use
-- 

select
  distinct vr , value, element_signature, private_disposition, count(*) as num_files
from
  element_signature natural left join scan_element natural left join series_scan natural left join seen_value
where
  is_private and private_disposition is null
group by
  vr, value, element_signature, private_disposition
