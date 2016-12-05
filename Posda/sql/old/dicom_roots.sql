CREATE TABLE collection (
    collection_id integer NOT NULL,
    collection_code text
);

CREATE SEQUENCE collection_collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE collection_collection_id_seq OWNED BY collection.collection_id;

CREATE TABLE site (
    site_id integer NOT NULL,
    site_code text
);

CREATE SEQUENCE site_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE site_site_id_seq OWNED BY site.site_id;

CREATE TABLE submission (
    submission_id integer NOT NULL,
    collection_id integer NOT NULL,
    site_id integer NOT NULL,
    collection_name text,
    site_name text,
    body_part_entered text,
    patient_id_prefix text,
    access_type text,
    date_inc text,
    extra text
);


CREATE SEQUENCE submission_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE submission_submission_id_seq OWNED BY submission.submission_id;

CREATE TABLE submissionevent (
    submission_id integer NOT NULL,
    event_type text,
    occurance_date_time timestamp with time zone,
    reporting_user text,
    comment text
);


ALTER TABLE ONLY collection ALTER COLUMN collection_id SET DEFAULT nextval('collection_collection_id_seq'::regclass);

ALTER TABLE ONLY site ALTER COLUMN site_id SET DEFAULT nextval('site_site_id_seq'::regclass);

ALTER TABLE ONLY submission ALTER COLUMN submission_id SET DEFAULT nextval('submission_submission_id_seq'::regclass);

ALTER TABLE ONLY collection
    ADD CONSTRAINT collection_collection_code_key UNIQUE (collection_code);

ALTER TABLE ONLY site
    ADD CONSTRAINT site_site_code_key UNIQUE (site_code);
