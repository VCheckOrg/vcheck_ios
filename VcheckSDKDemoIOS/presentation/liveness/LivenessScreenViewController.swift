import AVFoundation
import CoreMedia
import CoreMotion
import SceneKit
import UIKit
import ARCore
import Lottie
import Vision

//TODO: Add all possible camera resource close actions after navigating to next screen!
//TODO: Also add debouncer for Vision's multiple faces detection

public final class LivenessScreenViewController: UIViewController {
    
    // MARK: Outlets/Actions
    
    @IBOutlet weak var roundedView: RoundedView!
    
    @IBOutlet weak var leftArrowAnimHolderView: UIView!
    @IBOutlet weak var rightArrowAnimHolderView: UIView!
    
    @IBOutlet weak var tvLivenessInfo: UILabel!
    
    @IBOutlet weak var imgMilestoneChecked: UIImageView!
    @IBOutlet weak var indicationFrame: RoundedView!
    
    
    // MARK: - Anim properties
    private var faceAnimationView: AnimationView = AnimationView()
    private var arrowAnimationView: AnimationView = AnimationView()
    private let hapticFeedbackGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Member Variables (open for ext.)
    var needToShowFatalError = false
    var alertWindowTitle = "Nothing"
    var alertMessage = "Nothing"
    var viewDidAppearReached = false
    
    // MARK: - Camera / Scene properties (open for ext.)
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var videoFieldOfView = Float(0)
    lazy var cameraImageLayer = CALayer()
    lazy var sceneView = SCNView()
    lazy var sceneCamera = SCNCamera()
    lazy var motionManager = CMMotionManager()
    
    // MARK: - AR Face properties
    private var faceSession: GARAugmentedFaceSession?
    
    // MARK: - Milestone flow & logic properties
    private var milestoneFlow = StandardMilestoneFlow()
    
    static let LIVENESS_TIME_LIMIT_MILLIS = 14000 //max is 15000
    static let BLOCK_PIPELINE_ON_OBSTACLE_TIME_MILLIS = 1100 //may reduce a bit
    static let BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS = 1200 //may reduce a bit
    static let MAX_FRAMES_WITH_FATAL_OBSTACLES = 50
    
    private var multiFaceFrameCounter: Int = 0
    private var noFaceFrameCounter: Int = 0
    private var majorObstacleFrameCounter: Int = 0
    
    private var isLivenessSessionFinished: Bool = false
    private var hasEnoughTimeForNextGesture: Bool = true
    private var livenessSessionTimeoutTimer : DispatchSourceTimer?
    private var blockStageIndicationByUI: Bool = false
    
    
    // MARK: multiple faces detection test
    lazy var faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: self.onFacesDetected)

    
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
                updateCameraFrame(frame: frame)
            }
            
            // Only show AR content when a face is detected. //!
            sceneView.scene?.rootNode.isHidden = frame.face == nil
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
                print("NO STRAIGHT FACE DETECTED - FRAME COUNT: \(self.noFaceFrameCounter)")
                if (self.noFaceFrameCounter >= LivenessScreenViewController.MAX_FRAMES_WITH_FATAL_OBSTACLES) {
                    self.endSessionPrematurely()
                    self.performSegue(withIdentifier: "LivenessToNoFaceDetected", sender: nil)
                }
            }
        }
        if (obstacleType == ObstacleType.MULTIPLE_FACES_DETECTED) {
            DispatchQueue.main.async {
                self.multiFaceFrameCounter += 1
                print("MULTIPLE FACES DETECTION - FRAME COUNT: \(self.multiFaceFrameCounter)")
                if (self.multiFaceFrameCounter >= LivenessScreenViewController.MAX_FRAMES_WITH_FATAL_OBSTACLES) {
                    self.endSessionPrematurely()
                    self.performSegue(withIdentifier: "LivenessToMultipleFaces", sender: nil)
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
        self.noFaceFrameCounter = 0
        self.multiFaceFrameCounter = 0
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
        
        //TODO: test
        detectFacesOnFrameOutput(buffer: imgBuffer)
        
        let frameTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        
        // Use the device's gravity vector to determine which direction is up for a face. This is the
        // positive counter-clockwise rotation of the device relative to landscape left orientation.
        let rotation = 2 * .pi - atan2(deviceMotion.gravity.x, deviceMotion.gravity.y) + .pi / 2
        let rotationDegrees = (UInt)(rotation * 180 / .pi) % 360
        //print("DEVICE(?) ROTATION DEGREES: \(rotationDegrees)")
        
        faceSession?.update(with: imgBuffer, timestamp: frameTime, recognitionRotation: rotationDegrees)
    }
}
