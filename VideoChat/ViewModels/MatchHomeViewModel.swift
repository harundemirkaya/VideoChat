//
//  MatchHomeViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 11.03.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class MatchHomeViewModel{
    // MARK: -Define
    
    // MARK: Network Manager Defined
    let networkManager = NetworkManager()
    
    // MARK: StationsVC Defined
    var matchHomeVC: MatchHomeViewController?
    
    var urlString: String?
    
    let db = Firestore.firestore()
    
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
        networkManager.fetchToken { [weak self] result in
            if result.response?.statusCode == 200{
                self?.matchHomeVC?.listenerToken = result.value?.rtcToken
            }
        }
    }
    
    func setRemoteUserID(_ isListener: Bool, listenerJoinedUID: String){
        if isListener{
            let channelDocument = db.collection("channels").document(listenerJoinedUID)
            channelDocument.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let publisherUID = data?["publisherUID"] as! String
                    let listenerUID = data?["listenerUID"] as! String
                    if let userID = Auth.auth().currentUser?.uid{
                        let docListenerUser = self.db.collection("users").document(userID)
                        docListenerUser.updateData(["remoteUserID": publisherUID]) { error in
                            if let error = error {
                                print("Hata oluştu: \(error.localizedDescription)")
                            }
                        }
                        
                        let docPublisherUser = self.db.collection("users").document(publisherUID)
                        docPublisherUser.updateData(["remoteUserID": listenerUID]) { error in
                            if let error = error {
                                print("Hata oluştu: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    func listenChatState(_ channelName: String){
        let channelCollection = db.collection("channels").document(channelName)
        channelCollection.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if !document.exists {
                self.matchHomeVC?.leaveChannel()
            }
        }
    }
}
