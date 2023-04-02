//
//  MessagesViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 16.03.2023.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Define
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Messages"
        return lbl
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var btnNewChat: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.tintColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        btn.setTitle("New Chat", for: .normal)
        btn.setTitleColor(UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00), for: .normal)
        return btn
    }()
    
    private var btnFriendRequests: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "figure.stand.line.dotted.figure.stand"), for: .normal)
        btn.tintColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        return btn
    }()
    
    private var recentlyChat = [User]()
    private var recentlyChatCount = [String:Int]()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        recentlyChat = [User]()
    }
        
    private func setupViews(){
        lblTitle.lblTitleConstraints(view)
        btnNewChat.btnNewChatConstraints(view)
        btnFriendRequests.btnFriendsRequestsConstraints(view)
        tableView.tableViewConstraints(view, lblTitle: lblTitle)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        
        btnNewChat.addTarget(self, action: #selector(btnNewChatTarget), for: .touchUpInside)
        btnFriendRequests.addTarget(self, action: #selector(btnFriendRequestsTarget), for: .touchUpInside)
    }
    
    @objc private func btnNewChatTarget(){
        let friendsVC = FriendsViewController()
        friendsVC.modalPresentationStyle = .fullScreen
        present(friendsVC, animated: true)
    }
    
    @objc private func btnFriendRequestsTarget(){
        let friendRequestsVC = FriendRequestsViewController()
        friendRequestsVC.modalPresentationStyle = .fullScreen
        present(friendRequestsVC, animated: true)
    }
    
    @objc private func fetchData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
            
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Messages")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let remoteUser = result.value(forKey: "remoteUsername"){
                        if let remoteUserID = result.value(forKey: "remoteID"){
                            let newUser = User(userName: remoteUser as! String, uid: remoteUserID as! String)
                            if !recentlyChat.contains(where: { $0.uid == newUser.uid }) {
                                recentlyChat.append(newUser)
                            }
                        }
                    }
                }
                tableView.reloadData()
            }
        } catch{
            print("error")
        }
        if let currentUser = Auth.auth().currentUser{
            let db = Firestore.firestore()
            let usersCollection = db.collection("users").document(currentUser.uid)
            usersCollection.addSnapshotListener { [self] userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    let unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                    for unreadMessage in unreadMessages{
                        recentlyChatCount.updateValue(unreadMessage.value.count, forKey: unreadMessage.key)
                        db.collection("users").document(unreadMessage.key).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let userName = data?["name"] as? String ?? "Unkown"
                                let newUser = User(userName: userName, uid: unreadMessage.key)
                                if !self.recentlyChat.contains(where: { $0.uid == newUser.uid }) {
                                    self.recentlyChat.append(newUser)
                                }
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlyChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        if let unreadMessagesCount = recentlyChatCount[recentlyChat[indexPath.row].uid]{
            cell.btnUnread.isHidden = false
            cell.btnUnread.setTitle(String(unreadMessagesCount), for: .normal)
        } else{
            cell.btnUnread.isHidden = true
        }
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear
        cell.userImageView.image = UIImage(named: "profile-photo")
        cell.userNameLabel.text = recentlyChat[indexPath.row].userName
        cell.messageLabel.text = "Recently Chat"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageChatVC = MessageChatViewController()
        messageChatVC.modalPresentationStyle = .fullScreen
        messageChatVC.remoteUser.userName = recentlyChat[indexPath.row].userName
        messageChatVC.remoteUser.uid = recentlyChat[indexPath.row].uid
        present(messageChatVC, animated: true)
        recentlyChatCount.removeValue(forKey: recentlyChat[indexPath.row].uid)
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
    
    func btnNewChatConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    }
    
    func btnFriendsRequestsConstraints(_ view: UIView){
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
