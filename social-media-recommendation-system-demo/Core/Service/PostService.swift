//
//  PostService.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 31/3/25.
//

import Foundation
import FirebaseFirestore
import SwiftyJSON

final class PostService {
    
    static func fetchPosts(
        lastCursorPost: String?,
        pageSize: Int,
        completion: @escaping ([Post], [String]) -> Void
    ) {
        
        Firestore.firestore()
            .collection("posts")
            .getDocuments {
                snapshot,
                error in
                
                if let error {
                    print("Fetch Posts Failed: \(error.localizedDescription)")
                    completion([], [])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("❌ Fetch Documents Posts Failed")
                    completion([], [])
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
                    
                    UserService.fetchUserById(with: json["author"].stringValue, completion: { user in
                        post.author = user
                        posts.append(post)
                        dispatchGroup.leave()
                    })
                    
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(
                        posts,
                        Array(uniqueTags)
                    )
                }
                
            }
        
    }
    
}
