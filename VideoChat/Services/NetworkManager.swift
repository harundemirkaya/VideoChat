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
}
