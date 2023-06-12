//
//  UIFont+Extensions.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 12.06.2023.
//

import Foundation
import UIKit

extension UILabel{
    func setDoubleFont(text1: String, font1: UIFont, color1: UIColor, text2: String, font2: UIFont, color2: UIColor){
        let attrs1 = [NSAttributedString.Key.font : font1, NSAttributedString.Key.foregroundColor : color1]
        let attrs2 = [NSAttributedString.Key.font : font2, NSAttributedString.Key.foregroundColor : color2]
        let attributedString1 = NSMutableAttributedString(string: text1, attributes: attrs1)
        let attributedString2 = NSMutableAttributedString(string: text2, attributes: attrs2)
        attributedString1.append(attributedString2)
        self.attributedText = attributedString1
    }
}
