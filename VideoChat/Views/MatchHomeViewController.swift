import UIKit
import AVFoundation
import AgoraRtcKit
import FirebaseAuth
import FirebaseFirestore


class MatchHomeViewController: UIViewController, AgoraRtcEngineDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate {
    
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
    var localView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    var remoteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    var localViewVideo: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var remoteViewVideo: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var panGestureRecognizer = UIGestureRecognizer()

    // MARK: -Buttons Defined
    var btnLeave: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        return btn
    }()
    
    var btnPremium: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "coin"), for: .normal)
        btn.setTitle("  0 Coin  ", for: .normal)
        btn.backgroundColor = .black.withAlphaComponent(0.8)
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    var btnGender: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "gender"), for: .normal)
        btn.setTitle("  Female  ", for: .normal)
        btn.backgroundColor = .black.withAlphaComponent(0.8)
        btn.layer.cornerRadius = 20
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
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        localView.addGestureRecognizer(panGestureRecognizer)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        leaveChannel()
        DispatchQueue.global(qos: .userInitiated).async {AgoraRtcEngineKit.destroy()}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initializeAgoraEngine()
        setupLocalVideo()
    }

    // MARK: -Views Config
    func setupViews(){
        remoteView.viewsConstraints(view)
        localView.viewsConstraints(view)
        localViewVideo.viewsConstraints(localView)
        btnPremium.btnPremiumConstraints(localView)
        btnGender.btnGenderConstraints(localView)
        remoteViewVideo.viewsConstraints(remoteView)
        initializeAgoraEngine()
        setupLocalVideo()
    }

    func resetView(_ view: UIView) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
            view.center = CGPoint(x: view.bounds.width / 2.0, y: view.center.y)
        }, completion: nil)
    }

    // MARK: -Gesture Recognizer
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        
        let translation = recognizer.translation(in: view.superview)

        view.center.x = max(view.center.x + translation.x, view.bounds.width / 2.0)
        recognizer.setTranslation(CGPoint.zero, in: view.superview)

        if recognizer.state == .ended {
            if view.center.x <= view.bounds.width / 2.0 {
                dismissView(view)
                gestureAction()
            } else {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                    view.center = CGPoint(x: view.bounds.width / 2.0, y: view.center.y)
                }, completion: nil)
            }
        }
        
        if recognizer.velocity(in: view.superview).x > 0 {
            recognizer.isEnabled = false
            recognizer.isEnabled = true
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            return true
        }
        return false
    }

    func dismissView(_ view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            view.center.x = -view.bounds.width / 2.0
        }) { (completed) in
            view.removeFromSuperview()
        }
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
    
    // MARK: -Permissions
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

    // MARK: -Agora Config
    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = appID
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteViewVideo
        agoraEngine.setupRemoteVideo(videoCanvas)
        btnLeave.btnLeaveConstraints(remoteView)
        btnLeave.addTarget(self, action: #selector(leaveChannel), for: .touchUpInside)
    }

    // MARK: -Setup Local Video with Agora
    func setupLocalVideo() {
        agoraEngine.enableVideo()
        agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localViewVideo
        agoraEngine.setupLocalVideo(videoCanvas)
    }

    // MARK: -Join Channels Funcs
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

    // MARK: -Leave Channel
    @objc func leaveChannel() {
        agoraEngine.stopPreview()
        let result = agoraEngine.leaveChannel(nil)
        if result == 0 { joined = false }
        localView.removeFromSuperview()
        localView.viewsConstraints(view)
        setupLocalVideo()
    }

    // MARK: -Show Message
    func showMessage(title: String, text: String, delay: Int = 2) -> Void {
        let deadlineTime = DispatchTime.now() + .seconds(delay)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            self.present(alert, animated: true)
            alert.dismiss(animated: true, completion: nil)
        })
    }
}

private extension UIView{
    func viewsConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func btnLeaveConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        widthAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    func btnPremiumConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    func btnGenderConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
}
