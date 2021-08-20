alter table file_nifti_defacing 
add column subprocess_invocation_id integer references subprocess_invocation (subprocess_invocation_id),
add column error_code text;
