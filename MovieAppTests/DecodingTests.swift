//
//  DecodingTests.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import XCTest
@testable import MovieApp

final class DecodingTests: XCTestCase {

    func testMovieDecodingMapsSnakeCase() throws {
        let json = """
        {
            "id": 42,
            "title": "The Matrix",
            "overview": "A hacker learns the truth.",
            "poster_path": "/poster.jpg",
            "vote_average": 8.7
        }
        """.data(using: .utf8)!

        let movie = try JSONDecoder().decode(Movie.self, from: json)

        XCTAssertEqual(movie.id, 42)
        XCTAssertEqual(movie.title, "The Matrix")
        XCTAssertEqual(movie.posterPath, "/poster.jpg")
        XCTAssertEqual(movie.voteAverage, 8.7, accuracy: 0.001)
    }

    func testMovieResponseDecoding() throws {
        let json = """
        { "page": 1, "results": [], "total_pages": 5, "total_results": 100 }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(MovieResponse.self, from: json)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 5)
    }

    func testRuntimeTextFormatting() {
        let details = MovieDetails(
            id: 1, title: "X", overview: "", posterPath: nil,
            genres: [], runtime: 135, voteAverage: 8.0
        )
        XCTAssertEqual(details.runtimeText, "2h 15m")

        let noRuntime = MovieDetails(
            id: 1, title: "X", overview: "", posterPath: nil,
            genres: [], runtime: nil, voteAverage: 8.0
        )
        XCTAssertEqual(noRuntime.runtimeText, "N/A")
    }
}

