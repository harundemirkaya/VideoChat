//
//  MatchHomeViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 03.03.2023.
//

import UIKit
import AVFoundation
import AgoraRtcKit
import CoreML
import Vision

class MatchHomeViewController: UIViewController, AgoraRtcEngineDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate, UITabBarControllerDelegate {
    
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
    
    var smallLocalViewVideo: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 60
        return view
    }()
    
    var remoteViewVideo: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var friendRequestView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
        return view
    }()
    
    private var lblFriendRequestViewTitle: UIView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Friend Request"
        label.font = UIFont(name: "Futura", size: 16)
        label.textColor = .black
        return label
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
        btn.setImage(UIImage(systemName: "bitcoinsign.circle.fill"), for: .normal)
        btn.tintColor = .primary()
        btn.setTitle("  0 Coin  ", for: .normal)
        btn.backgroundColor = .black.withAlphaComponent(0.8)
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    var btnGender: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "person.crop.circle.dashed"), for: .normal)
        btn.tintColor  = .primary()
        btn.setTitle("    ", for: .normal)
        btn.backgroundColor = .black.withAlphaComponent(0.8)
        btn.layer.cornerRadius = 15
        btn.addTarget(self, action: #selector(btnGenderTarget), for: .touchUpInside)
        return btn
    }()
    
    var btnAddFriend: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        btn.tintColor = .primary()
        btn.setTitle("  Add Friend ", for: .normal)
        btn.backgroundColor = .black.withAlphaComponent(0.8)
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    private var btnFriendRequestDelete = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Delete", for: .normal)
        btn.backgroundColor = UIColor(red: 0.92, green: 0.22, blue: 0.21, alpha: 1.00)
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 0.2
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    private var btnFriendRequestConfirm = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Confirm", for: .normal)
        btn.backgroundColor = UIColor(red: 0.13, green: 0.63, blue: 0.56, alpha: 1.00)
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 0.2
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    var joined: Bool = false
    
    var userIDforChannel = UInt()
    
    var publisherToken: String?{
        didSet{
            if publisherToken != nil{
                matchHomeViewModel.createChannel(isCustomChannel ? true : false)
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
    
    var isListener = false
    
    let matchHomeViewModel = MatchHomeViewModel()
    
    var channelName = ""
    
    var remoteUserIDForFriendRequest = ""
    
    var isCustomChannel: Bool = false
    
    var isCustomPublisher: Bool = false
    
    var isCustomListener: Bool = false
    
    var customChannelName: String = "0CHANNEL"
    
    var customChannelID: UInt = UInt(0)
    
    var userInfo = [AnyHashable : Any]()
    
    private lazy var captureCount = 0
    private var genderPrediction: [String] = []{
        didSet{
            if genderPrediction.count == 99{
                var maleCount = 0
                var femaleCount = 0
                for genderPredict in genderPrediction{
                    if genderPredict == "Male"{
                        maleCount += 1
                    } else if genderPredict == "Female"{
                        femaleCount += 1
                    }
                }
                matchHomeViewModel.setUserGender((femaleCount > maleCount) ? "Female" : "Male")
            }
        }
    }
    
    let matchNotification = MatchNotification()
    
    private let selectGenderPopUp = SelectGenderPopUp()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        matchHomeViewModel.matchHomeVC = self
        self.tabBarController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCustomCallNotification(_:)), name: NSNotification.Name("customCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSendCallNotification(_:)), name: NSNotification.Name("sendCall"), object: nil)
        
        self.matchHomeViewModel.listenMatchRequest()
        self.btnAddFriend.isHidden = true
        setupViews()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        localView.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async {AgoraRtcEngineKit.destroy()}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initializeAgoraEngine()
        setupLocalVideo(localViewVideo)
    }
    
    // MARK: -Views Config
    func setupViews(){
        remoteView.viewsConstraints(view)
        localView.viewsConstraints(view)
        localViewVideo.viewsConstraints(localView)
        smallLocalViewVideo.smallLocalViewVideoConstraints(remoteView)
        
        btnPremium.btnPremiumConstraints(localView)
        btnGender.btnGenderConstraints(localView)
        remoteViewVideo.viewsConstraints(remoteView)
        remoteViewVideo.viewsConstraints(remoteView)
        initializeAgoraEngine()
        setupLocalVideo(localViewVideo)
        btnLeave.btnLeaveConstraints(remoteView)
        
        btnLeave.addTarget(self, action: #selector(leaveChannel), for: .touchUpInside)
        btnAddFriend.btnAddFriendConstraints(remoteView)
        btnAddFriend.addTarget(self, action: #selector(btnAddFriendTarget), for: .touchUpInside)
        
        matchHomeViewModel.getTarget { target in
            self.btnGender.setTitle("  \(target)  ", for: .normal)
        }
    }
    
    @objc func handleCustomCallNotification(_ notification: Notification) {
        if let remoteUserID = notification.userInfo?["remoteUserID"] as? UInt {
            dismiss(animated: true)
            tabBarController?.selectedIndex = 1
            localView.isHidden = true
            isCustomChannel = true
            customChannelID = UInt(remoteUserID)
            customChannelName = "\(remoteUserID)CHANNEL"
            matchHomeViewModel.listenerFilters(0, isCustomChannel: true, customChannelName: "\(remoteUserID)CHANNEL")
        }
    }
    
    @objc func handleSendCallNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo{
            self.userInfo = userInfo
            dismiss(animated: true)
            tabBarController?.selectedIndex = 1
            localView.isHidden = true
            isCustomChannel = true
            isCustomPublisher = true
            self.matchHomeViewModel.getUserIDForChannel(completion: { [weak self] value in
                if let value = value{
                    self?.customChannelID = value
                    self?.customChannelName = "\(value)CHANNEL"
                    self?.matchHomeViewModel.getTokenPublisher(0, isCustom: true, customChannelID: value)
                }
            })
        }
    }
    
    func handleMatchNotification(name: String?, url: URL?, matchRequestID: String?){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            self.matchNotification.matchNotification(name: name, view: window, url: url, id: matchRequestID)
        }
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
        
        btnAddFriend.isHidden = false
        setupLocalVideo(smallLocalViewVideo)
        
        var channelName = ""
        if isListener{
            channelName = isCustomChannel ? customChannelName : self.filteredChannelName ?? "ERRORCHANNEL"
        } else{
            channelName = isCustomChannel ? customChannelName : String("\(self.userIDforChannel)CHANNEL")
        }
        matchHomeViewModel.setRemoteUserID(isListener, channelName: channelName)
        
        if !isCustomChannel{
            matchHomeViewModel.listenChatState(channelName)
        }
        
        matchHomeViewModel.listenFriendRequest(channelName)
        
    }
    
    // MARK: -Setup Local Video with Agora
    func setupLocalVideo(_ localView: UIView) {
        agoraEngine.enableVideo()
        agoraEngine.startPreview()
        agoraEngine.setVideoFrameDelegate(self)
        agoraEngine.setCameraFocusPositionInPreview(CGPoint(x: 0.5, y: 0.5))
        agoraEngine.setCameraExposurePosition(CGPoint(x: 0.5, y: 0.5))
        let config = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension1280x720, frameRate: .fps30, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative, mirrorMode: .disabled)
        agoraEngine.setVideoEncoderConfiguration(config)
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        agoraEngine.setupLocalVideo(videoCanvas)
    }
    
    // MARK: -Join Channels Funcs
    func joinChannel() async {
        if await !self.checkForPermissions() {
            showMessage(title: "Error", text: "Permissions were not granted")
            return
        }
        matchHomeViewModel.joinChannel()
    }
    
    func joinListener(){
        let channelName = isCustomChannel ? customChannelName : self.filteredChannelName ?? "0CHANNEL"
        let channelID = isCustomChannel ? 0 : self.userIDforChannel
        let result = self.agoraEngine.joinChannel(
            byToken: self.listenerToken, channelId: channelName, uid: channelID, mediaOptions: self.option,
            joinSuccess: { (channel, uid, elapsed) in }
        )
        if result == 0 {
            self.joined = true
            matchHomeViewModel.setListenerToken()
        }
    }
    
    // MARK: -Leave Channel
    @objc func leaveChannel() {
        agoraEngine.stopPreview()
        let result = agoraEngine.leaveChannel(nil)
        if result == 0 { joined = false }
        localView.removeFromSuperview()
        smallLocalViewVideo.removeFromSuperview()
        localView.viewsConstraints(view)
        smallLocalViewVideo.smallLocalViewVideoConstraints(remoteView)
        setupLocalVideo(localViewVideo)
        btnAddFriend.isHidden = true
        
        if let channelName = isCustomChannel ? customChannelName : (self.isListener ? self.filteredChannelName : self.channelName){
            if channelName != ""{
                matchHomeViewModel.deleteChannel(channelName)
            }
        }
    
        if isCustomChannel{
            localView.isHidden = false
            isCustomChannel = false
            isCustomPublisher = false
        }
        
        matchHomeViewModel.setBusyFalse()
        removeAllVariable()
    }
    
    @objc func btnAddFriendTarget(){
        btnAddFriend.isHidden = true
        matchHomeViewModel.addFriends()
    }
    
    @objc func btnGenderTarget(){
        matchHomeViewModel.getTarget { target in
            self.selectGenderPopUp.selectGenderPopUpOpen(view: self.view, target: target, vc: self)
        }
    }
    
    func friendRequestViewTarget(remoteUserID: String){
        self.remoteUserIDForFriendRequest = remoteUserID
        friendRequestView.alpha = 1.0
        friendRequestView.friendRequestViewConstraints(remoteView, mainView: view)
        btnFriendRequestDelete.btnFriendRequestDeleteConstraints(friendRequestView)
        btnFriendRequestConfirm.btnFriendRequestConfirmConstraints(friendRequestView)
        lblFriendRequestViewTitle.lblFriendRequestViewTitleConstraints(friendRequestView, btnConfirm: btnFriendRequestConfirm)
        
        btnFriendRequestConfirm.addTarget(self, action: #selector(btnFriendRequestConfirmTarget), for: .touchUpInside)
        btnFriendRequestDelete.addTarget(self, action: #selector(btnFriendRequestDeleteTarget), for: .touchUpInside)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 1.0, animations: {
                self.friendRequestView.alpha = 0.0
            }, completion: { finished in
                self.friendRequestView.removeFromSuperview()
            })
        }
    }
    
    @objc func btnFriendRequestConfirmTarget(){
        UIView.animate(withDuration: 1.0, animations: {
            self.friendRequestView.alpha = 0.0
        }, completion: { finished in
            self.friendRequestView.removeFromSuperview()
        })
        btnAddFriend.isHidden = true
        matchHomeViewModel.confirmRequest(remoteUserIDForFriendRequest)
    }
    
    @objc func btnFriendRequestDeleteTarget(){
        UIView.animate(withDuration: 1.0, animations: {
            self.friendRequestView.alpha = 0.0
        }, completion: { finished in
            self.friendRequestView.removeFromSuperview()
        })
        matchHomeViewModel.removeRequest(remoteUserIDForFriendRequest)
    }
    
    func createCustomChannel(_ userID: UInt){
        matchHomeViewModel.getTokenPublisher(userID)
    }
    
    func removeAllVariable(){
        joined = false
        userIDforChannel = UInt()
        listenerJoinedUID = ""
        filteredChannelName = ""
        isListener = false
        channelName = ""
        remoteUserIDForFriendRequest = ""
        isCustomChannel = false
        isCustomPublisher = false
        customChannelName = "0CHANNEL"
        customChannelID = UInt(0)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        leaveChannel()
        removeAllVariable()
    }
    
    public func setGenderButtonTitle(_ title: String){
        btnGender.setTitle("  \(title)  ", for: .normal)
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
    
    // MARK: -AI
    private func detectFace(image: CVPixelBuffer){
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
            DispatchQueue.main.async {
                if let results = vnRequest.results as? [VNFaceObservation], results.count > 0{
                    if let firstFaceObservation = results.first {
                        // Tespit edilen ilk yüzü alın
                        let faceImage = self.cropFaceImage(from: image, with: firstFaceObservation)
                        // Tespit edilen yüzü detectGender fonksiyonuna gönder
                        self.detectGender(image: faceImage)
                    }
                }
            }
        }
        
        let imageResultHander = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageResultHander.perform([faceDetectionRequest])
    }
    
    private func cropFaceImage(from image: CVPixelBuffer, with observation: VNFaceObservation) -> CIImage {
        let ciImage = CIImage(cvPixelBuffer: image)
        
        let boundingBox = observation.boundingBox
        let imageSize = ciImage.extent.size
        
        let faceRect = CGRect(x: boundingBox.origin.x * imageSize.width,
                              y: (1 - boundingBox.origin.y - boundingBox.size.height) * imageSize.height,
                              width: boundingBox.size.width * imageSize.width,
                              height: boundingBox.size.height * imageSize.height)
        
        let faceImage = ciImage.cropped(to: faceRect)
        
        return faceImage
    }
    
    func detectGender(image: CIImage) {
        let config = MLModelConfiguration()
        config.allowLowPrecisionAccumulationOnGPU = false
        config.computeUnits = MLComputeUnits.cpuOnly
        guard let model = try? VNCoreMLModel(for: GenderClass_1(configuration: config).model) else {
            fatalError("can't load GenderNet model")
        }
        // Create request for Vision Core ML model created
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            // Update UI on main queue
            DispatchQueue.main.async {
                if Double(topResult.confidence) > 0.99{
                    self.genderPrediction.append(topResult.identifier)
                    self.captureCount += 1
                }
            }
        }
        
        // Run the Core ML AgeNet classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
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
    
    func btnGenderConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        widthAnchor.constraint(equalToConstant: 130).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func btnPremiumConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        widthAnchor.constraint(equalToConstant: 130).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func btnAddFriendConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        widthAnchor.constraint(equalToConstant: 130).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func friendRequestViewConstraints(_ view: UIView, mainView: UIView){
        view.addSubview(self)
        heightAnchor.constraint(equalToConstant: mainView.frame.size.height * 0.15).isActive = true
        bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func btnFriendRequestDeleteConstraints(_ view: UIView){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: 150).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
    }
    
    func btnFriendRequestConfirmConstraints(_ view: UIView){
        view.addSubview(self)
        widthAnchor.constraint(equalToConstant: 150).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
    }
    
    func lblFriendRequestViewTitleConstraints(_ view: UIView, btnConfirm: UIButton){
        view.addSubview(self)
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: btnConfirm.topAnchor, constant: -20).isActive = true
    }
    
    func smallLocalViewVideoConstraints(_ view: UIView){
        view.addSubview(self)
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        widthAnchor.constraint(equalToConstant: 150).isActive = true
        heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
}

extension MatchHomeViewController: AgoraVideoFrameDelegate{
    func onCapture(_ videoFrame: AgoraOutputVideoFrame) -> Bool {
        guard captureCount < 99 else {
            return false
        }
        guard let pixelBuffer = videoFrame.pixelBuffer else { return false }
        detectFace(image: pixelBuffer)
        return true
    }
}
