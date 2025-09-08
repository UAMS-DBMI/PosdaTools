-- pathology_image_desc definition

CREATE TABLE public.file_seg_image_linkage (
	file_id int4 NOT NULL,
	seg_id int4 NOT NULL,
	linked_sop_instance_uid text NOT NULL,
	linked_sop_class_uid text NOT NULL
);
CREATE INDEX file_seg_image_linkage_file_id ON public.file_seg_image_linkage USING btree (file_id);
CREATE INDEX file_seg_image_linkage_linked_sop_idx ON public.file_seg_image_linkage USING btree (linked_sop_instance_uid);

CREATE UNIQUE INDEX unique_file_seg_idx
ON public.file_seg_image_linkage (file_id, seg_id);
