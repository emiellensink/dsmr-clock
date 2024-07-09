import Foundation
import SDL2
import SDL2_Image

class RenderableImage: Renderable {
    enum Hook {
        case leading
        case center
        case trailing
    }

    private let texture: OpaquePointer?
    private let renderer: OpaquePointer?

    let width: Int
    let height: Int

    let sourceWidth: Int32
    let sourceHeight: Int32

    var x = 0.0
    var y = 0.0
    var angle = 0.0
    var timestamp = Date()

    let hook: Hook
    let offset: SDL_Point

    init(
        image: String, 
        color: Color, 
        renderer: OpaquePointer?, 
        hook: Hook = .center, 
        offset: SDL_Point = SDL_Point(x: 0, y: 0),
        maxWidth: Double
    ) {        
        let surface = ImageCache.image(for: image)
        let texture = SDL_CreateTextureFromSurface(renderer, surface)
        
        SDL_SetTextureColorMod(
            texture, 
            UInt8(color.r * 255.0),
            UInt8(color.g * 255.0), 
            UInt8(color.b * 255.0)
        )

        self.texture = texture
        self.renderer = renderer

        let surfaceWidth = Double(surface.pointee.w)
        let surfaceHeight = Double(surface.pointee.h)

        let scaleFactor = maxWidth < surfaceWidth ? maxWidth / surfaceWidth : 1.0

        self.width = Int(surfaceWidth * scaleFactor)
        self.height = Int(surfaceHeight * scaleFactor)

        self.sourceWidth = Int32(surfaceWidth)
        self.sourceHeight = Int32(surfaceHeight)

        self.offset = offset
        self.hook = hook
    }

    deinit {
        SDL_DestroyTexture(texture)
    }

    func render() {
        var srcRect = SDL_Rect(x: 0, y: 0, w: sourceWidth, h: sourceHeight)
        var center: SDL_Point
        
        switch hook {
            case .leading: center = SDL_Point(x: 0, y: sdlHeight / 2)
            case .center: center = SDL_Point(x: sdlWidth / 2, y: sdlHeight / 2)
            case .trailing: center = SDL_Point(x: sdlWidth, y: sdlHeight / 2)
        }
        
        var dstRect = SDL_Rect(x: sdlX - center.x + offset.x, y: sdlY - center.y + offset.y, w: sdlWidth, h: sdlHeight)
        SDL_RenderCopyEx(renderer, texture, &srcRect, &dstRect, angle, &center, SDL_FLIP_NONE)
    }

    // MARK: Convenience

    var sdlX: Int32 { Int32(x) }
    var sdlY: Int32 { Int32(y) }
    var sdlWidth: Int32 { Int32(width) }
    var sdlHeight: Int32 { Int32(height) }
}
