//
//  MessagesViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 9.04.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

class MessagesViewModel{
    
    // MARK: MessagesVC Defined
    var messagesVC: MessagesViewController?
    
    let db = Firestore.firestore()
    
    func getUnreadMessags(){
        if let currentUser = Auth.auth().currentUser{
            let usersCollection = db.collection("users").document(currentUser.uid)
            usersCollection.addSnapshotListener { [self] userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    let unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                    for unreadMessage in unreadMessages{
                        self.messagesVC?.recentlyChatCount.updateValue(unreadMessage.value.count, forKey: unreadMessage.key)
                        db.collection("users").document(unreadMessage.key).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let userName = data?["name"] as? String ?? "Unkown"
                                let newUser = User(userName: userName, uid: unreadMessage.key)
                                if let recentlyChat = self.messagesVC?.recentlyChat{
                                    if !recentlyChat.contains(where: { $0.uid == newUser.uid }) {
                                        self.messagesVC?.recentlyChat.append(newUser)
                                    }
                                    self.messagesVC?.reloadTableData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
