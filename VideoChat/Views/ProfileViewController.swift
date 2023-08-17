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
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 50
        return view
    }()
    
    private lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Settings"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var userProfilePhoto: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "root-bg"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.clipsToBounds = true
        imgView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imgView.layer.cornerRadius = 30
        return imgView
    }()
    
    private lazy var labelUsername: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Harun DEMİRKAYA"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var buttonLogout: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        button.setTitle("Log Out", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.00)
        return view
    }()
    
    private var accountEditView = ProfileRow(iconImageName: "account-icon", labelNameText: "Account", labelDescriptionText: "Privacy, security, change number")
    
    private var chatEditView = ProfileRow(iconImageName: "chat-icon", labelNameText: "Chat", labelDescriptionText: "Chat history,theme,wallpapers")
    
    private var notificationEditView = ProfileRow(iconImageName: "notification-icon", labelNameText: "Notifications", labelDescriptionText: "Messages, group and others")
    
    private var helpEditView = ProfileRow(iconImageName: "help-icon", labelNameText: "Help", labelDescriptionText: "Help center,contact us, privacy policy")
    
    private var storageEditView = ProfileRow(iconImageName: "storage-icon", labelNameText: "Storage and data", labelDescriptionText: "Network usage, stogare usage")
    
    private var inviteEditView = ProfileRow(iconImageName: "invite-icon", labelNameText: "Invite a friend", labelDescriptionText: "Invite your friends to The First Date")
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    
    func setupViews(){
        let imageView = UIImageView(image: UIImage(named: "profile-bg"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let endEditing = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(endEditing)
        
        contentView.contentViewConstraints(view)
        labelTitle.labelTitleConstraints(view)
        userProfilePhoto.userProfilePhotoConstraints(contentView)
        labelUsername.labelUsernameConstraints(contentView, userProfilePhoto: userProfilePhoto)
        buttonLogout.buttonLogoutConstraints(contentView, labelUsername: labelUsername)
        divider.dividerConstraints(contentView, buttonLogout: buttonLogout)
        accountEditView.accountEditViewConstraints(contentView, divider: divider)
        chatEditView.otherEditViewConstraints(contentView, otherEditView: accountEditView)
        notificationEditView.otherEditViewConstraints(contentView, otherEditView: chatEditView)
        helpEditView.otherEditViewConstraints(contentView, otherEditView: notificationEditView)
        storageEditView.otherEditViewConstraints(contentView, otherEditView: helpEditView)
        inviteEditView.otherEditViewConstraints(contentView, otherEditView: storageEditView)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

private extension UIView{
    func contentViewConstraints(_ view: UIView){
        view.addSubview(self)
        heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.85).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
    }
    
    func labelTitleConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func userProfilePhotoConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
    }
    
    func labelUsernameConstraints(_ view: UIView, userProfilePhoto: UIImageView){
        view.addSubview(self)
        centerYAnchor.constraint(equalTo: userProfilePhoto.centerYAnchor).isActive = true
        leadingAnchor.constraint(equalTo: userProfilePhoto.trailingAnchor, constant: 12).isActive = true
    }
    
    func buttonLogoutConstraints(_ view: UIView, labelUsername: UILabel){
        view.addSubview(self)
        leadingAnchor.constraint(equalTo: labelUsername.trailingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        centerYAnchor.constraint(equalTo: labelUsername.centerYAnchor).isActive = true
    }
    
    func dividerConstraints(_ view: UIView, buttonLogout: UIButton){
        view.addSubview(self)
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 1).isActive = true
        topAnchor.constraint(equalTo: buttonLogout.bottomAnchor, constant: 30).isActive = true
    }
    
    func accountEditViewConstraints(_ view: UIView, divider: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 30).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func otherEditViewConstraints(_ view: UIView, otherEditView: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: otherEditView.bottomAnchor, constant: 30).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
