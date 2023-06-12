//
//  UIColor+Extensions.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 12.06.2023.
//

import Foundation
import UIKit

extension UIColor{
    static func primary() -> UIColor{
        return UIColor(named: "primary") ?? .black
    }
    
    static func borderGray() -> UIColor {
        return UIColor(named: "border-gray") ?? .black
    }
    
    static func textfieldBG() -> UIColor? {
        return UIColor(named: "textfield-bg") ?? .black
    }
}

