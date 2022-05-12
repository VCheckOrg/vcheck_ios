//
//  DemoStartViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 25.04.2022.
//

import Foundation
import UIKit
import Alamofire
import Localize_Swift

class DemoStartViewController : UIViewController {
    
    private let viewModel = DemoStartViewModel()
    
    @IBAction func startDemoFlowAction(_ sender: UIButton) {
        initVerification()
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocalDatasource.shared.deleteAllSessionData()
        
        if (self.spinner.isAnimating) {
            self.spinner.stopAnimating()
        }
    }

    
    // MARK: - Networking
    private func initVerification() {
        
        self.activityIndicatorStart()
        
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
        }
        
        viewModel.startVerifFlow()
    }
    
    func goToCountriesScreen(data: [CountryTO]) {
        
        if let defaultSelectedCountry = self.viewModel.countries!.first(where: { $0.code == "ua" }) {
            LocalDatasource.shared.saveSelectedCountryCode(code: defaultSelectedCountry.code)
        } else {
           print("CANNOT SAVE DEFAULT COUNTRY TO KEYCHAIN")
        }
        
        self.performSegue(withIdentifier: "StartToCountries", sender: data) //set the data from the segue to the controller
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "StartToCountries") {
            print ("Navigating to Countries")
            let vc = segue.destination as! ChooseCountryViewController
            vc.countries = sender as! [CountryTO]
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


//--------------------

extension UIViewController {
    func add(_ child: UIViewController, in container: UIView) {
        addChild(child)
        container.addSubview(child.view)
        //child.view.frame = CGRectMake(100, 100, 100, 200);
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
