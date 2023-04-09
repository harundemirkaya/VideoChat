//
//  MatchHomeViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 11.03.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import AgoraRtcKit

class MatchHomeViewModel{
    // MARK: -Define
    
    // MARK: Network Manager Defined
    let networkManager = NetworkManager()
    
    // MARK: MatchHomeVC Defined
    var matchHomeVC: MatchHomeViewController?
    
    var urlString: String?
    
    private let db = Firestore.firestore()
    
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
    
    func joinChannel(){
        if let currentUser = Auth.auth().currentUser {
            // MARK: Set User ID
            let docRef = db.collection("users").document(currentUser.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let userID = data!["id"] as! UInt
                    self.matchHomeVC?.userIDforChannel = userID
                    let isEmptyChannelDB = self.db.collection("channels")
                    isEmptyChannelDB.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error.localizedDescription)")
                        } else {
                            let numberOfDocuments = querySnapshot?.count ?? 0
                            if numberOfDocuments == 0 {
                                self.getTokenPublisher(userID)
                            } else{
                                self.listenerFilters(userID)
                            }
                        }
                    }
                } else {
                    print("Kullanıcı belgesi mevcut değil")
                }
            }
        } else {
            print("Kullanıcı oturum açmadı")
        }
    }
    
    func createChannel(){
        let channelsCollection = db.collection("channels")
        let getCurrentUser = db.collection("users").document(Auth.auth().currentUser!.uid)
        var currentUserGender = ""
        getCurrentUser.getDocument { (document, error) in
            if let document = document, document.exists {
                currentUserGender = document.data()?["gender"] as! String
                let data: [String: Any] = [
                    "channelName": "\(self.matchHomeVC?.userIDforChannel! ?? 0)CHANNEL",
                    "publisherToken": self.matchHomeVC?.publisherToken! ?? "",
                    "publisherUID": Auth.auth().currentUser!.uid as String,
                    "gender": currentUserGender,
                    "listenerToken": ""
                ]
                let docRefChannel = channelsCollection.document("\(self.matchHomeVC?.userIDforChannel! ?? 0)CHANNEL")
                docRefChannel.setData(data){ error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else{
                        self.matchHomeVC?.channelName = "\(self.matchHomeVC?.userIDforChannel! ?? 0)CHANNEL"
                        let result = self.matchHomeVC?.agoraEngine.joinChannel(
                            byToken: self.matchHomeVC?.publisherToken ?? "", channelId: self.matchHomeVC?.channelName ?? "", uid: self.matchHomeVC?.userIDforChannel ?? 0, mediaOptions: self.matchHomeVC?.option ?? AgoraRtcChannelMediaOptions() ,
                            joinSuccess: { (channel, uid, elapsed) in }
                        )
                        if result == 0 {
                            self.matchHomeVC?.joined = true
                            if let userRole = self.matchHomeVC?.userRole{
                                self.matchHomeVC?.showMessage(title: "Success", text: "Successfully joined the channel as \(userRole)")
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func listenerFilters(_ userID: UInt){
        let channelsCollection = db.collection("channels")
        channelsCollection.getDocuments{ (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    let gender = document.data()["gender"] as? String ?? ""
                    if gender == "female" {
                        let data = document.data()
                        self.matchHomeVC?.filteredChannelName = data["channelName"] as? String ?? ""
                        self.getTokenListener(userID, channelName: self.matchHomeVC?.filteredChannelName ?? "")
                        self.matchHomeVC?.listenerJoinedUID = document.documentID
                    }
                }
            }
        }
    }
    
    func setListenerToken(){
        let channelsCollectionDocument = db.collection("channels").document(self.matchHomeVC?.listenerJoinedUID ?? "")
        channelsCollectionDocument.updateData([
            "listenerToken": self.matchHomeVC?.listenerToken! ?? "",
            "listenerUID": String(Auth.auth().currentUser!.uid)
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                self.matchHomeVC?.isListener = true
                if let userRole = self.matchHomeVC?.userRole{
                    self.matchHomeVC?.showMessage(title: "Success", text: "Successfully joined the channel as \(userRole)")
                }
            }
        }
    }
    
    func deleteChannel(){
        let channelCollection = db.collection("channels").document(self.matchHomeVC?.channelName ?? "")
        channelCollection.delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func addFriends(){
        let channel = db.collection("channels").document(self.matchHomeVC?.channelName ?? "")
        channel.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let publisherUID = data?["publisherUID"] as! String
                let listenerUID = data?["listenerUID"] as! String
                if self.matchHomeVC?.isListener == true{
                    let user = self.db.collection("users").document(publisherUID)
                    user.getDocument { userDocument, userError in
                        if let userDocument = userDocument, userDocument.exists{
                            let userData = userDocument.data()
                            var friendsRequests = userData?["friendsRequests"] as? [String] ?? []
                            if friendsRequests.contains(listenerUID){
                                self.matchHomeVC?.showMessage(title: "Failed", text: "You have already sent a request to the user")
                            } else{
                                friendsRequests.append(listenerUID)
                                user.updateData(["friendsRequests": friendsRequests]) { error in
                                    if let error = error {
                                        print("Hata oluştu: \(error.localizedDescription)")
                                    } else{
                                        self.matchHomeVC?.showMessage(title: "Success", text: "Friendship Request Success")
                                        self.matchHomeVC?.btnAddFriend.isHidden = true
                                    }
                                }
                            }
                        }
                    }
                } else{
                    let user = self.db.collection("users").document(listenerUID)
                    user.getDocument { userDocument, userError in
                        if let userDocument = userDocument, userDocument.exists{
                            let userData = userDocument.data()
                            var friendsRequests = userData?["friendsRequests"] as? [String] ?? []
                            if friendsRequests.contains(publisherUID){
                                self.matchHomeVC?.showMessage(title: "Failed", text: "You have already sent a request to the user")
                            } else{
                                friendsRequests.append(publisherUID)
                                user.updateData(["friendsRequests": friendsRequests]) { error in
                                    if let error = error {
                                        print("Hata oluştu: \(error.localizedDescription)")
                                    } else{
                                        self.matchHomeVC?.showMessage(title: "Success", text: "Friendship Request Success")
                                        self.matchHomeVC?.btnAddFriend.isHidden = true
                                    }
                                }
                            }
                            
                        }
                    }
                }
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
}
