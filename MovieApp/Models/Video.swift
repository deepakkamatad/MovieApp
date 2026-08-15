//
//  Video.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation

struct Video: Codable, Identifiable, Equatable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}

extension Video {
    var youtubeURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}

