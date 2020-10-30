// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "DateTimePicker",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "DateTimePicker",
            targets: ["DateTimePicker"])
    ],
    targets: [
        .target(
            name: "DateTimePicker",
            path: "Source")
    ]
)
