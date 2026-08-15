//
//  FavoritesManager.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation
import Combine

@MainActor
final class FavoritesManager: ObservableObject {

    @Published private(set) var favoriteMovieIDs: Set<Int>

    private let defaults: UserDefaults
    private let storageKey = "favorite_movie_ids"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.array(forKey: storageKey) as? [Int] ?? []
        self.favoriteMovieIDs = Set(stored)
    }

    func isFavorite(movieID: Int) -> Bool {
        favoriteMovieIDs.contains(movieID)
    }

    func toggleFavorite(movieID: Int) {
        if favoriteMovieIDs.contains(movieID) {
            favoriteMovieIDs.remove(movieID)
        } else {
            favoriteMovieIDs.insert(movieID)
        }
        persist()
    }

    private func persist() {
        defaults.set(Array(favoriteMovieIDs), forKey: storageKey)
    }
}
