//
//  SegmentationVCExtensions.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 08.08.2022.
//

import Foundation

import Foundation
import AVFoundation
import UIKit

// MARK: - Camera & Video Preview setup

extension SegmentationViewController {

    /// Setup a camera capture session from the front camera to receive captures.
    /// - Returns: true when the function has fatal error; false when not.
    func setupCamera() -> Bool {
        guard
            let device =
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
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
        session.sessionPreset = .iFrame960x540
        session.addInput(input)
        session.addOutput(output)
        captureSession = session
        captureDevice = device

        videoFieldOfView = captureDevice?.activeFormat.videoFieldOfView ?? 0
        
        self.previewLayer = {
            let preview = AVCaptureVideoPreviewLayer(session: self.captureSession!)
            preview.videoGravity = .resizeAspectFill //.resizeAspect
            return preview
        }()
        
        self.view.layer.insertSublayer(previewLayer, at: 0)

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
}

extension SegmentationViewController {

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
