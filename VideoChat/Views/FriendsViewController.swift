//
//  FriendsViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 18.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
        btn.setImage(UIImage(named: "btn-back"), for: .normal)
        return btn
    }()
    
    private var userFriendsID: [String] = []{
        didSet{
            getFriends()
        }
    }
    
    private var userFriends: [User] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        getFriendsID()
        setupViews()
    }
    
    private func getFriendsID(){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    let friendsRequests = userData?["friends"] as? [String] ?? []
                    self.userFriendsID = friendsRequests
                }
            }
        }
    }
    
    private func getFriends(){
        if userFriendsID != []{
            let db = Firestore.firestore()
            let users = db.collection("users")
            for userID in userFriendsID{
                let user = users.document(userID)
                user.getDocument { userDocument, userError in
                    if let userDocument = userDocument, userDocument.exists{
                        let userData = userDocument.data()
                        let name = userData?["name"] as! String
                        self.userFriends.append(User(userName: name, uid: userID))
                        
                    }
                }
            }
        }
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
        return userFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        
        cell.userImageView.image = UIImage(systemName: "person")
        cell.userNameLabel.text = userFriends[indexPath.row].userName
        
        return cell
    }
    
    @objc private func btnBackTarget(){
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageChatVC = MessageChatViewController()
        messageChatVC.modalPresentationStyle = .fullScreen
        messageChatVC.remoteUser.userName = userFriends[indexPath.row].userName
        messageChatVC.remoteUser.uid = userFriends[indexPath.row].uid
        present(messageChatVC, animated: true)
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
