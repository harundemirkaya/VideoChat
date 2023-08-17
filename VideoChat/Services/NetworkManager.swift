//
//  NetworkManager.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 11.03.2023.
//

import Foundation
import Alamofire

class NetworkManager{
    
    var tokenURL: String?
    
    public func fetchToken(completion: @escaping (_ result: DataResponse<RTCToken, AFError>) -> Void) {
        AF.request(tokenURL!).responseDecodable(of: RTCToken.self) { response in
            completion(response)
        }
    }
    
    public func postMessage(message: String, remoteUserID: String, completion: @escaping (_ result: DataResponse<Any, AFError>) -> Void) {
        let parameters: [String: Any] = [
            "message": message,
            "remoteUserID": remoteUserID
        ]

        let url = "http://213.238.190.162:5001/process"

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                completion(response)
            }
    }
}
