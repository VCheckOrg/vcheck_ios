//
//  Utils.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation
import CommonCrypto
import UIKit

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
