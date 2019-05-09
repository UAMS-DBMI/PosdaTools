CREATE DATABASE dicom_dd WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';

\connect dicom_dd

create table dicom_element(
  tag text unique,
  name text,
  keyword text unique,
  vr text,
  vm text,
  is_retired boolean,
  comments text
);
