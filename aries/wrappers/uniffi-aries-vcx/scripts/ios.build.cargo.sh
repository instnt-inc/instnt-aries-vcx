    #!/bin/bash
    set -ex

    SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

    # Required env vars
    ARIES_VCX_ROOT=$(dirname $(dirname $(dirname $(dirname $SCRIPT_DIR))))
    IOS_BUILD_DEPS_DIR=${ARIES_VCX_ROOT}/target/ios_build_deps
    LANGUAGE="swift"
    TARGET="aarch64-apple-ios"
    TARGET_NICKNAME="arm64"
    ABI="iphoneos"

    check_version () {

        rustc --version
        rustup default 1.78.0

    }

    generate_bindings() {

        #sudo apt-get update
        #sudo apt-get install libzmq3-dev
        #sudo apt-get install pkg-config
        #pkg-config --modversion libzmq
        #export LIBZMQ_LIB_DIR=/usr/lib/x86_64-linux-gnu
        #export LIBZMQ_INCLUDE_DIR=/usr/include

        # # Update package list
        # sudo apt-get update

        # # Install necessary packages
        # sudo apt-get install cmake autoconf automake libtool pkg-config git

        # # Clone ZeroMQ repository
        # git clone https://github.com/zeromq/libzmq.git vendor/libzmq

        # # Build ZeroMQ from source
        # cd vendor/libzmq
        # ./autogen.sh
        # ./configure
        # make
        # # Optional: Install ZeroMQ
        # sudo make install
        
        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries/wrappers/uniffi-aries-vcx"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries/agents/ios/ariesvcx/ariesvcx"

        pushd "${UNIFFI_ROOT}/core"
            cargo run --features=uniffi/cli --bin uniffi-bindgen generate src/vcx.udl --language ${LANGUAGE}
        popd
        
        cp -R ${UNIFFI_ROOT}/core/src/vcx.swift ${UNIFFI_ROOT}/core/src/vcxFFI.* ${IOS_APP_DIR}
        rm -R ${UNIFFI_ROOT}/core/src/vcx.swift ${UNIFFI_ROOT}/core/src/vcxFFI.*
    }

    build_uniffi_for_demo() {
        echo "Running build_uniffi_for_demo..."
        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries/wrappers/uniffi-aries-vcx"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries/agents/ios/ariesvcx/ariesvcx"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks
        mkdir -p ${ABI_PATH}

        pushd ${UNIFFI_ROOT}/core
            cargo build --target ${TARGET} --features "aries_vcx_anoncreds/zmq_vendored"
            cp ${ARIES_VCX_ROOT}/target/${TARGET}/debug/libuniffi_vcx.a ${ABI_PATH}/libuniffi_vcx.a

        popd
    }

    build_ios_xcframework() {

        #sudo apt-get update
        #sudo apt-get install libzmq3-dev
        #sudo apt-get install pkg-config
        #pkg-config --modversion libzmq
        #export LIBZMQ_LIB_DIR=/usr/lib/x86_64-linux-gnu
        #export LIBZMQ_INCLUDE_DIR=/usr/include

        
 
        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries/wrappers/uniffi-aries-vcx"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries/agents/ios/ariesvcx/ariesvcx"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks

        #mv ${UNIFFI_ROOT}/core/src/vcxFFI.modulemap ${UNIFFI_ROOT}/core/src/module.modulemap 

        xcodebuild -create-xcframework -library ${ABI_PATH}/libuniffi_vcx.a -headers ${IOS_APP_DIR}/ -output "${ABI_PATH}/vcx.xcframework"

    }

    check_version
    #generate_bindings
    #build_uniffi_for_demo
    #build_ios_xcframework
