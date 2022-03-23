table! {
    event_log (id) {
        id -> Nullable<BigInt>,
        index -> Nullable<BigInt>,
        project_id -> Text,
        caller -> Text,
        event_key -> Text,
        event_value -> Text,
        timestamp -> Nullable<BigInt>,
    }
}

table! {
    event_log_v1 (id) {
        id -> Nullable<BigInt>,
        index -> Nullable<BigInt>,
        block -> Nullable<BigInt>,
        global_id -> Nullable<BigInt>,
        nonce -> Nullable<BigInt>,
        canister_id -> Text,
        caller -> Text,
        from_addr -> Text,
        to_addr -> Text,
        event_key -> Text,
        event_value -> Text,
        caller_time -> Nullable<BigInt>,
        ices_time -> Nullable<BigInt>,
    }
}


table! {
    project_info (id) {
        id -> Int4,
        project_id -> Varchar,
        project_name -> Varchar,
        app_id -> Nullable<Varchar>,
        app_secret -> Nullable<Varchar>,
        enable -> Bool,
    }
}

table! {
    user_log (id) {
        id ->  Nullable<BigInt>,
        index ->  Nullable<BigInt>,
        project_id -> Text,
        canister_id -> Text,
        caller -> Text,
        account_id -> Text,
        func_name -> Text,
        func_tag -> Text,
        timesstamp -> Nullable<BigInt>,
    }
}


allow_tables_to_appear_in_same_query!(event_log, project_info, user_log,);