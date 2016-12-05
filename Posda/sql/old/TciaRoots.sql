--
-- 
-- Copyright 2016, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 
--
CREATE Table Collection(
  collection_id serial,
  collection_code text unique
);
CREATE Table Site(
  site_id serial,
  site_code text unique
);
CREATE Table Submission (
  submission_id serial,
  collection_id integer not null,
  site_id integer not null,
  collection_name text,
  site_name text,
  body_part_entered text,
  patient_id_prefix text,
  access_type text,
  date_inc text,
  extra text
);
CREATE Table SubmissionEvent(
  submission_id integer not null,
  event_type text,
  occurance_date_time timestamp with time zone,
  reporting_user text,
  comment text
);
