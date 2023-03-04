//
//  ViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 2.03.2023.
//

import UIKit

class ViewController: UIViewController {

    // MARK: -Define
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let imgViewBG: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "root-bg"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Explore Together"
        lbl.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        return lbl
    }()
    
    let lblSubTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Create an account to run wild through our curated experiences."
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    
    let btnGoogleLogin: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Continue with Google", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        return btn
    }()
    
    let btnAppleLogin: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Continue with Apple", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        return btn
    }()
    
    let btnEmailLogin: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Continue with Email", for: .normal)
        btn.setImage(UIImage(systemName: "envelope"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        return btn
    }()
    
    let lblLogin: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.attributedText = "Already have an account? <b>Log in.</b>".htmlToAttributedString
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        stackView.stackViewConstraints(view)
        imgViewBG.imgViewBGConstraints(stackView)
        lblTitle.lblTitleConstraints(stackView)
        lblSubTitle.lblSubTitleConstraints(stackView, lblTitle: lblTitle)
        btnGoogleLogin.btnGoogleLoginConstraints(stackView, lblSubTitle: lblSubTitle, view: view)
        btnAppleLogin.btnOtherLoginConstraints(stackView, btn: btnGoogleLogin, view: view)
        btnEmailLogin.btnOtherLoginConstraints(stackView, btn: btnAppleLogin, view: view)
        lblLogin.lblLogin(stackView, btn: btnEmailLogin)
        
        btnEmailLogin.addTarget(self, action: #selector(btnEmailLoginTarget), for: .touchUpInside)
        
        let tapLoginLabel = UITapGestureRecognizer(target: self, action: #selector(lblLoginTarget))
        lblLogin.addGestureRecognizer(tapLoginLabel)
    }
    
    @objc func btnEmailLoginTarget(){
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true)
    }
    
    @objc func lblLoginTarget(){
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
}

// MARK: -Constraints
private extension UIView{
    func stackViewConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func imgViewBGConstraints(_ stackView: UIStackView){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
    }
    
    func lblTitleConstraints(_ stackView: UIStackView){
        stackView.addSubview(self)
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: stackView.centerYAnchor, constant: 50).isActive = true
    }
    
    func lblSubTitleConstraints(_ stackView: UIStackView, lblTitle: UILabel){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 5).isActive = true
        leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 50).isActive = true
        trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -50).isActive = true
    }
    
    func btnGoogleLoginConstraints(_ stackView: UIStackView, lblSubTitle: UILabel, view: UIView){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: lblSubTitle.bottomAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.85).isActive = true
        heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.06).isActive = true
    }
    
    func btnOtherLoginConstraints(_ stackView: UIStackView, btn: UIButton, view: UIView){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: btn.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.85).isActive = true
        heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.06).isActive = true
    }
    
    func lblLogin(_ stackView: UIStackView, btn: UIButton){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: btn.bottomAnchor, constant: 15).isActive = true
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
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
