SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_tokens (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    tokenable_id bigint NOT NULL,
    tokenable_type character varying NOT NULL,
    value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.access_tokens_id_seq OWNED BY public.access_tokens.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    user_id bigint NOT NULL,
    title character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    repositories_count integer
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entities (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    external_id character varying NOT NULL,
    source integer DEFAULT 0 NOT NULL,
    login character varying,
    avatar_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entities_id_seq OWNED BY public.entities.id;


--
-- Name: insights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insights (
    id bigint NOT NULL,
    insightable_id bigint NOT NULL,
    insightable_type character varying NOT NULL,
    entity_id bigint NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: insights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.insights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: insights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.insights_id_seq OWNED BY public.insights.id;


--
-- Name: pull_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    repository_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pull_number integer NOT NULL,
    pull_created_at timestamp(6) without time zone NOT NULL,
    pull_closed_at timestamp(6) without time zone,
    pull_merged_at timestamp(6) without time zone,
    open boolean DEFAULT true NOT NULL
);


--
-- Name: pull_requests_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests_comments (
    id bigint NOT NULL,
    pull_requests_entity_id bigint NOT NULL,
    external_id character varying NOT NULL,
    comment_created_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pull_requests_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pull_requests_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pull_requests_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pull_requests_comments_id_seq OWNED BY public.pull_requests_comments.id;


--
-- Name: pull_requests_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests_entities (
    id bigint NOT NULL,
    pull_request_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    origin integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pull_requests_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pull_requests_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pull_requests_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pull_requests_entities_id_seq OWNED BY public.pull_requests_entities.id;


--
-- Name: pull_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pull_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pull_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pull_requests_id_seq OWNED BY public.pull_requests.id;


--
-- Name: pull_requests_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests_reviews (
    id bigint NOT NULL,
    pull_requests_entity_id bigint NOT NULL,
    external_id character varying NOT NULL,
    review_created_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pull_requests_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pull_requests_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pull_requests_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pull_requests_reviews_id_seq OWNED BY public.pull_requests_reviews.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    company_id bigint NOT NULL,
    title character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pull_requests_count integer
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_id_seq OWNED BY public.repositories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    password_digest character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    restore_token character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_sessions (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_sessions_id_seq OWNED BY public.users_sessions.id;


--
-- Name: access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens ALTER COLUMN id SET DEFAULT nextval('public.access_tokens_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities ALTER COLUMN id SET DEFAULT nextval('public.entities_id_seq'::regclass);


--
-- Name: insights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights ALTER COLUMN id SET DEFAULT nextval('public.insights_id_seq'::regclass);


--
-- Name: pull_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_id_seq'::regclass);


--
-- Name: pull_requests_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_comments ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_comments_id_seq'::regclass);


--
-- Name: pull_requests_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_entities ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_entities_id_seq'::regclass);


--
-- Name: pull_requests_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_reviews ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_reviews_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_sessions ALTER COLUMN id SET DEFAULT nextval('public.users_sessions_id_seq'::regclass);


--
-- Name: access_tokens access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: insights insights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights
    ADD CONSTRAINT insights_pkey PRIMARY KEY (id);


--
-- Name: pull_requests_comments pull_requests_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_comments
    ADD CONSTRAINT pull_requests_comments_pkey PRIMARY KEY (id);


--
-- Name: pull_requests_entities pull_requests_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_entities
    ADD CONSTRAINT pull_requests_entities_pkey PRIMARY KEY (id);


--
-- Name: pull_requests pull_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests
    ADD CONSTRAINT pull_requests_pkey PRIMARY KEY (id);


--
-- Name: pull_requests_reviews pull_requests_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_reviews
    ADD CONSTRAINT pull_requests_reviews_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_sessions users_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_sessions
    ADD CONSTRAINT users_sessions_pkey PRIMARY KEY (id);


--
-- Name: index_access_tokens_on_tokenable_id_and_tokenable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_tokens_on_tokenable_id_and_tokenable_type ON public.access_tokens USING btree (tokenable_id, tokenable_type);


--
-- Name: index_access_tokens_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_tokens_on_uuid ON public.access_tokens USING btree (uuid);


--
-- Name: index_companies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_user_id ON public.companies USING btree (user_id);


--
-- Name: index_companies_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_uuid ON public.companies USING btree (uuid);


--
-- Name: index_entities_on_source_and_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_source_and_external_id ON public.entities USING btree (source, external_id);


--
-- Name: index_entities_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_uuid ON public.entities USING btree (uuid);


--
-- Name: index_insights_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insights_on_entity_id ON public.insights USING btree (entity_id);


--
-- Name: index_insights_on_insightable_id_and_insightable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insights_on_insightable_id_and_insightable_type ON public.insights USING btree (insightable_id, insightable_type);


--
-- Name: index_pull_requests_comments_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_comments_on_external_id ON public.pull_requests_comments USING btree (external_id);


--
-- Name: index_pull_requests_comments_on_pull_requests_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_comments_on_pull_requests_entity_id ON public.pull_requests_comments USING btree (pull_requests_entity_id);


--
-- Name: index_pull_requests_entities_on_pull_request_id_and_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_entities_on_pull_request_id_and_entity_id ON public.pull_requests_entities USING btree (pull_request_id, entity_id);


--
-- Name: index_pull_requests_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_repository_id ON public.pull_requests USING btree (repository_id);


--
-- Name: index_pull_requests_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_uuid ON public.pull_requests USING btree (uuid);


--
-- Name: index_pull_requests_reviews_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_reviews_on_external_id ON public.pull_requests_reviews USING btree (external_id);


--
-- Name: index_pull_requests_reviews_on_pull_requests_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_reviews_on_pull_requests_entity_id ON public.pull_requests_reviews USING btree (pull_requests_entity_id);


--
-- Name: index_repositories_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_company_id ON public.repositories USING btree (company_id);


--
-- Name: index_repositories_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_uuid ON public.repositories USING btree (uuid);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uuid ON public.users USING btree (uuid);


--
-- Name: index_users_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_sessions_on_user_id ON public.users_sessions USING btree (user_id);


--
-- Name: index_users_sessions_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_sessions_on_uuid ON public.users_sessions USING btree (uuid);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20211101190000'),
('20211101190250'),
('20220817183402'),
('20221026162239'),
('20221108144820'),
('20221229110331'),
('20221229111144'),
('20221229113504'),
('20221229135528'),
('20221230044750'),
('20221230070121'),
('20221230075113'),
('20221230134024'),
('20221230154819'),
('20221230184649'),
('20221231194301');


