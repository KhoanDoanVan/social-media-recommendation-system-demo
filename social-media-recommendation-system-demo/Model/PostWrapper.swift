//
//  PostWrapper.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import Foundation


struct PostWrapper<T> {
    let model: T
    var score: Double
}
