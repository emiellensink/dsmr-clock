// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-executable",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [ ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .systemLibrary(
            name: "SDL2", 
            pkgConfig: "sdl2", 
            providers: [.apt(["libsdl2-dev"])]
        ),

        .systemLibrary(
            name: "SDL2_Image", 
            pkgConfig: "sdl2_image", 
            providers: [.apt(["libsdl2-image-dev"])]
        ),

        .systemLibrary( 
            name: "SDL2_TTF", 
            pkgConfig: "sdl2_ttf", 
            providers: [.apt(["libsdl2-ttf-dev"])]
        ),

        .systemLibrary( 
            name: "Chipmunk", 
            pkgConfig: "chipmunk", 
            providers: [.apt(["libchipmunk-dev"])]
        ),

        .executableTarget(
            name: "swift-executable",
            dependencies: [
                "SDL2", "SDL2_TTF", "SDL2_Image", "Chipmunk"
            ]),
    ]
)
