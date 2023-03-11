//
//  RTCTokenModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 12.03.2023.
//

import Foundation

struct RTCToken: Codable {
    let rtcToken, rtmToken: String?
}
