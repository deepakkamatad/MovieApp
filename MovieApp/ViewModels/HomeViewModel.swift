//
//  HomeViewModel.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded([Movie])
        case empty
        case error(String)
    }

    private enum Feed: Equatable {
        case popular
        case search(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var nextPageError: String?
    @Published var searchText: String = ""

    private let service: MovieServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var nextPageTask: Task<Void, Never>?

    private var feed: Feed = .popular
    private var movies: [Movie] = []
    private var loadedMovieIDs: Set<Int> = []
    private var currentPage = 0
    private var totalPages = 1

    private let prefetchThreshold = 5
    private let debounceNanoseconds: UInt64 = 400_000_000

    var canLoadMore: Bool { currentPage < totalPages }

    init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
    }

    func loadPopular() async {
        feed = .popular
        await loadFirstPage()
    }

    func onSearchTextChanged(_ text: String) {
        searchTask?.cancel()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchTask = Task { await loadPopular() }
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: self.debounceNanoseconds)
            guard !Task.isCancelled else { return }
            self.feed = .search(trimmed)
            await self.loadFirstPage()
        }
    }

    func retry() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        feed = trimmed.isEmpty ? .popular : .search(trimmed)
        await loadFirstPage()
    }

    func loadNextPageIfNeeded(currentItem movie: Movie) {
        guard case .loaded(let movies) = state,
              !isLoadingNextPage,
              nextPageError == nil,
              canLoadMore,
              let index = movies.firstIndex(of: movie),
              index >= movies.count - prefetchThreshold
        else { return }

        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoadingNextPage, canLoadMore else { return }

        nextPageTask?.cancel()
        nextPageTask = Task { [weak self] in
            guard let self else { return }

            let requestedFeed = self.feed
            self.isLoadingNextPage = true
            self.nextPageError = nil
            defer { self.isLoadingNextPage = false }

            do {
                let page = try await self.fetchPage(self.currentPage + 1, for: requestedFeed)
                guard !Task.isCancelled, requestedFeed == self.feed else { return }
                self.append(page)
            } catch is CancellationError {
            } catch let error as APIError {
                guard !Task.isCancelled, requestedFeed == self.feed else { return }
                self.nextPageError = error.userMessage
            } catch {
                guard !Task.isCancelled, requestedFeed == self.feed else { return }
                self.nextPageError = "Couldn't load more movies."
            }
        }
    }

    private func loadFirstPage() async {
        nextPageTask?.cancel()
        isLoadingNextPage = false
        nextPageError = nil
        resetPagination()

        let requestedFeed = feed
        state = .loading

        do {
            let page = try await fetchPage(1, for: requestedFeed)
            guard !Task.isCancelled, requestedFeed == feed else { return }
            append(page)
            if movies.isEmpty { state = .empty }
        } catch is CancellationError {
        } catch let error as APIError {
            guard !Task.isCancelled, requestedFeed == feed else { return }
            state = .error(error.userMessage)
        } catch {
            guard !Task.isCancelled, requestedFeed == feed else { return }
            state = .error("Something went wrong. Please try again.")
        }
    }

    private func fetchPage(_ page: Int, for feed: Feed) async throws -> MoviePage {
        switch feed {
        case .popular:
            return try await service.fetchPopularMovies(page: page)
        case .search(let query):
            return try await service.searchMovies(query: query, page: page)
        }
    }

    private func append(_ page: MoviePage) {
        currentPage = page.page
        totalPages = page.totalPages

        // TMDb can repeat items across pages; keep the list unique so
        // SwiftUI's `List` never sees duplicate identifiers.
        let newMovies = page.movies.filter { loadedMovieIDs.insert($0.id).inserted }
        movies.append(contentsOf: newMovies)

        if !movies.isEmpty {
            state = .loaded(movies)
        }
    }

    private func resetPagination() {
        movies = []
        loadedMovieIDs = []
        currentPage = 0
        totalPages = 1
    }
}
