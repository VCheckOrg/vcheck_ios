//
//  DemoStartViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 25.04.2022.
//

import Foundation
import UIKit
import Alamofire

class DemoStartViewController : UIViewController {
    
    private let viewModel = DemoStartViewModel()
    
    @IBAction func startDemoFlowAction(_ sender: UIButton) {
        print("BTN CLICKED")
        initVerification()
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.spinner.isAnimating) {
            self.spinner.stopAnimating()
        }
    }

    
    // MARK: - Networking
    private func initVerification() {
        
        self.activityIndicatorStart()
        
        viewModel.startVerifFlow()
        
        viewModel.gotCountries = {
            self.goToCountriesScreen(data: self.viewModel.countries)
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
        }
    }
    
    //using a segue
    func goToCountriesScreen(data: Codable) {
      self.performSegue(withIdentifier: "StartToCountries", sender: data)//set the data from the segue to the controller
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "StartToCountries") {
            print ("Navigating to Countries")
            //let vc = segue.destination as! ChooseCountryViewController
            //vc.verificationId = "Your Data" // TODO set countries data
        }
    }
    
    // MARK: - UI Setup
    private func activityIndicatorStart() {
        self.spinner.startAnimating()
    }
    
    private func activityIndicatorStop() {
        self.spinner.stopAnimating()
    }
}
