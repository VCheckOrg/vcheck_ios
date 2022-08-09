//
//  SegmentationScreenViewController.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 05.08.2022.
//

import AVFoundation
import UIKit
@_implementationOnly import Lottie


class SegmentationViewController: UIViewController {
 
    
    @IBOutlet weak var segmentationFrame: VCheckSDKRoundedView!
    
    @IBOutlet weak var segmentationAnimHolder: UIView!
    
    @IBOutlet weak var animatingImage: UIImageView!
    
    @IBOutlet weak var closePseudoBtn: UIImageView!
    
    @IBOutlet weak var indicationText: UILabel!
    
    @IBOutlet weak var btnImReady: UIButton!
    
    private var docData: DocTypeData? = nil
    
    private var checkedDocIdx = 0
    
    // MARK: - Anim properties
    private var docAnimationView: AnimationView = AnimationView()
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
    lazy var previewLayer = CALayer()

    // MARK: - Video recording properties
    var videoRecorder = LivenessVideoRecorder.init()
    var videoStreamingPermitted: Bool = false
    var videoBuffer: CVImageBuffer?

    // MARK: - Milestone flow & logic properties

    static let LIVENESS_TIME_LIMIT_MILLIS = 60000 //max is 60000
    static let BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS = 2000
    static let GESTURE_REQUEST_INTERVAL = 0.45 //TODO: reduce on Android!

    private var isLivenessSessionFinished: Bool = false
    private var hasEnoughTimeForNextGesture: Bool = true
    private var livenessSessionTimeoutTimer : DispatchSourceTimer?
    private var periodicGestureCheckTimer: Timer?
    private var blockProcessingByUI: Bool = false
    private var blockRequestByProcessing: Bool = false  //TODO: implement on Android!

    // MARK: - Implementation & Lifecycle methods
    
    private func setDocData() {
        docData = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if !setupCamera() { return }

        self.setDocData()
        self.setupInstructionStageUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewDidAppearReached = true

        if needToShowFatalError {
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }
    
    private func setupInstructionStageUI() {

        blockProcessingByUI = true
        blockRequestByProcessing = true
        //binding!!.docAnimationView.isVisible = false
        //binding!!.scalableDocHandView.isVisible = true
        
        switch(DocType.docCategoryIdxToType(categoryIdx: (docData?.category!)!)) {
            case DocType.FOREIGN_PASSPORT:
                self.animatingImage.image = UIImage.init(named: "img_hand_foreign_passport")
            case DocType.ID_CARD:
                self.animatingImage.image = UIImage.init(named: "img_hand_id_card")
            default:
                self.animatingImage.image = UIImage.init(named: "img_hand_inner_passport")
        }

        //self.animateInstructionStage()

        self.btnImReady.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.setupDocCheckStage(_:))))
    }
    
    @objc func setupDocCheckStage(_ sender: UITapGestureRecognizer) {
        //binding!!.scalableDocHandView.isVisible = false
        //binding!!.readyButton.isVisible = false
        resetFlowForNewSession()
        //setGestureResponsesObserver() //remove
        setUIForNextStage()
    }
    
    
    private func resetFlowForNewSession() {
                
        self.isLivenessSessionFinished = false
        self.hasEnoughTimeForNextGesture = true
        self.blockProcessingByUI = false
        
        self.videoRecorder = LivenessVideoRecorder.init()
        self.videoStreamingPermitted = true
        self.videoRecorder.startRecording()
        
        self.livenessSessionTimeoutTimer = nil
        self.startLivenessSessionTimeoutTimer()
        
        //self.indicationText.text = "liveness_stage_check_face_pos".localized
        
        self.periodicGestureCheckTimer = Timer.scheduledTimer(timeInterval:
                        LivenessScreenViewController.GESTURE_REQUEST_INTERVAL, target: self,
                          selector: #selector(performGestureCheck), userInfo: nil, repeats: true)
        
        //self.delayedStageIndicationRenew()
    }
    
    @objc func performGestureCheck() {
        if (self.isLivenessSessionFinished == false) {
            if (self.areAllDocPagesChecked()) {
                self.onAllStagesPassed()
            } else {
                if (videoBuffer != nil
                    && self.hasEnoughTimeForNextGesture == true
                    && self.blockRequestByProcessing == false) {
                    self.checkStage()
                } else { print("------ VideoBuffer is NIL!") }
            }
        }
    }
    
    private func areAllDocPagesChecked() -> Bool {
        return checkedDocIdx >= docData?.maxPagesCount ?? 0
    }
    
    private func checkStage() {
        guard let frameImage: UIImage = getScreenshotFromVideoStream(videoBuffer!) else {
            print("====== Cannot perform gesture request: either frameImage is nil!")
            return
        }
        
        self.blockRequestByProcessing = true
        
        guard let country = docData!.country, let category = docData!.category else {
            print("Doc segmentation request: Error - country or cate gory for request have not been set!")
            return
        }
        
        VCheckSDKRemoteDatasource.shared.sendSegmentationDocAttempt(frameImage: frameImage,
                                                                    country: country,
                                                                    category: "\(category)",
                                                                    index: "\(checkedDocIdx)",
                                                                    completion: { (data, error) in
            if let error = error {
                print("Doc segmentation request: Error [\(error.errorText)]")
                return
            }
            if (data?.success == true) {
                self.onStagePassed()
            }
            self.blockRequestByProcessing = false
        })
    }
    
    func onAllStagesPassed() {
        
        self.periodicGestureCheckTimer?.invalidate()
        
        self.hasEnoughTimeForNextGesture = false
        
        self.videoStreamingPermitted = false
        self.isLivenessSessionFinished = true
        
        self.hapticFeedbackGenerator.notificationOccurred(.success)

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
    
    func onStagePassed() {
        self.hapticFeedbackGenerator.notificationOccurred(.success)
        self.indicateNextStage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //TODO: add specific view controller!
        if (segue.identifier == "LivenessToNoTime") {
            let vc = segue.destination as! NoTimeViewController
            vc.onRepeatBlock = { result in
                self.resetFlowForNewSession()
            }
        }
    }

    func endSessionPrematurely(performSegueWithIdentifier: String) {
        self.videoRecorder.stopRecording(completion: { url in
            print("========== FINISHED WRITING VIDEO IN: \(url)")
            DispatchQueue.main.async {
                self.periodicGestureCheckTimer?.invalidate()
                
                self.hasEnoughTimeForNextGesture = false
                
                self.videoStreamingPermitted = false
                self.isLivenessSessionFinished = true
                
                self.periodicGestureCheckTimer?.invalidate()
                
                self.hapticFeedbackGenerator.notificationOccurred(.warning)
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

extension SegmentationViewController {

    func indicateNextStage() {
        DispatchQueue.main.async {
            
    //        binding!!.tvSegmentationInstruction.setMargins(
    //            20, 45, 20, 20)
            self.indicationText.text = "segmentation_stage_success";

            self.blockProcessingByUI = true

            //self.indicationFrame.isHidden = false
            //self.fadeViewInThenOut(view: self.indicationFrame, delay: 0.0)
            
            if (DocType.docCategoryIdxToType(categoryIdx: (self.docData?.category!)!) == DocType.ID_CARD) {
                //binding!!.docAnimationView.isVisible = true
                //binding!!.docAnimationView.playAnimation()
            } else {
                //binding!!.docAnimationView.isVisible = false
            }

            DispatchQueue.main.asyncAfter(deadline:
                    .now() + .milliseconds(LivenessScreenViewController.BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS) ) {

//              self.imgMilestoneChecked.isHidden = true
//              self.indicationFrame.isHidden = true

                self.blockProcessingByUI = false
                
                self.setUIForNextStage()
                
                //self.setupOrUpdateFaceAnimation(forMilestoneType: self.milestoneFlow.getCurrentStage()!)
            }
        }
    }
    
    
    func setUIForNextStage() {
        //docAnimationView.isVisible = false
//        binding!!.tvSegmentationInstruction.setMargins(
//            20, 45, 20, 20)

        switch(DocType.docCategoryIdxToType(categoryIdx: (docData?.category!)!)) {
            case DocType.FOREIGN_PASSPORT:
                self.indicationText.text = "segmentation_single_page_hint".localized
            case DocType.ID_CARD:
                if (checkedDocIdx == 0) {
                    self.indicationText.text = "segmentation_front_side_hint";
                }
                if (checkedDocIdx == 1) {
                    self.indicationText.text = "segmentation_back_side_hint";
                }
            default:
                if (checkedDocIdx == 0) {
                    self.indicationText.text = "segmentation_front_side_hint";
                }
                if (checkedDocIdx == 1) {
                    self.indicationText.text = "segmentation_back_side_hint";
                }
        }
        blockProcessingByUI = false
        blockRequestByProcessing = false
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

extension SegmentationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

        guard let imgBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else {
            NSLog("In captureOutput, imgBuffer is nil.")
            return
        }
        
        if (self.isLivenessSessionFinished == false) {
            self.videoBuffer = imgBuffer
                        
            //MARK: Liveness Session Video Recording
            if (self.videoRecorder.outputFileURL != nil && self.videoStreamingPermitted == true) {
                self.videoRecorder.recordVideo(sampleBuffer: sampleBuffer)
            }
            
            if (blockProcessingByUI == false) {
                DispatchQueue.main.async {
                    //self.updateFaceAnimation()
                    //self.updateArrowAnimation() //TODO: update animation?
                }
            }
        }
    }
    
    
    func getScreenshotFromVideoStream(_ imageBuffer: CVImageBuffer) -> UIImage? {
        var ciImage: CIImage? = nil
        if let imageBuffer = imageBuffer as CVPixelBuffer? {
            ciImage = CIImage(cvPixelBuffer: imageBuffer)
        }
        let temporaryContext = CIContext(options: nil)
        var videoImage: CGImage? = nil
        if let imageBuffer = imageBuffer as CVPixelBuffer?, let ciImage = ciImage {
            videoImage = temporaryContext.createCGImage(
                ciImage,
                from: CGRect(
                    x: 0,
                    y: 0,
                    width: CGFloat(CVPixelBufferGetWidth(imageBuffer)),
                    height: CGFloat(CVPixelBufferGetHeight(imageBuffer))))
        }
        if let cgImage = videoImage {
            let uiImage = UIImage(cgImage: cgImage)
            let rotatedImage = uiImage.rotate(radians: Float(90.degreesToRadians))
            return rotatedImage
        } else {
            print("--------------- FAILED TO CONVERT VIDEO SCREEN TO IMAGE!")
            return nil
        }
    }
    
}


//    func setupOrUpdateFaceAnimation(forMilestoneType: GestureMilestoneType) {
//
//        roundedView.subviews.forEach { $0.removeFromSuperview() }
//
//        if (forMilestoneType == GestureMilestoneType.OuterLeftHeadYawMilestone) {
//            faceAnimationView = AnimationView(name: "left", bundle: InternalConstants.bundle)
//        } else if (forMilestoneType == GestureMilestoneType.OuterRightHeadYawMilestone) {
//            faceAnimationView = AnimationView(name: "right", bundle: InternalConstants.bundle)
//        } else if (forMilestoneType == GestureMilestoneType.UpHeadPitchMilestone) {
//            faceAnimationView = AnimationView(name: "up", bundle: InternalConstants.bundle)
//        } else if (forMilestoneType == GestureMilestoneType.DownHeadPitchMilestone) {
//            faceAnimationView = AnimationView(name: "down", bundle: InternalConstants.bundle)
//        } else if (forMilestoneType == GestureMilestoneType.MouthOpenMilestone) {
//            faceAnimationView = AnimationView(name: "mouth", bundle: InternalConstants.bundle)
//        } else {
//            faceAnimationView = AnimationView(name: "mouth", bundle: InternalConstants.bundle)
//        }
//
//        faceAnimationView.contentMode = .scaleAspectFit
//        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
//        roundedView.addSubview(faceAnimationView)
//
//        faceAnimationView.centerXAnchor.constraint(equalTo: roundedView.centerXAnchor, constant: 4).isActive = true
//        faceAnimationView.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor).isActive = true
//
//        faceAnimationView.heightAnchor.constraint(equalToConstant: 200).isActive = true
//        faceAnimationView.widthAnchor.constraint(equalToConstant: 200).isActive = true
//    }


/*
 rightArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
 leftArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
 centerAnimHolderView.subviews.forEach { $0.removeFromSuperview() }

 if (forMilestoneType == GestureMilestoneType.OuterLeftHeadYawMilestone) {
     
     rightArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
     centerAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
     
     arrowAnimationView = AnimationView(name: "arrow", bundle: InternalConstants.bundle)

     arrowAnimationView.contentMode = .center
     arrowAnimationView.translatesAutoresizingMaskIntoConstraints = false
     leftArrowAnimHolderView.addSubview(arrowAnimationView)

     arrowAnimationView.centerXAnchor.constraint(equalTo: leftArrowAnimHolderView.centerXAnchor).isActive = true
     arrowAnimationView.centerYAnchor.constraint(equalTo: leftArrowAnimHolderView.centerYAnchor).isActive = true

     arrowAnimationView.heightAnchor.constraint(equalToConstant: 250).isActive = true
     arrowAnimationView.widthAnchor.constraint(equalToConstant: 250).isActive = true

     arrowAnimationView.loopMode = .loop

 }
 */

//    func updateFaceAnimation() {
//        if (self.blockStageIndicationByUI == false) {
//            if (self.milestoneFlow.getCurrentStage() != GestureMilestoneType.StraightHeadCheckMilestone) {
//                DispatchQueue.main.async {
//                    let toProgress = self.faceAnimationView.realtimeAnimationProgress
//                    if (toProgress >= 0.99) {
//                        self.faceAnimationView.play(toProgress: toProgress - 0.99)
//                    }
//                    if (toProgress <= 0.01) {
//                        self.faceAnimationView.play(toProgress: toProgress + 1)
//                    }
//                }
//            } else {
//                self.faceAnimationView.play(toProgress: 0.02)
//            }
//        }
//    }
//
//    func updateArrowAnimation() {
//        if (self.blockStageIndicationByUI == false
//            && self.milestoneFlow.getCurrentStage() != GestureMilestoneType.StraightHeadCheckMilestone) {
//            DispatchQueue.main.async {
//                let toProgress = self.arrowAnimationView.realtimeAnimationProgress
//                if (toProgress <= 0.01) {
//                    self.arrowAnimationView.play(toProgress: toProgress + 1)
//                }
//            }
//        }
//    }
//
