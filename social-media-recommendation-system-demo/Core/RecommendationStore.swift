//
//  RecommendationStore.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 31/3/25.
//

import TabularData
import Foundation
#if canImport(CreateML)
import CreateML
#endif

final class RecommendationStore {
    
    private func dataFrame(
        for wrapperData: [PostWrapper],
        with allTags: [String]
    ) -> DataFrame {
        
        var dataFrame = DataFrame()
        
        /// Category
        dataFrame.append(
            column: Column(
                name: "category",
                contents: wrapperData.map(\.model.category.rawValue)
            )
        )
        
        
        /// Tags
        let tagVectors = wrapperData.map {
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
        
        /// Like
        dataFrame.append(
            column: Column(
                name: "like",
                contents: wrapperData.map { $0.model.isLiked ? 1 : 0 }
            )
        )
        
        /// Comment
        dataFrame.append(
            column: Column(
                name: "comment",
                contents: wrapperData.map { $0.model.isCommented ? 1 : 0 }
            )
        )
        
        /// Share
        dataFrame.append(
            column: Column(
                name: "share",
                contents: wrapperData.map { $0.model.isShared ? 1 : 0 }
            )
        )
        
        /// Bookmark
        dataFrame.append(
            column: Column(
                name: "bookmark",
                contents: wrapperData.map { $0.model.isBookmarked ? 1 : 0 }
            )
        )
        
        /// Score (Output:  label)
        dataFrame.append(
            column: Column(
                name: "score",
                contents: wrapperData.map { $0.score ?? 0.0 }
            )
        )
        
        return dataFrame
    }
    
}
