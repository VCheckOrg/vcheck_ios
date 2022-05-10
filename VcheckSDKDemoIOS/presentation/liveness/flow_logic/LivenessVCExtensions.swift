//
//  LivenessVCExtensions.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.05.2022.
//

import Foundation
import AVFoundation
import CoreMedia
import CoreMotion
import SceneKit
import UIKit
import ARCore
import Lottie
import Vision


// MARK: - camera & scene setup

extension LivenessScreenViewController {
    
    func getBrightness(sampleBuffer: CMSampleBuffer) -> Double {
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        let brightnessValue : Double = exifData?[kCGImagePropertyExifBrightnessValue as String] as! Double
        return brightnessValue
    }
    
    /// Setup a camera capture session from the front camera to receive captures.
    /// - Returns: true when the function has fatal error; false when not.
    func setupCamera() -> Bool {
        guard
            let device =
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        else {
            alertWindowTitle = "A fatal error occurred."
            alertMessage = "Failed to get device from AVCaptureDevice."
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
            return false
        }
        guard
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            alertWindowTitle = "A fatal error occurred."
            alertMessage = "Failed to get device input from AVCaptureDeviceInput."
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
            return false
        }
        
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
        
        let session = AVCaptureSession()
        session.sessionPreset = .high
        session.addInput(input)
        session.addOutput(output)
        captureSession = session
        captureDevice = device
        
        videoFieldOfView = captureDevice?.activeFormat.videoFieldOfView ?? 0
        
        cameraImageLayer.contentsGravity = .center
        cameraImageLayer.frame = self.view.bounds
        view.layer.insertSublayer(cameraImageLayer, at: 0)
        
        // Start capturing images from the capture session once permission is granted.
        getVideoPermission(permissionHandler: { granted in
            guard granted else {
                NSLog("Permission not granted to use camera.")
                self.alertWindowTitle = "Alert"
                self.alertMessage = "Permission not granted to use camera."
                self.popupAlertWindowOnError(
                    alertWindowTitle: self.alertWindowTitle, alertMessage: self.alertMessage)
                return
            }
            self.captureSession?.startRunning()
        })
        
        return true
    }
    
    /// Create the scene view from a scene and supporting nodes, and add to the view.
    /// The scene is loaded from 'fox_face.scn' which was created from 'canonical_face_mesh.fbx', the
    /// canonical face mesh asset.
    /// https://developers.google.com/ar/develop/developer-guides/creating-assets-for-augmented-faces
    /// - Returns: true when the function has fatal error; false when not.
    func setupScene() -> Bool {
        
        guard let scene = SCNScene(named: "Face.scnassets/liveness_scene.scn")
        else {
            alertWindowTitle = "A fatal error occurred."
            alertMessage = "Failed to load face scene!"
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
            return false
        }
        
        let cameraNode = SCNNode()
        cameraNode.camera = sceneCamera
        scene.rootNode.addChildNode(cameraNode)
        
        sceneView.scene = scene
        sceneView.frame = view.bounds
        sceneView.delegate = self
        sceneView.rendersContinuously = true
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.backgroundColor = .clear
        // Flip 'x' to mirror content to mimic 'selfie' mode
        sceneView.layer.transform = CATransform3DMakeScale(-1, 1, 1)
        view.addSubview(sceneView)
        
        return true
    }
    
    /// Start receiving motion updates to determine device orientation for use in the face session.
    /// - Returns: true when the function has fatal error; false when not.
    func setupMotion() -> Bool {
        guard motionManager.isDeviceMotionAvailable else {
            alertWindowTitle = "Alert"
            alertMessage = "Device does not have motion sensors."
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
            return false
        }
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdates()
        
        return true
    }
}


// MARK: - Multiple faces detection

extension LivenessScreenViewController {
    
    func detectFacesOnFrameOutput(buffer: CVImageBuffer) {
        detectFaces(on: convertCVImageBufferToUIImage(buffer: buffer))
    }
    
    func convertCVImageBufferToUIImage(buffer: CVImageBuffer) -> UIImage {
        let ciImage: CIImage = CIImage(cvPixelBuffer: buffer)
        return ciImage.orientationCorrectedImage()!
    }
    
    func detectFaces(on image: UIImage) {
      let handler = VNImageRequestHandler(
        cgImage: image.cgImage!,
        options: [:])
      
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          try handler.perform([self.faceDetectionRequest])
        } catch {
          print(error)
        }
      }
    }
}


// MARK: - Permission and alert util

extension LivenessScreenViewController {
    
    /// Get permission to use device camera.
    ///
    /// - Parameters:
    ///   - permissionHandler: The closure to call with whether permission was granted when
    ///     permission is determined.
    func getVideoPermission(permissionHandler: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionHandler(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: permissionHandler)
        default:
            permissionHandler(false)
        }
    }
    
    func popupAlertWindowOnError(alertWindowTitle: String, alertMessage: String) {
        if !self.viewDidAppearReached {
            self.needToShowFatalError = true
            // Then the process will proceed to viewDidAppear, which will popup an alert window when needToShowFatalError is true.
            return
        }
        // viewDidAppearReached is true, so we can pop up window now.
        let alertController = UIAlertController(
            title: alertWindowTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "Default action"), style: .default,
                handler: { _ in
                    self.needToShowFatalError = false
                }))
        self.present(alertController, animated: true, completion: nil)
    }
}


//DispatchQueue.main.async {
//CATransaction.begin()
//print("DETECTED FACES: \(results.count)")
//        for result in results {
//          //print(result.boundingBox)
//          // self.drawFace(in: result.boundingBox)
//        }
//CATransaction.commit()

//extension UIDevice {
//    static var isSimulator: Bool = {
//        #if targetEnvironment(simulator)
//        return true
//        #else
//        return false
//        #endif
//    }()

//DispatchQueue.global(qos: .userInitiated).async {
//    print("This is run on a background queue")
//
//    DispatchQueue.main.async {
//        print("This is run on the main queue, after the previous code in outer block")
//    }
//}

//    func delay(_ delay:Double, closure:@escaping ()->()) {
//        let when = DispatchTime.now() + delay
//        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
//    }

//      let mouthOpen: Bool = mouthAngle > 0.39
//      let turnedLeft: Bool = faceAnglesHolder.pitch < -30
//      let turnedRight: Bool = faceAnglesHolder.pitch > 30

//faceAnimationView.transform = CGAffineTransform(rotationAngle: CGFloat.pi) //rotate by 180 deg.
//faceAnimationView.loopMode = .autoReverse
//faceAnimationView.play()
