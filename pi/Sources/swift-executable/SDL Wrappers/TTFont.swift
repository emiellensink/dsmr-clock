import SDL2_TTF

final class TTFont {

    let pointer: OpaquePointer

    init?(file: String, size: Int) {
        if let font = TTF_OpenFont(file, Int32(size)) {
            self.pointer = font
        } else {
            return nil
        }
    }

    deinit {
        print("DEINIT TTFONT")
        TTF_CloseFont(pointer)
    }
}
