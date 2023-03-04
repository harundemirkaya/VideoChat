//
//  RegisterViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 2.03.2023.
//

import UIKit

class RegisterViewController: UIViewController {

    // MARK: -Define
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let imgViewBG: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "register-bg"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    let btnBack: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Create Account"
        lbl.font = lbl.font.withSize(24)
        lbl.textColor = .white
        return lbl
    }()
    
    let txtFieldName: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "Name Surname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        txtField.tintColor = .white
        txtField.textColor = .white
        txtField.backgroundColor = .black.withAlphaComponent(0.20)
        txtField.layer.cornerRadius = 15
        txtField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        txtField.layer.borderWidth = 1
        return txtField
    }()
    
    let txtFieldEmail: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        txtField.tintColor = .white
        txtField.textColor = .white
        txtField.backgroundColor = .black.withAlphaComponent(0.20)
        txtField.layer.cornerRadius = 15
        txtField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        txtField.layer.borderWidth = 1
        return txtField
    }()
    
    let txtFieldPassword: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        txtField.tintColor = .white
        txtField.textColor = .white
        txtField.backgroundColor = .black.withAlphaComponent(0.20)
        txtField.layer.cornerRadius = 15
        txtField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        txtField.layer.borderWidth = 1
        return txtField
    }()
    
    let btnRegister: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Create Account", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.75, green: 0.35, blue: 0.95, alpha: 1.00)
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        return btn
    }()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        stackView.stackViewConstraints(view)
        imgViewBG.imgViewBGConstraints(stackView)
        btnBack.btnBackConstraints(stackView)
        lblTitle.lblTitleConstraints(stackView)
        txtFieldName.txtFieldNameConstraints(stackView, lblTitle: lblTitle, view: view)
        txtFieldEmail.txtFieldEmailConstraints(stackView, txtFieldName: txtFieldName, view: view)
        txtFieldPassword.txtFieldPasswordConstraints(stackView, txtFieldEmail: txtFieldEmail, view: view)
        btnRegister.btnRegisterConstraints(stackView, txtFieldPassword: txtFieldPassword, view: view)
        
        btnBack.addTarget(self, action: #selector(btnBackTarget), for: .touchUpInside)
    }
    
    @objc func btnBackTarget(){
        dismiss(animated: true)
    }
}

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
    
    func btnBackConstraints(_ stackView: UIStackView){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20).isActive = true
    }
    
    func lblTitleConstraints(_ stackView: UIStackView){
        stackView.addSubview(self)
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: stackView.centerYAnchor, constant: -100).isActive = true
    }
    
    func txtFieldNameConstraints(_ stackView: UIStackView, lblTitle: UILabel, view: UIView){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.85).isActive = true
        heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.06).isActive = true
    }
    
    func txtFieldEmailConstraints(_ stackView: UIStackView, txtFieldName: UITextField, view: UIView){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldName.bottomAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.85).isActive = true
        heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.06).isActive = true
    }
    
    func txtFieldPasswordConstraints(_ stackView: UIStackView, txtFieldEmail: UITextField, view: UIView){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldEmail.bottomAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.85).isActive = true
        heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.06).isActive = true
    }
    
    func btnRegisterConstraints(_ stackView: UIStackView, txtFieldPassword: UITextField, view: UIView){
        stackView.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldPassword.bottomAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.85).isActive = true
        heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.06).isActive = true
    }
}

// MARK: -TextField Padding Placeholder
class RightAlignedTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }
}
