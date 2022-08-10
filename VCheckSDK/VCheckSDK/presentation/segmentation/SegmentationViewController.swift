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
     
    @IBOutlet weak var textIndicatorConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segmentationFrame: VCheckSDKRoundedView!
    
    @IBOutlet weak var segmentationAnimHolder: UIView!
    
    @IBOutlet weak var closePseudoBtn: UIImageView!
    
    @IBOutlet weak var animatingImage: UIImageView!
    
    @IBOutlet weak var indicationText: UILabel!
    
    @IBOutlet weak var btnImReady: UIButton!
    
    private var docData: DocTypeData? = nil
    
    private var checkedDocIdx = 0
    
    private var frameSize: CGSize? = nil
    
    private var firstImgToUpload: UIImage? = nil
    private var secondImgToUpload: UIImage? = nil
    
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

    // MARK: - Video stream properties
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
        
        closePseudoBtn.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.declineSessionAndCloseVC(_:))))

        self.setDocData()
        self.setupInstructionStageUI()
    }
    
    @objc func declineSessionAndCloseVC(_ sender: UITapGestureRecognizer) {
        self.navigationController?.dismiss(animated: true)
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
        self.setSegmentationFrameSize()
    }
    
    private func setupInstructionStageUI() {

        blockProcessingByUI = true
        blockRequestByProcessing = true
        
        animatingImage.isHidden = false
        animateHandImg()
        
        setHintForStage()
        
        switch(DocType.docCategoryIdxToType(categoryIdx: (docData?.category!)!)) {
            case DocType.FOREIGN_PASSPORT:
                self.animatingImage.image = UIImage.init(named: "img_hand_foreign_passport")
            case DocType.ID_CARD:
                self.animatingImage.image = UIImage.init(named: "img_hand_id_card")
            default:
                self.animatingImage.image = UIImage.init(named: "img_hand_inner_passport")
        }

        self.btnImReady.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.setupDocCheckStage(_:))))
    }
    
    @objc func setupDocCheckStage(_ sender: UITapGestureRecognizer) {
        
        animatingImage.isHidden = true
        
        resetFlowForNewSession()
        setUIForNextStage()
    }
    
    
    private func resetFlowForNewSession() {
                
        self.isLivenessSessionFinished = false
        self.hasEnoughTimeForNextGesture = true
        self.blockProcessingByUI = false
        
        self.videoStreamingPermitted = true
        
        self.livenessSessionTimeoutTimer = nil
        self.startLivenessSessionTimeoutTimer()
                
        self.periodicGestureCheckTimer = Timer.scheduledTimer(timeInterval:
                        LivenessScreenViewController.GESTURE_REQUEST_INTERVAL, target: self,
                          selector: #selector(performGestureCheck), userInfo: nil, repeats: true)
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
                } else { print("------ VideoBuffer is nil") }
            }
        }
    }
    
    private func areAllDocPagesChecked() -> Bool {
        return checkedDocIdx >= docData!.maxPagesCount!
    }
    
    private func checkStage() {
        guard let fullImage: UIImage = getScreenshotFromVideoStream(videoBuffer!) else {
            print("====== Cannot perform segmentation request: frameImage is nil!")
            return
        }
        
        self.blockRequestByProcessing = true
        
        guard let country = docData!.country, let category = docData!.category else {
            print("Doc segmentation request: Error - country or category for request have not been set!")
            return
        }
        guard let croppedImage = fullImage.cropWithMask() else {
            print("Doc segmentation request: Error - image was not properly cropped!")
            return
        }
                
        VCheckSDKRemoteDatasource.shared.sendSegmentationDocAttempt(frameImage: croppedImage,
                                                                    country: country,
                                                                    category: "\(category)",
                                                                    index: "\(checkedDocIdx)",
                                                                    completion: { (data, error) in
            if let error = error {
                print("Doc segmentation request: Error [\(error.errorText)]")
                return
            }
            print("----- DOC SEG RESPONSE: \(String(describing: data))")
            if (data?.success == true) {
                self.onStagePassed(fullImage: fullImage)
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
        
        if (self.livenessSessionTimeoutTimer != nil) {
            self.livenessSessionTimeoutTimer!.cancel()
        }
        
        print("*********** ON ALL STAGES PASSED")
        
        self.performSegue(withIdentifier: "SegToCheckDocInfo", sender: nil)
    }
    
    func onStagePassed(fullImage: UIImage) {
        print("================ ON STAGE PASSED FOR IDX: \(self.checkedDocIdx)")
        
        if (self.checkedDocIdx == 0) {
            self.firstImgToUpload = fullImage
        } else if (self.checkedDocIdx == 1) {
            self.secondImgToUpload = fullImage
        }
        self.checkedDocIdx += 1
        
        self.hapticFeedbackGenerator.notificationOccurred(.success)
        self.indicateNextStage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //TODO: add specific view controller for timeout!
        if (segue.identifier == "SegToCheckDocInfo") {
            let vc = segue.destination as! CheckDocPhotoViewController
            vc.firstPhoto = self.firstImgToUpload
            vc.secondPhoto = self.secondImgToUpload
        }
    }

    func endSessionPrematurely(performSegueWithIdentifier: String) {

        self.periodicGestureCheckTimer?.invalidate()
        
        self.hasEnoughTimeForNextGesture = false
        
        self.videoStreamingPermitted = false
        self.isLivenessSessionFinished = true
        
        self.periodicGestureCheckTimer?.invalidate()
        
        self.hapticFeedbackGenerator.notificationOccurred(.warning)
        if (self.livenessSessionTimeoutTimer != nil) {
            self.livenessSessionTimeoutTimer!.cancel()
        }
        //self.performSegue(withIdentifier: performSegueWithIdentifier, sender: nil)
    }

    func startLivenessSessionTimeoutTimer() {
        let delay : DispatchTime = .now() + .milliseconds(LivenessScreenViewController.LIVENESS_TIME_LIMIT_MILLIS)
        if livenessSessionTimeoutTimer == nil {
            livenessSessionTimeoutTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            livenessSessionTimeoutTimer!.schedule(deadline: delay, repeating: 0)
            livenessSessionTimeoutTimer!.setEventHandler {
                //self.endSessionPrematurely(performSegueWithIdentifier: "LivenessToNoTime") //!
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

            self.indicationText.text = "segmentation_stage_success".localized;
            self.textIndicatorConstraint.constant = 50.0

            self.blockProcessingByUI = true
            
            self.segmentationAnimHolder.subviews.forEach { $0.removeFromSuperview() }
            
            if (DocType.docCategoryIdxToType(categoryIdx: (self.docData?.category!)!) == DocType.ID_CARD) {
                
                self.docAnimationView = AnimationView(name: "id_card_turn_front", bundle: InternalConstants.bundle)
        
                self.docAnimationView.contentMode = .scaleAspectFit
                self.docAnimationView.translatesAutoresizingMaskIntoConstraints = false
                self.segmentationAnimHolder.addSubview(self.docAnimationView)
        
                self.docAnimationView.centerXAnchor.constraint(equalTo: self.segmentationAnimHolder.centerXAnchor).isActive = true
                self.docAnimationView.centerYAnchor.constraint(equalTo: self.segmentationAnimHolder.centerYAnchor).isActive = true
        
                self.docAnimationView.heightAnchor.constraint(equalToConstant: 200).isActive = true
                self.docAnimationView.widthAnchor.constraint(equalToConstant: 200).isActive = true
                
                self.docAnimationView.play()
            }

            DispatchQueue.main.asyncAfter(deadline:
                    .now() + .milliseconds(LivenessScreenViewController.BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS) ) {

                self.segmentationAnimHolder.subviews.forEach { $0.removeFromSuperview() }

                self.blockProcessingByUI = false
                
                self.setUIForNextStage()
            }
        }
    }
    
    
    func setUIForNextStage() {
        
        self.btnImReady.isHidden = true
        
        setHintForStage()
        
        blockProcessingByUI = false
        blockRequestByProcessing = false
    }
    
    func setHintForStage() {
        switch(DocType.docCategoryIdxToType(categoryIdx: (docData?.category!)!)) {
            case DocType.FOREIGN_PASSPORT:
                self.indicationText.text = "segmentation_single_page_hint".localized
            case DocType.ID_CARD:
                if (checkedDocIdx == 0) {
                    self.indicationText.text = "segmentation_front_side_hint".localized;
                }
                if (checkedDocIdx == 1) {
                    self.indicationText.text = "segmentation_back_side_hint".localized;
                }
            default:
                if (checkedDocIdx == 0) {
                    self.indicationText.text = "segmentation_front_side_hint".localized;
                }
                if (checkedDocIdx == 1) {
                    self.indicationText.text = "segmentation_back_side_hint".localized;
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
    
    private func setSegmentationFrameSize() {
        if (frameSize == nil) {
            let screenWidth = UIScreen.main.bounds.width

            let frameWidth = screenWidth * 0.82
            let frameHeight = frameWidth * 0.63
            
            self.frameSize = CGSize(width: frameWidth, height: frameHeight)
        }
//            print("VIEW WIDTH: \(screenWidth)")
//            print ("FRAME WIDTH: \(frameWidth) | FRAME HEIGHT: \(frameHeight)")
        
        self.segmentationFrame.frame = CGRect(x: 0, y: 0, width: self.frameSize!.width, height: self.frameSize!.height)
        self.segmentationFrame.center = self.view.center
        
        self.docAnimationView.frame = CGRect(x: 0, y: 0, width: self.frameSize!.width + 20, height: self.frameSize!.height + 20) //!
        self.docAnimationView.center = self.view.center
    }
    
    func animateHandImg() {
        let originalTransform = self.animatingImage.transform
        let scaledTransform = originalTransform.scaledBy(x: 6.0, y: 6.0)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: -20.0, y: -20.0)
        UIView.animate(withDuration: 1.5, delay: 0.0, options: [.repeat], animations: {
            self.animatingImage.transform = scaledAndTranslatedTransform
        })
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
            
//            if (blockProcessingByUI == false) {
//                DispatchQueue.main.async {
//                    //self.updateFaceAnimation()
//                    //self.updateArrowAnimation() //TODO: remove?
//                }
//            }
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


//--------------------------------
//    func writeImage(image: UIImage) {
//        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.finishWriteImage), nil)
//    }
//
//    @objc private func finishWriteImage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
//        if (error != nil) {
//            // Something wrong happened.
//            print("error occurred: \(String(describing: error))")
//        } else {
//            // Everything is alright.
//            print("saved success!")
//        }
//---------------------------------
