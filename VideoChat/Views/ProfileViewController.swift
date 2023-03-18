//
//  ProfileViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 16.03.2023.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: -Define
    
    // MARK: Views Defined
    var topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemPink
        return view
    }()
    
    // MARK: Buttons Defined
    var btnProfilePhoto: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "coin"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.cornerRadius = btn.frame.width / 2
        btn.clipsToBounds = true
        return btn
    }()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    func setupViews(){
        topView.topViewConstraints(view)
        btnProfilePhoto.btnProfilePhotoConstraints(topView)
    }
}

private extension UIView{
    func topViewConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200).isActive = true
    }
    
    func btnProfilePhotoConstraints(_ view: UIView){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: 160).isActive = true
        heightAnchor.constraint(equalToConstant: 160).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
    }
}
