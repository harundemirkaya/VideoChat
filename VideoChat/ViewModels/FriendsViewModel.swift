//
//  FriendsViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 9.04.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FriendsViewModel{
    
    // MARK: FriendsVC Defined
    var friendsVC: FriendsViewController?
    
    let db = Firestore.firestore()
    
    func getFriendsID(){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    let friendsRequests = userData?["friends"] as? [String] ?? []
                    self.friendsVC?.userFriendsID = friendsRequests
                }
            }
        }
    }
    
    func getFriends(){
        if friendsVC?.userFriendsID != []{
            let users = db.collection("users")
            if let userFriendsID = friendsVC?.userFriendsID{
                for userID in userFriendsID{
                    let user = users.document(userID)
                    user.getDocument { userDocument, userError in
                        if let userDocument = userDocument, userDocument.exists{
                            let userData = userDocument.data()
                            let name = userData?["name"] as! String
                            self.friendsVC?.userFriends.append(User(userName: name, uid: userID))
                            
                        }
                    }
                }
            }
        }
    }
}
