    #!/bin/bash
    set -ex

    SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

    # Required env vars
    ARIES_VCX_ROOT=$(dirname $(dirname $(dirname $SCRIPT_DIR)))
    IOS_BUILD_DEPS_DIR=${ARIES_VCX_ROOT}/aries_framework_vcx/target/ios_build_deps
    LANGUAGE="swift"
    TARGET="aarch64-apple-ios"
    TARGET_NICKNAME="arm64"
    ABI="iphoneos"

    generate_bindings() {

        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx/"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx/ios/"
        
        rustup target add ${TARGET}

        #cargo install cargo-lipo

        pushd "${UNIFFI_ROOT}"
            cargo run --features=uniffi/cli --bin uniffi-bindgen generate src/aries_framework_vcx.udl --language ${LANGUAGE}
        popd
        
        #mkdir ${IOS_APP_DIR}/Source

        cp -R ${UNIFFI_ROOT}/src/vcx.swift ${UNIFFI_ROOT}/src/vcxFFI.* ${IOS_APP_DIR}
        cp -R ${UNIFFI_ROOT}/src/vcx.swift ${UNIFFI_ROOT}/src/vcxFFI.* ${IOS_APP_DIR}/Source
        rm -R ${UNIFFI_ROOT}/src/vcx.swift ${UNIFFI_ROOT}/src/vcxFFI.*
    }

    build_uniffi_for_demo() {
        echo "Running build_uniffi_for_demo..."
        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx/"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx/ios"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks
        mkdir -p ${ABI_PATH}

        pushd ${UNIFFI_ROOT}/core
            cargo build --target ${TARGET} --features "aries_vcx_anoncreds/zmq_vendored"
            cp ${ARIES_VCX_ROOT}/aries_framework_vcx/target/${TARGET}/debug/libuniffi_vcx.a ${ABI_PATH}/libuniffi_vcx.a

        popd
    }

    build_ios_xcframework() {

        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx/"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx/ios"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks

        mv ${IOS_APP_DIR}/Source/vcxFFI.modulemap ${IOS_APP_DIR}/Source/module.modulemap 

        xcodebuild -create-xcframework -library ${ABI_PATH}/libuniffi_vcx.a -headers ${IOS_APP_DIR}/Source -output "${ABI_PATH}/vcx.xcframework"

        cd ${ABI_PATH}
        zip -r vcx.xcframework.zip vcx.xcframework

        # Remove .a file if it is not required and have large size
        rm -R ${ABI_PATH}/libuniffi_vcx.a
        rm -R ${ABI_PATH}/vcx.xcframework

    }

    delete_existing_xcframework() {
        
        export UNIFFI_ROOT="${ARIES_VCX_ROOT}/aries_framework_vcx"
        export IOS_APP_DIR="${ARIES_VCX_ROOT}/aries_framework_vcx/ios"
        export ABI_PATH=${IOS_APP_DIR}/Frameworks

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

    generate_bindings
    build_uniffi_for_demo
    build_ios_xcframework
    delete_existing_xcframework
    upload_framework