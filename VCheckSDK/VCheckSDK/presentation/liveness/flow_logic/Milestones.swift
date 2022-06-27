//
//  Milestones.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 07.05.2022.
//

import Foundation

enum GestureMilestoneType {
    case CheckHeadPositionMilestone
    case OuterLeftHeadPitchMilestone
    case OuterRightHeadPitchMilestone
    case InnerHeadPitchMilestone
    case MouthOpenMilestone
    case MouthClosedMilestone
}

enum ObstacleType {
    case YAW_ANGLE
    case MULTIPLE_FACES_DETECTED
    case NO_OR_PARTIAL_FACE_DETECTED
    
    //Deprecated local checks:
    //case BRIGHTNESS_LEVEL_IS_LOW
    //case MOTIONS_ARE_TOO_SHARP
    //case WRONG_GESTURE
}

class MilestoneConstraints {
    static let YAW_PASS_ANGLE_ABS: Float = 20.0
    static let LEFT_PITCH_PASS_ANGLE: Float = -30.0
    static let RIGHT_PITCH_PASS_ANGLE: Float = 30.0
    static let MOUTH_OPEN_PASS_FACTOR: Float = 0.35  //reduced from 0.55 !
    
    //Deprecated local checks:
    //static let NEXT_FRAME_MAX_PITCH_DIFF: Float = 15.0 //!
    //static let NEXT_FRAME_MAX_YAW_DIFF: Float = 8.0
    //VIDEO_APP_LIVENESS_MAX_ANGLES_DIFF=100,25,100 //add roll?
}


open class GestureMilestone {
    
    let gestureMilestoneType: GestureMilestoneType
    
    init(milestoneType: GestureMilestoneType) {
        self.gestureMilestoneType = milestoneType
    }

    open func isMet(pitchAngle: Float, mouthFactor: Float, yawAbsAngle: Float) -> Bool {
        return false
    }
}

class HeadPitchGestureMilestone : GestureMilestone {
    
    override init(milestoneType: GestureMilestoneType) {
        super.init(milestoneType: milestoneType)
        if (gestureMilestoneType != GestureMilestoneType.InnerHeadPitchMilestone
            && gestureMilestoneType != GestureMilestoneType.OuterLeftHeadPitchMilestone
            && gestureMilestoneType != GestureMilestoneType.OuterRightHeadPitchMilestone
        ) {
            print("Head angle milestone type required but not provided!")
        }
    }

    override func isMet(pitchAngle: Float, mouthFactor: Float, yawAbsAngle: Float) -> Bool {
        switch(gestureMilestoneType) {
            case GestureMilestoneType.InnerHeadPitchMilestone:
            return (pitchAngle < MilestoneConstraints.RIGHT_PITCH_PASS_ANGLE
                    && pitchAngle > MilestoneConstraints.LEFT_PITCH_PASS_ANGLE
                    && yawAbsAngle < MilestoneConstraints.YAW_PASS_ANGLE_ABS)
            case GestureMilestoneType.OuterLeftHeadPitchMilestone:
            return (pitchAngle < MilestoneConstraints.LEFT_PITCH_PASS_ANGLE
                    && yawAbsAngle < MilestoneConstraints.YAW_PASS_ANGLE_ABS)
            case GestureMilestoneType.OuterRightHeadPitchMilestone:
            return (pitchAngle > MilestoneConstraints.RIGHT_PITCH_PASS_ANGLE
                    && yawAbsAngle < MilestoneConstraints.YAW_PASS_ANGLE_ABS)
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

    override func isMet(pitchAngle: Float, mouthFactor: Float, yawAbsAngle: Float) -> Bool {
        switch (gestureMilestoneType) {
            case GestureMilestoneType.MouthOpenMilestone:
                return (mouthFactor >= MilestoneConstraints.MOUTH_OPEN_PASS_FACTOR
                    && yawAbsAngle < MilestoneConstraints.YAW_PASS_ANGLE_ABS)
            case GestureMilestoneType.MouthClosedMilestone:
                return (mouthFactor < MilestoneConstraints.MOUTH_OPEN_PASS_FACTOR
                    && yawAbsAngle < MilestoneConstraints.YAW_PASS_ANGLE_ABS)
            default: return false
        }
    }
}

class CheckOverallHeadPositionMilestone : GestureMilestone {

    private let pitchStableMilestone: HeadPitchGestureMilestone =
        HeadPitchGestureMilestone(milestoneType: GestureMilestoneType.InnerHeadPitchMilestone)
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

    override func isMet(pitchAngle: Float, mouthFactor: Float, yawAbsAngle: Float) -> Bool {
        if (!areMilestoneTypesMet()) {
            return false
        } else {
            return (pitchStableMilestone.isMet(pitchAngle: pitchAngle, mouthFactor: mouthFactor, yawAbsAngle: yawAbsAngle)
                && mouthClosedMilestone.isMet(pitchAngle: pitchAngle, mouthFactor: mouthFactor, yawAbsAngle: yawAbsAngle))
        }
    }
}


class StandardMilestoneFlow {
    
    private let stagesList: [GestureMilestone] = [
        CheckOverallHeadPositionMilestone(milestoneType: GestureMilestoneType.CheckHeadPositionMilestone),
        HeadPitchGestureMilestone(milestoneType: GestureMilestoneType.OuterLeftHeadPitchMilestone),
        HeadPitchGestureMilestone(milestoneType: GestureMilestoneType.OuterRightHeadPitchMilestone),
        MouthGestureMilestone(milestoneType: GestureMilestoneType.MouthOpenMilestone)
    ]

    private var currentStageIdx: Int = 0

    func getCurrentStage() -> GestureMilestone {
        return stagesList[currentStageIdx]
    }
    
    func getUndoneStage() -> GestureMilestone {
        if (currentStageIdx == 0) {
            return stagesList[0]
        } else {
            return stagesList[currentStageIdx - 1]
        }
    }

    func checkCurrentStage(pitchAngle: Float, mouthFactor: Float, yawAngle: Float,
                           onMilestoneResult: (GestureMilestoneType) -> Void,
                           onObstacleMet: (ObstacleType) -> Void) {
        let yawAbsAngle = abs(yawAngle)
        if (currentStageIdx > (stagesList.count)) {
            print("ERROR: Index out of bounds in milestones list!")
            return
        }
        if (yawAbsAngle > MilestoneConstraints.YAW_PASS_ANGLE_ABS) {
            onObstacleMet(ObstacleType.YAW_ANGLE)
        } else {
            if (stagesList[currentStageIdx].isMet(pitchAngle: pitchAngle,
                                                  mouthFactor: mouthFactor, yawAbsAngle: yawAbsAngle)) {
                onMilestoneResult(stagesList[currentStageIdx].gestureMilestoneType)
                currentStageIdx += 1
            }
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
