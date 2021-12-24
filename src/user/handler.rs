use self::diesel::prelude::*;
use rocket::fairing::AdHoc;
use rocket::response::{status::Created, Debug};
use rocket::serde::{json::Json, Deserialize, Serialize};
// use rocket::{Build, Rocket};
use rocket_sync_db_pools::{database, diesel};

#[database("postgres")]
struct Db(diesel::PgConnection);

type Result<T, E = Debug<diesel::result::Error>> = std::result::Result<T, E>;

#[derive(Debug, Clone, Deserialize, Serialize, Queryable, Insertable)]
#[serde(crate = "rocket::serde")]
#[table_name = "user_log"]
struct User {
    #[serde(skip_deserializing)]
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

#[post("/", data = "<user>")]
async fn create(db: Db, user: Json<User>) -> Result<Created<Json<User>>> {
    let user_value = user.clone();
    db.run(move |conn| {
        diesel::insert_into(user_log::table)
            .values(&user_value)
            .execute(conn)
    })
    .await?;

    Ok(Created::new("/").body(user))
}

#[get("/")]
async fn list(db: Db) -> Result<Json<Vec<Option<i64>>>> {
    let ids: Vec<Option<i64>> = db
        .run(move |conn| user_log::table.select(user_log::id).load(conn))
        .await?;

    Ok(Json(ids))
}

#[get("/<id>")]
async fn read(db: Db, id: i64) -> Option<Json<User>> {
    db.run(move |conn| user_log::table.filter(user_log::id.eq(id)).first(conn))
        .await
        .map(Json)
        .ok()
}

#[delete("/<id>")]
async fn delete(db: Db, id: i64) -> Result<Option<()>> {
    let affected = db
        .run(move |conn| {
            diesel::delete(user_log::table)
                .filter(user_log::id.eq(id))
                .execute(conn)
        })
        .await?;

    Ok((affected == 1).then(|| ()))
}

#[delete("/")]
async fn destroy(db: Db) -> Result<()> {
    db.run(move |conn| diesel::delete(user_log::table).execute(conn))
        .await?;

    Ok(())
}

// async fn run_migrations(rocket: Rocket<Build>) -> Rocket<Build> {
//     // This macro from `diesel_migrations` defines an `embedded_migrations`
//     // module containing a function named `run` that runs the migrations in the
//     // specified directory, initializing the database.
//     embed_migrations!("migrations");

//     let conn = Db::get_one(&rocket).await.expect("database connection");
//     conn.run(|c| embedded_migrations::run(c))
//         .await
//         .expect("diesel migrations");

//     rocket
// }

pub fn stage() -> AdHoc {
    AdHoc::on_ignite("Diesel Usergres Stage", |rocket| async {
        rocket
            .attach(Db::fairing())
            // .attach(AdHoc::on_ignite("Diesel Migrations", run_migrations))
            .mount("/user", routes![list, read, create, delete, destroy])
    })
}
