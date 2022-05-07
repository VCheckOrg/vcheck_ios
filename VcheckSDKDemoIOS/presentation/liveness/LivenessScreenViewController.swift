import AVFoundation
import CoreMedia
import CoreMotion
import SceneKit
import UIKit
import ARCore
import Lottie

/// Demonstrates how to use ARCore Augmented Faces with SceneKit.
public final class LivenessScreenViewController: UIViewController {
    
    
  @IBOutlet weak var roundedView: RoundedView!
    
    
    
  //@IBOutlet weak var testLivenessRealtimeInfo: UITextView!
    
  // MARK: - Member Variables
  private var needToShowFatalError = false
  private var alertWindowTitle = "Nothing"
  private var alertMessage = "Nothing"
  private var viewDidAppearReached = false

  // MARK: - Camera / Scene properties
  private var captureDevice: AVCaptureDevice?
  private var captureSession: AVCaptureSession?
  private var videoFieldOfView = Float(0)
  private lazy var cameraImageLayer = CALayer()
  private lazy var sceneView = SCNView()
  private lazy var sceneCamera = SCNCamera()
  private lazy var motionManager = CMMotionManager()

  // MARK: - Face properties
  private var faceSession: GARAugmentedFaceSession?
    
  // MARK: - Anim properties
  var faceAnimationView: AnimationView = AnimationView(name: "right")
  //var arrowAnimationView: AnimationView = AnimationView(name: "")
    
  // MARK: - Implementation methods
  override public func viewDidLoad() {
    super.viewDidLoad()

    if !setupScene() {
      return
    }
    if !setupCamera() {
      return
    }
    if !setupMotion() {
      return
    }

    do {
      faceSession = try GARAugmentedFaceSession(fieldOfView: videoFieldOfView)
        
    } catch {
      alertWindowTitle = "A fatal error occurred."
      alertMessage = "Failed to create session. Error description: \(error)"
      popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
    }
  }

  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    viewDidAppearReached = true
      
    if needToShowFatalError {
      popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
    }
      
    setupFaceAnimation()
  }

  /// Create the scene view from a scene and supporting nodes, and add to the view.
  /// The scene is loaded from 'fox_face.scn' which was created from 'canonical_face_mesh.fbx', the
  /// canonical face mesh asset.
  /// https://developers.google.com/ar/develop/developer-guides/creating-assets-for-augmented-faces
  /// - Returns: true when the function has fatal error; false when not.
  private func setupScene() -> Bool {
      
    guard let scene = SCNScene(named: "Face.scnassets/liveness_scene.scn")
    else {
      alertWindowTitle = "A fatal error occurred."
      alertMessage = "Failed to load face scene!"
      popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
      return false
    }

    let cameraNode = SCNNode()
    cameraNode.camera = sceneCamera
    scene.rootNode.addChildNode(cameraNode)

    sceneView.scene = scene
    sceneView.frame = view.bounds
    sceneView.delegate = self
    sceneView.rendersContinuously = true
    sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    sceneView.backgroundColor = .clear
    // Flip 'x' to mirror content to mimic 'selfie' mode
    sceneView.layer.transform = CATransform3DMakeScale(-1, 1, 1)
    view.addSubview(sceneView)

    return true
  }

  /// Setup a camera capture session from the front camera to receive captures.
  /// - Returns: true when the function has fatal error; false when not.
  private func setupCamera() -> Bool {
    guard
      let device =
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    else {
      alertWindowTitle = "A fatal error occurred."
      alertMessage = "Failed to get device from AVCaptureDevice."
      popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
      return false
    }

    guard
      let input = try? AVCaptureDeviceInput(device: device)
    else {
      alertWindowTitle = "A fatal error occurred."
      alertMessage = "Failed to get device input from AVCaptureDeviceInput."
      popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
      return false
    }

    let output = AVCaptureVideoDataOutput()
    output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))

    let session = AVCaptureSession()
    session.sessionPreset = .high
    session.addInput(input)
    session.addOutput(output)
    captureSession = session
    captureDevice = device

    videoFieldOfView = captureDevice?.activeFormat.videoFieldOfView ?? 0

    cameraImageLayer.contentsGravity = .center
    cameraImageLayer.frame = self.view.bounds
    view.layer.insertSublayer(cameraImageLayer, at: 0)

    // Start capturing images from the capture session once permission is granted.
    getVideoPermission(permissionHandler: { granted in
      guard granted else {
        NSLog("Permission not granted to use camera.")
        self.alertWindowTitle = "Alert"
        self.alertMessage = "Permission not granted to use camera."
        self.popupAlertWindowOnError(
          alertWindowTitle: self.alertWindowTitle, alertMessage: self.alertMessage)
        return
      }
      self.captureSession?.startRunning()
    })

    return true
  }

  /// Start receiving motion updates to determine device orientation for use in the face session.
  /// - Returns: true when the function has fatal error; false when not.
  private func setupMotion() -> Bool {
    guard motionManager.isDeviceMotionAvailable else {
      alertWindowTitle = "Alert"
      alertMessage = "Device does not have motion sensors."
      popupAlertWindowOnError(alertWindowTitle: alertWindowTitle, alertMessage: alertMessage)
      return false
    }
    motionManager.deviceMotionUpdateInterval = 0.01
    motionManager.startDeviceMotionUpdates()

    return true
  }

  /// Get permission to use device camera.
  ///
  /// - Parameters:
  ///   - permissionHandler: The closure to call with whether permission was granted when
  ///     permission is determined.
  private func getVideoPermission(permissionHandler: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      permissionHandler(true)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video, completionHandler: permissionHandler)
    default:
      permissionHandler(false)
    }
  }

  private func popupAlertWindowOnError(alertWindowTitle: String, alertMessage: String) {
    if !self.viewDidAppearReached {
      self.needToShowFatalError = true
      // Then the process will proceed to viewDidAppear, which will popup an alert window when needToShowFatalError is true.
      return
    }
    // viewDidAppearReached is true, so we can pop up window now.
    let alertController = UIAlertController(
      title: alertWindowTitle, message: alertMessage, preferredStyle: .alert)
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("OK", comment: "Default action"), style: .default,
        handler: { _ in
          self.needToShowFatalError = false
        }))
    self.present(alertController, animated: true, completion: nil)
  }

}

// MARK: - Camera delegate

extension LivenessScreenViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

  public func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let imgBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
      let deviceMotion = motionManager.deviceMotion
    else {
      NSLog("In captureOutput, imgBuffer or deviceMotion is nil.")
      return
    }

    let frameTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))

    // Use the device's gravity vector to determine which direction is up for a face. This is the
    // positive counter-clockwise rotation of the device relative to landscape left orientation.
    let rotation = 2 * .pi - atan2(deviceMotion.gravity.x, deviceMotion.gravity.y) + .pi / 2
    let rotationDegrees = (UInt)(rotation * 180 / .pi) % 360
      
    //print("DEVICE(?) ROTATION DEGREES: \(rotationDegrees)")

    faceSession?.update(with: imgBuffer, timestamp: frameTime, recognitionRotation: rotationDegrees)
  }

}

// MARK: - Scene Renderer delegate
extension LivenessScreenViewController: SCNSceneRendererDelegate {

  public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    guard let frame = faceSession?.currentFrame else {
      NSLog("In renderer, currentFrame is nil.")
      return
    }
      
    updateFaceAnimation()

    processFaceFrame(frame: frame)
  }
}

// MARK: - Frame processing upper-level ext.

extension LivenessScreenViewController {
    
    func processFaceFrame(frame: GARAugmentedFaceFrame) {
        if let face = frame.face {
            
           processFaceCalcForFrame(face: face)
        
            // Update the camera image layer's transform to the display transform for this frame.
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            cameraImageLayer.contents = frame.capturedImage as CVPixelBuffer
            cameraImageLayer.setAffineTransform(
              frame.displayTransform(
                forViewportSize: cameraImageLayer.bounds.size,
                presentationOrientation: .portrait,
                mirrored: true)
            )
            CATransaction.commit()

            // Only show AR content when a face is detected.
            sceneView.scene?.rootNode.isHidden = frame.face == nil
        }
    }
    
    func processFaceCalcForFrame(face: GARAugmentedFace) {
          //SIMD3<Float>(0.044765785, 0.031215014, 0.037100613)
          
          let h1 = MouthCalcCoordsHolder.init(x1: face.mesh.vertices[37].x, x2: face.mesh.vertices[83].x, y1: face.mesh.vertices[37].y,
                                              y2: face.mesh.vertices[83].y, z1: face.mesh.vertices[37].z, z2: face.mesh.vertices[83].z)
          let h2 = MouthCalcCoordsHolder.init(x1: face.mesh.vertices[267].x, x2: face.mesh.vertices[314].x, y1: face.mesh.vertices[267].y,
                                              y2: face.mesh.vertices[314].y, z1: face.mesh.vertices[267].z, z2: face.mesh.vertices[314].z)
          let h3 = MouthCalcCoordsHolder.init(x1: face.mesh.vertices[61].x, x2: face.mesh.vertices[281].x, y1: face.mesh.vertices[61].y,
                                              y2: face.mesh.vertices[281].y, z1: face.mesh.vertices[61].z, z2: face.mesh.vertices[281].z)
          
          let mouthAngle = landmarksToMouthAspectRatio(h1: h1, h2: h2, h3: h3)
          let faceAnglesHolder = face.centerTransform.eulerAngles
          
          let mouthOpen: Bool = mouthAngle > 0.39
          let turnedLeft: Bool = faceAnglesHolder.pitch < -30
          let turnedRight: Bool = faceAnglesHolder.pitch > 30
          
        print("MOUTH: \(mouthAngle)\nPITCH: \(faceAnglesHolder.pitch)\nYAW: \(faceAnglesHolder.yaw)"
              + "\n\nMOUTH OPEN: \(mouthOpen)\n\nTURNED LEFT: \(turnedLeft)\n\nTURNED RIGHT: \(turnedRight)")
        
        //TODO: make simple logs instead
  //        DispatchQueue.main.async {
  //            self.testLivenessRealtimeInfo.text = "MOUTH: \(mouthAngle)\nPITCH: \(faceAnglesHolder.pitch)\nYAW: \(faceAnglesHolder.yaw)"
  //             + "\n\nMOUTH OPEN: \(mouthOpen)\n\nTURNED LEFT: \(turnedLeft)\n\nTURNED RIGHT: \(turnedRight)"
  //        }
      }
      
      func landmarksToMouthAspectRatio(h1: MouthCalcCoordsHolder, h2: MouthCalcCoordsHolder, h3: MouthCalcCoordsHolder) -> Float {
          
          let a = euclidean(coordsHolder: h1)
          let b = euclidean(coordsHolder: h2)
          let c = euclidean(coordsHolder: h3)
          
  //        let a = euclidean(p0: vertices[37], p1: vertices[83])  //1, 2
  //        let b = euclidean(p0: vertices[267], p1: vertices[314])  //3, 4
  //        let c = euclidean(p0: vertices[61], p1: vertices[281])  //5, 6

          return (a + b / (2.0 * c)) * 1.2  //! 1.2 is a factor for making result more precise!
      }

      func euclidean(coordsHolder: MouthCalcCoordsHolder) -> Float {
           //return sqrt((p0[0] - p1[0]).pow(2) + (p0[1] - p1[1]).pow(2) + (p0[2] - p1[2]).pow(2))
          let calc = pow((coordsHolder.x1 - coordsHolder.x2), 2) + pow((coordsHolder.y1 - coordsHolder.y2), 2) + pow((coordsHolder.z1 - coordsHolder.z2), 2)
          return sqrt(calc)
       }
}


    // MARK: - Animation extensions

extension LivenessScreenViewController {
    
    func setupFaceAnimation() {
        faceAnimationView = AnimationView(name: "right")
        faceAnimationView.contentMode = .scaleAspectFit
        faceAnimationView.translatesAutoresizingMaskIntoConstraints = false
        self.roundedView.addSubview(faceAnimationView)

        faceAnimationView.centerXAnchor.constraint(equalTo: self.roundedView.centerXAnchor, constant: 4).isActive = true
        faceAnimationView.centerYAnchor.constraint(equalTo: self.roundedView.centerYAnchor).isActive = true
        
        faceAnimationView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        faceAnimationView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        //faceAnimationView.transform = CGAffineTransform(rotationAngle: CGFloat.pi) //rotate by 180 deg.
        
        //faceAnimationView.loopMode = .autoReverse
        //faceAnimationView.play()
    }
    
    func updateFaceAnimation() {
        DispatchQueue.main.async {
            let toProgress = self.faceAnimationView.realtimeAnimationProgress
            //print(toProgress)
            if (toProgress >= 0.99) {
                self.faceAnimationView.play(toProgress: toProgress - 0.99)
            }
            if (toProgress <= 0.01) {
                self.faceAnimationView.play(toProgress: toProgress + 1)
            }
        }
    }
    
}


// MARK: - Coords' util structs

struct MouthCalcCoordsHolder {
    
    let x1: Float
    let x2: Float
    let y1: Float
    let y2: Float
    let z1: Float
    let z2: Float
}

struct FaceAnglesHolder {
    
    let pitch: Float
    let yaw: Float
    let roll: Float
}

// MARK: - Matrix extensions

extension simd_float4x4 {
    
    // Function to convert rad to deg
    func radiansToDegress(radians: Float32) -> Float32 {
        return radians * 180 / (Float32.pi)
    }
    
    //Obsolete(?)
    var translation: SCNVector3 {
       get {
           return SCNVector3Make(columns.3.x, columns.3.y, columns.3.z)
       }
    }

    // Retrieve euler angles from a quaternion matrix
    var eulerAngles: FaceAnglesHolder {
        get {
            // Get quaternions
            let qw = sqrt(1 + self.columns.0.x + self.columns.1.y + self.columns.2.z) / 2.0
            let qx = (self.columns.2.y - self.columns.1.z) / (qw * 4.0)
            let qy = (self.columns.0.z - self.columns.2.x) / (qw * 4.0)
            let qz = (self.columns.1.x - self.columns.0.y) / (qw * 4.0)

            // Deduce euler angles
            /// yaw (z-axis rotation)
            let siny = +2.0 * (qw * qz + qx * qy)
            let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
            let actualRoll = radiansToDegress(radians:atan2(siny, cosy))
            // pitch (y-axis rotation)
            let sinp = +2.0 * (qw * qy - qz * qx)
            var actualYaw: Float
            if abs(sinp) >= 1 {
                actualYaw = radiansToDegress(radians:copysign(Float.pi / 2, sinp))
            } else {
                actualYaw = radiansToDegress(radians:asin(sinp))
            }
            /// roll (x-axis rotation)
            let sinr = +2.0 * (qw * qx + qy * qz)
            let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
            let actualPitch = -radiansToDegress(radians:atan2(sinr, cosr))

            /// return array containing ypr values
            return FaceAnglesHolder(pitch: actualPitch, yaw: abs(actualYaw), roll: actualRoll)
            //! actualPitch was roll; ! actualYaw was pitch; ! actualRoll was yaw
        }
    }
}


//extension UIDevice {
//    static var isSimulator: Bool = {
//        #if targetEnvironment(simulator)
//        return true
//        #else
//        return false
//        #endif
//    }()

//DispatchQueue.global(qos: .userInitiated).async {
//    print("This is run on a background queue")
//
//    DispatchQueue.main.async {
//        print("This is run on the main queue, after the previous code in outer block")
//    }
//}
