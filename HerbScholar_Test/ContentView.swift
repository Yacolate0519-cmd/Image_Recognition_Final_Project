//
//  HerbScholar_TestApp.swift
//  HerbScholar_Test
//
//  Created by Yacolate on 2025/12/6.
//

import SwiftUI

struct ContentView: View {
    @State var selectIndex: Int = 1
    var body: some View {
        TabView(selection: $selectIndex){
            HerbQuizView()
                .tabItem {
                    Label("Quiz", systemImage: "newspaper.fill")
                }
                .tag(0)
            
            CameraView()
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }
                .tag(1)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "book.closed")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}



