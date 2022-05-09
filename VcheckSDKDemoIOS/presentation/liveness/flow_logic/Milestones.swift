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
    case WRONG_GESTURE
    case MULTIPLE_FACES_DETECTED
    case NO_STRAIGHT_FACE_DETECTED
    case BRIGHTNESS_LEVEL_IS_LOW
    case MOTIONS_ARE_TOO_SHARP
}

class MilestoneConstraints {
    static let YAW_PASS_ANGLE_ABS: Float = 20.0
    static let LEFT_PITCH_PASS_ANGLE: Float = -30.0
    static let RIGHT_PITCH_PASS_ANGLE: Float = 30.0
    static let MOUTH_OPEN_PASS_FACTOR: Float = 0.39  //reduced from 0.55 !
    
    static let NEXT_FRAME_MAX_PITCH_DIFF: Float = 40.0
    static let NEXT_FRAME_MAX_YAW_DIFF: Float = 25.0
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
    
    private var recentFramePitchAngle: Float = 0.0
    private var recentFrameYawAngle: Float = 0.0
    

    func getCurrentStage() -> GestureMilestone {
        return stagesList[currentStageIdx]
    }
    
    func getUndoneStage() -> GestureMilestone {
        return stagesList[currentStageIdx - 1]
    }

    func checkCurrentStage(pitchAngle: Float, mouthFactor: Float, yawAngle: Float,
                           onMilestoneResult: (GestureMilestoneType) -> Void,
                           onObstacleMet: (ObstacleType) -> Void) {
        let yawAbsAngle = abs(yawAngle)
        if (currentStageIdx > (stagesList.count)) {
            print("ERROR: Index out of bounds in milestones list!")
            return
        }
        if (hasExtensivePitchDiff(pitchAngle: pitchAngle) || hasExtensiveYawDiff(yawAngle: yawAngle)) {
            onObstacleMet(ObstacleType.MOTIONS_ARE_TOO_SHARP)
        } else if (yawAbsAngle > MilestoneConstraints.YAW_PASS_ANGLE_ABS) {
            onObstacleMet(ObstacleType.YAW_ANGLE)
        } else {
            if (stagesList[currentStageIdx].isMet(pitchAngle: pitchAngle,
                                                  mouthFactor: mouthFactor, yawAbsAngle: yawAbsAngle)) {
                onMilestoneResult(stagesList[currentStageIdx].gestureMilestoneType)
                currentStageIdx += 1
            } else {
                stagesList.enumerated().forEach { (idx, stage) in
                    if (idx != 0 && idx != currentStageIdx && stage.isMet(pitchAngle: pitchAngle,
                                       mouthFactor: mouthFactor, yawAbsAngle: yawAbsAngle)) {
                        onObstacleMet(ObstacleType.WRONG_GESTURE)
                    }
                }
            }
        }
        recentFramePitchAngle = pitchAngle
        recentFrameYawAngle = yawAngle
    }
    
    func hasExtensivePitchDiff(pitchAngle: Float) -> Bool {
        if ((pitchAngle < 0 && recentFramePitchAngle < 0) || (pitchAngle > 0 && recentFramePitchAngle > 0)) {
            return abs(abs(pitchAngle) - abs(recentFramePitchAngle)) > MilestoneConstraints.NEXT_FRAME_MAX_PITCH_DIFF
        } else {
            return (abs(pitchAngle) + abs(recentFramePitchAngle)) > MilestoneConstraints.NEXT_FRAME_MAX_PITCH_DIFF
        }
    }
    
    func hasExtensiveYawDiff(yawAngle: Float) -> Bool {
        if ((yawAngle < 0 && recentFrameYawAngle < 0) || (yawAngle > 0 && recentFrameYawAngle > 0)) {
            return abs(abs(yawAngle) - abs(recentFrameYawAngle)) > MilestoneConstraints.NEXT_FRAME_MAX_PITCH_DIFF
        } else {
            return (abs(yawAngle) + abs(recentFrameYawAngle)) > MilestoneConstraints.NEXT_FRAME_MAX_YAW_DIFF
        }
    }
}


class MajorObstacleFrameCounterHolder {
    
    private var multiFaceFrameCounter: Int = 0
    private var noFaceFrameCounter: Int = 0
    private var wrongGestureFrameCounter: Int = 0
    private var noBrightnessFrameCounter: Int = 0
    
    func resetFrameCountersOnSessionPrematureEnd() {
        self.multiFaceFrameCounter = 0
        self.noFaceFrameCounter = 0
        self.wrongGestureFrameCounter = 0
        self.noBrightnessFrameCounter = 0
    }
    
    func resetFrameCountersOnStageSuccess() {
        self.multiFaceFrameCounter = -15
        self.noFaceFrameCounter = -15
        self.wrongGestureFrameCounter = -15
        self.noBrightnessFrameCounter = -15
    }
    
    func incrementMultiFaceFrameCounter() {
        self.multiFaceFrameCounter += 1
        print("MULTIPLE FACES DETECTED - FRAME COUNT: \(self.multiFaceFrameCounter)")
    }
    
    func incrementNoFaceFrameCounter() {
        self.noFaceFrameCounter += 1
        print("NO STRAIGHT FACE DETECTED - FRAME COUNT: \(self.noFaceFrameCounter)")
    }
    
    func incrementWrongGestureFrameCounter() {
        self.wrongGestureFrameCounter += 1
        print("WRONG GESTURE - FRAME COUNT: \(self.multiFaceFrameCounter)")
    }
    
    func incrementNoBrightnessFrameCounter() {
        self.noBrightnessFrameCounter += 1
        print("NOT ENOUGH BRIGHTNESS DETECTED - FRAME COUNT: \(self.multiFaceFrameCounter)")
    }
    
    func getMultiFaceFrameCounter() -> Int {
        return self.multiFaceFrameCounter
    }
    
    func getNoFaceFrameCounter() -> Int {
        return self.noFaceFrameCounter
    }
    
    func getWrongGestureFrameCounter() -> Int {
        return self.wrongGestureFrameCounter
    }
    
    func getNoBrightnessFrameCounter() -> Int {
        return self.noBrightnessFrameCounter
    }
}
