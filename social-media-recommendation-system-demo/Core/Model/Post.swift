//
//  Post.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import Foundation
import SwiftyJSON

struct Post: Decodable, Identifiable {
    
    let id: String
    let content: String
    let imageUrl: String
    let category: Category
    let tags: [String]
    var author: User?
    
    enum Category: String, Codable {
        case indoorPlants
        case outdoorPlants
        case flowers
        case trees
    }
    
    init(json: JSON) {
        
        self.id = json["id"].stringValue
        self.content = json["content"].stringValue
        self.imageUrl = json["imageUrl"].stringValue
        self.category = Category(rawValue: json["category"].stringValue) ?? .indoorPlants
        self.tags = json["tags"].arrayValue.map { $0.stringValue }
        
        if json["author"].exists() {
            self.author = User(json: json["author"])
        } else {
            self.author = nil
        }
    }
    
}
