//
//  HomeVM.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import Foundation
import FirebaseFirestore

final class HomeVM: ObservableObject {
    
    // MARK: - Properties
    @Published var users: [User] = []
    @Published var posts: [Post] = []
    @Published var allPosts: [PostWrapper<Post>] = []
    
    @Published var isFetchUsers: Bool = false
    @Published var isFetchPosts: Bool = false
    
    /// Pagination
    private var pageSize: Int = 5
    private var lastCursorPost: DocumentSnapshot? = nil
    
    // MARK: - Methods
    /// Fetch Users
    public func fetchUsers() {
        
        self.isFetchUsers = true
        
        UserService.fetchUsers { [weak self] users in
                        
            DispatchQueue.main.async { [weak self] in
                self?.users = users
                self?.isFetchUsers = false
            }
            
        }
        
    }
    
    /// Fetch Posts
    public func fetchPosts() {
        
        self.isFetchPosts = true
        
        PostService.fetchPosts(
            lastCursorPost: lastCursorPost?.documentID,
            pageSize: self.pageSize
        ) { [weak self] posts, tags in
            
            print("🏷️ Tags: \(tags)")
                        
            DispatchQueue.main.async { [weak self] in
                self?.posts = posts
                self?.allPosts = posts.map {
                    PostWrapper(model: $0)
                }
                self?.isFetchPosts = false
            }
            
        }
        
    }
    
}
