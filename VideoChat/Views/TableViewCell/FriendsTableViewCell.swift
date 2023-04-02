//
//  MessageTableViewCell.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 18.03.2023.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
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
    
    let clickToChatLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click to Chat"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(userImageView)
        addSubview(userNameLabel)
        addSubview(clickToChatLabel)
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            userImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            clickToChatLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 0),
            clickToChatLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            clickToChatLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            clickToChatLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
