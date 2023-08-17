//
//  ProfileRow.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 15.07.2023.
//

import Foundation
import UIKit

class ProfileRow: UIView{
    
    // MARK: -Define
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return imageView
    }()
    
    private lazy var labelName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var labelDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.47, green: 0.49, blue: 0.48, alpha: 1.00)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    init(iconImageName: String, labelNameText: String, labelDescriptionText: String){
        super.init(frame: .zero)
        self.setupViews(iconImageName: iconImageName, labelNameText: labelNameText, labelDescriptionText: labelDescriptionText)
    }
    
    private func setupViews(iconImageName: String, labelNameText: String, labelDescriptionText: String) {
        backgroundColor = .clear
        
        translatesAutoresizingMaskIntoConstraints = false
        
        icon.image = UIImage(named: iconImageName)?.withTintColor(.white)
        labelName.text = labelNameText
        labelDescription.text = labelDescriptionText
        
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.9).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.06).isActive = true
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        addSubview(icon)
        icon.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(labelName)
        labelName.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12).isActive = true
        labelName.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
        
        addSubview(labelDescription)
        labelDescription.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12).isActive = true
        labelDescription.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 4).isActive = true
    }
}
