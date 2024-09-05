// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ariesVCX",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ariesVCX",
            targets: ["ariesVCX"]),
    ],
    targets: [
        .binaryTarget(
            name: "VCX_uniffiFFI_Lib",
            path: "aries/agents/ios/ariesvcx/ariesvcx/Frameworks/vcx.xcframework"
        ),
        .target(
            name: "ariesVCX", 
            dependencies: ["VCX_uniffiFFI_Lib"],
            path: "aries/agents/ios/ariesvcx/ariesvcx/Sources"
        )        
    ]
)
