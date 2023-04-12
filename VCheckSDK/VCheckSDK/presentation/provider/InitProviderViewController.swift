//
//  InitProviderViewController.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 12.04.2023.
//

import Foundation
import UIKit

class InitProviderViewController : UIViewController {
    
    private let viewModel = InitProviderViewModel()
    
    
    override func viewDidLoad() {
        
        viewModel.didReceivedCurrentStage = {
            self.processStageData(response: self.viewModel.currentStageResponse!)
        }
        
        self.viewModel.initProvider()
    }
    
    
    private func processStageData(response: StageResponse) {
        if (response.errorCode != nil
            && response.errorCode == StageObstacleErrorType.USER_INTERACTED_COMPLETED.toTypeIdx()) {
            self.performSegue(withIdentifier: "InitProviderToLivenessInstructions", sender: nil) //?
        } else {
            if (response.data != nil) {
                let stageData = response.data!
                if (stageData.type != StageType.LIVENESS_CHALLENGE.toTypeIdx()) {
                    checkDocStageDataForNavigation(stageData: stageData)
                } else {
                    if (stageData.config != nil) {
                        VCheckSDKLocalDatasource.shared.setLivenessMilestonesList(list: (stageData.config?.gestures)!)
                    }
                    self.performSegue(withIdentifier: "InitProviderToLivenessInstructions", sender: nil)
                }
            }
        }
    }

    private func checkDocStageDataForNavigation(stageData: StageResponseData) {
        var docId: Int? = nil
        if (stageData.uploadedDocId != nil) {
            docId = stageData.uploadedDocId
            self.performSegue(withIdentifier: "InitProviderToCheckDocInfo", sender: docId)
        } else if (stageData.primaryDocId != nil) {
            docId = stageData.primaryDocId
            self.performSegue(withIdentifier: "InitProviderToCheckDocInfo", sender: docId)
        } else {
            docId = nil
            self.performSegue(withIdentifier: "InitProviderToChooseDocType", sender: nil)
        }
    }

}
