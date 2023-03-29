//
//  MessageChatTableViewCell.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 29.03.2023.
//

import UIKit

class MessageChatTableViewCell: UITableViewCell {

    var message: Message? {
        didSet {
            configure()
        }
    }
    
    let messageView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    var isCurrentUser: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(messageView)
        messageView.addSubview(messageLabel)
        
        leadingConstraint = messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            leadingConstraint,
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 16),
            messageLabel.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let message = message else { return }
        messageLabel.text = message.message
        
        if isCurrentUser {
            messageView.backgroundColor = UIColor(red: 0.5, green: 0.8, blue: 1, alpha: 1)
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        } else {
            messageView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
        }
    }
    
}
