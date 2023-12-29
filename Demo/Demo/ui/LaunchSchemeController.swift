//
//  ChooseSchemeController.swift
//  Demo
//
//  Created by Kirill Kaun on 28.12.2023.
//

import Foundation

import UIKit
import VCheckSDK

class LaunchSchemeController: UIViewController {

    @IBOutlet weak var fullFlowBtn: UIButton!
    @IBOutlet weak var docCheckOnlyBtn: UIButton!
    @IBOutlet weak var livenessOnlyBtn: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentScrollView: UIScrollView!

    @IBAction func startFullSDKFlow(_ sender: Any) {
        self.createVerification(verifType: VerificationSchemeType.FULL_CHECK)
    }
    @IBAction func startDocCheckOnlyFlow(_ sender: Any) {
        self.createVerification(verifType: VerificationSchemeType.DOCUMENT_UPLOAD_ONLY)
    }
    @IBAction func startLivenessOnlyFlow(_ sender: Any) {
        self.createVerification(verifType: VerificationSchemeType.LIVENESS_CHALLENGE_ONLY)
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadingIndicator.isHidden = true
        
        setLocalizedTexts()
    }
    
    func setLocalizedTexts() {
        self.fullFlowBtn.setTitle("full_verification".localized, for: .normal)
        self.livenessOnlyBtn.setTitle("verification_of_liveness".localized, for: .normal)
        self.docCheckOnlyBtn.setTitle("verification_of_documents".localized, for: .normal)
    }
    
    func createVerification(verifType: VerificationSchemeType) {
        
        self.loadingIndicator.isHidden = false
        self.contentScrollView.isHidden = true
        
        RemoteDatasource.shared.requestServerTimestamp(completion: { (timestamp, error) in
            if let ts = timestamp {
                RemoteDatasource.shared.createVerificationRequest(timestamp: ts,
                                                                   locale: LocalDatasource.shared.getLang(),
                                                                   scheme: verifType.description.lowercased(),
                                                                   completion: { (data, error) in
                    if let error = error {
                        self.showToast(message: error, seconds: 3.0)
                        self.loadingIndicator.isHidden = true
                        self.contentScrollView.isHidden = false
                        return
                    }

                    LocalDatasource.shared.setVerificationId(id: data!.id!)
                    self.startSDK(verifType: verifType, token: data!.token!)
                })
            } else {
                self.showToast(message: "Error: server timestamp not set", seconds: 3.0)
                self.loadingIndicator.isHidden = true
                self.contentScrollView.isHidden = false
                return
            }
        })
    }
    
    ///An example of the partner's app function of handling an SDK flow end
    func onSDKFlowFinished() {
        let sceneDelegate = getOwnSceneDelegate()!
        sceneDelegate.window!.rootViewController = self
        sceneDelegate.window!.makeKeyAndVisible()
        self.performSegue(withIdentifier: "ChooseSchemeToVerifStatus", sender: nil)
    }
    
    func onVerificationExpired() {
        DispatchQueue.main.async {
            self.showToast(message: "Verification session expired. Please, try again", seconds: 3)
        }
    }
    
    ///An example on how to start SDK
    func startSDK(verifType: VerificationSchemeType, token: String) {
                                
        VCheckSDK.shared
            .verificationToken(token: token)
            .verificationType(type: verifType)
            .languageCode(langCode: LocalDatasource.shared.getLang())
            //.designConfig(config: self.designConfig) //we should add this call to chain in actual partner app
            .environment(env: VCheckEnvironment.DEV)
            .showPartnerLogo(show: false)
            .showCloseSDKButton(show: true)
            .partnerEndCallback(callback: {
                self.onSDKFlowFinished()
            })
            .onVerificationExpired(callback: {
                self.onVerificationExpired()
            })
            .start(partnerAppRW: (getOwnSceneDelegate()?.window!)!,
                    partnerAppVC: self,
                    replaceRootVC: true)
        
        self.loadingIndicator.isHidden = true
        self.contentScrollView.isHidden = false
    }
    
    func getOwnSceneDelegate() -> SceneDelegate? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene!.delegate as? SceneDelegate ?? nil
    }
}
