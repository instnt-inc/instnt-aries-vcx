// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import class Foundation.ProcessInfo

let package = Package(
    name: "InstntAriesFrameworkVCX",
    products: [
        .library(
            name: "InstntAriesFrameworkVCX",
            targets: ["InstntAriesFrameworkVCX"]),
    ],
    targets: [
        .target(
            name: "InstntAriesVCX",
            path: "aries_framework_vcx/ios/Source"
            ),
    ]
)

let InstntAriesVCXTarget = package.targets.first(where: { $0.name == "InstntAriesFrameworkVCX" })

if ProcessInfo.processInfo.environment["USE_LOCAL_XCFRAMEWORK"] == nil {
    package.targets.append(.binaryTarget(
        name: "VCX_uniffiFFI_Lib_zip",
        path: url: "https://github.com/instnt-inc/instnt-aries-vcx/releases/download/aries-framework-vcx-uniffi-ios/vcx.xcframework.zip",
        checksum: "cb1fa78a18a5a5bcd22ffa6c7eba494ff374fa2ab1166b4900640430aeda6194"
        ))
        
        InstntAriesVCXTarget?.dependencies.append("VCX_uniffiFFI_Lib_zip")

} else {
    package.targets.append(.binaryTarget(
        name: "uniffiFFI_local",
        path: "aries_framework_vcx/ios/Frameworks/vcx.xcframework"))
                
        InstntAriesVCXTarget?.dependencies.append("uniffiFFI_local")

}

