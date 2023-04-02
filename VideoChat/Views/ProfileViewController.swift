//
//  ProfileViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 16.03.2023.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: -Define
    
    private let imgProfilePhoto: UIImageView = {
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
        lbl.text = "John Doe"
        lbl.font = UIFont(name: "Futura", size: 16)
        return lbl
    }()
    
    private let txtFieldName: UITextField = {
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
    
    private let txtFieldEmail: UITextField = {
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
    
    private let txtFieldOldPassword: UITextField = {
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
    
    private let txtFieldNewPassword: UITextField = {
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
    
    private let txtFieldNewPasswordAgain: UITextField = {
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
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        fetchData()
        setupViews()
    }
    
    func fetchData(){
        if let currentUser = Auth.auth().currentUser{
            let db = Firestore.firestore()
            db.collection("users").document(currentUser.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    self.txtFieldName.placeholder = data!["name"] as? String
                    self.txtFieldEmail.placeholder = data!["email"] as? String
                    let urlString = data!["profilePhoto"] as? String
                    if let url = URL(string: urlString!){
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                                guard let data = data, error == nil else {
                                    print("Error loading image: \(error?.localizedDescription ?? "unknown error")")
                                    return
                                }
                                DispatchQueue.main.async {
                                    self.imgProfilePhoto.image = UIImage(data: data)
                                }
                            }.resume()
                    }
                } else {
                    print("Belge mevcut değil")
                }
            }
            
        }
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
        
        btnUpdateNameOrEmail.addTarget(self, action: #selector(btnUpdateNameOrEmailTarget), for: .touchUpInside)
        
        imgProfilePhoto.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
        imgProfilePhoto.addGestureRecognizer(gestureRecognizer)
        
        let endEditing = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(endEditing)
    }
    
    @objc func selectPhoto(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgProfilePhoto.image = info[.editedImage] as? UIImage
        picker.dismiss(animated: true)
    }
    
    @objc func btnUpdateNameOrEmailTarget(){
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
                                let fireStoreDB = Firestore.firestore()
                                if let currentUser = Auth.auth().currentUser{
                                    fireStoreDB.collection("users").document(currentUser.uid).updateData([
                                        "profilePhoto": imageUrl
                                    ]) { err in
                                        if let err = err {
                                            print("Hata oluştu: \(err)")
                                        } else {
                                            print("Veri başarıyla güncellendi")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
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
