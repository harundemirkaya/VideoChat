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
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let buttonRegister: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let lblBigTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setDoubleFont(text1: "Connect\nfriends", font1: .systemFont(ofSize: 68), color1: .white, text2: "\neasily &\nquickly", font2: .boldSystemFont(ofSize: 68), color2: .white)
        label.numberOfLines = 0
        return label
    }()
    
    private let lblSmallTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Our chat app is the perfect way to stay connected with friends and family."
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = UIColor(red: 0.73, green: 0.76, blue: 0.75, alpha: 1.00)
        return label
    }()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews(){
        view.backgroundColor = .white
        
        imgViewBG.imgViewBGConstraints(view)
        lblBigTitle.lblBigTitleConstraints(view)
        lblSmallTitle.lblSmallTitleConstraints(view, lblBigTitle: lblBigTitle)
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
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.05).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    func buttonLoginConstraints(_ view: UIView, buttonRegister: UIButton){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.89).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.05).isActive = true
        centerXAnchor.constraint(equalTo: buttonRegister.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: buttonRegister.topAnchor, constant: -15).isActive = true
    }
    
    func lblBigTitleConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
    }
    
    func lblSmallTitleConstraints(_ view: UIView, lblBigTitle: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblBigTitle.bottomAnchor, constant: 20).isActive = true
        leadingAnchor.constraint(equalTo: lblBigTitle.leadingAnchor).isActive = true
        trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -30).isActive = true
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
