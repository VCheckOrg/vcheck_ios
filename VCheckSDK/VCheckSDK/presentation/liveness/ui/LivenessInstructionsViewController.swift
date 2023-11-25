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
    
    private static let HALF_BALL_ANIM_TIME: Int = 1000
    private static let PHONE_TO_FACE_CYCLE_INTERVAL: Int = 2000
    private static let FACE_FADE_DURATION: Int = 550
    
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
                    self.setupOrUpdateFaceAnimation()
                case 3:
                    self.setupOrUpdateFaceAnimation()
                case 4:
                    self.startMouthOpeningCycle()
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
        
        faceAnimationView.contentMode = .scaleAspectFit
        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
        animsHolder.addSubview(faceAnimationView)
        
        faceAnimationView.centerXAnchor.constraint(equalTo: animsHolder.centerXAnchor, constant: 4).isActive = true
        faceAnimationView.centerYAnchor.constraint(equalTo: animsHolder.centerYAnchor).isActive = true
        
        //TODO: remove completely
        //removed all size constraints
//        faceAnimationView.heightAnchor.constraint(equalToConstant: 164).isActive = true
//        faceAnimationView.widthAnchor.constraint(equalToConstant: 164).isActive = true
        
        faceAnimationView.loopMode = .loop
        
        faceAnimationView.play()
        
        self.currentCycleIdx += 1
    }
    
    func setupOrUpdateFaceAnimation() {
                
        rightFadingCircle.isHidden = false
        leftFadingCircle.isHidden = false
        arrowAnimationView.isHidden = false
        
        animsHolder.subviews.forEach { $0.removeFromSuperview() }
            
        if (currentCycleIdx == 2) {
            fadeViewInThenOut(view: leftFadingCircle, delay: 0.0)
            faceAnimationView = LottieAnimationView(name: "left", bundle: InternalConstants.bundle)
        } else {
            fadeViewInThenOut(view: rightFadingCircle, delay: 0.0)
            faceAnimationView = LottieAnimationView(name: "right", bundle: InternalConstants.bundle)
        }
        
        faceAnimationView.contentMode = .scaleAspectFit
        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
        animsHolder.addSubview(faceAnimationView)
        
        faceAnimationView.centerXAnchor.constraint(equalTo: animsHolder.centerXAnchor, constant: 4).isActive = true
        faceAnimationView.centerYAnchor.constraint(equalTo: animsHolder.centerYAnchor).isActive = true
        
//        faceAnimationView.heightAnchor.constraint(equalToConstant: 310).isActive = true
//        faceAnimationView.widthAnchor.constraint(equalToConstant: 310).isActive = true
        
        faceAnimationView.loopMode = .loop
        
        faceAnimationView.play()
        
        self.currentCycleIdx += 1
    }
    
    func startMouthOpeningCycle() {
        
        rightFadingCircle.isHidden = true
        leftFadingCircle.isHidden = true
        arrowAnimationView.isHidden = true
        
        animsHolder.subviews.forEach { $0.removeFromSuperview() }
        
        faceAnimationView = LottieAnimationView(name: "mouth", bundle: InternalConstants.bundle)
        
        faceAnimationView.contentMode = .scaleAspectFit
        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
        animsHolder.addSubview(faceAnimationView)
        
        faceAnimationView.loopMode = .loop
        
        faceAnimationView.play()
        
        self.currentCycleIdx = 1
    }
    
//
//         fadeFaceAnimInForTransition()
//
//         Handler(Looper.getMainLooper()).postDelayed({
//             fadeFaceAnimOutForTransition()
//         }, PHONE_TO_FACE_CYCLE_INTERVAL - FACE_FADE_DURATION)
//
//         currentCycleIdx = 1
//     }
    
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
        
    }
    
    func fadeFaceAnimOutForTransition() {
        
    }
    
    
    
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        let animationDuration = 2.0
        UIView.animate(withDuration: animationDuration, delay: delay,
                       options: [UIView.AnimationOptions.autoreverse,
                                 UIView.AnimationOptions.repeat], animations: {
            view.alpha = 0
        }, completion: nil)
    }
}
