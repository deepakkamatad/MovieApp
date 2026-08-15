//
//  Mocks.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation
@testable import MovieApp

final class MockMovieService: MovieServiceProtocol {
    var popular: [Movie] = []
    var searchResults: [Movie] = []
    var detailsToReturn: MovieDetails?
    var videosToReturn: [Video] = []
    var castToReturn: [CastMember] = []
    var errorToThrow: Error?

    var totalPages = 1
    var pages: [Int: [Movie]] = [:]

    private(set) var searchCallCount = 0
    private(set) var lastSearchQuery: String?
    private(set) var requestedPages: [Int] = []

    func fetchPopularMovies(page: Int) async throws -> MoviePage {
        requestedPages.append(page)
        if let errorToThrow { throw errorToThrow }
        return MoviePage(
            movies: pages[page] ?? (page == 1 ? popular : []),
            page: page,
            totalPages: totalPages
        )
    }

    func searchMovies(query: String, page: Int) async throws -> MoviePage {
        searchCallCount += 1
        lastSearchQuery = query
        requestedPages.append(page)
        if let errorToThrow { throw errorToThrow }
        return MoviePage(
            movies: pages[page] ?? (page == 1 ? searchResults : []),
            page: page,
            totalPages: totalPages
        )
    }

    func fetchMovieDetails(movieID: Int) async throws -> MovieDetails {
        if let errorToThrow { throw errorToThrow }
        guard let detailsToReturn else { throw APIError.decodingError }
        return detailsToReturn
    }

    func fetchMovieVideos(movieID: Int) async throws -> [Video] {
        if let errorToThrow { throw errorToThrow }
        return videosToReturn
    }

    func fetchMovieCredits(movieID: Int) async throws -> [CastMember] {
        if let errorToThrow { throw errorToThrow }
        return castToReturn
    }
}

extension Movie {
    static func stub(id: Int, title: String = "Title") -> Movie {
        Movie(id: id, title: title, overview: "overview", posterPath: nil, voteAverage: 7.5)
    }
}

