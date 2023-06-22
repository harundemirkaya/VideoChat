//
//  SelectGender.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 22.06.2023.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SelectGenderPopUp{
    // MARK: -Define
    private lazy var selectGenderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var btnFemale: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.cornerRadius = 10
        
        let imageView = UIImageView(image: UIImage(named: "female-icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Female"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: btn.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: btn.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: btn.trailingAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: btn.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: btn.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: btn.bottomAnchor)
        ])
        
        btn.addTarget(self, action: #selector(btnGenderTarget(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var btnMale: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.cornerRadius = 10
        
        let imageView = UIImageView(image: UIImage(named: "male-icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Male"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: btn.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: btn.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: btn.trailingAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: btn.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: btn.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: btn.bottomAnchor)
        ])
        
        btn.addTarget(self, action: #selector(btnGenderTarget(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var btnBoth: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.cornerRadius = 10
        
        let imageView = UIImageView(image: UIImage(named: "both-icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Both"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: btn.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: btn.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: btn.trailingAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: btn.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: btn.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: btn.bottomAnchor)
        ])
        
        btn.addTarget(self, action: #selector(btnGenderTarget(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var lblFemalePrice: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "13"
        
        let iconImageView = UIImageView(image: UIImage(named: "coin-icon"))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        lbl.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: lbl.trailingAnchor, constant: 5),
            iconImageView.centerYAnchor.constraint(equalTo: lbl.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return lbl
    }()
    
    private lazy var lblMalePrice: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "13"
        
        let iconImageView = UIImageView(image: UIImage(named: "coin-icon"))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        lbl.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: lbl.trailingAnchor, constant: 5),
            iconImageView.centerYAnchor.constraint(equalTo: lbl.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return lbl
    }()
    
    private lazy var lblBothPrice: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Free"
        
        let iconImageView = UIImageView(image: UIImage(named: "coin-icon"))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        lbl.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: lbl.trailingAnchor, constant: 5),
            iconImageView.centerYAnchor.constraint(equalTo: lbl.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return lbl
    }()
    
    private lazy var btnSelect: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .primary()
        btn.layer.cornerRadius = 20
        btn.setTitle("Select", for: .normal)
        btn.addTarget(self, action: #selector(btnSelectTarget), for: .touchUpInside)
        return btn
    }()
    
    private lazy var selectedTarget = "both"
    
    private lazy var smallNotification = SmallNotification()
    
    private var mainView: UIView?
    
    // MARK: -Functions
    public func selectGenderPopUpOpen(view: UIView?, target: String){
        if let view = view{
            self.mainView = view
            
            selectGenderView.selectGenderViewConstraints(view)
            btnFemale.btnFemaleConstraints(selectGenderView)
            btnMale.btnMaleConstraints(selectGenderView, btnFemale: btnFemale)
            btnBoth.btnBothConstraints(selectGenderView, btnMale: btnMale)
            lblFemalePrice.lblPriceConstraints(selectGenderView, btn: btnFemale)
            lblMalePrice.lblPriceConstraints(selectGenderView, btn: btnMale)
            lblBothPrice.lblPriceConstraints(selectGenderView, btn: btnBoth)
            btnSelect.btnSelectConstraints(selectGenderView, lbl: lblBothPrice)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.selectGenderView.transform = CGAffineTransform(translationX: 0, y: -350)
            })
            
            self.changeButton(target)
        }
    }
    
    private func changeButton(_ target: String){
        switch target{
        case "both":
            btnGenderTarget(btnBoth)
        case "female":
            btnGenderTarget(btnFemale)
        case "male":
            btnGenderTarget(btnMale)
        default:
            break
        }
    }
    
    @objc private func btnGenderTarget(_ sender: UIButton){
        if sender == btnFemale{
            btnFemale.layer.borderWidth = 3
            btnFemale.layer.borderColor = UIColor.primary().cgColor
            selectedTarget = "female"
            
            btnMale.layer.borderWidth = 1
            btnMale.layer.borderColor = UIColor.black.cgColor
            btnBoth.layer.borderWidth = 1
            btnBoth.layer.borderColor = UIColor.black.cgColor
        } else if sender == btnMale{
            btnMale.layer.borderWidth = 3
            btnMale.layer.borderColor = UIColor.primary().cgColor
            selectedTarget = "male"
            
            btnFemale.layer.borderWidth = 1
            btnFemale.layer.borderColor = UIColor.black.cgColor
            btnBoth.layer.borderWidth = 1
            btnBoth.layer.borderColor = UIColor.black.cgColor
        } else{
            btnBoth.layer.borderWidth = 3
            btnBoth.layer.borderColor = UIColor.primary().cgColor
            selectedTarget = "both"
            
            btnFemale.layer.borderWidth = 1
            btnFemale.layer.borderColor = UIColor.black.cgColor
            btnMale.layer.borderWidth = 1
            btnMale.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @objc private func btnSelectTarget(){
        if let currentUser = Auth.auth().currentUser{
            let userCollection = Firestore.firestore().collection("users").document(currentUser.uid)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var userCoin = userData?["coin"] as? Int ?? 0
                    if let price = Int(self.lblFemalePrice.text ?? "0"){
                        if userCoin >= price{
                            userCollection.updateData([
                                "target": self.selectedTarget
                            ]) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                } else{
                                    self.changeButton(self.selectedTarget)
                                    self.closePopUp()
                                }
                            }
                        } else{
                            if let mainView = self.mainView{
                                self.smallNotification.smallNotification(view: mainView, notificationText: "Insufficient Balance")
                                self.closePopUp()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func closePopUp(){
        UIView.animate(withDuration: 0.5, animations: {
            self.selectGenderView.transform = CGAffineTransform(translationX: 0, y: 350)
        }){ _ in
            self.selectGenderView.removeFromSuperview()
        }
    }
}

private extension UIView{
    func selectGenderViewConstraints(_ view: UIView){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        heightAnchor.constraint(equalToConstant: 350).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func btnFemaleConstraints(_ view: UIView){
        view.addSubview(self)
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    }
    
    func btnMaleConstraints(_ view: UIView, btnFemale: UIButton){
        view.addSubview(self)
        leadingAnchor.constraint(equalTo: btnFemale.trailingAnchor, constant: 30).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    }
    
    func btnBothConstraints(_ view: UIView, btnMale: UIButton){
        view.addSubview(self)
        leadingAnchor.constraint(equalTo: btnMale.trailingAnchor, constant: 30).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    }
    
    func lblPriceConstraints(_ view: UIView, btn: UIButton){
        view.addSubview(self)
        topAnchor.constraint(equalTo: btn.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: btn.centerXAnchor, constant: -5).isActive = true
    }
    
    func btnSelectConstraints(_ view: UIView, lbl: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lbl.bottomAnchor, constant: 20).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
}
