import AVFoundation
import CoreMedia
import CoreMotion
import SceneKit
import UIKit
import ARCore
import Lottie

import Vision

/// Demonstrates how to use ARCore Augmented Faces with SceneKit.
public final class LivenessScreenViewController: UIViewController {
    
    
    // MARK: Outlets/Actions
    
    @IBOutlet weak var roundedView: RoundedView!
    
    @IBOutlet weak var leftArrowAnimHolderView: UIView!
    @IBOutlet weak var rightArrowAnimHolderView: UIView!
    
    @IBOutlet weak var tvLivenessInfo: UILabel!
    
    @IBOutlet weak var imgMilestoneChecked: UIImageView!
    @IBOutlet weak var indicationFrame: RoundedView!
    
    
    // MARK: - Anim properties
    var faceAnimationView: AnimationView = AnimationView()
    var arrowAnimationView: AnimationView = AnimationView()
    let hapticFeedbackGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Member Variables
    private var needToShowFatalError = false
    private var alertWindowTitle = "Nothing"
    private var alertMessage = "Nothing"
    private var viewDidAppearReached = false
    
    // MARK: - Camera / Scene properties
    private var captureDevice: AVCaptureDevice?
    private var captureSession: AVCaptureSession?
    private var videoFieldOfView = Float(0)
    private lazy var cameraImageLayer = CALayer()
    private lazy var sceneView = SCNView()
    private lazy var sceneCamera = SCNCamera()
    private lazy var motionManager = CMMotionManager()
    
    // MARK: - Face properties
    private var faceSession: GARAugmentedFaceSession?
    
    // MARK: - Milestone flow & logic
    private var milestoneFlow = StandardMilestoneFlow()
    
    static let LIVENESS_TIME_LIMIT_MILLIS = 14000 //max is 15000
    static let BLOCK_PIPELINE_ON_OBSTACLE_TIME_MILLIS = 1200 //may reduce a bit
    static let BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS = 1600 //may reduce a bit
    static let MAX_FRAMES_WITH_FATAL_OBSTACLES = 50
    //static let MIN_FRAMES_FOR_MINOR_OBSTACLES = 8
    
    private var multiFaceFrameCounter: Int = 0
    private var noFaceFrameCounter: Int = 0
    private var majorObstacleFrameCounter: Int = 0
    
    private var isLivenessSessionFinished: Bool = false
    private var hasEnoughTimeForNextGesture: Bool = true
    private var livenessSessionTimeoutTimer : DispatchSourceTimer?
    private var blockStageIndicationByUI: Bool = false

    
    // MARK: - Implementation & Lifecycle methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if !setupScene() { return }
        if !setupCamera() { return }
        if !setupMotion() { return }
        
        imgMilestoneChecked.isHidden = true
        indicationFrame.isHidden = true
        
        do {
            faceSession = try GARAugmentedFaceSession(fieldOfView: videoFieldOfView)
        } catch {
            alertWindowTitle = "A fatal error occurred."
            alertMessage = "Failed to create session. Error description: \(error)"
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearReached = true
        
        if needToShowFatalError {
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
        }
        
        startLivenessSessionTimeoutTimer()
        
        setupOrUpdateFaceAnimation(forMilestoneType: GestureMilestoneType.CheckHeadPositionMilestone)
        setupOrUpdateArrowAnimation(forMilestoneType: GestureMilestoneType.CheckHeadPositionMilestone)
    }
}


// MARK: - Scene Renderer delegate

extension LivenessScreenViewController: SCNSceneRendererDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = faceSession?.currentFrame else {
            NSLog("In renderer, currentFrame is nil.")
            return
        }
        
        if (isLivenessSessionFinished == false) {
            if (blockStageIndicationByUI == false) {
                updateFaceAnimation()
                updateArrowAnimation()
            }
            processFaceFrame(frame: frame)
        } else {
            if (self.livenessSessionTimeoutTimer != nil) {
                self.livenessSessionTimeoutTimer!.cancel()
            }
        }
    }
}

// MARK: - Frame processing at upper level

extension LivenessScreenViewController {
    
    func processFaceFrame(frame: GARAugmentedFaceFrame) {
        if let face = frame.face {
            
            if (!isLivenessSessionFinished) {
                processFaceCalcForFrame(face: face)
            }
            //try move to if (!isLivenessSessionFinished) for resources optimization
            updateCameraFrame(frame: frame)
            
            noFaceFrameCounter = 0
            // Only show AR content when a face is detected. //!
            sceneView.scene?.rootNode.isHidden = frame.face == nil

        } else {
            onObstableTypeMet(obstacleType: ObstacleType.NO_STRAIGHT_FACE_DETECTED)
        }
    }
    
    func processFaceCalcForFrame(face: GARAugmentedFace) {
        
        let mouthAngle = calculateMouthFactor(face: face)
        let faceAnglesHolder = face.centerTransform.eulerAngles
        
        milestoneFlow.checkCurrentStage(pitchAngle: faceAnglesHolder.pitch,
                                        mouthFactor: mouthAngle,
                                        yawAbsAngle: faceAnglesHolder.yaw,
                                        onMilestoneResult: { milestoneType in
            print("------- PASSED MILESTONE: \(milestoneType)")
            DispatchQueue.main.async {
                if (milestoneType == GestureMilestoneType.MouthOpenMilestone) {
                    self.hapticFeedbackGenerator.notificationOccurred(.success)
                    self.isLivenessSessionFinished = true
                    self.performSegue(withIdentifier: "LivenessToLocalSuccess", sender: nil)
                } else {
                    if (self.hasEnoughTimeForNextGesture) {
                        if (milestoneType != GestureMilestoneType.CheckHeadPositionMilestone) {
                            self.majorObstacleFrameCounter = -15
                            self.hapticFeedbackGenerator.notificationOccurred(.success)
                            //!
                            self.delayedStageIndicationRenew()
                        }
                        if (self.blockStageIndicationByUI == false) {
                            self.setupOrUpdateFaceAnimation(forMilestoneType: milestoneType)
                            self.setupOrUpdateArrowAnimation(forMilestoneType: milestoneType)
                        }
                        self.updateLivenessInfoText(forMilestoneType: milestoneType)
                    }
                }
            }
        },
        onObstacleMet: { obstacleType in
            onObstableTypeMet(obstacleType: obstacleType)
        })
        
        //      print("MOUTH: \(mouthAngle)\nPITCH: \(faceAnglesHolder.pitch)\nYAW: \(faceAnglesHolder.yaw)"
        //              + "\n\nMOUTH OPEN: \(mouthOpen)\n\nTURNED LEFT: \(turnedLeft)\n\nTURNED RIGHT: \(turnedRight)")
    }
    
    func onObstableTypeMet(obstacleType: ObstacleType) {
        //print("------- MET OBSTACLE: \(obstacleType)")
        if (obstacleType == ObstacleType.YAW_ANGLE) {
            DispatchQueue.main.async {
                self.hapticFeedbackGenerator.notificationOccurred(.warning) //?
                self.tvLivenessInfo.textColor = .red
                self.tvLivenessInfo.text = NSLocalizedString("line_face_obstacle", comment: "")
                DispatchQueue.main.asyncAfter(deadline:
                        .now() + .milliseconds(LivenessScreenViewController.BLOCK_PIPELINE_ON_OBSTACLE_TIME_MILLIS) ) {
                    self.updateLivenessInfoText(forMilestoneType: self.milestoneFlow.getUndoneStage().gestureMilestoneType)
                }
            }
        }
        if (obstacleType == ObstacleType.WRONG_GESTURE) {
            DispatchQueue.main.async {
                self.majorObstacleFrameCounter += 1
                //print("WRONG GESTURE FRAME COUNT: \(self.majorObstacleFrameCounter)")
                if (self.majorObstacleFrameCounter >= LivenessScreenViewController.MAX_FRAMES_WITH_FATAL_OBSTACLES) {
                    self.endSessionPrematurely()
                    self.performSegue(withIdentifier: "LivenessToWrongGesture", sender: nil)
                }
            }
        }
        if (obstacleType == ObstacleType.NO_STRAIGHT_FACE_DETECTED) {
            DispatchQueue.main.async {
                self.noFaceFrameCounter += 1
                print("NO STRAIGHT FACE FRAME COUNT: \(self.noFaceFrameCounter)")
                if (self.noFaceFrameCounter >= LivenessScreenViewController.MAX_FRAMES_WITH_FATAL_OBSTACLES) {
                    self.endSessionPrematurely()
                    self.performSegue(withIdentifier: "LivenessToNoFaceDetected", sender: nil)
                }
            }
        }
        if (obstacleType == ObstacleType.BRIGHTNESS_LEVEL_IS_LOW) {
//            DispatchQueue.main.async {
//                self.endSessionPrematurely()
//
//            }
            //TODO: add view controllers for error screens and UI for brightness obstacle!
        }
    }
    
    func endSessionPrematurely() {
        self.hapticFeedbackGenerator.notificationOccurred(.warning) //?
        self.majorObstacleFrameCounter = 0
        self.isLivenessSessionFinished = true
    }
    
    func startLivenessSessionTimeoutTimer() {
        let delay : DispatchTime = .now() + .milliseconds(LivenessScreenViewController.LIVENESS_TIME_LIMIT_MILLIS)
        if livenessSessionTimeoutTimer == nil {
            livenessSessionTimeoutTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            livenessSessionTimeoutTimer!.schedule(deadline: delay, repeating: 0)
            livenessSessionTimeoutTimer!.setEventHandler {
                self.hasEnoughTimeForNextGesture = false
                self.livenessSessionTimeoutTimer!.cancel()
                self.livenessSessionTimeoutTimer = nil
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LivenessToNoTime", sender: nil)
                }
            }
            livenessSessionTimeoutTimer!.resume()
        } else {
            livenessSessionTimeoutTimer?.schedule(deadline: delay, repeating: 0)
        }
    }
}


// MARK: - Animation extensions

extension LivenessScreenViewController {
    
    func delayedStageIndicationRenew() {
        DispatchQueue.main.async {
            self.blockStageIndicationByUI = true
            
            self.imgMilestoneChecked.isHidden = false
            self.indicationFrame.isHidden = false
            
            self.fadeViewInThenOut(view: self.indicationFrame, delay: 0.0)
            
            DispatchQueue.main.asyncAfter(deadline:
                    .now() + .milliseconds(LivenessScreenViewController.BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS) ) {
                        
                        self.imgMilestoneChecked.isHidden = true
                        self.indicationFrame.isHidden = true
                        
                        self.blockStageIndicationByUI = false
            }
        }
    }
    
    func updateLivenessInfoText(forMilestoneType: GestureMilestoneType) {
        self.tvLivenessInfo.textColor = .white
        if (forMilestoneType == GestureMilestoneType.CheckHeadPositionMilestone) {
            self.tvLivenessInfo.text = NSLocalizedString("liveness_stage_face_left", comment: "")
        } else if (forMilestoneType == GestureMilestoneType.OuterLeftHeadPitchMilestone) {
            self.tvLivenessInfo.text = NSLocalizedString("liveness_stage_face_right", comment: "")
        } else if (forMilestoneType == GestureMilestoneType.OuterRightHeadPitchMilestone) {
            self.tvLivenessInfo.text = NSLocalizedString("liveness_stage_open_mouth", comment: "")
        } else {
            self.tvLivenessInfo.text = NSLocalizedString("liveness_stage_check_face_pos", comment: "")
        }
    }
    
    func setupOrUpdateFaceAnimation(forMilestoneType: GestureMilestoneType) {
            
        if (forMilestoneType == GestureMilestoneType.CheckHeadPositionMilestone) {
            faceAnimationView = AnimationView(name: "left")
        } else if (forMilestoneType == GestureMilestoneType.OuterLeftHeadPitchMilestone) {
            faceAnimationView = AnimationView(name: "right")
        } else if (forMilestoneType == GestureMilestoneType.OuterRightHeadPitchMilestone) {
            faceAnimationView = AnimationView(name: "mouth")
        } else {
            faceAnimationView = AnimationView()
            faceAnimationView.stop()
        }
        
        faceAnimationView.contentMode = .scaleAspectFit
        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.addSubview(faceAnimationView)
        
        faceAnimationView.centerXAnchor.constraint(equalTo: roundedView.centerXAnchor, constant: 4).isActive = true
        faceAnimationView.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor).isActive = true
        
        faceAnimationView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        faceAnimationView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    
    }
    
    func setupOrUpdateArrowAnimation(forMilestoneType: GestureMilestoneType) {

        if (forMilestoneType == GestureMilestoneType.CheckHeadPositionMilestone) {
            arrowAnimationView = AnimationView(name: "arrow")
            
            arrowAnimationView.contentMode = .center
            arrowAnimationView.translatesAutoresizingMaskIntoConstraints = false
            leftArrowAnimHolderView.addSubview(arrowAnimationView)
            
            arrowAnimationView.centerXAnchor.constraint(equalTo: leftArrowAnimHolderView.centerXAnchor).isActive = true
            arrowAnimationView.centerYAnchor.constraint(equalTo: leftArrowAnimHolderView.centerYAnchor).isActive = true
            
            arrowAnimationView.heightAnchor.constraint(equalToConstant: 250).isActive = true
            arrowAnimationView.widthAnchor.constraint(equalToConstant: 250).isActive = true
            
            arrowAnimationView.loopMode = .loop
            
        } else if (forMilestoneType == GestureMilestoneType.OuterLeftHeadPitchMilestone) {
            
            leftArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
            
            arrowAnimationView = AnimationView(name: "arrow")
            
            arrowAnimationView.contentMode = .center
            arrowAnimationView.translatesAutoresizingMaskIntoConstraints = false
            rightArrowAnimHolderView.addSubview(arrowAnimationView)
            
            arrowAnimationView.centerXAnchor.constraint(equalTo: rightArrowAnimHolderView.centerXAnchor).isActive = true
            arrowAnimationView.centerYAnchor.constraint(equalTo: rightArrowAnimHolderView.centerYAnchor, constant: 25).isActive = true
            
            arrowAnimationView.heightAnchor.constraint(equalToConstant: 250).isActive = true
            arrowAnimationView.widthAnchor.constraint(equalToConstant: 250).isActive = true
            
            arrowAnimationView.transform = CGAffineTransform(rotationAngle: CGFloat.pi) //rotate by 180 deg.
            
            arrowAnimationView.loopMode = .loop
            
        } else {
            arrowAnimationView = AnimationView()
            arrowAnimationView.stop()
            rightArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
            leftArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    func updateFaceAnimation() {
        if (self.blockStageIndicationByUI == false) {
            DispatchQueue.main.async {
                let toProgress = self.faceAnimationView.realtimeAnimationProgress
                if (toProgress >= 0.99) {
                    self.faceAnimationView.play(toProgress: toProgress - 0.99)
                }
                if (toProgress <= 0.01) {
                    self.faceAnimationView.play(toProgress: toProgress + 1)
                }
            }
        }
    }
    
    func updateArrowAnimation() {
        if (self.blockStageIndicationByUI == false) {
            DispatchQueue.main.async {
                let toProgress = self.arrowAnimationView.realtimeAnimationProgress
                if (toProgress <= 0.01) {
                    self.arrowAnimationView.play(toProgress: toProgress + 1)
                }
            }
        }
    }
    
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {

        let animationDuration = Double(LivenessScreenViewController.BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS) / 1000.0

        UIView.animate(withDuration: animationDuration, delay: delay,
                       options: [UIView.AnimationOptions.autoreverse,
                                 UIView.AnimationOptions.repeat], animations: {
            view.alpha = 0
        }, completion: nil)

    }
}

// MARK: - Camera optput capturing delegate

extension LivenessScreenViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func updateCameraFrame(frame: GARAugmentedFaceFrame) {
        // Update the camera image layer's transform to the display transform for this frame. //?
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        cameraImageLayer.contents = frame.capturedImage as CVPixelBuffer
        cameraImageLayer.setAffineTransform(
            frame.displayTransform(
                forViewportSize: cameraImageLayer.bounds.size,
                presentationOrientation: .portrait,
                mirrored: true))
        CATransaction.commit()
    }
    
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let brightness = getBrightness(sampleBuffer: sampleBuffer)
        //print("CURRENT BRIGHTNESS: \(brightness)")
        if (brightness < -1.0) {
            onObstableTypeMet(obstacleType: ObstacleType.BRIGHTNESS_LEVEL_IS_LOW)
        }
        
        guard let imgBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let deviceMotion = motionManager.deviceMotion
        else {
            NSLog("In captureOutput, imgBuffer or deviceMotion is nil.")
            return
        }
        
        let frameTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        
        // Use the device's gravity vector to determine which direction is up for a face. This is the
        // positive counter-clockwise rotation of the device relative to landscape left orientation.
        let rotation = 2 * .pi - atan2(deviceMotion.gravity.x, deviceMotion.gravity.y) + .pi / 2
        let rotationDegrees = (UInt)(rotation * 180 / .pi) % 360
        
        //print("DEVICE(?) ROTATION DEGREES: \(rotationDegrees)")
        
        faceSession?.update(with: imgBuffer, timestamp: frameTime, recognitionRotation: rotationDegrees)
    }
}

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
    private func setupCamera() -> Bool {
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
    private func setupScene() -> Bool {
        
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
    private func setupMotion() -> Bool {
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

// MARK: - Permission and alert util

extension LivenessScreenViewController {
    /// Get permission to use device camera.
    ///
    /// - Parameters:
    ///   - permissionHandler: The closure to call with whether permission was granted when
    ///     permission is determined.
    private func getVideoPermission(permissionHandler: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionHandler(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: permissionHandler)
        default:
            permissionHandler(false)
        }
    }
    
    private func popupAlertWindowOnError(alertWindowTitle: String, alertMessage: String) {
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

// MARK: - Matrix (face coords calc) extensions

extension simd_float4x4 {
    
    // Function to convert rad to deg
    func radiansToDegress(radians: Float32) -> Float32 {
        return radians * 180 / (Float32.pi)
    }
    
    //Obsolete(?)
    var translation: SCNVector3 {
        get {
            return SCNVector3Make(columns.3.x, columns.3.y, columns.3.z)
        }
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
            var actualYaw: Float
            if abs(sinp) >= 1 {
                actualYaw = radiansToDegress(radians:copysign(Float.pi / 2, sinp))
            } else {
                actualYaw = radiansToDegress(radians:asin(sinp))
            }
            /// roll (x-axis rotation)
            let sinr = +2.0 * (qw * qx + qy * qz)
            let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
            let actualPitch = -radiansToDegress(radians:atan2(sinr, cosr))
            
            /// return array containing ypr values
            return FaceAnglesHolder(pitch: actualPitch, yaw: abs(actualYaw), roll: actualRoll)
            //! actualPitch was roll; ! actualYaw was pitch; ! actualRoll was yaw
        }
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
