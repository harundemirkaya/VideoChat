//
//  MatchHomeViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 11.03.2023.
//

import Foundation

class MatchHomeViewModel{
    // MARK: -Define
    
    // MARK: Network Manager Defined
    let networkManager = NetworkManager()
    
    // MARK: StationsVC Defined
    var matchHomeVC: MatchHomeViewController?
    
    var urlString: String?
    
    // MARK: -Get Token Funcs
    func getTokenPublisher(_ userID: UInt){
        urlString = "http://213.238.190.166:3169/rte/\(userID)CHANNEL/publisher/userAccount/\(userID)/?expiry=3600"
        networkManager.tokenURL = urlString
        networkManager.fetchToken { [weak self] result in
            if result.response?.statusCode == 200{
                self?.matchHomeVC?.publisherToken = result.value?.rtcToken
            }
        }
    }
    
    func getTokenListener(_ userID: UInt, channelName: String){
        urlString = "http://213.238.190.166:3169/rte/\(channelName)/publisher/userAccount/\(userID)/?expiry=3600"
        networkManager.tokenURL = urlString
        print(urlString)
        networkManager.fetchToken { [weak self] result in
            if result.response?.statusCode == 200{
                self?.matchHomeVC?.listenerToken = result.value?.rtcToken
            }
        }
    }
}
