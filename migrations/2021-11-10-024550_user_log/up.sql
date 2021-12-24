-- Your SQL goes here
CREATE TABLE user_log (
    id BIGSERIAL PRIMARY KEY,
    index INT8 NOT NULL,
    project_id VARCHAR NOT NULL,
    canister_id VARCHAR,
    caller VARCHAR,
    account_id VARCHAR,
    func_name VARCHAR,
    func_tag VARCHAR,
    timesstamp INT8,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(0)
);