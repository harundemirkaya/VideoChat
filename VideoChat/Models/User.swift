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
    // var userPhoto
    
    init(userName: String, uid: String) {
        self.userName = userName
        self.uid = uid
    }
}
