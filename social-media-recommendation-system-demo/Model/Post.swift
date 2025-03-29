//
//  Post.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import Foundation

struct Post {
    
    let id: String
    let content: String
    let imageUrl: String
    let category: Category
    let tags: [String]
    let author: String
    
    enum Category: String, Codable {
        case indoorPlants
        case outdoorPlants
        case flowers
        case trees
    }
    
}
