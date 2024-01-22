//
//  LivenessInstructionsViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 11.05.2022.
//

import Foundation
import UIKit
@_implementationOnly import Lottie

class LivenessInstructionsViewController: UIViewController {
    
    @IBOutlet weak var arrowHolder: UIView!
    
    @IBOutlet weak var animsHolder: VCheckSDKRoundedView!
    
    @IBOutlet weak var rightFadingCircle: VCheckSDKRoundedView!
    @IBOutlet weak var leftFadingCircle: VCheckSDKRoundedView!
    
    var timer = Timer()
    
    private var currentCycleIdx = 1
    
    private static let HALF_BALL_ANIM_TIME_SEC: TimeInterval = 1
    private static let PHONE_TO_FACE_CYCLE_INTERVAL_SEC: TimeInterval = 2
    private static let FACE_FADE_DURATION_SEC: TimeInterval = 0.55
    
    // MARK: - Anim properties
    private var faceAnimationView: LottieAnimationView = LottieAnimationView()
    private var arrowAnimationView: LottieAnimationView = LottieAnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightFadingCircle.backgroundColor = UIColor.systemGreen
        leftFadingCircle.backgroundColor = UIColor.systemGreen
                
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
            
            switch(self.currentCycleIdx) {
                case 1:
                    self.startPhoneAnimCycle()
                case 2:
                    self.setupOrUpdateFaceSidesAnimation()
                case 3:
                    self.setupOrUpdateFaceSidesAnimation()
                case 4:
                    self.startBlinkEyesCycle()
                default:
                    break;
            }
        })
        self.timer.fire()
    }
    
    func startPhoneAnimCycle() {
        
        rightFadingCircle.isHidden = true
        leftFadingCircle.isHidden = true
        arrowAnimationView.isHidden = true
        
        arrowHolder.subviews.forEach { $0.removeFromSuperview() }
        
        animsHolder.subviews.forEach { $0.removeFromSuperview() }
        
        faceAnimationView = LottieAnimationView(name: "face_plus_phone", bundle: InternalConstants.bundle)
        
        faceAnimationView.isHidden = true
        
        faceAnimationView.contentMode = .scaleAspectFit
        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
        animsHolder.addSubview(faceAnimationView)
        
        faceAnimationView.centerXAnchor.constraint(equalTo: animsHolder.centerXAnchor, constant: 4).isActive = true
        faceAnimationView.centerYAnchor.constraint(equalTo: animsHolder.centerYAnchor).isActive = true
        
        faceAnimationView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        faceAnimationView.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        faceAnimationView.play(toFrame: AnimationFrameTime(26), loopMode: .playOnce)
                
        fadeFaceAnimInForTransition()
        fadeFaceAnimOutForTransition()
        
        self.currentCycleIdx += 1
    }
    
    func setupOrUpdateFaceSidesAnimation() {
        
        if (currentCycleIdx == 2 || currentCycleIdx == 3) {
            rightFadingCircle.isHidden = false
            leftFadingCircle.isHidden = false
            arrowAnimationView.isHidden = false
            
            animsHolder.subviews.forEach { $0.removeFromSuperview() }
                
            if (currentCycleIdx == 2) {
                animateLeftFadingCircle()
                faceAnimationView = LottieAnimationView(name: "left", bundle: InternalConstants.bundle)
            }
            if (currentCycleIdx == 3) {
                animateRightFadingCircle()
                faceAnimationView = LottieAnimationView(name: "right", bundle: InternalConstants.bundle)
            }
            
            faceAnimationView.isHidden = true
            
            faceAnimationView.contentMode = .scaleAspectFit
            faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
            animsHolder.addSubview(faceAnimationView)
            
            faceAnimationView.centerXAnchor.constraint(equalTo: animsHolder.centerXAnchor, constant: 4).isActive = true
            faceAnimationView.centerYAnchor.constraint(equalTo: animsHolder.centerYAnchor, constant: 0).isActive = true
            
            faceAnimationView.heightAnchor.constraint(equalToConstant: 160).isActive = true
            faceAnimationView.widthAnchor.constraint(equalToConstant: 160).isActive = true
            
            faceAnimationView.loopMode = .loop
            
            faceAnimationView.play()
            
            fadeFaceAnimInForTransition()
            fadeFaceAnimOutForTransition()
            
            self.currentCycleIdx += 1
        }
    }
    
    func startBlinkEyesCycle() {
        
        rightFadingCircle.isHidden = true
        leftFadingCircle.isHidden = true
        arrowAnimationView.isHidden = true
        
        animsHolder.subviews.forEach { $0.removeFromSuperview() }
        
        faceAnimationView = LottieAnimationView(name: "blink", bundle: InternalConstants.bundle)
        
        faceAnimationView.isHidden = true
        
        faceAnimationView.contentMode = .scaleAspectFit
        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
        animsHolder.addSubview(faceAnimationView)
        
        faceAnimationView.centerXAnchor.constraint(equalTo: animsHolder.centerXAnchor, constant: 2).isActive = true
        faceAnimationView.centerYAnchor.constraint(equalTo: animsHolder.centerYAnchor, constant: 0).isActive = true
        
        faceAnimationView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        faceAnimationView.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        faceAnimationView.loopMode = .loop
        
        faceAnimationView.play()
        
        fadeFaceAnimInForTransition()
        fadeFaceAnimOutForTransition()
        
        self.currentCycleIdx = 1
    }
    
    func setupOrUpdateArrowAnimation(forLeftCycle: Bool) {
        
        arrowHolder.subviews.forEach { $0.removeFromSuperview() }

        if (forLeftCycle) {
            arrowAnimationView = LottieAnimationView(name: "arrow", bundle: InternalConstants.bundle)
            
            arrowAnimationView.contentMode = .scaleAspectFill
            arrowAnimationView.translatesAutoresizingMaskIntoConstraints = false
            arrowHolder.addSubview(arrowAnimationView)
            
            arrowAnimationView.centerXAnchor.constraint(equalTo: arrowHolder.centerXAnchor, constant: -60).isActive = true
            arrowAnimationView.centerYAnchor.constraint(equalTo: arrowHolder.centerYAnchor).isActive = true
            
            arrowAnimationView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            arrowAnimationView.widthAnchor.constraint(equalToConstant: 220).isActive = true
            
            arrowAnimationView.loopMode = .loop
            
        } else {
            arrowAnimationView = LottieAnimationView(name: "arrow", bundle: InternalConstants.bundle)
            
            arrowAnimationView.contentMode = .scaleAspectFill
            arrowAnimationView.translatesAutoresizingMaskIntoConstraints = false
            arrowHolder.addSubview(arrowAnimationView)
            
            arrowAnimationView.centerXAnchor.constraint(equalTo: arrowHolder.centerXAnchor, constant: 60).isActive = true
            arrowAnimationView.centerYAnchor.constraint(equalTo: arrowHolder.centerYAnchor, constant: 10).isActive = true
            
            arrowAnimationView.heightAnchor.constraint(equalToConstant: 190).isActive = true
            arrowAnimationView.widthAnchor.constraint(equalToConstant: 220).isActive = true
            
            arrowAnimationView.transform = CGAffineTransform(rotationAngle: CGFloat.pi) //rotate by 180 deg.
            
            arrowAnimationView.loopMode = .loop
        }
        
        arrowAnimationView.play()
    }
    
    func fadeFaceAnimInForTransition() {
        faceAnimationView.isHidden = false
        faceAnimationView.fadeIn(duration: LivenessInstructionsViewController.FACE_FADE_DURATION_SEC, delay: 0)
    }
    
    func fadeFaceAnimOutForTransition() {
        faceAnimationView.fadeOut(duration: LivenessInstructionsViewController.FACE_FADE_DURATION_SEC, delay: 
                                    LivenessInstructionsViewController.PHONE_TO_FACE_CYCLE_INTERVAL_SEC - LivenessInstructionsViewController.FACE_FADE_DURATION_SEC)
    }
    
    func animateRightFadingCircle() {
        self.leftFadingCircle.isHidden = true
        self.rightFadingCircle.fadeIn(duration: 1, delay: 0)
        self.rightFadingCircle.fadeOut(duration: 1, delay: 1)
    }
    
    func animateLeftFadingCircle() {
        self.rightFadingCircle.isHidden = true
        self.leftFadingCircle.fadeIn(duration: 1, delay: 0)
        self.leftFadingCircle.fadeOut(duration: 1, delay: 1)
    }
}
