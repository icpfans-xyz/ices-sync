-- Your SQL goes here
CREATE TABLE project_info (
    id SERIAL PRIMARY KEY,
    project_id VARCHAR NOT NULL,
    project_name VARCHAR NOT NULL,
    app_id VARCHAR,
    app_secret VARCHAR,
    enable BOOLEAN NOT NULL DEFAULT true
);