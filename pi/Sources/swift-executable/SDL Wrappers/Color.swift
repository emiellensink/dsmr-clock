import Foundation
import SDL2

final class Color {
    let r: Double
    let g: Double
    let b: Double
    let a: Double

    init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init(h: Double, s: Double, v: Double, a: Double = 1.0) {      // H = 0...360
        let value = Color.hsv2rgb(h: h, s: s, v: v)
        self.r = value.r
        self.g = value.g
        self.b = value.b
        self.a = a
    }

    init(h: Double, s: Double, l: Double, a: Double = 1.0) {      // H = 0...360
        let value = Color.hsl2rgb(h: h / 360.0, s: s, l: l)
        self.r = value.r
        self.g = value.g
        self.b = value.b
        self.a = a
    }

    var sdlColor: SDL_Color {
        SDL_Color(
            r: UInt8(r * 255.0), 
            g: UInt8(g * 255.0), 
            b: UInt8(b * 255.0), 
            a: UInt8(a * 255.0)
        )
    }

    // MARK: - Private stuff

    static private func hue2rgb(p: Double, q: Double, t: Double) -> Double {
        var t = t

        if t < 0 { t += 1 }
        if t > 1 { t -= 1} 
        if t < 1.0 / 6.0 { return p + (q - p) * 6 * t }
        if t < 1.0 / 2.0 { return q } 
        if t < 2.0 / 3.0 { return p + (q - p) * (2.0 / 3.0 - t) * 6}   

        return p
    }

    static private func hsl2rgb(h: Double, s: Double, l: Double) -> (r: Double, g: Double, b: Double) {
        var r = 0.0
        var g = 0.0
        var b = 0.0

        if s == 0.0 {
            r = l
            g = l
            b = l
        } else {
            let q = l < 0.5 ? l * (1 + s) : l + s - l * s
            let p = 2.0 * l - q
            r = hue2rgb(p: p, q: q, t: h + 1.0 / 3.0)
            g = hue2rgb(p: p, q: q, t: h)
            b = hue2rgb(p: p, q: q, t: h - 1.0 / 3.0)
        }

        return (r: r, g: g, b: b)
    }

    static private func hsv2rgb(h: Double, s: Double, v: Double) -> (r: Double, g: Double, b: Double) {

        let h = h / 360.0
        
        let i = floor(h * 6)
        let f = h * 6.0 - i
        let p = v * (1.0 - s)
        let q = v * (1.0 - f * s)
        let t = v * (1.0 - (1 - f) * s)
        
        var r = 0.0
        var g = 0.0
        var b = 0.0

        switch Int(i) % 6 {
            case 0: r = v; g = t; b = p
            case 1: r = q; g = v; b = p
            case 2: r = p; g = v; b = t
            case 3: r = p; g = q; b = v
            case 4: r = t; g = p; b = v
            case 5: r = v; g = p; b = q
            default:
                break
        }
        
        return (r: r, g: g, b: b)
    }
}
