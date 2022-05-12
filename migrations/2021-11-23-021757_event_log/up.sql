-- Your SQL goes here
CREATE TABLE "public"."t_event_logs_v1" (
  "id" bigserial PRIMARY KEY,
  "type" varchar(254) COLLATE "pg_catalog"."default",
  "block" int8,
  "global_id" varchar(254) COLLATE "pg_catalog"."default",
  "nonce" int8,
  "canister_id" varchar(254) COLLATE "pg_catalog"."default",
  "caller" varchar(254) COLLATE "pg_catalog"."default",
  "from_addr" varchar(254) COLLATE "pg_catalog"."default",
  "to_addr" varchar(254) COLLATE "pg_catalog"."default",
  "event_key" varchar(254) COLLATE "pg_catalog"."default",
  "event_value" text COLLATE "pg_catalog"."default",
  "caller_time" timestamp(6),
  "ices_time" timestamp(6),
  "index" int8
);