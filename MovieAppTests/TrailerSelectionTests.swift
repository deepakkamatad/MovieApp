//
//  TrailerSelectionTests.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import XCTest
@testable import MovieApp

@MainActor
final class TrailerSelectionTests: XCTestCase {

    func testPrefersYouTubeTrailer() {
        let videos = [
            Video(id: "1", key: "aaa", name: "Teaser", site: "YouTube", type: "Teaser"),
            Video(id: "2", key: "bbb", name: "Trailer", site: "YouTube", type: "Trailer"),
            Video(id: "3", key: "ccc", name: "Clip", site: "Vimeo", type: "Trailer")
        ]
        let selected = MovieDetailViewModel.selectTrailer(from: videos)
        XCTAssertEqual(selected?.key, "bbb")
    }

    func testFallsBackToFirstYouTubeVideo() {
        let videos = [
            Video(id: "1", key: "zzz", name: "Featurette", site: "YouTube", type: "Featurette")
        ]
        XCTAssertEqual(MovieDetailViewModel.selectTrailer(from: videos)?.key, "zzz")
    }

    func testReturnsNilWhenNoYouTube() {
        let videos = [
            Video(id: "1", key: "vvv", name: "Clip", site: "Vimeo", type: "Trailer")
        ]
        XCTAssertNil(MovieDetailViewModel.selectTrailer(from: videos))
    }
}

