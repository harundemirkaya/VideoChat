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
        Auth.auth().signIn(withEmail: loginVC?.txtFieldEmail.text ?? "", password: loginVC?.txtFieldPassword.text ?? "") { [weak self] authResult, error in
            guard self != nil else { return }
            if error != nil {
                self?.loginVC?.alertMessage(title: "Error", description: error?.localizedDescription ?? "Error")
                return
            }
            let appTabBar = AppTabBarController()
            appTabBar.modalPresentationStyle = .fullScreen
            self?.loginVC?.present(appTabBar, animated: true)
        }
    }
}
