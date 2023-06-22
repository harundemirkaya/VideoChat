//
//  BusyNotification.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 3.05.2023.
//

import Foundation
import UIKit

class SmallNotification{
    
    // MARK: Define
    private let notificationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let lblDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private var btnOkey = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Okey", for: .normal)
        btn.backgroundColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 0.2
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    public func smallNotification(view: UIView?, notificationText: String){
        if let view = view{
            lblDescription.text = notificationText
            notificationView.notificationViewConstraints(view)
            lblDescription.lblDescriptionConstraints(notificationView)
            btnOkey.btnOkeyConstraints(notificationView, lblDescription: lblDescription)
            
            btnOkey.addTarget(self, action: #selector(btnOkeyTarget), for: .touchUpInside)
        }
    }
    
    // MARK: -Close Notification
    @objc func btnOkeyTarget(){
        notificationView.removeFromSuperview()
    }
}

private extension UIView{
    func notificationViewConstraints(_ view: UIView){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.15).isActive = true
    }
    
    func lblDescriptionConstraints(_ view: UIView){
        view.addSubview(self)
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func btnOkeyConstraints(_ view: UIView, lblDescription: UILabel){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.6).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
    }
}
