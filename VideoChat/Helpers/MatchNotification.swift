//
//  MatchNotification.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 15.04.2023.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class MatchNotification{
    
    // MARK: Define
    private let notificationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let imgProfilePhoto: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.layer.cornerRadius = imgView.frame.size.width / 2
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let lblRemoteUserName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let lblDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Calling..."
        label.textColor = .white
        return label
    }()
    
    private var btnMatchReject = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Reject", for: .normal)
        btn.backgroundColor = UIColor(red: 0.92, green: 0.22, blue: 0.21, alpha: 1.00)
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 0.2
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    private var btnMatchConfirm = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Confirm", for: .normal)
        btn.backgroundColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 0.2
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    private let db = Firestore.firestore()
    
    private var remoteID = UInt(0)
    
    public func matchNotification(name: String?, view: UIView?, url: URL?, id: String?){
        if let name = name, let view = view, let url = url, let id = id{
            self.remoteID = UInt(id) ?? UInt(0)
            
            lblRemoteUserName.text = name
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data, error == nil else {
                        print("Error loading image: \(error?.localizedDescription ?? "unknown error")")
                        return
                    }
                    DispatchQueue.main.async {
                        self.imgProfilePhoto.image = UIImage(data: data)
                    }
                }.resume()
            
            notificationView.notificationViewConstraints(view)
            imgProfilePhoto.imgProfilePhotoConstraints(notificationView)
            lblRemoteUserName.lblRemoteUserNameConstraints(notificationView, imgView: imgProfilePhoto)
            lblDescription.lblDescriptionConstraints(view, lblUsername: lblRemoteUserName)
            btnMatchReject.btnMatchRejectConstraints(notificationView, lblDescription: lblDescription)
            btnMatchConfirm.btnMatchConfirmConstraints(notificationView, btnMatchReject: btnMatchReject)
            
            btnMatchConfirm.addTarget(self, action: #selector(btnMatchConfirmTarget), for: .touchUpInside)
            btnMatchReject.addTarget(self, action: #selector(btnMatchRejectTarget), for: .touchUpInside)
        }
    }
    
    @objc func btnMatchConfirmTarget(){
        NotificationCenter.default.post(name: NSNotification.Name("customCall"), object: nil, userInfo: ["remoteUserID":remoteID])
        self.btnMatchRejectTarget()
    }
    
    @objc func btnMatchRejectTarget(){
        notificationView.removeFromSuperview()
        if let currentUser = Auth.auth().currentUser{
            let userCollection = db.collection("users").document(currentUser.uid)
            userCollection.getDocument { (document, error) in
                if let document = document, document.exists {
                    userCollection.updateData([
                        "matchRequest": FieldValue.delete()
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

private extension UIView{
    func notificationViewConstraints(_ view: UIView){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.35).isActive = true
    }
    
    func imgProfilePhotoConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: 150).isActive = true
        heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func lblRemoteUserNameConstraints(_ view: UIView, imgView: UIImageView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 5).isActive = true
        centerXAnchor.constraint(equalTo: imgView.centerXAnchor).isActive = true
    }
    
    func lblDescriptionConstraints(_ view: UIView, lblUsername: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblUsername.bottomAnchor, constant: 1).isActive = true
        centerXAnchor.constraint(equalTo: lblUsername.centerXAnchor).isActive = true
    }
    
    func btnMatchRejectConstraints(_ view: UIView, lblDescription: UILabel){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: 130).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
    }
    
    func btnMatchConfirmConstraints(_ view: UIView, btnMatchReject: UIButton){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: 130).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        centerYAnchor.constraint(equalTo: btnMatchReject.centerYAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
    }
}
