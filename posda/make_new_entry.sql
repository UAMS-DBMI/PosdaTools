-- -d posda_files

/*
This is a script to create a new (mostly fake) file that can be processed
*/

BEGIN;
	select nextval('file_file_id_seq');

	insert into file -- (digest, size, is_dicom_file, file_type, processing_priority, ready_to_process)
	values (lastval(), 'fake-' || lastval(),526982,null,'parsed dicom file', 1, true);

	insert into file_location
	values (
		lastval(),
		4,
		'2018-10-26/236672039783267694204755956183380793691/quasar1/LDCT-01-001/1.3.6.1.4.1.14519.5.2.1.3983.1600.175911262200889415475108687483/1.3.6.1.4.1.14519.5.2.1.3983.1600.128692777087971278951654848485/CT_1.3.6.1.4.1.14519.5.2.1.3983.1600.123423624873766335964873668008.dcm',
		null,
		null
	);
COMMIT;
