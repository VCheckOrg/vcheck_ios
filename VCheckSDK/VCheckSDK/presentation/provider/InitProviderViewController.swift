//
//  InitProviderViewController.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 12.04.2023.
//

import Foundation
import UIKit

class InitProviderViewController : UIViewController {
    
    
    
    override func viewDidLoad() {
        
        
        viewModel.didReceivedCurrentStage = {
            if (self.viewModel.currentStageResponse?.errorCode != nil
                && self.viewModel.currentStageResponse?.errorCode ==
                    StageObstacleErrorType.USER_INTERACTED_COMPLETED.toTypeIdx()) {
                //TODO: change route
                //self.performSegue(withIdentifier: "StartToLivenessInstructions", sender: nil)
            } else {
                if (self.viewModel.currentStageResponse?.data != nil) {
                    if (self.viewModel.currentStageResponse?.data?.uploadedDocId != nil) {
                        //TODO: change route
                        //self.performSegue(withIdentifier: "StartToCheckDocInfo", sender: self.viewModel.currentStageResponse?.data?.uploadedDocId)
                        return
                    } else if (self.viewModel.currentStageResponse?.data?.primaryDocId != nil) {
                        //TODO: change route
                        //self.performSegue(withIdentifier: "StartToCheckDocInfo", sender: self.viewModel.currentStageResponse?.data?.primaryDocId)
                        return
                    } else if (self.viewModel.currentStageResponse!.data!.type! == StageType.DOCUMENT_UPLOAD.toTypeIdx()) {
                        self.viewModel.getCountries()
                    } else {
                        if (self.viewModel.currentStageResponse?.data?.config != nil) {
                            VCheckSDKLocalDatasource.shared.setLivenessMilestonesList(list:
                                (self.viewModel.currentStageResponse?.data?.config!.gestures)!)
                        }
                        //TODO: change route
                        //self.performSegue(withIdentifier: "StartToLivenessInstructions", sender: nil)
                    }
                }
            }
        }
    }
}
