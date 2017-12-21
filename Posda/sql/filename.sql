create or replace function filename(input_file_id integer)
returns text as $$ 
declare 
	result text;
begin
	select root_path || '/' || rel_path into result
	from file
	natural join file_location
	natural left join file_storage_root
	where file.file_id = input_file_id;
	return result;
end;
$$ language plpgsql;
