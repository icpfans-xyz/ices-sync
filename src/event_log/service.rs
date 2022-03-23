use crate::connection;
use crate::ic::canister;
use candid::{Decode, Encode, IDLArgs, CandidType,Deserialize, Int, Nat,Principal};
// use ic_kit::candid::{CandidType, Deserialize, Int, Nat};
// use ic_kit::Principal;
use serde::Serialize;
use diesel::prelude::*;
use diesel::query_dsl::QueryDsl;
use log::{error, info};
use std::convert::TryFrom;
use chrono::{Utc, DateTime, TimeZone, NaiveDateTime};


#[derive(Debug, Clone, Queryable, Insertable)]
#[table_name = "t_event_logs_v1"]
pub struct EventLogV1 {
    pub id: Option<i64>,
    pub index: Option<i64>,
    pub block: Option<i64>,
    pub nonce: Option<i64>,
    pub canister_id: String,
    pub caller: String,
    pub from_addr: String,
    pub to_addr: String,
    pub event_key: String,
    pub event_value: String,
    pub caller_time: Option<NaiveDateTime>,
    pub canister_time: Option<NaiveDateTime>,
    
}



#[derive(CandidType, Serialize, Deserialize, Clone, Debug)]
pub enum Indexed {
    Indexed,
    Not,
}

#[derive(CandidType, Deserialize, Clone, Debug)]
pub struct Transaction { 
    pub from: String,
    pub to: String,
    pub amount: Nat,

}

#[derive(CandidType, Deserialize, Clone, Debug)]
pub enum EventValue {
    True,
    False,
    U64(u64),
    I64(i64),
    Float(f64),
    Text(String),
    Principal(Principal),
    #[serde(with = "serde_bytes")]
    Slice(Vec<u8>),
    Vec(Vec<EventValue>),
    Transaction(Transaction),
}

#[derive(CandidType,Deserialize, Clone, Debug)]
pub struct Event {
    /// The timestamp in ms.
    pub time: Int,
    /// The caller that initiated the call on the token contract.
    pub caller: Principal,
    /// The key that took place.
    pub key: String,
    /// Details of the transaction.
    pub values: Vec<(String, EventValue, Indexed)>,
}

#[derive(CandidType, Deserialize)]
pub struct EventLogResult {
    pub index: Nat,
    pub block: Nat,
    pub nonce: Nat,
    pub canisterId: Principal,
    pub event: Event,
    pub canisterTime: Int,
}


table! {
    t_event_logs_v1 (id) {
        id -> Nullable<BigInt>,
        index -> Nullable<BigInt>,
        block -> Nullable<BigInt>,
        nonce -> Nullable<BigInt>,
        canister_id -> Text,
        caller -> Text,
        from_addr -> Text,
        to_addr -> Text,
        event_key -> Text,
        event_value -> Text,
        caller_time -> Nullable<Timestamp>,
        canister_time -> Nullable<Timestamp>,
    }
}


pub async fn sync_canister_event() -> () {
    info!("user service start");
    let size = 10;
    let db_index = get_last_index();
    // let latest_index = db_index + 1 ;
    let latest_index = 1 ;
    let method_name = String::from("getEventLogs");
    // last record index
    let text_value = format!("({}:nat, {}:nat)", latest_index, size);
    info!("text_value:{}", &text_value);
    let args: IDLArgs = text_value.parse().expect("Error IDLArgs params");
    let params: Vec<u8> = args.to_bytes().expect("Error Encode params");
    // let params = &Encode!(&Nat::from(latest_index), &Nat::from(size)).expect("Error Encode params");
    let response = canister::update_call(&method_name, &params).await;
    match response {
        Ok(reply) => {
            // let json = String::from_utf8_lossy(&reply).to_string();
            // info!("{}", &json);
            let event_logs = Decode!(reply.as_slice(), Vec<EventLogResult>)
                .expect("Error Decode canister result");
            info!("event_logs len:{}", event_logs.len());
            for u in event_logs.iter() {
                info!("canisterId:{}", &u.canisterId);
                let event = &u.event;
                for v_tup in &u.event.values {
                    info!("Tuple subkey:{}", v_tup.0);
                    // enum EventValue
                    // let event_value : EventValue = &v_tup.1;
                    match &v_tup.1 {
                        EventValue::True =>{
                            info!("# True");
                        }
                        EventValue::False =>{
                            info!("# True");
                        }
                        EventValue::U64(v) =>{
                            info!("U64:{}", v);
                        }
                        EventValue::I64(i) =>{
                            info!("I64:{}", i);
                        }
                        EventValue::Float(i) =>{
                            info!("Float:{}", i);
                        }
                        EventValue::Text(txt) =>{
                            info!("Text:{}", txt);
                        }
                        EventValue::Principal(p) =>{
                            info!("Principal:{}", p.to_string());
                        }
                        EventValue::Slice(s) =>{
                            info!("Slice size:{}", s.len());
                        }
                        EventValue::Vec(vlist) =>{
                            info!("Vec size:{}", vlist.len());
                        }
                        EventValue::Transaction(ts) => {
                            info!("Transaction::from{},to:{},amount:{}", ts.from,ts.from,ts.amount);
                        }
                    };

                    match &v_tup.2 {
                        Indexed::Indexed => {
                            info!("Indexed")
                        }
                        Indexed::Not => {
                            info!("Not Indexed")
                        }
                    }
                    
                }
                // let value_json = serde_json::to_string(&u.event.values).expect("Error value to json");

                let bytes =
                    Encode!(&u.index, &u.block, &u.nonce,&u.canisterTime, &event.time).expect("Error Encode canister result to byte");
                let (c_index, c_block ,c_nonce, c_time, caller_time) =
                    Decode!(&bytes, u128, u128, u128, i128, i128).expect("Error Decode canister  result");
                let index: i64 = match i64::try_from(c_index) {
                    Ok(i) => i,
                    Err(_) => 0,
                };
                let block: i64 = match i64::try_from(c_block) {
                    Ok(i) => i,
                    Err(_) => 0,
                };
                let nonce: i64 = match i64::try_from(c_nonce) {
                    Ok(i) => i,
                    Err(_) => 0,
                };
                let canister_timestamp: i64 = match i64::try_from(c_time) {
                    Ok(i) => i/1000000,
                    Err(_) => 0,
                };
                let caller_timestamp: i64 = match i64::try_from(caller_time) {
                    Ok(i) => i/1000000,
                    Err(_) => 0,
                };
                let canister_dt: DateTime<Utc> = Utc.timestamp_millis(canister_timestamp);
                let canister_date = canister_dt.naive_utc();

                let caller_dt: DateTime<Utc> = Utc.timestamp_millis(caller_timestamp);
                let caller_date = caller_dt.naive_utc();
                // let value_json = serde_json::to_string(&u.eventValue).expect("Error value to json");
                let new_log = EventLogV1 {
                    id: None,
                    index: Some(index),
                    block: Some(block),
                    nonce: Some(nonce),
                    canister_id: u.canisterId.to_text(),
                    caller: event.caller.to_text(),
                    from_addr: u.canisterId.to_text(),
                    to_addr: u.canisterId.to_text(),
                    event_key: event.key.clone(),
                    event_value: "value".to_string(),
                    caller_time: Some(canister_date),
                    canister_time: Some(caller_date),
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
    let results = t_event_logs_v1::table
        .order_by(t_event_logs_v1::index.desc())
        .limit(1)
        .load::<EventLogV1>(&conn)
        .expect("Error loading event");
    if results.len() == 0 {
        return 0;
    }

    match results.get(0) {
        Some(log) => return log.index.unwrap(),
        None => return 0,
    }
}

pub fn create_event(u: &EventLogV1) -> EventLogV1 {
    let conn = &connection::establish_connection();
    diesel::insert_into(t_event_logs_v1::table)
        .values(u)
        .get_result(conn)
        .expect("Error saving new event log")
}
