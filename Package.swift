// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TealiumPrismFirebase",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "TealiumPrismFirebase",
            targets: ["TealiumPrismFirebase"]
        ),
    ],
    dependencies: [
        // LOCAL DEVELOPMENT: Use local tealium-swift-v3
        .package(path: "../tealium-swift-v3"),
        // PRODUCTION: When Prism SDK is published, use:
        // .package(url: "https://github.com/tealium/tealium-prism-swift", from: "1.0.0"),
        
        // Firebase SDK
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
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