//
//  PostService.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 31/3/25.
//

import Foundation
import FirebaseFirestore
import SwiftyJSON
import Firebase

final class PostService {
    
    static func fetchPosts(
        lastCursorPost: DocumentSnapshot?,
        pageSize: Int,
        completion: @escaping (
            [Post],
            [String],
            DocumentSnapshot?
        ) -> Void
    ) {
        
    
        let query: Query

        if let lastPost = lastCursorPost {
            query = Firestore.firestore()
                .collection("posts")
                .order(by: "id")
                .start(afterDocument: lastPost)
                .limit(to: pageSize)
        } else {
            query = Firestore.firestore()
                .collection("posts")
                .order(by: "id")
                .limit(to: pageSize)
        }
        
        if let lastPost = lastCursorPost {
            query.start(afterDocument: lastPost)
        }
        
        query.getDocuments {
            snapshot,
            error in
            
            if let error {
                print("Fetch Posts Failed: \(error.localizedDescription)")
                completion([], [], nil)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("❌ Fetch Documents Posts Failed")
                completion([], [], nil)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            var posts: [Post] = []
            var uniqueTags: Set<String> = []
            
            for document in documents {
                
                let json = JSON(document.data())
                var post = Post(json: json)
                
                uniqueTags.formUnion(post.tags)
                
                dispatchGroup.enter()
                
                UserService.fetchUserById(
                    with: json["author"].stringValue,
                    completion: { user in
                    post.author = user
                    posts.append(post)
                    dispatchGroup.leave()
                })
                
            }
            
            dispatchGroup.notify(queue: .main) {
                
                let lastSnapshot = documents.last
                                
                completion(
                    posts,
                    Array(uniqueTags),
                    lastSnapshot
                )
            }
            
        }
        
    }
    
}
