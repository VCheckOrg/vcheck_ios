//
//  UtilExtensions.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 20.10.2023.
//

import Foundation
import UIKit
import CommonCrypto


extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
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
