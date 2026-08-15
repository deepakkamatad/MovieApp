//
//  FavoriteButton.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import SwiftUI

struct FavoriteButton: View {
    let movieID: Int
    @EnvironmentObject private var favorites: FavoritesManager

    var body: some View {
        Button {
            favorites.toggleFavorite(movieID: movieID)
        } label: {
            Image(systemName: favorites.isFavorite(movieID: movieID) ? "heart.fill" : "heart")
                .foregroundColor(favorites.isFavorite(movieID: movieID) ? .red : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            favorites.isFavorite(movieID: movieID) ? "Remove from favorites" : "Add to favorites"
        )
    }
}

