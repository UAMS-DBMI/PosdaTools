-- This file is for default values that should be set for a new install,
-- but are not part of the UI configuration or queries themselves.

COPY user_inbox (user_inbox_id, user_name, user_email_addr) FROM stdin;
1	admin	admin@admin.bogus
\.

SELECT pg_catalog.setval('user_inbox_user_inbox_id_seq', 1, true);
