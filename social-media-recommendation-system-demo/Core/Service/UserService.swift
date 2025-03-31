//
//  UserService.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import FirebaseFirestore
import SwiftyJSON

final class UserService {
    
    /// Fetch entire users
    static func fetchUsers(completion: @escaping ([User]) -> Void) {
        
        Firestore.firestore()
            .collection("user")
            .getDocuments {
                snapshot,
                error in
                
                if let error {
                    print("❌ Fetch Users Failed: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("❌ Fetch Documents Users Failed")
                    completion([])
                    return
                }
                
                let users: [User] = documents.compactMap { document in
                    let json = JSON(document.data())
                    return User(json: json)
                }
                
                completion(users)
            }
        
    }
    
    
    
    /// Fetch user by id
    static func fetchUserById(
        with userId: String,
        completion: @escaping (User?) -> Void
    ) {
        
        print("UserID: \(userId)")
        
        Firestore.firestore()
            .collection("user")
            .document(userId)
            .getDocument { snapshot, error in
                
                if let error {
                    print("❌ Fetch User by Id \(userId) Failed: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let snapshot,
                      snapshot.exists,
                      let data = snapshot.data()
                else {
                    print("❌ User document not found")
                    completion(nil)
                    return
                }
                
                let json = JSON(data)
                let user = User(json: json)
                
                completion(user)
            }
    }
    
}
