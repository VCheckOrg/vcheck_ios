//
//  LivenessInstructionsViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 11.05.2022.
//

import Foundation
import UIKit
import Lottie

class LivenessInstructionsViewController: UIViewController {
    
    @IBOutlet weak var arrowHolder: UIView!
    
    @IBOutlet weak var animsHolder: RoundedView!
    
    var timer = Timer()
    
    private var playAnimForLeftCycle: Bool = true

    
    // MARK: - Anim properties
    private var faceAnimationView: AnimationView = AnimationView()
    private var arrowAnimationView: AnimationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAnimsCycle()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
            self.updateAnimsCycle()
        })
    }
    
    func updateAnimsCycle() {
        self.setupOrUpdateFaceAnimation(forLeftCycle: self.playAnimForLeftCycle)
        self.setupOrUpdateArrowAnimation(forLeftCycle: self.playAnimForLeftCycle)
        self.playAnimForLeftCycle = !self.playAnimForLeftCycle
    }
    
    func setupOrUpdateFaceAnimation(forLeftCycle: Bool) {
        
        animsHolder.subviews.forEach { $0.removeFromSuperview() }
            
        if (forLeftCycle == true) {
            faceAnimationView = AnimationView(name: "left")
        } else {
            faceAnimationView = AnimationView(name: "right")
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
            arrowAnimationView = AnimationView(name: "arrow")
            
            arrowAnimationView.contentMode = .scaleAspectFill
            arrowAnimationView.translatesAutoresizingMaskIntoConstraints = false
            arrowHolder.addSubview(arrowAnimationView)
            
            arrowAnimationView.centerXAnchor.constraint(equalTo: arrowHolder.centerXAnchor, constant: -60).isActive = true
            arrowAnimationView.centerYAnchor.constraint(equalTo: arrowHolder.centerYAnchor).isActive = true
            
            arrowAnimationView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            arrowAnimationView.widthAnchor.constraint(equalToConstant: 220).isActive = true
            
            arrowAnimationView.loopMode = .loop
            
        } else {
            arrowAnimationView = AnimationView(name: "arrow")
            
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
    
    
            
//        } else {
//            arrowAnimationView = AnimationView()
//            arrowAnimationView.stop()
//            rightArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
//            leftArrowAnimHolderView.subviews.forEach { $0.removeFromSuperview() }
//        }
    
//    func updateFaceAnimation() {
//        if (self.blockStageIndicationByUI == false) {
//            DispatchQueue.main.async {
//                let toProgress = self.faceAnimationView.realtimeAnimationProgress
//                if (toProgress >= 0.99) {
//                    self.faceAnimationView.play(toProgress: toProgress - 0.99)
//                }
//                if (toProgress <= 0.01) {
//                    self.faceAnimationView.play(toProgress: toProgress + 1)
//                }
//            }
//        }
//    }
//
//    func updateArrowAnimation() {
//        if (self.blockStageIndicationByUI == false) {
//            DispatchQueue.main.async {
//                let toProgress = self.arrowAnimationView.realtimeAnimationProgress
//                if (toProgress <= 0.01) {
//                    self.arrowAnimationView.play(toProgress: toProgress + 1)
//                }
//            }
//        }
//    }
}
