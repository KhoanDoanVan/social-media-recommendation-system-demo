//
//  User.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//


import SwiftyJSON

struct User: Identifiable, Codable {
    
    let id: String
    let name: String
    let username: String
    let imageUrl: String
    let isFamous: Bool
    
    init(json: JSON) {
        
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.username = json["username"].stringValue
        self.imageUrl = json["imageUrl"].stringValue
        self.isFamous = json["isFamous"].boolValue
        
    }

}
