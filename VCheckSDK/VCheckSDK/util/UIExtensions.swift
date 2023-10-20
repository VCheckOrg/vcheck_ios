//
//  UIExtensions.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 20.10.2023.
//

import Foundation
import UIKit
import SwiftUI


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

extension UIImage {
  convenience init?(named: String) {
      self.init(named: named, in: InternalConstants.bundle, compatibleWith: nil)
  }
}

extension Text {
init(textKey: LocalizedStringKey) {
    self.init(textKey, bundle: InternalConstants.bundle)
  }
}

extension String {
    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: InternalConstants.bundle, value: "", comment: "")
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
            print("VCheckSDK - error: no Selected Doc Type With Data provided for cropping with mask")
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

