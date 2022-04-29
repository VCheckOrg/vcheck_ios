//
//  DataRequest.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

//import Foundation
//import Alamofire
//
//extension DataRequest {
//    fileprivate func decodableResponseSerializer<T: Decodable>() -> GenericResponseSerializer<T> {
//        return DataResponseSerializer { _, response, data, error in
//            guard error == nil else { return .failure(error!) }
//
//            guard let data = data else {
//                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
//            }
//
//            return Result { try JSONDecoder().decode(T.self, from: data) }
//        }
//    }
//
//    @discardableResult
//    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
//        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
//    }
//
//    @discardableResult
//    func responsePhoto(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<Photo>) -> Void) -> Self {
//        return responseDecodable(queue: queue!, completionHandler: completionHandler)
//    }
//}
