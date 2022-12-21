CREATE TABLE feeds
(
    id                serial not null
                      constraint feed_pkey
                      primary key,
    created_at        timestamp not null,
    title             varchar(128),
    provider          varchar(128),
    format            varchar(8),
    url               varchar(128),
    auth_type         varchar(16),
    auth_api_token    text,
    auth_login        varchar(32),
    auth_pass         varchar(32),
    certificate       text,
    use_taxii         boolean,
    polling_frequency varchar(32),
    weight            integer,
    parsing_rules     jsonb,
    is_active         boolean,
    updated_at        timestamp,
    status            varchar(32),
    is_truncating     boolean default false,
    max_records_count numeric
);

CREATE INDEX ix_feed_created_at
    ON feeds (created_at);

CREATE INDEX ix_feed_id
    ON feeds (id);

CREATE TABLE feeds_raw_data
(
    id         serial    not null
        constraint feed_raw_data_pkey
            primary key,
    created_at timestamp not null,
    feed_id    integer
        constraint feed_raw_data_feed_id_fkey
            references public.feeds,
    filename   varchar(128),
    content    bytea,
    chunk      integer
);

create index ix_feed_raw_data_created_at
    on feeds_raw_data (created_at);

create index ix_feed_raw_data_id
    on feeds_raw_data (id);

create table jobs
(
    id           bigserial not null
        constraint jobs_pkey
            primary key,
    service_name varchar(64),
    title        varchar(64),
    result       jsonb,
    status       varchar(16),
    started_at   timestamp,
    finished_at  timestamp
);

CREATE INDEX ix_jobs_id
    on jobs (id);

create table indicators
(
    created_at                timestamp                       not null,
    id                        uuid default uuid_generate_v4() not null
        constraint indicators_pkey
            primary key,
    ioc_type                  varchar(32),
    value                     varchar(1024),
    context                   jsonb,
    is_sending_to_detections  boolean,
    is_false_positive         boolean,
    ioc_weight                numeric,
    tags_weight               numeric,
    is_archived               boolean,
    false_detected_counter    integer,
    positive_detected_counter integer,
    total_detected_counter    integer,
    first_detected_at         timestamp,
    last_detected_at          timestamp,
    created_by                integer,
    updated_at                timestamp,
    constraint indicators_unique_value_type
        unique (value, ioc_type)
);

CREATE INDEX ix_indicators_created_at
    on indicators (created_at);

create table indicator_feed_relationships
(
    id           bigserial not null
        constraint indicator_feed_relationships_pkey
            primary key,
    created_at   timestamp not null,
    indicator_id uuid
        constraint indicator_feed_relationships_indicator_id_fkey
            references public.indicators
            on delete set null,
    feed_id      bigint
        constraint indicator_feed_relationships_feed_id_fkey
            references public.feeds
            on delete set null,
    deleted_at   timestamp
);

CREATE INDEX ix_indicator_feed_relationships_id
    on indicator_feed_relationships (id);

CREATE INDEX ix_indicator_feed_relationships_created_at
    on indicator_feed_relationships (created_at);





--
-- Create model Feed
--
CREATE TABLE "feeds" ("id" bigserial NOT NULL PRIMARY KEY, "created_at" timestamp with time zone NOT NULL, "updated_at" timestamp with time zone NOT NULL, "title" text NOT NULL UNIQUE, "provider" text NOT NULL, "description" text NULL, "format" text NOT NULL, "url" text NOT NULL, "auth_type" text NULL, "auth_api_token" text NOT NULL, "auth_login" text NOT NULL, "auth_pass" text NOT NULL, "certificate" bytea NOT NULL, "use_taxii" boolean NULL, "polling_frequency" text NOT NULL, "weight" numeric(6, 3) NOT NULL, "available_fields" jsonb NOT NULL, "parsing_rules" jsonb NULL, "status" text NOT NULL, "is_active" boolean NOT NULL, "is_truncating" boolean NOT NULL, "max_records_count" numeric(20, 5) NOT NULL);
CREATE TABLE "feeds_indicators" ("id" bigserial NOT NULL PRIMARY KEY, "feed_id" bigint NOT NULL, "indicator_id" varchar(36) NOT NULL);
CREATE INDEX "feeds_title_990d141d_like" ON "feeds" ("title" text_pattern_ops);
ALTER TABLE "feeds_indicators" ADD CONSTRAINT "feeds_indicators_feed_id_indicator_id_4b66f315_uniq" UNIQUE ("feed_id", "indicator_id");
ALTER TABLE "feeds_indicators" ADD CONSTRAINT "feeds_indicators_feed_id_1104169b_fk_feeds_id" FOREIGN KEY ("feed_id") REFERENCES "feeds" ("id") DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "feeds_indicators" ADD CONSTRAINT "feeds_indicators_indicator_id_5bc00a4b_fk_indicators_id" FOREIGN KEY ("indicator_id") REFERENCES "indicators" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "feeds_indicators_feed_id_1104169b" ON "feeds_indicators" ("feed_id");
CREATE INDEX "feeds_indicators_indicator_id_5bc00a4b" ON "feeds_indicators" ("indicator_id");
CREATE INDEX "feeds_indicators_indicator_id_5bc00a4b_like" ON "feeds_indicators" ("indicator_id" varchar_pattern_ops);
COMMIT;

BEGIN;
--
-- Create model IndicatorFeedRelationship
--
CREATE TABLE "indicator_feed_relationships" ("id" bigserial NOT NULL PRIMARY KEY, "updated_at" timestamp with time zone NOT NULL, "created_at" timestamp with time zone NOT NULL, "deleted_at" timestamp with time zone NULL, "indicator_id_id" varchar(36) NOT NULL);
--
-- Remove field indicators from feed
--
DROP TABLE "feeds_indicators" CASCADE;
--
-- Add field indicators to feed
--
--
-- Add field feed to indicatorfeedrelationship
--
ALTER TABLE "indicator_feed_relationships" ADD COLUMN "feed_id" bigint NOT NULL CONSTRAINT "indicator_feed_relationships_feed_id_1867b37c_fk_feeds_id" REFERENCES "feeds"("id") DEFERRABLE INITIALLY DEFERRED; SET CONSTRAINTS "indicator_feed_relationships_feed_id_1867b37c_fk_feeds_id" IMMEDIATE;
--
-- Rename field indicator_id on indicatorfeedrelationship to indicator
--
ALTER TABLE "indicator_feed_relationships" RENAME COLUMN "indicator_id_id" TO "indicator_id";
--
-- Remove field updated_at from indicatorfeedrelationship
--
ALTER TABLE "indicator_feed_relationships" DROP COLUMN "updated_at" CASCADE;
ALTER TABLE "indicator_feed_relationships" ADD CONSTRAINT "indicator_feed_relat_indicator_id_53950c25_fk_indicator" FOREIGN KEY ("indicator_id") REFERENCES "indicators" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "indicator_feed_relationships_indicator_id_53950c25" ON "indicator_feed_relationships" ("indicator_id");
CREATE INDEX "indicator_feed_relationships_indicator_id_53950c25_like" ON "indicator_feed_relationships" ("indicator_id" varchar_pattern_ops);
CREATE INDEX "indicator_feed_relationships_feed_id_1867b37c" ON "indicator_feed_relationships" ("feed_id");
COMMIT;

BEGIN;
--
-- Create model Indicator
--
CREATE TABLE "indicators" ("created_at" timestamp with time zone NOT NULL, "updated_at" timestamp with time zone NOT NULL, "id" varchar(36) NOT NULL PRIMARY KEY, "ioc_type" varchar(32) NOT NULL, "value" varchar(512) NOT NULL, "context" jsonb NOT NULL, "is_sending_to_detections" boolean NOT NULL, "is_false_positive" boolean NOT NULL, "weight" numeric(6, 3) NOT NULL, "tags_weight" numeric(6, 3) NOT NULL, "is_archived" boolean NOT NULL, "false_detected_counter" bigint NOT NULL, "positive_detected_counter" bigint NOT NULL, "total_detected_counter" bigint NOT NULL, "first_detected_at" timestamp with time zone NOT NULL, "last_detected_at" timestamp with time zone NOT NULL, "created_by_id" bigint NULL);
--
-- Create model Session
--
CREATE TABLE "sessions" ("id" bigserial NOT NULL PRIMARY KEY, "access_token" varchar(255) NOT NULL, "last_activity_at" timestamp with time zone NOT NULL, "created_at" timestamp with time zone NOT NULL, "user_id_id" bigint NOT NULL);
--
-- Create model IndicatorActivities
--
CREATE TABLE "activities" ("id" bigserial NOT NULL PRIMARY KEY, "created_at" timestamp with time zone NOT NULL, "updated_at" timestamp with time zone NOT NULL, "type" varchar(50) NOT NULL, "details" jsonb NOT NULL, "indicator_id" varchar(36) NOT NULL);
ALTER TABLE "indicators" ADD CONSTRAINT "indicators_ioc_type_value_41d377bc_uniq" UNIQUE ("ioc_type", "value");
ALTER TABLE "indicators" ADD CONSTRAINT "indicators_created_by_id_1b25a4eb_fk_users_id" FOREIGN KEY ("created_by_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "indicators_id_bea8fe23_like" ON "indicators" ("id" varchar_pattern_ops);
CREATE INDEX "indicators_created_by_id_1b25a4eb" ON "indicators" ("created_by_id");
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_id_38efddc1_fk_users_id" FOREIGN KEY ("user_id_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "sessions_user_id_id_38efddc1" ON "sessions" ("user_id_id");
ALTER TABLE "activities" ADD CONSTRAINT "activities_indicator_id_7ecc5c5e_fk_indicators_id" FOREIGN KEY ("indicator_id") REFERENCES "indicators" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "activities_indicator_id_7ecc5c5e" ON "activities" ("indicator_id");
CREATE INDEX "activities_indicator_id_7ecc5c5e_like" ON "activities" ("indicator_id" varchar_pattern_ops);
COMMIT;


BEGIN;
--
-- Change Meta options on indicatoractivities
--
--
-- Remove field updated_at from indicatoractivities
--
ALTER TABLE "activities" DROP COLUMN "updated_at" CASCADE;
--
-- Add field created_by to indicatoractivities
--
ALTER TABLE "activities" ADD COLUMN "created_by_id" bigint NOT NULL CONSTRAINT "activities_created_by_id_8862b97d_fk_users_id" REFERENCES "users"("id") DEFERRABLE INITIALLY DEFERRED; SET CONSTRAINTS "activities_created_by_id_8862b97d_fk_users_id" IMMEDIATE;
--
-- Alter field created_at on indicatoractivities
--
--
-- Alter field type on indicatoractivities
--
ALTER TABLE "activities" ALTER COLUMN "type" TYPE text USING "type"::text;
--
-- Rename table for indicatoractivities to indicator_activities
--
ALTER TABLE "activities" RENAME TO "indicator_activities";
--
-- Alter field access_token on session
--
ALTER TABLE "sessions" ALTER COLUMN "access_token" TYPE text USING "access_token"::text;
CREATE INDEX "indicator_activities_created_by_id_a9892b79" ON "indicator_activities" ("created_by_id");
COMMIT;


BEGIN;
--
-- Create model Source
--
CREATE TABLE "sources" ("id" bigserial NOT NULL PRIMARY KEY, "created_at" timestamp with time zone NOT NULL, "updated_at" timestamp with time zone NOT NULL, "name" varchar(255) NOT NULL UNIQUE, "is_instead_full" boolean NOT NULL, "is_active" boolean NOT NULL, "provider_name" varchar(255) NOT NULL, "path" text NOT NULL, "certificate" varchar(100) NULL, "authenticity" integer NOT NULL, "format" varchar(17) NOT NULL, "auth_type" varchar(17) NOT NULL, "auth_login" varchar(32) NULL, "auth_password" varchar(64) NULL, "max_rows" integer NULL, "raw_indicators" text NULL, "update_time_period" bigint NOT NULL CHECK ("update_time_period" >= 0));
CREATE INDEX "sources_name_94ff009b_like" ON "sources" ("name" varchar_pattern_ops);
COMMIT;


BEGIN;
--
-- Create model Tag
--
CREATE TABLE "tags" ("id" bigserial NOT NULL PRIMARY KEY, "created_at" timestamp with time zone NOT NULL, "updated_at" timestamp with time zone NOT NULL, "title" text NOT NULL UNIQUE, "weight" numeric(6, 3) NULL, "deleted_at" timestamp with time zone NULL, "created_by_id" bigint NOT NULL);
ALTER TABLE "tags" ADD CONSTRAINT "tags_created_by_id_bc2c5343_fk_users_id" FOREIGN KEY ("created_by_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "tags_title_14a4130c_like" ON "tags" ("title" text_pattern_ops);
CREATE INDEX "tags_created_by_id_bc2c5343" ON "tags" ("created_by_id");
COMMIT;



BEGIN;
--
-- Alter field created_at on tag
--
--
-- Alter field updated_at on tag
--
COMMIT;


BEGIN;
--
-- Create model IndicatorTagRelationship
--
CREATE TABLE "indicator_tag_relationships" ("id" bigserial NOT NULL PRIMARY KEY, "created_at" timestamp with time zone NOT NULL, "deleted_at" timestamp with time zone NULL, "indicator_id" varchar(36) NOT NULL);
--
-- Add field indicators to tag
--
--
-- Add field tag to indicatortagrelationship
--
ALTER TABLE "indicator_tag_relationships" ADD COLUMN "tag_id" bigint NOT NULL CONSTRAINT "indicator_tag_relationships_tag_id_41eb5122_fk_tags_id" REFERENCES "tags"("id") DEFERRABLE INITIALLY DEFERRED; SET CONSTRAINTS "indicator_tag_relationships_tag_id_41eb5122_fk_tags_id" IMMEDIATE;
ALTER TABLE "indicator_tag_relationships" ADD CONSTRAINT "indicator_tag_relati_indicator_id_0e19c41d_fk_indicator" FOREIGN KEY ("indicator_id") REFERENCES "indicators" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "indicator_tag_relationships_indicator_id_0e19c41d" ON "indicator_tag_relationships" ("indicator_id");
CREATE INDEX "indicator_tag_relationships_indicator_id_0e19c41d_like" ON "indicator_tag_relationships" ("indicator_id" varchar_pattern_ops);
CREATE INDEX "indicator_tag_relationships_tag_id_41eb5122" ON "indicator_tag_relationships" ("tag_id");
COMMIT;


BEGIN;
--
-- Create model User
--
CREATE TABLE "users" ("id" bigserial NOT NULL PRIMARY KEY, "last_login" timestamp with time zone NULL, "login" text NOT NULL UNIQUE, "pass_hash" text NOT NULL, "full_name" text NOT NULL, "role" text NOT NULL, "is_active" boolean NOT NULL, "created_at" timestamp with time zone NOT NULL, "updated_at" timestamp with time zone NOT NULL, "deleted_at" timestamp with time zone NULL, "staff" boolean NOT NULL, "admin" boolean NOT NULL, "created_by" bigint NULL);
ALTER TABLE "users" ADD CONSTRAINT "users_created_by_0c0a4e75_fk_users_id" FOREIGN KEY ("created_by") REFERENCES "users" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "users_login_3b007138_like" ON "users" ("login" text_pattern_ops);
CREATE INDEX "users_created_by_0c0a4e75" ON "users" ("created_by");
COMMIT;



