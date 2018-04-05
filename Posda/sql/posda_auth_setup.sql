COPY apps (app_id, app_name) FROM stdin;
1	UserAdmin
2	PosdaCuration
3	PhiFixer
4	ReviewPhi
5	SubmissionSender
6	CountGetter
7	FileDist
8	DicomProxy
9	DicomProxyAnalysis
10	DbIf
11	SeriesProjection
12	NewItcTools
\.

SELECT pg_catalog.setval('apps_app_id_seq', 12, true);

COPY permissions (permission_id, app_id, permission_name) FROM stdin;
1	1	launch
2	2	launch
3	3	launch
4	4	launch
5	5	launch
6	6	launch
7	7	launch
8	8	launch
9	9	launch
10	10	launch
11	1	debug
12	2	debug
13	3	debug
14	4	debug
15	5	debug
16	6	debug
17	7	debug
18	8	debug
19	9	debug
20	10	debug
22	11	launch
23	11	debug
38	10	superuser
44	12	debug
45	12	launch
46	10	curator
47	10	workflow_1
48	10	legacy_bbennett
\.

SELECT pg_catalog.setval('permissions_permission_id_seq', 49, true);

COPY users (user_id, user_name, full_name, password) FROM stdin;
1	admin	Default Admin Account	aJE5lY8D,2wUueoiymAn8HsfbdAp0kPfTiODV7kpeNUttYTgQGbE
\.

SELECT pg_catalog.setval('users_user_id_seq', 2, true);

COPY user_permissions (user_id, permission_id) FROM stdin;
1	20
1	1
1	11
1	10
1	22
1	23
1	48
1	47
1	46
\.
