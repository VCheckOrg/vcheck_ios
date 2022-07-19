//
//  Milestones.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 07.05.2022.
//

import Foundation

enum GestureMilestoneType {
    
    case StraightHeadCheckMilestone
    
    case OuterLeftHeadYawMilestone
    case OuterRightHeadYawMilestone
    
    case UpHeadPitchMilestone
    case DownHeadPitchMilestone
    
    case MouthOpenMilestone
}

class StandardMilestoneFlow {
    
    private var stagesList: [GestureMilestoneType] = []

    private var currentStageIdx: Int = 0
    
    func resetStages() {
        currentStageIdx = 0
    }
    
    func setStagesList(list: [String]) {
        let gestures: [GestureMilestoneType] = list.map { (element) -> (GestureMilestoneType) in
            let gm = gmFromServiceValue(strValue: element)
            return gm
        }
        stagesList = gestures
    }
    
    func getCurrentStage() -> GestureMilestoneType? {
        if (currentStageIdx > (stagesList.count - 1)) {
            return nil
        } else {
            return stagesList[currentStageIdx]
        }
    }
    
    func getFirstStage() -> GestureMilestoneType {
        if (stagesList.count > 0) {
            return stagesList[0]
        } else {
            return GestureMilestoneType.StraightHeadCheckMilestone
        }
    }
    
    func areAllStagesPassed() -> Bool {
        return currentStageIdx > (stagesList.count - 1)
    }
    
    func incrementCurrentStage() {
         currentStageIdx += 1
     }
    
    func gmFromServiceValue(strValue: String) -> GestureMilestoneType {
        switch(strValue) {
            case "left": return GestureMilestoneType.OuterLeftHeadYawMilestone
            case "right": return GestureMilestoneType.OuterRightHeadYawMilestone
            case "up": return GestureMilestoneType.UpHeadPitchMilestone
            case "down": return GestureMilestoneType.DownHeadPitchMilestone
            case "mouth": return GestureMilestoneType.MouthOpenMilestone
            default: return GestureMilestoneType.StraightHeadCheckMilestone
        }
    }
    
    func getGestureRequestFromCurrentStage() -> String {
        if (currentStageIdx > (stagesList.count - 1)) {
            return "straight"
        } else {
                switch(stagesList[currentStageIdx]) {
                case GestureMilestoneType.OuterLeftHeadYawMilestone: return "left"
                case GestureMilestoneType.OuterRightHeadYawMilestone: return "right"
                case GestureMilestoneType.UpHeadPitchMilestone: return "up"
                case GestureMilestoneType.DownHeadPitchMilestone: return "down"
                case GestureMilestoneType.MouthOpenMilestone: return "mouth"
                default: return "straight"
            }
        }
    }
    
}
