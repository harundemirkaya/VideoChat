//
//  LoginViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 9.04.2023.
//

import Foundation
import FirebaseAuth

class LoginViewModel{
    
    // MARK: LoginVC Defined
    var loginVC: LoginViewController?
    
    func login(){
        guard let loginVC = loginVC else { return }
        Auth.auth().signIn(withEmail: loginVC.txtFieldEmail.text ?? "", password: loginVC.txtFieldPassword.text ?? "") { authResult, error in
            if error != nil {
                loginVC.alertMessage(title: "Error", description: error?.localizedDescription ?? "Error")
                return
            }
            let appTabBar = AppTabBarController()
            appTabBar.modalPresentationStyle = .fullScreen
            loginVC.present(appTabBar, animated: true)
        }
    }
}
