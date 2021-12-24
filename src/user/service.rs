use crate::connection;
use crate::ic::canister;
use candid::{CandidType, Decode, Encode, Int, Nat};
use diesel::prelude::*;
use diesel::query_dsl::QueryDsl;
use log::{error, info};
use serde::Deserialize;
use std::convert::TryFrom;

#[derive(Debug, Clone, Queryable, Insertable)]
#[table_name = "user_log"]
pub struct User {
    id: Option<i64>,
    index: Option<i64>,
    project_id: String,
    canister_id: String,
    caller: String,
    account_id: String,
    func_name: String,
    func_tag: String,
    timesstamp: Option<i64>,
}

#[derive(CandidType, Deserialize)]
pub struct UserLogResult {
    pub index: Nat,
    pub project_id: String,
    pub canister_id: String,
    pub caller: String,
    pub account_id: Option<String>,
    pub func_name: String,
    pub func_tag: String,
    pub timesstamp: Int,
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


pub async fn sync_canister_user() -> () {
    info!("user service start");
    let db_index = i32::try_from(get_last_index()).expect("Error i64 convert to i32");
    let size = 10;
    info!("index_nat:{},size_nat:{}", &db_index, &size);
    let method_name = String::from("getAllPage");
    let params = &Encode!(&Nat::from(db_index), &Nat::from(size)).expect("Error Encode params");
    let response = canister::query_call(&method_name, params).await;
    match response {
        Ok(reply) => {
            // let json = String::from_utf8_lossy(&reply).to_string();
            let user_logs = Decode!(reply.as_slice(), Vec<UserLogResult>)
                .expect("Error Decode canister result");
            for u in user_logs.iter() {
                let bytes =
                    Encode!(&u.index, &u.timesstamp).expect("Error Encode canister result to byte");
                let (c_index, c_time) =
                    Decode!(&bytes, u128, i128).expect("Error Decode canister  result");
                let index: i64 = match i64::try_from(c_index) {
                    Ok(i) => i,
                    Err(_) => 0,
                };
                let time: i64 = match i64::try_from(c_time) {
                    Ok(i) => i,
                    Err(_) => 0,
                };
                let new_user = User {
                    id: None,
                    index: Some(index),
                    project_id: u.project_id.clone(),
                    canister_id: u.canister_id.clone(),
                    caller: u.caller.clone(),
                    account_id: u.account_id.clone().unwrap(),
                    func_name: u.func_name.clone(),
                    func_tag: u.func_tag.clone(),
                    timesstamp: Some(time),
                };
                create_user(&new_user);
            }
        }
        Err(e) => {
            error!("Error creating:{}", e);
        }
    };
}

fn get_last_index() -> i64 {
    let conn = connection::establish_connection();
    let results = user_log::table
        .order_by(user_log::index.desc())
        .limit(1)
        .load::<User>(&conn)
        .expect("Error loading posts");
    if results.len() == 0 {
        return 0;
    }

    match results.get(0) {
        Some(user) => return user.index.unwrap(),
        None => return 0,
    }
}

pub fn create_user(u: &User) -> User {
    let conn = connection::establish_connection();
    diesel::insert_into(user_log::table)
        .values(u)
        .get_result(&conn)
        .expect("Error saving new user")
}
