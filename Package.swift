// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TealiumPrismFirebase",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .tvOS(.v15),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "TealiumPrismFirebase",
            targets: ["TealiumPrismFirebase"]
        ),
    ],
    dependencies: [
        // .package(url: "https://github.com/Tealium/tealium-prism-swift", from: "0.4.0"),
        .package(url: "https://github.com/Tealium/tealium-swift-v3", branch: "MT-1952"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.0.0")
    ],
    targets: [
        .target(
            name: "TealiumPrismFirebase",
            dependencies: [
                .product(name: "TealiumPrismCore", package: "tealium-swift-v3"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ],
            path: "./Sources/TealiumPrismFirebase"
        ),
        .testTarget(
            name: "TealiumPrismFirebaseTests",
            dependencies: ["TealiumPrismFirebase"],
            path: "./Tests/TealiumPrismFirebaseTests"
        ),
    ]
)