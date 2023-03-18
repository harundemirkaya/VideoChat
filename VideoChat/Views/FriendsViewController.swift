//
//  FriendsViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 18.03.2023.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: -Define
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "My Friends"
        return lbl
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var btnBack: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        return btn
    }()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    private func setupViews(){
        lblTitle.lblTitleConstraints(view)
        btnBack.btnBackConstraints(view)
        tableView.tableViewConstraints(view, lblTitle: lblTitle)
        
        tableView.register(FriendsTableViewCell.self, forCellReuseIdentifier: "FriendsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        btnBack.addTarget(self, action: #selector(btnBackTarget), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        
        // Kullanıcı resmini ve adını ayarla
        cell.userImageView.image = UIImage(systemName: "person")
        cell.userNameLabel.text = "John Doe"
        
        return cell
    }
    
    @objc private func btnBackTarget(){
        self.dismiss(animated: true)
    }
}

private extension UIView{
    func lblTitleConstraints(_ view: UIView){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    }
    
    func btnBackConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    }
    
    func tableViewConstraints(_ view: UIView, lblTitle: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
