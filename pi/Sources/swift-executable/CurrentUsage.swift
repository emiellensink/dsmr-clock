import Foundation

final class CurrentUsage {
    private(set) var renderables: [Renderable]
    private let renderer: OpaquePointer?
    private let font: TTFont
    private let symbols: TTFont

    private let suggestedY = 0.05 * Double(Constants.Dimensions.height)

    var usage = 0.0 {      // In kWh
        didSet {
            updateRenderable()
        }
    }
    
    init(renderer: OpaquePointer?, font: TTFont, symbols: TTFont) {
        self.renderer = renderer
        self.font = font
        self.symbols = symbols

        let renderable = RenderableText(
            text: "Hello", 
            font: font, 
            color: Color(r: 1.0, g: 1.0, b: 1.0), 
            renderer: renderer
        )

        renderable.x = Double(Constants.Dimensions.width) / 2.0
        renderable.y = suggestedY

        self.renderables = [renderable]
    }

    private func updateRenderable() {
        let usageInWatt = Int(abs(usage * 1000))
        let text = usage > 0 ? "\(usageInWatt) Wh" : "\(usageInWatt) Wh"
        let symbol = usage > 0 ? "▲" : "▼"
        let color = usage > 0 ? Color(r: 0.25, g: 1.0, b: 0.25): Color(r: 1.0, g: 0.25, b: 0.25)

        let renderable = RenderableText(
            text: text, 
            font: font, 
            color: color, 
            renderer: renderer,
            hook: .leading
        )

        let symbolRenderable = RenderableText(
            text: symbol, 
            font: symbols, 
            color: color, 
            renderer: renderer,
            hook: .leading
        )

        renderable.y = suggestedY
        symbolRenderable.y = suggestedY

        let totalWidth = renderable.width + symbolRenderable.width + 10
        let start = Double(Constants.Dimensions.width) / 2.0 - Double(totalWidth) / 2.0
        symbolRenderable.x = start
        renderable.x = start + 10.0 + Double(symbolRenderable.width)
        
        self.renderables = [symbolRenderable, renderable]
    }
}
