table! {
    t_event_logs_v1 (id) {
        id -> Int8,
        #[sql_name = "type"]
        type_ -> Nullable<Varchar>,
        block -> Nullable<Int8>,
        global_id -> Nullable<Varchar>,
        nonce -> Nullable<Int8>,
        canister_id -> Nullable<Varchar>,
        caller -> Nullable<Varchar>,
        from_addr -> Nullable<Varchar>,
        to_addr -> Nullable<Varchar>,
        event_key -> Nullable<Varchar>,
        event_value -> Nullable<Text>,
        caller_time -> Nullable<Timestamp>,
        ices_time -> Nullable<Timestamp>,
        index -> Nullable<Int8>,
    }
}
