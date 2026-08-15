//
//  APIErrorTests.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import XCTest
@testable import MovieApp

final class APIErrorTests: XCTestCase {

    func testMissingAPIKeyThrownWhenNotConfigured() async {
        let service = MovieService(client: APIClient(), apiKey: nil)

        do {
            _ = try await service.fetchPopularMovies(page: 1)
            XCTFail("Expected missingAPIKey to be thrown")
        } catch let error as APIError {
            XCTAssertEqual(error, .missingAPIKey)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testEveryErrorHasNonTechnicalMessage() {
        let errors: [APIError] = [
            .invalidURL,
            .invalidResponse,
            .serverError(500),
            .decodingError,
            .networkError(URLError(.notConnectedToInternet)),
            .missingAPIKey
        ]

        for error in errors {
            XCTAssertFalse(error.userMessage.isEmpty)
        }
    }
}

