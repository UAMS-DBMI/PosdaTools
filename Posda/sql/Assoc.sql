-- $Source: /home/bbennett/pass/archive/Posda/sql/Assoc.sql,v $
-- $Date: 2010/01/03 22:46:34 $
-- $Revision: 1.2 $
-- 
-- Copyright 2008, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 

--  RECEIVER
--  Represents a receiver thread:
--     Serves a port
--     is started at a time
--     is stopped at a time
--     may be discovered_dead (process died abnormally)
--     receiver_ae table ae's represented here
--
CREATE TABLE receiver (
  receiver_id serial NOT NULL,
  dt_started timestamp,
  dt_ended timestamp,
  discovered_dead boolean,
  port_served int
);

-- ACCEPTED_CONNECTION
-- Represents an accepted network connection
-- 
CREATE TABLE accepted_connection (
  accepted_connection_id serial NOT NULL,
  accepted_at timestamp NOT NULL,
  receiver_id integer NOT NULL,
  ac_ip_address text NOT NULL,
  socket_closed_at timestamp,
  discovered_dead_at timestamp,
  closing_log_message text
);


--  RECEIVER_AE
--  Represents an ae on a receiver thread
--    Has an ae_local_server which defines its parmeters
--
CREATE TABLE receiver_ae (
  receiver_id int NOT NULL,
  ae_local_server_id int NOT NULL
);

-- AE_LOCAL_SERVER
-- represents an AE on a local server
--   Has an AE Title
--   May be promiscuous (or see ae_local_server_authorized_clients)
--   ae_local_title must be unique (or NULL only if is_anonymous)
--
CREATE TABLE ae_local_server (
  ae_local_server_id serial NOT NULL,
  description text NOT NULL,
  is_anonymous boolean,
  is_promiscuous boolean,
  ae_local_title text,    -- Not Null if not anonymous
  aels_app_context text NOT NULL,
  aels_imp_class_uid text NOT NULL,
  aels_imp_ver_name text NOT NULL,
  aels_protocol_version int NOT NULL,
  aels_max_length int NOT NULL,
  aels_num_invoked int,
  aels_num_performed int
);

-- AE_LOCAL_RCV_PRES_CTX
-- Defines acceptable presentation contexts for a local server to receive
-- Many rows per ae_local_server
-- Each row has SOP_CLASS, XFR_STX, sort order
-- For proposed presentation context, accept matching row with lowest sort
-- order
-- implementation_class is 'STORAGE' , 'VERIFICATION', 'QR', or 'NORMALIZED'
--
CREATE TABLE ae_local_rcv_pres_ctx (
  ae_local_server_id int NOT NULL,
  sop_class_uid text NOT NULL,
  xfr_stx_uid text NOT NULL,
  aels_implementation_class text NOT NULL
);

CREATE TABLE ae_local_server_sopclass_role(
  ae_local_server_id int NOT NULL,
  sop_class_uid text NOT NULL,
  aels_scu_role boolean,
  aels_scp_role boolean
);

-- AE_LOCAL_SERVER_AUTHORIZED_CLIENTS
-- Unless ae_local_server is_promiscous, this defines all the 
-- application entities it will accept requests from
--
CREATE TABLE ae_local_server_authorized_clients (
  ae_local_server_id int NOT NULL,
  ae_calling_ae_title text NOT NULL
);


-- AE_DESTINATION
-- Defines a destination for an association
-- has a destination ae title
-- has an ip address or network name
-- has a port number
--
CREATE TABLE ae_destination (
  ae_destination_id serial NOT NULL,
  ae_destination_title text NOT NULL,
  ip_address text,
  network_name text,
  port_number int NOT NULL
);

-- INITIATED CONNECTION
CREATE TABLE initiated_connection(
  initiated_connection_id serial NOT NULL,
  ae_destination_id int NOT NULL,
  requested_at timestamp NOT NULL,
  established_at timestamp,
  closed_at timestamp,
  found_dead_at timestamp,
  closing_comment text
);

-- AE_LOCAL_SENDER
-- Just a list of ae_titles that may be used as
-- a calling_ae_title when requesting an association
--
CREATE TABLE ae_local_sender (
  ae_local_sender_id serial NOT NULL,
  ae_sender_title text NOT NULL,
  aelsn_app_context text NOT NULL,
  aelsn_imp_class_uid text NOT NULL,
  aelsn_imp_ver_name text NOT NULL,
  aelsn_protocol_version int NOT NULL,
  aelsn_max_length int NOT NULL,
  aelsn_num_invoked int,
  aelsn_num_performed int
);

CREATE TABLE assoc_rq (
  assoc_rq_id serial NOT NULL,
  arq_calling_ae_title text NOT NULL,
  arq_called_ae_title text NOT NULL,
  arq_app_context text NOT NULL,
  arq_imp_class_uid text NOT NULL,
  arq_imp_ver_name text NOT NULL,
  arq_protocol_version int NOT NULL,
  arq_max_length int NOT NULL,
  arq_num_invoked int,
  arq_num_performed int
);
CREATE TABLE assoc_rq_pres_ctx (
  assoc_rq_id int NOT NULL,
  pres_ctx_id int NOT NULL,
  sop_class_uid text NOT NULL
);
CREATE TABLE assoc_rq_xfr_stx (
  assoc_rq_id int NOT NULL,
  pres_ctx_id int NOT NULL,
  rq_xfr_stx_uid text NOT NULL,
  sort_order int
);
CREATE TABLE assoc_rq_sop_class_role(
  assoc_rq_id int NOT NULL,
  sop_class_uid text NOT NULL,
  assoc_rq_scu_role boolean,
  assoc_rq_scp_role boolean
);
CREATE TABLE assoc_ac (
  assoc_ac_id serial NOT NULL,
  aac_calling_ae_title text NOT NULL,
  aac_called_ae_title text NOT NULL,
  aac_imp_class_uid text NOT NULL,
  aac_imp_ver_name text NOT NULL,
  aac_app_context text NOT NULL,
  aac_max_length int NOT NULL,
  aac_protocol_version int NOT NULL,
  aac_num_invoked int,
  aac_num_performed int
);
CREATE TABLE assoc_ac_pres_ctx (
  assoc_ac_id int NOT NULL,
  pres_ctx_id int NOT NULL,
  assoc_ac_pc_result int NOT NULL,
  aac_xfr_stx_uid text NOT NULL
);
CREATE TABLE assoc_ac_sop_class_role(
  assoc_ac_id int NOT NULL,
  sop_class_uid text NOT NULL,
  assoc_ac_scu_role boolean,
  assoc_ac_scp_role boolean
);
CREATE TABLE assoc_rj (
  assoc_rj_id int NOT NULL,
  rj_result int,
  rj_source int,
  rj_reason int
);

CREATE TABLE rcv_assoc_rq(
  accepted_connection_id int NOT NULL,
  assoc_rq_id int NOT NULL
);
CREATE TABLE sent_assoc_rq(
  initiated_connection_id int NOT NULL,
  assoc_rq_id int NOT NULL
);
CREATE TABLE rcv_assoc_ac(
  initiated_connection_id int NOT NULL,
  assoc_ac_id int NOT NULL
);
CREATE TABLE sent_assoc_ac(
  accepted_connection_id int NOT NULL,
  assoc_ac_id int NOT NULL
);
CREATE TABLE rcv_assoc_rj(
  initiated_connection_id int NOT NULL,
  assoc_rj_id int NOT NULL
);
CREATE TABLE sent_assoc_rj(
  accepted_connection_id int NOT NULL,
  assoc_rj_id int NOT NULL
);

-- ASSOCIATION
-- Has a row per association
-- Created when Assoc_RQ is sent or received
-- Set rejected when Assoc_RJ is sent or received
-- Set accepted when Assoc_AC is sent or received
-- Termination_dt not null after A_Release or A_Abort or Connection interrupted
-- Most parameters meaningful only if accepted
--   parameters determined by Assoc_RQ and Assoc_AC contents
-- 
CREATE TABLE association (
  association_id serial NOT NULL,
  client_side boolean,
  invoked boolean, -- true if invoked
  accepted boolean, -- true if accepted
  rejected boolean, -- true if rejected
  accepted_connection_id int,  -- if not client_side, id of accepted_connection
  ae_local_sender_id int, -- if client_side, id of ae_local_sender
  initiated_connection_id int,  -- if client_side, id of initiated_connection
  calling_ae_title text NOT NULL,
  called_ae_title text NOT NULL,
  app_context text NOT NULL,
  max_length int NOT NULL,
  protocol_version int NOT NULL,
  num_invoked int,
  num_performed int,
  initiation_dt timestamp,
  termination_dt timestamp,
  termination_notes text
);

CREATE TABLE assoc_pres_ctx (
  association_id int NOT NULL,
  pres_ctx_id int NOT NULL,
  implementation_class text NOT NULL,
  pc_sop_class_uid text NOT NULL,
  pc_xfr_stx_uid text NOT NULL
);

CREATE TABLE association_sop_class_role(
  association_id int NOT NULL,
  sop_class_uid text NOT NULL,
  assoc_scu_role boolean,
  assoc_scp_role boolean
);

CREATE TABLE a_release_rq (
  a_release_rq_id serial NOT NULL
);
CREATE TABLE sent_a_release_rq(
  association_id int NOT NULL,
  a_release_rq_id int NOT NULL
);
CREATE TABLE rcv_a_release_rq(
  association_id int NOT NULL,
  a_release_rq_id int NOT NULL
);
CREATE TABLE a_release_rp (
  a_release_rp_id serial NOT NULL
);
CREATE TABLE sent_a_release_rp(
  association_id int NOT NULL,
  a_release_rp_id int NOT NULL
);
CREATE TABLE rcv_a_release_rp(
  association_id int NOT NULL,
  a_release_rp_id int NOT NULL
);
CREATE TABLE a_abort (
  a_abort_id serial NOT NULL,
  abt_source int,
  abt_reason int
);
CREATE TABLE sent_a_abort(
  association_id int NOT NULL,
  a_abort_id int NOT NULL
);
CREATE TABLE rcv_a_abort(
  association_id int NOT NULL,
  a_abort_id int NOT NULL
);
