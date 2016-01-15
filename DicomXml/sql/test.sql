-- $Source: /home/bbennett/pass/archive/DicomXml/sql/test.sql,v $
-- $Date: 2014/05/08 19:42:58 $
-- $Revision: 1.2 $
-- 
-- Copyright 2014, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
create table xml_document (
  xml_document_id serial NOT NULL,
  xml_file text NOT NULL
);
create table xml_element (
  xml_element_id serial NOT NULL,
  xml_element_name text NOT NULL,
  xml_document_id integer NOT NULL,
  xml_element_depth integer NOT NULL
);
create table xml_text_field(
  xml_text_field_id serial NOT NULL,
  xml_text_field_text text NOT NULL, 
  xml_document_id integer NOT NULL,
  xml_text_field_depth integer NOT NULL
);
create table xml_document_content(
  xml_document_content_is_element boolean,
  xml_element_id integer,
  xml_text_field_id integer,
  xml_document_id integer NOT NULL,
  xml_document_sequence integer NOT NULL
);
create table xml_element_content(
  xml_containing_element_id integer NOT NULL,
  xml_element_content_is_element boolean,
  xml_element_id integer,
  xml_text_field_id integer,
  xml_element_sequence integer NOT NULL
);
create table xml_ele_ancestor_elements(
  xml_element_id integer NOT NULL,
  xml_ele_ancestor_element_depth integer NOT NULL,
  xml_ele_ancestor_element_id integer NOT NULL
);
create table xml_txt_ancestor_elements(
  xml_text_field_id integer NOT NULL,
  xml_txt_ancestor_element_depth integer NOT NULL,
  xml_txt_ancestor_element_id integer NOT NULL
);
create table xml_element_attribute(
  xml_element_id integer NOT NULL,
  xml_attribute_key text NOT NULL,
  xml_attribute_value text
);
create table xml_word_in_text(
  xml_word_in_text_id serial NOT NULL,
  xml_word_in_text text unique NOT NULL
);
create table xml_word_occurance_in_text(
  xml_word_in_text_id integer NOT NULL,
  xml_text_field_id integer NOT NULL,
  xml_preceding_word_id integer
);
--
-- Indices
--
create INDEX xml_element_containing_element_index on
  xml_element_content(xml_containing_element_id);
create INDEX xml_attribute_element_index on 
  xml_element_attribute(xml_element_id);
create INDEX xml_document_element_index on xml_element(xml_document_id);
create INDEX xml_document_text_index on xml_text_field(xml_document_id);
create INDEX xml_element_attribute_index on xml_element_attribute(xml_element_id);
