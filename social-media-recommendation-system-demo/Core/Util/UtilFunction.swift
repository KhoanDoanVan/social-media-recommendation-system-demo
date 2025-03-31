//
//  UtilFunction.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 31/3/25.
//



import Foundation


class UtilFunction {
    
    static func tagsToVector(tags: [String], allTags: [String]) -> [Int] {
        return allTags.map {
            tags.contains($0) ? 1 : 0
        }
    }
    
}
