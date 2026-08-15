//
//  MobileService.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation

protocol MovieServiceProtocol: Sendable {
    func fetchPopularMovies(page: Int) async throws -> MoviePage
    func searchMovies(query: String, page: Int) async throws -> MoviePage
    func fetchMovieDetails(movieID: Int) async throws -> MovieDetails
    func fetchMovieVideos(movieID: Int) async throws -> [Video]
    func fetchMovieCredits(movieID: Int) async throws -> [CastMember]
}

nonisolated final class MovieService: MovieServiceProtocol {

    private let client: APIClientProtocol
    private let apiKey: String?

    init(client: APIClientProtocol = APIClient(), apiKey: String? = Config.tmdbAPIKey) {
        self.client = client
        self.apiKey = apiKey
    }

    func fetchPopularMovies(page: Int) async throws -> MoviePage {
        let url = try makeURL(
            path: "/movie/popular",
            queryItems: [URLQueryItem(name: "page", value: String(page))]
        )
        return MoviePage(response: try await client.request(MovieResponse.self, endpoint: url))
    }

    func searchMovies(query: String, page: Int) async throws -> MoviePage {
        let url = try makeURL(
            path: "/search/movie",
            queryItems: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        )
        return MoviePage(response: try await client.request(MovieResponse.self, endpoint: url))
    }

    func fetchMovieDetails(movieID: Int) async throws -> MovieDetails {
        let url = try makeURL(path: "/movie/\(movieID)")
        return try await client.request(MovieDetails.self, endpoint: url)
    }

    func fetchMovieVideos(movieID: Int) async throws -> [Video] {
        let url = try makeURL(path: "/movie/\(movieID)/videos")
        return try await client.request(VideosResponse.self, endpoint: url).results
    }

    func fetchMovieCredits(movieID: Int) async throws -> [CastMember] {
        let url = try makeURL(path: "/movie/\(movieID)/credits")
        return try await client.request(Credits.self, endpoint: url).cast
    }

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        guard let apiKey else { throw APIError.missingAPIKey }

        guard var components = URLComponents(string: Config.apiBaseURL + path) else {
            throw APIError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "api_key", value: apiKey)] + queryItems

        guard let url = components.url else { throw APIError.invalidURL }
        return url
    }
}
