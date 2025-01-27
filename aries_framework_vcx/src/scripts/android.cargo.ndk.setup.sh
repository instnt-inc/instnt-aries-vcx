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

download_and_unzip_if_missed() {
    expected_directory="$1"
    url="$2"
    fname="tmp_$(date +%s)_$expected_directory.zip"
    if [ ! -d "${expected_directory}" ] ; then
        echo "Downloading ${GREEN}${url}${RESET} as ${GREEN}${fname}${RESET}"
        wget -q -O ${fname} "${url}"
        echo "Unzipping ${GREEN}${fname}${RESET}"
        unzip -qqo "${fname}"
        rm "${fname}"
        echo "${GREEN}Done!${RESET}"
    else
        echo "${BLUE}Skipping download ${url}${RESET}. Expected directory ${expected_directory} was found"
    fi
}

setup_linked_dependencies() {
    mkdir -p $ANDROID_BUILD_DEPS_DIR
    # download deps
    pushd "${ANDROID_BUILD_DEPS_DIR}"
        download_and_unzip_if_missed "openssl_$TARGET_NICKNAME" "https://repo.sovrin.org/android/libindy/deps/openssl/openssl_$TARGET_NICKNAME.zip"
        download_and_unzip_if_missed "libsodium_$TARGET_NICKNAME" "https://repo.sovrin.org/android/libindy/deps/sodium/libsodium_$TARGET_NICKNAME.zip"
        download_and_unzip_if_missed "libzmq_$TARGET_NICKNAME" "https://repo.sovrin.org/android/libindy/deps/zmq/libzmq_$TARGET_NICKNAME.zip"
    popd

    # main env vars that need to be set
    export OPENSSL_DIR=${ANDROID_BUILD_DEPS_DIR}/openssl_${TARGET_NICKNAME}
    export SODIUM_DIR=${ANDROID_BUILD_DEPS_DIR}/libsodium_${TARGET_NICKNAME}
    export LIBZMQ_DIR=${ANDROID_BUILD_DEPS_DIR}/libzmq_${TARGET_NICKNAME}

    # secondary env vars that need to be set
    export SODIUM_LIB_DIR=${SODIUM_DIR}/lib
    export SODIUM_INCLUDE_DIR=${SODIUM_DIR}/include
    export SODIUM_STATIC=1
    export LIBZMQ_LIB_DIR=${LIBZMQ_DIR}/lib
    export LIBZMQ_INCLUDE_DIR=${LIBZMQ_DIR}/include
    export LIBZMQ_PREFIX=${LIBZMQ_DIR}
    export OPENSSL_LIB_DIR=${OPENSSL_DIR}/lib
    export OPENSSL_STATIC=1
}

setup_linked_dependencies
