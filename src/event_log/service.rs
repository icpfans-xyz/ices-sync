use crate::connection;
use crate::ic::canister;
use candid::{CandidType, Decode, Encode, Int, Nat, IDLArgs};
use diesel::prelude::*;
use diesel::query_dsl::QueryDsl;
use log::{error, info};
use serde::Deserialize;
use std::convert::TryFrom;
use chrono::{Utc, DateTime, TimeZone, NaiveDateTime};

#[derive(Debug, Clone, Queryable, Insertable)]
#[table_name = "event_log"]
pub struct EventLog {
    pub id: Option<i64>,
    pub index: Option<i64>,
    pub project_id: String,
    pub caller: String,
    pub event_key: String,
    pub event_value: String,
    pub timestamp: Option<i64>,
    pub time: Option<NaiveDateTime>,
    
}

#[derive(CandidType, Deserialize)]
pub struct EventLogResult {
    pub index: Nat,
    pub projectId: String,
    pub caller: String,
    pub eventKey: String,
    pub eventValue: Vec<String>,
    pub timestamp: Int,
}

table! {
    event_log (id) {
        id -> Nullable<BigInt>,
        index -> Nullable<BigInt>,
        project_id -> Text,
        caller -> Text,
        event_key -> Text,
        event_value -> Text,
        timestamp -> Nullable<BigInt>,
        time -> Nullable<Timestamp>,
    }
}


pub async fn sync_canister_event() -> () {
    info!("user service start");
    let size = 10;
    let db_index = get_last_index();
    let latest_index = db_index + 1 ;
    info!("index_nat:{},size_nat:{}", &latest_index, &size);
    let method_name = String::from("getEventLogs");
    // last record index
    let text_value = format!("({}:nat, {}:nat)", latest_index, size);
    let args: IDLArgs = text_value.parse().expect("Error IDLArgs params");
    let params: Vec<u8> = args.to_bytes().expect("Error Encode params");
    // let params = &Encode!(&Nat::from(latest_index), &Nat::from(size)).expect("Error Encode params");
    let response = canister::update_call(&method_name, &params).await;
    match response {
        Ok(reply) => {
            // let json = String::from_utf8_lossy(&reply).to_string();
            let event_logs = Decode!(reply.as_slice(), Vec<EventLogResult>)
                .expect("Error Decode canister result");
            for u in event_logs.iter() {
                let bytes =
                    Encode!(&u.index, &u.timestamp).expect("Error Encode canister result to byte");
                let (c_index, c_time) =
                    Decode!(&bytes, u128, i128).expect("Error Decode canister  result");
                let index: i64 = match i64::try_from(c_index) {
                    Ok(i) => i,
                    Err(_) => 0,
                };
                let timestamp: i64 = match i64::try_from(c_time) {
                    Ok(i) => i/1000000,
                    Err(_) => 0,
                };
                let target_dt: DateTime<Utc> = Utc.timestamp_millis(timestamp);
                let nv_date = target_dt.naive_utc();
                let value_json = serde_json::to_string(&u.eventValue).expect("Error value to json");
                let new_log = EventLog {
                    id: None,
                    index: Some(index),
                    project_id: u.projectId.clone(),
                    caller: u.caller.clone(),
                    event_key: u.eventKey.clone(),
                    event_value: value_json,
                    timestamp: Some(timestamp),
                    time: Some(nv_date),
                };
                create_event(&new_log);
            }
        }
        Err(e) => {
            error!("Error creating:{}", e);
        }
    };
}

fn get_last_index() -> i64 {
    let conn = connection::establish_connection();
    let results = event_log::table
        .order_by(event_log::index.desc())
        .limit(1)
        .load::<EventLog>(&conn)
        .expect("Error loading event");
    if results.len() == 0 {
        return 0;
    }

    match results.get(0) {
        Some(log) => return log.index.unwrap(),
        None => return 0,
    }
}

pub fn create_event(u: &EventLog) -> EventLog {
    let conn = &connection::establish_connection();
    diesel::insert_into(event_log::table)
        .values(u)
        .get_result(conn)
        .expect("Error saving new event log")
}
