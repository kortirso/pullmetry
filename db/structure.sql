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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


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


--
-- Name: que_validate_tags(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_validate_tags(tags_array jsonb) RETURNS boolean
    LANGUAGE sql
    AS $$
  SELECT bool_and(
    jsonb_typeof(value) = 'string'
    AND
    char_length(value::text) <= 100
  )
  FROM jsonb_array_elements(tags_array)
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    job_class text NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error_message text,
    queue text DEFAULT 'default'::text NOT NULL,
    last_error_backtrace text,
    finished_at timestamp with time zone,
    expired_at timestamp with time zone,
    args jsonb DEFAULT '[]'::jsonb NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    job_schema_version integer NOT NULL,
    kwargs jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT error_length CHECK (((char_length(last_error_message) <= 500) AND (char_length(last_error_backtrace) <= 10000))),
    CONSTRAINT job_class_length CHECK ((char_length(
CASE job_class
    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN ((args -> 0) ->> 'job_class'::text)
    ELSE job_class
END) <= 200)),
    CONSTRAINT queue_length CHECK ((char_length(queue) <= 100)),
    CONSTRAINT valid_args CHECK ((jsonb_typeof(args) = 'array'::text)),
    CONSTRAINT valid_data CHECK (((jsonb_typeof(data) = 'object'::text) AND ((NOT (data ? 'tags'::text)) OR ((jsonb_typeof((data -> 'tags'::text)) = 'array'::text) AND (jsonb_array_length((data -> 'tags'::text)) <= 5) AND public.que_validate_tags((data -> 'tags'::text))))))
)
WITH (fillfactor='90');


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.que_jobs IS '7';


--
-- Name: que_determine_job_state(public.que_jobs); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_determine_job_state(job public.que_jobs) RETURNS text
    LANGUAGE sql
    AS $$
  SELECT
    CASE
    WHEN job.expired_at  IS NOT NULL    THEN 'expired'
    WHEN job.finished_at IS NOT NULL    THEN 'finished'
    WHEN job.error_count > 0            THEN 'errored'
    WHEN job.run_at > CURRENT_TIMESTAMP THEN 'scheduled'
    ELSE                                     'ready'
    END
$$;


--
-- Name: que_job_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_job_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    locker_pid integer;
    sort_key json;
  BEGIN
    -- Don't do anything if the job is scheduled for a future time.
    IF NEW.run_at IS NOT NULL AND NEW.run_at > now() THEN
      RETURN null;
    END IF;

    -- Pick a locker to notify of the job's insertion, weighted by their number
    -- of workers. Should bounce pseudorandomly between lockers on each
    -- invocation, hence the md5-ordering, but still touch each one equally,
    -- hence the modulo using the job_id.
    SELECT pid
    INTO locker_pid
    FROM (
      SELECT *, last_value(row_number) OVER () + 1 AS count
      FROM (
        SELECT *, row_number() OVER () - 1 AS row_number
        FROM (
          SELECT *
          FROM public.que_lockers ql, generate_series(1, ql.worker_count) AS id
          WHERE
            listening AND
            queues @> ARRAY[NEW.queue] AND
            ql.job_schema_version = NEW.job_schema_version
          ORDER BY md5(pid::text || id::text)
        ) t1
      ) t2
    ) t3
    WHERE NEW.id % count = row_number;

    IF locker_pid IS NOT NULL THEN
      -- There's a size limit to what can be broadcast via LISTEN/NOTIFY, so
      -- rather than throw errors when someone enqueues a big job, just
      -- broadcast the most pertinent information, and let the locker query for
      -- the record after it's taken the lock. The worker will have to hit the
      -- DB in order to make sure the job is still visible anyway.
      SELECT row_to_json(t)
      INTO sort_key
      FROM (
        SELECT
          'job_available' AS message_type,
          NEW.queue       AS queue,
          NEW.priority    AS priority,
          NEW.id          AS id,
          -- Make sure we output timestamps as UTC ISO 8601
          to_char(NEW.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at
      ) t;

      PERFORM pg_notify('que_listener_' || locker_pid::text, sort_key::text);
    END IF;

    RETURN null;
  END
$$;


--
-- Name: que_state_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_state_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    row record;
    message json;
    previous_state text;
    current_state text;
  BEGIN
    IF TG_OP = 'INSERT' THEN
      previous_state := 'nonexistent';
      current_state  := public.que_determine_job_state(NEW);
      row            := NEW;
    ELSIF TG_OP = 'DELETE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := 'nonexistent';
      row            := OLD;
    ELSIF TG_OP = 'UPDATE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := public.que_determine_job_state(NEW);

      -- If the state didn't change, short-circuit.
      IF previous_state = current_state THEN
        RETURN null;
      END IF;

      row := NEW;
    ELSE
      RAISE EXCEPTION 'Unrecognized TG_OP: %', TG_OP;
    END IF;

    SELECT row_to_json(t)
    INTO message
    FROM (
      SELECT
        'job_change' AS message_type,
        row.id       AS id,
        row.queue    AS queue,

        coalesce(row.data->'tags', '[]'::jsonb) AS tags,

        to_char(row.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at,
        to_char(now()      AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS time,

        CASE row.job_class
        WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' THEN
          coalesce(
            row.args->0->>'job_class',
            'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'
          )
        ELSE
          row.job_class
        END AS job_class,

        previous_state AS previous_state,
        current_state  AS current_state
    ) t;

    PERFORM pg_notify('que_state', message::text);

    RETURN null;
  END
$$;


--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_tokens (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    tokenable_id bigint NOT NULL,
    tokenable_type character varying NOT NULL,
    value text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    expired_at timestamp(6) without time zone
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
-- Name: api_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_access_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    value text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    uuid uuid NOT NULL
);


--
-- Name: api_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_access_tokens_id_seq OWNED BY public.api_access_tokens.id;


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
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    repositories_count integer,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    accessable boolean DEFAULT true NOT NULL,
    not_accessable_ticks integer DEFAULT 0 NOT NULL
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
-- Name: companies_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies_users (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    company_id bigint NOT NULL,
    user_id bigint NOT NULL,
    invite_id bigint NOT NULL,
    access integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: companies_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_users_id_seq OWNED BY public.companies_users.id;


--
-- Name: emailbutler_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emailbutler_messages (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    mailer character varying NOT NULL,
    action character varying NOT NULL,
    params jsonb DEFAULT '{}'::jsonb NOT NULL,
    send_to character varying[],
    status integer DEFAULT 0 NOT NULL,
    "timestamp" timestamp(6) without time zone,
    lock_version integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: emailbutler_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emailbutler_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emailbutler_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emailbutler_messages_id_seq OWNED BY public.emailbutler_messages.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entities (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    external_id character varying NOT NULL,
    provider integer DEFAULT 0 NOT NULL,
    login character varying,
    avatar_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    identity_id bigint,
    html_url character varying
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
-- Name: event_store_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_store_events (
    id bigint NOT NULL,
    event_id uuid NOT NULL,
    event_type character varying NOT NULL,
    metadata jsonb,
    data jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    valid_at timestamp(6) without time zone
);


--
-- Name: event_store_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_store_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_store_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_store_events_id_seq OWNED BY public.event_store_events.id;


--
-- Name: event_store_events_in_streams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_store_events_in_streams (
    id bigint NOT NULL,
    stream character varying NOT NULL,
    "position" integer,
    event_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: event_store_events_in_streams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_store_events_in_streams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_store_events_in_streams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_store_events_in_streams_id_seq OWNED BY public.event_store_events_in_streams.id;


--
-- Name: excludes_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.excludes_groups (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    insightable_id bigint NOT NULL,
    insightable_type character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: excludes_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.excludes_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: excludes_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.excludes_groups_id_seq OWNED BY public.excludes_groups.id;


--
-- Name: excludes_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.excludes_rules (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    excludes_group_id bigint NOT NULL,
    target integer NOT NULL,
    condition integer NOT NULL,
    value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN excludes_rules.target; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.excludes_rules.target IS 'Target for comparison: branch name';


--
-- Name: COLUMN excludes_rules.condition; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.excludes_rules.condition IS 'Condition for exclude rule: include/contain';


--
-- Name: COLUMN excludes_rules.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.excludes_rules.value IS 'Value for comparison';


--
-- Name: excludes_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.excludes_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: excludes_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.excludes_rules_id_seq OWNED BY public.excludes_rules.id;


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title character varying,
    description text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    email text,
    answerable boolean DEFAULT false NOT NULL
);


--
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feedbacks_id_seq OWNED BY public.feedbacks.id;


--
-- Name: identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    uid character varying NOT NULL,
    provider integer DEFAULT 0 NOT NULL,
    email text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    login character varying
);


--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.identities_id_seq OWNED BY public.identities.id;


--
-- Name: ignores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ignores (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    insightable_id bigint NOT NULL,
    insightable_type character varying NOT NULL,
    entity_value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ignores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ignores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ignores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ignores_id_seq OWNED BY public.ignores.id;


--
-- Name: insights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insights (
    id bigint NOT NULL,
    insightable_id bigint NOT NULL,
    insightable_type character varying NOT NULL,
    entity_id bigint NOT NULL,
    comments_count integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    reviews_count integer DEFAULT 0,
    required_reviews_count integer DEFAULT 0,
    open_pull_requests_count integer DEFAULT 0,
    average_review_seconds integer DEFAULT 0,
    average_merge_seconds integer DEFAULT 0,
    average_open_pr_comments numeric(6,2),
    review_involving integer,
    previous_date character varying,
    reviewed_loc integer,
    average_reviewed_loc integer,
    changed_loc integer,
    average_changed_loc integer,
    hidden boolean DEFAULT false NOT NULL,
    bad_reviews_count integer DEFAULT 0 NOT NULL,
    conventional_comments_count integer DEFAULT 0,
    time_since_last_open_pull_seconds integer DEFAULT 0
);


--
-- Name: COLUMN insights.hidden; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insights.hidden IS 'Flag for hiding insights, if true - available only for owner';


--
-- Name: COLUMN insights.time_since_last_open_pull_seconds; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insights.time_since_last_open_pull_seconds IS 'Time since last open pull request';


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
-- Name: invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invites (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    inviteable_id bigint NOT NULL,
    inviteable_type character varying NOT NULL,
    receiver_id bigint,
    email text,
    code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    access integer DEFAULT 0 NOT NULL
);


--
-- Name: invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invites_id_seq OWNED BY public.invites.id;


--
-- Name: kudos_achievement_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kudos_achievement_groups (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    parent_id bigint,
    "position" integer DEFAULT 0 NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: kudos_achievement_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kudos_achievement_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_achievement_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kudos_achievement_groups_id_seq OWNED BY public.kudos_achievement_groups.id;


--
-- Name: kudos_achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kudos_achievements (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    award_name character varying NOT NULL,
    rank integer,
    points integer,
    title jsonb DEFAULT '{}'::jsonb NOT NULL,
    description jsonb DEFAULT '{}'::jsonb NOT NULL,
    kudos_achievement_group_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: kudos_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kudos_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kudos_achievements_id_seq OWNED BY public.kudos_achievements.id;


--
-- Name: kudos_users_achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kudos_users_achievements (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    kudos_achievement_id bigint NOT NULL,
    notified boolean DEFAULT false NOT NULL,
    rank integer,
    points integer,
    title jsonb DEFAULT '{}'::jsonb NOT NULL,
    description jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: kudos_users_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kudos_users_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_users_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kudos_users_achievements_id_seq OWNED BY public.kudos_users_achievements.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    notifyable_id bigint NOT NULL,
    notifyable_type character varying NOT NULL,
    notification_type integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    uuid uuid NOT NULL,
    webhook_id bigint NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


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
    pull_created_at timestamp(6) without time zone,
    pull_closed_at timestamp(6) without time zone,
    pull_merged_at timestamp(6) without time zone,
    entity_id bigint NOT NULL,
    pull_requests_comments_count integer DEFAULT 0 NOT NULL,
    changed_loc integer DEFAULT 0 NOT NULL,
    last_commit_external_id character varying
);


--
-- Name: COLUMN pull_requests.changed_loc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pull_requests.changed_loc IS 'Lines Of Code changed in pull request';


--
-- Name: pull_requests_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests_comments (
    id bigint NOT NULL,
    external_id character varying NOT NULL,
    comment_created_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pull_request_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    parsed_body jsonb
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
    external_id character varying,
    review_created_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pull_request_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    required boolean DEFAULT false NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    commit_external_id character varying
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
-- Name: que_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.que_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.que_jobs_id_seq OWNED BY public.que_jobs.id;


--
-- Name: que_lockers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.que_lockers (
    pid integer NOT NULL,
    worker_count integer NOT NULL,
    worker_priorities integer[] NOT NULL,
    ruby_pid integer NOT NULL,
    ruby_hostname text NOT NULL,
    queues text[] NOT NULL,
    listening boolean NOT NULL,
    job_schema_version integer DEFAULT 1,
    CONSTRAINT valid_queues CHECK (((array_ndims(queues) = 1) AND (array_length(queues, 1) IS NOT NULL))),
    CONSTRAINT valid_worker_priorities CHECK (((array_ndims(worker_priorities) = 1) AND (array_length(worker_priorities, 1) IS NOT NULL)))
);


--
-- Name: que_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_values (
    key text NOT NULL,
    value jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT valid_value CHECK ((jsonb_typeof(value) = 'object'::text))
)
WITH (fillfactor='90');


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    company_id bigint NOT NULL,
    title character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pull_requests_count integer,
    link character varying DEFAULT ''::character varying NOT NULL,
    provider integer DEFAULT 0 NOT NULL,
    external_id character varying,
    synced_at timestamp(6) without time zone,
    accessable boolean DEFAULT true NOT NULL,
    owner_avatar_url character varying
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
-- Name: repositories_insights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories_insights (
    id bigint NOT NULL,
    repository_id bigint NOT NULL,
    previous_date character varying,
    open_pull_requests_count integer DEFAULT 0 NOT NULL,
    commented_pull_requests_count integer DEFAULT 0 NOT NULL,
    reviewed_pull_requests_count integer DEFAULT 0 NOT NULL,
    merged_pull_requests_count integer DEFAULT 0 NOT NULL,
    average_comment_time integer DEFAULT 0 NOT NULL,
    average_review_time integer DEFAULT 0 NOT NULL,
    average_merge_time integer DEFAULT 0 NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    average_comments_count numeric(6,2) DEFAULT 0.0 NOT NULL,
    changed_loc integer DEFAULT 0 NOT NULL,
    average_changed_loc numeric(8,2) DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    conventional_comments_count integer DEFAULT 0
);


--
-- Name: repositories_insights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_insights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_insights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_insights_id_seq OWNED BY public.repositories_insights.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: subscribers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscribers (
    id bigint NOT NULL,
    email text NOT NULL,
    unsubscribe_token character varying,
    unsubscribed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscribers_id_seq OWNED BY public.subscribers.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    start_time timestamp(6) without time zone NOT NULL,
    end_time timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    external_invoice_id character varying,
    plan integer DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN subscriptions.external_invoice_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.subscriptions.external_invoice_id IS 'Invoice ID from external system';


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    email text DEFAULT ''::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    role integer DEFAULT 0 NOT NULL,
    work_start_time time without time zone,
    work_end_time time without time zone,
    work_time_zone character varying,
    start_time character varying,
    end_time character varying,
    time_zone character varying
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
-- Name: vacations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vacations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    start_time timestamp(6) without time zone NOT NULL,
    end_time timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: vacations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vacations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vacations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vacations_id_seq OWNED BY public.vacations.id;


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    source integer DEFAULT 0 NOT NULL,
    url character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    company_id bigint NOT NULL
);


--
-- Name: webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_id_seq OWNED BY public.webhooks.id;


--
-- Name: work_times; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_times (
    id bigint NOT NULL,
    worktimeable_id bigint NOT NULL,
    worktimeable_type character varying NOT NULL,
    starts_at character varying NOT NULL,
    ends_at character varying NOT NULL,
    timezone character varying DEFAULT '0'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: work_times_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_times_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_times_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_times_id_seq OWNED BY public.work_times.id;


--
-- Name: access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens ALTER COLUMN id SET DEFAULT nextval('public.access_tokens_id_seq'::regclass);


--
-- Name: api_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.api_access_tokens_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: companies_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_users ALTER COLUMN id SET DEFAULT nextval('public.companies_users_id_seq'::regclass);


--
-- Name: emailbutler_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emailbutler_messages ALTER COLUMN id SET DEFAULT nextval('public.emailbutler_messages_id_seq'::regclass);


--
-- Name: entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities ALTER COLUMN id SET DEFAULT nextval('public.entities_id_seq'::regclass);


--
-- Name: event_store_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events ALTER COLUMN id SET DEFAULT nextval('public.event_store_events_id_seq'::regclass);


--
-- Name: event_store_events_in_streams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events_in_streams ALTER COLUMN id SET DEFAULT nextval('public.event_store_events_in_streams_id_seq'::regclass);


--
-- Name: excludes_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excludes_groups ALTER COLUMN id SET DEFAULT nextval('public.excludes_groups_id_seq'::regclass);


--
-- Name: excludes_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excludes_rules ALTER COLUMN id SET DEFAULT nextval('public.excludes_rules_id_seq'::regclass);


--
-- Name: feedbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks ALTER COLUMN id SET DEFAULT nextval('public.feedbacks_id_seq'::regclass);


--
-- Name: identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities ALTER COLUMN id SET DEFAULT nextval('public.identities_id_seq'::regclass);


--
-- Name: ignores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ignores ALTER COLUMN id SET DEFAULT nextval('public.ignores_id_seq'::regclass);


--
-- Name: insights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights ALTER COLUMN id SET DEFAULT nextval('public.insights_id_seq'::regclass);


--
-- Name: invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invites ALTER COLUMN id SET DEFAULT nextval('public.invites_id_seq'::regclass);


--
-- Name: kudos_achievement_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievement_groups ALTER COLUMN id SET DEFAULT nextval('public.kudos_achievement_groups_id_seq'::regclass);


--
-- Name: kudos_achievements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievements ALTER COLUMN id SET DEFAULT nextval('public.kudos_achievements_id_seq'::regclass);


--
-- Name: kudos_users_achievements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_users_achievements ALTER COLUMN id SET DEFAULT nextval('public.kudos_users_achievements_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: pull_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_id_seq'::regclass);


--
-- Name: pull_requests_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_comments ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_comments_id_seq'::regclass);


--
-- Name: pull_requests_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_reviews ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_reviews_id_seq'::regclass);


--
-- Name: que_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs ALTER COLUMN id SET DEFAULT nextval('public.que_jobs_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: repositories_insights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories_insights ALTER COLUMN id SET DEFAULT nextval('public.repositories_insights_id_seq'::regclass);


--
-- Name: subscribers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscribers ALTER COLUMN id SET DEFAULT nextval('public.subscribers_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_sessions ALTER COLUMN id SET DEFAULT nextval('public.users_sessions_id_seq'::regclass);


--
-- Name: vacations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vacations ALTER COLUMN id SET DEFAULT nextval('public.vacations_id_seq'::regclass);


--
-- Name: webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks ALTER COLUMN id SET DEFAULT nextval('public.webhooks_id_seq'::regclass);


--
-- Name: work_times id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_times ALTER COLUMN id SET DEFAULT nextval('public.work_times_id_seq'::regclass);


--
-- Name: access_tokens access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (id);


--
-- Name: api_access_tokens api_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_access_tokens
    ADD CONSTRAINT api_access_tokens_pkey PRIMARY KEY (id);


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
-- Name: companies_users companies_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_users
    ADD CONSTRAINT companies_users_pkey PRIMARY KEY (id);


--
-- Name: emailbutler_messages emailbutler_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emailbutler_messages
    ADD CONSTRAINT emailbutler_messages_pkey PRIMARY KEY (id);


--
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: event_store_events_in_streams event_store_events_in_streams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events_in_streams
    ADD CONSTRAINT event_store_events_in_streams_pkey PRIMARY KEY (id);


--
-- Name: event_store_events event_store_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events
    ADD CONSTRAINT event_store_events_pkey PRIMARY KEY (id);


--
-- Name: excludes_groups excludes_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excludes_groups
    ADD CONSTRAINT excludes_groups_pkey PRIMARY KEY (id);


--
-- Name: excludes_rules excludes_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excludes_rules
    ADD CONSTRAINT excludes_rules_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: ignores ignores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ignores
    ADD CONSTRAINT ignores_pkey PRIMARY KEY (id);


--
-- Name: insights insights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights
    ADD CONSTRAINT insights_pkey PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: kudos_achievement_groups kudos_achievement_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievement_groups
    ADD CONSTRAINT kudos_achievement_groups_pkey PRIMARY KEY (id);


--
-- Name: kudos_achievements kudos_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievements
    ADD CONSTRAINT kudos_achievements_pkey PRIMARY KEY (id);


--
-- Name: kudos_users_achievements kudos_users_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_users_achievements
    ADD CONSTRAINT kudos_users_achievements_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: pull_requests_comments pull_requests_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests_comments
    ADD CONSTRAINT pull_requests_comments_pkey PRIMARY KEY (id);


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
-- Name: que_jobs que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (id);


--
-- Name: que_lockers que_lockers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_lockers
    ADD CONSTRAINT que_lockers_pkey PRIMARY KEY (pid);


--
-- Name: que_values que_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_values
    ADD CONSTRAINT que_values_pkey PRIMARY KEY (key);


--
-- Name: repositories_insights repositories_insights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories_insights
    ADD CONSTRAINT repositories_insights_pkey PRIMARY KEY (id);


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
-- Name: subscribers subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT subscribers_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


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
-- Name: vacations vacations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vacations
    ADD CONSTRAINT vacations_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: work_times work_times_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_times
    ADD CONSTRAINT work_times_pkey PRIMARY KEY (id);


--
-- Name: idx_on_insightable_id_insightable_type_entity_value_508616f247; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_insightable_id_insightable_type_entity_value_508616f247 ON public.ignores USING btree (insightable_id, insightable_type, entity_value);


--
-- Name: idx_on_inviteable_id_inviteable_type_receiver_id_700d475c99; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_inviteable_id_inviteable_type_receiver_id_700d475c99 ON public.invites USING btree (inviteable_id, inviteable_type, receiver_id);


--
-- Name: index_access_tokens_on_tokenable_id_and_tokenable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_tokens_on_tokenable_id_and_tokenable_type ON public.access_tokens USING btree (tokenable_id, tokenable_type);


--
-- Name: index_access_tokens_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_tokens_on_uuid ON public.access_tokens USING btree (uuid);


--
-- Name: index_api_access_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_access_tokens_on_user_id ON public.api_access_tokens USING btree (user_id);


--
-- Name: index_api_access_tokens_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_access_tokens_on_uuid ON public.api_access_tokens USING btree (uuid);


--
-- Name: index_api_access_tokens_on_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_access_tokens_on_value ON public.api_access_tokens USING btree (value);


--
-- Name: index_companies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_user_id ON public.companies USING btree (user_id);


--
-- Name: index_companies_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_uuid ON public.companies USING btree (uuid);


--
-- Name: index_companies_users_on_company_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_users_on_company_id_and_user_id ON public.companies_users USING btree (company_id, user_id);


--
-- Name: index_companies_users_on_invite_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_invite_id ON public.companies_users USING btree (invite_id);


--
-- Name: index_companies_users_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_users_on_uuid ON public.companies_users USING btree (uuid);


--
-- Name: index_emailbutler_messages_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_emailbutler_messages_on_uuid ON public.emailbutler_messages USING btree (uuid);


--
-- Name: index_entities_on_identity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_identity_id ON public.entities USING btree (identity_id);


--
-- Name: index_entities_on_provider_and_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_provider_and_external_id ON public.entities USING btree (provider, external_id);


--
-- Name: index_entities_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_uuid ON public.entities USING btree (uuid);


--
-- Name: index_event_store_events_in_streams_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_in_streams_on_created_at ON public.event_store_events_in_streams USING btree (created_at);


--
-- Name: index_event_store_events_in_streams_on_stream_and_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_store_events_in_streams_on_stream_and_event_id ON public.event_store_events_in_streams USING btree (stream, event_id);


--
-- Name: index_event_store_events_in_streams_on_stream_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_store_events_in_streams_on_stream_and_position ON public.event_store_events_in_streams USING btree (stream, "position");


--
-- Name: index_event_store_events_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_on_created_at ON public.event_store_events USING btree (created_at);


--
-- Name: index_event_store_events_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_store_events_on_event_id ON public.event_store_events USING btree (event_id);


--
-- Name: index_event_store_events_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_on_event_type ON public.event_store_events USING btree (event_type);


--
-- Name: index_event_store_events_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_on_valid_at ON public.event_store_events USING btree (valid_at);


--
-- Name: index_excludes_groups_on_insightable_id_and_insightable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excludes_groups_on_insightable_id_and_insightable_type ON public.excludes_groups USING btree (insightable_id, insightable_type);


--
-- Name: index_excludes_groups_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_excludes_groups_on_uuid ON public.excludes_groups USING btree (uuid);


--
-- Name: index_excludes_rules_on_excludes_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excludes_rules_on_excludes_group_id ON public.excludes_rules USING btree (excludes_group_id);


--
-- Name: index_excludes_rules_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_excludes_rules_on_uuid ON public.excludes_rules USING btree (uuid);


--
-- Name: index_feedbacks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_feedbacks_on_user_id ON public.feedbacks USING btree (user_id);


--
-- Name: index_identities_on_uid_and_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_identities_on_uid_and_provider ON public.identities USING btree (uid, provider);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_user_id ON public.identities USING btree (user_id);


--
-- Name: index_ignores_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ignores_on_uuid ON public.ignores USING btree (uuid);


--
-- Name: index_insights_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insights_on_entity_id ON public.insights USING btree (entity_id);


--
-- Name: index_insights_on_insightable_id_and_insightable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insights_on_insightable_id_and_insightable_type ON public.insights USING btree (insightable_id, insightable_type);


--
-- Name: index_invites_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_invites_on_uuid ON public.invites USING btree (uuid);


--
-- Name: index_kudos_achievement_groups_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_achievement_groups_on_parent_id ON public.kudos_achievement_groups USING btree (parent_id);


--
-- Name: index_kudos_achievement_groups_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kudos_achievement_groups_on_uuid ON public.kudos_achievement_groups USING btree (uuid);


--
-- Name: index_kudos_achievements_on_award_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_achievements_on_award_name ON public.kudos_achievements USING btree (award_name);


--
-- Name: index_kudos_achievements_on_kudos_achievement_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_achievements_on_kudos_achievement_group_id ON public.kudos_achievements USING btree (kudos_achievement_group_id);


--
-- Name: index_kudos_achievements_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kudos_achievements_on_uuid ON public.kudos_achievements USING btree (uuid);


--
-- Name: index_kudos_users_achievements_on_kudos_achievement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_users_achievements_on_kudos_achievement_id ON public.kudos_users_achievements USING btree (kudos_achievement_id);


--
-- Name: index_notifications_on_notifyable_id_and_notifyable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_notifyable_id_and_notifyable_type ON public.notifications USING btree (notifyable_id, notifyable_type);


--
-- Name: index_notifications_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_uuid ON public.notifications USING btree (uuid);


--
-- Name: index_notifications_on_webhook_id_and_notification_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_on_webhook_id_and_notification_type ON public.notifications USING btree (webhook_id, notification_type);


--
-- Name: index_pull_requests_comments_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_comments_on_external_id ON public.pull_requests_comments USING btree (external_id);


--
-- Name: index_pull_requests_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_entity_id ON public.pull_requests USING btree (entity_id);


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
-- Name: index_repositories_insights_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_insights_on_repository_id ON public.repositories_insights USING btree (repository_id);


--
-- Name: index_repositories_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_company_id ON public.repositories USING btree (company_id);


--
-- Name: index_repositories_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_uuid ON public.repositories USING btree (uuid);


--
-- Name: index_subscribers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscribers_on_email ON public.subscribers USING btree (email);


--
-- Name: index_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_user_id ON public.subscriptions USING btree (user_id);


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

CREATE INDEX index_users_sessions_on_user_id ON public.users_sessions USING btree (user_id);


--
-- Name: index_users_sessions_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_sessions_on_uuid ON public.users_sessions USING btree (uuid);


--
-- Name: index_vacations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vacations_on_user_id ON public.vacations USING btree (user_id);


--
-- Name: index_webhooks_on_company_id_and_source_and_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_webhooks_on_company_id_and_source_and_url ON public.webhooks USING btree (company_id, source, url);


--
-- Name: index_webhooks_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_webhooks_on_uuid ON public.webhooks USING btree (uuid);


--
-- Name: index_work_times_on_worktimeable_id_and_worktimeable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_work_times_on_worktimeable_id_and_worktimeable_type ON public.work_times USING btree (worktimeable_id, worktimeable_type);


--
-- Name: kudos_users_achievements_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX kudos_users_achievements_unique_index ON public.kudos_users_achievements USING btree (user_id, kudos_achievement_id);


--
-- Name: que_jobs_args_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_args_gin_idx ON public.que_jobs USING gin (args jsonb_path_ops);


--
-- Name: que_jobs_data_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_data_gin_idx ON public.que_jobs USING gin (data jsonb_path_ops);


--
-- Name: que_jobs_kwargs_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_kwargs_gin_idx ON public.que_jobs USING gin (kwargs jsonb_path_ops);


--
-- Name: que_poll_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_poll_idx ON public.que_jobs USING btree (job_schema_version, queue, priority, run_at, id) WHERE ((finished_at IS NULL) AND (expired_at IS NULL));


--
-- Name: que_jobs que_job_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_job_notify AFTER INSERT ON public.que_jobs FOR EACH ROW WHEN ((NOT (COALESCE(current_setting('que.skip_notify'::text, true), ''::text) = 'true'::text))) EXECUTE FUNCTION public.que_job_notify();


--
-- Name: que_jobs que_state_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_state_notify AFTER INSERT OR DELETE OR UPDATE ON public.que_jobs FOR EACH ROW WHEN ((NOT (COALESCE(current_setting('que.skip_notify'::text, true), ''::text) = 'true'::text))) EXECUTE FUNCTION public.que_state_notify();


--
-- Name: kudos_users_achievements fk_rails_4621adbc67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_users_achievements
    ADD CONSTRAINT fk_rails_4621adbc67 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: kudos_users_achievements fk_rails_db98df5998; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_users_achievements
    ADD CONSTRAINT fk_rails_db98df5998 FOREIGN KEY (kudos_achievement_id) REFERENCES public.kudos_achievements(id);


--
-- Name: kudos_achievements fk_rails_e8b9da81fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievements
    ADD CONSTRAINT fk_rails_e8b9da81fe FOREIGN KEY (kudos_achievement_group_id) REFERENCES public.kudos_achievement_groups(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240910132339'),
('20240903124912'),
('20240718070046'),
('20240705181734'),
('20240705181004'),
('20240705100956'),
('20240703185841'),
('20240702074229'),
('20240701132738'),
('20240624073726'),
('20240619082632'),
('20240611163102'),
('20240504185723'),
('20240504173744'),
('20240501090856'),
('20240429175135'),
('20240423084933'),
('20240423080644'),
('20240410190722'),
('20240309093507'),
('20240308124848'),
('20240308095839'),
('20240308074454'),
('20240220110817'),
('20240122114110'),
('20231226083832'),
('20231216131105'),
('20231213192605'),
('20231210142646'),
('20231210092757'),
('20231202162353'),
('20231126184938'),
('20231107124203'),
('20231024120000'),
('20230925093816'),
('20230918101006'),
('20230914184514'),
('20230914071959'),
('20230913201840'),
('20230913074316'),
('20230912200254'),
('20230912195115'),
('20230912182023'),
('20230912175713'),
('20230906185155'),
('20230904130559'),
('20230904082413'),
('20230627192841'),
('20230617083913'),
('20230612131612'),
('20230609173154'),
('20230606135138'),
('20230606045228'),
('20230602143731'),
('20230429043024'),
('20230228150952'),
('20230225111223'),
('20230225034617'),
('20230224044112'),
('20230222161252'),
('20230222145138'),
('20230127092045'),
('20230125135040'),
('20230121185501'),
('20230121154845'),
('20230120194630'),
('20230120143333'),
('20230119174916'),
('20230119174641'),
('20230109170258'),
('20230107125130'),
('20230107113744'),
('20230106184328'),
('20230105044303'),
('20230103184140'),
('20230103153335'),
('20230102191844'),
('20230102190258'),
('20230102171638'),
('20230101151400'),
('20230101101434'),
('20230101082827'),
('20230101061815'),
('20221231194301'),
('20221230184649'),
('20221230154819'),
('20221230134024'),
('20221230075113'),
('20221230070121'),
('20221230044750'),
('20221229135528'),
('20221229113504'),
('20221229111144'),
('20221229110331'),
('20221108144820'),
('20221026162239'),
('20220817183402'),
('20211101190250'),
('20211101190000');

