// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShortlessKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ShortlessKit", targets: ["ShortlessKit"])
    ],
    targets: [
        .target(name: "ShortlessKit")
    ]
)
