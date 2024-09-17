// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InstntAriesVCX",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "InstntAriesVCX",
            targets: ["InstntAriesVCX"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "InstntAriesVCX",
            path: "aries/agents/ios/ariesvcx/ariesvcx/Source/"
            ),
            .binaryTarget(
        name: "VCX_uniffiFFI_Lib",
        url: "https://github.com/instnt-inc/instnt-aries-vcx/releases/download/abhishek_GithubAction2/vcx.xcframework.zip",
        checksum: "c8964e8a20c2e74199cf40848b7b14afc95a4f3dcae80a4dba974acf54d253ac"
        )
    ]
)

let AriesVCXTarget = package.targets.first(where: { $0.name == "InstntAriesVCX" })

// package.targets.append(.binaryTarget(
//         name: "VCX_uniffiFFI_Lib",
//         url: "https://github.com/instnt-inc/instnt-aries-vcx/releases/download/abhishek_GithubAction2/vcx.xcframework.zip",
//         checksum: "c8964e8a20c2e74199cf40848b7b14afc95a4f3dcae80a4dba974acf54d253ac"
//         ))

//checksum: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
//#path: "aries/agents/ios/ariesvcx/ariesvcx/SPM/vcx.xcframework"))

AriesVCXTarget?.dependencies.append("VCX_uniffiFFI_Lib")

