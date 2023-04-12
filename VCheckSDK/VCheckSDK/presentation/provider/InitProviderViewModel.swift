//
//  InitProviderViewModel.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 12.04.2023.
//

import Foundation

class InitProviderViewModel {
    
    var didReceivedCurrentStage: (() -> ())?
    
    
    func getCurrentStage() {
        
        self.dataService.getCurrentStage(completion: { (data, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
                        
            if (data!.data != nil || data!.errorCode != nil) {
                self.currentStageResponse = data
                self.didReceivedCurrentStage!()
            }
        })
    }
}
