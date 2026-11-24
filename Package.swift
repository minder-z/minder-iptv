// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MinderIPTV",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "MinderIPTV", path: "Sources/MinderIPTV")
    ]
)
