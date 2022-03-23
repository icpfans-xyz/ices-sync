use serde::{Serialize, Deserialize};

#[derive(Deserialize, Serialize)]
pub struct SubValue { 
    pub sub_key: String,
    pub sub_value: String,
    pub indexed: bool,
}

