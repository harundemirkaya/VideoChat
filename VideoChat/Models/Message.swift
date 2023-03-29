//
//  Message.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 26.03.2023.
//

import Foundation

class Message{
    var senderID: String
    var remoteID: String
    var publisherID: String
    var message: String
    
    init(senderID: String, remoteID: String, publisherID: String, message: String) {
        self.senderID = senderID
        self.remoteID = remoteID
        self.message = message
        self.publisherID = publisherID
    }
}
