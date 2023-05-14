//
//  ProfileViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 16.03.2023.
//

import UIKit
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: -Define
    
    let imgProfilePhoto: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.layer.cornerRadius = imgView.frame.size.width / 2
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let lblUsername: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Edit Profile"
        lbl.font = UIFont(name: "Futura", size: 16)
        return lbl
    }()
    
    let txtFieldName: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "Name Surname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        txtField.tintColor = .black
        txtField.textColor = .black
        txtField.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.98, alpha: 1.00)
        txtField.layer.cornerRadius = 5
        txtField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        txtField.layer.borderWidth = 1
        return txtField
    }()
    
    let txtFieldEmail: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "E-mail", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        txtField.tintColor = .black
        txtField.textColor = .black
        txtField.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.98, alpha: 1.00)
        txtField.layer.cornerRadius = 5
        txtField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        txtField.layer.borderWidth = 1
        return txtField
    }()
    
    private let btnUpdateNameOrEmail: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        btn.setTitle("Update My Info", for: .normal)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let lblChangePassword: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Change Password"
        lbl.font = UIFont(name: "Futura", size: 16)
        return lbl
    }()
    
    let txtFieldOldPassword: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "Old Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        txtField.tintColor = .black
        txtField.textColor = .black
        txtField.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.98, alpha: 1.00)
        txtField.layer.cornerRadius = 5
        txtField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        txtField.layer.borderWidth = 1
        txtField.isSecureTextEntry = true
        return txtField
    }()
    
    let txtFieldNewPassword: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        txtField.tintColor = .black
        txtField.textColor = .black
        txtField.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.98, alpha: 1.00)
        txtField.layer.cornerRadius = 5
        txtField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        txtField.layer.borderWidth = 1
        txtField.isSecureTextEntry = true
        return txtField
    }()
    
    let txtFieldNewPasswordAgain: UITextField = {
        let txtField = RightAlignedTextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.attributedPlaceholder = NSAttributedString(string: "New Password Again", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        txtField.tintColor = .black
        txtField.textColor = .black
        txtField.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.98, alpha: 1.00)
        txtField.layer.cornerRadius = 5
        txtField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        txtField.layer.borderWidth = 1
        txtField.isSecureTextEntry = true
        return txtField
    }()
    
    private let btnUpdatePassword: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        btn.setTitle("Update Password", for: .normal)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let btnLogout: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor(red: 0.92, green: 0.22, blue: 0.21, alpha: 1.00)
        btn.setTitle("Logout", for: .normal)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let profileViewModel = ProfileViewModel()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        profileViewModel.profileVC = self
        
        profileViewModel.fetchData()
        setupViews()
    }
    
    
    func setupViews(){
        imgProfilePhoto.imgProfilePhotoConstraints(view)
        lblUsername.lblUsernameConstraints(view, imgProfilePhoto: imgProfilePhoto)
        txtFieldName.txtFieldNameConstraints(view, lblUsername: lblUsername)
        txtFieldEmail.txtFieldEmailConstraints(view, txtFieldName: txtFieldName)
        btnUpdateNameOrEmail.btnUpdateNameOrEmailConstraints(view, txtFieldEmail: txtFieldEmail)
        lblChangePassword.lblChangePasswordConstraints(view, btnUpdateNameOrEmail: btnUpdateNameOrEmail)
        txtFieldOldPassword.txtFieldOldPasswordConstraints(view, lblChangePassword: lblChangePassword)
        txtFieldNewPassword.txtFieldNewPasswordConstraints(view, txtFieldOldPassword: txtFieldOldPassword)
        txtFieldNewPasswordAgain.txtFieldNewPasswordAgainConstraints(view, txtFieldNewPassword: txtFieldNewPassword)
        btnUpdatePassword.btnUpdatePasswordConstraints(view, txtFieldNewPasswordAgain: txtFieldNewPasswordAgain)
        btnLogout.btnLogoutConstraints(view, btnUpdatePassword: btnUpdatePassword)
        
        btnUpdateNameOrEmail.addTarget(self, action: #selector(btnUpdateNameOrEmailTarget), for: .touchUpInside)
        btnUpdatePassword.addTarget(self, action: #selector(btnUpdatePasswordTarget), for: .touchUpInside)
        btnLogout.addTarget(self, action: #selector(btnLogoutTarget), for: .touchUpInside)
        
        imgProfilePhoto.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
        imgProfilePhoto.addGestureRecognizer(gestureRecognizer)
        
        let endEditing = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(endEditing)
    }
    
    @objc func btnLogoutTarget(){
        profileViewModel.logout()
    }
    
    @objc func selectPhoto(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func btnUpdatePasswordTarget(){
        if txtFieldOldPassword.text != "", txtFieldNewPassword.text != "", txtFieldNewPasswordAgain.text != ""{
            if txtFieldNewPassword.text == txtFieldNewPasswordAgain.text{
                profileViewModel.updatePassword()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgProfilePhoto.image = info[.editedImage] as? UIImage
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        let id = UUID().uuidString
        
        if let data = imgProfilePhoto.image?.jpegData(compressionQuality: 0.5){
            let imageReference = mediaFolder.child("\(id).jpg")
            imageReference.putData(data) { StorageMetadata, error in
                if error != nil{
                    print(error?.localizedDescription as Any)
                } else{
                    imageReference.downloadURL { url, error in
                        if error == nil{
                            let imageUrl = url?.absoluteString
                            if let imageUrl = imageUrl{
                                self.profileViewModel.getUserProfilePhotoURL { oldPhotoURL in
                                    self.profileViewModel.updateProfilePhoto(imageUrl, oldImageURL: oldPhotoURL)
                                }
                            }
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }
    
    @objc func btnUpdateNameOrEmailTarget(){
        profileViewModel.updateNameOrEmail()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

private extension UIView{
    func imgProfilePhotoConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: 150).isActive = true
        heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func lblUsernameConstraints(_ view: UIView, imgProfilePhoto: UIImageView){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: imgProfilePhoto.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: imgProfilePhoto.bottomAnchor, constant: 20).isActive = true
    }
    
    func txtFieldNameConstraints(_ view: UIView, lblUsername: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblUsername.bottomAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: lblUsername.centerXAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    func txtFieldEmailConstraints(_ view: UIView, txtFieldName: UITextField){
        view.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldName.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: txtFieldName.centerXAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    func btnUpdateNameOrEmailConstraints(_ view: UIView, txtFieldEmail: UITextField){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: txtFieldEmail.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: txtFieldEmail.bottomAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    func lblChangePasswordConstraints(_ view: UIView, btnUpdateNameOrEmail: UIButton){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: btnUpdateNameOrEmail.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: btnUpdateNameOrEmail.bottomAnchor, constant: 15).isActive = true
    }
    
    func txtFieldOldPasswordConstraints(_ view: UIView, lblChangePassword: UILabel){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: lblChangePassword.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: lblChangePassword.bottomAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    func txtFieldNewPasswordConstraints(_ view: UIView, txtFieldOldPassword: UITextField){
        view.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldOldPassword.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: txtFieldOldPassword.centerXAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    func txtFieldNewPasswordAgainConstraints(_ view: UIView, txtFieldNewPassword: UITextField){
        view.addSubview(self)
        topAnchor.constraint(equalTo: txtFieldNewPassword.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: txtFieldNewPassword.centerXAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    func btnUpdatePasswordConstraints(_ view: UIView, txtFieldNewPasswordAgain: UITextField){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: txtFieldNewPasswordAgain.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: txtFieldNewPasswordAgain.bottomAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    func btnLogoutConstraints(_ view: UIView, btnUpdatePassword: UIButton){
        view.addSubview(self)
        topAnchor.constraint(equalTo: btnUpdatePassword.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: btnUpdatePassword.centerXAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
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
