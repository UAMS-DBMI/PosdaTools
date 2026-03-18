DROP TABLE IF EXISTS "public".collection_release_dataset;
DROP TABLE IF EXISTS "public".transfer_wp;
DROP TABLE IF EXISTS "public".transfer_idc;
DROP TABLE IF EXISTS "public".transfer_gc;
DROP TABLE IF EXISTS "public".transfer_dataset;
DROP TABLE IF EXISTS "public".transfer_aspera;
DROP TABLE IF EXISTS "public".dataset_release_file;
DROP TABLE IF EXISTS "public".dataset_release_draft_file;
DROP TABLE IF EXISTS "public".dataset_release_draft;
DROP TABLE IF EXISTS "public".dataset_release;
DROP TABLE IF EXISTS "public".dataset_destination;
DROP TABLE IF EXISTS "public".dataset;
DROP TABLE IF EXISTS "public".collection_release_transfer;
DROP TABLE IF EXISTS "public".wp_object_map;
DROP TABLE IF EXISTS "public".transfer_destination;
DROP TABLE IF EXISTS "public".dataset_license;
DROP TABLE IF EXISTS "public".collection_release;
DROP TABLE IF EXISTS "public".collection_related;
DROP TABLE IF EXISTS "public".collection;


CREATE  TABLE "public".collection ( 
	collection_id        integer  NOT NULL  ,
	collection_doi       text    ,
	collection_type      integer    ,
	collection_short_title text    ,
	collection_title     text    ,
	collection_name      text    ,
	active               boolean    ,
	when_created         timestamptz    ,
	who_updated          text    ,
	when_updated         timestamptz    ,
	who_created          text    ,
	CONSTRAINT pk_collection PRIMARY KEY ( collection_id ),
	CONSTRAINT unq_collection_doi UNIQUE ( collection_doi ) 
 ) ;

CREATE  TABLE "public".collection_related ( 
	collection_id        integer  NOT NULL  ,
	related_collection_id integer  NOT NULL  ,
	relation_type        text    ,
	CONSTRAINT pk_related_collection PRIMARY KEY ( collection_id, related_collection_id )
 ) ;

ALTER TABLE "public".collection_related ADD CONSTRAINT fk_related_collection_collection FOREIGN KEY ( collection_id ) REFERENCES "public".collection( collection_id )   ;

ALTER TABLE "public".collection_related ADD CONSTRAINT fk_related_collection_related_collection FOREIGN KEY ( related_collection_id ) REFERENCES "public".collection( collection_id )   ;

CREATE  TABLE "public".collection_release ( 
	collection_release_id integer  NOT NULL  ,
	collection_id        integer  NOT NULL  ,
	release_number       integer    ,
	release_date         timestamptz    ,
	release_notes        text    ,
	when_created         timestamptz    ,
	who_created          text    ,
	when_updated         timestamptz    ,
	who_updated          text    ,
	CONSTRAINT pk_collection_release PRIMARY KEY ( collection_release_id )
 ) ;

CREATE UNIQUE INDEX unq_collection_release_collection_release_num ON "public".collection_release ( collection_id, release_number ) ;

CREATE INDEX idx_collection_release_collection_id ON "public".collection_release  ( collection_id ) ;

ALTER TABLE "public".collection_release ADD CONSTRAINT fk_collection_release_collection FOREIGN KEY ( collection_id ) REFERENCES "public".collection( collection_id )   ;

CREATE  TABLE "public".dataset_license ( 
	license_id           integer  NOT NULL  ,
	license_label        text    ,
	license_url          text    ,
	CONSTRAINT pk_dataset_license PRIMARY KEY ( license_id )
 ) ;

CREATE  TABLE "public".transfer_destination ( 
	destination_id       integer  NOT NULL  ,
	name                 text    ,
	CONSTRAINT pk_destination PRIMARY KEY ( destination_id )
 ) ;

CREATE  TABLE "public".wp_object_map ( 
	map_id               integer  NOT NULL  ,
	posda_object_type    text    ,
	posda_object_id      integer    ,
	wp_object_type       text    ,
	wp_object_id         integer    ,
	wp_edit_url          text    ,
	wp_view_url          text    ,
	parent_wp_object_id  integer    ,
	when_synced          timestamptz    ,
	CONSTRAINT pk_wp_object_map PRIMARY KEY ( map_id ),
	CONSTRAINT unq_wp_object_map_posda_object UNIQUE ( posda_object_type, posda_object_id ) ,
	CONSTRAINT idx_wp_object_map_wp_object UNIQUE ( wp_object_type, wp_object_id ) 
 ) ;

COMMENT ON COLUMN "public".wp_object_map.posda_object_type IS 'collection, dataset, collection_release, dataset_release';

COMMENT ON COLUMN "public".wp_object_map.wp_object_type IS 'collection, analysis_result, download, version, version_download';

CREATE  TABLE "public".collection_release_transfer ( 
	collection_release_transfer_id integer  NOT NULL  ,
	collection_release_id integer  NOT NULL  ,
	destination_id       integer  NOT NULL  ,
	transfer_name        text    ,
	transfer_mode        text    ,
	transfer_status      text    ,
	transfer_notes       text    ,
	when_created         timestamptz    ,
	who_created          text    ,
	when_updated         timestamptz    ,
	who_updated          text    ,
	CONSTRAINT pk_collection_release_transfer PRIMARY KEY ( collection_release_transfer_id )
 ) ;

CREATE INDEX idx_collection_release_transfer_collection_release_id ON "public".collection_release_transfer  ( collection_release_id ) ;

COMMENT ON COLUMN "public".collection_release_transfer.transfer_mode IS 'optional, such as single_dataset, grouped_dicom, clinical_bundle';

COMMENT ON COLUMN "public".collection_release_transfer.transfer_status IS 'draft, queued, submitted, failed';

ALTER TABLE "public".collection_release_transfer ADD CONSTRAINT fk_collection_release_transfer_destination FOREIGN KEY ( destination_id ) REFERENCES "public".transfer_destination( destination_id ) ON DELETE RESTRICT  ;

ALTER TABLE "public".collection_release_transfer ADD CONSTRAINT fk_collection_release_transfer_collection_release FOREIGN KEY ( collection_release_id ) REFERENCES "public".collection_release( collection_release_id ) ON DELETE RESTRICT  ;

CREATE  TABLE "public".dataset ( 
	dataset_id           integer  NOT NULL  ,
	dataset_doi          text    ,
	collection_id        integer  NOT NULL  ,
	license_id           integer  NOT NULL  ,
	dataset_type         text    ,
	dataset_title        text    ,
	active               boolean    ,
	when_created         timestamptz    ,
	who_created          text    ,
	when_updated         timestamptz    ,
	who_updated          text    ,
	CONSTRAINT pk_dataset PRIMARY KEY ( dataset_id ),
	CONSTRAINT unq_dataset_doi UNIQUE ( dataset_doi ) 
 ) ;

ALTER TABLE "public".dataset ADD CONSTRAINT fk_dataset_collection FOREIGN KEY ( collection_id ) REFERENCES "public".collection( collection_id ) ON DELETE RESTRICT  ;

ALTER TABLE "public".dataset ADD CONSTRAINT fk_dataset_dataset_license FOREIGN KEY ( license_id ) REFERENCES "public".dataset_license( license_id )   ;

CREATE  TABLE "public".dataset_destination ( 
	dataset_id           integer  NOT NULL  ,
	destination_id       integer  NOT NULL  ,
	default_display      boolean  NOT NULL  ,
	default_transfer_mode text    ,
	CONSTRAINT pk_dataset_destination PRIMARY KEY ( dataset_id, destination_id )
 ) ;

CREATE UNIQUE INDEX unq_dataset_destination_one_default_display ON "public".dataset_destination ( dataset_id ) WHERE default_display = true;

ALTER TABLE "public".dataset_destination ADD CONSTRAINT fk_dataset_destination_destination FOREIGN KEY ( destination_id ) REFERENCES "public".transfer_destination( destination_id ) ON DELETE RESTRICT  ;

ALTER TABLE "public".dataset_destination ADD CONSTRAINT fk_dataset_destination_dataset FOREIGN KEY ( dataset_id ) REFERENCES "public".dataset( dataset_id ) ON DELETE CASCADE  ;

CREATE  TABLE "public".dataset_release ( 
	dataset_release_id   integer  NOT NULL  ,
	dataset_id           integer  NOT NULL  ,
	release_number       integer  NOT NULL  ,
	release_date         timestamptz  NOT NULL  ,
	release_notes        text    ,
	when_created         timestamptz    ,
	who_created          text    ,
	when_updated         timestamptz    ,
	who_updated          text    ,
	CONSTRAINT pk_dataset_release PRIMARY KEY ( dataset_release_id )
 ) ;

CREATE UNIQUE INDEX unq_dataset_release_dataset_release_num ON "public".dataset_release ( dataset_id, release_number ) ;

CREATE INDEX idx_dataset_release_dataset_id ON "public".dataset_release  ( dataset_id ) ;

ALTER TABLE "public".dataset_release ADD CONSTRAINT fk_dataset_release_dataset FOREIGN KEY ( dataset_id ) REFERENCES "public".dataset( dataset_id ) ON DELETE RESTRICT  ;

CREATE  TABLE "public".dataset_release_draft ( 
	dataset_release_draft_id integer  NOT NULL  ,
	dataset_id           integer  NOT NULL  ,
	cloned_from_release_id integer    ,
	draft_name           text    ,
	draft_status         text    ,
	draft_notes          text    ,
	when_created         timestamptz    ,
	who_created          text    ,
	when_updated         timestamptz    ,
	who_updated          text    ,
	CONSTRAINT pk_dataset_release_draft PRIMARY KEY ( dataset_release_draft_id )
 ) ;

CREATE INDEX idx_dataset_release_draft_dataset_id ON "public".dataset_release_draft  ( dataset_id ) ;

CREATE INDEX idx_dataset_release_draft_dataset_when_created ON "public".dataset_release_draft  ( dataset_id, when_created  DESC   ) ;

ALTER TABLE "public".dataset_release_draft ADD CONSTRAINT fk_dataset_release_draft_dataset FOREIGN KEY ( dataset_id ) REFERENCES "public".dataset( dataset_id ) ON DELETE CASCADE  ;

ALTER TABLE "public".dataset_release_draft ADD CONSTRAINT fk_dataset_release_draft_dataset_release FOREIGN KEY ( cloned_from_release_id ) REFERENCES "public".dataset_release( dataset_release_id )   ;

CREATE  TABLE "public".dataset_release_draft_file ( 
	dataset_release_draft_id integer  NOT NULL  ,
	file_id              integer  NOT NULL  ,
	CONSTRAINT pk_dataset_release_draft_file PRIMARY KEY ( dataset_release_draft_id, file_id )
 ) ;

CREATE INDEX idx_dataset_release_draft_file_file_id ON "public".dataset_release_draft_file  ( file_id ) ;

ALTER TABLE "public".dataset_release_draft_file ADD CONSTRAINT fk_dataset_release_draft_file_dataset_release_draft FOREIGN KEY ( dataset_release_draft_id ) REFERENCES "public".dataset_release_draft( dataset_release_draft_id ) ON DELETE CASCADE  ;

ALTER TABLE "public".dataset_release_draft_file ADD CONSTRAINT fk_dataset_release_draft_file_file FOREIGN KEY ( file_id ) REFERENCES "public"."file"( file_id ) ON DELETE RESTRICT  ;

CREATE  TABLE "public".dataset_release_file ( 
	dataset_release_id   integer  NOT NULL  ,
	file_id              integer  NOT NULL  ,
	CONSTRAINT pk_dataset_release_file PRIMARY KEY ( dataset_release_id, file_id )
 ) ;

CREATE INDEX idx_dataset_release_file_file_id ON "public".dataset_release_file  ( file_id ) ;

ALTER TABLE "public".dataset_release_file ADD CONSTRAINT fk_dataset_release_file_dataset_release FOREIGN KEY ( dataset_release_id ) REFERENCES "public".dataset_release( dataset_release_id ) ON DELETE CASCADE  ;

ALTER TABLE "public".dataset_release_file ADD CONSTRAINT fk_dataset_release_file_file FOREIGN KEY ( file_id ) REFERENCES "public"."file"( file_id ) ON DELETE RESTRICT  ;

CREATE  TABLE "public".transfer_aspera ( 
	collection_release_transfer_id integer  NOT NULL  ,
	published            boolean    ,
	"public"             boolean    ,
	faspex_url           text    ,
	CONSTRAINT pk_release_aspera PRIMARY KEY ( collection_release_transfer_id )
 ) ;

ALTER TABLE "public".transfer_aspera ADD CONSTRAINT fk_transfer_aspera_collection_release_transfer FOREIGN KEY ( collection_release_transfer_id ) REFERENCES "public".collection_release_transfer( collection_release_transfer_id ) ON DELETE CASCADE  ;

CREATE  TABLE "public".transfer_dataset ( 
	collection_release_transfer_id integer  NOT NULL  ,
	dataset_release_id   integer  NOT NULL  ,
	retriever_manifest_file_id integer    ,
	CONSTRAINT pk_collection_release_transfer_dataset_release PRIMARY KEY ( collection_release_transfer_id, dataset_release_id )
 ) ;

CREATE INDEX idx_transfer_dataset_dataset_release_id ON "public".transfer_dataset  ( dataset_release_id ) ;

ALTER TABLE "public".transfer_dataset ADD CONSTRAINT fk_collection_release_transfer_dataset_release_collection_release_transfer FOREIGN KEY ( collection_release_transfer_id ) REFERENCES "public".collection_release_transfer( collection_release_transfer_id ) ON DELETE CASCADE  ;

ALTER TABLE "public".transfer_dataset ADD CONSTRAINT fk_collection_release_transfer_dataset_release_dataset_release FOREIGN KEY ( dataset_release_id ) REFERENCES "public".dataset_release( dataset_release_id ) ON DELETE RESTRICT  ;

ALTER TABLE "public".transfer_dataset ADD CONSTRAINT fk_collection_release_transfer_dataset_release_file FOREIGN KEY ( retriever_manifest_file_id ) REFERENCES "public"."file"( file_id ) ON DELETE RESTRICT  ;

CREATE  TABLE "public".transfer_gc ( 
	collection_release_transfer_id integer  NOT NULL  ,
	published            boolean    ,
	"public"             boolean    ,
	CONSTRAINT pk_release_gc PRIMARY KEY ( collection_release_transfer_id )
 ) ;

ALTER TABLE "public".transfer_gc ADD CONSTRAINT fk_transfer_gc_collection_release_transfer FOREIGN KEY ( collection_release_transfer_id ) REFERENCES "public".collection_release_transfer( collection_release_transfer_id ) ON DELETE CASCADE  ;

CREATE  TABLE "public".transfer_idc ( 
	collection_release_transfer_id integer  NOT NULL  ,
	gcs_url              text    ,
	dataset_manifest_file_id integer    ,
	collection_manifest_file_id integer    ,
	clinical_manifest_file_id integer    ,
	published            boolean    ,
	"public"             boolean    ,
	CONSTRAINT pk_release_idc PRIMARY KEY ( collection_release_transfer_id )
 ) ;

ALTER TABLE "public".transfer_idc ADD CONSTRAINT fk_release_idc_file_dataset_manifest FOREIGN KEY ( dataset_manifest_file_id ) REFERENCES "public"."file"( file_id ) ON DELETE RESTRICT  ;

ALTER TABLE "public".transfer_idc ADD CONSTRAINT fk_release_idc_file_collection_manifest FOREIGN KEY ( collection_manifest_file_id ) REFERENCES "public"."file"( file_id ) ON DELETE RESTRICT  ;

ALTER TABLE "public".transfer_idc ADD CONSTRAINT fk_release_idc_file_download_manifest FOREIGN KEY ( clinical_manifest_file_id ) REFERENCES "public"."file"( file_id ) ON DELETE RESTRICT  ;

ALTER TABLE "public".transfer_idc ADD CONSTRAINT fk_transfer_idc_collection_release_transfer FOREIGN KEY ( collection_release_transfer_id ) REFERENCES "public".collection_release_transfer( collection_release_transfer_id ) ON DELETE CASCADE  ;

CREATE  TABLE "public".transfer_wp ( 
	collection_release_transfer_id integer  NOT NULL  ,
	wp_media_file_id     integer    ,
	published            boolean    ,
	"public"             boolean    ,
	CONSTRAINT pk_release_wp PRIMARY KEY ( collection_release_transfer_id )
 ) ;

ALTER TABLE "public".transfer_wp ADD CONSTRAINT fk_transfer_wp_collection_release_transfer FOREIGN KEY ( collection_release_transfer_id ) REFERENCES "public".collection_release_transfer( collection_release_transfer_id ) ON DELETE CASCADE  ;

CREATE  TABLE "public".collection_release_dataset ( 
	collection_release_id integer  NOT NULL  ,
	dataset_release_id   integer  NOT NULL  ,
	CONSTRAINT pk_collection_release_dataset PRIMARY KEY ( collection_release_id, dataset_release_id )
 ) ;

CREATE INDEX idx_collection_release_dataset_dataset_release_id ON "public".collection_release_dataset  ( dataset_release_id ) ;

ALTER TABLE "public".collection_release_dataset ADD CONSTRAINT fk_collection_release_dataset_collection_release FOREIGN KEY ( collection_release_id ) REFERENCES "public".collection_release( collection_release_id ) ON DELETE CASCADE  ;

ALTER TABLE "public".collection_release_dataset ADD CONSTRAINT fk_collection_release_dataset_dataset_release FOREIGN KEY ( dataset_release_id ) REFERENCES "public".dataset_release( dataset_release_id ) ON DELETE RESTRICT  ;

