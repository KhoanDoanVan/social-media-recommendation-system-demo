//
//  HomeVM.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import Foundation


final class HomeVM: ObservableObject {
    
    
    @Published var users: [User] = []
    @Published var posts: [Post] = []
    
    @Published var isFetchUsers: Bool = false
    @Published var isFetchPosts: Bool = false
    
    
    /// Fetch Users
    public func fetchUsers() {
        
        self.isFetchUsers = true
        
        UserService.fetchUsers { [weak self] users in
            
            print("Users: \(users)")
            
            DispatchQueue.main.async { [weak self] in
                self?.users = users
                self?.isFetchUsers = false
            }
            
        }
        
    }
    
    /// Fetch Posts
    public func fetchPosts() {
        
        self.isFetchPosts = true
        
        PostService.fetchPosts { [weak self] posts in
            
            print("Posts: \(posts)")
            
            DispatchQueue.main.async { [weak self] in
                self?.posts = posts
                self?.isFetchPosts = false
            }
            
        }
        
    }
    
}
