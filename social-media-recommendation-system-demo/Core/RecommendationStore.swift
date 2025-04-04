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
    
    /// Queue
    private let queue = DispatchQueue (
        label: "com.social-media-recommendation-service.queue",
        qos: .userInitiated
    )
    
    /// COMPUTE RECOMMENDATION
    func computeRecommendationPosts(
        postsAnalysis: [PostWrapper],
        postsInteracted: [PostWrapper],
        allTags: [String],
        topScore: Int
    ) async throws -> [Post] {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            queue.async { [weak self] in
                
                guard let self else { return }
                
                #if targetEnvironment(simulator)
                continuation.resume(
                    throwing: NSError(
                        domain: "Simulator not supported",
                        code: -1
                    )
                )
                
                #else
                
                /// Data Frame interacted
                let trainingDataFrameInteracted = self.dataFrame(for: postsInteracted, with: allTags)
                
                /// Data Frame Analysis
                let testDataFrameAnalysis = self.dataFrame(for: postsAnalysis, with: allTags)
                
                do {
                    
                    // MARK: - FIXING HERE
                    /// Regressor for train
                    let regresssor = try MLLinearRegressor(
                        trainingData: trainingDataFrameInteracted,
                        targetColumn: "score"
                    )
                    
                    /// Predict scores for posts analysis
                    let predictions = (
                        try regresssor.predictions(
                            from: testDataFrameAnalysis
                        ))
                        .compactMap { value in
                            value as? Double
                        }
                    
                    /// Rank posts by score
                    let sorted = zip(
                            postsAnalysis,
                            predictions
                        )
                        .sorted {
                            $0.1 > $1.1
                        }
                        .prefix(topScore)
                    
                    /// Print each post's score
                    print("Post Scores After Prediction:")
                    for (postWrapper, score) in sorted {
                        print("Post ID: \(postWrapper.model.id), Score: \(score)")
                    }
                    
                    /// Result
                    let result = sorted.map(\.0.model)
                    continuation.resume(returning: result)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
                
                #endif
            }
            
        }
        
    }
    
    /// DATA FRAME
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
