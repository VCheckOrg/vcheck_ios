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
    
    private var isLeftTurnSubCycle: Bool = true
    
    
    // MARK: - Anim properties
    private var faceAnimationView: LottieAnimationView = LottieAnimationView()
    private var arrowAnimationView: LottieAnimationView = LottieAnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightFadingCircle.backgroundColor = UIColor.systemGreen
        leftFadingCircle.backgroundColor = UIColor.systemGreen
                
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
            if (self.currentCycleIdx == 1) {
                self.startPhoneAnimCycle()
            } else if (self.currentCycleIdx == 2) {
                self.isLeftTurnSubCycle = true
                self.startFaceSidesAnimation()
            } else {
                self.isLeftTurnSubCycle = false
                self.startFaceSidesAnimation()
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
        
        faceAnimationView.heightAnchor.constraint(equalToConstant: 164).isActive = true
        faceAnimationView.widthAnchor.constraint(equalToConstant: 164).isActive = true
        
        faceAnimationView.loopMode = .loop
        
        faceAnimationView.play()
        
        self.currentCycleIdx += 1
    }
    
    func startFaceSidesAnimation() {
        rightFadingCircle.isHidden = false
        leftFadingCircle.isHidden = false
        arrowAnimationView.isHidden = false
        self.setupOrUpdateFaceAnimation(forLeftCycle: self.isLeftTurnSubCycle)
        self.setupOrUpdateArrowAnimation(forLeftCycle: self.isLeftTurnSubCycle)
        self.fadeInOutCircles(forLeftCycle: !self.isLeftTurnSubCycle)
        self.isLeftTurnSubCycle = !self.isLeftTurnSubCycle
        if (self.currentCycleIdx >= 3) {
            self.currentCycleIdx = 1
        } else {
            self.currentCycleIdx += 1
        }
    }
    
    func setupOrUpdateFaceAnimation(forLeftCycle: Bool) {
        
        animsHolder.subviews.forEach { $0.removeFromSuperview() }
            
        if (forLeftCycle == true) {
            faceAnimationView = LottieAnimationView(name: "left", bundle: InternalConstants.bundle)
        } else {
            faceAnimationView = LottieAnimationView(name: "right", bundle: InternalConstants.bundle)
        }
        
        faceAnimationView.contentMode = .scaleAspectFit
        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
        animsHolder.addSubview(faceAnimationView)
        
        faceAnimationView.centerXAnchor.constraint(equalTo: animsHolder.centerXAnchor, constant: 4).isActive = true
        faceAnimationView.centerYAnchor.constraint(equalTo: animsHolder.centerYAnchor).isActive = true
        
        faceAnimationView.heightAnchor.constraint(equalToConstant: 310).isActive = true
        faceAnimationView.widthAnchor.constraint(equalToConstant: 310).isActive = true
        
        faceAnimationView.loopMode = .loop
        
        faceAnimationView.play()
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
    
    func fadeInOutCircles(forLeftCycle: Bool) {
        if (forLeftCycle) {
            fadeViewInThenOut(view: leftFadingCircle, delay: 0.0)
        } else {
            fadeViewInThenOut(view: rightFadingCircle, delay: 0.0)
        }
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
