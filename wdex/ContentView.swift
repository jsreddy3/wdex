//
//  ContentView.swift
//  wdex
//
//  Created by Jaiden Reddy on 3/6/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            MainView()
        }
        .background(Color.white)
    }
}

struct MainView: View {
    var body: some View {
        VStack {
            CollectionsView()
            BottomNavBar()
        }
        .background(Color.white)
    }
}
