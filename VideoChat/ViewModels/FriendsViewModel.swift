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
        guard let friendsVC = friendsVC else { return }
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    let friendsRequests = userData?["friends"] as? [String] ?? []
                    friendsVC.userFriendsID = friendsRequests
                }
            }
        }
    }
    
    func getFriends(){
        guard let friendsVC = friendsVC else { return }
        if friendsVC.userFriendsID != []{
            let users = db.collection("users")
            let userFriendsID = friendsVC.userFriendsID
            for userID in userFriendsID{
                let user = users.document(userID)
                user.getDocument { userDocument, userError in
                    if let userDocument = userDocument, userDocument.exists{
                        let userData = userDocument.data()
                        let name = userData?["name"] as! String
                        let profilePhoto = userData?["profilePhoto"] as! String
                        friendsVC.userFriends.append(User(userName: name, uid: userID, userPhoto: profilePhoto))
                        
                    }
                }
            }
        }
    }
    
    func getProfileImage(withURL imageURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let friendsVC = friendsVC else { return }
        if let cachedImage = ImageCache.shared.getImage(forKey: imageURL) {
            completion(cachedImage)
        } else {
            downloadImage(from: imageURL) { image in
                if let image = image {
                    ImageCache.shared.setImage(image, forKey: imageURL)
                }
                completion(image)
                DispatchQueue.main.async {
                    friendsVC.reloadTableData()
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
