//
//  FavoritesTests.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import XCTest
@testable import MovieApp

@MainActor
final class FavoritesManagerTests: XCTestCase {

    private func makeDefaults() -> UserDefaults {
        let suite = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        return suite
    }

    func testToggleAddsAndRemoves() {
        let manager = FavoritesManager(defaults: makeDefaults())

        XCTAssertFalse(manager.isFavorite(movieID: 1))
        manager.toggleFavorite(movieID: 1)
        XCTAssertTrue(manager.isFavorite(movieID: 1))
        manager.toggleFavorite(movieID: 1)
        XCTAssertFalse(manager.isFavorite(movieID: 1))
    }

    func testPersistenceSurvivesReinit() {
        let defaults = makeDefaults()
        let manager = FavoritesManager(defaults: defaults)
        manager.toggleFavorite(movieID: 7)
        manager.toggleFavorite(movieID: 9)

        // Simulate relaunch with the same store.
        let reloaded = FavoritesManager(defaults: defaults)
        XCTAssertTrue(reloaded.isFavorite(movieID: 7))
        XCTAssertTrue(reloaded.isFavorite(movieID: 9))
        XCTAssertFalse(reloaded.isFavorite(movieID: 1))
    }
}

