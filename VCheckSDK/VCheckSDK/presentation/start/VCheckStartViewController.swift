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
        
        viewModel.gotProviders = {
            self.processProvidersData(response: self.viewModel.providersResponse!)
        }
        
        viewModel.verificationIsAlreadyCompleted = {
            self.performSegue(withIdentifier: "StartToVerifAlreadyCompleted", sender: nil)
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
    
    private func processProvidersData(response: ProvidersResponse) {
        if (response.data != nil) {
            let providersList = response.data!
            VCheckSDK.shared.setAllAvailableProviders(providers: providersList)

            if (!(providersList.isEmpty) && providersList.count == 1) { // 1 provider
                if (providersList[0].countries == nil) {
                    VCheckSDK.shared.setProviderLogicCase(providerLC: ProviderLogicCase.ONE_PROVIDER_NO_COUNTRIES)
                    VCheckSDK.shared.setSelectedProvider(provider: providersList[0])
                    self.navigateToInitProvider()
                } else if (providersList[0].countries!.isEmpty) {
                    VCheckSDK.shared.setProviderLogicCase(providerLC: ProviderLogicCase.ONE_PROVIDER_NO_COUNTRIES)
                    VCheckSDK.shared.setSelectedProvider(provider: providersList[0])
                    self.navigateToInitProvider()
                } else if (providersList[0].countries!.count == 1) {
                    VCheckSDK.shared.setProviderLogicCase(providerLC: ProviderLogicCase.ONE_PROVIDER_ONE_COUNTRY)
                    VCheckSDK.shared.setSelectedProvider(provider: providersList[0])
                    VCheckSDK.shared.setOptSelectedCountryCode(code: providersList[0].countries![0])
                    self.navigateToInitProvider()
                } else {
                    VCheckSDK.shared.setProviderLogicCase(providerLC: ProviderLogicCase.ONE_PROVIDER_MULTIPLE_COUNTRIES)
                    VCheckSDK.shared.setSelectedProvider(provider: providersList[0])
                    self.navigateToCountrySelection(countryCodes: providersList[0].countries!)
                }
            } else if (!(providersList.isEmpty)) { // more than 1 provider
                if providersList.contains(where: { $0.countries != nil && !$0.countries!.isEmpty }) {
                    VCheckSDK.shared.setProviderLogicCase(providerLC: ProviderLogicCase.MULTIPLE_PROVIDERS_PRESENT_COUNTRIES)
                    var joinedCountriesSet = Set<String>()
                    for provider in providersList {
                        if let countries = provider.countries, !countries.isEmpty {
                            joinedCountriesSet.formUnion(countries)
                        }
                    }
                    self.navigateToCountrySelection(countryCodes: Array(joinedCountriesSet))
                } else {
                    VCheckSDK.shared.setProviderLogicCase(providerLC: ProviderLogicCase.MULTIPLE_PROVIDERS_NO_COUNTRIES)
                    self.navigateToProviderSelection(providersList: providersList)
                }
            } else {
                showToast(message: "Could not retrieve one or more valid providers", seconds: 5.0)
            }
        }
    }
    
    private func navigateToInitProvider() {
        self.performSegue(withIdentifier: "StartToInitProvider", sender: nil)
    }

    private func navigateToProviderSelection(providersList: [Provider]) {
        self.performSegue(withIdentifier: "StartToChooseProvider", sender: providersList)
    }

    private func navigateToCountrySelection(countryCodes: [String]) {
        self.performSegue(withIdentifier: "StartToCountries", sender: countryCodes)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "StartToCountries") {
            let vc = segue.destination as! ChooseCountryViewController
            let countryList = (sender as! [String]).map { (code) -> (CountryTO) in
                return CountryTO.init(from: code)
            }
            vc.initialCountries = countryList
        }
        if (segue.identifier == "StartToChooseProvider") {
            let vc = segue.destination as! ChooseProviderViewController
            vc.providersList = sender as? [Provider]
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
