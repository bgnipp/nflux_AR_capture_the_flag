import PackageDescription

let package = Package(
    name: "nflux_2017_july_swift_3",
    dependencies: [
        .Package(url: "https://github.com/socketio/socket.io-client-swift", majorVersion: 10)
    ]
)
