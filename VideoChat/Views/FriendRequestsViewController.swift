//
//  FriendRequestsViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 23.03.2023.
//

import UIKit

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: -Define
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Friend Requests"
        return lbl
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        return tableView
    }()
    
    private var btnBack: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "btn-back"), for: .normal)
        return btn
    }()
    
    var userFriendsRequests = [String](){
        didSet{
            friendRequestsViewModel.setRequests()
        }
    }
    
    var users = [User](){
        didSet{
            self.tableView.reloadData()
        }
    }
    
    private let imgEmptyData: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName : "person.crop.circle.fill.badge.plus"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.tintColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let lblEmptyData: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "You Do Not Have a Friend Request"
        lbl.font = UIFont(name: "Futura", size: 16)
        return lbl
    }()
    
    let friendRequestsViewModel = FriendRequestsViewModel()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        friendRequestsViewModel.friendRequestVC = self
        
        friendRequestsViewModel.getUserData()
        setupViews()
    }
    
    private func setupViews(){
        lblTitle.lblTitleConstraints(view)
        btnBack.btnBackConstraints(view)
        tableView.tableViewConstraints(view, lblTitle: lblTitle)
        
        tableView.register(FriendsRequestsTableViewCell.self, forCellReuseIdentifier: "FriendsRequestsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        imgEmptyData.imgEmptyData(view)
        lblEmptyData.lblEmptyData(view, imgView: imgEmptyData)
        imgEmptyData.isHidden = true
        lblEmptyData.isHidden = true
        
        btnBack.addTarget(self, action: #selector(btnBackTarget), for: .touchUpInside)
    }
    
    func reloadTableData(){
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
            if self.users.count == 0{
                self.imgEmptyData.isHidden = false
                self.lblEmptyData.isHidden = false
            } else{
                self.imgEmptyData.isHidden = true
                self.lblEmptyData.isHidden = true
            }
        }
        return  users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsRequestsTableViewCell", for: indexPath) as! FriendsRequestsTableViewCell
        if users.count != 0{
            friendRequestsViewModel.getProfileImage(withURL: users[indexPath.row].userPhoto) { image in
                DispatchQueue.main.async {
                    cell.imageView?.image = image
                    cell.imageView?.contentMode = .scaleAspectFit
                }
            }
            cell.userNameLabel.text = users[indexPath.row].userName
            cell.btnConfirm.tag = indexPath.row
            cell.btnDelete.tag = indexPath.row
            cell.btnConfirm.addTarget(self, action: #selector(btnConfirmTarget(sender:)), for: .touchUpInside)
            cell.btnDelete.addTarget(self, action: #selector(btnDeleteTarget(sender:)), for: .touchUpInside)
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = .clear
        }
        return cell
    }
    
    @objc private func btnConfirmTarget(sender: UIButton){
        friendRequestsViewModel.confirmRequest(sender)
    }
    
    @objc private func btnDeleteTarget(sender: UIButton){
        friendRequestsViewModel.removeRequest(sender)
    }
    
    @objc private func btnBackTarget(){
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
    }
    
    func tableViewConstraints(_ view: UIView, lblTitle: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func imgEmptyData(_ view: UIView){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: 80).isActive = true
        heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func lblEmptyData(_ view: UIView, imgView: UIImageView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 10).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
