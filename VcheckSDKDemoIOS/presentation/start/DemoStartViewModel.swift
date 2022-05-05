//
//  DemoStartViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation

class DemoStartViewModel {
    
    private var dataService: RemoteDatasource = RemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    
    // MARK: - Properties
    private var timestamp: String?
    
    var countries: [Country]?

    var error: ApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didCreateVerif: (() -> ())?
    var didInitVerif: (() -> ())?
    var didFinishFetch: (() -> ())?
    var gotCountries: (() -> ())?
    
    
    // MARK: - Data calls
    
    func startVerifFlow() {
        self.isLoading = true
        
        self.dataService.requestServerTimestamp(completion: { (timestamp, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.timestamp = timestamp
            self.createVerifAttempt()
        })
    }
    
    func createVerifAttempt() {
        let languagePrefix = Locale.current.languageCode!
        //Locale.preferredLanguages[0] // test! getting default device locale code
        //print(languagePrefix)
        
        if let timestamp = self.timestamp {
            self.dataService.createVerificationRequest(timestamp: timestamp,
                                                       locale: languagePrefix,
                                                       completion: { (data, error) in
                if let error = error {
                    self.error = error
                    self.isLoading = false
                    return
                }

                let urlArr = data!.redirectUrl!.components(separatedBy: "/")
                var urlBody = urlArr.last
                let token = urlBody!.substringBefore("?id")
                
                LocalDatasource.shared.saveAccessToken(accessToken: token)
                
                print("VERIF ::: CREATE ATTEMPT SUCCESS! DATA: \(String(describing: data))")
                
                self.initVerif()
            })
        } else {
            print("Error: server timestamp not set!")
        }
    }
    
    
    func initVerif() {
        
        self.dataService.initVerification(completion: { (data, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            
            print("VERIF ::: INIT SUCCESS! DATA: \(String(describing: data))")
            
            self.getCountries()
        })
    }
    
    
    func getCountries() {
        
        self.dataService.getCountries(completion: { (data, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            
            //print("VERIF ::: GOT COUNTRIES - SUCCESS! DATA: \(String(describing: data))")
            
            if (data!.count > 0) {
                self.isLoading = false
                self.countries = data
                self.gotCountries!()
            }
        })
    }
    
}
