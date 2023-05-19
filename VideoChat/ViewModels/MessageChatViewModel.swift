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
    
    var messagesListener: ListenerRegistration? = nil
    
    func getUnreadMessages(){
        guard let messageChatVC = messageChatVC else { return }
        if let currentUser = Auth.auth().currentUser{
            let users = db.collection("users")
            let user = users.document(currentUser.uid)
            
            messagesListener = user.addSnapshotListener { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                    let remoteUserID = messageChatVC.remoteUser.uid
                    if let userUnreadmessages = unreadMessages[remoteUserID] {
                        for userUnreadMessage in userUnreadmessages{
                            messageChatVC.saveData(userUnreadMessage, isRemote: true)
                            messageChatVC.reloadTableData()
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
    
    func removeMessagesListener(){
        guard let messagesListener = self.messagesListener else { return }
        messagesListener.remove()
    }
    
    func sendMessage(){
        guard let messageChatVC = messageChatVC else { return }
        if messageChatVC.txtFieldMessage.text != ""{
            let users = db.collection("users")
            let remoteUserID = messageChatVC.remoteUser.uid
            let user = users.document(remoteUserID)
            user.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                    if let message = messageChatVC.txtFieldMessage.text{
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
                            messageChatVC.saveData()
                            messageChatVC.txtFieldMessage.text = ""
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
    
    func getUserUDID(completion: @escaping (UInt?) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            let docRef = db.collection("users").document(currentUser.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let userID = data!["id"] as! UInt
                    completion(userID)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    func busyControl(_ remoteUserUID: String){
        guard let messageChatVC = messageChatVC else { return }
        let docRef = db.collection("users").document(remoteUserUID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let isBusy = data?["isBusy"] as? Bool{
                    if isBusy{
                        messageChatVC.busyChannelNotification()
                    } else{
                        messageChatVC.sendCallWithNotification()
                    }
                }
            }
        }
    }
    
    func getProfileImage(withURL imageURL: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = ImageCache.shared.getImage(forKey: imageURL) {
            completion(cachedImage)
        } else {
            downloadImage(from: imageURL) { image in
                if let image = image {
                    ImageCache.shared.setImage(image, forKey: imageURL)
                }
                completion(image)
            }
        }
    }
    
    private func downloadImage(from imageURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: imageURL) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}
