//
//  ProfileViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 9.04.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreData

class ProfileViewModel{
    
    // MARK: ProfileViewController Defined
    var profileVC: ProfileViewController?
    
    private let db = Firestore.firestore()
    
    func fetchData(){
        guard let profileVC = profileVC else { return }
        if let currentUser = Auth.auth().currentUser{
            db.collection("users").document(currentUser.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    profileVC.txtFieldName.placeholder = data!["name"] as? String
                    profileVC.txtFieldEmail.placeholder = data!["email"] as? String
                    guard let profilePhoto = data!["profilePhoto"] as? String else { return }
                    self.getProfileImage(withURL: profilePhoto) { image in
                        DispatchQueue.main.async {
                            profileVC.imgProfilePhoto.image = image
                        }
                    }
                } else {
                    print("Belge mevcut değil")
                }
            }
        }
    }
    
    func updatePassword(){
        guard let profileVC = profileVC else { return }
        if let currentUser = Auth.auth().currentUser, let oldPassword = profileVC.txtFieldOldPassword.text, let newPassword = profileVC.txtFieldNewPassword.text{
            let credential = EmailAuthProvider.credential(withEmail: currentUser.email!, password: oldPassword)
            currentUser.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    currentUser.updatePassword(to: newPassword) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            profileVC.txtFieldOldPassword.text = ""
                            profileVC.txtFieldNewPassword.text = ""
                            profileVC.txtFieldNewPasswordAgain.text = ""
                        }
                    }
                }
            }
        }
    }
    
    func updateProfilePhoto(_ imageUrl: String, oldImageURL: String){
        if let currentUser = Auth.auth().currentUser{
            self.db.collection("users").document(currentUser.uid).updateData([
                "profilePhoto": imageUrl
            ]) { err in
                if let err = err {
                    print("Hata oluştu: \(err)")
                } else {
                    let storageRef = Storage.storage().reference(forURL: oldImageURL)
                    storageRef.delete { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            
                        }
                    }
                }
            }
        }
    }
    
    func updateNameOrEmail(){
        guard let profileVC = profileVC else { return }
        if let currentUser = Auth.auth().currentUser{
            if profileVC.txtFieldName.text != ""{
                db.collection("users").document(currentUser.uid).updateData([
                    "name": profileVC.txtFieldName.text as Any
                ]) { err in
                    if let err = err {
                        print("Hata oluştu: \(err)")
                    } else {
                        profileVC.txtFieldName.placeholder = profileVC.txtFieldName.text
                        profileVC.txtFieldName.text = ""
                        print("Veri başarıyla güncellendi")
                    }
                }
            }
            if profileVC.txtFieldEmail.text != ""{
                if let email = profileVC.txtFieldEmail.text{
                    currentUser.updateEmail(to: email) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            self.db.collection("users").document(currentUser.uid).updateData([
                                "email": email
                            ]) { err in
                                if let err = err {
                                    print("Hata oluştu: \(err)")
                                } else {
                                    profileVC.txtFieldEmail.placeholder = profileVC.txtFieldEmail.text
                                    profileVC.txtFieldEmail.text = ""
                                    print("Veri başarıyla güncellendi")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func logout(){
        guard let profileVC = profileVC else { return }
        deleteUserData(entityName: "Messages") { isSuccess in
            if isSuccess{
                do {
                    try Auth.auth().signOut()
                    let homeVC = ViewController()
                    homeVC.modalPresentationStyle = .fullScreen
                    profileVC.present(homeVC, animated: true)
                } catch let signOutError as NSError {
                    print(signOutError.localizedDescription)
                }
            }
        }
    }
    
    func getUserProfilePhotoURL(completion: @escaping (String) -> Void) {
        if let currentUser = Auth.auth().currentUser{
            let documentRef = db.collection("users").document(currentUser.uid)
            documentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let userData = document.data()
                    let profilePhoto = userData?["profilePhoto"] as? String ?? ""
                    completion(profilePhoto)
                }
            }
        }
    }
    
    func deleteUserData(entityName: String, completion: @escaping (Bool) -> Void) {
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        persistentContainer.viewContext.perform {
            do {
                try persistentContainer.viewContext.execute(batchDeleteRequest)
                completion(true)
            } catch {
                print("Hata oluştu: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    func getProfileImage(withURL imageURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let profileVC = profileVC else { return }
        if let cachedImage = ImageCache.shared.getImage(forKey: imageURL) {
            completion(cachedImage)
        } else {
            downloadImage(from: imageURL) { image in
                if let image = image {
                    ImageCache.shared.setImage(image, forKey: imageURL)
                }
                completion(image)
                ///
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
