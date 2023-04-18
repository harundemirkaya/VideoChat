//
//  MessageChatViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 9.04.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MessageChatViewModel{
    
    // MARK: MessageChatVC Defined
    var messageChatVC: MessageChatViewController?
    
    private let db = Firestore.firestore()
    
    func getUnreadMessages(){
        if let currentUser = Auth.auth().currentUser{
            let users = db.collection("users")
            let user = users.document(currentUser.uid)
            
            user.addSnapshotListener { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                    if let remoteUserID = self.messageChatVC?.remoteUser.uid, let userUnreadmessages = unreadMessages[remoteUserID] {
                        for userUnreadMessage in userUnreadmessages{
                            self.messageChatVC?.saveData(userUnreadMessage, isRemote: true)
                            self.messageChatVC?.reloadTableData()
                        }
                        unreadMessages.removeValue(forKey: remoteUserID)
                        user.updateData([
                            "unreadMessages": unreadMessages
                        ]) { err in
                            if let err = err {
                                print("Hata oluştu: \(err)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sendMessage(){
        if messageChatVC?.txtFieldMessage.text != ""{
            let users = db.collection("users")
            if let remoteUserID = messageChatVC?.remoteUser.uid{
                let user = users.document(remoteUserID)
                user.getDocument { userDocument, userError in
                    if let userDocument = userDocument, userDocument.exists{
                        let userData = userDocument.data()
                        var unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                        if let message = self.messageChatVC?.txtFieldMessage.text{
                            if var messages = unreadMessages[Auth.auth().currentUser!.uid] {
                            messages.append(message)
                            unreadMessages[Auth.auth().currentUser!.uid] = messages
                            } else {
                                unreadMessages[Auth.auth().currentUser!.uid] = [message]
                            }
                        }
                        user.updateData([
                            "unreadMessages": unreadMessages
                        ]) { err in
                            if let err = err {
                                print("Hata oluştu: \(err)")
                            } else{
                                self.messageChatVC?.saveData()
                                self.messageChatVC?.txtFieldMessage.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getCurrentUserID() -> String{
        if let currentUser = Auth.auth().currentUser{
            return currentUser.uid
        }
        return ""
    }
    
    func sendVideoCall(_ remoteUserID: String, currentUserID: String){
        let remoteUserCollection = db.collection("users").document(remoteUserID)
        remoteUserCollection.getDocument { userDocument, userError in
            if let userDocument = userDocument, userDocument.exists{
                let userData = userDocument.data()
                let id = userData?["id"] as? UInt
                remoteUserCollection.updateData([
                    "matchRequest": [currentUserID,String(id ?? UInt())]
                ]) { err in
                    if let err = err {
                        print("Hata oluştu: \(err)")
                    }
                }
            }
        }
    }
}
