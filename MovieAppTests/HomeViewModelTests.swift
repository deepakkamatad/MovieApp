//
//  HomeViewModelTests.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import XCTest
@testable import MovieApp

@MainActor
final class HomeViewModelTests: XCTestCase {

    func testLoadPopularSuccess() async {
        let service = MockMovieService()
        service.popular = [.stub(id: 1), .stub(id: 2)]
        let vm = HomeViewModel(service: service)

        await vm.loadPopular()

        if case .loaded(let movies) = vm.state {
            XCTAssertEqual(movies.count, 2)
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func testLoadPopularEmpty() async {
        let service = MockMovieService()
        service.popular = []
        let vm = HomeViewModel(service: service)

        await vm.loadPopular()
        XCTAssertEqual(vm.state, .empty)
    }

    func testLoadPopularErrorMapsToUserMessage() async {
        let service = MockMovieService()
        service.errorToThrow = APIError.serverError(500)
        let vm = HomeViewModel(service: service)

        await vm.loadPopular()

        if case .error(let message) = vm.state {
            XCTAssertEqual(message, APIError.serverError(500).userMessage)
        } else {
            XCTFail("Expected error state")
        }
    }

    func testEmptySearchRestoresPopular() async {
        let service = MockMovieService()
        service.popular = [.stub(id: 99)]
        let vm = HomeViewModel(service: service)

        vm.onSearchTextChanged("   ")
        try? await Task.sleep(nanoseconds: 100_000_000)

        if case .loaded(let movies) = vm.state {
            XCTAssertEqual(movies.first?.id, 99)
        } else {
            XCTFail("Expected popular movies to be restored")
        }
        XCTAssertEqual(service.searchCallCount, 0)
    }

    func testDebouncedSearchCallsServiceOnce() async {
        let service = MockMovieService()
        service.searchResults = [.stub(id: 5, title: "Batman")]
        let vm = HomeViewModel(service: service)

        vm.onSearchTextChanged("bat")
        try? await Task.sleep(nanoseconds: 600_000_000)

        XCTAssertEqual(service.searchCallCount, 1)
        XCTAssertEqual(service.lastSearchQuery, "bat")
    }

    // MARK: - Pagination

    func testLoadNextPageAppendsResults() async {
        let service = MockMovieService()
        service.totalPages = 2
        service.pages = [1: [.stub(id: 1), .stub(id: 2)], 2: [.stub(id: 3)]]
        let vm = HomeViewModel(service: service)

        await vm.loadPopular()
        XCTAssertTrue(vm.canLoadMore)

        vm.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)

        if case .loaded(let movies) = vm.state {
            XCTAssertEqual(movies.map(\.id), [1, 2, 3])
        } else {
            XCTFail("Expected loaded state")
        }
        XCTAssertEqual(service.requestedPages, [1, 2])
        XCTAssertFalse(vm.canLoadMore)
    }

    func testDuplicateMoviesAcrossPagesAreIgnored() async {
        let service = MockMovieService()
        service.totalPages = 2
        service.pages = [1: [.stub(id: 1)], 2: [.stub(id: 1), .stub(id: 2)]]
        let vm = HomeViewModel(service: service)

        await vm.loadPopular()
        vm.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)

        if case .loaded(let movies) = vm.state {
            XCTAssertEqual(movies.map(\.id), [1, 2])
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func testLoadNextPageStopsOnLastPage() async {
        let service = MockMovieService()
        service.totalPages = 1
        service.pages = [1: [.stub(id: 1)]]
        let vm = HomeViewModel(service: service)

        await vm.loadPopular()
        XCTAssertFalse(vm.canLoadMore)

        vm.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(service.requestedPages, [1])
    }

    func testNextPageFailureKeepsExistingResults() async {
        let service = MockMovieService()
        service.totalPages = 3
        service.pages = [1: [.stub(id: 1)]]
        let vm = HomeViewModel(service: service)

        await vm.loadPopular()
        service.errorToThrow = APIError.serverError(500)

        vm.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // The already-loaded page must survive a failed append.
        if case .loaded(let movies) = vm.state {
            XCTAssertEqual(movies.map(\.id), [1])
        } else {
            XCTFail("Expected loaded state to be preserved")
        }
        XCTAssertEqual(vm.nextPageError, APIError.serverError(500).userMessage)
        XCTAssertFalse(vm.isLoadingNextPage)
    }

    func testNewSearchResetsPagination() async {
        let service = MockMovieService()
        service.totalPages = 2
        service.pages = [1: [.stub(id: 1)], 2: [.stub(id: 2)]]
        let vm = HomeViewModel(service: service)

        await vm.loadPopular()
        vm.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)

        service.pages = [1: [.stub(id: 50, title: "Batman")]]
        service.totalPages = 1
        vm.onSearchTextChanged("bat")
        try? await Task.sleep(nanoseconds: 600_000_000)

        if case .loaded(let movies) = vm.state {
            XCTAssertEqual(movies.map(\.id), [50])
        } else {
            XCTFail("Expected search results to replace the paginated list")
        }
        XCTAssertFalse(vm.canLoadMore)
    }
}

