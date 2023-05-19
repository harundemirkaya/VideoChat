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
                            let profilePhoto = userData?["profilePhoto"] as! String
                            self.friendRequestVC?.users.append(User(userName: name, uid: userID, userPhoto: profilePhoto))
                        }
                    }
                }
            }
        }
    }
    
    func confirmRequest(_ sender: UIButton){
        guard let friendRequestVC = friendRequestVC else { return }
        ImageCache.shared.getProfilePhotoURL(friendRequestVC.users[sender.tag].uid)
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var userFriends = userData?["friends"] as? [String] ?? []
                    let uid = friendRequestVC.users[sender.tag].uid
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
    
    func getProfileImage(withURL imageURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let friendRequestVC = friendRequestVC else { return }
        if let cachedImage = ImageCache.shared.getImage(forKey: imageURL) {
            completion(cachedImage)
        } else {
            downloadImage(from: imageURL) { image in
                if let image = image {
                    ImageCache.shared.setImage(image, forKey: imageURL)
                }
                completion(image)
                DispatchQueue.main.async {
                    friendRequestVC.reloadTableData()
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
}
