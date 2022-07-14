import AVFoundation
import CoreMedia
import CoreMotion
import SceneKit
import UIKit
@_implementationOnly import ARCore
@_implementationOnly import Lottie
import Vision

internal class LivenessScreenViewController: UIViewController {

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

    // MARK: - AR and Face Detection properties
    private var faceSession: GARAugmentedFaceSession?
    lazy var faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: self.onFacesDetected)

    // MARK: - Video recording properties
    var videoRecorder = LivenessVideoRecorder.init()
    var videoStreamingPermitted: Bool = false

    // MARK: - Milestone flow & logic properties

    private var milestoneFlow = StandardMilestoneFlow()
    private var majorObstacleFrameCounterHolder = MajorObstacleFrameCounterHolder()

    static let LIVENESS_TIME_LIMIT_MILLIS = 14000 //max is 15000
    static let BLOCK_PIPELINE_ON_OBSTACLE_TIME_MILLIS = 1100 //may reduce a bit
    static let BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS = 1200 //may reduce a bit

    static let MAX_FRAMES_WITH_WRONG_GESTURE = 50
    static let FACE_DETECTION_FRAME_INTERVAL = 20
    private var faceCountDetectionFrameCounter: Int = 0

    private var isLivenessSessionFinished: Bool = false
    private var hasEnoughTimeForNextGesture: Bool = true
    private var livenessSessionTimeoutTimer : DispatchSourceTimer?
    private var blockStageIndicationByUI: Bool = false
    private var blockTextIndicationByWarning: Bool = false


    // MARK: - Implementation & Lifecycle methods

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let milestonesList = LocalDatasource.shared.getLivenessMilestonesList()
        else {
            self.alertWindowTitle = "Milestone list is not found"
            self.alertMessage = "Probably, milestone list was not retrieved form verification service or not cached properly."
            self.needToShowFatalError = true
            return
        }
        milestoneFlow.setStagesList(list: milestonesList)

        if !setupScene() { return }
        if !setupCamera() { return }
        if !setupMotion() { return }

        imgMilestoneChecked.isHidden = true
        indicationFrame.isHidden = true
        
        setupFaceSession()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewDidAppearReached = true

        if needToShowFatalError {
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
            return
        }
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LivenessToNoFaceDetected") {
            let vc = segue.destination as! NoFaceDetectedViewController
            vc.onRepeatBlock = { result in self.renewLivenessSessionOnRetry() }
        }
        if (segue.identifier == "LivenessToNoTime") {
            let vc = segue.destination as! NoTimeViewController
            vc.onRepeatBlock = { result in self.renewLivenessSessionOnRetry() }
        }
        if (segue.identifier == "LivenessToMultipleFaces") {
            let vc = segue.destination as! MultipleFacesDetectedViewController
            vc.onRepeatBlock = { result in self.renewLivenessSessionOnRetry() }
        }
        if (segue.identifier == "LivenessToTooDark") {
            let vc = segue.destination as! NoBrightnessViewController
            vc.onRepeatBlock = { result in self.renewLivenessSessionOnRetry() }
        }
        if (segue.identifier == "LivenessToVideoProcessing") {
            let vc = segue.destination as! VideoProcessingViewController
            vc.videoFileURL = self.videoRecorder.outputFileURL
            vc.livenessVC = self
        }
    }

    func renewLivenessSessionOnRetry() {
        DispatchQueue.main.async {
            self.indicationFrame.alpha = 1
            // reset UI
            self.imgMilestoneChecked.isHidden = true
            self.indicationFrame.isHidden = true
            self.faceAnimationView = AnimationView()
            self.arrowAnimationView = AnimationView()
            self.arrowAnimationView.stop()
            self.rightArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
            self.leftArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
            // reset logic
            self.videoRecorder = LivenessVideoRecorder.init()
            self.videoStreamingPermitted = true
            self.milestoneFlow.resetStages() //!
            self.majorObstacleFrameCounterHolder = MajorObstacleFrameCounterHolder()
            self.faceCountDetectionFrameCounter = 0
            self.isLivenessSessionFinished = false
            self.hasEnoughTimeForNextGesture = true
            self.blockStageIndicationByUI = false
            self.livenessSessionTimeoutTimer = nil
            self.startLivenessSessionTimeoutTimer()
        }
        self.faceSession = nil
        self.setupFaceSession()
    }

    func setupFaceSession() {
        do {
            faceSession = try GARAugmentedFaceSession(fieldOfView: videoFieldOfView)
            
            videoStreamingPermitted = true
            videoRecorder.startRecording()

            startLivenessSessionTimeoutTimer()

            setupOrUpdateFaceAnimation(forMilestoneType: self.milestoneFlow.getCurrentStage().gestureMilestoneType)
            setupOrUpdateArrowAnimation(forMilestoneType: self.milestoneFlow.getCurrentStage().gestureMilestoneType)
        } catch {
            alertWindowTitle = "A fatal error occurred."
            alertMessage = "Failed to create session. Error description: \(error)"
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
        }
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
                DispatchQueue.main.async {
                    self.updateFaceAnimation()
                    self.updateArrowAnimation()
                }
            }
            processFaceFrame(frame: frame)
        } else {
            DispatchQueue.main.asyncAfter(deadline:
                    .now() + .milliseconds(800) ) {
                self.videoStreamingPermitted = false
                self.videoRecorder.stopRecording(completion: { url in
                    DispatchQueue.main.async {
                        print("========== FINISHED WRITING VIDEO IN: \(url)")
                        if (self.livenessSessionTimeoutTimer != nil) {
                            self.livenessSessionTimeoutTimer!.cancel()
                        }
                        self.performSegue(withIdentifier: "LivenessToVideoProcessing", sender: nil)
                    }
                })
            }
        }
    }
}

// MARK: - Frame processing at upper level

extension LivenessScreenViewController {

    func processFaceFrame(frame: GARAugmentedFaceFrame) {
        if let face = frame.face {

            if (isLivenessSessionFinished == false) {
                processFaceCalcForFrame(face: face)
            }
            if (videoStreamingPermitted == true) {
                DispatchQueue.main.async {
                    self.updateCameraFrame(frame: frame)
                }
            }
            DispatchQueue.main.async {
                // Only show AR content when a face is detected. //!
                self.sceneView.scene?.rootNode.isHidden = frame.face == nil
            }
        }
    }

    func processFaceCalcForFrame(face: GARAugmentedFace) {

        let mouthAngle = calculateMouthFactor(face: face)
        let faceAnglesHolder = face.centerTransform.eulerAngles
        
        milestoneFlow.checkCurrentStage(yawAngle: faceAnglesHolder.yaw,
                                        mouthFactor: mouthAngle,
                                        pitchAngle: faceAnglesHolder.pitch,
                                        onMilestoneResult: { milestoneType in
            //print("------- PASSED MILESTONE: \(milestoneType)")
            DispatchQueue.main.async {
                if (self.hasEnoughTimeForNextGesture) {
                    if (self.milestoneFlow.getCurrentStage().gestureMilestoneType
                            != GestureMilestoneType.CheckHeadPositionMilestone) {
                        self.majorObstacleFrameCounterHolder.resetFrameCountersOnStageSuccess()
                        self.hapticFeedbackGenerator.notificationOccurred(.success)
                        self.delayedStageIndicationRenew()
                    }
                    self.updateLivenessInfoText(forMilestoneType: self.milestoneFlow.getCurrentStage().gestureMilestoneType)
                    self.setupOrUpdateFaceAnimation(forMilestoneType: self.milestoneFlow.getCurrentStage().gestureMilestoneType)
                    self.setupOrUpdateArrowAnimation(forMilestoneType: self.milestoneFlow.getCurrentStage().gestureMilestoneType)
                }
            }
        },
        onObstacleMet: { obstacleType in
            onObstableTypeMet(obstacleType: obstacleType)
        },
        onAllStagesPassed: {
            self.hapticFeedbackGenerator.notificationOccurred(.success)
            self.delayedStageIndicationRenew()
            self.isLivenessSessionFinished = true
        })

        //print("PITCH: \(faceAnglesHolder.pitch)\nYAW: \(faceAnglesHolder.yaw)")
        //+ "MOUTH: \(mouthAngle)\n | \n\nMOUTH OPEN: \(mouthOpen)\n\nTURNED LEFT: \(turnedLeft)\n\nTURNED RIGHT: \(turnedRight)")
    }

    func onObstableTypeMet(obstacleType: ObstacleType) {
        if (obstacleType == ObstacleType.NO_OR_PARTIAL_FACE_DETECTED) {
            self.endSessionPrematurely(performSegueWithIdentifier: "LivenessToNoFaceDetected")
        }
        if (obstacleType == ObstacleType.MULTIPLE_FACES_DETECTED) {
            self.endSessionPrematurely(performSegueWithIdentifier: "LivenessToMultipleFaces")
        }
        if (obstacleType == ObstacleType.PITCH_ANGLE) {
            DispatchQueue.main.async {
                self.hapticFeedbackGenerator.notificationOccurred(.warning)
                self.tvLivenessInfo.textColor = .red
                self.tvLivenessInfo.text = "line_face_obstacle".localized
                self.blockTextIndicationByWarning = true
                DispatchQueue.main.asyncAfter(deadline:
                        .now() + .milliseconds(LivenessScreenViewController.BLOCK_PIPELINE_ON_OBSTACLE_TIME_MILLIS) ) {
                    //self.updateLivenessInfoText(forMilestoneType: self.milestoneFlow.getUndoneStage().gestureMilestoneType)
                    if (self.blockTextIndicationByWarning == true) {
                        self.blockTextIndicationByWarning = false
                    }
                }
            }
        }
    }

    func endSessionPrematurely(performSegueWithIdentifier: String) {
        self.videoStreamingPermitted = false
        self.videoRecorder.stopRecording(completion: { url in
            print("========== FINISHED WRITING VIDEO IN: \(url)")
            DispatchQueue.main.async {
                self.faceCountDetectionFrameCounter = 0

                self.hasEnoughTimeForNextGesture = false

                self.isLivenessSessionFinished = true
                self.hapticFeedbackGenerator.notificationOccurred(.warning)
                self.majorObstacleFrameCounterHolder.resetFrameCountersOnSessionPrematureEnd()
                if (self.livenessSessionTimeoutTimer != nil) {
                    self.livenessSessionTimeoutTimer!.cancel()
                }
                self.performSegue(withIdentifier: performSegueWithIdentifier, sender: nil)
            }
        })
    }

    func startLivenessSessionTimeoutTimer() {
        let delay : DispatchTime = .now() + .milliseconds(LivenessScreenViewController.LIVENESS_TIME_LIMIT_MILLIS)
        if livenessSessionTimeoutTimer == nil {
            livenessSessionTimeoutTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            livenessSessionTimeoutTimer!.schedule(deadline: delay, repeating: 0)
            livenessSessionTimeoutTimer!.setEventHandler {
                self.endSessionPrematurely(performSegueWithIdentifier: "LivenessToNoTime")
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
        if (blockTextIndicationByWarning == false) {
            self.tvLivenessInfo.textColor = .white
            //TODO: update texts for up/down gestures!
            if (forMilestoneType == GestureMilestoneType.OuterLeftHeadYawMilestone) {
                self.tvLivenessInfo.text = "liveness_stage_face_left".localized
            } else if (forMilestoneType == GestureMilestoneType.OuterRightHeadYawMilestone) {
                self.tvLivenessInfo.text = "liveness_stage_face_right".localized
            } else if (forMilestoneType == GestureMilestoneType.MouthOpenMilestone) {
                self.tvLivenessInfo.text = "liveness_stage_open_mouth".localized
            } else if (forMilestoneType == GestureMilestoneType.UpHeadPitchMilestone) {
                self.tvLivenessInfo.text = "liveness_stage_face_up".localized
            } else if (forMilestoneType == GestureMilestoneType.DownHeadPitchMilestone) {
                self.tvLivenessInfo.text = "liveness_stage_face_down".localized
            } else {
                self.tvLivenessInfo.text = "liveness_stage_check_face_pos".localized
            }
        }
    }

    func setupOrUpdateFaceAnimation(forMilestoneType: GestureMilestoneType) {

        roundedView.subviews.forEach { $0.removeFromSuperview() }

        if (forMilestoneType == GestureMilestoneType.OuterLeftHeadYawMilestone) {
            faceAnimationView = AnimationView(name: "left", bundle: InternalConstants.bundle)
        } else if (forMilestoneType == GestureMilestoneType.OuterRightHeadYawMilestone) {
            faceAnimationView = AnimationView(name: "right", bundle: InternalConstants.bundle)
        } else if (forMilestoneType == GestureMilestoneType.UpHeadPitchMilestone) {
            faceAnimationView = AnimationView(name: "up", bundle: InternalConstants.bundle)
        } else if (forMilestoneType == GestureMilestoneType.DownHeadPitchMilestone) {
            faceAnimationView = AnimationView(name: "down", bundle: InternalConstants.bundle)
        } else if (forMilestoneType == GestureMilestoneType.MouthOpenMilestone) {
            faceAnimationView = AnimationView(name: "mouth", bundle: InternalConstants.bundle)
        } else {
            faceAnimationView = AnimationView()
            faceAnimationView.stop()
            roundedView.subviews.forEach { $0.removeFromSuperview() }
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
        
        rightArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
        leftArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }

        if (forMilestoneType == GestureMilestoneType.OuterLeftHeadYawMilestone) {
            arrowAnimationView = AnimationView(name: "arrow", bundle: InternalConstants.bundle)

            arrowAnimationView.contentMode = .center
            arrowAnimationView.translatesAutoresizingMaskIntoConstraints = false
            leftArrowAnimHolderView.addSubview(arrowAnimationView)

            arrowAnimationView.centerXAnchor.constraint(equalTo: leftArrowAnimHolderView.centerXAnchor).isActive = true
            arrowAnimationView.centerYAnchor.constraint(equalTo: leftArrowAnimHolderView.centerYAnchor).isActive = true

            arrowAnimationView.heightAnchor.constraint(equalToConstant: 250).isActive = true
            arrowAnimationView.widthAnchor.constraint(equalToConstant: 250).isActive = true

            arrowAnimationView.loopMode = .loop

        } else if (forMilestoneType == GestureMilestoneType.OuterRightHeadYawMilestone) {

            leftArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }

            arrowAnimationView = AnimationView(name: "arrow", bundle: InternalConstants.bundle)

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
        DispatchQueue.main.async {
            let animationDuration = Double(LivenessScreenViewController.BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS) / 1000.0
            UIView.animate(withDuration: animationDuration, delay: delay,
                           options: [UIView.AnimationOptions.autoreverse,
                                     UIView.AnimationOptions.repeat], animations: {
                view.alpha = 0
            }, completion: nil)
        }
    }
}

// MARK: - Camera output capturing delegate

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

        guard let imgBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let deviceMotion = motionManager.deviceMotion
        else {
            NSLog("In captureOutput, imgBuffer or deviceMotion is nil.")
            return
        }

        //MARK: Face Detection
        if (self.isLivenessSessionFinished == false && self.videoStreamingPermitted == true) {
            faceCountDetectionFrameCounter += 1
            if (faceCountDetectionFrameCounter >= LivenessScreenViewController.FACE_DETECTION_FRAME_INTERVAL) {
                faceCountDetectionFrameCounter = 0
                detectFacesOnFrameOutput(buffer: imgBuffer)
            }
        }

        //MARK: Liveness Session Video Recording
        if (self.videoRecorder.outputFileURL != nil && self.videoStreamingPermitted == true) {
            self.videoRecorder.recordVideo(sampleBuffer: sampleBuffer)
        }

        let frameTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        // Use the device's gravity vector to determine which direction is up for a face. This is the
        // positive counter-clockwise rotation of the device relative to landscape left orientation.
        let rotation = 2 * .pi - atan2(deviceMotion.gravity.x, deviceMotion.gravity.y) + .pi / 2
        let rotationDegrees = (UInt)(rotation * 180 / .pi) % 360
        //print("DEVICE(?) ROTATION DEGREES: \(rotationDegrees)")

        faceSession?.update(with: imgBuffer, timestamp: frameTime, recognitionRotation: rotationDegrees)
    }

    func onFacesDetected(request: VNRequest, error: Error?) {
      guard let results = request.results as? [VNFaceObservation] else {
        return
      }
        //print("FACE(S) DETECTED: \(results.count)")
        if (results.count < 1) {
            onObstableTypeMet(obstacleType: ObstacleType.NO_OR_PARTIAL_FACE_DETECTED)
        }
        if (results.count > 1) {
            onObstableTypeMet(obstacleType: ObstacleType.MULTIPLE_FACES_DETECTED)
        }
    }
}
