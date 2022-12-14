//
//  Utils.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation
import CommonCrypto
import UIKit

extension UIApplication {

  static var topWindow: UIWindow {
    if #available(iOS 15.0, *) {
      let scenes = UIApplication.shared.connectedScenes
      let windowScene = scenes.first as? UIWindowScene
      return windowScene!.windows.first!
    } else {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first!
    }
  }
}

extension Data {
    public func sha256() -> String{
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}

public extension String {
    
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }

    mutating func substringBefore(_ string: String) -> String {
        let components = self.components(separatedBy: string)
        return components[0]
    }
    
    func isMatchedBy(regex: String) -> Bool {
        return (self.range(of: regex, options: .regularExpression) ?? nil) != nil
    }
    
    func checkIfValidDocDateFormat() -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"

        if (dateFormatterGet.date(from: self) != nil) {
            return true
        } else {
            return false
        }
    }
    
    func isValidURL() -> Bool {
        let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: self)
    }
}


extension UIViewController {

    func showToast(message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
 }


extension UIView {
    
    private struct OnClickHolder {
        static var _closure:()->() = {}
    }

    private var onClickClosure: () -> () {
        get { return OnClickHolder._closure }
        set { OnClickHolder._closure = newValue }
    }

    func onTap(closure: @escaping ()->()) {
        self.onClickClosure = closure
        
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickAction))
        addGestureRecognizer(tap)
    }

    @objc private func onClickAction() {
        onClickClosure()
    }
}


extension CIImage {
    func orientationCorrectedImage() -> UIImage? {
        var imageOrientation = UIImage.Orientation.up
        switch UIDevice.current.orientation {
        case UIDeviceOrientation.portrait:
            imageOrientation = UIImage.Orientation.right
        case UIDeviceOrientation.landscapeLeft:
            imageOrientation = UIImage.Orientation.down
        case UIDeviceOrientation.landscapeRight:
            imageOrientation = UIImage.Orientation.up
        case UIDeviceOrientation.portraitUpsideDown:
            imageOrientation = UIImage.Orientation.left
        default:
            break;
        }

        var w = self.extent.size.width
        var h = self.extent.size.height

        if imageOrientation == .left || imageOrientation == .right || imageOrientation == .leftMirrored || imageOrientation == .rightMirrored {
            swap(&w, &h)
        }

        UIGraphicsBeginImageContext(CGSize(width: w, height: h));
        UIImage.init(ciImage: self, scale: 1.0, orientation: imageOrientation).draw(in: CGRect(x: 0, y: 0, width: w, height: h))
        let uiImage:UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        return uiImage
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

var bundleKey: UInt8 = 0

class AnyLanguageBundle: Bundle {

    override func localizedString(forKey key: String,
                              value: String?,
                              table tableName: String?) -> String {

        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {

    class func setLanguage(_ language: String) {
        defer {
            object_setClass(InternalConstants.bundle, AnyLanguageBundle.self)
        }
        objc_setAssociatedObject(InternalConstants.bundle, &bundleKey,
                                 InternalConstants.bundle.path(forResource: language, ofType: "lproj"),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension UIDevice {
    static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension UIImage {
    
    func cropWithMask() -> UIImage? {
        
        if let maskDimens = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()?.maskDimensions {
            let originalWidth = self.size.width
            let originalHeight = self.size.height
            let desiredWidth = originalWidth * (maskDimens.widthPercent! / 100)
            let desiredHeight = desiredWidth * (maskDimens.ratio!)
            let cropHeightFromEachSide = ((originalHeight - desiredHeight) / 2)
            let cropWidthFromEachSide = ((originalWidth - desiredWidth) / 2)
            
            return crop(rect: CGRect(x: cropWidthFromEachSide,
                                   y: cropHeightFromEachSide,
                                   width: desiredWidth,
                                   height: desiredHeight))
        } else {
            print("VCheck SDK - error: no Selected Doc Type With Data provided for cropping with mask")
            return nil
        }
    }
    
    func crop(rect: CGRect) -> UIImage {
            var rect = rect
            rect.origin.x*=self.scale
            rect.origin.y*=self.scale
            rect.size.width*=self.scale
            rect.size.height*=self.scale

            let imageRef = self.cgImage!.cropping(to: rect)
            let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
            return image
        }
}

extension UIView {
    public var viewWidth: CGFloat {
        return self.frame.size.width
    }

    public var viewHeight: CGFloat {
        return self.frame.size.height
    }
}


extension String {
    
    func hexToUIColor () -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
    
    func isValidHexColor() -> Bool {
        let rgbRegEx = "^#(?:[0-9a-fA-F]{3}){1,2}$"; //TODO: test regex
        let argbRegEx = "^#(?:[0-9a-fA-F]{3,4}){1,2}$"; //TODO: test regex
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [
            rgbRegEx, argbRegEx
        ])
        return predicate.evaluate(with: self)
    }
}



struct ImageCompressor {
    
    static let maxAPIFrameSizeBytes = 97000 //~98 kb
    
    static func compressFrame(image: UIImage, maxByte: Int = maxAPIFrameSizeBytes,
                         completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let currentImageSize = image.jpegData(compressionQuality: 1.0)?.count else {
                return completion(nil)
            }
        
            var iterationImage: UIImage? = image
            var iterationImageSize = currentImageSize
            var iterationCompression: CGFloat = 1.0
        
            while iterationImageSize > maxByte && iterationCompression > 0.01 {
                let percantageDecrease = getPercantageToDecreaseTo(forDataCount: iterationImageSize)
            
                let canvasSize = CGSize(width: image.size.width * iterationCompression,
                                        height: image.size.height * iterationCompression)
                UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
                defer { UIGraphicsEndImageContext() }
                image.draw(in: CGRect(origin: .zero, size: canvasSize))
                iterationImage = UIGraphicsGetImageFromCurrentImageContext()
            
                guard let newImageSize = iterationImage?.jpegData(compressionQuality: 1.0)?.count else {
                    return completion(nil)
                }
                iterationImageSize = newImageSize
                iterationCompression -= percantageDecrease
            }
            
//            let imgData = NSData(data: iterationImage!.jpegData(compressionQuality: 1)!)
//            print("VCheck - compression: actual size of image in KB: ", Double(imgData.count) / 1000.0)
            
            completion(iterationImage)
        }
    }
    
    private static func getPercantageToDecreaseTo(forDataCount dataCount: Int) -> CGFloat {
        switch dataCount {
        case 0..<3000000: return 0.05
        case 3000000..<10000000: return 0.1
        default: return 0.2
        }
    }
}
