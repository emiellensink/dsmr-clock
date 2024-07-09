import Foundation 
import SDL2_Image

final class ImageCache {
    private init() { }

    static var cache: [String: UnsafeMutablePointer<SDL_Surface>] = [:]

    static func image(for file: String) -> UnsafeMutablePointer<SDL_Surface> {
        if let item = cache[file] {
            return item
        } else {
            let path = ImageFinder.imageFile(for: file)
            let item = IMG_Load(path)!
            cache[file] = item
            return item
        }
    }
}
