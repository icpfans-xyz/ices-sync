-- Your SQL goes here
CREATE TABLE event_log (
    id BIGSERIAL PRIMARY KEY,
    index INT8 NOT NULL,
    project_id VARCHAR NOT NULL,
    caller VARCHAR,
    event_key VARCHAR,
    event_value text,
    timestamp INT8,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(0)
);