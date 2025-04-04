//
//  HomeVM.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import Foundation
import FirebaseFirestore
import Firebase


enum PostActionHandler: CaseIterable {
    case like
    case comment
    case share
    case bookmark
}

final class HomeVM: ObservableObject {
    
    // MARK: - Properties
    @Published var users: [User] = []
    @Published var postsFetch: [Post] = []
    @Published var allPostsWillAnalysis: [PostWrapper] = []
    @Published var allPostsUserInteracted: [PostWrapper] = []
    
    @Published var isFetchUsers: Bool = false
    @Published var isFetchPosts: Bool = false
    
    /// Pagination
    private var pageSize: Int = 5
    private var lastCursorPost: DocumentSnapshot? = nil
    private var isHasMorePosts: Bool = true
    
    /// Recommnedation
    private let recommendationStore: RecommendationStore
    
    // MARK: - Init
    init(recommendationStore: RecommendationStore = RecommendationStore()) {
        self.recommendationStore = recommendationStore
    }
    
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
        ) {
            [weak self] posts,
            tags,
            lastDocumentPost in
            
            Task {

                do {
                    let postsWrapper = posts.map{ PostWrapper(model: $0) }
                    let postsForAnalysis = (self?.allPostsWillAnalysis ?? []) + postsWrapper
                    
                    let postsPotential = try await self?.recommendationStore.computeRecommendationPosts(
                        postsAnalysis: postsForAnalysis,
                        postsInteracted: self?.allPostsUserInteracted ?? [],
                        allTags: tags,
                        topScore: 3
                    )
                    
                    /// Post UI
                    if let postsPotential,
                       !postsPotential.isEmpty
                    {
                        DispatchQueue.main.async { [weak self] in
                            self?.lastCursorPost = lastDocumentPost
                            
                            /// Post Fetch
                            self?.postsFetch.append(contentsOf: postsPotential)
                            
                            self?.isFetchPosts = false
                        }
                        
                        self?.allPostsWillAnalysis = []
                        
                        /// Update posts will analysis from posts don't recommendation
                        for post in postsPotential {
                            
                            for postAnalysis in postsForAnalysis {
                                
                                if post.id != postAnalysis.model.id {
                                    self?.allPostsWillAnalysis.append(postAnalysis)
                                }
                                
                            }
                            
                        }
                        
                    } else {
                        self?.isHasMorePosts = false /// No more posts for get
                    }
                    
                } catch {
                    print("Error: \(error)")
                }
                
            }
            
        }
        
    }
    
    /// Action Post
    public func actionPost(
        with post: Post,
        _ action: PostActionHandler
    ) {
        
        // MARK: Case Changes UI Posts
        switch action {
        case .like:
            self.activeOrRemoveActiveActionPost(
                post: post,
                action: .like,
                state: post.isLiked ? false : true
            )
        case .comment:
            self.activeOrRemoveActiveActionPost(
                post: post,
                action: .comment,
                state: post.isCommented ? false : true
            )
        case .share:
            self.activeOrRemoveActiveActionPost(
                post: post,
                action: .share,
                state: post.isShared ? false : true
            )
        case .bookmark:
            self.activeOrRemoveActiveActionPost(
                post: post,
                action: .bookmark,
                state: post.isBookmarked ? false : true
            )
        }
               
        // MARK: Case Exists in Post Interacted
        if let indexPostInteracted = self.allPostsUserInteracted.firstIndex(where: {
            $0.model.id == post.id
        }) {
            
            switch action {
            case .like:
                self.allPostsUserInteracted[indexPostInteracted].model.isLiked = false
            case .comment:
                self.allPostsUserInteracted[indexPostInteracted].model.isCommented = false
            case .share:
                self.allPostsUserInteracted[indexPostInteracted].model.isShared = false
            case .bookmark:
                self.allPostsUserInteracted[indexPostInteracted].model.isBookmarked = false
            }
            
            let post = self.allPostsUserInteracted[indexPostInteracted].model
            
            if !self.anotherPropertyStillExsits(action, post) {
                removePostFromPostInteractedByIndex(index: indexPostInteracted)
            }
            
            return
        }
        // MARK: Case Not Exist in Post Interacted
        else {
            
            var newPostInteracted = PostWrapper(model: post)
            
            switch action {
            case .like:
                newPostInteracted.model.isLiked = true
            case .comment:
                newPostInteracted.model.isCommented = true
            case .share:
                newPostInteracted.model.isShared = true
            case .bookmark:
                newPostInteracted.model.isBookmarked = true
            }
            
            /// Add to post interacted
            self.allPostsUserInteracted.append(newPostInteracted)
        }
    }
    
    
    /// Remove Post from posts interacted
    private func removePostFromPostInteractedByIndex(
        index: Int
    ) {
        self.allPostsUserInteracted.remove(at: index)
    }
    
    /// Check ability of exists another property true in model
    private func anotherPropertyStillExsits(
        _ actionChecked: PostActionHandler,
        _ model: Post
    ) -> Bool {
        
        var exists: Bool = false
        
        for action in PostActionHandler.allCases {
            
            if action != actionChecked {
                
                if action == .bookmark {
                    exists = model.isBookmarked
                } else if action == .comment {
                    exists = model.isCommented
                } else if action == .like {
                    exists = model.isLiked
                } else if action == .share {
                    exists = model.isShared
                }
                
            }
            
            if exists {
                return true
            }
            
        }
        
        return false
        
    }
    
    // MARK: - Action
    
    /// Like
    private func activeOrRemoveActiveActionPost(
        post: Post,
        action: PostActionHandler,
        state: Bool
    ) {
        
        guard let index = self.postsFetch.firstIndex(where: {
            $0.id == post.id
        }) else {
            print("❌ Find index from Post List Failed")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            switch action {
            case .like:
                self?.postsFetch[index].isLiked = state
            case .comment:
                self?.postsFetch[index].isCommented = state
            case .share:
                self?.postsFetch[index].isShared = state
            case .bookmark:
                self?.postsFetch[index].isBookmarked = state
            }
        }
        
    }
    
    
    
}
