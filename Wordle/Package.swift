// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Wordle",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Wordle",
            targets: ["Wordle"]),
    ],
    dependencies: [
        .package(url: "https://github.com/simibac/ConfettiSwiftUI.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Wordle",
            dependencies: ["ConfettiSwiftUI"]),
        .testTarget(
            name: "WordleTests",
            dependencies: ["Wordle"]),
    ]
) 