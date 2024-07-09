// The Swift Programming Language
// https://docs.swift.org/swift-book

import SDL2
import SDL2_TTF
import SDL2_Image
import Chipmunk

import Foundation

guard SDL_Init(SDL_INIT_VIDEO) == 0 else {
    fatalError("SDL init failed.")
}

guard TTF_Init() == 0 else {
    fatalError("TTF init failed.")
}

// Create a window at the center of the screen with 800x600 pixel resolution
let window = SDL_CreateWindow(
    "DSMR",
    Int32(SDL_WINDOWPOS_CENTERED_MASK), 
    Int32(SDL_WINDOWPOS_CENTERED_MASK),
    Int32(Constants.Dimensions.width), 
    Int32(Constants.Dimensions.height),
    SDL_WINDOW_SHOWN.rawValue
)

let renderer = SDL_CreateRenderer(
    window, 
    -1, 
    SDL_RENDERER_ACCELERATED.rawValue | SDL_RENDERER_PRESENTVSYNC.rawValue
)

SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1")

guard let hourFont = TTFont(file: FontFinder.fontFile(for: "Ubuntu-Medium"), size: Constants.Dimensions.height / 3) else { fatalError("Could not open font")}
guard let minuteFont = TTFont(file: FontFinder.fontFile(for: "Ubuntu-Medium"), size: Constants.Dimensions.height / 4) else { fatalError("Could not open font")}
guard let secondFont = TTFont(file: FontFinder.fontFile(for: "Ubuntu-Bold"), size: Constants.Dimensions.height / 14) else { fatalError("Could not open font")}

guard let usageFont = TTFont(file: FontFinder.fontFile(for: "Ubuntu-Bold"), size: Constants.Dimensions.height / 20) else { fatalError("Could not open font")}
guard let totalsFont = TTFont(file: FontFinder.fontFile(for: "Ubuntu-Bold"), size: Constants.Dimensions.height / 24) else { fatalError("Could not open font")}
guard let symbolFont = TTFont(file: FontFinder.fontFile(for: "Arial Unicode"), size: Constants.Dimensions.height / 22) else { fatalError("Could not open font")}

let color = Color(r: 1.0, g: 1.0, b: 1.0)
let physics = Physics()

var quit = false
var event = SDL_Event()

let timeDropper = TimeDropper(renderer: renderer, physics: physics, hourFont: hourFont, minuteFont: minuteFont, secondFont: secondFont)
let currentUsage = CurrentUsage(renderer: renderer, font: usageFont, symbols: symbolFont)
let totalUsage = TotalUsage(renderer: renderer, font: totalsFont, symbols: symbolFont)
let wattUsage = WattUsage(renderer: renderer, physics: physics)

var loading = false {
    didSet {
        totalUsage.loading = loading
    }
}

let secondsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
    timeDropper.hue = wattUsage.hue
    timeDropper.tick()
}

let datagramTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
    if !loading {
        loading = true
        Task {
            do {
                let datagram = try await DatagramClient.get()

                Task { @MainActor in 
                    currentUsage.usage = datagram.electricity.delivered.actual.reading > 0 
                    ? datagram.electricity.delivered.actual.reading
                    : -datagram.electricity.received.actual.reading

                    totalUsage.totalReceived = datagram.electricity.received.total.reading
                    totalUsage.totalDelivered = datagram.electricity.delivered.total.reading 

                    wattUsage.totalReceived = datagram.electricity.received.total.reading
                    wattUsage.totalDelivered = datagram.electricity.delivered.total.reading

                    loading = false
                }
            } catch let error {
                print(error)
                loading = false
            }
        }
    }
}

let frameTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
    while SDL_PollEvent(&event) > 0 {

        if event.type == SDL_QUIT.rawValue {
            exit(0)
        }
    }

    physics.step()

    let backgroundColor = Color(h: wattUsage.hue, s: 1.0, l: 0.1)

    SDL_SetRenderDrawColor(
        renderer, 
        UInt8(backgroundColor.r * 255), 
        UInt8(backgroundColor.g * 255), 
        UInt8(backgroundColor.b * 255), 
        255
    )

    SDL_RenderClear(renderer)

    // Render the time
    for renderable in timeDropper.renderables + wattUsage.renderables {
        renderable.render()
    }
    
    // SDL_SetRenderDrawColor(renderer, 64, 64, 64, 255)
    
    // for n in 0 ..< 16 {
    //     let offset = -3.141592654 / 2.0
    //     let step = 3.141592654 / 8.0
    //     let r1 = Double(n) * step + offset
    //     let r2 = Double(n + 1) * step + offset

    //     let centerX = Double(Constants.Dimensions.width) / 2.0
    //     let centerY = Double(Constants.Dimensions.height) / 2.0

    //     let x1 = centerX + centerX * sin(r1)
    //     let y1 = centerY + centerY * cos(r1)
    //     let x2 = centerX + centerX * sin(r2)
    //     let y2 = centerY + centerY * cos(r2)

    //     SDL_RenderDrawLine(renderer, Int32(x1), Int32(y1), Int32(x2), Int32(y2))
    // }

    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 80)
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)

    var rect = SDL_Rect(
        x: 0, 
        y: 0, 
        w: Int32(Constants.Dimensions.width), 
        h: Int32(Double(Constants.Dimensions.height) * 0.13)
    )
    SDL_RenderFillRect(renderer, &rect)

    for renderable in currentUsage.renderables + totalUsage.renderables {
        renderable.render()
    }
    
    SDL_RenderPresent(renderer)
}

RunLoop.current.run()

// Destroy the window
SDL_DestroyWindow(window)

// Quit all SDL systems
SDL_Quit()
