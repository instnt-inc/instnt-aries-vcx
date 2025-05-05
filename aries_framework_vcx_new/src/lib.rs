uniffi::include_scaffolding!("aries_framework_vcx_new");

use error::*;
mod error;
pub use aries_vcx;
pub use aries_vcx::aries_vcx_wallet::wallet::askar::{askar_wallet_config::AskarWalletConfig,key_method::{ArgonLevel, AskarKdfMethod, KeyMethod}, AskarWallet};
pub use aries_vcx::aries_vcx_wallet::wallet::base_wallet::ManageWallet;
mod framework{
    use aries_vcx::aries_vcx_wallet::wallet::askar::{askar_wallet_config::AskarWalletConfig,key_method::{ArgonLevel, AskarKdfMethod, KeyMethod}, AskarWallet};
    use aries_vcx::aries_vcx_wallet::wallet::base_wallet::ManageWallet;
    use crate::connection_service::ConnectionServiceConfig;
    use crate::{
        VCXFrameworkResult
    };
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

    impl AriesFrameworkVCX {
        pub fn initialize_calling_aries(framework_config: FrameworkConfig) -> VCXFrameworkResult<Self> {
            //let wallet= framework_config.wallet_config.create_wallet();
            Ok((Self { 
                framework_config
            } ))
        }
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

