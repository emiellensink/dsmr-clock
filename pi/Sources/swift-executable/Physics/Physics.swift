import Foundation
import Chipmunk

final class Physics {
    let space: OpaquePointer?
    //let ground: OpaquePointer?
    let leftWall: OpaquePointer?
    let rightWall: OpaquePointer?

    init() {
        space = cpSpaceNew()
        let gravity = cpv(0, -400) //cpv(0, -980)
        cpSpaceSetGravity(space, gravity)

        // ground = cpSegmentShapeNew(
        //     cpSpaceGetStaticBody(space), 
        //     cpv(0, 96), 
        //     cpv(Double(Constants.Dimensions.width), 96), 
        //     0
        // )

        // cpShapeSetFriction(ground, 1)
        // cpShapeSetElasticity(ground, 0.6)
        // cpSpaceAddShape(space, ground)

        for n in 0 ..< 8 {
            let offset = -3.141592654 / 2.0
            let step = 3.141592654 / 8.0
            let r1 = Double(n) * step + offset
            let r2 = Double(n + 1) * step + offset

            let centerX = Double(Constants.Dimensions.width) / 2.0
            let centerY = Double(Constants.Dimensions.height) / 2.0

            let x1 = centerX + centerX * sin(r1)
            let y1 = centerY + centerY * cos(r1)
            let x2 = centerX + centerX * sin(r2)
            let y2 = centerY + centerY * cos(r2)

            let ground = cpSegmentShapeNew(
                cpSpaceGetStaticBody(space), 
                cpv(cpFloat(x1), cpFloat(Double(Constants.Dimensions.height) - y1)), 
                cpv(cpFloat(x2), cpFloat(Double(Constants.Dimensions.height) - y2)), 
                0
            )

            cpShapeSetFriction(ground, 0.8)
            cpShapeSetElasticity(ground, 0.6)
            cpSpaceAddShape(space, ground)
        }

        leftWall = cpSegmentShapeNew(
            cpSpaceGetStaticBody(space), 
            cpv(0, 0), 
            cpv(0, Double(Constants.Dimensions.height)), 
            0
        )

        cpShapeSetFriction(leftWall, 0)
        cpShapeSetElasticity(leftWall, 1)
        cpSpaceAddShape(space, leftWall)

        rightWall = cpSegmentShapeNew(
            cpSpaceGetStaticBody(space), 
            cpv(Double(Constants.Dimensions.width), 0), 
            cpv(Double(Constants.Dimensions.width), Double(Constants.Dimensions.height)), 
            0
        )

        cpShapeSetFriction(rightWall, 0)
        cpShapeSetElasticity(rightWall, 1)
        cpSpaceAddShape(space, rightWall)
    }

    func step() {
        let timestep: cpFloat = 1.0/60.0
        cpSpaceStep(space, timestep)
    }

    deinit {
        //cpShapeFree(ground)
        cpSpaceFree(space)
        cpSpaceFree(leftWall)
        cpSpaceFree(rightWall)
    }
}