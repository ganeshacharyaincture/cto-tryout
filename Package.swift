// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "MusicPlaylistApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MusicPlaylistApp",
            targets: ["MusicPlaylistApp"])
    ],
    targets: [
        .target(
            name: "MusicPlaylistApp",
            path: "MusicPlaylistApp"),
        .testTarget(
            name: "MusicPlaylistAppTests",
            dependencies: ["MusicPlaylistApp"],
            path: "MusicPlaylistAppTests")
    ]
)
