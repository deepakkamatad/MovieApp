//
//  MoviePage.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation

struct MoviePage: Equatable {
    let movies: [Movie]
    let page: Int
    let totalPages: Int

    var hasMorePages: Bool { page < totalPages }
}

extension MoviePage {
    init(response: MovieResponse) {
        self.init(
            movies: response.results,
            page: response.page,
            totalPages: response.totalPages
        )
    }
}
