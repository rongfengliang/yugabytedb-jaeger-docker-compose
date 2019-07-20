
CREATE KEYSPACE IF NOT EXISTS jaeger_v1_test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};

use jaeger_v1_test;
CREATE TYPE IF NOT EXISTS jaeger_v1_test.keyvalue (
    key             text,
    value_type      text,
    value_string    text,
    value_bool      boolean,
    value_long      bigint,
    value_double    double,
    value_binary    blob
);

CREATE TYPE IF NOT EXISTS jaeger_v1_test.log (
    ts   bigint,
    fields list<frozen<keyvalue>>
);

CREATE TYPE IF NOT EXISTS jaeger_v1_test.span_ref (
    ref_type        text,
    trace_id        blob,
    span_id         bigint
);

CREATE TYPE IF NOT EXISTS jaeger_v1_test.process (
    service_name    text,
    tags            list<frozen<keyvalue>>
);

CREATE TABLE IF NOT EXISTS jaeger_v1_test.traces (
    trace_id        blob,
    span_id         bigint,
    span_hash       bigint,
    parent_id       bigint,
    operation_name  text,
    flags           int,
    start_time      bigint,
    duration        bigint,
    tags            list<frozen<keyvalue>>,
    logs            list<frozen<log>>,
    refs            list<frozen<span_ref>>,
    process         frozen<process>,
    PRIMARY KEY (trace_id, span_id, span_hash)
)
    WITH compaction = {
        'compaction_window_size': '1',
        'compaction_window_unit': 'HOURS',
        'class': 'org.apache.cassandra.db.compaction.TimeWindowCompactionStrategy'
    }
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 172800
    AND speculative_retry = 'NONE'
    AND gc_grace_seconds = 10800; 

CREATE TABLE IF NOT EXISTS jaeger_v1_test.service_names (
    service_name text,
    PRIMARY KEY (service_name)
)
    WITH compaction = {
        'min_threshold': '4',
        'max_threshold': '32',
        'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy'
    }
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 172800
    AND speculative_retry = 'NONE'
    AND gc_grace_seconds = 10800; 

CREATE TABLE IF NOT EXISTS jaeger_v1_test.operation_names (
    service_name        text,
    operation_name      text,
    PRIMARY KEY ((service_name), operation_name)
)
    WITH compaction = {
        'min_threshold': '4',
        'max_threshold': '32',
        'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy'
    }
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 172800
    AND speculative_retry = 'NONE'
    AND gc_grace_seconds = 10800; 

CREATE TABLE IF NOT EXISTS jaeger_v1_test.service_operation_index (
    service_name        text,
    operation_name      text,
    start_time          bigint,
    trace_id            blob,
    PRIMARY KEY ((service_name, operation_name), start_time)
) WITH CLUSTERING ORDER BY (start_time DESC)
    AND compaction = {
        'compaction_window_size': '1',
        'compaction_window_unit': 'HOURS',
        'class': 'org.apache.cassandra.db.compaction.TimeWindowCompactionStrategy'
    }
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 172800
    AND speculative_retry = 'NONE'
    AND gc_grace_seconds = 10800; 

CREATE TABLE IF NOT EXISTS jaeger_v1_test.service_name_index (
    service_name      text,
    bucket            int,
    start_time        bigint,
    trace_id          blob,
    PRIMARY KEY ((service_name, bucket), start_time)
) WITH CLUSTERING ORDER BY (start_time DESC)
    AND compaction = {
        'compaction_window_size': '1',
        'compaction_window_unit': 'HOURS',
        'class': 'org.apache.cassandra.db.compaction.TimeWindowCompactionStrategy'
    }
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 172800
    AND speculative_retry = 'NONE'
    AND gc_grace_seconds = 10800; 

CREATE TABLE IF NOT EXISTS jaeger_v1_test.duration_index (
    service_name    text,       
    operation_name  text,
    bucket          timestamp,  
    duration        bigint, 
    start_time      bigint,
    trace_id        blob,
    PRIMARY KEY ((service_name, operation_name, bucket), duration, start_time, trace_id)
) WITH CLUSTERING ORDER BY (duration DESC, start_time DESC)
    AND compaction = {
        'compaction_window_size': '1',
        'compaction_window_unit': 'HOURS',
        'class': 'org.apache.cassandra.db.compaction.TimeWindowCompactionStrategy'
    }
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 172800
    AND speculative_retry = 'NONE'
    AND gc_grace_seconds = 10800; 

CREATE TABLE IF NOT EXISTS jaeger_v1_test.tag_index (
    service_name    text,
    tag_key         text,
    tag_value       text,
    start_time      bigint,
    trace_id        blob,
    span_id         bigint,
    PRIMARY KEY ((service_name, tag_key, tag_value), start_time, trace_id, span_id)
)
    WITH CLUSTERING ORDER BY (start_time DESC)
    AND compaction = {
        'compaction_window_size': '1',
        'compaction_window_unit': 'HOURS',
        'class': 'org.apache.cassandra.db.compaction.TimeWindowCompactionStrategy'
    }
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 172800
    AND speculative_retry = 'NONE'
    AND gc_grace_seconds = 10800; 

CREATE TYPE IF NOT EXISTS jaeger_v1_test.dependency (
    parent          text,
    child           text,
    call_count      bigint,
    source          text
);

CREATE TABLE IF NOT EXISTS jaeger_v1_test.dependencies_v2 (
    ts_bucket    timestamp,
    ts           timestamp,
    dependencies list<frozen<dependency>>,
    PRIMARY KEY (ts_bucket, ts)
) WITH CLUSTERING ORDER BY (ts DESC)
    AND compaction = {
        'min_threshold': '4',
        'max_threshold': '32',
        'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy'
    }
    AND default_time_to_live = 0;
