--
-- PostgreSQL database dump
--

-- Dumped from database version 8.4.20
-- Dumped by pg_dump version 9.5.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET row_security = off;

--
-- Name: db_version; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA db_version;


SET search_path = db_version, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: version; Type: TABLE; Schema: db_version; Owner: -
--

CREATE TABLE version (
    version integer
);


SET search_path = public, pg_catalog;

--
-- Name: apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE apps (
    app_id integer NOT NULL,
    app_name text NOT NULL
);


--
-- Name: apps_app_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apps_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apps_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apps_app_id_seq OWNED BY apps.app_id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE permissions (
    permission_id integer NOT NULL,
    app_id integer,
    permission_name text NOT NULL
);


--
-- Name: permissions_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permissions_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permissions_permission_id_seq OWNED BY permissions.permission_id;


--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_permissions (
    user_id integer,
    permission_id integer
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    user_id integer NOT NULL,
    user_name text NOT NULL,
    full_name text NOT NULL,
    password text
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_user_id_seq OWNED BY users.user_id;


--
-- Name: app_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apps ALTER COLUMN app_id SET DEFAULT nextval('apps_app_id_seq'::regclass);


--
-- Name: permission_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN permission_id SET DEFAULT nextval('permissions_permission_id_seq'::regclass);


--
-- Name: user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN user_id SET DEFAULT nextval('users_user_id_seq'::regclass);


--
-- Name: apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (app_id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (permission_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users_user_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_user_name_key UNIQUE (user_name);


--
-- Name: permissions_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps(app_id) ON DELETE CASCADE;


--
-- Name: user_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_permissions
    ADD CONSTRAINT user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE;


--
-- Name: user_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_permissions
    ADD CONSTRAINT user_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

