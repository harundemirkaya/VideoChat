//
//  TabBar.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 15.03.2023.
//
// MARK: -Import Libraries
import UIKit
import Network

// MARK: -App Tab Bar Class
class AppTabBarController: UITabBarController {
    
    var views: [UIViewController] = []
    
    var tabBarIndex = true
    
    var changeVC: UIViewController?
    
    // MARK: -ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tabBar.barTintColor = .white
        tabBar.backgroundColor = .black.withAlphaComponent(0.8)
        tabBar.layer.cornerRadius = 20
        tabBar.tintColor = .systemPink
        
        // MARK: Define VC and Add Tab Bar
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem.init(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 0)
        
        let mapVC = MapViewController()
        mapVC.tabBarItem = UITabBarItem.init(title: "Map", image: UIImage(systemName: "mappin.and.ellipse"), tag: 0)
        
        let matchVC = MatchHomeViewController()
        matchVC.tabBarItem = UITabBarItem.init(title: "Match", image: UIImage(systemName: "video.fill"), tag: 1)
        
        let messagesVC = MessagesViewController()
        messagesVC.tabBarItem = UITabBarItem.init(title: "Messages", image: UIImage(systemName: "message.fill"), tag: 2)
        
        views = [profileVC, mapVC, matchVC, messagesVC]

        self.viewControllers = views
        selectedIndex = 2
    }
}
