//
//  MatchNotificationViewModel.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 16.05.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MatchNotificationViewModel{
    // MARK: -Define
    
    // MARK: MatchNotificationView Defined
    var matchNotificationView: MatchNotification?
    
    // MARK: Firebase Firestore Defined
    private let db = Firestore.firestore()
    
    func closeNotification(){
        guard let matchNotificationView = matchNotificationView else { return }
        matchNotificationView.notificationView.removeFromSuperview()
        if let currentUser = Auth.auth().currentUser{
            let userCollection = db.collection("users").document(currentUser.uid)
            userCollection.getDocument { (document, error) in
                if let document = document, document.exists {
                    userCollection.updateData([
                        "matchRequest": FieldValue.delete()
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func removeChannel(_ remoteID: UInt){
        let channelCollection = db.collection("channels").document("\(remoteID)CHANNEL")
        channelCollection.delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
