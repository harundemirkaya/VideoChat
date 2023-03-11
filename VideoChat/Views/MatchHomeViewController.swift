import UIKit
import AVFoundation
import AgoraRtcKit
import Firebase
import FirebaseAuth


class MatchHomeViewController: UIViewController, AgoraRtcEngineDelegate {
    
    // MARK: -Agora Config
    var agoraEngine: AgoraRtcEngineKit!
    var userRole: AgoraClientRole = .broadcaster
    let appID = "3dbfbb81b19e4e379cdc2c179d89999e"
    var token = ""
    var channelName = ""

    // MARK: -Define Views
    var localView: UIView!
    var remoteView: UIView!

    var joinButton: UIButton!
    var joined: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.joinButton.setTitle( self.joined ? "Leave" : "Join", for: .normal)
            }
        }
    }

    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        localView = UIView(frame: view.bounds)
        remoteView = UIView(frame: CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
        
        view.addSubview(localView)
        view.addSubview(remoteView)
        remoteView.alpha = 0
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        localView.addGestureRecognizer(gestureRecognizer)
        
        joinButton = UIButton(type: .system)
        joinButton.frame = CGRect(x: 140, y: 700, width: 100, height: 50)
        joinButton.setTitle("Join", for: .normal)

        joinButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(joinButton)
        joinButton.isHidden = true

        initializeAgoraEngine()
        setupLocalVideo()
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
                if translation.x > 100 {
                    self.localView.frame.origin.x = self.view.bounds.width
                    self.remoteView.alpha = 1
                    self.remoteView.frame.origin.x = self.view.bounds.width - self.remoteView.frame.width
                } else {
                    self.localView.frame.origin.x = 0
                    self.remoteView.alpha = 0
                    self.remoteView.frame.origin.x = self.view.bounds.width
                }
            })
        default:
            break
        }
        buttonAction(sender: joinButton)
    }



    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        leaveChannel()
        DispatchQueue.global(qos: .userInitiated).async {AgoraRtcEngineKit.destroy()}
    }

    @objc func buttonAction(sender: UIButton!) {
        if !joined {
            sender.isEnabled = false
            Task {
                await joinChannel()
                sender.isEnabled = true
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

        let option = AgoraRtcChannelMediaOptions()
        
        if self.userRole == .broadcaster {
            option.clientRoleType = .broadcaster
            setupLocalVideo()
        } else {
            option.clientRoleType = .audience
        }

        option.channelProfile = .communication
        
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
                    var isEmptyChannel = true
                    
                    let isEmptyChannelDB = db.collection("channels")
                    isEmptyChannelDB.getDocuments { querySnapshot, error in
                        if let error = error{
                            print(error.localizedDescription)
                        } else{
                            let isEmpty = querySnapshot?.isEmpty ?? true
                            isEmptyChannel = isEmpty
                        }
                    }
                    
                    if isEmptyChannel{
                        // MARK: Set Token
                        var publisherToken = ""
                        guard let url = URL(string: "http://213.238.190.166:3169/rte/\(userID)CHANNEL/publisher/userAccount/\(userID)/?expiry=3600") else {
                            print("Invalid URL")
                            return
                        }
                        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard error == nil else {
                                print("Error: \(error!)")
                                return
                            }
                            
                            guard let data = data else {
                                print("No data received")
                                return
                            }
                            
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                guard let rtcToken = json?["rtcToken"] as? String else {
                                    print("Could not find rtcToken in JSON")
                                    return
                                }
                                
                                publisherToken = rtcToken
                            } catch {
                                print("Error decoding JSON: \(error)")
                            }
                        }
                        task.resume()


                        
                        
                        let data: [String: Any] = [
                            "channelName": "\(userID)CHANNEL",
                            "publisherToken": publisherToken,
                            "listenerToken": ""
                        ]
                        isEmptyChannelDB.addDocument(data: data){ (error) in
                            if let error = error {
                                print("Error adding document: \(error)")
                            }
                        }
                    } else{
                        // MARK: Dolu ise
                    }
                    
                    let result = self.agoraEngine.joinChannel(
                        byToken: self.token, channelId: self.channelName, uid: userID, mediaOptions: option,
                        joinSuccess: { (channel, uid, elapsed) in }
                    )
                    
                    if result == 0 {
                        self.joined = true
                        self.showMessage(title: "Success", text: "Successfully joined the channel as \(self.userRole)")
                    }
                } else {
                    print("Kullanıcı belgesi mevcut değil")
                }
            }
        } else {
            print("Kullanıcı oturum açmadı")
        }
    }

    func leaveChannel() {
        agoraEngine.stopPreview()
        let result = agoraEngine.leaveChannel(nil)
        if result == 0 { joined = false }
    }

}

private extension UIView{
    func stackViewConstraints(_ view: UIView){
        view.addSubview(self)
        heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
    }
    
    func localViewConstraints(_ stackView: UIStackView){
        stackView.addSubview(self)
        heightAnchor.constraint(equalToConstant: stackView.frame.size.height).isActive = true
        widthAnchor.constraint(equalToConstant: stackView.frame.size.width).isActive = true
        centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
    }
    
    func remoteViewConstraints(_ stackView: UIStackView, localView: UIView){
        stackView.addSubview(self)
        heightAnchor.constraint(equalToConstant: stackView.frame.size.height).isActive = true
        widthAnchor.constraint(equalToConstant: stackView.frame.size.width).isActive = true
        leadingAnchor.constraint(equalTo: localView.trailingAnchor).isActive = true
    }
}
