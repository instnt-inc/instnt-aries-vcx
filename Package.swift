// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AriesVCX",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AriesVCX",
            targets: ["AriesVCX"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AriesVCX",
            path: "aries/agents/ios/ariesvcx/ariesvcx/SPM/Sources/AriesVCX"
            )
    ]
)

let MyLibraryVCX3Target = package.targets.first(where: { $0.name == "AriesVCX" })

package.targets.append(.binaryTarget(
        name: "VCX_uniffiFFI_Lib",
        path: "https://github.com/instnt-inc/instnt-aries-vcx/releases/download/abhishek_GithubAction2/vcx.xcframework.zip"))

//#path: "aries/agents/ios/ariesvcx/ariesvcx/SPM/vcx.xcframework"))

MyLibraryVCX3Target?.dependencies.append("VCX_uniffiFFI_Lib")

