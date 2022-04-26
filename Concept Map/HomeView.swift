//
//  HomeView.swift
//  Concept Map
//
//  Created by 澁谷悠大 on 2022/04/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.yellow.edgesIgnoringSafeArea(.all)
                NavigationLink(destination: ContentView()) {
                    Text("画面遷移")
                }
            }
        }
        .navigationViewStyle(.stack)
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
