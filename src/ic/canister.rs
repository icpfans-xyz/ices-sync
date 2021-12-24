use candid::{CandidType, Nat};
use dotenv::dotenv;
use garcon::Delay;
use ic_agent::agent::agent_error::AgentError;
use ic_agent::agent::http_transport::ReqwestHttpReplicaV2Transport;
use ic_agent::identity::BasicIdentity;
use ic_agent::Agent;
use ic_types::Principal;
use std::env;
use std::time::Duration;

#[derive(CandidType)]
struct Argument {
    index: Nat,
}

fn waiter_with_timeout(duration: Duration) -> Delay {
    Delay::builder().timeout(duration).build()
}
fn expiry_duration() -> Duration {
    // 5 minutes is max ingress timeout
    Duration::from_secs(60 * 4)
}


pub async fn query_call(
    method_name: &str,
    params: &Vec<u8>,
) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    dotenv().ok();
    let ic_url = env::var("IC_URL").expect("IC_URL must be set");
    let canister_id = env::var("CANISTER_ID").expect("CANISTER_ID must be set");
    info!("c_url:{},{}", ic_url, canister_id);
    let rng = ring::rand::SystemRandom::new();
    let key_pair = ring::signature::Ed25519KeyPair::generate_pkcs8(&rng)
        .expect("Could not generate a key pair.");
    let identity = BasicIdentity::from_key_pair(
        ring::signature::Ed25519KeyPair::from_pkcs8(key_pair.as_ref())
            .expect("Could not read the key pair."),
    );
    let agent: Agent = Agent::builder()
        .with_transport(ReqwestHttpReplicaV2Transport::create(ic_url).unwrap())
        .with_identity(identity)
        .build()
        .unwrap();
    // Only do the following call when not contacting the IC main net (e.g. a local emulator).
    // This is important as the main net public key is static and a rogue network could return
    // a different key.
    // If you know the root key ahead of time, you can use `agent.set_root_key(root_key)?;`.
    agent.fetch_root_key().await?;
    let canister_id = String::from(canister_id);
    let canister_id_principal = Principal::from_text(canister_id).unwrap();
    
    let response = agent
        .query(&canister_id_principal, method_name)
        .with_arg(params)
        .call()
        .await;
    match response {
        Ok(reply) => return Ok(reply),
        Err(AgentError::ReplicaError {
            reject_code,
            reject_message,
        }) => {
            return Err(format!(
                "Error {} occured with message: {}",
                reject_code, reject_message
            )
            .into())
        }
        Err(_) => return Err("Other Error...".into()),
    };
}


pub async fn update_call(
    method_name: &str,
    params: &Vec<u8>,
) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    dotenv().ok();
    let ic_url = env::var("IC_URL").expect("IC_URL must be set");
    let canister_id = env::var("CANISTER_ID").expect("CANISTER_ID must be set");
    info!("c_url:{},{}", ic_url, canister_id);
    let rng = ring::rand::SystemRandom::new();
    let key_pair = ring::signature::Ed25519KeyPair::generate_pkcs8(&rng)
        .expect("Could not generate a key pair.");
    let identity = BasicIdentity::from_key_pair(
        ring::signature::Ed25519KeyPair::from_pkcs8(key_pair.as_ref())
            .expect("Could not read the key pair."),
    );
    let agent: Agent = Agent::builder()
        .with_transport(ReqwestHttpReplicaV2Transport::create(ic_url).unwrap())
        .with_identity(identity)
        .build()
        .unwrap();
    // Only do the following call when not contacting the IC main net (e.g. a local emulator).
    // This is important as the main net public key is static and a rogue network could return
    // a different key.
    // If you know the root key ahead of time, you can use `agent.set_root_key(root_key)?;`.
    agent.fetch_root_key().await?;
    // initialize agent and canister_id
    let canister_id = String::from(canister_id);
    let canister_id_principal = Principal::from_text(canister_id).unwrap();
    let response = agent
        .update(&canister_id_principal, method_name)
        .with_arg(params)
        .call_and_wait(waiter_with_timeout(expiry_duration()))
        .await;

    match response {
        Ok(reply) => return Ok(reply),
        Err(AgentError::ReplicaError {
            reject_code,
            reject_message,
        }) => {
            return Err(format!(
                "Error {} occured with message: {}",
                reject_code, reject_message
            )
            .into())
        }
        Err(_) => return Err("Other Error...".into()),
    };
}
