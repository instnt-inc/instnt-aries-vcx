#!/bin/bash
set -ex

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

# Required env vars
ARIES_VCX_ROOT=$(dirname $(dirname $(dirname $SCRIPT_DIR)))
ANDROID_BUILD_DEPS_DIR=${ARIES_VCX_ROOT}/target/android_build_deps
LANGUAGE="kotlin"
# Run comment 1 to 4 from android.cargo.ndk.framework.all.architecture.sh 
TARGET="aarch64-linux-android"
TARGET_NICKNAME="arm64"
ABI="arm64-v8a"

generate_bindings() {
    export FRAMEWORK_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx"
    export ANDROID_DEMO_DIR="${ARIES_VCX_ROOT}/aries/agents/MyUniffiAndroid"

    pushd "${FRAMEWORK_ROOT}"
                cargo run --features=uniffi/cli --bin uniffi-bindgen generate src/aries_framework_vcx.udl --language ${LANGUAGE}
    popd
    
    cp -R ${FRAMEWORK_ROOT}/src/org/hyperledger/ariesframeworkvcx/aries_framework_vcx.kt ${ANDROID_DEMO_DIR}/app/src/main/java/com/example/myuniffiandroid
    rm -R ${FRAMEWORK_ROOT}/src/org
}

generate_bindings
