//
//  FriendRequestsViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 9.04.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FriendRequestsViewModel{
    
    // MARK: FriendRequestsVC Defined
    var friendRequestVC: FriendRequestsViewController?
    
    private let db = Firestore.firestore()
    
    func getUserData(){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    let friendsRequests = userData?["friendsRequests"] as? [String] ?? []
                    self.friendRequestVC?.userFriendsRequests = friendsRequests
                }
            }
        }
    }
    
    func setRequests(){
        if friendRequestVC?.userFriendsRequests.count != 0{
            let users = db.collection("users")
            if let userFriendsRequests = friendRequestVC?.userFriendsRequests{
                for userID in userFriendsRequests{
                    let user = users.document(userID)
                    user.getDocument { userDocument, userError in
                        if let userDocument = userDocument, userDocument.exists{
                            let userData = userDocument.data()
                            let name = userData?["name"] as! String
                            self.friendRequestVC?.users.append(User(userName: name, uid: userID))
                        }
                    }
                }
            }
        }
    }
    
    func confirmRequest(_ sender: UIButton){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var userFriends = userData?["friends"] as? [String] ?? []
                    if let uid = self.friendRequestVC?.users[sender.tag].uid{
                        userFriends.append(uid)
                        userCollection.updateData([
                            "friends": userFriends
                        ]) { err in
                            if let err = err {
                                print("Hata oluştu: \(err)")
                            } else {
                                let remoteUserCollection = self.db.collection("users").document(uid)
                                remoteUserCollection.getDocument { userDocument, userError in
                                    if let userDocument = userDocument, userDocument.exists{
                                        let userData = userDocument.data()
                                        var userFriends = userData?["friends"] as? [String] ?? []
                                        userFriends.append(userID)
                                        remoteUserCollection.updateData([
                                            "friends": userFriends
                                        ]) { err in
                                            if let err = err {
                                                print("Hata oluştu: \(err)")
                                            } else{
                                                self.removeRequest(sender)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeRequest(_ sender: UIButton){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var friendsRequests = userData?["friendsRequests"] as? [String] ?? []
                    if let uid = self.friendRequestVC?.users[sender.tag].uid{
                        friendsRequests.removeAll(where: { $0 == uid})
                        userCollection.updateData([
                            "friendsRequests": friendsRequests
                        ]) { err in
                            if let err = err {
                                print("Hata oluştu: \(err)")
                            } else{
                                self.friendRequestVC?.users.remove(at: sender.tag)
                            }
                        }
                    }
                }
            }
        }
    }
}
