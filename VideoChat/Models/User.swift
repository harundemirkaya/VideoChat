//
//  User.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 23.03.2023.
//

import Foundation

class User{
    var uid: String
    var userName: String
    var userPhoto: String
    
    init(userName: String, uid: String, userPhoto: String) {
        self.userName = userName
        self.uid = uid
        self.userPhoto = userPhoto
    }
}
