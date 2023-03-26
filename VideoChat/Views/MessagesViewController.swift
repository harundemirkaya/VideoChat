//
//  MessagesViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 16.03.2023.
//

import UIKit
import CoreData

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
        btn.setTitle("New Chat", for: .normal)
        btn.setTitleColor(.tintColor, for: .normal)
        return btn
    }()
    
    private var btnFriendRequests: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "person.crop.circle.fill.badge.plus"), for: .normal)
        btn.setTitleColor(.tintColor, for: .normal)
        return btn
    }()
    
    private var recentlyChat = [User]()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
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
                            recentlyChat.append(User(userName: remoteUser as! String, uid: remoteUserID as! String))
                        }
                    }
                }
                tableView.reloadData()
            }
        } catch{
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlyChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        
        cell.userImageView.image = UIImage(systemName: "person")
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
