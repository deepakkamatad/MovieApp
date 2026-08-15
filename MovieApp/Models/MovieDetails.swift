//
//  MovieDetails.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation

struct MovieDetails: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let genres: [Genre]
    let runtime: Int?
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case genres
        case runtime
        case voteAverage = "vote_average"
    }
}

extension MovieDetails {
    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: Config.imageBaseURL + posterPath)
    }

    var runtimeText: String {
        guard let runtime, runtime > 0 else { return "N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    var genresText: String {
        genres.map(\.name).joined(separator: " • ")
    }
}

