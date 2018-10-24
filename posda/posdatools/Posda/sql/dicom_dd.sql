create table dicom_element(
  tag text unique,
  name text,
  keyword text unique,
  vr text,
  vm text,
  is_retired boolean,
  comments text
);
