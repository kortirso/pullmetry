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
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_tokenable_id bigint,
    tokenable_type character varying NOT NULL,
    value text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    expired_at timestamp(6) without time zone,
    tokenable_id uuid NOT NULL
);


--
-- Name: api_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_access_tokens (
    numeric_id bigint,
    numeric_user_id bigint,
    value text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL
);


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
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_user_id bigint,
    title character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    repositories_count integer,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    accessable boolean DEFAULT true NOT NULL,
    not_accessable_ticks integer DEFAULT 0 NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: companies_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies_users (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_company_id bigint,
    numeric_user_id bigint,
    numeric_invite_id bigint,
    access integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id uuid NOT NULL,
    company_id uuid NOT NULL,
    invite_id uuid NOT NULL
);


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
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    external_id character varying NOT NULL,
    provider integer DEFAULT 0 NOT NULL,
    login character varying,
    avatar_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    numeric_identity_id bigint,
    html_url character varying,
    identity_id uuid
);


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
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_insightable_id bigint,
    insightable_type character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    insightable_id uuid NOT NULL
);


--
-- Name: excludes_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.excludes_rules (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_excludes_group_id bigint,
    target integer NOT NULL,
    condition integer NOT NULL,
    value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    excludes_group_id uuid NOT NULL
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
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    numeric_id bigint,
    numeric_user_id bigint,
    title character varying,
    description text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    email text,
    answerable boolean DEFAULT false NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identities (
    numeric_id bigint,
    numeric_user_id bigint,
    uid character varying NOT NULL,
    provider integer DEFAULT 0 NOT NULL,
    email text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    login character varying,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: ignores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ignores (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_insightable_id bigint,
    insightable_type character varying NOT NULL,
    entity_value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    insightable_id uuid NOT NULL
);


--
-- Name: insights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insights (
    numeric_id bigint,
    numeric_insightable_id bigint,
    insightable_type character varying NOT NULL,
    numeric_entity_id bigint,
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
    time_since_last_open_pull_seconds integer DEFAULT 0,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    insightable_id uuid NOT NULL,
    entity_id uuid NOT NULL
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
-- Name: invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invites (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_inviteable_id bigint,
    inviteable_type character varying NOT NULL,
    numeric_receiver_id bigint,
    email text,
    code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    access integer DEFAULT 0 NOT NULL,
    inviteable_id uuid NOT NULL,
    receiver_id uuid
);


--
-- Name: issue_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issue_comments (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_issue_id bigint,
    external_id character varying NOT NULL,
    comment_created_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    issue_id uuid NOT NULL
);


--
-- Name: TABLE issue_comments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.issue_comments IS 'Comments of issue';


--
-- Name: COLUMN issue_comments.comment_created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.issue_comments.comment_created_at IS 'Time of creating comment in issue';


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issues (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_repository_id bigint,
    opened_at timestamp(6) without time zone,
    closed_at timestamp(6) without time zone,
    issue_number integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    repository_id uuid NOT NULL
);


--
-- Name: kudos_achievement_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kudos_achievement_groups (
    id bigint NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
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
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
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
    numeric_user_id bigint,
    kudos_achievement_id bigint NOT NULL,
    notified boolean DEFAULT false NOT NULL,
    rank integer,
    points integer,
    title jsonb DEFAULT '{}'::jsonb NOT NULL,
    description jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id uuid NOT NULL
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
    numeric_id bigint,
    numeric_notifyable_id bigint,
    notifyable_type character varying NOT NULL,
    notification_type integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_webhook_id bigint,
    notifyable_id uuid NOT NULL,
    webhook_id uuid NOT NULL
);


--
-- Name: pull_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_repository_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pull_number integer NOT NULL,
    pull_created_at timestamp(6) without time zone,
    pull_closed_at timestamp(6) without time zone,
    pull_merged_at timestamp(6) without time zone,
    numeric_entity_id bigint,
    pull_requests_comments_count integer DEFAULT 0 NOT NULL,
    changed_loc integer DEFAULT 0 NOT NULL,
    last_commit_external_id character varying,
    repository_id uuid NOT NULL,
    entity_id uuid NOT NULL
);


--
-- Name: COLUMN pull_requests.changed_loc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pull_requests.changed_loc IS 'Lines Of Code changed in pull request';


--
-- Name: pull_requests_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests_comments (
    numeric_id bigint,
    external_id character varying NOT NULL,
    comment_created_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    numeric_pull_request_id bigint,
    numeric_entity_id bigint,
    parsed_body jsonb,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    pull_request_id uuid NOT NULL,
    entity_id uuid NOT NULL
);


--
-- Name: pull_requests_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests_reviews (
    numeric_id bigint,
    external_id character varying,
    review_created_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    numeric_pull_request_id bigint,
    numeric_entity_id bigint,
    required boolean DEFAULT false NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    commit_external_id character varying,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    pull_request_id uuid NOT NULL,
    entity_id uuid NOT NULL
);


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
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_company_id bigint,
    title character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pull_requests_count integer,
    link character varying DEFAULT ''::character varying NOT NULL,
    provider integer DEFAULT 0 NOT NULL,
    external_id character varying,
    synced_at timestamp(6) without time zone,
    accessable boolean DEFAULT true NOT NULL,
    owner_avatar_url character varying,
    company_id uuid NOT NULL
);


--
-- Name: repositories_insights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories_insights (
    numeric_id bigint,
    numeric_repository_id bigint,
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
    conventional_comments_count integer DEFAULT 0,
    open_issues_count integer DEFAULT 0 NOT NULL,
    closed_issues_count integer DEFAULT 0 NOT NULL,
    average_issue_comment_time integer DEFAULT 0 NOT NULL,
    average_issue_close_time integer DEFAULT 0 NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    repository_id uuid NOT NULL
);


--
-- Name: COLUMN repositories_insights.open_issues_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.repositories_insights.open_issues_count IS 'Open issues';


--
-- Name: COLUMN repositories_insights.closed_issues_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.repositories_insights.closed_issues_count IS 'Closed issues';


--
-- Name: COLUMN repositories_insights.average_issue_comment_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.repositories_insights.average_issue_comment_time IS 'Average time until first comment in issue';


--
-- Name: COLUMN repositories_insights.average_issue_close_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.repositories_insights.average_issue_close_time IS 'Average time until closing issue';


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
    numeric_id bigint,
    email text NOT NULL,
    unsubscribe_token character varying,
    unsubscribed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    numeric_id bigint,
    numeric_user_id bigint,
    start_time timestamp(6) without time zone NOT NULL,
    end_time timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    external_invoice_id character varying,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: COLUMN subscriptions.external_invoice_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.subscriptions.external_invoice_id IS 'Invoice ID from external system';


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
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
-- Name: users_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_sessions (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numeric_user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: vacations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vacations (
    numeric_id bigint,
    numeric_user_id bigint,
    start_time timestamp(6) without time zone NOT NULL,
    end_time timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    numeric_id bigint,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source integer DEFAULT 0 NOT NULL,
    url character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    numeric_company_id bigint,
    company_id uuid NOT NULL
);


--
-- Name: work_times; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_times (
    numeric_id bigint,
    numeric_worktimeable_id bigint,
    worktimeable_type character varying NOT NULL,
    starts_at character varying NOT NULL,
    ends_at character varying NOT NULL,
    timezone character varying DEFAULT '0'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    worktimeable_id uuid NOT NULL
);


--
-- Name: emailbutler_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emailbutler_messages ALTER COLUMN id SET DEFAULT nextval('public.emailbutler_messages_id_seq'::regclass);


--
-- Name: event_store_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events ALTER COLUMN id SET DEFAULT nextval('public.event_store_events_id_seq'::regclass);


--
-- Name: event_store_events_in_streams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events_in_streams ALTER COLUMN id SET DEFAULT nextval('public.event_store_events_in_streams_id_seq'::regclass);


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
-- Name: que_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs ALTER COLUMN id SET DEFAULT nextval('public.que_jobs_id_seq'::regclass);


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
-- Name: issue_comments issue_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issue_comments
    ADD CONSTRAINT issue_comments_pkey PRIMARY KEY (id);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


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
-- Name: idx_on_numeric_company_id_numeric_user_id_7ddb80d90a; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_numeric_company_id_numeric_user_id_7ddb80d90a ON public.companies_users USING btree (numeric_company_id, numeric_user_id);


--
-- Name: idx_on_numeric_insightable_id_insightable_type_58195392fb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_numeric_insightable_id_insightable_type_58195392fb ON public.excludes_groups USING btree (numeric_insightable_id, insightable_type);


--
-- Name: idx_on_numeric_insightable_id_insightable_type_enti_b01b1b20a5; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_numeric_insightable_id_insightable_type_enti_b01b1b20a5 ON public.ignores USING btree (numeric_insightable_id, insightable_type, entity_value);


--
-- Name: idx_on_numeric_inviteable_id_inviteable_type_numeri_d4079f4003; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_numeric_inviteable_id_inviteable_type_numeri_d4079f4003 ON public.invites USING btree (numeric_inviteable_id, inviteable_type, numeric_receiver_id);


--
-- Name: idx_on_numeric_notifyable_id_notifyable_type_3479f2327d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_numeric_notifyable_id_notifyable_type_3479f2327d ON public.notifications USING btree (numeric_notifyable_id, notifyable_type);


--
-- Name: idx_on_numeric_webhook_id_notification_type_3de333d1a8; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_numeric_webhook_id_notification_type_3de333d1a8 ON public.notifications USING btree (numeric_webhook_id, notification_type);


--
-- Name: idx_on_numeric_worktimeable_id_worktimeable_type_a086a988c8; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_numeric_worktimeable_id_worktimeable_type_a086a988c8 ON public.work_times USING btree (numeric_worktimeable_id, worktimeable_type);


--
-- Name: index_access_tokens_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_tokens_on_id ON public.access_tokens USING btree (id);


--
-- Name: index_access_tokens_on_numeric_tokenable_id_and_tokenable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_tokens_on_numeric_tokenable_id_and_tokenable_type ON public.access_tokens USING btree (numeric_tokenable_id, tokenable_type);


--
-- Name: index_access_tokens_on_tokenable_id_and_tokenable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_tokens_on_tokenable_id_and_tokenable_type ON public.access_tokens USING btree (tokenable_id, tokenable_type);


--
-- Name: index_api_access_tokens_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_access_tokens_on_id ON public.api_access_tokens USING btree (id);


--
-- Name: index_api_access_tokens_on_numeric_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_access_tokens_on_numeric_user_id ON public.api_access_tokens USING btree (numeric_user_id);


--
-- Name: index_api_access_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_access_tokens_on_user_id ON public.api_access_tokens USING btree (user_id);


--
-- Name: index_api_access_tokens_on_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_access_tokens_on_value ON public.api_access_tokens USING btree (value);


--
-- Name: index_companies_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_id ON public.companies USING btree (id);


--
-- Name: index_companies_on_numeric_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_numeric_user_id ON public.companies USING btree (numeric_user_id);


--
-- Name: index_companies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_user_id ON public.companies USING btree (user_id);


--
-- Name: index_companies_users_on_company_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_users_on_company_id_and_user_id ON public.companies_users USING btree (company_id, user_id);


--
-- Name: index_companies_users_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_users_on_id ON public.companies_users USING btree (id);


--
-- Name: index_companies_users_on_invite_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_invite_id ON public.companies_users USING btree (invite_id);


--
-- Name: index_companies_users_on_numeric_invite_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_numeric_invite_id ON public.companies_users USING btree (numeric_invite_id);


--
-- Name: index_emailbutler_messages_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_emailbutler_messages_on_uuid ON public.emailbutler_messages USING btree (uuid);


--
-- Name: index_entities_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_id ON public.entities USING btree (id);


--
-- Name: index_entities_on_identity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_identity_id ON public.entities USING btree (identity_id);


--
-- Name: index_entities_on_numeric_identity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_numeric_identity_id ON public.entities USING btree (numeric_identity_id);


--
-- Name: index_entities_on_provider_and_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_provider_and_external_id ON public.entities USING btree (provider, external_id);


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
-- Name: index_excludes_groups_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_excludes_groups_on_id ON public.excludes_groups USING btree (id);


--
-- Name: index_excludes_groups_on_insightable_id_and_insightable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excludes_groups_on_insightable_id_and_insightable_type ON public.excludes_groups USING btree (insightable_id, insightable_type);


--
-- Name: index_excludes_rules_on_excludes_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excludes_rules_on_excludes_group_id ON public.excludes_rules USING btree (excludes_group_id);


--
-- Name: index_excludes_rules_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_excludes_rules_on_id ON public.excludes_rules USING btree (id);


--
-- Name: index_excludes_rules_on_numeric_excludes_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excludes_rules_on_numeric_excludes_group_id ON public.excludes_rules USING btree (numeric_excludes_group_id);


--
-- Name: index_feedbacks_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_feedbacks_on_id ON public.feedbacks USING btree (id);


--
-- Name: index_feedbacks_on_numeric_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_feedbacks_on_numeric_user_id ON public.feedbacks USING btree (numeric_user_id);


--
-- Name: index_feedbacks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_feedbacks_on_user_id ON public.feedbacks USING btree (user_id);


--
-- Name: index_identities_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_identities_on_id ON public.identities USING btree (id);


--
-- Name: index_identities_on_numeric_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_numeric_user_id ON public.identities USING btree (numeric_user_id);


--
-- Name: index_identities_on_uid_and_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_identities_on_uid_and_provider ON public.identities USING btree (uid, provider);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_user_id ON public.identities USING btree (user_id);


--
-- Name: index_ignores_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ignores_on_id ON public.ignores USING btree (id);


--
-- Name: index_insights_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insights_on_entity_id ON public.insights USING btree (entity_id);


--
-- Name: index_insights_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_insights_on_id ON public.insights USING btree (id);


--
-- Name: index_insights_on_insightable_id_and_insightable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insights_on_insightable_id_and_insightable_type ON public.insights USING btree (insightable_id, insightable_type);


--
-- Name: index_insights_on_numeric_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insights_on_numeric_entity_id ON public.insights USING btree (numeric_entity_id);


--
-- Name: index_insights_on_numeric_insightable_id_and_insightable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_insights_on_numeric_insightable_id_and_insightable_type ON public.insights USING btree (numeric_insightable_id, insightable_type);


--
-- Name: index_invites_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_invites_on_id ON public.invites USING btree (id);


--
-- Name: index_issue_comments_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_issue_comments_on_id ON public.issue_comments USING btree (id);


--
-- Name: index_issue_comments_on_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issue_comments_on_issue_id ON public.issue_comments USING btree (issue_id);


--
-- Name: index_issue_comments_on_numeric_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issue_comments_on_numeric_issue_id ON public.issue_comments USING btree (numeric_issue_id);


--
-- Name: index_issues_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_issues_on_id ON public.issues USING btree (id);


--
-- Name: index_issues_on_numeric_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_numeric_repository_id ON public.issues USING btree (numeric_repository_id);


--
-- Name: index_issues_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_repository_id ON public.issues USING btree (repository_id);


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
-- Name: index_kudos_users_achievements_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_users_achievements_on_user_id ON public.kudos_users_achievements USING btree (user_id);


--
-- Name: index_notifications_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_id ON public.notifications USING btree (id);


--
-- Name: index_notifications_on_notifyable_id_and_notifyable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_notifyable_id_and_notifyable_type ON public.notifications USING btree (notifyable_id, notifyable_type);


--
-- Name: index_notifications_on_webhook_id_and_notification_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_on_webhook_id_and_notification_type ON public.notifications USING btree (webhook_id, notification_type);


--
-- Name: index_pull_requests_comments_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_comments_on_entity_id ON public.pull_requests_comments USING btree (entity_id);


--
-- Name: index_pull_requests_comments_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_comments_on_external_id ON public.pull_requests_comments USING btree (external_id);


--
-- Name: index_pull_requests_comments_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_comments_on_id ON public.pull_requests_comments USING btree (id);


--
-- Name: index_pull_requests_comments_on_pull_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_comments_on_pull_request_id ON public.pull_requests_comments USING btree (pull_request_id);


--
-- Name: index_pull_requests_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_entity_id ON public.pull_requests USING btree (entity_id);


--
-- Name: index_pull_requests_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_id ON public.pull_requests USING btree (id);


--
-- Name: index_pull_requests_on_numeric_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_numeric_entity_id ON public.pull_requests USING btree (numeric_entity_id);


--
-- Name: index_pull_requests_on_numeric_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_numeric_repository_id ON public.pull_requests USING btree (numeric_repository_id);


--
-- Name: index_pull_requests_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_repository_id ON public.pull_requests USING btree (repository_id);


--
-- Name: index_pull_requests_reviews_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_reviews_on_entity_id ON public.pull_requests_reviews USING btree (entity_id);


--
-- Name: index_pull_requests_reviews_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_reviews_on_external_id ON public.pull_requests_reviews USING btree (external_id);


--
-- Name: index_pull_requests_reviews_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_reviews_on_id ON public.pull_requests_reviews USING btree (id);


--
-- Name: index_pull_requests_reviews_on_pull_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_reviews_on_pull_request_id ON public.pull_requests_reviews USING btree (pull_request_id);


--
-- Name: index_repositories_insights_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_insights_on_id ON public.repositories_insights USING btree (id);


--
-- Name: index_repositories_insights_on_numeric_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_insights_on_numeric_repository_id ON public.repositories_insights USING btree (numeric_repository_id);


--
-- Name: index_repositories_insights_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_insights_on_repository_id ON public.repositories_insights USING btree (repository_id);


--
-- Name: index_repositories_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_company_id ON public.repositories USING btree (company_id);


--
-- Name: index_repositories_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_id ON public.repositories USING btree (id);


--
-- Name: index_repositories_on_numeric_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_numeric_company_id ON public.repositories USING btree (numeric_company_id);


--
-- Name: index_subscribers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscribers_on_email ON public.subscribers USING btree (email);


--
-- Name: index_subscribers_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscribers_on_id ON public.subscribers USING btree (id);


--
-- Name: index_subscriptions_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscriptions_on_id ON public.subscriptions USING btree (id);


--
-- Name: index_subscriptions_on_numeric_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_numeric_user_id ON public.subscriptions USING btree (numeric_user_id);


--
-- Name: index_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_user_id ON public.subscriptions USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_id ON public.users USING btree (id);


--
-- Name: index_users_sessions_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_sessions_on_id ON public.users_sessions USING btree (id);


--
-- Name: index_users_sessions_on_numeric_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_sessions_on_numeric_user_id ON public.users_sessions USING btree (numeric_user_id);


--
-- Name: index_users_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_sessions_on_user_id ON public.users_sessions USING btree (user_id);


--
-- Name: index_vacations_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vacations_on_id ON public.vacations USING btree (id);


--
-- Name: index_vacations_on_numeric_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vacations_on_numeric_user_id ON public.vacations USING btree (numeric_user_id);


--
-- Name: index_vacations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vacations_on_user_id ON public.vacations USING btree (user_id);


--
-- Name: index_webhooks_on_company_id_and_source_and_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_webhooks_on_company_id_and_source_and_url ON public.webhooks USING btree (company_id, source, url);


--
-- Name: index_webhooks_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_webhooks_on_id ON public.webhooks USING btree (id);


--
-- Name: index_webhooks_on_numeric_company_id_and_source_and_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_webhooks_on_numeric_company_id_and_source_and_url ON public.webhooks USING btree (numeric_company_id, source, url);


--
-- Name: index_work_times_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_work_times_on_id ON public.work_times USING btree (id);


--
-- Name: index_work_times_on_worktimeable_id_and_worktimeable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_work_times_on_worktimeable_id_and_worktimeable_type ON public.work_times USING btree (worktimeable_id, worktimeable_type);


--
-- Name: kudos_users_achievements_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX kudos_users_achievements_unique_index ON public.kudos_users_achievements USING btree (numeric_user_id, kudos_achievement_id);


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
('20241207182227'),
('20241207181125'),
('20241207174751'),
('20241207174615'),
('20241021055406'),
('20241018121510'),
('20241018094904'),
('20241018090402'),
('20241018085327'),
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

