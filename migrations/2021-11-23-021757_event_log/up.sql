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



-- ----------------------------
-- View structure for v1_caller_event_count_3m
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_caller_event_count_3m";
CREATE VIEW "public"."v1_caller_event_count_3m" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.caller
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '89 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.id) AS counts,
            t_event_logs_v1.caller
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.caller, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_caller_event_count_3m" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_caller_count_7d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_caller_count_7d";
CREATE VIEW "public"."v1_all_caller_count_7d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '6 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.caller) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_caller_count_7d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_canister_count_7d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_canister_count_7d";
CREATE VIEW "public"."v1_all_canister_count_7d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '6 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.canister_id) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_canister_count_7d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_event_count_7d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_event_count_7d";
CREATE VIEW "public"."v1_all_event_count_7d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '6 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(t_event_logs_v1.id) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_event_count_7d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_caller_count_7d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_caller_count_7d";
CREATE VIEW "public"."v1_canister_caller_count_7d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '6 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.caller) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_canister_caller_count_7d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_caller_count_all
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_caller_count_all";
CREATE VIEW "public"."v1_canister_caller_count_all" AS  SELECT count(DISTINCT t.caller) AS counts,
    t.canister_id
   FROM t_event_logs_v1 t
  GROUP BY t.canister_id;
ALTER TABLE "public"."v1_canister_caller_count_all" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_event_count_7d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_event_count_7d";
CREATE VIEW "public"."v1_canister_event_count_7d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '6 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(t_event_logs_v1.id) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_canister_event_count_7d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_event_key_group
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_event_key_group";
CREATE VIEW "public"."v1_canister_event_key_group" AS  SELECT t.event_key,
    t.canister_id
   FROM t_event_logs_v1 t
  GROUP BY t.canister_id, t.event_key;
ALTER TABLE "public"."v1_canister_event_key_group" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_caller_event_count_7d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_caller_event_count_7d";
CREATE VIEW "public"."v1_caller_event_count_7d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.caller
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '6 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.id) AS counts,
            t_event_logs_v1.caller
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.caller, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_caller_event_count_7d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_caller_count_30d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_caller_count_30d";
CREATE VIEW "public"."v1_all_caller_count_30d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '29 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.caller) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_caller_count_30d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_canister_count_30d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_canister_count_30d";
CREATE VIEW "public"."v1_all_canister_count_30d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '29 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.canister_id) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_canister_count_30d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_event_count_30d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_event_count_30d";
CREATE VIEW "public"."v1_all_event_count_30d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '29 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(t_event_logs_v1.id) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_event_count_30d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_caller_event_count_30d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_caller_event_count_30d";
CREATE VIEW "public"."v1_caller_event_count_30d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.caller
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '29 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.id) AS counts,
            t_event_logs_v1.caller
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.caller, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_caller_event_count_30d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_caller_count_30d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_caller_count_30d";
CREATE VIEW "public"."v1_canister_caller_count_30d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '29 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.caller) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_canister_caller_count_30d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_event_count_30d
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_event_count_30d";
CREATE VIEW "public"."v1_canister_event_count_30d" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '29 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(t_event_logs_v1.id) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_canister_event_count_30d" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_caller_event_count_24h
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_caller_event_count_24h";
CREATE VIEW "public"."v1_caller_event_count_24h" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.caller
   FROM ( SELECT to_char(generate_series(CURRENT_DATE::timestamp without time zone, CURRENT_DATE + '23:00:00'::interval, '01:00:00'::interval), 'yyyy-MM-dd HH24'::text) AS "time") a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text) AS "time",
            count(DISTINCT t_event_logs_v1.id) AS counts,
            t_event_logs_v1.caller
           FROM t_event_logs_v1
          WHERE t_event_logs_v1.ices_time >= CURRENT_DATE AND t_event_logs_v1.ices_time <= (CURRENT_DATE + '1 day'::interval)
          GROUP BY (to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text)), t_event_logs_v1.caller) c ON a."time" = c."time";
ALTER TABLE "public"."v1_caller_event_count_24h" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_caller_count_24h
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_caller_count_24h";
CREATE VIEW "public"."v1_canister_caller_count_24h" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(generate_series(CURRENT_DATE::timestamp without time zone, CURRENT_DATE + '23:00:00'::interval, '01:00:00'::interval), 'yyyy-MM-dd HH24'::text) AS "time") a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text) AS "time",
            count(DISTINCT t_event_logs_v1.caller) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          WHERE t_event_logs_v1.ices_time >= CURRENT_DATE AND t_event_logs_v1.ices_time <= (CURRENT_DATE + '1 day'::interval)
          GROUP BY (to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text)), t_event_logs_v1.canister_id) c ON a."time" = c."time";
ALTER TABLE "public"."v1_canister_caller_count_24h" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_event_count_24h
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_event_count_24h";
CREATE VIEW "public"."v1_canister_event_count_24h" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(generate_series(CURRENT_DATE::timestamp without time zone, CURRENT_DATE + '23:00:00'::interval, '01:00:00'::interval), 'yyyy-MM-dd HH24'::text) AS "time") a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text) AS "time",
            count(t_event_logs_v1.id) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          WHERE t_event_logs_v1.ices_time >= CURRENT_DATE AND t_event_logs_v1.ices_time <= (CURRENT_DATE + '1 day'::interval)
          GROUP BY (to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text)), t_event_logs_v1.canister_id) c ON a."time" = c."time";
ALTER TABLE "public"."v1_canister_event_count_24h" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_caller_count_1y
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_caller_count_1y";
CREATE VIEW "public"."v1_all_caller_count_1y" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '364 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.caller) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_caller_count_1y" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_canister_count_24h
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_canister_count_24h";
CREATE VIEW "public"."v1_all_canister_count_24h" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(generate_series(CURRENT_DATE::timestamp without time zone, CURRENT_DATE + '23:00:00'::interval, '01:00:00'::interval), 'yyyy-MM-dd HH24'::text) AS "time") a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text) AS "time",
            count(DISTINCT t_event_logs_v1.canister_id) AS counts
           FROM t_event_logs_v1
          WHERE t_event_logs_v1.ices_time >= CURRENT_DATE AND t_event_logs_v1.ices_time <= (CURRENT_DATE + '1 day'::interval)
          GROUP BY (to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text)), t_event_logs_v1.canister_id) c ON a."time" = c."time";
ALTER TABLE "public"."v1_all_canister_count_24h" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_event_count_24h
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_event_count_24h";
CREATE VIEW "public"."v1_all_event_count_24h" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(generate_series(CURRENT_DATE::timestamp without time zone, CURRENT_DATE + '23:00:00'::interval, '01:00:00'::interval), 'yyyy-MM-dd HH24'::text) AS "time") a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text) AS "time",
            count(t_event_logs_v1.ices_time) AS counts
           FROM t_event_logs_v1
          WHERE t_event_logs_v1.ices_time >= CURRENT_DATE AND t_event_logs_v1.ices_time <= (CURRENT_DATE + '1 day'::interval)
          GROUP BY (to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text))) c ON a."time" = c."time";
ALTER TABLE "public"."v1_all_event_count_24h" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_caller_count_24h
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_caller_count_24h";
CREATE VIEW "public"."v1_all_caller_count_24h" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(generate_series(CURRENT_DATE::timestamp without time zone, CURRENT_DATE + '23:00:00'::interval, '01:00:00'::interval), 'yyyy-MM-dd HH24'::text) AS "time") a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text) AS "time",
            count(DISTINCT t_event_logs_v1.caller) AS counts
           FROM t_event_logs_v1
          WHERE t_event_logs_v1.ices_time >= CURRENT_DATE AND t_event_logs_v1.ices_time <= (CURRENT_DATE + '1 day'::interval)
          GROUP BY (to_char(t_event_logs_v1.ices_time, 'yyyy-mm-dd HH24'::text))) c ON a."time" = c."time";
ALTER TABLE "public"."v1_all_caller_count_24h" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_canister_count_3m
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_canister_count_3m";
CREATE VIEW "public"."v1_all_canister_count_3m" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '89 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.canister_id) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_canister_count_3m" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_caller_count_3m
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_caller_count_3m";
CREATE VIEW "public"."v1_all_caller_count_3m" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '89 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.caller) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_caller_count_3m" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_canister_count_1y
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_canister_count_1y";
CREATE VIEW "public"."v1_all_canister_count_1y" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '364 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.canister_id) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_canister_count_1y" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_event_count_1y
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_event_count_1y";
CREATE VIEW "public"."v1_all_event_count_1y" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '364 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(t_event_logs_v1.id) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_event_count_1y" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_event_count_3m
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_event_count_3m";
CREATE VIEW "public"."v1_all_event_count_3m" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '89 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(t_event_logs_v1.id) AS counts
           FROM t_event_logs_v1
          GROUP BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_all_event_count_3m" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_caller_event_count_1y
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_caller_event_count_1y";
CREATE VIEW "public"."v1_caller_event_count_1y" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.caller
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '364 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.id) AS counts,
            t_event_logs_v1.caller
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.caller, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_caller_event_count_1y" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_caller_count_3m
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_caller_count_3m";
CREATE VIEW "public"."v1_canister_caller_count_3m" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '89 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.caller) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_canister_caller_count_3m" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_caller_count_1y
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_caller_count_1y";
CREATE VIEW "public"."v1_canister_caller_count_1y" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '364 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(DISTINCT t_event_logs_v1.caller) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_canister_caller_count_1y" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_event_count_3m
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_event_count_3m";
CREATE VIEW "public"."v1_canister_event_count_3m" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '89 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(t_event_logs_v1.id) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_canister_event_count_3m" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_event_count_1y
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_event_count_1y";
CREATE VIEW "public"."v1_canister_event_count_1y" AS  SELECT a."time",
    COALESCE(c.counts, 0::bigint) AS counts,
    c.canister_id
   FROM ( SELECT to_char(b.b, 'YYYY-MM-DD'::text) AS "time"
           FROM generate_series(CURRENT_TIMESTAMP - '364 days'::interval, CURRENT_TIMESTAMP, '1 day'::interval) b(b)
          GROUP BY (to_char(b.b, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(b.b, 'YYYY-MM-DD'::text))) a
     LEFT JOIN ( SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text) AS event_date,
            count(t_event_logs_v1.id) AS counts,
            t_event_logs_v1.canister_id
           FROM t_event_logs_v1
          GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))
          ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM-DD'::text))) c ON a."time" = c.event_date;
ALTER TABLE "public"."v1_canister_event_count_1y" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_caller_count_all
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_caller_count_all";
CREATE VIEW "public"."v1_all_caller_count_all" AS  SELECT count(DISTINCT t.caller) AS counts
   FROM t_event_logs_v1 t;
ALTER TABLE "public"."v1_all_caller_count_all" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_event_count_all
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_event_count_all";
CREATE VIEW "public"."v1_all_event_count_all" AS  SELECT count(*) AS counts
   FROM t_event_logs_v1;
ALTER TABLE "public"."v1_all_event_count_all" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_all_canister_count_all
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_all_canister_count_all";
CREATE VIEW "public"."v1_all_canister_count_all" AS  SELECT count(DISTINCT t.canister_id) AS counts
   FROM t_event_logs_v1 t;
ALTER TABLE "public"."v1_all_canister_count_all" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_canister_event_count_all
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_canister_event_count_all";
CREATE VIEW "public"."v1_canister_event_count_all" AS  SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM'::text) AS "time",
    count(t_event_logs_v1.id) AS counts,
    t_event_logs_v1.canister_id
   FROM t_event_logs_v1
  GROUP BY t_event_logs_v1.canister_id, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM'::text))
  ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM'::text));
ALTER TABLE "public"."v1_canister_event_count_all" OWNER TO "postgres";

-- ----------------------------
-- View structure for v1_caller_event_count_all
-- ----------------------------
DROP VIEW IF EXISTS "public"."v1_caller_event_count_all";
CREATE VIEW "public"."v1_caller_event_count_all" AS  SELECT to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM'::text) AS "time",
    count(DISTINCT t_event_logs_v1.id) AS counts,
    t_event_logs_v1.caller
   FROM t_event_logs_v1
  GROUP BY t_event_logs_v1.caller, (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM'::text))
  ORDER BY (to_char(t_event_logs_v1.ices_time::timestamp with time zone, 'YYYY-MM'::text));
ALTER TABLE "public"."v1_caller_event_count_all" OWNER TO "postgres";

