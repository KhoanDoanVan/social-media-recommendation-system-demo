//
//  Home.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import SwiftUI
import Kingfisher

struct Home: View {
    
    @StateObject private var vm = HomeVM()
    
    @State private var likeBounce = false
    @State private var commentBounce = false
    @State private var shareBounce = false
    @State private var bookmarkBounce = false
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 10) {
                topNav
                
                listPost
                
                Spacer()
            }
            .padding(.vertical, 15)
            .background(
                LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color.cyan.opacity(0.1), location: 0.0),
                    .init(color: Color.white, location: 0.2),
                    .init(color: Color.white, location: 0.8),
                    .init(color: Color.indigo.opacity(0.1), location: 1.0)
                ]), startPoint: .leading, endPoint: .trailing)
            )
            .onAppear {
                vm.fetchUsers()
                vm.fetchPosts()
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    
    /// Top Nav
    var topNav: some View {
        
        HStack(spacing: 0) {
            Text("PlantLover")
                .font(.system(size: 25))
                .bold()
            
            Spacer()
            
            HStack(spacing: 20) {
                Image(systemName: "heart")
                Image(systemName: "ellipsis.message")
            }
            .font(.system(size: 25))
        }
        .padding(.horizontal, 15)
        
    }
    
    /// List story
    var listStory: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        Circle()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.white)
                        Circle()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(.cyan)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.white)
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    }
                    Spacer()
                    Text("You")
                        .font(.system(size: 18))
                    
                }
                .frame(width: 80, height: 110)
                
                
                if !vm.users.isEmpty {
                    
                    ForEach(vm.users) { user in
                        
                        VStack(spacing: 0) {
                            
                            ZStack {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(.cyan)
                                Circle()
                                    .frame(width: 70, height: 70)
                                    .foregroundStyle(.white)
                                
                                KFImage(URL(string: user.imageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 65, height: 65)
                                    .clipShape(
                                        .circle
                                    )
                            }
                            Spacer()
                            Text(user.username)
                                .font(.system(size: 16))
                            
                        }
                        .frame(width: 80, height: 110)
                        
                    }
                    
                } else {
                    
                    ProgressView()
                    
                }
                
            }
            .padding(.horizontal, 15)
        }
    }
    
    /// List post
    var listPost: some View {
        
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 15) {
                
                listStory
                
                ForEach(vm.postsFetch, id: \.id) { post in
                    cardPost(post: post)
                }
                
                ProgressView()
                    .onAppear {
                        vm.fetchPosts()
                    }
                
            }
        }
        
    }
    
    func cardPost(post: Post) -> some View {
        
        VStack(spacing: 15) {
            
            HStack(spacing: 0) {
                HStack(spacing: 10) {
                    
                    KFImage(URL(string: post.author?.imageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(
                            .circle
                        )
                    
                    Text(post.author?.username ?? "unknown")
                        .bold()
                    
                    if let isFamous = post.author?.isFamous,
                       isFamous
                    {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.blue)
                    }
                    
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
            }
            
            KFImage(URL(string: post.imageUrl))
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .scaledToFit()
                .clipShape(
                    .rect(cornerRadius: 15)
                )
            
            HStack(spacing: 0) {
                
                HStack(spacing: 10) {
                    
                    BounceButton(
                        systemImage: post.isLiked ? "heart.fill" : "heart",
                        color: post.isLiked ? .red : .black
                    ) {
                        vm.actionPost(with: post, .like)
                    }
                    
                    BounceButton(
                        systemImage: post.isCommented ? "message.fill" : "message",
                        color: post.isCommented ? .blue : .black
                    ) {
                        vm.actionPost(with: post, .comment)
                    }
                    
                    BounceButton(
                        systemImage: post.isShared ? "paperplane.fill" : "paperplane",
                        color: post.isShared ? .purple : .black
                    ) {
                        vm.actionPost(with: post, .share)
                    }
                    
                }
                
                Spacer()
                
                BounceButton(
                    systemImage: post.isBookmarked ? "bookmark.fill" : "bookmark",
                    color: post.isBookmarked ? .yellow : .black
                ) {
                    vm.actionPost(with: post, .bookmark)
                }
                
            }
            .font(.system(size: 20))
            
            HStack(spacing: 10) {
                Text(post.author?.username ?? "unknown")
                    .bold()
                
                Text(post.content)
                    .lineLimit(1)
                    .foregroundStyle(Color.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white)
        .clipShape(
            .rect(cornerRadius: 15)
        )
        .padding(.horizontal, 15)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 2)
    }
}

struct BounceButton: View {
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    @State private var isBouncing = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                isBouncing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isBouncing = false
            }
            action()
        } label: {
            Image(systemName: systemImage)
                .foregroundStyle(color)
                .scaleEffect(isBouncing ? 1.2 : 1.0)
        }
    }
}

#Preview {
    NavigationStack {
        Home()
    }
}
