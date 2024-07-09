import Foundation

final class TimeDropper {
    private let renderer: OpaquePointer?
    private let physics: Physics

    var hue = 0.0

    private var currentHour = ""
    private var currentMinute = ""
    private var currentSecond = ""

    private var hourRenderables: [PhysicalRenderableText?] = []
    private var minuteRenderables: [PhysicalRenderableText?] = []
    private var secondRenderables: [PhysicalRenderableText?] = []

    private let hourFont: TTFont
    private let minuteFont: TTFont
    private let secondFont: TTFont

    var renderables: [Renderable] {
        (hourRenderables + minuteRenderables + secondRenderables)
            .compactMap { $0 }
    }

    init(renderer: OpaquePointer?, physics: Physics, hourFont: TTFont, minuteFont: TTFont, secondFont: TTFont) {
        self.renderer = renderer
        self.physics = physics
        self.hourFont = hourFont
        self.minuteFont = minuteFont
        self.secondFont = secondFont
    }

    func tick() {
        let date = Date()
        let hms = Calendar.current.dateComponents([.hour, .minute, .second], from: date)

        let hour = String("0\(hms.hour!)".suffix(2))
        let minute = String("0\(hms.minute!)".suffix(2))
        let second = String("0\(hms.second!)".suffix(2))

        Task { @MainActor in
            if hour != currentHour {
                currentHour = hour
                let item = PhysicalRenderableText(
                    text: hour, 
                    font: hourFont, 
                    color: Color(h: hue, s: 0.45, l: 0.8), 
                    renderer: renderer, 
                    physics: physics
                )

                item.x = 0.2 * Double(Constants.Dimensions.width)
                item.y = -100

                hourRenderables = [item]
            }

            if minute != currentMinute {
                currentMinute = minute
                let item = PhysicalRenderableText(
                    text: minute, 
                    font: minuteFont, 
                    color: Color(h: hue, s: 0.45, l: 0.6), 
                    renderer: renderer, 
                    physics: physics
                )

                item.x = 0.7 * Double(Constants.Dimensions.width)
                item.y = -100

                minuteRenderables = [item]
                removeSeconds(count: secondRenderables.count)
            }

            if second != currentSecond {
                currentSecond = second

                let item = PhysicalRenderableText(
                    text: second, 
                    font: secondFont, 
                    color: Color(h: hue, s: 0.5, l: Double.random(in: 0.4 ..< 1.0)), 
                    renderer: renderer, 
                    physics: physics
                )

                let x = 60 + (hms.second! * 30 % (Constants.Dimensions.width - 120))

                item.x = Double(x)
                item.y = -100

                secondRenderables.append(item)
            }
        }
    }

    func removeSeconds(count: Int) {
        if count > 0, secondRenderables.count > 0 {
            secondRenderables.removeFirst()

            if count - 1 > 0, secondRenderables.count > 0 {
                let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    self.removeSeconds(count: count - 1)
                }
            }
        }
    }
}
