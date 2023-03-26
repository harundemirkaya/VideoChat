//
//  MessageChatViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 19.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreData

class MessageChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: -Define
    
    // MARK: Views Defined
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userInfoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let textEditView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let messagesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        return view
    }()
    
    // MARK: Buttons Defined
    private let btnBack: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        return btn
    }()
    
    private let btnVideoCall: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "video.fill"), for: .normal)
        return btn
    }()
    
    private let btnSend: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        return btn
    }()
    
    // MARK: ImageViews Defined
    private let imgViewUserPhoto: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: Labels Defined
    let lblUsername: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = ""
        return lbl
    }()
    
    // MARK: Textfields Defined
    private let txtFieldMessage: UITextField = {
        let txtField = UITextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.layer.cornerRadius = 4.0
        txtField.layer.borderWidth = 1.0
        txtField.layer.borderColor = UIColor.gray.cgColor
        let paddingViewUsername = UIView(frame: CGRectMake(0, 0, 15, txtField.frame.height))
        txtField.leftView = paddingViewUsername
        txtField.leftViewMode = UITextField.ViewMode.always
        txtField.backgroundColor = .white
        txtField.autocorrectionType = .no
        txtField.autocapitalizationType = .none
        return txtField
    }()
    
    // MARK: TableView Defined
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        return tableView
    }()
    
    var remoteUser = User(userName: "", uid: "")
    
    var messages = [Message]()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentUser = Auth.auth().currentUser{
            let db = Firestore.firestore()
            let users = db.collection("users")
            let user = users.document(currentUser.uid)
            
            // Dinleyici ekle
            user.addSnapshotListener { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                    if let userUnreadmessages = unreadMessages[self.remoteUser.uid] {
                        for userUnreadMessage in userUnreadmessages{
                            self.saveData(userUnreadMessage)
                        }
                        unreadMessages.removeValue(forKey: self.remoteUser.uid)
                        user.updateData([
                            "unreadMessages": unreadMessages
                        ]) { err in
                            if let err = err {
                                print("Hata oluştu: \(err)")
                            }
                        }
                    }
                }
            }
        }
    }

    
    private func setupViews(){
        // MARK: for Remote User
        lblUsername.text = remoteUser.userName
        
        stackView.stackViewConstraints(view)
        
        userInfoView.userInfoViewConstraints(stackView)
        imgViewUserPhoto.imgViewUserPhotoConstraints(userInfoView)
        btnBack.btnBackConstraints(userInfoView, imgViewUserPhoto: imgViewUserPhoto)
        lblUsername.lblUsernameConstraints(userInfoView, imgViewUserPhoto: imgViewUserPhoto)
        btnVideoCall.btnVideoCallConstraints(userInfoView, btnBack: btnBack)
        
        textEditView.textEditViewConstraints(stackView)
        btnSend.btnSendConstraints(textEditView)
        txtFieldMessage.txtFieldsMessageConstraints(textEditView, btnSend: btnSend)
        
        messagesView.messagesViewConstraints(stackView, userInfoView: userInfoView, textEditView: textEditView)
        tableView.tableViewConstraints(messagesView)
        tableView.dataSource = self
        tableView.delegate = self
        
        btnBack.addTarget(self, action: #selector(btnBackTarget), for: .touchUpInside)
        btnSend.addTarget(self, action: #selector(btnSendTarget), for: .touchUpInside)
    }
    
    @objc private func btnBackTarget(){
        self.dismiss(animated: true)
    }
    
    @objc private func btnSendTarget(){
        if txtFieldMessage.text != ""{
            let db = Firestore.firestore()
            let users = db.collection("users")
            let user = users.document(remoteUser.uid)
            user.getDocument { userDocument, userError in
                if let userDocument = userDocument, userDocument.exists{
                    let userData = userDocument.data()
                    var unreadMessages = userData?["unreadMessages"] as? [String:[String]] ?? [:]
                    if var messages = unreadMessages[Auth.auth().currentUser!.uid] {
                        messages.append(self.txtFieldMessage.text!)
                        unreadMessages[Auth.auth().currentUser!.uid] = messages
                    } else {
                        unreadMessages[Auth.auth().currentUser!.uid] = [self.txtFieldMessage.text!]
                    }
                    user.updateData([
                        "unreadMessages": unreadMessages
                    ]) { err in
                        if let err = err {
                            print("Hata oluştu: \(err)")
                        } else{
                            self.saveData()
                        }
                    }
                }
            }
        }
    }
    
    private func saveData(_ message: String = ""){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let messages = NSEntityDescription.insertNewObject(forEntityName: "Messages", into: context)
        messages.setValue(Auth.auth().currentUser?.uid, forKey: "senderID")
        messages.setValue(remoteUser.uid, forKey: "remoteID")
        messages.setValue(remoteUser.userName, forKey: "remoteUsername")
        if message == ""{
            messages.setValue(txtFieldMessage.text, forKey: "message")
        } else{
            messages.setValue(message, forKey: "message")
        }
        do{
            try context.save()
            self.fetchData()
        } catch{
            print("error")
        }
    }
    
    @objc private func fetchData(){
        messages.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
            
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Messages")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if result.value(forKey: "remoteID") as! String == remoteUser.uid{
                        let senderID = result.value(forKey: "senderID")
                        let remoteID = result.value(forKey: "remoteID")
                        let messageDesc = result.value(forKey: "message")
                        let message = Message(senderID: senderID as! String , remoteID: remoteID as! String, message: messageDesc as! String)
                        messages.append(message)
                    }
                }
                tableView.reloadData()
            }
        } catch{
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = messages[indexPath.row].message
        return cell
    }
}

private extension UIView{
    func stackViewConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func userInfoViewConstraints(_ view: UIStackView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func imgViewUserPhotoConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        widthAnchor.constraint(equalToConstant: 40).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func btnBackConstraints(_ view: UIView, imgViewUserPhoto: UIImageView){
        view.addSubview(self)
        centerYAnchor.constraint(equalTo: imgViewUserPhoto.centerYAnchor).isActive = true
        leadingAnchor.constraint(equalTo: imgViewUserPhoto.leadingAnchor, constant: -15).isActive = true
    }
    
    func lblUsernameConstraints(_ view: UIView, imgViewUserPhoto: UIImageView){
        view.addSubview(self)
        leadingAnchor.constraint(equalTo: imgViewUserPhoto.trailingAnchor, constant: 10).isActive = true
        centerYAnchor.constraint(equalTo: imgViewUserPhoto.centerYAnchor).isActive = true
    }
    
    func btnVideoCallConstraints(_ view: UIView, btnBack: UIButton){
        view.addSubview(self)
        topAnchor.constraint(equalTo: btnBack.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    func textEditViewConstraints(_ view: UIStackView){
        view.addSubview(self)
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor ).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func btnSendConstraints(_ view: UIView){
        view.addSubview(self)
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        widthAnchor.constraint(equalToConstant: 30).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func txtFieldsMessageConstraints(_ view: UIView, btnSend: UIButton){
        view.addSubview(self)
        
        centerYAnchor.constraint(equalTo: btnSend.centerYAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        trailingAnchor.constraint(equalTo: btnSend.leadingAnchor, constant: -5).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func messagesViewConstraints(_ view: UIStackView, userInfoView: UIView, textEditView: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: userInfoView.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: textEditView.topAnchor).isActive = true
    }
    
    func tableViewConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
