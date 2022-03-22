use diesel::prelude::*;
// use diesel::query_dsl::QueryDsl;
use crate::connection;
use crate::event_log::service::{event_log, EventLog};
use chrono::{DateTime, NaiveDateTime, TimeZone, Utc};
use rand::Rng;


pub fn gen_data(target_timestamp: i64, day_record: i64, mut index: i64) -> i64 {
    println!("day_record: {}", day_record);
    let mut rng = rand::thread_rng();
    let project_arr = [
        "icp123",
        "dfinity",
        "plug",
        "stoic-wallet",
        "dfinity-explorer",
        "nnsdao",
        "icpuppies",
        "crowdeats",
    ];
    let caller_arr = [
        "xvfsm-gaya2-2xarb-luyiv-cuec2-tszas-n3tda-opqk6-drk22-v65j5-sqe",
        "hzpfi-laaaa-aaaah-aa4cq-cai",
        "rwlgt-iiaaa-aaaaa-aaaaa-cai",
        "rrkah-fqaaa-aaaaa-aaaaq-cai",
        "uen23-h7f3t-b73ip-xxne3-3ycht-h5he4-bg3ix-5wjdm-buzyg-46un3-3qe",
        "5gj3d-vyaaa-aaaad-qa4aa-cai",
        "2iql3-oiaaa-aaaab-qacja-cai",
        "rtrzn-oaaaa-aaaam-qaaka-cai",
        "nges7-giaaa-aaaaj-qaiya-cai",
        "kjrvl-xyaaa-aaaak-aabta-cai",
        "uy3uz-syaaa-aaaab-qadka-cai",
        "phmyx-qaaaa-aaaak-aabpq-cai",
        "ej4po-xaaaa-aaaah-aa4kq-cai",
        "koqt7-2aaaa-aaaak-aabtq-cai",
    ];
    let key_arr = [
        "CAS_USER",
        "tx",
        "clam",
        "rewards",
        "approve",
        "trans",
        "icpuppies",
        "crowdeats",
    ];
    let key_value_arr = [
        "[\"cas_login value\",\"hello value2\"]",
        "[\"tx value\",\"heddllo fds\"]",
        "[\"resf value\",\"goods fds\"]",
        "[\"approve value\",\"approve fds\"]",
        "[\"trans\",\"approve trans\"]",
    ];
    for i in 0..day_record {
        index += 1;
        let ts = target_timestamp + (i * 1000) ;
        let target_dt: DateTime<Utc> = Utc.timestamp_millis(ts);
        let nv_date = target_dt.naive_utc();
        println!(
            "target_time: {}",
            target_dt.format("%Y-%m-%d %H:%M:%S").to_string()
        );

        let project_id = project_arr[rng.gen_range(0..project_arr.len())];
        let caller = caller_arr[rng.gen_range(0..caller_arr.len())];
        let key = key_arr[rng.gen_range(0..key_arr.len())];
        let value = if  key == "CAP_USER"  {
            let r = format!("[\"{}\"]", caller);
            r
        } else {
            let s = key_value_arr[rng.gen_range(0..key_value_arr.len())];
            String::from(s)
        };
        
        let new_log = EventLog {
            id: None,
            index: Some(index),
            project_id: String::from(project_id),
            caller: String::from(caller),
            event_key:  String::from(key),
            event_value: String::from(value),
            timestamp: Some(ts),
            time: Some(nv_date),
        };
        create_event(&new_log);
    }
    index
}

#[test]
pub fn gen_day_date() -> () {
    let dt = Utc::now();
    println!("dt: {}", dt);
    let current_timestamp = dt.timestamp_millis();
    println!("current_timestamp: {}", current_timestamp);
    println!(
        "current_time: {}",
        dt.format("%Y-%m-%d %H:%M:%S").to_string()
    );
    let mut rng = rand::thread_rng();
    let mut number = rng.gen_range(0..34);
    let day_record = rng.gen_range(0..30);
    
    let mut index:i64 = 0;
    while number >= 0 {
        let n_day = 1000 * 60 * 60 * 24 * number;
        let target_timestamp = current_timestamp - n_day;
        index = gen_data(target_timestamp, day_record, index);
        number -= 1;
    }
}

#[test]
pub fn time_dule() -> () {
    let t: i64 = 1637793188236113624;
    let r = t / 1000000;
    println!("rrr:{}", r);
}

pub fn create_event(u: &EventLog) -> EventLog {
    let conn = &connection::establish_connection();
    diesel::insert_into(event_log::table)
        .values(u)
        .get_result(conn)
        .expect("Error saving new event log")
}
