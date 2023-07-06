//
//  PackageView.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 23.06.2023.
//

import Foundation
import UIKit

class PackageButton: UIButton{
    
    // MARK: -Define
    private lazy var lblPackageName: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .boldSystemFont(ofSize: 18)
        return lbl
    }()
    
    private lazy var coinImage: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "coin-icon"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private lazy var lblCoin: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var lblPrice: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    init(packageName: String, coinText: String, priceText: String, packageTextColor: UIColor = .black, coinTextColor: UIColor = .black, priceTextColor: UIColor = .black, tag: Int){
        super.init(frame: .zero)
        self.setupViews(lblPackageNameText: packageName, lblCoinText: coinText, lblPriceText: priceText, packageTextColor: packageTextColor, coinTextColor: coinTextColor, priceTextColor: priceTextColor, tag: tag)
    }
    
    private func setupViews(lblPackageNameText: String, lblCoinText: String, lblPriceText: String, packageTextColor: UIColor = .black, coinTextColor: UIColor = .black, priceTextColor: UIColor = .black, tag: Int){
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        isUserInteractionEnabled = true
        self.tag = tag
        
        lblPackageName.text = lblPackageNameText
        lblCoin.text = lblCoinText
        lblPrice.text = lblPriceText
        
        lblPackageName.textColor = packageTextColor
        lblCoin.textColor = coinTextColor
        lblPrice.textColor = priceTextColor
        
        lblPackageName.lblPackageNameConstraints(self)
        coinImage.coinImageConstraints(self, lblPackageName: lblPackageName)
        lblCoin.lblCoinConstraints(self, coinImage: coinImage)
        lblPrice.lblPriceConstraints(self, lblCoin: lblCoin)
    }
}

private extension UIView{
    func lblPackageNameConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func coinImageConstraints(_ view: UIView, lblPackageName: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblPackageName.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: 44).isActive = true
        heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func lblCoinConstraints(_ view: UIView, coinImage: UIImageView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: coinImage.bottomAnchor, constant: 15).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func lblPriceConstraints(_ view: UIView, lblCoin: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblCoin.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
