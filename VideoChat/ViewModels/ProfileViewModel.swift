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

class ProfileViewModel{
    
    // MARK: ProfileViewController Defined
    var profileVC: ProfileViewController?
    
    private let db = Firestore.firestore()
    
    func fetchData(){
        if let currentUser = Auth.auth().currentUser{
            db.collection("users").document(currentUser.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    self.profileVC?.txtFieldName.placeholder = data!["name"] as? String
                    self.profileVC?.txtFieldEmail.placeholder = data!["email"] as? String
                    let urlString = data!["profilePhoto"] as? String
                    if let urlstring = urlString, let url = URL(string: urlstring){
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard let data = data, error == nil else {
                                print("Error loading image: \(error?.localizedDescription ?? "unknown error")")
                                return
                            }
                            DispatchQueue.main.async {
                                self.profileVC?.imgProfilePhoto.image = UIImage(data: data)
                            }
                        }.resume()
                    }
                } else {
                    print("Belge mevcut değil")
                }
            }
        }
    }
    
    func updatePassword(){
        if let currentUser = Auth.auth().currentUser, let oldPassword = profileVC?.txtFieldOldPassword.text, let newPassword = profileVC?.txtFieldNewPassword.text{
            let credential = EmailAuthProvider.credential(withEmail: currentUser.email!, password: oldPassword)
            currentUser.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    currentUser.updatePassword(to: newPassword) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            self.profileVC?.txtFieldOldPassword.text = ""
                            self.profileVC?.txtFieldNewPassword.text = ""
                            self.profileVC?.txtFieldNewPasswordAgain.text = ""
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
        if let currentUser = Auth.auth().currentUser{
            if profileVC?.txtFieldName.text != ""{
                db.collection("users").document(currentUser.uid).updateData([
                    "name": profileVC?.txtFieldName.text as Any
                ]) { err in
                    if let err = err {
                        print("Hata oluştu: \(err)")
                    } else {
                        self.profileVC?.txtFieldName.placeholder = self.profileVC?.txtFieldName.text
                        self.profileVC?.txtFieldName.text = ""
                        print("Veri başarıyla güncellendi")
                    }
                }
            }
            if profileVC?.txtFieldEmail.text != ""{
                if let email = profileVC?.txtFieldEmail.text{
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
                                    self.profileVC?.txtFieldEmail.placeholder = self.profileVC?.txtFieldEmail.text
                                    self.profileVC?.txtFieldEmail.text = ""
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
        do {
            try Auth.auth().signOut()
            let homeVC = ViewController()
            homeVC.modalPresentationStyle = .fullScreen
            profileVC?.present(homeVC, animated: true)
        } catch let signOutError as NSError {
            print(signOutError.localizedDescription)
        }
    }
    
    func getUserProfilePhotoURL(completion: @escaping (String) -> Void) {
        if let currentUser = Auth.auth().currentUser{
            let documentRef = db.collection("users").document(currentUser.uid)
            documentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let userData = document.data()
                    var profilePhoto = userData?["profilePhoto"] as? String ?? ""
                    completion(profilePhoto)
                }
            }
        }
    }
}
