//
//  ImageCompressor.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 20.10.2023.
//

import Foundation
import UIKit

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
