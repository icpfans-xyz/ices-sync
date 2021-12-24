#[macro_use]
extern crate rocket;
extern crate chrono;
// extern crate diesel_migrations;
#[macro_use]
extern crate diesel;
extern crate dotenv;
#[macro_use]
extern crate log;
extern crate serde_json;

use log::info;
use rocket::tokio::{self};
use std::time::Duration;
use env_logger::Env;

mod connection;
mod event_log;
mod ic;
mod schema;
mod user;
// mod test_data;

#[rocket::main]
async fn main() -> Result<(), rocket::Error> {
    let env = Env::default()
        .filter_or("RUST_LOG", "info");

    env_logger::init_from_env(env);
    let rocket = rocket::build()
        // .attach(user::handler::stage())
        .ignite()
        .await?;

    tokio::spawn(async move {
        info!("startup schedules task");
        startup_schedules().await;
    });

    // The `launch()` future resolves after ~5 seconds.
    let result = rocket.launch().await;
    assert!(result.is_ok());

    Ok(())
}

pub async fn startup_schedules() {
    let mut interval = tokio::time::interval(Duration::from_secs(5));

    loop {
        interval.tick().await;
        // no job_scheduler anymore, calculating via interval at the top!
        info!("sync every 5 seconds!");
        event_log::service::sync_canister_event().await;
    }
}
