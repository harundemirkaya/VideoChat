//
//  FriendsRequestsTableViewCell.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 23.03.2023.
//

import UIKit

class FriendsRequestsTableViewCell: UITableViewCell {

    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let btnDelete: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = UIColor(red: 0.92, green: 0.22, blue: 0.21, alpha: 1.00)
        return btn
    }()
    
    let btnConfirm: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        return btn
    }()
    
    let imgConfirm: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    let imgDelete: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(btnDelete)
        contentView.addSubview(btnConfirm)
        btnConfirm.addSubview(imgConfirm)
        btnDelete.addSubview(imgDelete)
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            userImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50),
            
            userNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            userNameLabel.trailingAnchor.constraint(equalTo: btnDelete.leadingAnchor, constant: -5),
            
            btnConfirm.centerYAnchor.constraint(equalTo: centerYAnchor),
            btnConfirm.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            btnConfirm.widthAnchor.constraint(equalToConstant: 64),
            btnConfirm.heightAnchor.constraint(equalToConstant: 64),
            
            imgConfirm.centerXAnchor.constraint(equalTo: btnConfirm.centerXAnchor),
            imgConfirm.centerYAnchor.constraint(equalTo: btnConfirm.centerYAnchor),
            imgConfirm.widthAnchor.constraint(equalTo: btnConfirm.widthAnchor, multiplier: 0.6),
            imgConfirm.heightAnchor.constraint(equalTo: btnConfirm.heightAnchor, multiplier: 0.6),
            
            btnDelete.centerYAnchor.constraint(equalTo: centerYAnchor),
            btnDelete.trailingAnchor.constraint(equalTo: btnConfirm.leadingAnchor, constant: -5),
            btnDelete.widthAnchor.constraint(equalToConstant: 64),
            btnDelete.heightAnchor.constraint(equalToConstant: 64),
            
            imgDelete.centerXAnchor.constraint(equalTo: btnDelete.centerXAnchor),
            imgDelete.centerYAnchor.constraint(equalTo: btnDelete.centerYAnchor),
            imgDelete.widthAnchor.constraint(equalTo: btnDelete.widthAnchor, multiplier: 0.6),
            imgDelete.heightAnchor.constraint(equalTo: btnDelete.heightAnchor, multiplier: 0.6),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
