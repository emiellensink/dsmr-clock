import Foundation

final class TotalUsage {
    var loading = false {
        didSet { 
            if loading { updateLoadingState() }
        }
    }
    private var isDark = false {
        didSet { updateRenderables() }
    }

    private(set) var renderables: [Renderable] = []

    private let renderer: OpaquePointer?
    private let font: TTFont
    private let symbols: TTFont

    private var lightBlock: RenderableText
    private var darkBlock: RenderableText

    private var greenArrow: RenderableText
    private var redArrow: RenderableText

    private var greenText: RenderableText
    private var redText: RenderableText

    var totalReceived: Double = 0.0 {
        didSet { updateReceived() }
    }
    var totalDelivered: Double = 0.0 {
        didSet { updateDelivered() }
    }

    private var initialReceived: Double = 0.0
    private var initialDelivered: Double = 0.0

    private let suggestedY = 0.1 * Double(Constants.Dimensions.height)

    private var currentDay = -1

    init(renderer: OpaquePointer?, font: TTFont, symbols: TTFont) { 
        self.renderer = renderer
        self.font = font
        self.symbols = symbols

        lightBlock = RenderableText(
            text: "■", 
            font: symbols, 
            color: Color(r: 1.0, g: 1.0, b: 1.0), 
            renderer: renderer
        )

        darkBlock = RenderableText(
            text: "■", 
            font: symbols, 
            color: Color(r: 0.5, g: 0.5, b: 0.5), 
            renderer: renderer
        )

        greenArrow = RenderableText(
            text: "▴", 
            font: symbols, 
            color: Color(r: 0.5, g: 1.0, b: 0.5), 
            renderer: renderer,
            hook: .leading
        )

        redArrow = RenderableText(
            text: "▾", 
            font: symbols, 
            color: Color(r: 1.0, g: 0.5, b: 0.5), 
            renderer: renderer,
            hook: .trailing
        )

        greenText = RenderableText(
            text: "---", 
            font: font, 
            color: Color(r: 0.5, g: 1.0, b: 0.5), 
            renderer: renderer,
            hook: .leading
        )

        redText = RenderableText(
            text: "---", 
            font: font, 
            color: Color(r: 1.0, g: 0.5, b: 0.5), 
            renderer: renderer,
            hook: .trailing
        )

        updateRenderables()
    }

    private func updateReceived() {
        if initialReceived == 0.0 {
            initialReceived = totalReceived
        }

        updateRenderableTextRed()
    }
    
    private func updateDelivered() {
        if initialDelivered == 0.0 {
            initialDelivered = totalDelivered
        }

        updateRenderableTextGreen()
    }

    private func updateRenderableTextRed() {
        let value = Int((totalReceived - initialReceived) * 1000)

        redText = RenderableText(
            text: "\(value)", 
            font: font, 
            color: Color(r: 1.0, g: 0.5, b: 0.5), 
            renderer: renderer,
            hook: .trailing
        )
        
        updateRenderables()
    }

    private func updateRenderableTextGreen() {
        let value = Int((totalDelivered - initialDelivered) * 1000)

        greenText = RenderableText(
            text: "\(value)", 
            font: font, 
            color: Color(r: 0.5, g: 1.0, b: 0.5), 
            renderer: renderer,
            hook: .leading
        )

        updateRenderables()
    }

    private func updateRenderables() {
        let date = Date()
        let hms = Calendar.current.dateComponents([.day], from: date)
        let day = hms.day!

        if day != currentDay {
            initialDelivered = totalDelivered
            initialReceived = totalReceived
            currentDay = day

            updateRenderableTextGreen()
            updateRenderableTextRed()
        }

        var renderables = [greenArrow, redArrow, greenText, redText]

        let centerX = Double(Constants.Dimensions.width) / 2.0

        lightBlock.x = centerX
        darkBlock.x = centerX
        renderables.append(isDark ? darkBlock : lightBlock)

        redText.x = centerX - 20
        redArrow.x = centerX - Double(redText.width) - 20

        greenArrow.x = centerX + 20
        greenText.x = centerX + Double(greenArrow.width) + 20

        for renderable in renderables {
            renderable.y = suggestedY
        }

        self.renderables = renderables
    }

    private func updateLoadingState() {
        if loading {
            isDark.toggle()

            let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.updateLoadingState()
            }
        } else {
            isDark = false
        }
    }
}
