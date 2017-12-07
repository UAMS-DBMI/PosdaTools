SET search_path = public, pg_catalog;


CREATE TABLE apps (
    app_id integer NOT NULL,
    app_name text NOT NULL
);

CREATE SEQUENCE apps_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE apps_app_id_seq OWNED BY apps.app_id;

CREATE TABLE permissions (
    permission_id integer NOT NULL,
    app_id integer,
    permission_name text NOT NULL
);

CREATE SEQUENCE permissions_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE permissions_permission_id_seq OWNED BY permissions.permission_id;

CREATE TABLE user_permissions (
    user_id integer,
    permission_id integer
);

CREATE TABLE users (
    user_id integer NOT NULL,
    user_name text NOT NULL,
    full_name text NOT NULL,
    password text
);

CREATE SEQUENCE users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE users_user_id_seq OWNED BY users.user_id;

ALTER TABLE ONLY apps ALTER COLUMN app_id SET DEFAULT nextval('apps_app_id_seq'::regclass);

ALTER TABLE ONLY permissions ALTER COLUMN permission_id SET DEFAULT nextval('permissions_permission_id_seq'::regclass);

ALTER TABLE ONLY users ALTER COLUMN user_id SET DEFAULT nextval('users_user_id_seq'::regclass);

SET search_path = public, pg_catalog;


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
40	10	count_check
22	11	launch
23	11	debug
38	10	superuser
41	10	curation
42	10	scripting
43	10	legacy
44	12	debug
45	12	launch
46	10	db_admin
\.

SELECT pg_catalog.setval('permissions_permission_id_seq', 46, true);

COPY user_permissions (user_id, permission_id) FROM stdin;
1	41
1	20
1	40
1	1
1	11
1	42
1	10
1	22
1	23
\.

COPY users (user_id, user_name, full_name, password) FROM stdin;
1	admin	Default Admin Account	aJE5lY8D,2wUueoiymAn8HsfbdAp0kPfTiODV7kpeNUttYTgQGbE
\.

SELECT pg_catalog.setval('users_user_id_seq', 11, true);

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (app_id);

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (permission_id);

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY users
    ADD CONSTRAINT users_user_name_key UNIQUE (user_name);

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps(app_id) ON DELETE CASCADE;

ALTER TABLE ONLY user_permissions
    ADD CONSTRAINT user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE;

ALTER TABLE ONLY user_permissions
    ADD CONSTRAINT user_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
