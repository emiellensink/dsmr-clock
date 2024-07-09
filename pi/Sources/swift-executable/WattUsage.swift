import Foundation
import SDL2_Image

final class WattUsage {
    private let renderer: OpaquePointer?
    private let physics: Physics

    private(set) var hue = 60.0
    private(set) var renderables: [Renderable] = []

    var totalDelivered: Double = 0.0 {
        didSet {
            update()
        }
    }
    var totalReceived: Double = 0.0 {
        didSet {
            update()
        }
    }

    private var lastIn = 0.0
    private var lastOut = 0.0

    private var wattIn = 0.0
    private var wattOut = 0.0

    init(renderer: OpaquePointer?, physics: Physics) {
        self.renderer = renderer
        self.physics = physics

        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.removeOldRenderables()
        }
    }

    private func removeOldRenderables() {
        renderables = renderables
            .filter { $0.age < 10.0 }
    }

    private func update() {
        if lastIn != 0.0 {
            wattIn += 1000.0 * (totalReceived - lastIn)
        }

        if lastOut != 0.0 {
            wattOut += 1000.0 * (totalDelivered - lastOut)
        }

        lastIn = totalReceived
        lastOut = totalDelivered

        doWattIn()
        doWattOut()
    }

    private func doWattIn() {
        if wattIn > 1.0 {
            if hue > 0.1 { hue -= 0.1; }

            let color = Color(
                h: Double.random(in: 0.0 ..< 10.0),
                s: 1.0,
                v: Double.random(in: 0.8 ..< 1.0)
            ) 

            let plug = PhysicalRenderableImage(
                image: "powerplug.fill", 
                color: color, 
                renderer: renderer,
                physics: physics,
                maxWidth: Double(Constants.Dimensions.width / 15)
            )

            plug.x = Double.random(in: 30.0 ..< Double(Constants.Dimensions.width - 30))
            plug.y = -100

            renderables.append(plug)

            wattIn -= 1.0
            if wattIn > 1.0 { 
                let next = 10.0 / wattIn
                let _ = Timer.scheduledTimer(withTimeInterval: next, repeats: false) { _ in
                    self.doWattIn()
                }
            }
        }
    }

    private func doWattOut() {
        if wattOut > 1.0 {
            if hue < 120.0 { hue += 0.1 }

            let color = Color(
                h: Double.random(in: 55.0 ..< 65.0),
                s: 1.0,
                v: Double.random(in: 0.8 ..< 1.0)
            ) 

            let sun = PhysicalRenderableImage(
                image: "sun.max.fill", 
                color: color,
                renderer: renderer,
                physics: physics,
                maxWidth: Double(Constants.Dimensions.width / 15)
            )

            sun.x = Double.random(in: 30.0 ..< Double(Constants.Dimensions.width - 30))
            sun.y = -100

            renderables.append(sun)

            wattOut -= 1.0
            if wattOut > 1.0 { 
                let next = 10.0 / wattOut
                let _ = Timer.scheduledTimer(withTimeInterval: next, repeats: false) { _ in
                    self.doWattOut()
                }
            }
        }
    }
}