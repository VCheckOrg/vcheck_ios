//
//  DemoStartViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 25.04.2022.
//

import Foundation
import UIKit
import AVFoundation


class VCheckStartViewController : UIViewController {
    
    private let viewModel = VCheckStartViewModel()
    
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                                
        if (self.spinner.isAnimating) {
            self.spinner.stopAnimating()
        }
        
        retryBtn.isHidden = true
        
        requestCameraPermission()
    }

    private func initVerification() {
        
        retryBtn.isHidden = true
        
        self.activityIndicatorStart()
        
        viewModel.verificationIsAlreadyCompleted = {
            self.performSegue(withIdentifier: "StartToVerifAlreadyCompleted", sender: nil)
        }
        
        viewModel.didReceivedCurrentStage = {
            if (self.viewModel.currentStageResponse?.errorCode != nil
                && self.viewModel.currentStageResponse?.errorCode ==
                    StageObstacleErrorType.USER_INTERACTED_COMPLETED.toTypeIdx()) {
                self.performSegue(withIdentifier: "StartToLivenessInstructions", sender: nil)
            } else {
                if (self.viewModel.currentStageResponse?.data != nil) {
                    if (self.viewModel.currentStageResponse?.data?.uploadedDocId != nil) {
                        self.performSegue(withIdentifier: "StartToCheckDocInfo", sender: self.viewModel.currentStageResponse?.data?.uploadedDocId)
                        return
                    } else if (self.viewModel.currentStageResponse?.data?.primaryDocId != nil) {
                        self.performSegue(withIdentifier: "StartToCheckDocInfo", sender: self.viewModel.currentStageResponse?.data?.primaryDocId)
                        return
                    } else if (self.viewModel.currentStageResponse!.data!.type! == StageType.DOCUMENT_UPLOAD.toTypeIdx()) {
                        self.viewModel.getCountries()
                    } else {
                        if (self.viewModel.currentStageResponse?.data?.config != nil) {
                            VCheckSDKLocalDatasource.shared.setLivenessMilestonesList(list:
                                (self.viewModel.currentStageResponse?.data?.config!.gestures)!)
                        }
                        self.performSegue(withIdentifier: "StartToLivenessInstructions", sender: nil)
                    }
                }
            }
        }
        
        viewModel.gotCountries = {
            let countryTOArr: [CountryTO] = self.viewModel.countries!.map { (element) -> (CountryTO) in
                let to: CountryTO = CountryTO.init(from: element)
                return to
            }
            
            self.goToCountriesScreen(data: countryTOArr)
        }
        
        viewModel.updateLoadingStatus = {
            if (self.viewModel.isLoading == true) {
                self.activityIndicatorStart()
            } else {
                self.activityIndicatorStop()
            }
        }
        
        viewModel.showAlertClosure = {
            let errText = self.viewModel.error?.errorText ?? "Error: No additional info"
            self.showToast(message: errText, seconds: 2.0)
            self.retryBtn.isHidden = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.retryVerificationStart))
            tapGesture.numberOfTapsRequired = 1
            self.retryBtn.addGestureRecognizer(tapGesture)
        }
        
        viewModel.startVerifFlow()
    }
    
    @objc func retryVerificationStart() {
        self.initVerification()
    }
    
    
    func goToCountriesScreen(data: [CountryTO]) {
        
        self.performSegue(withIdentifier: "StartToCountries", sender: data)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "StartToCountries") {
            print ("Navigating to Countries")
            let vc = segue.destination as! ChooseCountryViewController
            vc.countries = sender as! [CountryTO]
        }
        if (segue.identifier == "StartToCheckDocInfo") {
            print ("Navigating to Check Doc Info")
            let vc = segue.destination as! CheckDocInfoViewController
            vc.docId = sender as? Int
        }
    }
    
    private func activityIndicatorStart() {
        self.spinner.startAnimating()
    }
    
    private func activityIndicatorStop() {
        self.spinner.stopAnimating()
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] accessGranted in
            DispatchQueue.main.async {
                if !accessGranted {
                    self?.alertCameraAccessNeeded()
                } else {
                    self?.initVerification()
                }
            }
        }
    }
    
    private func alertCameraAccessNeeded() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsAppURL) else { return } // This should never happen
        let alert = UIAlertController(
            title: "need_camera_access_title".localized,
            message: "need_camera_access_descr".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "decline".localized, style: .default) { _ in
            self.showToast(message: "declined_camera_access".localized, seconds: 4.0)
        })
        alert.addAction(UIAlertAction(title: "allow".localized, style: .cancel) { _ in
            UIApplication.shared.open(settingsAppURL, options: [:])
        })
        present(alert, animated: true)
    }
}


// MARK: - Child VCs nav extension
extension UIViewController {
    func add(_ child: UIViewController, in container: UIView) {
        addChild(child)
        container.addSubview(child.view)
        child.view.frame = container.bounds
        child.didMove(toParent: self)
    }
    
    func add(_ child: UIViewController) {
        add(child, in: view)
    }
    
    func remove(from view: UIView) {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    func remove() {
        remove(from: view)
    }
}
