//
//  ContentView.swift
//  UmamuAPI Project
//
//  Created by alumne on 19/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Primera Tab: UmamusumeListView
            UmamusumeListView()
                .tabItem {
                    Label("Umamusume", systemImage: selectedTab == 0 ? "list.star.fill" : "list.bullet")
                }
                .tag(0)
            
            // Segunda Tab: SparkListView
            SparkListView()
                .tabItem {
                    Label("Sparks", systemImage: selectedTab == 1 ? "sparkles" : "bolt.fill")
                }
                .tag(1)
        }
        .accentColor(.pink)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
