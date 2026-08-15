//
//  MovieAppApp.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//

import SwiftUI

@main
struct MovieAppApp: App {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(favoritesManager)
        }
    }
}
