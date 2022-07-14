//
//  Milestones.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 07.05.2022.
//

import Foundation

enum GestureMilestoneType {
    case CheckHeadPositionMilestone
    case InnerHeadPitchMilestone //?
    
    case OuterLeftHeadYawMilestone
    case OuterRightHeadYawMilestone
    
    case UpHeadPitchMilestone
    case DownHeadPitchMilestone
    
    case MouthOpenMilestone
    case MouthClosedMilestone
}

enum ObstacleType {
    case PITCH_ANGLE
    case MULTIPLE_FACES_DETECTED
    case NO_OR_PARTIAL_FACE_DETECTED
}

class MilestoneConstraints {
    static let PITCH_STRAIGHT_CHECK_ANGLE_ABS: Float = 20.0
    
    static let PITCH_UP_PASS_ANGLE: Float = 20.0
    static let PITCH_DOWN_PASS_ANGLE: Float = -20.0
    
    static let LEFT_YAW_PASS_ANGLE: Float = -30.0
    static let RIGHT_YAW_PASS_ANGLE: Float = 30.0
    static let MOUTH_OPEN_PASS_FACTOR: Float = 0.35  //reduced from 0.55 !
}


class GestureMilestone {
    
    let gestureMilestoneType: GestureMilestoneType
    
    init(milestoneType: GestureMilestoneType) {
        self.gestureMilestoneType = milestoneType
    }

    open func isMet(yawAngle: Float, mouthFactor: Float, pitchAngle: Float) -> Bool {
        return false
    }
}

class HeadPitchGestureMilestone : GestureMilestone {
    
    override init(milestoneType: GestureMilestoneType) {
        super.init(milestoneType: milestoneType)
        if (gestureMilestoneType != GestureMilestoneType.UpHeadPitchMilestone
            && gestureMilestoneType != GestureMilestoneType.DownHeadPitchMilestone) {
            print("Head angle milestone type required but not provided!")
        }
    }
    
    
    override func isMet(yawAngle: Float, mouthFactor: Float, pitchAngle: Float) -> Bool {
        switch(gestureMilestoneType) {
            case GestureMilestoneType.UpHeadPitchMilestone:
                return (pitchAngle > MilestoneConstraints.PITCH_UP_PASS_ANGLE)
            case GestureMilestoneType.DownHeadPitchMilestone:
                return (pitchAngle < MilestoneConstraints.PITCH_DOWN_PASS_ANGLE)
            default: return false
        }
    }
}

class HeadYawGestureMilestone : GestureMilestone {
    
    override init(milestoneType: GestureMilestoneType) {
        super.init(milestoneType: milestoneType)
        if (gestureMilestoneType != GestureMilestoneType.OuterLeftHeadYawMilestone
            && gestureMilestoneType != GestureMilestoneType.OuterRightHeadYawMilestone) {
            print("Head angle milestone type required but not provided!")
        }
    }

    override func isMet(yawAngle: Float, mouthFactor: Float, pitchAngle: Float) -> Bool {
        switch(gestureMilestoneType) {
            case GestureMilestoneType.OuterLeftHeadYawMilestone:
            return (yawAngle < MilestoneConstraints.LEFT_YAW_PASS_ANGLE
                    && abs(pitchAngle) < MilestoneConstraints.PITCH_STRAIGHT_CHECK_ANGLE_ABS)
            case GestureMilestoneType.OuterRightHeadYawMilestone:
            return (yawAngle > MilestoneConstraints.RIGHT_YAW_PASS_ANGLE
                    && abs(pitchAngle) < MilestoneConstraints.PITCH_STRAIGHT_CHECK_ANGLE_ABS)
            default: return false
        }
    }
}

class MouthGestureMilestone : GestureMilestone {

    override init (milestoneType: GestureMilestoneType) {
        super.init(milestoneType: milestoneType)
        if (gestureMilestoneType != GestureMilestoneType.MouthClosedMilestone
            && gestureMilestoneType != GestureMilestoneType.MouthOpenMilestone) {
            print("Mouth milestone type required but not provided!")
        }
    }

    override func isMet(yawAngle: Float, mouthFactor: Float, pitchAngle: Float) -> Bool {
        switch (gestureMilestoneType) {
            case GestureMilestoneType.MouthOpenMilestone:
                return (mouthFactor >= MilestoneConstraints.MOUTH_OPEN_PASS_FACTOR
                    && abs(pitchAngle) < MilestoneConstraints.PITCH_STRAIGHT_CHECK_ANGLE_ABS)
            case GestureMilestoneType.MouthClosedMilestone:
                return (mouthFactor < MilestoneConstraints.MOUTH_OPEN_PASS_FACTOR
                    && abs(pitchAngle) < MilestoneConstraints.PITCH_STRAIGHT_CHECK_ANGLE_ABS)
            default: return false
        }
    }
}

class CheckOverallHeadPositionMilestone : GestureMilestone {

    private let pitchStableMilestone: HeadYawGestureMilestone =
        HeadYawGestureMilestone(milestoneType: GestureMilestoneType.InnerHeadPitchMilestone)
    private let mouthClosedMilestone: MouthGestureMilestone =
        MouthGestureMilestone(milestoneType: GestureMilestoneType.MouthClosedMilestone)

    override init (milestoneType: GestureMilestoneType) {
        super.init(milestoneType: milestoneType)
        if (!areMilestoneTypesMet()) {
            print("CheckOverallHeadPosition: wrong milestone type(s)!")
        }
    }

    private func areMilestoneTypesMet() -> Bool {
        return (pitchStableMilestone.gestureMilestoneType == GestureMilestoneType.InnerHeadPitchMilestone
            && mouthClosedMilestone.gestureMilestoneType == GestureMilestoneType.MouthClosedMilestone)
    }

    override func isMet(yawAngle: Float, mouthFactor: Float, pitchAngle: Float) -> Bool {
        if (!areMilestoneTypesMet()) {
            return false
        } else {
            return (pitchStableMilestone.isMet(yawAngle: yawAngle, mouthFactor: mouthFactor, pitchAngle: pitchAngle)
                && mouthClosedMilestone.isMet(yawAngle: yawAngle, mouthFactor: mouthFactor, pitchAngle: pitchAngle))
        }
    }
}


class StandardMilestoneFlow {
    
    private var stagesList: [GestureMilestone] = [
        CheckOverallHeadPositionMilestone(milestoneType: GestureMilestoneType.CheckHeadPositionMilestone)
    ]

    private var currentStageIdx: Int = 0
    
    func resetStages() {
        currentStageIdx = 0
    }
    
    func setStagesList(list: [String]) {
        let gestures: [GestureMilestone] = list.map { (element) -> (GestureMilestone) in
            let gm = gmFromServiceValue(strValue: element)
            return gm
        }
        stagesList.append(contentsOf: gestures)
    }

    func getCurrentStage() -> GestureMilestone {
        if (currentStageIdx > (stagesList.count - 1)) {
            return stagesList[0]
        } else {
            return stagesList[currentStageIdx]
        }
    }

    func checkCurrentStage(yawAngle: Float, mouthFactor: Float, pitchAngle: Float,
                           onMilestoneResult: (GestureMilestoneType) -> Void,
                           onObstacleMet: (ObstacleType) -> Void,
                           onAllStagesPassed: () -> Void) {
        if (currentStageIdx > (stagesList.count - 1)) {
            onAllStagesPassed()
            return
        }
        if (getCurrentStage().isMet(yawAngle: yawAngle,
                              mouthFactor: mouthFactor, pitchAngle: pitchAngle)) {
            onMilestoneResult(getCurrentStage().gestureMilestoneType)
            currentStageIdx += 1
            return
        }
    }
    
    func gmFromServiceValue(strValue: String) -> GestureMilestone {
        switch(strValue) {
            case "left": return HeadYawGestureMilestone(milestoneType: GestureMilestoneType.OuterLeftHeadYawMilestone)
            case "right": return HeadYawGestureMilestone(milestoneType: GestureMilestoneType.OuterRightHeadYawMilestone)
            case "up": return HeadPitchGestureMilestone(milestoneType: GestureMilestoneType.UpHeadPitchMilestone)
            case "down": return HeadPitchGestureMilestone(milestoneType: GestureMilestoneType.DownHeadPitchMilestone)
            case "mouth": return MouthGestureMilestone(milestoneType: GestureMilestoneType.MouthOpenMilestone)
            default: return CheckOverallHeadPositionMilestone(milestoneType: GestureMilestoneType.CheckHeadPositionMilestone)
        }
    }
    
}


class MajorObstacleFrameCounterHolder {
    
    private var wrongGestureFrameCounter: Int = 0
    
    func resetFrameCountersOnSessionPrematureEnd() {
        self.wrongGestureFrameCounter = 0
    }
    
    func resetFrameCountersOnStageSuccess() {
        self.wrongGestureFrameCounter = -15
    }
    
    func incrementWrongGestureFrameCounter() {
        self.wrongGestureFrameCounter += 1
        print("WRONG GESTURE - FRAME COUNT: \(self.wrongGestureFrameCounter)")
    }
    
    func getWrongGestureFrameCounter() -> Int {
        return self.wrongGestureFrameCounter
    }
}



//        print("--- STAGES: \(stagesList)")
//        print("--- CURRENT STAGE: \(getCurrentStage().gestureMilestoneType)")
//        print("--- PITCH: \(pitchAngle) | ABS PITCH : \(abs(pitchAngle))")
        //print("--- NEXT STAGE: \(getNextStage().gestureMilestoneType)")

//        if (!(getCurrentStage() is HeadPitchGestureMilestone)
//            && abs(pitchAngle) > MilestoneConstraints.PITCH_STRAIGHT_CHECK_ANGLE_ABS) {
//            onObstacleMet(ObstacleType.PITCH_ANGLE)
//            print("======== OBSTACLE PITCH MET!!!")
//            return
//        } else {

//Hardcoded (deprecated) list:
//        CheckOverallHeadPositionMilestone(milestoneType: GestureMilestoneType.CheckHeadPositionMilestone),
//        HeadYawGestureMilestone(milestoneType: GestureMilestoneType.OuterLeftHeadYawMilestone),
//        HeadYawGestureMilestone(milestoneType: GestureMilestoneType.OuterRightHeadYawMilestone),
//        MouthGestureMilestone(milestoneType: GestureMilestoneType.MouthOpenMilestone)


//    func getNextStage() -> GestureMilestone {
//        if (stagesList.count == 1) {
//            return stagesList[0]
//        } else if (stagesList.count <= currentStageIdx - 1) {
//            return stagesList[stagesList.count - 1]
//        } else {
//            return stagesList[currentStageIdx + 1]
//        }
//    }

//    func getUndoneStage() -> GestureMilestone {
//        if (currentStageIdx == 0) {
//            return stagesList[0]
//        } else {
//            return stagesList[currentStageIdx - 1]
//        }
//    }
