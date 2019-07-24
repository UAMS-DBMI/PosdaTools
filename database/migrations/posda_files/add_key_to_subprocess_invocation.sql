/*
	Issue: PT-731

	It was discovered that subprocess_invocation table has no primary key
	while working on this issue.
*/

alter table subprocess_invocation add primary key (subprocess_invocation_id);
