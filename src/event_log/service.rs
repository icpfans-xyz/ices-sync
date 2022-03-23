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
use crate::event_log::event::SubValue;


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
    pub ices_time: Option<NaiveDateTime>,
    
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
        ices_time -> Nullable<Timestamp>,
    }
}


pub async fn sync_canister_event() -> () {
    info!("user service start");
    let size = 10;
    let db_index = get_last_index();
    let latest_index = db_index + 1 ;
    // let latest_index = 1 ;
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
            let event_logs = Decode!(reply.as_slice(), Vec<EventLogResult>)
                .expect("Error Decode canister result");
            info!("event_logs len:{}", event_logs.len());
            for u in event_logs.iter() {
                let event = &u.event;
                // json list
                let mut sub_value_vec: Vec<SubValue> = Vec::new();
                for v_tup in &u.event.values {
                    info!("Tuple subkey:{}", &v_tup.0);
                    // enum EventValue
                    // let event_value : EventValue = &v_tup.1;
                    let mut indexed = false;
                    match &v_tup.2 {
                        Indexed::Indexed => {
                            indexed = true;
                        }
                        Indexed::Not => {
                            indexed = false;
                        }
                    }

                    let mut value_vec: Vec<String> = Vec::new();
                    let mut transtion_vec: Vec<SubValue> = Vec::new();

                    recursive_event_value(&v_tup.1, & mut value_vec, & mut transtion_vec, indexed);
                    
                    info!("value_vec len:{}", value_vec.len());
                    let mut sub_value_str = String::new();
                    if value_vec.len()>1 {
                        let value_vec_json = serde_json::to_string(&value_vec).expect("Error value to json");
                        info!("value_vec_json:{}",value_vec_json);
                        sub_value_str.push_str(&value_vec_json);
                    } 
                    if value_vec.len()==1 {
                        sub_value_str.push_str(&value_vec[0]);
                    }
                    

                    let sub_value  = SubValue {
                        sub_key: String::from(&v_tup.0),
                        sub_value: String::from(sub_value_str),
                        indexed: indexed,
                    };

                    sub_value_vec.push(sub_value);
                    // append transtion
                    sub_value_vec.append(& mut transtion_vec);
                    
                }

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
                let value_vec_json = serde_json::to_string(&sub_value_vec).expect("Error value to json");
                info!("value_vec_json:{}",value_vec_json);
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
                    event_value: value_vec_json,
                    caller_time: Some(caller_date),
                    ices_time: Some(canister_date),
                };
                create_event(&new_log);
            }
        }
        Err(e) => {
            error!("Error creating:{}", e);
        }
    };
}



fn recursive_event_value(value : &EventValue, value_vec : & mut  Vec<String>
    ,transtion_vec : & mut  Vec<SubValue>, indexed : bool) -> () {
    match value {
        EventValue::True =>{
            value_vec.push("true".to_string());
        }
        EventValue::False =>{
            value_vec.push(String::from("false"));
        }
        EventValue::U64(v) =>{
            value_vec.push(v.to_string());
        }
        EventValue::I64(v) =>{
            value_vec.push(v.to_string());
        }
        EventValue::Float(v) =>{
            value_vec.push(v.to_string());
        }
        EventValue::Text(txt) =>{
            info!("Text:{}", txt);
            value_vec.push(txt.to_string());
        }
        EventValue::Principal(p) =>{
            info!("Principal:{}", p.to_string());
            value_vec.push(p.to_string());
        }
        EventValue::Slice(buf) =>{
            let s = String::from_utf8_lossy(buf);
            value_vec.push(s.to_string());
        }
        EventValue::Vec(vlist) =>{
            for v in  vlist.iter() {
                recursive_event_value(&v, value_vec,transtion_vec,indexed);
            }
        }
        EventValue::Transaction(ts) => {
            let sub_key  = SubValue {
                sub_key: String::from("from"),
                sub_value: ts.from.to_string(),
                indexed: indexed,
            };
            let sub_to  = SubValue {
                sub_key: String::from("to"),
                sub_value: ts.to.to_string(),
                indexed: indexed,
            };
            let sub_value  = SubValue {
                sub_key: String::from("amount"),
                sub_value: ts.amount.to_string(),
                indexed: false,
            };
            transtion_vec.push(sub_key);
            transtion_vec.push(sub_to);
            transtion_vec.push(sub_value);
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
