--
-- $Source: /home/bbennett/pass/archive/Posda/sql/dicom_dd.sql,v $
-- $Date: 2010/02/10 15:24:15 $
-- $Revision: 1.3 $
-- 
-- Copyright 2008, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 
--

CREATE TABLE ele (
    ele_sig text NOT NULL,
    grp integer,
    ele integer,
    grp_mask integer,
    ele_mask integer,
    grp_shift integer,
    ele_shift integer,
    vr text,
    vm text,
    vers text,
    owned_by text,
    name text,
    std boolean,
    pvt boolean,
    retired boolean,
    keyword text,
    private_block text
);


CREATE TABLE sopcl (
    sopcl_type text,
    sopcl_desc text,
    dir_rec text,
    sopcl_uid text,
    std_ref text,
    retired boolean
);


CREATE TABLE vr (
    vr_code text,
    vr_name text,
    len integer,
    fixed boolean,
    pad_leading boolean,
    pad_null boolean,
    pad_trailing boolean,
    strip_leading boolean,
    strip_trailing boolean,
    strip_trailing_null boolean,
    vr_type text
);

CREATE TABLE xfr_stx (
    xfr_stx_uid text NOT NULL,
    ref boolean,
    encap boolean,
    deflated boolean,
    vax boolean,
    explicit boolean,
    short_len boolean,
    std boolean,
    retired boolean,
    name text,
    default_for text,
    doc text
);
