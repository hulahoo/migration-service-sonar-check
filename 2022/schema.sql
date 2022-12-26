CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Если есть права на удаление БД:

-- DROP DATABASE IF EXISTS db;
-- CREATE DATABASE db
--    WITH
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'ru_RU.UTF-8@icu'
--     LC_CTYPE = 'ru_RU.UTF-8'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1
--     IS_TEMPLATE = False;
-- GRANT ALL ON DATABASE db TO postgres;
-- GRANT ALL ON DATABASE db TO dbuser;
-- GRANT TEMPORARY, CONNECT ON DATABASE db TO PUBLIC;

CREATE TABLE IF NOT EXISTS "users" (
    id         bigserial NOT NULL PRIMARY KEY,
    "login"    varchar(128) NOT NULL UNIQUE,
    pass_hash  varchar(256) NOT NULL,
    full_name  varchar(128) NOT NULL,
    "role"     varchar(128) NOT NULL,
    is_active  boolean NOT NULL default true,
    created_at timestamp with time zone NOT NULL,
    created_by bigint,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone NULL,
    created_by bigint NULL,
    last_login timestamp with time zone NULL,
    "admin"    boolean default false,
    staff      boolean default false
);
CREATE INDEX IF NOT EXISTS ix_user_login ON users ("login" text_pattern_ops);
CREATE INDEX IF NOT EXISTS ix_user_created_by ON users ("created_by");



CREATE TABLE IF NOT EXISTS "sessions" (
    id               bigserial NOT NULL PRIMARY KEY,
    user_id          bigint NOT NULL,
    access_token     varchar(255) NOT NULL,
    last_activity_at timestamp with time zone NOT NULL,
    created_at       timestamp with time zone NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_session_access_token ON sessions (access_token text_pattern_ops);



CREATE TABLE IF NOT EXISTS stat_received_objects (
    id         bigserial not null primary key,
    created_at timestamp with time zone NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_stat_received_object_created_at ON stat_received_objects (created_at);
CREATE INDEX IF NOT EXISTS ix_stat_received_object_id ON stat_received_objects (id);



CREATE TABLE IF NOT EXISTS stat_checked_objects (
    id         bigserial not null primary key,
    created_at timestamp with time zone NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_stat_checked_object_created_at ON stat_checked_objects (created_at);
CREATE INDEX IF NOT EXISTS ix_stat_checked_object_id ON stat_checked_objects (id);



CREATE TABLE IF NOT EXISTS stat_matched_objects (
    id           bigserial not null primary key,
    indicator_id uuid   not null,
    created_at   timestamp with time zone NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_stat_matched_object_created_at ON stat_matched_objects (created_at);
CREATE INDEX IF NOT EXISTS ix_stat_matched_object_indicator_id ON stat_matched_objects (indicator_id);
CREATE INDEX IF NOT EXISTS ix_stat_matched_object_id ON stat_matched_objects (id);



CREATE TABLE IF NOT EXISTS indicators
(
    id                        uuid default uuid_generate_v4() not null
                              constraint indicators_pkey
                              primary key,
    ioc_type                  varchar(32),
    value                     varchar(1024),
    context                   jsonb,
    is_sending_to_detections  boolean default true,
    is_false_positive         boolean default false,
    weight                    decimal,
    feeds_weight              decimal,
    tags_weight               decimal,
    time_weight               decimal,
    is_archived               boolean default false,
    false_detected_counter    bigint,
    positive_detected_counter bigint,
    total_detected_counter    bigint,
    first_detected_at         timestamp with time zone,
    last_detected_at          timestamp with time zone,
    created_by                bigint,
    created_at                timestamp with time zone,
    updated_at                timestamp with time zone,
    deleted_at                timestamp with time zone,
    constraint indicators_unique_value_type
        unique (value, ioc_type)
);
CREATE INDEX IF NOT EXISTS ix_indicator_id ON indicators (id);
CREATE INDEX IF NOT EXISTS ix_indicator_created_at ON indicators (created_at);



CREATE TABLE IF NOT EXISTS indicator_feed_relationships
(
    id           bigserial not null primary key,
    indicator_id uuid not null,
    feed_id      bigint not null,
    created_at   timestamp with time zone,
    deleted_at   timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_indicator_feed_relationships_id ON indicator_feed_relationships (id);
CREATE INDEX IF NOT EXISTS ix_indicator_feed_relationships_created_at ON indicator_feed_relationships (created_at);



CREATE TABLE IF NOT EXISTS processes
(
    id           bigserial not null primary key,
    parent_id    bigint null,
    service_name varchar(64),
    title        varchar(128),
    result       jsonb,
    status       varchar(32),
    started_at   timestamp with time zone,
    finished_at  timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_jobs_id ON processes (id);



CREATE TABLE IF NOT EXISTS feeds
(
    id                bigserial not null primary key,
    title             varchar(128),
    provider          varchar(128),
    description       varchar(255),
    format            varchar(8),
    url               varchar(255),
    auth_type         varchar(16),
    auth_api_token    varchar(255),
    auth_login        varchar(32),
    auth_pass         varchar(32),
    certificate       bytea,
    use_taxii         boolean default false,
    polling_frequency varchar(32),
    id_use            boolean default false,
    weight            decimal,
    available_fields  jsonb,
    parsing_rules     jsonb,
    status            varchar(32),
    is_active         boolean default true,
    is_truncating     boolean default true,
    max_records_count decimal,
    created_at        timestamp with time zone,
    updated_at        timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_feed_created_at ON feeds (created_at);
CREATE INDEX IF NOT EXISTS ix_feed_id ON feeds (id);



CREATE TABLE IF NOT EXISTS feeds_raw_data
(
    id         bigserial not null primary key,
    feed_id    bigint,
    filename   varchar(128),
    content    bytea,
    chunk      integer,
    created_at timestamp not null
);
CREATE INDEX IF NOT EXISTS ix_feed_raw_data_created_at ON feeds_raw_data (created_at);
CREATE INDEX IF NOT EXISTS ix_feed_raw_data_id ON feeds_raw_data (id);



CREATE TABLE IF NOT EXISTS tags
(
    id           bigserial not null primary key,
    title        varchar(128) unique,
    weight       decimal,
    created_at   timestamp with time zone,
    created_by   bigint,
    updated_at   timestamp with time zone,
    deleted_at   timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_tags_id ON tags (id);



CREATE TABLE IF NOT EXISTS indicator_tag_relationships
(
    id           bigserial not null primary key,
    indicator_id uuid,
    tag_id       bigint,
    created_at   timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_indicator_tag_relationships_id ON indicator_tag_relationships (id);



CREATE TABLE IF NOT EXISTS indicator_activities
(
    id             bigserial not null primary key,
    indicator_id   uuid,
    activity_type  varchar(64),
    details        jsonb,
    created_at     timestamp with time zone,
    created_by     bigint null
);
CREATE INDEX IF NOT EXISTS ix_indicator_activities_id ON indicator_activities (id);



CREATE TABLE IF NOT EXISTS detections
(
    id              bigserial not null primary key,
    source_event    jsonb,
    indicator_id    uuid,
    detection_event jsonb,
    tags_weight     bigint,
    created_at      timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_detections_id ON detections (id);



CREATE TABLE IF NOT EXISTS detection_tag_relationships
(
    id              bigserial not null primary key,
    detection_id    bigint,
    tag_id          bigint,
    created_at      timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_detection_tag_relationships_id ON detection_tag_relationships (id);



CREATE TABLE IF NOT EXISTS context_sources
(
    id                          bigserial not null primary key,
    ioc_type                    varchar(32) not null,
    source_url                  varchar(255) not null,
    request_method              varchar(16) not null,
    request_headers             text,
    request_body                text,
    inbound_removable_prefix    varchar(128),
    outbound_appendable_prefix  varchar(128),
    created_at                  timestamp with time zone,
    created_by                  bigint
);
CREATE INDEX IF NOT EXISTS ix_context_sources_id ON context_sources (id);



CREATE TABLE IF NOT EXISTS indicator_context_source_relationships
(
    id                 bigserial not null primary key,
    indicator_id       uuid,
    context_source_id  bigint,
    created_at         timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_indicator_context_source_relationships_id ON indicator_context_source_relationships (id);



CREATE TABLE IF NOT EXISTS search_history
(
    id                 bigserial not null primary key,
    search_type        varchar(64),
    query_text         varchar(255),
    query_data         bytea,
    results            jsonb,
    created_at         timestamp with time zone,
    created_by         bigint
);
CREATE INDEX IF NOT EXISTS ix_search_history_id ON search_history (id);



CREATE TABLE IF NOT EXISTS user_settings
(
    id                 bigserial not null primary key,
    user_id            bigint,
    key                varchar(128),
    value              jsonb,
    created_at         timestamp with time zone,
    updated_at         timestamp with time zone,
    created_by         bigint
);
CREATE INDEX IF NOT EXISTS ix_user_settings_id ON user_settings (id);



CREATE TABLE IF NOT EXISTS platform_settings
(
    id                 bigserial not null primary key,
    key                varchar(128),
    value              jsonb,
    created_at         timestamp with time zone,
    updated_at         timestamp with time zone,
    created_by         bigint
);
CREATE INDEX IF NOT EXISTS ix_platform_settings_id ON platform_settings (id);



CREATE TABLE IF NOT EXISTS audit_logs
(
    id                 bigserial not null primary key,
    service_name       varchar(128),
    user_id            bigint,
    event_type         varchar(128),
    object_type        varchar(128),
    object_name        varchar(128),
    description        varchar(256),
    prev_value         jsonb,
    new_value          jsonb,
    context            jsonb,
    created_at         timestamp with time zone
);
CREATE INDEX IF NOT EXISTS ix_audit_logs_id ON audit_logs (id);


-- Создание админа
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO "users" (
    login,
    pass_hash,
    full_name,
    role,
    is_active,
    created_at,
    updated_at
) VALUES (
    'admin',
    crypt('admin', 'admin'),
    'admin',
    'admin',
    True,
    '2022-12-21 10:10',
    '2022-12-21 10:10'
)
