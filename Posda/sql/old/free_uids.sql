-- 
-- Copyright 2008, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 

-- Name: uid_root; Type: TABLE
--

CREATE TABLE uid_root (
    root text
);


-- Name: assigned_uids; Type: TABLE
--

CREATE TABLE assigned_uids (
    id serial NOT NULL,
    time_assigned timestamp with time zone,
    ip_addr text
);


-- Name: uid_request_parms; Type: TABLE
--

CREATE TABLE uid_request_parms (
    id integer,
    "key" text,
    value text
);
