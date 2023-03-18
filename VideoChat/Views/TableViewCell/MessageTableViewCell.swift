//
//  MessageTableViewCell.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 18.03.2023.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    // Kullanıcının resmini göstermek için bir UIImageView oluşturun
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // Kullanıcının adını göstermek için bir UILabel oluşturun
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Mesajın kısa bir önizlemesini göstermek için bir UILabel oluşturun
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Hücre oluşturulduğunda çağrılan fonksiyon
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // UI bileşenlerini hücreye ekle
        addSubview(userImageView)
        addSubview(userNameLabel)
        addSubview(messageLabel)
        
        // Kullanıcı resmini sola hizala
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            userImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Kullanıcı adını ve mesajı sağa hizala
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 0),
            messageLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
