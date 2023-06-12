//
//  ViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 2.03.2023.
//

import UIKit

class ViewController: UIViewController {

    // MARK: -Define
    
    private let imgViewBG: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "root-bg"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private let buttonLogin: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .primary()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let buttonRegister: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews(){
        view.backgroundColor = .white
        
        imgViewBG.imgViewBGConstraints(view)
        buttonRegister.buttonRegisterConstraints(view)
        buttonLogin.buttonLoginConstraints(view, buttonRegister: buttonRegister)
        
        buttonRegister.addTarget(self, action: #selector(buttonRegisterTarget), for: .touchUpInside)
        buttonLogin.addTarget(self, action: #selector(buttonLoginTarget), for: .touchUpInside)
    }
    
    @objc func buttonRegisterTarget(){
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true)
    }
    
    @objc func buttonLoginTarget(){
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
}

// MARK: -Constraints
private extension UIView{
    func imgViewBGConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func buttonRegisterConstraints(_ view: UIView){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.89).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.07).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    func buttonLoginConstraints(_ view: UIView, buttonRegister: UIButton){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.89).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.07).isActive = true
        centerXAnchor.constraint(equalTo: buttonRegister.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: buttonRegister.topAnchor, constant: -15).isActive = true
    }
}

// MARK: -Display HTML Functions
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
