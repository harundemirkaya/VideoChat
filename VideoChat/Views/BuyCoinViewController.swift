//
//  BuyCoinViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 23.06.2023.
//

import UIKit
import StoreKit

class BuyCoinViewController: UIViewController {
    // MARK: -Define
    private lazy var pageTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Purchase Coins"
        lbl.textColor = .black
        return lbl
    }()
    
    private lazy var weeklySubscriptionSlider: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "weekly-slider"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.layer.cornerRadius = 15
        return imgView
    }()
    
    private lazy var lblCoinsTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Coins"
        lbl.textColor = .black
        return lbl
    }()
    
    private var litePackage = PackageButton(packageName: "Lite", coinText: "300 Coin", priceText: "5$", packageTextColor: .systemPurple, tag: 1)
    private var basicPackage = PackageButton(packageName: "Basic", coinText: "500 Coin", priceText: "8$", packageTextColor: .systemPink, tag: 2)
    private var weeklyPackage = PackageButton(packageName: "Weekly", coinText: "800 Coin", priceText: "5$", packageTextColor: .systemBrown, tag: 3)
    private var monthlyPackage = PackageButton(packageName: "Monthly", coinText: "1000 Coin", priceText: "9$", packageTextColor: .systemRed, tag: 4)
    
    // MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: -Functions
    private func setupViews(){
        view.backgroundColor = .white
        
        pageTitle.pageTitleConstraints(view)
        weeklySubscriptionSlider.weeklySubscriptionSliderConstraints(view, lblTitle: pageTitle)
        litePackage.litePackageConstraints(view, slider: weeklySubscriptionSlider)
        basicPackage.basicPackageConstraints(view, litePackageView: litePackage)
        weeklyPackage.weeklyPackageConstraints(view, litePackageView: litePackage)
        monthlyPackage.monthlyPackageConstraints(view, weeklyPackageView: weeklyPackage)
        lblCoinsTitle.lblCoinsTitleConstraints(view, litePackage: litePackage)
        
        litePackage.addTarget(self, action: #selector(packageTarget(_:)), for: .touchUpInside)
        basicPackage.addTarget(self, action: #selector(packageTarget(_:)), for: .touchUpInside)
        weeklyPackage.addTarget(self, action: #selector(packageTarget(_:)), for: .touchUpInside)
        monthlyPackage.addTarget(self, action: #selector(packageTarget(_:)), for: .touchUpInside)
        
    }
    
    @objc private func packageTarget(_ sender: UIButton){
        switch sender.tag{
        case 1:
            IAPManager.shared.purchase(product: .litepackage1)
        case 2:
            break
            /// TO DO
        case 3:
            break
            /// TO DO
        case 4:
            break
            /// TO DO
        default:
            break
        }
    }
}

private extension UIView{
    func pageTitleConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func weeklySubscriptionSliderConstraints(_ view: UIView, lblTitle: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 30).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.9).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.1).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func litePackageConstraints(_ view: UIView, slider: UIImageView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 60).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.4).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.2).isActive = true
    }
    
    func basicPackageConstraints(_ view: UIView, litePackageView: UIView){
        view.addSubview(self)
        centerYAnchor.constraint(equalTo: litePackageView.centerYAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.4).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.2).isActive = true
    }
    
    func weeklyPackageConstraints(_ view: UIView, litePackageView: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: litePackageView.bottomAnchor, constant: 20).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.4).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.2).isActive = true
    }
    
    func monthlyPackageConstraints(_ view: UIView, weeklyPackageView: UIView){
        view.addSubview(self)
        centerYAnchor.constraint(equalTo: weeklyPackageView.centerYAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.4).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.2).isActive = true
    }
    
    func lblCoinsTitleConstraints(_ view: UIView, litePackage: UIView){
        view.addSubview(self)
        bottomAnchor.constraint(equalTo: litePackage.topAnchor, constant: -10).isActive = true
        leadingAnchor.constraint(equalTo: litePackage.leadingAnchor, constant: 5).isActive = true
    }
}
