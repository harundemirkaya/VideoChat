//
//  RegisterViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 9.04.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel{
    
    // MARK: RegisterVC Defined
    var registerVC: RegisterViewController?
    private let db = Firestore.firestore()
    
    func register(){
        guard let registerVC = registerVC else { return }
        if let email = registerVC.txtFieldEmail.text, let password = registerVC.txtFieldPassword.text, let name = registerVC.txtFieldName.text{
            var id = 0
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    registerVC.alertMessage(title: "Error", description: error.localizedDescription)
                } else {
                    let db = Firestore.firestore()
                    db.collection("usersID").document("XnRPhVQEm9NtD8vHuQ8b").getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let myValue = data!["id"]
                            id = myValue as! Int
                            let user = Auth.auth().currentUser
                            if let user = user {
                                db.collection("users").document(user.uid).setData([
                                    "id": id,
                                    "name": name,
                                    "email": email,
                                    "gender": "Male",
                                    "coin": 0,
                                    "target": "Both"
                                ]) { error in
                                    if let error = error {
                                        registerVC.alertMessage(title: "Error", description: error.localizedDescription)
                                    } else {
                                        db.collection("usersID").document("XnRPhVQEm9NtD8vHuQ8b").updateData([
                                            "id": id + 1
                                        ]) { err in
                                            if let err = err {
                                                print("Hata oluştu: \(err)")
                                            } else {
                                                print("Veri başarıyla güncellendi")
                                            }
                                        }
                                        let appTabBar = AppTabBarController()
                                        appTabBar.modalPresentationStyle = .fullScreen
                                        registerVC.present(appTabBar, animated: true)
                                    }
                                }
                            }
                        } else {
                            print("Belge mevcut değil")
                        }
                    }
                }
            }
        }
    }
}
