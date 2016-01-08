-- $Source: /home/bbennett/pass/archive/Posda/sql/passwd.sql,v $
-- $Date: 2010/08/06 16:54:38 $
-- $Revision: 1.2 $
-- 
-- Copyright 2010, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 

--
-- Name: attr_checkbox
--

CREATE TABLE attr_checkbox (
    attr_name text,
    prompt text,
    attr_value text
);

--
-- Name: attr_property_checkbox
--

CREATE TABLE attr_property_checkbox (
    attr_name text,
    attr_value text,
    property_name text,
    prompt text,
    property_value text
);

--
-- Name: attr_property_entry
--

CREATE TABLE attr_property_entry (
    attr_name text,
    attr_value text,
    prompt text,
    property_name text,
    length integer,
    multiplicity text,
    default_value text
);

--
-- Name: user_attr_property
--

CREATE TABLE user_attr_property (
    user_id text,
    attr_name text,
    attr_value text,
    property_name text,
    property_value text
);

--
-- Name: user_attributes
--

CREATE TABLE user_attributes (
    user_id text,
    attr_name text,
    attr_value text
);

--
-- Name: users
--

CREATE TABLE users (
    user_id text,
    real_name text,
    email_addr text,
    is_super boolean,
    enc_passwd text
);
