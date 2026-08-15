//
//  APIClient.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case networkError(Error)
    case missingAPIKey

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError),
             (.missingAPIKey, .missingAPIKey):
            return true
        case let (.serverError(a), .serverError(b)):
            return a == b
        case (.networkError, .networkError):
            return true
        default:
            return false
        }
    }

    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Something went wrong. Please try again."
        case .invalidResponse, .serverError:
            return "Server is unavailable right now. Please try again later."
        case .decodingError:
            return "We couldn't read the data. Please try again."
        case .networkError:
            return "No internet connection. Check your network and retry."
        case .missingAPIKey:
            return "TMDb API key is not configured. Add TMDB_API_KEY to Secrets.xcconfig (see README)."
        }
    }
}

protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(_ type: T.Type, endpoint: URL) async throws -> T
}

nonisolated final class APIClient: APIClientProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ type: T.Type, endpoint: URL) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: endpoint)
        } catch {
            throw APIError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverError(http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}

