--
-- 
-- Copyright 2016, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 
--
CREATE Table Collection{
  collection_id serial,
  root_code integer unique,
  collection_name text,
  date_inc integer
}
CREATE Table Site{
  site_id serial,
  site_code integer unique,
  site_name text
}
CREATE Table Submission (
  submission_id serial,
  collection_id integer not null,
  site_id integer not null,
  body_part_entered text,
  access_type text
);
CREATE Table SubmissionEvent(
  submission_id integer not null,
  event_type text,
  occurance_date_time timestamp with timezone,
  reporting_user text,
  comment text
);
