/*

	Add uid_root to submissions table, as part of the Defacing initiative.

*/
alter table submissions add column uid_root text default '1.3.6.1.4.1.14519.5.2.1';
