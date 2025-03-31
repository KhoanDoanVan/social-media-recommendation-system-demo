//
//  RecommendationStore.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 31/3/25.
//

import TabularData
import Foundation


final class RecommendationStore {
    
    private func dataFrame(
        for data: [PostWrapper<Post>],
        with allTags: [String]
    ) -> DataFrame {
        
        var dataFrame = DataFrame()
        
        /// Category
        dataFrame.append(
            column: Column(
                name: "category",
                contents: data.map(\.model.category.rawValue)
            )
        )
        
        /// Tags
        let tagVectors = data.map {
            UtilFunction.tagsToVector(tags: $0.model.tags, allTags: allTags)
        }
        
        for (index, tag) in allTags.enumerated() {
            
            let columnData = tagVectors.map {
                $0[index]
            }
            
            dataFrame.append(
                column: Column(
                    name: "tag_\(tag)",
                    contents: columnData
                )
            )
        }
        
        
        return dataFrame
    }
    
}
