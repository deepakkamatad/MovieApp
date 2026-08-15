//
//  Config.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation

nonisolated enum Config {

    private static let placeholderKey = "your_tmdb_api_key_here"

    static var tmdbAPIKey: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String else {
            return nil
        }

        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != placeholderKey else { return nil }
        return trimmed
    }

    static var isAPIKeyConfigured: Bool { tmdbAPIKey != nil }

    static let apiBaseURL = "https://api.themoviedb.org/3"

    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
}
