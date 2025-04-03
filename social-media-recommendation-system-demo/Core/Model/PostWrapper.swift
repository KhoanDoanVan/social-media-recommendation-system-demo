//
//  PostWrapper.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import Foundation


struct PostWrapper {
    var model: Post
    var score: Double?
    
    mutating func calculateScore() {
        
        let likeWeight = 1.0
        let bookmarkWeight = 0.8
        let shareWeight = 0.6
        let commentWeight = 0.4
        
        let score = (model.isLiked ? likeWeight : 0) +
        (model.isShared ? shareWeight : 0) +
        (model.isCommented ? commentWeight : 0) +
        (model.isBookmarked ? bookmarkWeight : 0)
        
        
        self.score = score > 0 ? score : 0
    }
    
}
