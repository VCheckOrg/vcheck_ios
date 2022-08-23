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
    static let BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS = 7000
    static let GESTURE_REQUEST_INTERVAL = 0.45

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

        if !setupCamera() { return }
        
        self.closePseudoBtn.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.declineSessionAndCloseVC(_:))))

        self.setDocData()
        self.setupInstructionStageUI()
    }
    
    @objc func declineSessionAndCloseVC(_ sender: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
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
        self.setBackground()
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

        self.btnImReady.setTitle("im_ready".localized, for: .normal)
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
        self.indicateNextStage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegToCheckDocInfo") {
            let vc = segue.destination as! CheckDocPhotoViewController
            vc.firstPhoto = self.firstImgToUpload
            vc.secondPhoto = self.secondImgToUpload
        }
        if (segue.identifier == "SegToTimeout") {
            let vc = segue.destination as! SegmentationTimeoutViewController
            vc.onRepeatBlock = { result in self.resetFlowForNewSession() }
        }
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

            self.indicationText.text = "segmentation_stage_success".localized;
            
            //self.textIndicatorConstraint.constant = 40.0 // was temp fix
            //self.indicationText.centerYAnchor.constraint(equalTo: self.indicationText.centerYAnchor, constant: 40.0).isActive = true

            self.blockProcessingByUI = true
            
            self.segmentationAnimHolder.subviews.forEach { $0.removeFromSuperview() }
            
            if (DocType.docCategoryIdxToType(categoryIdx: (self.docData?.category!)!) == DocType.ID_CARD) {
                
                self.docAnimationView = AnimationView(name: "id_card_turn_front", bundle: InternalConstants.bundle)
        
                self.docAnimationView.contentMode = .scaleAspectFit
                self.docAnimationView.translatesAutoresizingMaskIntoConstraints = false
                self.segmentationAnimHolder.addSubview(self.docAnimationView)
        
                self.docAnimationView.centerXAnchor.constraint(equalTo: self.segmentationAnimHolder.centerXAnchor).isActive = true
                self.docAnimationView.centerYAnchor.constraint(equalTo: self.segmentationAnimHolder.centerYAnchor).isActive = true
        
                self.docAnimationView.heightAnchor.constraint(equalToConstant: 400).isActive = true
                self.docAnimationView.widthAnchor.constraint(equalToConstant: 400).isActive = true
                
                self.docAnimationView.play(fromFrame: 0, toFrame: 200, loopMode: .playOnce, completion: {_ in
                    print("COMPLETION CAUGHT!")
                    //TODO: fix anim and add proper anim file! Not playing till the end on iOS + Android
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline:
                    .now() + .milliseconds(SegmentationViewController.BLOCK_PIPELINE_ON_ST_SUCCESS_TIME_MILLIS) ) {

                self.segmentationAnimHolder.subviews.forEach { $0.removeFromSuperview() }

                self.blockProcessingByUI = false
                
                self.setUIForNextStage()
            }
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
        if (frameSize == nil) {
            let screenWidth = UIScreen.main.bounds.width

            let frameWidth = screenWidth * 0.82
            let frameHeight = frameWidth * 0.63
            
            self.frameSize = CGSize(width: frameWidth, height: frameHeight)
        }
        
        self.segmentationFrame.frame = CGRect(x: 0, y: 0, width: self.frameSize!.width, height: self.frameSize!.height)
        self.segmentationFrame.center = self.view.center
        
        self.docAnimationView.frame = CGRect(x: 0, y: 0, width: self.frameSize!.width + 26, height: self.frameSize!.height + 26) //!
        self.docAnimationView.center = self.view.center
    }
    
    func animateHandImg() {
        let originalTransform = self.animatingImage.transform
        let scaledTransform = originalTransform.scaledBy(x: 7.0, y: 7.0)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: -20.0, y: -20.0)
        UIView.animate(withDuration: 1.5, delay: 0.0, options: [.repeat], animations: {
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
