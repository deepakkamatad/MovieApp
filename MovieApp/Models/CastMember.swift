//
//  CastMember.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation

struct CastMember: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
    }
}

extension CastMember {
    var profileURL: URL? {
        guard let profilePath else { return nil }
        return URL(string: Config.imageBaseURL + profilePath)
    }
}

