uniffi::include_scaffolding!("aries_framework_vcx_new");

use crate::framework::reverse_string;
use crate::framework::get_constant_framework_db_url;
use crate::framework::get_constant_framework_db_wallet_profile;
use crate::framework::initialize;
use crate::framework::initialize_new;
use crate::framework::initialize_calling_aries;
use crate::framework::AriesFrameworkVCX;
use crate::framework::FrameworkConfig;
use crate::connection_service::ConnectionServiceConfig;

use error::*;
mod error;
pub use aries_vcx;
pub use aries_vcx::aries_vcx_wallet::wallet::askar::{askar_wallet_config::AskarWalletConfig,key_method::{ArgonLevel, AskarKdfMethod, KeyMethod}, AskarWallet};
pub use aries_vcx::aries_vcx_wallet::wallet::base_wallet::ManageWallet;
mod framework{
    use aries_vcx::aries_vcx_wallet::wallet::askar::{askar_wallet_config::AskarWalletConfig,key_method::{ArgonLevel, AskarKdfMethod, KeyMethod}, AskarWallet};
    use aries_vcx::aries_vcx_wallet::wallet::base_wallet::ManageWallet;
    use crate::connection_service::ConnectionServiceConfig;
    use crate::VCXFrameworkResult;
    use std::{fmt::Error, sync::{mpsc::Receiver, Arc, Mutex}};
    const IN_MEMORY_DB_URL: &str = "sqlite://:memory:";
    const DEFAULT_WALLET_PROFILE: &str = "aries_framework_vcx_default";
    const DEFAULT_ASKAR_KEY_METHOD: KeyMethod = KeyMethod::DeriveKey {
        inner: AskarKdfMethod::Argon2i {
            inner: (ArgonLevel::Interactive),
        },
    };

    #[derive(Clone)]
    pub struct FrameworkConfig {
        pub wallet_config: AskarWalletConfig,
        pub connection_service_config: ConnectionServiceConfig,
        pub agent_endpoint: String,
        pub agent_label: String,
    }
    
    pub struct AriesFrameworkVCX {
        pub framework_config: FrameworkConfig,
    }

    pub fn initialize_calling_aries(framework_config: FrameworkConfig) -> AriesFrameworkVCX {
        //let wallet= framework_config.wallet_config.create_wallet();
        AriesFrameworkVCX {
            framework_config
        }
    }

    pub fn initialize(input_string: &str) -> String {
            if input_string == "sample_pass_key" {
               return  "Dont use for Production".to_string();
            }
            if input_string == "instntMultipassWallet" {
               return "instntMultipassWallet".to_string();
            }
            return "No Match Found".to_string();
        }

    pub fn initialize_new(framework_config: FrameworkConfig) -> String {
        if framework_config.wallet_config.pass_key() == "sample_pass_key" {
            return  "Dont use for Production".to_string();
        }
        if framework_config.wallet_config.pass_key() == "instntMultipassWallet" {
            return "instntMultipassWallet".to_string();
        }
        if framework_config.agent_label == "sample_pass_key" {
            return  "Dont use for Production".to_string();
        }
        if framework_config.agent_label == "instntMultipassWallet" {
            return "instntMultipassWallet".to_string();
        }
        return "No Match Found".to_string();
    }

    pub fn reverse_string(input_string: &str) -> String {
    input_string.chars().rev().collect()
   }

    pub fn get_constant_framework_db_url() -> String {
    IN_MEMORY_DB_URL.to_string()
   }
   
    pub fn get_constant_framework_db_wallet_profile() -> String {
    DEFAULT_WALLET_PROFILE.to_string()
   }

}

mod connection_service {

    #[derive(Clone)]
    pub struct ConnectionServiceConfig {
        pub auto_complete_requests: bool,
        pub auto_respond_to_requests: bool,
        pub auto_handle_requests: bool,
    }

    impl Default for ConnectionServiceConfig {
        fn default() -> Self {
            Self {
                auto_complete_requests: true,
                auto_handle_requests: true,
                auto_respond_to_requests: true,
            }
        }
    }

}


