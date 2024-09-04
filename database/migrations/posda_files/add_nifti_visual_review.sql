--
-- Name: add_nifti_visual_review script
--

-- drop table nifti_visual_review_instance;
-- drop table nifti_visual_review_files;
-- drop table nifti_visual_review_status;


alter table activity add primary key (activity_id);


create table if not exists nifti_visual_review_instance (
	nifti_visual_review_instance_id serial not null primary key,
	activity_id int4 not null,
	scheduler text not null,
	scheduled timestamp,
	foreign key (activity_id) references activity(activity_id)
);

create table if not exists nifti_visual_review_files (
	nifti_visual_review_instance_id int not null,
	nifti_file_id int not null unique,
	nifti_file_name text,
    primary key (nifti_visual_review_instance_id, nifti_file_id),
    foreign key (nifti_visual_review_instance_id) references nifti_visual_review_instance(nifti_visual_review_instance_id),
	foreign key (nifti_file_id) references file_nifti(file_id)
);

create table if not exists nifti_visual_review_status (
	nifti_file_id int4 not null primary key,
	review_status text,
	reviewing_user text,
	review_time timestamp,
    foreign key (nifti_file_id) references file_nifti(file_id)
);
