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

build_uniffi_for_demo() {
    export FRAMEWORK_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx"
    export ANDROID_DEMO_DIR="${ARIES_VCX_ROOT}/aries/agents/MyUniffiAndroid"
    export ABI_PATH=${ANDROID_DEMO_DIR}/app/src/main/jniLibs/${ABI}
    mkdir -p ${ABI_PATH}

    pushd ${FRAMEWORK_ROOT}
        cargo ndk -t ${ABI} build
        cp ${ARIES_VCX_ROOT}/target/${TARGET}/debug/libuniffi_aries_framework_vcx.so ${ABI_PATH}/libuniffi_aries_framework_vcx.so
        cp ${LIBZMQ_LIB_DIR}/libzmq.so ${ABI_PATH}/libzmq.so
    popd
}   


build_uniffi_for_demo
