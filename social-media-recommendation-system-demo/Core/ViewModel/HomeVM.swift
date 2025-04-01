//
//  HomeVM.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import Foundation
import FirebaseFirestore
import Firebase

final class HomeVM: ObservableObject {
    
    // MARK: - Properties
    @Published var users: [User] = []
    @Published var posts: [Post] = []
    @Published var allPosts: [PostWrapper<Post>] = []
    
    @Published var isFetchUsers: Bool = false
    @Published var isFetchPosts: Bool = false
    
    /// Pagination
    private var pageSize: Int = 3
    private var lastCursorPost: DocumentSnapshot? = nil
    private var isHasMorePosts: Bool = true
    
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
        
        guard !isFetchPosts,
              isHasMorePosts
        else { return }
        
        self.isFetchPosts = true
        
        PostService.fetchPosts(
            lastCursorPost: self.lastCursorPost,
            pageSize: self.pageSize
        ) { [weak self] posts, tags, lastDocumentPost in
            
            print("🏷️ Tags: \(tags)")
            print("👹 LastPosts: \(posts)")
            
            if posts.isEmpty {
                self?.isHasMorePosts = false /// No more posts for get
            } else {
                
                DispatchQueue.main.async { [weak self] in
                    self?.lastCursorPost = lastDocumentPost
                    self?.posts.append(contentsOf: posts)
                    self?.allPosts.append(contentsOf: posts.map { PostWrapper(model: $0) })
                    
                    self?.isFetchPosts = false
                }
                
            }
            
        }
        
    }
    
}
