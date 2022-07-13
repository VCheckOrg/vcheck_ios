//
//  FlowLogicExtensions.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.05.2022.
//

import Foundation
import AVFoundation
import SceneKit
@_implementationOnly import ARCore


// MARK: - Matrix (face coords calc) extensions

extension simd_float4x4 {

    // Function to convert rad to deg
    func radiansToDegress(radians: Float32) -> Float32 {
        return radians * 180 / (Float32.pi)
    }

    // Retrieve euler angles from a quaternion matrix
    var eulerAngles: FaceAnglesHolder {
        get {
            // Get quaternions
            let qw = sqrt(1 + self.columns.0.x + self.columns.1.y + self.columns.2.z) / 2.0
            let qx = (self.columns.2.y - self.columns.1.z) / (qw * 4.0)
            let qy = (self.columns.0.z - self.columns.2.x) / (qw * 4.0)
            let qz = (self.columns.1.x - self.columns.0.y) / (qw * 4.0)

            // Deduce euler angles
            /// yaw (z-axis rotation)
            let siny = +2.0 * (qw * qz + qx * qy)
            let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
            let actualRoll = radiansToDegress(radians:atan2(siny, cosy))
            // pitch (y-axis rotation)
            let sinp = +2.0 * (qw * qy - qz * qx)
            var pitch: Float
            if abs(sinp) >= 1 {
                pitch = radiansToDegress(radians:copysign(Float.pi / 2, sinp))
            } else {
                pitch = radiansToDegress(radians:asin(sinp))
            }
            /// roll (x-axis rotation)
            let sinr = +2.0 * (qw * qx + qy * qz)
            let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
            let yaw = -radiansToDegress(radians:atan2(sinr, cosr))

            /// return array containing ypr values
            return FaceAnglesHolder(pitch: pitch, yaw: yaw, roll: actualRoll)
            //! actualPitch was roll; ! actualYaw was pitch; ! actualRoll was yaw
        }
    }
}


// MARK: - Mouth calc extensions

extension LivenessScreenViewController {

    func calculateMouthFactor(face: GARAugmentedFace) -> Float {
        let h1 = MouthCalcCoordsHolder.init(x1: face.mesh.vertices[37].x, x2: face.mesh.vertices[83].x, y1: face.mesh.vertices[37].y,
                                            y2: face.mesh.vertices[83].y, z1: face.mesh.vertices[37].z, z2: face.mesh.vertices[83].z)
        let h2 = MouthCalcCoordsHolder.init(x1: face.mesh.vertices[267].x, x2: face.mesh.vertices[314].x, y1: face.mesh.vertices[267].y,
                                            y2: face.mesh.vertices[314].y, z1: face.mesh.vertices[267].z, z2: face.mesh.vertices[314].z)
        let h3 = MouthCalcCoordsHolder.init(x1: face.mesh.vertices[61].x, x2: face.mesh.vertices[281].x, y1: face.mesh.vertices[61].y,
                                            y2: face.mesh.vertices[281].y, z1: face.mesh.vertices[61].z, z2: face.mesh.vertices[281].z)

        return landmarksToMouthAspectRatio(h1: h1, h2: h2, h3: h3)
    }

    func landmarksToMouthAspectRatio(h1: MouthCalcCoordsHolder, h2: MouthCalcCoordsHolder, h3: MouthCalcCoordsHolder) -> Float {

        let a = euclidean(coordsHolder: h1)
        let b = euclidean(coordsHolder: h2)
        let c = euclidean(coordsHolder: h3)

        return (a + b / (2.0 * c)) * 1.2  //! 1.2 is a factor for making result more precise!
    }

    func euclidean(coordsHolder: MouthCalcCoordsHolder) -> Float {
        let calc = pow((coordsHolder.x1 - coordsHolder.x2), 2) + pow((coordsHolder.y1 - coordsHolder.y2), 2) + pow((coordsHolder.z1 - coordsHolder.z2), 2)
        return sqrt(calc)
    }
}


// MARK: - Coords' util structs

struct MouthCalcCoordsHolder {

    let x1: Float
    let x2: Float
    let y1: Float
    let y2: Float
    let z1: Float
    let z2: Float
}

struct FaceAnglesHolder {

    let pitch: Float
    let yaw: Float
    let roll: Float
}
