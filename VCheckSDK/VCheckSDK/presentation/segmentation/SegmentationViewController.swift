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
    @IBOutlet weak var successFrame: VCheckSDKRoundedView!
    @IBOutlet weak var darkFrameOverlay: UIView!
    @IBOutlet weak var segmentationAnimHolder: UIView!
    @IBOutlet weak var closePseudoBtn: UIImageView!
    @IBOutlet weak var animatingImage: UIImageView!
    @IBOutlet weak var indicationText: UILabel!
    @IBOutlet weak var btnImReady: UIButton!
    
    // MARK: - Session segmentation-specific properties
    private var docData: DocTypeData? = nil
    private var checkedDocIdx = 0
    
    private var frameSize: CGSize? = nil
    private var firstImgToUpload: UIImage? = nil
    private var secondImgToUpload: UIImage? = nil
    private var isBackgroundSet: Bool = false
    
    // MARK: - Anim properties
    private var docAnimationView: AnimationView = AnimationView()
    private let hapticFeedbackGenerator = UINotificationFeedbackGenerator()

   // MARK: - Member Variables (open for ext.)
    var needToShowFatalError = false
    var alertWindowTitle = "Nothing"
    var alertMessage = "Nothing"
    var viewDidAppearReached = false

    // MARK: - Camera / Scene / Streaming properties (open for ext.)
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var videoFieldOfView = Float(0)
    lazy var previewLayer = CALayer()
    var videoStreamingPermitted: Bool = false
    var videoBuffer: CVImageBuffer?

    // MARK: - Milestone flow & logic properties
    static let SEG_TIME_LIMIT_MILLIS = 60000 //max is 60000
    static let BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS = 4000
    static let GESTURE_REQUEST_INTERVAL = 0.45
    static let MASK_UI_MULTIPLY_FACTOR: Double = 1.1

    private var isLivenessSessionFinished: Bool = false
    private var hasEnoughTimeForNextGesture: Bool = true
    private var livenessSessionTimeoutTimer : DispatchSourceTimer?
    private var periodicGestureCheckTimer: Timer?
    private var blockProcessingByUI: Bool = false
    private var blockRequestByProcessing: Bool = false

    // MARK: - Implementation & Lifecycle methods
    
    private func setDocData() {
        docData = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentationFrame.backgroundColor = UIColor.clear
        self.segmentationFrame.borderColor = UIColor.white
        
        self.successFrame.backgroundColor = UIColor.clear
        self.successFrame.borderColor = UIColor.systemGreen
        self.successFrame.isHidden = true
        
        self.darkFrameOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.darkFrameOverlay.isHidden = true

        if !setupCamera() { return }
        
        self.closePseudoBtn.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.declineSessionAndCloseVC(_:))))

        self.setDocData()
        self.setupInstructionStageUI()
    }
    
    @objc func declineSessionAndCloseVC(_ sender: UITapGestureRecognizer) {
        self.hasEnoughTimeForNextGesture = false
        
        self.videoStreamingPermitted = false
        self.isLivenessSessionFinished = true
                        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewDidAppearReached = true
        
        self.onRepeatSessionAfterTimeout()
        self.setupInstructionStageUI()

        if needToShowFatalError {
            popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
        self.setSegmentationFrameSize()
        self.setBackground()
    }
    
    private func setupInstructionStageUI() {

        self.blockProcessingByUI = true
        self.blockRequestByProcessing = true
        
        self.animatingImage.transform = .identity
        self.animatingImage.layer.removeAllAnimations()
        self.animatingImage.isHidden = false
        
        self.animateHandImg()
        
        switch(DocType.docCategoryIdxToType(categoryIdx: (docData?.category!)!)) {
            case DocType.FOREIGN_PASSPORT:
                self.animatingImage.image = UIImage.init(named: "img_hand_foreign_passport")
                self.indicationText.text = "segmentation_instr_foreign_passport_descr".localized
            case DocType.ID_CARD:
                self.animatingImage.image = UIImage.init(named: "img_hand_id_card")
                self.indicationText.text = "segmentation_instr_id_card_descr".localized
            default:
                self.animatingImage.image = UIImage.init(named: "img_hand_inner_passport")
                self.indicationText.text = "segmentation_instr_inner_passport_descr".localized
        }

        self.btnImReady.setTitle("im_ready".localized, for: .normal)
        self.btnImReady.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.setupDocCheckStage(_:))))
    }
    
    @objc func setupDocCheckStage(_ sender: UITapGestureRecognizer) {
        resetFlowForNewSession()
        setUIForNextStage()
    }
    
    
    private func resetFlowForNewSession() {
        
        self.btnImReady.isHidden = true
        
        self.animatingImage.isHidden = true
        
        self.darkFrameOverlay.alpha = 1
        self.darkFrameOverlay.isHidden = true
        
        self.checkedDocIdx = 0

        self.isLivenessSessionFinished = false
        self.hasEnoughTimeForNextGesture = true
        self.blockProcessingByUI = false
        
        self.videoStreamingPermitted = true
        
        self.livenessSessionTimeoutTimer = nil
        self.startLivenessSessionTimeoutTimer()
                
        self.periodicGestureCheckTimer = Timer.scheduledTimer(timeInterval:
                        SegmentationViewController.GESTURE_REQUEST_INTERVAL, target: self,
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
                } else { print("VCheckSDK: VideoBuffer is nil") }
            }
        }
    }
    
    private func areAllDocPagesChecked() -> Bool {
        return checkedDocIdx >= docData!.maxPagesCount!
    }
    
    private func checkStage() {
        guard let fullImage: UIImage = getScreenshotFromVideoStream(videoBuffer!) else {
            print("VCheckSDK - Error: Cannot perform segmentation request: frameImage is nil!")
            return
        }
        
        self.blockRequestByProcessing = true
        
        guard let country = docData!.country, let category = docData!.category else {
            print("VCheckSDK - Error: Doc segmentation request: Error - country or category for request have not been set!")
            return
        }
        
        if let rotatedImage = fullImage.rotate(radians: Float(90.degreesToRadians)) {
            
            guard let croppedImage = rotatedImage.cropWithMask() else {
                print("VCheckSDK - Error: Doc segmentation request: Error - image was not properly cropped!")
                return
            }
            ImageCompressor.compressFrame(image: croppedImage, completion: { (compressedImage) in
                
                if (compressedImage == nil) {
                    print("VCheckSDK - Error: Failed to compress image!")
                    return
                } else {
                    VCheckSDKRemoteDatasource.shared.sendSegmentationDocAttempt(frameImage: compressedImage!,
                                                                                country: country,
                                                                                category: "\(category)",
                                                                                index: "\(self.checkedDocIdx)",
                                                                                completion: { (data, error) in
                        if let error = error {
                            print("VCheckSDK - Error: Doc segmentation request: Error [\(error.errorText)]")
                            return
                        }
                        if (data?.success == true) {
                            self.onStagePassed(fullImage: rotatedImage)
                        }
                        self.blockRequestByProcessing = false
                    })
                }
            })
        } else {
            print("VCheckSDK - Error: Failed to rotate image as needed!")
        }
    }
    
    private func onAllStagesPassed() {
        
        self.periodicGestureCheckTimer?.invalidate()
        
        self.hasEnoughTimeForNextGesture = false
        
        self.videoStreamingPermitted = false
        self.isLivenessSessionFinished = true
        
        self.hapticFeedbackGenerator.notificationOccurred(.success)
        
        if (self.livenessSessionTimeoutTimer != nil) {
            self.livenessSessionTimeoutTimer!.cancel()
        }
                
        self.performSegue(withIdentifier: "SegToCheckDocInfo", sender: nil)
    }
    
    private func onStagePassed(fullImage: UIImage) {
        if (self.checkedDocIdx == 0) {
            self.firstImgToUpload = fullImage
        } else if (self.checkedDocIdx == 1) {
            self.secondImgToUpload = fullImage
        }
        self.checkedDocIdx += 1
        
        self.hapticFeedbackGenerator.notificationOccurred(.success)
        if (!self.areAllDocPagesChecked()) {
            self.indicateNextStage()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegToCheckDocInfo") {
            let vc = segue.destination as! CheckDocPhotoViewController
            vc.firstPhoto = self.firstImgToUpload
            vc.secondPhoto = self.secondImgToUpload
            vc.isFromSegmentation = true
            vc.onRepeatBlock = { result in }
        }
        if (segue.identifier == "SegToTimeout") {
            let vc = segue.destination as! SegmentationTimeoutViewController
            vc.onRepeatBlock = { result in }
            vc.isInvalidDocError = false
        }
    }
    
    private func onRepeatSessionAfterTimeout() {
        //self.checkedDocIdx = 0
        self.setHintForStage()
        self.darkFrameOverlay.alpha = 1
        self.darkFrameOverlay.isHidden = true
        self.successFrame.alpha = 1
        self.successFrame.isHidden = true
        self.darkFrameOverlay.isHidden = true
        self.btnImReady.isHidden = false
        self.animatingImage.transform = .identity
        self.animatingImage.layer.removeAllAnimations()
        self.setupInstructionStageUI()
    }
    
    private func startLivenessSessionTimeoutTimer() {
        let delay : DispatchTime = .now() + .milliseconds(SegmentationViewController.SEG_TIME_LIMIT_MILLIS)
        if livenessSessionTimeoutTimer == nil {
            livenessSessionTimeoutTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            livenessSessionTimeoutTimer!.schedule(deadline: delay, repeating: 0)
            livenessSessionTimeoutTimer!.setEventHandler {
                
                self.periodicGestureCheckTimer?.invalidate()
                
                if (self.livenessSessionTimeoutTimer != nil) {
                    self.livenessSessionTimeoutTimer!.cancel()
                }
                
                DispatchQueue.main.async(execute: {
                    self.endSessionPrematurely(performSegueWithIdentifier: "SegToTimeout")
                })
            }
            livenessSessionTimeoutTimer!.resume()
        } else {
            livenessSessionTimeoutTimer?.schedule(deadline: delay, repeating: 0)
        }
    }

    private func endSessionPrematurely(performSegueWithIdentifier: String) {
        
        self.hasEnoughTimeForNextGesture = false
        
        self.videoStreamingPermitted = false
        self.isLivenessSessionFinished = true
                
        self.hapticFeedbackGenerator.notificationOccurred(.warning)
        
        self.performSegue(withIdentifier: performSegueWithIdentifier, sender: nil)
    }
}


// MARK: - Animation and UI/UX extensions

extension SegmentationViewController {

    func indicateNextStage() {
        DispatchQueue.main.async {
            
            self.blockProcessingByUI = true
            
            self.segmentationFrame.isHidden = true
            self.successFrame.isHidden = false
            self.darkFrameOverlay.isHidden = false

            self.indicationText.text = "segmentation_stage_success".localized;
            
            if (DocType.docCategoryIdxToType(categoryIdx: (self.docData?.category!)!) == DocType.ID_CARD
                && self.checkedDocIdx == 1) {
                self.indicationText.text = "segmentation_stage_success_first_page".localized
            } else {
                self.indicationText.text = "segmentation_stage_success".localized;
            }

            //self.textIndicatorConstraint.constant = 40.0 // was temp fix
            //self.indicationText.centerYAnchor.constraint(equalTo: self.indicationText.centerYAnchor, constant: 40.0).isActive = true // was temp fix
            
            self.fadeFrameInThenOut(view: self.successFrame, delay: 0.0)
            
            self.fadeViewIn(view: self.darkFrameOverlay, delay: 0.0, animationDuration: 0.5)
            
            DispatchQueue.main.asyncAfter(deadline:
                    .now() + .milliseconds(900)) { //duration of full fade animation cycle
                self.successFrame.isHidden = true
                self.playStageSuccessAnimation()
            }
            DispatchQueue.main.asyncAfter(deadline:
                    .now() + .milliseconds(3500)) { //BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS - 500
                self.fadeViewOut(view: self.darkFrameOverlay, delay: 0.0, animationDuration: 0.5)
            }
            DispatchQueue.main.asyncAfter(deadline:
                    .now() + .milliseconds(SegmentationViewController.BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS)) {

                self.segmentationAnimHolder.subviews.forEach { $0.removeFromSuperview() }

                self.blockProcessingByUI = false
                
                self.setUIForNextStage()
            }
        }
    }
    
    func playStageSuccessAnimation() {
        self.segmentationAnimHolder.subviews.forEach { $0.removeFromSuperview() }
        
        if (DocType.docCategoryIdxToType(categoryIdx: (self.docData?.category!)!) == DocType.ID_CARD) {
            
            self.docAnimationView = AnimationView(name: "id_card_turn_side", bundle: InternalConstants.bundle)
    
            self.docAnimationView.contentMode = .scaleAspectFill
            self.docAnimationView.translatesAutoresizingMaskIntoConstraints = false
            self.segmentationAnimHolder.addSubview(self.docAnimationView)
    
            self.docAnimationView.centerXAnchor.constraint(equalTo: self.segmentationAnimHolder.centerXAnchor).isActive = true
            self.docAnimationView.centerYAnchor.constraint(equalTo: self.segmentationAnimHolder.centerYAnchor).isActive = true
                        
            self.docAnimationView.loopMode = .playOnce
            
            self.docAnimationView.play()
        }
    }
    
    func updateDocAnimation() {
        if (self.blockProcessingByUI == true) {
            DispatchQueue.main.async {
                let toProgress = self.docAnimationView.realtimeAnimationProgress
                if (toProgress <= 0.01) {
                    self.docAnimationView.play(toProgress: toProgress + 1)
                }
            }
        }
    }
    
    func setUIForNextStage() {
        
        self.segmentationFrame.isHidden = false
        
        self.darkFrameOverlay.isHidden = true
        
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
    
    private func setSegmentationFrameSize() {
        if let maskDimens = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData().maskDimensions {
            
            if (frameSize == nil) {
                let screenWidth = UIScreen.main.bounds.width

                let frameWidth = (screenWidth * (maskDimens.widthPercent! / 100) * SegmentationViewController.MASK_UI_MULTIPLY_FACTOR)
                let frameHeight = frameWidth * (maskDimens.ratio!)
                
                self.frameSize = CGSize(width: frameWidth, height: frameHeight)
            }
            
            self.segmentationFrame.frame = CGRect(x: 0, y: 0, width: self.frameSize!.width, height: self.frameSize!.height)
            self.segmentationFrame.center = self.view.center
            
            self.successFrame.frame = CGRect(x: 0, y: 0, width: self.frameSize!.width, height: self.frameSize!.height)
            self.successFrame.center = self.view.center
            
            self.darkFrameOverlay.frame = CGRect(x: 0, y: 0, width: self.frameSize!.width, height: self.frameSize!.height)
            self.darkFrameOverlay.center = self.view.center
            
            self.segmentationAnimHolder.frame = CGRect(x: 0, y: 0, width: self.frameSize!.width + 60, height: self.frameSize!.height + 60) //!
            self.segmentationAnimHolder.center = self.view.center
            
        } else {
            showToast(message: "Error: cannot retrieve mask dimensions from document type info", seconds: 3.0)
        }
    }
    
    func animateHandImg() {
        let originalTransform = self.animatingImage.transform
        let scaledTransform = originalTransform.scaledBy(x: 7.0, y: 7.0)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: -20.0, y: -20.0)
        UIView.animate(withDuration: 1.4, delay: 0.0, options: [.repeat], animations: {
            self.animatingImage.transform = scaledAndTranslatedTransform
        })
    }
    
    func setBackground() {
        if let frameSize = self.frameSize {
            if (self.isBackgroundSet == false) {
                let pathBigRect = UIBezierPath(rect: self.view.bounds)
                let pathSmallRect = UIBezierPath(rect: CGRect(x: ((self.view.viewWidth - frameSize.width) / 2) + 2,
                                                              y: ((self.view.viewHeight - frameSize.height) / 2) + 2,
                                                              width: frameSize.width - 4,
                                                              height: frameSize.height - 4))
                pathBigRect.append(pathSmallRect)
                
                pathBigRect.usesEvenOddFillRule = true

                let fillLayer = CAShapeLayer()
                fillLayer.path = pathBigRect.cgPath
                fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
                fillLayer.fillColor = UIColor.black.cgColor
                fillLayer.opacity = 0.5
                self.view.layer.insertSublayer(fillLayer, at: 1)
                
                self.isBackgroundSet = true
            }
        }
    }
    
    func fadeFrameInThenOut(view : UIView, delay: TimeInterval) {
        DispatchQueue.main.async {
            let animationDuration = Double(0.9)
            UIView.animate(withDuration: animationDuration, delay: delay,
                           options: [UIView.AnimationOptions.autoreverse,
                                     UIView.AnimationOptions.repeat], animations: {
                view.alpha = 0
            }, completion: nil)
        }
    }
    
    func fadeViewIn(view : UIView, delay: TimeInterval, animationDuration: Double) {
        DispatchQueue.main.async {
            view.alpha = 0
            UIView.animate(withDuration: animationDuration, delay: delay,
                           options: [], animations: {
                view.alpha = 1
            }, completion: nil)
        }
    }
    
    func fadeViewOut(view : UIView, delay: TimeInterval, animationDuration: Double) {
        DispatchQueue.main.async {
            view.alpha = 1
            UIView.animate(withDuration: animationDuration, delay: delay,
                           options: [], animations: {
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
            return UIImage(cgImage: cgImage)
        } else {
            print("VCheckSDK - Error: Failed to convert screen into image!")
            return nil
        }
    }
    
}
