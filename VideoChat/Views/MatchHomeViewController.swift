import UIKit
import AVFoundation
import AgoraRtcKit
import Firebase
import FirebaseAuth
import Vision


class MatchHomeViewController: UIViewController, AgoraRtcEngineDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: -Agora Config
    var agoraEngine: AgoraRtcEngineKit!
    var userRole: AgoraClientRole = .broadcaster
    let appID = "3dbfbb81b19e4e379cdc2c179d89999e"
    
    let option: AgoraRtcChannelMediaOptions = {
        let option = AgoraRtcChannelMediaOptions()
        option.clientRoleType = .broadcaster
        option.channelProfile = .communication
        return option
    }()

    // MARK: -Views Defined
    var localView: UIView!
    var remoteView: UIView!

    // MARK: -Buttons Defined
    var joinButton: UIButton!
    var btnLeave: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        return btn
    }()
    
    var joined: Bool = false
    
    var userIDforChannel: UInt?
    
    var publisherToken: String?{
        didSet{
            if publisherToken != nil{
                self.createChannel()
            }
        }
    }
    
    var listenerToken: String?{
        didSet{
            if listenerToken != nil{
                self.joinListener()
            }
        }
    }
    
    var listenerJoinedUID: String?
    
    var filteredChannelName: String?
    
    var genderClassLabel: UILabel!
    
    let matchHomeViewModel = MatchHomeViewModel()

    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        matchHomeViewModel.matchHomeVC = self
        setupViews()
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        localView.addGestureRecognizer(gestureRecognizer)
        

        initializeAgoraEngine()
        setupLocalVideo()
    }
    
    func setupViews(){
        localView = UIView(frame: view.bounds)
        localView.backgroundColor = .green
        remoteView = UIView(frame: CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
        remoteView.backgroundColor = .red
        view.addSubview(localView)
        view.addSubview(remoteView)
        btnLeave.addTarget(self, action: #selector(leaveChannel), for: .touchUpInside)
        btnLeave.btnLeaveConstraints(remoteView)
        remoteView.alpha = 0
    }
    
    func resetViews() {
        UIView.animate(withDuration: 0.3) {
            self.localView.frame = self.view.bounds
            self.remoteView.frame = CGRect(x: self.view.bounds.width, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }
    }

    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        switch gestureRecognizer.state {
        case .changed:
            localView.frame.origin.x = translation.x
            remoteView.alpha = min(max(translation.x / 100, 0), 1)
            remoteView.frame.origin.x = localView.frame.maxX + min(max(translation.x, 0), 100)
        case .ended:
            let velocity = gestureRecognizer.velocity(in: view)
            let duration = TimeInterval(abs(1000 / velocity.x))
            UIView.animate(withDuration: duration, animations: {
                if translation.x < 100 {
                    self.localView.frame.origin.x = self.view.bounds.width
                    self.remoteView.alpha = 1
                    self.remoteView.frame.origin.x = self.view.bounds.width - self.remoteView.frame.width
                } else {
                    self.localView.frame.origin.x = 0
                    self.remoteView.alpha = 0
                    self.remoteView.frame.origin.x = self.view.bounds.width
                }
            })
            gestureAction()
        default:
            break
        }
    }



    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        leaveChannel()
        DispatchQueue.global(qos: .userInitiated).async {AgoraRtcEngineKit.destroy()}
    }

    @objc func gestureAction() {
        if !joined {
            Task {
                await joinChannel()
            }
        } else {
            leaveChannel()
        }
    }
    
    func checkForPermissions() async -> Bool {
        var hasPermissions = await self.avAuthorization(mediaType: .video)
        if !hasPermissions { return false }
        hasPermissions = await self.avAuthorization(mediaType: .audio)
        return hasPermissions
    }

    func avAuthorization(mediaType: AVMediaType) async -> Bool {
        let mediaAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch mediaAuthorizationStatus {
        case .denied, .restricted: return false
        case .authorized: return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default: return false
        }
    }
    
    func showMessage(title: String, text: String, delay: Int = 2) -> Void {
        let deadlineTime = DispatchTime.now() + .seconds(delay)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            self.present(alert, animated: true)
            alert.dismiss(animated: true, completion: nil)
        })
    }

    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = appID
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteView
        agoraEngine.setupRemoteVideo(videoCanvas)
    }
    
    func setupLocalVideo() {
        agoraEngine.enableVideo()
        agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        agoraEngine.setupLocalVideo(videoCanvas)
    }

    func joinChannel() async {
        if await !self.checkForPermissions() {
            showMessage(title: "Error", text: "Permissions were not granted")
            return
        }
        
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            var genderID = [Int]()
            // MARK: Gender Filter
            db.collection("users").whereField("gender", isEqualTo: "female").getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        if let userId = document.get("id") as? Int {
                            genderID.append(userId)
                        }
                    }
                }
            }
            // MARK: Set User ID
            let docRef = db.collection("users").document(currentUser.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let userID = data!["id"] as! UInt
                    self.userIDforChannel = userID
                    let isEmptyChannelDB = db.collection("channels")
                    isEmptyChannelDB.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error.localizedDescription)")
                        } else {
                            let numberOfDocuments = querySnapshot?.count ?? 0
                            if numberOfDocuments == 0 {
                                self.matchHomeViewModel.getTokenPublisher(userID)
                            } else{
                                self.listenerFilters(userID)
                            }
                        }
                    }
                } else {
                    print("Kullanıcı belgesi mevcut değil")
                }
            }
        } else {
            print("Kullanıcı oturum açmadı")
        }
    }
    
    func createChannel(){
        let db = Firestore.firestore()
        let channelsCollection = db.collection("channels")
        let getCurrentUser = db.collection("users").document(Auth.auth().currentUser!.uid)
        var currentUserGender = ""
        getCurrentUser.getDocument { (document, error) in
            if let document = document, document.exists {
                currentUserGender = document.data()?["gender"] as! String
                let data: [String: Any] = [
                    "channelName": "\(self.userIDforChannel!)CHANNEL",
                    "publisherToken": self.publisherToken!,
                    "gender": currentUserGender,
                    "listenerToken": ""
                ]
                channelsCollection.addDocument(data: data){ (error) in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else{
                        let result = self.agoraEngine.joinChannel(
                            byToken: self.publisherToken, channelId: "\(self.userIDforChannel!)CHANNEL", uid: self.userIDforChannel!, mediaOptions: self.option,
                            joinSuccess: { (channel, uid, elapsed) in }
                        )
                        if result == 0 {
                            self.joined = true
                            self.showMessage(title: "Success", text: "Successfully joined the channel as \(self.userRole)")
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func listenerFilters(_ userID: UInt){
        let db = Firestore.firestore()
        let channelsCollection = db.collection("channels")
        channelsCollection.getDocuments{ (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    let gender = document.data()["gender"] as? String ?? ""
                    if gender == "female" {
                        let data = document.data()
                        self.filteredChannelName = data["channelName"] as? String ?? ""
                        self.matchHomeViewModel.getTokenListener(userID, channelName: self.filteredChannelName!)
                        self.listenerJoinedUID = document.documentID
                        channelsCollection.document(document.documentID).delete{ error in
                            if let error = error{
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func joinListener(){
        let result = self.agoraEngine.joinChannel(
            byToken: self.listenerToken, channelId: self.filteredChannelName!, uid: self.userIDforChannel!, mediaOptions: self.option,
            joinSuccess: { (channel, uid, elapsed) in }
        )
        if result == 0 {
            self.joined = true
            let db = Firestore.firestore()
            let channelsCollctionDocument = db.collection("channels").document(self.listenerJoinedUID!)
            channelsCollctionDocument.updateData([
                "listenerToken": self.listenerToken!
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    self.showMessage(title: "Success", text: "Successfully joined the channel as \(self.userRole)")
                }
            }
        }
    }

    @objc func leaveChannel() {
        agoraEngine.stopPreview()
        let result = agoraEngine.leaveChannel(nil)
        if result == 0 { joined = false }
        resetViews()
    }

}

private extension UIView{
    func btnLeaveConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        widthAnchor.constraint(equalToConstant: 64).isActive = true
    }
}
