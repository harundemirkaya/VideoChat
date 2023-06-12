//
//  RegisterViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 2.03.2023.
//

import UIKit

class RegisterViewController: UIViewController {

    // MARK: -Define
    let btnBack: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "btn-back"), for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Hello! Register to Get\nStarted"
        lbl.font = .boldSystemFont(ofSize: 30)
        lbl.numberOfLines = 0
        lbl.textColor = .black
        return lbl
    }()
    
    let lblRedirectLogin: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setDoubleFont(text1: "Already have an account?", font1: .systemFont(ofSize: 15), color1: .black, text2: " Login Now", font2: .boldSystemFont(ofSize: 15), color2: .primary())
        lbl.numberOfLines = 0
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    let txtFieldName: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "Name Surname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        txtField.textColor = .black
        txtField.backgroundColor = .textfieldBG()
        txtField.layer.cornerRadius = 8
        txtField.layer.borderColor = UIColor.borderGray().cgColor
        txtField.layer.borderWidth = 1
        return txtField
    }()
    
    let txtFieldEmail: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        txtField.textColor = .black
        txtField.backgroundColor = .textfieldBG()
        txtField.layer.cornerRadius = 8
        txtField.layer.borderColor = UIColor.borderGray().cgColor
        txtField.layer.borderWidth = 1
        return txtField
    }()
    
    let txtFieldPassword: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        txtField.textColor = .black
        txtField.backgroundColor = .textfieldBG()
        txtField.layer.cornerRadius = 8
        txtField.layer.borderColor = UIColor.borderGray().cgColor
        txtField.layer.borderWidth = 1
        return txtField
    }()
    
    let btnRegister: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    let registerViewModel = RegisterViewModel()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        registerViewModel.registerVC = self
        
        btnBack.btnBackConstraints(view)
        lblTitle.lblTitleConstraints(view, btnBack: btnBack)
        txtFieldName.txtFieldNameConstraints(view, lblTitle: lblTitle)
        txtFieldEmail.txtFieldEmailConstraints(view, txtFieldName: txtFieldName)
        txtFieldPassword.txtFieldPasswordConstraints(view, txtFieldEmail: txtFieldEmail)
        btnRegister.btnRegisterConstraints(view, txtFieldPassword: txtFieldPassword)
        lblRedirectLogin.lblRedirectLoginConstraints(view)
        
        btnBack.addTarget(self, action: #selector(btnBackTarget), for: .touchUpInside)
        btnRegister.addTarget(self, action: #selector(btnRegisterTarget), for: .touchUpInside)
        txtFieldEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let tapGestureLabelLogin = UITapGestureRecognizer(target: self, action: #selector(pushToLogin))
        
        view.addGestureRecognizer(tapGestureView)
        lblRedirectLogin.addGestureRecognizer(tapGestureLabelLogin)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func btnBackTarget(){
        dismiss(animated: true)
    }
    
    @objc func btnRegisterTarget(){
        registerViewModel.register()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        txtFieldEmail.text = txtFieldEmail.text?.lowercased()
    }
    
    @objc private func pushToLogin(){
        let registerVC = LoginViewController()
        registerVC.modalPresentationStyle = .fullScreen
        self.present(registerVC, animated: true)
    }
    
    // MARK: -Show Alert Message
    func alertMessage(title: String, description: String){
        let alertMessage = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Okey", style: UIAlertAction.Style.default)
        alertMessage.addAction(okButton)
        alertMessage.isAccessibilityElement = true
        alertMessage.accessibilityHint = description
        self.present(alertMessage, animated: true)
    }
}

private extension UIView{
    func btnBackConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        widthAnchor.constraint(equalToConstant: 44).isActive = true
        heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func lblTitleConstraints(_ view: UIView, btnBack: UIButton){
        view.addSubview(self)
        topAnchor.constraint(equalTo: btnBack.bottomAnchor, constant: 30).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    func txtFieldNameConstraints(_ view: UIView, lblTitle: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 52).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.89).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.07).isActive = true
    }
    
    func txtFieldEmailConstraints(_ view: UIView, txtFieldName: UITextField){
        view.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldName.bottomAnchor, constant: 15).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.89).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.07).isActive = true
    }
    
    func txtFieldPasswordConstraints(_ view: UIView, txtFieldEmail: UITextField){
        view.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldEmail.bottomAnchor, constant: 15).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.89).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.07).isActive = true
    }
    
    func btnRegisterConstraints(_ view: UIView, txtFieldPassword: UITextField){
        view.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldPassword.bottomAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.89).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.07).isActive = true
    }
    
    func lblRedirectLoginConstraints(_ view: UIView){
        view.addSubview(self)
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -26).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

// MARK: -TextField Padding Placeholder
private class RightAlignedTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }
}
