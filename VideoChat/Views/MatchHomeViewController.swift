import UIKit
import AVFoundation
import AgoraRtcKit


class MatchHomeViewController: UIViewController, AgoraRtcEngineDelegate {
    
    // MARK: -Agora Config
    var agoraEngine: AgoraRtcEngineKit!
    var userRole: AgoraClientRole = .broadcaster
    let appID = "3dbfbb81b19e4e379cdc2c179d89999e"
    var token = "007eJxTYGCZOrvxWqz6ggjh1cs8U9826eyRmxzdGDPhM0fZ9hOmpXsUGIxTktKSkiwMkwwtU01Sjc0tk1OSjZINzS1TLCyBIFW8kDmlIZCRYZ7EYxZGBkYGFiAG8ZnAJDOYZAGTHAzF+WklqSWZ2QwMAOcIIuU="
    var channelName = "softetik"

    // MARK: -Define Views
    var localView: UIView!
    var remoteView: UIView!

    
    // Click to join or leave a call
    var joinButton: UIButton!

    // Track if the local user is in a call
    var joined: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.joinButton.setTitle( self.joined ? "Leave" : "Join", for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        localView = UIView(frame: view.bounds)
        remoteView = UIView(frame: CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
        
        localView.backgroundColor = .green
        remoteView.backgroundColor = .red
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
        
        // The following functions are used when calling Agora APIs
        initializeAgoraEngine()
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
        // Break out, because camera permissions have been denied or restricted.
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
        // Pass in your App ID here.
        config.appId = appID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
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
        // Enable the video module
        agoraEngine.enableVideo()
        // Start the local video preview
        agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        // Set the local video view
        agoraEngine.setupLocalVideo(videoCanvas)
    }

    func joinChannel() async {
        if await !self.checkForPermissions() {
            showMessage(title: "Error", text: "Permissions were not granted")
            return
        }

        let option = AgoraRtcChannelMediaOptions()

        // Set the client role option as broadcaster or audience.
        if self.userRole == .broadcaster {
            option.clientRoleType = .broadcaster
            setupLocalVideo()
        } else {
            option.clientRoleType = .audience
        }

        // For a video call scenario, set the channel profile as communication.
        option.channelProfile = .communication

        // Join the channel with a temp token. Pass in your token and channel name here
        let result = agoraEngine.joinChannel(
            byToken: token, channelId: channelName, uid: 0, mediaOptions: option,
            joinSuccess: { (channel, uid, elapsed) in }
        )
            // Check if joining the channel was successful and set joined Bool accordingly
        if result == 0 {
            joined = true
            showMessage(title: "Success", text: "Successfully joined the channel as \(self.userRole)")
        }
    }

    func leaveChannel() {
        agoraEngine.stopPreview()
        let result = agoraEngine.leaveChannel(nil)
        // Check if leaving the channel was successful and set joined Bool accordingly
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
