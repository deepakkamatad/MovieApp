//
//  MovieDetailViewModel.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {

    @Published private(set) var details: MovieDetails?
    @Published private(set) var cast: [CastMember] = []
    @Published private(set) var trailer: Video?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let movieID: Int
    private let service: MovieServiceProtocol

    init(movieID: Int, service: MovieServiceProtocol = MovieService()) {
        self.movieID = movieID
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let details = service.fetchMovieDetails(movieID: movieID)
            async let videos = service.fetchMovieVideos(movieID: movieID)
            async let credits = service.fetchMovieCredits(movieID: movieID)

            let (loadedDetails, loadedVideos, loadedCast) = try await (details, videos, credits)

            self.details = loadedDetails
            self.cast = loadedCast
            self.trailer = Self.selectTrailer(from: loadedVideos)
        } catch let error as APIError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

        isLoading = false
    }

    static func selectTrailer(from videos: [Video]) -> Video? {
        videos.first { $0.site == "YouTube" && $0.type == "Trailer" }
            ?? videos.first { $0.site == "YouTube" }
    }
}

