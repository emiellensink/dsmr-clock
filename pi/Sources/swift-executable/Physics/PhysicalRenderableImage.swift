import Foundation
import Chipmunk

final class PhysicalRenderableImage: RenderableImage {
    let physics: Physics

    var shape: OpaquePointer?
    var body: OpaquePointer?

    let text: String

    init(image: String, color: Color, renderer: OpaquePointer?, physics: Physics, maxWidth: Double) {
        self.physics = physics
        self.text = image

        super.init(image: text, color: color, renderer: renderer, hook: .center, maxWidth: maxWidth)

        let mass = cpFloat(Double(width) * Double(height))
        let moment = cpMomentForBox(mass, cpFloat(width), cpFloat(height))

        let body = cpSpaceAddBody(physics.space, cpBodyNew(mass, moment))
        let shape = cpSpaceAddShape(physics.space, cpBoxShapeNew(body, cpFloat(width), cpFloat(height), cpFloat(0)))

        cpShapeSetFriction(shape, 0.4)
        cpShapeSetElasticity(shape, 0.4)

        self.shape = shape
        self.body = body
    }

    override var x: Double {
        get {
            let current = cpBodyGetPosition(body)
            return Double(current.x)
        }
        set {
            var current = cpBodyGetPosition(body)
            current.x = cpFloat(newValue)
            cpBodySetPosition(body, current)
        }
    }

    override var y: Double {
        get {
            let current = cpBodyGetPosition(body)
            let translated = cpVect(x: x, y: Double(Constants.Dimensions.height) - current.y)
            return Double(translated.y)

        }
        set {
            var current = cpBodyGetPosition(body)
            current.y = Double(Constants.Dimensions.height) - cpFloat(newValue)
            cpBodySetPosition(body, current)
        }
    }

    override var angle: Double {
        get {
            let current = cpBodyGetAngle(body)
            let translated = -57.2957795131 * current
            return translated
        }
        set {
            cpBodySetAngle(body, cpFloat(-newValue / 57.2957795131))
        }
    }

    deinit {
        cpSpaceRemoveBody(physics.space, body)
        cpSpaceRemoveShape(physics.space, shape)
        cpShapeFree(shape)
        cpBodyFree(body)
    }
}