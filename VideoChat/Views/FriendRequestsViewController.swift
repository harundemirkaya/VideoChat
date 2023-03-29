//
//  FriendRequestsViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 23.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
        return tableView
    }()
    
    private var btnBack: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        return btn
    }()
    
    var userFriendsRequests = [String](){
        didSet{
            setRequests()
        }
    }
    
    var users = [User](){
        didSet{
            self.tableView.reloadData()
        }
    }
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        getUserData()
        setupViews()
    }
    
    private func setupViews(){
        lblTitle.lblTitleConstraints(view)
        btnBack.btnBackConstraints(view)
        tableView.tableViewConstraints(view, lblTitle: lblTitle)
        
        tableView.register(FriendsRequestsTableViewCell.self, forCellReuseIdentifier: "FriendsRequestsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        btnBack.addTarget(self, action: #selector(btnBackTarget), for: .touchUpInside)
    }
    
    private func getUserData(){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    let friendsRequests = userData?["friendsRequests"] as? [String] ?? []
                    self.userFriendsRequests = friendsRequests
                }
            }
        }
    }
    
    private func setRequests(){
        if userFriendsRequests.count != 0{
            let db = Firestore.firestore()
            let users = db.collection("users")
            for userID in userFriendsRequests{
                let user = users.document(userID)
                user.getDocument { userDocument, userError in
                    if let userDocument = userDocument, userDocument.exists{
                        let userData = userDocument.data()
                        let name = userData?["name"] as! String
                        self.users.append(User(userName: name, uid: userID))
                        
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsRequestsTableViewCell", for: indexPath) as! FriendsRequestsTableViewCell
        if users.count != 0{
            cell.userImageView.image = UIImage(systemName: "person")
            cell.userNameLabel.text = users[indexPath.row].userName
            cell.btnConfirm.tag = indexPath.row
            cell.btnDelete.tag = indexPath.row
            cell.btnConfirm.addTarget(self, action: #selector(btnConfirmTarget(sender:)), for: .touchUpInside)
            cell.btnDelete.addTarget(self, action: #selector(btnDeleteTarget(sender:)), for: .touchUpInside)
        }
        return cell
    }
    
    @objc private func btnConfirmTarget(sender: UIButton){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let userCollection = db.collection("users").document(userID)
            userCollection.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var userFriends = userData?["friends"] as? [String] ?? []
                    userFriends.append(self.users[sender.tag].uid)
                    userCollection.updateData([
                        "friends": userFriends
                    ]) { err in
                        if let err = err {
                            print("Hata oluştu: \(err)")
                        } else {
                            let remoteUserCollection = db.collection("users").document(self.users[sender.tag].uid)
                            remoteUserCollection.getDocument { userDocument, userError in
                                if let userDocument = userDocument, userDocument.exists{
                                    let userData = userDocument.data()
                                    var userFriends = userData?["friends"] as? [String] ?? []
                                    userFriends.append(userID)
                                    remoteUserCollection.updateData([
                                        "friends": userFriends
                                    ]) { err in
                                        if let err = err {
                                            print("Hata oluştu: \(err)")
                                        } else{
                                            self.removeRequest(userCollection, index: sender.tag)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeRequest(_ userCollection: DocumentReference, index: Int){
        userCollection.getDocument { userDocument, userError in
            if let userDocument = userDocument, userDocument.exists{
                let userData = userDocument.data()
                var friendsRequests = userData?["friendsRequests"] as? [String] ?? []
                friendsRequests.removeAll(where: { $0 == self.users[index].uid})
                userCollection.updateData([
                    "friendsRequests": friendsRequests
                ]) { err in
                    if let err = err {
                        print("Hata oluştu: \(err)")
                    } else{
                        self.users.remove(at: index)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc private func btnDeleteTarget(sender: UIButton){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let userCollection = db.collection("users").document(userID)
            removeRequest(userCollection, index: sender.tag)
        }
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
