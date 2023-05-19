//
//  ImageCache.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 17.05.2023.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private let db = Firestore.firestore()
    
    private init() {
        cache.totalCostLimit = 100
    }
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func getProfilePhotoURL(_ userID: String){
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let profilePhoto = data?["profilePhoto"] as? String ?? ""
                self.downloadImage(from: profilePhoto) { image in
                    guard let image = image else { return }
                    self.setImage(image, forKey: profilePhoto)
                }
            }
        }
    }
    
    private func downloadImage(from imageURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: imageURL) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}
