-- Name: GetPublicTagDispositionBySignature
-- Schema: posda_public_tag
-- Columns: ['disposition']
-- Args: ['signature']
-- Tags: ['DispositionReport', 'NotInteractive']
-- Description: Get the disposition of a public tag by signature
-- Used in DispositionReport.pl - not for interactive use
-- 

select
  disposition
from public_tag_disposition
where tag_name = ?
