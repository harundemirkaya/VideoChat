//
//  LoginViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 2.03.2023.
//

import UIKit

class LoginViewController: UIViewController {

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
        lbl.text = "Welcome back!\nGlad to see you, Again!"
        lbl.font = .boldSystemFont(ofSize: 30)
        lbl.numberOfLines = 0
        lbl.textColor = .black
        return lbl
    }()
    
    let lblRedirectRegister: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setDoubleFont(text1: "Don’t have an account?", font1: .systemFont(ofSize: 15), color1: .black, text2: " Register Now", font2: .boldSystemFont(ofSize: 15), color2: .primary())
        lbl.numberOfLines = 0
        lbl.isUserInteractionEnabled = true
        return lbl
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
        txtField.isSecureTextEntry = true
        return txtField
    }()
    
    let btnLogin: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Login", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    let loginViewModel = LoginViewModel()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews(){
        view.backgroundColor = .white
        loginViewModel.loginVC = self
        
        btnBack.btnBackConstraints(view)
        lblTitle.lblTitleConstraints(view, btnBack: btnBack)
        txtFieldEmail.txtFieldEmailConstraints(view, lblTitle: lblTitle)
        txtFieldPassword.txtFieldPasswordConstraints(view, txtFieldEmail: txtFieldEmail)
        btnLogin.btnLoginConstraints(view, txtFieldPassword: txtFieldPassword)
        lblRedirectRegister.lblRedirectRegisterConstraints(view)
        
        btnBack.addTarget(self, action: #selector(btnBackTarget), for: .touchUpInside)
        btnLogin.addTarget(self, action: #selector(btnLoginTarget), for: .touchUpInside)
        txtFieldEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let tapGestureLabelRegister = UITapGestureRecognizer(target: self, action: #selector(pushToRegister))
        
        view.addGestureRecognizer(tapGestureView)
        lblRedirectRegister.addGestureRecognizer(tapGestureLabelRegister)
        
    }
    
    @objc private func btnBackTarget(){
        dismiss(animated: true)
    }
    
    @objc private func btnLoginTarget(){
        loginViewModel.login()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        txtFieldEmail.text = txtFieldEmail.text?.lowercased()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func pushToRegister(){
        let registerVC = RegisterViewController()
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
    
    func txtFieldEmailConstraints(_ view: UIView, lblTitle: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 52).isActive = true
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
    
    func btnLoginConstraints(_ view: UIView, txtFieldPassword: UITextField){
        view.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldPassword.bottomAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.89).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.07).isActive = true
    }
    
    func lblRedirectRegisterConstraints(_ view: UIView){
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
