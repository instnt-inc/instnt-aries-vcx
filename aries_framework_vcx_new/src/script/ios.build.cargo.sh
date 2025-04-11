    #!/bin/bash
    set -ex

    SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

    # Required env vars
    ARIES_VCX_ROOT=$(dirname $(dirname $(dirname $SCRIPT_DIR)))
    LANGUAGE="swift"
    TARGET="aarch64-apple-ios"
    TARGET_NICKNAME="arm64"
    ABI="iphoneos"


    presetup() {

        brew install cmake autoconf automake libtool pkg-config git
        git clone https://github.com/zeromq/libzmq.git vendor/libzmq
        cd vendor/libzmq
        ./autogen.sh
        ./configure
        make
        sudo make install

    }

    generate_bindings() {

        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx_new"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx_new/ios/"
        
        rustup target add ${TARGET}

        pushd "${UNIFFI_ROOT}"
            cargo run --features=uniffi/cli --bin uniffi-bindgen generate src/aries_framework_vcx_new.udl --language ${LANGUAGE}
            #cargo run --features=uniffi/cli --bin uniffi-bindgen generate src/aries_framework_vcx_new.udl --language ${LANGUAGE}
        popd
        
        cp -R ${UNIFFI_ROOT}/src/aries_framework_vcx_new.swift ${UNIFFI_ROOT}/src/aries_framework_vcx_newFFI.* ${IOS_APP_DIR}
        cp -R ${UNIFFI_ROOT}/src/aries_framework_vcx_new.swift ${UNIFFI_ROOT}/src/aries_framework_vcx_newFFI.* ${IOS_APP_DIR}/Source
        rm -R ${UNIFFI_ROOT}/src/aries_framework_vcx_new.swift ${UNIFFI_ROOT}/src/aries_framework_vcx_newFFI.*
    }

    build_uniffi_for_demo() {
        echo "Running build_uniffi_for_demo..."
        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx_new"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx_new/ios"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks
        mkdir -p ${ABI_PATH}

        pushd ${UNIFFI_ROOT}
            cargo build --target ${TARGET} --features "aries_vcx_anoncreds/zmq_vendored"
            
            # --features "aries_vcx_anoncreds/zmq_vendored"

            cp ${ARIES_VCX_ROOT}/target/${TARGET}/debug/libaries_framework_vcx_new.a ${ABI_PATH}/libaries_framework_vcx_new.a

        popd
    }

    build_ios_xcframework() {

        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx_new/"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx_new/ios"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks

        mv ${IOS_APP_DIR}/Source/aries_framework_vcx_newFFI.modulemap ${IOS_APP_DIR}/Source/module.modulemap 

        if [ -d "${ABI_PATH}/aries_framework_vcx_new.xcframework" ]; then
        rm -R "${ABI_PATH}/aries_framework_vcx_new.xcframework"
        fi

        xcodebuild -create-xcframework -library ${ABI_PATH}/libaries_framework_vcx_new.a -headers ${IOS_APP_DIR}/Source -output "${ABI_PATH}/aries_framework_vcx_new.xcframework"

        cd ${ABI_PATH}
        zip -r aries_framework_vcx_new.xcframework.zip aries_framework_vcx_new.xcframework

        # Remove .a file if it is not required and have large size
        rm -R ${ABI_PATH}/libaries_framework_vcx_new.a

    }

    local_cleanup() {
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx_new/ios"
        rm -R ${ABI_PATH}/aries_framework_vcx_new.xcframework.zip
    }

    delete_existing_xcframework() {
        
        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx/ios"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks

        rm -R ${ABI_PATH}/vcx.xcframework

        XCFRAMEWORK_PATH="${ABI_PATH}/vcx.xcframework.zip"

        # Print for debugging
        echo "XCFRAMEWORK_PATH=${XCFRAMEWORK_PATH}"

        # Ensure the file has the correct permissions (readable)
        chmod u+rw "$XCFRAMEWORK_PATH"

        # Get the name of the file to be uploaded
        ASSET_NAME=$(basename "$XCFRAMEWORK_PATH")

        # Fetch the release ID by tag
        RELEASE_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$REPO/releases/tags/$TAG" | jq -r '.id')

        if [ "$RELEASE_ID" == "null" ]; then
        echo "Release not found for tag: $TAG"
        else
        echo "Found release ID: $RELEASE_ID"

        # Delete the release
        echo "Deleting release with ID: $RELEASE_ID"
        RES=$(curl -s -X DELETE -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$REPO/releases/$RELEASE_ID")
        echo "Release deletion complete."
        fi

        echo "Asset delete process complete."

    }

    upload_framework() {

        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx/ios"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks

        # Create a release
        
        RESPONSE=$(curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            -d "{\"tag_name\":\"$TAG\",\"name\":\"Release $TAG\",\"draft\":false,\"prerelease\":false}" \
            https://api.github.com/repos/$REPO/releases)
        
        #Extract the release ID
        RELEASE_ID=$(echo $RESPONSE | jq -r .id)
        echo "Release ID: $RELEASE_ID"
        echo "RELEASE_ID=$RELEASE_ID" >> $GITHUB_ENV

        # Define the path to your zip file
        XCFRAMEWORK_PATH="${ABI_PATH}/vcx.xcframework.zip"

        # Print for debugging
        echo "XCFRAMEWORK_PATH=${XCFRAMEWORK_PATH}"

        # Ensure the file has the correct permissions (readable)
        chmod u+rw "$XCFRAMEWORK_PATH"

        # Get the name of the file to be uploaded
        ASSET_NAME=$(basename "$XCFRAMEWORK_PATH")

        # Upload the file to the release
        curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/zip" \
        --data-binary @"$XCFRAMEWORK_PATH" \
        "https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=$(basename "$XCFRAMEWORK_PATH")"

        rm -R ${ABI_PATH}/vcx.xcframework.zip

        echo "File uploaded"

    }

    #presetup
    generate_bindings
    build_uniffi_for_demo
    build_ios_xcframework

    if [ "$CI" == "true" ]; then
    echo "Running in GitHub Actions"
    delete_existing_xcframework
    upload_framework
    else
    echo "Running locally"
    local_cleanup
    fi