// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "DateTimePicker",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(name: "DateTimePicker",  targets: ["DateTimePicker"])
    ],
    dependencies: [],
    targets: [
        .target(name: "DateTimePicker", path: "Source")
    ],
    swiftLanguageVersions: [.v5]
)
