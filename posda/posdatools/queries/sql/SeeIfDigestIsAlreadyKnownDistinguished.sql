-- Name: SeeIfDigestIsAlreadyKnownDistinguished
-- Schema: posda_files
-- Columns: ['count']
-- Args: ['pixel_digest']
-- Tags: ['meta', 'test', 'hello']
-- Description: Find Duplicated Pixel Digest

select count(*) from distinguished_pixel_digests where pixel_digest = ?