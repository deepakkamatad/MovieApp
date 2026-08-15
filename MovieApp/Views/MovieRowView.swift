//
//  MovieRowView.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import SwiftUI

struct MovieRowView: View {
    let movie: Movie
    var runtimeText: String = "N/A"

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PosterImage(url: movie.posterURL)
                .frame(width: 80, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)

                Label(String(format: "%.1f", movie.voteAverage), systemImage: "star.fill")
                    .font(.subheadline)
                    .foregroundColor(.orange)

                Label(runtimeText, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)

            FavoriteButton(movieID: movie.id)
                .font(.title3)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

struct PosterImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                placeholder
            case .empty:
                ZStack {
                    placeholder
                    ProgressView()
                }
            @unknown default:
                placeholder
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            Color(.secondarySystemBackground)
            Image(systemName: "film")
                .foregroundColor(.secondary)
        }
    }
}

