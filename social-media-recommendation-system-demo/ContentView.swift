//
//  ContentView.swift
//  social-media-recommendation-system-demo
//
//  Created by Đoàn Văn Khoan on 29/3/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selected = 0
    @State private var showCreate = false

    var body: some View {
        
        ZStack {
            TabView(selection: $selected) {
                Home()
                    .tabItem {
                        Image(systemName: selected == 0 ? "house.fill" : "house" )
                            .environment(\.symbolVariants, selected == 0 ? .fill : .none)
                    }
                    .onAppear {
                        selected = 0
                    }
                    .tag(0)
                    .toolbar(.hidden, for: .tabBar)
                
                CreationView()
                    .tabItem {
                        Image(systemName: selected == 1 ? "plus.circle.fill" : "plus.circle" )
                            .environment(\.symbolVariants, selected == 1 ? .fill : .none)
                    }
                    .onAppear {
                        selected = 1
                    }
                    .tag(1)
                    .toolbar(.hidden, for: .tabBar)

                Profile()
                    .tabItem {
                        Image(systemName: selected == 2 ? "person.crop.circle.fill" : "person.crop.circle" )
                            .environment(\.symbolVariants, selected == 2 ? .fill : .none)
                    }
                    .onAppear {
                        selected = 2
                    }
                    .tag(2)
                    .toolbar(.hidden, for: .tabBar)
            }
            .onChange(of: selected) { oldValue, newValue in
                if newValue == 1 {
                    showCreate = true
                }
            }
            .sheet(isPresented: $showCreate, onDismiss: { selected = 0 }, content: {
                CreationView()
            })
            .tint(.cyan)
        }
        
    }
}


#Preview {
    ContentView()
}
