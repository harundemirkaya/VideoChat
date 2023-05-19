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
        guard let messagesVC = messagesVC else { return }
        if let currentUser = Auth.auth().currentUser{
            let usersCollection = db.collection("users").document(currentUser.uid)
            usersCollection.addSnapshotListener { [weak self] userDocument, userError in
                guard let self = self else { return }
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    let unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                    for unreadMessage in unreadMessages{
                        messagesVC.recentlyChatCount.updateValue(unreadMessage.value.count, forKey: unreadMessage.key)
                        self.db.collection("users").document(unreadMessage.key).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let userName = data?["name"] as? String ?? "Unkown"
                                let profilePhoto = data?["profilePhoto"] as? String ?? ""
                                let newUser = User(userName: userName, uid: unreadMessage.key, userPhoto: profilePhoto)
                                if !messagesVC.recentlyChat.contains(where: { $0.uid == newUser.uid }) {
                                    messagesVC.recentlyChat.append(newUser)
                                }
                                messagesVC.reloadTableData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getProfileImage(withURL imageURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let messagesVC = messagesVC else { return }
        if let cachedImage = ImageCache.shared.getImage(forKey: imageURL) {
            completion(cachedImage)
        } else {
            downloadImage(from: imageURL) { image in
                if let image = image {
                    ImageCache.shared.setImage(image, forKey: imageURL)
                }
                completion(image)
                DispatchQueue.main.async {
                    messagesVC.reloadTableData()
                }
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
    
    func getProfilePhotoURL(_ userID: String, completion: @escaping (String?) -> Void){
        if userID != ""{
            db.collection("users").document(userID).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let profilePhoto = data?["profilePhoto"] as? String ?? ""
                    completion(profilePhoto)
                }
            }
        }
    }
}
