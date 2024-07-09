import Foundation
import SDL2
import SDL2_TTF

protocol Renderable {
    func render()

    var x: Double { get set }
    var y: Double { get set }
    var angle: Double { get set }

    var timestamp: Date { get }

    var age: TimeInterval { get }
}

extension Renderable {
    var age: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }
}

class RenderableText: Renderable {
    enum Hook {
        case leading
        case center
        case trailing
    }

    private let surface: UnsafeMutablePointer<SDL_Surface>
    private let texture: OpaquePointer?
    private let renderer: OpaquePointer?

    let width: Int
    let height: Int

    var x = 0.0
    var y = 0.0
    var angle = 0.0
    var timestamp = Date()
    
    let hook: Hook
    let offset: SDL_Point

    init(
        text: String, 
        font: TTFont, 
        color: Color, 
        renderer: OpaquePointer?, 
        hook: Hook = .center, 
        offset: SDL_Point = SDL_Point(x: 0, y: 0)
    ) {        
        self.surface = TTF_RenderUTF8_Blended(font.pointer, text, color.sdlColor)
        self.texture = SDL_CreateTextureFromSurface(renderer, surface)
        self.renderer = renderer

        self.width = Int(surface.pointee.w)
        self.height = Int(surface.pointee.h)

        self.offset = offset
        self.hook = hook
    }

    deinit {
        SDL_FreeSurface(surface)
        SDL_DestroyTexture(texture)
    }

    func render() {
        var srcRect = SDL_Rect(x: 0, y: 0, w: sdlWidth, h: sdlHeight)
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
