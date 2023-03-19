//
//  MessagesViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 16.03.2023.
//

import UIKit

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
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    private func setupViews(){
        lblTitle.lblTitleConstraints(view)
        btnNewChat.btnNewChatConstraints(view)
        tableView.tableViewConstraints(view, lblTitle: lblTitle)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        
        btnNewChat.addTarget(self, action: #selector(btnNewChatTarget), for: .touchUpInside)
    }
    
    @objc private func btnNewChatTarget(){
        let friendsVC = FriendsViewController()
        friendsVC.modalPresentationStyle = .fullScreen
        present(friendsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        
        cell.userImageView.image = UIImage(systemName: "person")
        cell.userNameLabel.text = "John Doe"
        cell.messageLabel.text = "Hello, how are you?"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageChatVC = MessageChatViewController()
        messageChatVC.modalPresentationStyle = .fullScreen
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
    
    func tableViewConstraints(_ view: UIView, lblTitle: UILabel){
        view.addSubview(self)
        topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
